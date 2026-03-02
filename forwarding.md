# Packet forwarding

**Taxonomy**

```
                         PACKET FORWARDING
                               |
        -------------------------------------------------
        |                                               |
   L2 FORWARDING                                   L3 FORWARDING
 (Frame Switching)                              (Packet Switching)
        |                                               |
   MAC Table (CAM)                               Routing Table (RIB)
        |                                               |
   Basic CAM Lookup                           FIB + Adjacency Table
                                                      |
                                              Forwarding Method
                                                      |
      -----------------------------------------------------------------
      |                         |                                   |
 Process Switching         Fast Switching                         CEF
 (Software / CPU)          (Route Cache)                Cisco Express Forwarding
      |                         |                                   |
  Slow Path                Flow-based cache                 Topology-based FIB
  Per-packet CPU           First packet slow                No per-flow cache
  Full routing lookup      Next packets fast                Deterministic
                                                      |
                                    --------------------------------------------
                                    |                                          |
                             Centralized Forwarding                  Distributed Forwarding
                             (Single RP / CPU)                      (Line cards / ASICs)
                                    |                                          |
                              Software CEF                               Hardware CEF
                                    |                                          |
                               CPU-driven FIB                           FIB in ASIC / TCAM
                                                                          Wire-speed lookup
```

## Terms

- Packet forwarding - is the data-plane process of receiving a packet/frame on one interface and transmitting it out another interface according to forwarding state programmed by the control plane
- Layer 2 forwarding is the process of forwarding Ethernet frames based on destination MAC address within the same broadcast domain (VLAN)
- Switching = Layer 2 forwarding
- Layer 3 forwarding is the process of forwarding IP packets based on destination IP address using a forwarding information base (FIB)
- Routing is the control-plane process of discovering network topology and computing best paths to IP networks
- MPLS forwarding - is a data-plane process in which packets are forwarded based on locally significant labels rather than destination IP address
- Policy based forwarding - PBF - it’s a different decision mechanism for L3 forwarding
- SD-WAN forwarding - Advanced PBF with telemetry-driven path choice
- Segment routing forwarding - is a data-plane process where packets are forwarded according to a pre-encoded ordered list of segments carried inside the packet header
  - SR-MPLS → Uses MPLS labels as segments
  - SRv6 → Uses IPv6 Segment Routing Header (SRH)
- Routing runs on CPU
- Forwarding runs in hardware (ASIC / NPU) in advanced devices, in simple devices it runs on CPU
- So forwarding must be extremely fast
- That’s why vendors separate: Control plane and Data plane
- Routing = thinking
- Forwarding = doing

**Forwarding Taxonomy**

```
Forwarding Types
├── Layer 2 (MAC-based)
├── Layer 3 (IP-based)
├── MPLS (label-based)
└── Segment Routing (source-encoded path)
```

**Control and Data Planes**

```
Control Plane:
    Routing protocols
        ↓
    RIB (routing table)
        ↓
    FIB (forwarding table)

Data Plane:
    Packet arrives
        ↓
    FIB lookup
        ↓
    Forward out interface
```

## Layer 2 forwarding

- Using a MAC address table
- Used when devices are on the same subnet
- Every VLAN has its own MAC table
- Packet remain unchanged
- If destination MAC is not in MAC table - flood frame to all ports in the same VLAN (except incoming port)
- Layer 2 control plane: STP, VTP, VLAN tagging, MAC Learning & Aging, flood control, MAC limits

## Layer 3 forwarding

- Looking up destination IP in forwarding table (FIB)
- Choosing outgoing interface
- Find out destination MAC with ARP protocol
- If IP address is not in ARP table, the device broadcasts ARP request to whole L2 domain
- Rewriting L2 header
- Decrementing TTL
- Sending packet out
- In two words: Layer 2 frame rewrite and send it to correct interface
- IPv4: TTL and checksum are modified  
- IPv6: only the Hop Count is decremented  
- Optimization goals: speed up the construction of new Layer 2 frame and egress interface lookup
- Layer 3 forwarding is required when hosts are in different subnets

**Routed interface types**

- Routed subinterfaces - logical subinterfaces on a router port

```
conf t
int g0/0/10.10
ip address 10.10.10.1 255.255.255.0
```

- Switched virtual interface - SVI - VLAN interface

```
conf t
interface vlan 10
ip address 10.10.10.1 255.255.255.0
no shut
```

- Routed switch port - convert a Layer 2 switch port to a routed switch port

```
conf t
int gi1/0/14
no switchport
ip address 10.10.10.1 255.255.255.0
no shutdown
```

## Layer 3 forwarding methods

- Process switching - software switching - slow path
- Fast switching
- CEF - Cisco Express Forwarding

### Process switching
 
- Done on CPU
- It is fallback for CEF - for punted packets, which cannot be processed by CEF
- Punted packet - A packet that is sent from the hardware forwarding path (ASIC) to the CPU for processing
- Examples of punted packets: packets destined to the router itself(OSPF, BGP), packets which are too complex
- Router receives a frame, FCS is checked, router checks the Ethernet Type field for the packet type
- Data Link header and trailer can now be discarded
- Header checksum is first verified for IPv4, no header checksum for IPv6
- Router checks destination IP: router itself or not
- Router checks that TTL is > 1, if not: ICMP Time Exceed + drop
- Router checks routing table: outgoing interface + next-hop address - the most computation intensive task
- Find out next hop Layer 2 address: ARP, IP/DLCI - the most computation intensive task
- Change TTL + recalculate checksum
- New Data Link frame is built: new header and trailer, including new FCS

### Fast switching

- First packet goes through process switching, results are added to fast switching cache or route cache. The cache contains the destination IP address, the next-hop information, and the data-link header information that needs to be added to the packet before forwarding. An entry **per each destination address, not per destination subnet/prefix**. All future packets with the same destination addresses use this data and are switched faster. Also called **route once, forward many times**  
- Draw backs: first packets are fully processed, cache entries are timed out quickly, if tables are changed, route entries are invalid, load balancing can only occur per destination  
- Not used any more 

Disable Fast switching:

```
Router#configure terminal
Router(config)#interface Ethernet 0
Router(config-if)#no ip route-cache
```

### CEF - Cisco Express Forwarding

**Architecture**

```
======================== CEF INTERNAL STRUCTURE ========================

CONTROL PLANE
-----------------------------------------------------------------------

        Routing Protocols
                |
                v
        +-------------------------+
        |          RIB            |
        |-------------------------|
        | Prefix                  |
        | Next-Hop IP             |
        | Metric                  |
        | Protocol                |
        +-------------------------+
                |
                | Best path installed
                v

DATA PLANE
-----------------------------------------------------------------------

        +-------------------------+
        |           FIB           |
        |-------------------------|
        | Prefix                  |
        | Adjacency Index  ----+--------------------+
        +-------------------------+                 |
                                                   |
                                                   v
                                        +-------------------------+
                                        |     ADJACENCY TABLE     |
                                        |-------------------------|
                                        | Index (Adj ID)          |
                                        | Next-Hop IP             |
                                        | Outgoing Interface      |
                                        | Destination MAC         |
                                        | Encapsulation / Rewrite |
                                        +-------------------------+

Hardware Implementation
-----------------------------------------------------------------------

        FIB entries programmed into TCAM
                |
                v
        TCAM lookup -> returns Adjacency Index
                |
                v
        ASIC uses adjacency entry to rewrite frame

=========================================================================

Forwarding Flow:

1) Packet arrives
2) Destination IP lookup in TCAM
3) TCAM returns FIB entry
4) FIB entry contains Adjacency Index
5) Adjacency entry provides full L2 rewrite string
6) Frame rewritten and forwarded

=========================================================================
```

**Example**

```
RIB:
  10.10.0.0/16 -> 192.168.1.1

FIB:
  10.10.0.0/16 -> Adj ID 42

Adjacency Table:
  ID 42:
     Next-Hop IP: 192.168.1.1
     Out Int: Gi0/0
     Dest MAC: 00:11:22:33:44:55
     Rewrite string: <prebuilt L2 header>
```

- So forwarding never consults the RIB
- It directly jumps via index
- Enabled by default on most platforms
- Cisco Express Forwarding (CEF) maintains two tables in the data plane
- Preconstruct the Layer 2 frame headers and egress interface information for each next hop, and keep them ready in an adjacency table stored in the router’s memory 
- This adjacency table can be constructed immediately as the routing table is populated
- No need to visit ARP table for every packet
- Routing table is very slow to search and contains too much data, that is why the destination prefixes alone from the routing table can be stored in a separate data structure called the Forwarding Information Base, or **FIB**, optimized for rapid lookups (usually, tree-based data structures meet this requirement)
- Each entry in the FIB that represents a destination prefix can instead contain a pointer toward the particular entry in the adjacency table that stores the appropriate rewrite information: Layer 2 frame header and egress interface indication
- After the FIB and adjacency table are created, the routing table is not used anymore
- Routing Information Base (RIB) — it is the master copy of routing information from which the FIB and other structures are populated, but it is not necessarily used to route packets itself
- RIBs for different routing protocols are different case
- CEF maybe implemented in software - CPU
- High end routers use specialized circuits (specifically, Ternary Content Addressable Memory [TCAM]) to store the FIB contents and perform even faster lookups + ASICs + NPUs

**Activation**

```
ip cef
ipv6 cef
```

**Verification**

```
#Shows what is inside FIB: Prefix, Next hop and Interface

show ip cef 
Router# show ip cef
Prefix              Next Hop             Interface
0.0.0.0/0           drop                 Null0 (default route handler entry)
0.0.0.0/32          receive
10.0.0.1/32         receive
10.0.0.2/32         10.0.9.2             FastEthernet0/1
10.0.0.3/32         10.0.9.6             FastEthernet1/0
10.0.0.4/32         10.0.9.2             FastEthernet0/1
10.0.0.5/32         10.0.9.13            FastEthernet0/0
10.0.9.0/30         attached             FastEthernet0/1

- Attached: The prefix is on a directly connected network, and the router knows how to reach it
- Receive: The router is the destination for these packets (e.g., interface IP, broadcast address, or loopback)
- Drop: Packets are discarded, commonly seen with 0.0.0.0/0 (Null0) or when features are not supported
- Punt: Though not in your list, this often appears alongside these, indicating packets are sent to the CPU for processing

show ipv6 cef
```

## Basic CAM

Used for:

- Layer 2 Switching
- MAC address table
- L2 forwarding decisions
- What it matches:  Destination MAC → Output port
- Single field lookup. Exact match only. No masking. No QoS awareness
- Searches in one cycle, No searching loop
- What Happens If We Use RAM?

```
Imagine 50,000 MAC entries.
With RAM:
Read entry 1 → compare
Read entry 2 → compare
Read entry 3 → compare
…
Until match found
That’s too slow for:
Millions of packets per second.
CPU would melt.
```

- What Happens With CAM?

```
Input: MAC address
Hardware checks ALL entries simultaneously
Match found in one cycle
Return associated port
No loop.
No CPU.
No iteration.
```

- **Why MAC Uses CAM (Not TCAM)**

```
MAC lookup requires:
Exact 48-bit match.
No masking.
No longest prefix.
So regular binary CAM is enough.
Routing requires:
Masking
Longest prefix
That needs TCAM.
```

- MAC table is not stored in CPU DRAM
- It lives inside the ASIC.

## TCAM

- Ternary content addressable memory
- Extension of CAM architecture
- The hardware can match on multiple header fields simultaneously, not just MAC
- Example fields:
  - Source IP
  - Destination IP
  - Source port
  - Destination port
  - Protocol (TCP/UDP)
  - DSCP (QoS marking)
  - VLAN ID
  - PCP
- Now the switch is not just doing L2 switching
- It can do: `L3 routing, ACL filtering, QoS classification, Policy routing`
- Special memory used for fast parallel lookups in switches/routers
- Why “Ternary”? Normal memory = 0 or 1 - TCAM cell =0,1,X (don’t care) - That X is the power - It allows masking
- Example: `1100XXXX`
- Matches: `11000000, 11001111, etc.`
- Perfect for: `IP prefixes (longest match), ACL masks`
- FIB example

```
10.0.0.0/8
10.1.0.0/16
10.1.1.0/24
```

- Packet arrives: 10.1.1.5
- `Compares against all entries at once`, Multiple matches possible, Hardware selects longest prefix match
- All comparisons happen simultaneously, Not one by one, One clock cycle
- Normal RAM compares Row by Row
- When packet bits enter TCAM:
  - They are broadcast to all rows
  - Each row has tiny logic gates
  - Those gates evaluate: Match? No match?
- Done in hardware, No CPU
- Lives in ASIC or Forwarding chip
- `Not general system RAM. Expensive. Power hungry. Limited size`
- TCAM space is limited
- Too many: Routes, ACL entries, QoS rules > TCAM exhaustion > New entries cannot be installed > Traffic may be dropped or to software forwarded 
- TCAM entries are stored in Value, Mask and Result (VMR) format
- Value - the bits you want to match - Example (IP prefix):`11000000 10101000 00000001 00000000` - (192.168.1.0)
- Mask - Defines which bits matter - Mask bit meaning: 1 = compare this bit and 0 = ignore this bit (don't care) - Example for /24:- Mask: `11111111 11111111 11111111 00000000` - So last 8 bits are ignored
- Result - What action to take if match happens - Example Result: → Forward to next-hop 10.0.0.1 → Use egress port 5 → Apply QoS queue 3 → Drop - TCAM does not just say “match - It immediately returns the associated action

**TCAM tables**

- Different TCAM tables on a switch contain different amount of entries
- For example, 4094 for VLANs, 32000 for MAC addresses
- This distribution can be controlled with SDM(Switching DataBase Manager) templates
- `sdm prefer vlan|advanced`
- `show sdm prefer` 

## Centralized forwarding

- Pactet arrives to ingress line card
- Transmitted to forwarding engine on the route processor
- Forwarding engine forwards packet to egress line card

## Distributed forwarding

- Every line card has its own forwarding engine
- Packet arrives to line card and processed by local engine
- Then via switch fabric it is transmitted directly to egress line card, bypassing Route Processor

## Statefull switchover

- Router may have 2 router processors for redundancy
- Statefull switchover is a redundance feature for cisco routers
- 2 route processors with syncronised configuration
- If main router processor fails, secondary one immediately takes control
- In this case routing protocol adjecency flaps and clears routing table
- Nonstop forwarding (NSF) or nonstop routing (NSR) allows router to maintain CEF entries for a short duration and continue forwarding packets until control plane recovers
