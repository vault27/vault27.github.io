# Packet forwarding

## Forwarding types

- Layer 2 forwarding = switching
- Layer 3 forwarding
- MPLS forwarding
- Policy based forwarding - PBF - it’s a different decision mechanism for L3 forwarding
- SD-WAN forwarding - Advanced PBF with telemetry-driven path choice
- Segment routing

## Routing/forwarding/switching

- Routing = process of building the best path table
- Forwarding = process of sending packets using that table
- Routing runs on CPU
- Forwarding runs in hardware (ASIC / NPU)
- So forwarding must be extremely fast.
- That’s why vendors separate: Control plane and Data plane

## Layer 2 forwarding

- Done using Layer 2 addresses - MAC addresses and VLAN tags
- Using a MAC address table
- Every VLAN has its own MAC table
- Packet remain unchanged
- If destination MAC is not in MAC table - flood frame to all ports in the same VLAN (except incoming port)
- Layer 2 control plane: STP, VTP, VLAN tagging, MAC Learning & Aging, flood control, MAC limits


## Layer 3 forwarding

- Forwarding = Data Plane
- Layer 3 forwarding is packet switching based on IP routing information
- Forwarding is:
  - Looking up destination IP in forwarding table (FIB)
  - Choosing outgoing interface
  - Rewriting L2 header
  - Decrementing TTL
  - Sending packet out
- In two words: Layer 2 frame rewrite and send it to correct interface
- IPv4: TTL and checksum are modified  
- IPv6: only the Hop Count is decremented  
- Optimization goals: speed up the construction of new Layer 2 frame and egress interface lookup
- Dynamic routing protocols
- FIB/RIB
- Administartive distance
- Metrics
- Redistribution
- Filtering in redistribution
- Filtering in routes exchange
- Summarization

Routing table input data:

- Static routes with administrative distance
- Connected networks
- Routes from dynamic routing protocols

If ECMP is enabled several routes can be installed to the same destination, we can do it with static routes as well.

Which route to use is determined by administrative distance or metric.  
On Linux (and, I think, on Windows) priority is determined by metric, but it is not the case on macOS as you correctly pointed out. Instead of assigning metrics to individual routes, macOS assigns priorities to interfaces.  

## Forwarding methods

- Process switching
- Fast switching
- CEF - Cisco Express Forwarding

**Process switching**

- Router receives a frame, FCS is checked, router checks the Ethernet Type field for the packet type
- Data Link header and trailer can now be discarded
- Header checksum is first verified for IPv4, no header checksum for IPv6
- Router checks destination IP: router itself or not
- Router checks that TTL is > 1, if not: ICMP Time Exceed + drop
- Router checks routing table: outgoing interface + next-hop address - the most computation intensive task
- Find out next hop Layer 2 address: ARP, IP/DLCI - the most computation intensive task
- Change TTL + recalculate checksum
- New Data Link frame is built: new header and trailer, including new FCS

  **Fast switching**

- First packet goes through process switching, results are added to fast switching cache or route cache. The cache contains the destination IP address, the next-hop information, and the data-link header information that needs to be added to the packet before forwarding. An entry **per each destination address, not per destination subnet/prefix**. All future packets with the same destination addresses use this data and are switched faster. Also called **route once, forward many times**  
- Draw backs: first packets are fully processed, cache entries are timed out quickly, if tables are changed, route entries are invalid, load balancing can only occur per destination  
- Not used any more 

Disable Fast switching:

```
Router#configure terminal
Router(config)#interface Ethernet 0
Router(config-if)#no ip route-cache
```

**CEF - Cisco Express Forwarding**

- Enabled by default on most platforms
- Cisco Express Forwarding (CEF) maintains two tables in the data plane
- Preconstruct the Layer 2 frame headers and egress interface information for each next hop, and keep them ready in an adjacency table stored in the router’s memory 
- This adjacency table can be constructed immediately as the routing table is populated
- No need to visit ARP table for every packet
- Routing table is very slow to search and contains too much data, that is why the destination prefixes alone from the routing table can be stored in a separate data structure called the Forwarding Information Base, or **FIB**, optimized for rapid lookups (usually, tree-based data structures meet this requirement)
- Each entry in the FIB that represents a destination prefix can instead contain
a pointer toward the particular entry in the adjacency table that stores the appropriate rewrite information: Layer 2 frame header and egress interface indication
- After the FIB and adjacency table are created, the routing table is not used anymore
- Routing Information Base (RIB)—it is the master copy of routing information from which the FIB and other structures are populated, but it is not necessarily used to route packets itself
- RIBs for different routing protocols are different case
- CEF is implemented in software.  
- High end routers use specialized circuits (specifically, Ternary Content Addressable Memory [TCAM]) to store the FIB contents and perform even faster lookups 

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

show ipv6 cef
```

## Routing

- Routing = Control Plane
- Routing is:
  - Learning routes (via static routes or routing protocols)
  - Building the routing table (RIB)
  - Running algorithms (SPF, BGP path selection, etc.)

```
Routing (control plane)
      ↓
Builds RIB
      ↓
Programs FIB
      ↓
Forwarding (data plane) uses FIB
```


## Routing protocols

### History

- EGP - 1982
- IGRP - 1985
- RIPv1 - 1988
- IS-IS - 1990
- OSPFv2 - 1991
- EIGRP - 1992
- RIPv2 - 1994
- BGP - 1995
- RIPng - 1995
- BGPv6, OSPFv3 - 1999
- IS-ISv6 - 2000

Types:

- Purpose: Interior Gateway Protocol (IGP) or Exterior Gateway Protocol (EGP)
- Operation: Distance vector protocol, link-state protocol, or path-vector protocol
- Behavior: Classful (legacy) or classless protocol

Distance vector

- RIP
- EIGRP

Link-state

- OSPF
- IS-IS

Path vector

- BGP

Routing Protocol Characteristics

- Speed of convergence: Speed of convergence defines how quickly the routers in the network topology share routing information and reach a state of consistent knowledge. The faster the convergence, the more preferable the protocol. Routing loops can occur when inconsistent routing tables are not updated due to slow convergence in a changing network
- Scalability: Scalability defines how large a network can become, based on the routing protocol that is deployed. The larger the network is, the more scalable the routing protocol needs to be.
- Classful or classless (use of VLSM): Classful routing protocols do not include the subnet mask and cannot support variable-length subnet mask (VLSM). Classless routing protocols include the subnet mask in the updates. Classless routing protocols support VLSM and better route summarization
- Resource usage: Resource usage includes the requirements of a routing protocol such as memory space (RAM), CPU utilization, and link bandwidth utilization. Higher resource requirements necessitate more powerful hardware to support the routing protocol operation, in addition to the packet forwarding processes
- Implementation and maintenance: Implementation and maintenance describes the level of knowledge that is required for a network administrator to implement and maintain the network based on the routing protocol deployed

### Concepts 

- Link State routing protocol - every router builds a tree or a graph of the whole network. Then launches shortest path algorithm to find out best paths to all destinations. These paths go to a Routing table
- Generally some variant of Dijkstra's algorithm is used
- LPM - Long Prefix Match - network with longest mask will be chosen from routing table. Default route has the shortest prefix and the lowest priority
- Classful routing protocols (RIPv1 and IGRP) do not advertise subnet mask information
- Contiguous network: A single classful network in which packets sent between every pair of subnets will pass only through subnets of that same classful network, without having to pass through subnets of any other classful network
- Discontiguous network: A single classful network in which packets sent between at least one pair of subnets must pass through subnets of a different classful network - 192.168.1.0 > 10.2.3.0 > 192.168.3.0
- Split horizon - loop-prevention technique used in distance-vector routing protocols - router will not advertise a route back out the same interface from which it learned that route

## Administrative distances

Route with lowest distance is installed into the routing table  
Can be changed with distance command

- Connected - 0
- Static - 1
- EIGRP summary route - 5
- EBGP - 20
- EIGRP (internal) - 90
- IGRP - 100
- OSPF - 110
- IS-IS - 115
- RIP - 120
- EIGRP (external) - 170
- iBGP - 200
- Unreachable - 255

## Redistribution

- Redistribution is configured on that side where we redistribute
- If we want to redistribute to BGP from OSPF, we configure it in BGP
- When we use redistribution, espeacially double mutual: ospf > bgp > ospf - loops are possible - why? - tags are used to help?

## Routing table

Format:

```
Route source | Administrative distance/metric | Next hop | Time stamp | Outgoing interface
R | 172.16.4.0/26 | 120/2 | via 1.1.1.1 | 00:00:12 | Etherntet 0/0
```

- Route source: Identifies how the route was learned. Directly connected interfaces have two route source codes. C identifies a directly connected network. Directly connected networks are automatically created whenever an interface is configured with an IP address and activated. L identifies that this is a local route. Local routes are automatically created whenever an interface is configured with an IP address and activated
- S: Identifies that the route was manually created by an administrator to reach a specific network. This is known as a static route.
- D: Identifies that the route was learned dynamically from another router using the EIGRP routing protocol.
- O: Identifies that the route was learned dynamically from another router using the OSPF routing protocol.
- R: Identifies that the route was learned dynamically from another router using the RIP routing protocol.

### Route maps

Mostly used for route redistribution: permit or deny redistribution based on match + changing something in route with set command as a bonus. Plus they are used to generate default route in OSPF, BGP routing policies(in neighbor statement, in export import commands for RT to control exported and imported routes) and in policy routing.  
- If/Then/Else logic
- One or more commands
- Processed in sequential order
- match command for matching parametres
- Match all packets - no match command and permit action
- Set command to change parametres
- Name is mandatory
- Action: permit or deny, this is for redistribution: redistribute or not
- Default deny all at the end
- There can be many permit and deny statements in one route map with different match commands
- If route does not match permit rule(ACL for example), it will be considered by next rule, not dropped
- Routes are dropped only when they match deny rule or implied deny all as a last rule in route-map
- Executed from the lowest sequence of number to the highest sequence
- If the match is found in the route map instance, the execution of the other further route map will stop
- If the route map is applied in the policy routing environments, the packets which don't meet a match criteria are forwarded based on a routing table
- If there are multiple match statements in route-rule - they all have to match

**Match commands for route redistribution**
- interface
- ip address - route prefix and length via ACL or prefix list
- next hop
- route source - ACL
- metric
- route type - internal | external | type-1 | type-2 | level-1 | level-2
- tag

**Set commands for redistribution**
- level - level-1 | level-2| level-1-2 | stub-area | backbone
- metric for OSPF, RIP, IS-IS
- metric for EIGRP/IGRP
- metric type - internal | external | type-1 | type-2 - for IS-IS and OSPF
- tag

### Distribute list

- Work together with ACLs
- Can be attached directly to neighbor BGP command

Example on Cisco IOS, allow sent to BGP neighbor all networks except one:

```
access-list 1 deny   159.33.0.0 0.0.0.255
access-list 1 permit any

neighbor 192.168.5.1 distribute-list 1 out
```

## ECMP

Rapidly changing latency, packet reordering and maximum transmission unit (MTU) differences within a network flow, which could disrupt the operation of many Internet protocols, most notably TCP and path MTU discovery. RFC 2992 - load balances based on hash of packet header.

## Load balance

- It is also called Load Sharing in the Unicast FIB
- Same AD and cost - load balance
- The IGRP and EIGRP routing processes also support unequal cost load balancing
- It can be per packet and per destination and per flow
- Per-packet load balancing guarantees equal load across all links, however, there is potential that the packets can arrive out of order at the destination because differential delay can exist within the network
- Per packet load balancing does disable the forwarding acceleration by a route cache, because the route cache information includes the outgoing interface
- For per-packet load balancing, the forwarding process determines the outgoing interface for each packet when it looks up the route table and picks the least used interface. This ensures equal utilization of the links but is a processor intensive task and impacts the overall forwarding performance
- Per packet is not used
- If we use fast switching, per destination load balance is used, in other case per packet is used
- Per destination is not used in our days as well
- Polarization of traffic - when most of the traffic goes via the same link
- Per flow is used everywhere
- The unicast RIB installs this best path set into the Forwarding Information Base (FIB) for use by the forwarding plane
- The forwarding plane uses a load-sharing algorithm to select one of the installed paths in the FIB to use for a given data packet
- Load sharing uses the same path for all packets in a given flow. A flow is defined by the load-sharing method that you configure
- Load-sharing method can consist of src/dst IP, src/dst port, in different combinations, then hash is calculated on these values
- Default load sharing method in Nexus: address source-destination port source-destination
- That is why VXLAN traffic always goes via different links - because source UDP port is always different. And usual ping always goes via the same link

Show method on Nexus:

```
leaf-1# show ip load-sharing
IPv4/IPv6 ECMP load sharing:
Universal-id (Random Seed): 316862977
Load-share mode : address source-destination port source-destination
GRE-Outer hash is disabled
Concatenation is disabled
Rotate: 32
```

Configure method on Nexus

```
switch(config)# ip load-sharing address source-destination
```

## FHRP: GLBP/HSRP/VRRP

First hop redundancy protocol (FHRP)
- Hot Standby Router Protocol (HSRP) - Cisco's initial, proprietary standard developed in 1998
- Gateway Load Balancing Protocol (GLBP) is a Cisco proprietary protocol that attempts to overcome the limitations of existing redundant router protocols by adding basic load balancing functionality - round robin. Allows setting priorities and weights. 224.0.0.102 to send hello packets to their peers every 3 seconds over UDP 3222.
- Virtual Router Redundancy Protocol (VRRP) - an open standard protocol

**HSRP**

Higher priority is better  

Config example

```
interface Vlan230
description Test
ip address 172.31.13.154 255.255.255.240
standby 230 ip 172.31.13.156
standby 230 priority 130
standby 230 preempt
```

Verification

```
router#show standby 
Vlan2 - Group 2
  State is Active
    1 state change, last state change 48w6d
  Virtual IP address is 172.22.33.1
  Active virtual MAC address is 0000.0c07.ac02 (MAC In Use)
    Local virtual MAC address is 0000.0c07.ac02 (v1 default)
  Hello time 3 sec, hold time 10 sec
    Next hello sent in 2.800 secs
  Preemption enabled
  Active router is local
  Standby router is 172.22.33.3, priority 120 (expires in 9.408 sec)
  Priority 130 (configured 130)
  Group name is "hsrp-Vl2-2" (default)
```

## VRF

- Virtual router: separate control plane and data plane, overlapping IP addresses, VPN in general
- VRF was developed for MPLS
- Full VRF - is when many VRFs are tied together
- VRF Lite: minimum configuration, no MPLS
- VRFs are not devided in terms of DATA plane, only in control plane, they have access to each other's interfaces
- If we configure VRF with legacy command ip vrf, then only ipv4 config will be delted from the interface + routing protocols config on interface
- VRF names are case sensitive. Best practice: name all with upper case
- Two routers with 2 VRFs are connected with TRUNK with 2 VLANs with 2 sub interfaces and with the same IPs on subs
- Firewall is connected to switch with TRUNK as well, but IPs are different on subs, because on FW they are in one VRF
- When we configure VRF connection via VRF and use eBGP we have to allow on some routers seeing their own AS number in updates
- For eBGP we use one router instance with one AS number, but different neighboors for each VRF
- On Firewall we configure 2 VLAN interfaces and 2 neighbors, which have the same AS, on Nexus we also need to configure option disable-peer-as-check so it forwards updates from one VRF to another with the same AS
- To configure route leaking between VRFs as a backup path we need to make local route between VRFs less valuable then remote route from firewall. It is done via route map and increasing Local Preference for remote route
- If route is leaked to VRF, we need to consider, that it will be spreaded along all this VRF via IGP

Each VRF:
- An IP routing table (RIB)
- A CEF FIB, populated based on that VRF’s RIB
- A separate instance or process of the routing protocol 

**Ping from VRF on Nexus**

```
ping 192.168.1.1 vrf GOOGLE
```

**Configuration on Nexus**

```
vrf context GOOGLE
interface Ethernet1/3
  no switchport
  vrf member GOOGLE
  ip address 192.168.1.1/24
  no shutdown
router bgp 64701
vrf GOOGLE
    address-family ipv4 unicast
      redistribute direct route-map connected
    neighbor 172.16.1.1
      address-family ipv4 unicast
```
**Configuration on IOS**
```
#ipv4 only
ip vrf [name]

#ipv4 and ipv6
vrf definition [name]

interface
ip vrf forwarding [name]
or
vrf forwarding [name]

router ospf router vrf VRFA
```

**Configuration on IOS XR**

```
vrf [name]
router bgp [ASN]
vrf [name]
rd [value]
interface GigabitEthernet0/0/0/0
• vrf [namel]
```

## Verification on Cisco IOS

**Show all VRFs in a system with their RD**

```
switch#show ip vrf
  Name                             Default RD            Interfaces
  Mgmt-vrf                         <not set>             Gi0/0
  core                             4294963200:5          Lo0
                                                         Twe1/0/9.905
                                                         Twe1/0/34.10
                                                         Vl530
                                                         Vl595
```

**Show all config related to VRF**

```
show run vrf
```

**Show all IP addresses for VRF**

```
switch#show ip vrf interfaces core
Interface              IP-Address      VRF                              Protocol
Lo0                    10.90.2.1       core                             up      
Twe1/0/9.905           10.90.0.21      core                             up      
Twe1/0/34.10           10.90.3.100     core                             down    
Vl530                  10.90.0.230     core                             up      
Vl595                  10.90.0.97      core                             down    
Vl908                  10.90.0.85      core                             up 
```

**Show in which VRF all IPs**

```
switch#show ip vrf interfaces 
Interface              IP-Address      VRF                              Protocol
Gi0/0                  10.90.1.4       Mgmt-vrf                         up      
Lo0                    10.90.2.1       core                             up      
Twe1/0/9.905           10.90.0.21      core                             up      
Twe1/0/34.10           10.90.3.100     core                             down    
Vl530                  10.90.0.230     core                             up      
Vl595                  10.90.0.97      core                             down    
```

## Route leaking

- Route leaking can be done via BGP, static routes or physical cable :)
- It can be configured between two VRFs. With any IGP used. BGP is started locally on one router. For every VRF we configure RD, RT which is use to export routes, RT which are used to import routes (we may import several RTs). Routes go from VRF to global VPNv4 table, and from this table they go to particlar VRF
- After enabling leaking we need to consider that leaked routes will start spreading across VRFs, so we may require to configure route maps with ip prefixes to increase/decrease local preference or weight to control routes priority, we also may need to filter particular routes
- When we configure leaks, we need to consider which exact networks will be leaked, if we leak all routing table, it will be a mess, we control it with a route map via ip prefix list. In BGP route map is attached to neighbor command to set high local preference for example for all routes from this neighbor. Route map is also used to set low local preference and filter which routes to export from particular VRF.

Example of configuration: route leaking via BGP, if firewall is down then leaking routes are active, by default they have low local prefrence and not active. Configured on Nexus 9000. Two VRFs: Google and Nasa. Configuration is for Spine-1.

```
# IP prefixes to filter what export from VRF
ip prefix-list GOOGLE seq 5 permit 192.168.1.0/24
ip prefix-list GOOGLE seq 10 permit 192.168.4.0/24
ip prefix-list NASA seq 5 permit 192.168.2.0/24
ip prefix-list NASA seq 10 permit 192.168.3.0/24

# Route map to set local preference for routes from FW
route-map FW permit 10
  set local-preference 200
  
# Route maps to filter what is exported from VRF and set RT
route-map GOOGLE permit 10
  match ip address prefix-list GOOGLE
  set local-preference 50
  set extcommunity rt 64600:1
route-map NASA permit 10
  match ip address prefix-list NASA
  set local-preference 50
  set extcommunity rt 64600:2

vrf context GOOGLE
  rd 64600:1
  address-family ipv4 unicast
    route-target import 64600:2
    export map GOOGLE
vrf context NASA
  rd 64600:2
  address-family ipv4 unicast
    route-target import 64600:1
    export map NASA
    
interface Ethernet1/1.1
  encapsulation dot1q 2
  vrf member GOOGLE
  ip address 172.16.1.1/31
  no shutdown

interface Ethernet1/1.2
  encapsulation dot1q 3
  vrf member NASA
  ip address 172.16.1.1/31
  no shutdown
  
interface Ethernet1/2.1
  encapsulation dot1q 2
  vrf member GOOGLE
  ip address 172.16.2.1/31
  no shutdown

interface Ethernet1/2.2
  encapsulation dot1q 3
  vrf member NASA
  ip address 172.16.2.1/31
  no shutdown
  
router bgp 64600
  router-id 10.10.1.1 
  vrf GOOGLE
    address-family ipv4 unicast
    neighbor 172.16.1.0
      remote-as 64701
      address-family ipv4 unicast
        allowas-in 1
    neighbor 172.16.2.0
      remote-as 64702
      address-family ipv4 unicast
        allowas-in 1
    neighbor 172.16.3.1
      remote-as 64601
      address-family ipv4 unicast
        allowas-in 3
        route-map FW in
  vrf NASA
    address-family ipv4 unicast
    neighbor 172.16.1.0
      remote-as 64701
      address-family ipv4 unicast
        allowas-in 1
    neighbor 172.16.2.0
      remote-as 64702
      address-family ipv4 unicast
        allowas-in 1
    neighbor 172.16.4.1
      remote-as 64601
      address-family ipv4 unicast
        allowas-in 1
        route-map FW in  
```
![image](https://user-images.githubusercontent.com/116812447/209544910-db2af0ff-7a61-4539-87ba-d2dc2ac26bd0.png)

## Black hole

- Black hole refers to a place in the network where incoming or outgoing traffic is silently discarded (or "dropped"), without informing the source that the data did not reach its intended recipient
- A null route or black hole route is a network route (routing table entry) that goes nowhere. Matching packets are dropped (ignored) rather than forwarded, acting as a kind of very limited firewall
- Null routes are typically configured with a special route flag, but can also be implemented by forwarding packets to an illegal IP address such as 0.0.0.0, or the loopback address
- Null routing has an advantage over classic firewalls since it is available on every potential network router (including all modern operating systems), and adds virtually no performance impact

## BFD

Bidirectional Forwarding Detection
- RFC:  5880, 5881, 7130
- Builds neighborship between peers
- Detects link failure in subsecond
- Sends alert to BFD enabled protocol, for example OSPF
- OSPF tears down relationship and chooses new route
- Support VRF
- For Layer 3 port channels used by BFD, you must enable LACP on the port channel
- For Layer 2 port channels used by SVI sessions, you must enable LACP on the port channel
- You can configure BFD at the global level and at the interface level. The interface configuration overrides the global configuration
- For physical ports that are members of a port channel, the member port inherits the primary port channel BFD configuration
- You can configure SHA-1 authentication of BFD packets
- BFD Echo Function - ? - enabled by default
- Cisco NX-OS uses the packet Time to Live (TTL) value to verify that the BFD packets came from an adjacent BFD peer. For all asynchronous and echo request packets, the BFD neighbor sets the TTL value to 255 and the local BFD process verifies the TTL value as 255 before processing the incoming packet. For the echo response packet, BFD sets the TTL value to 254
- Disable Internet Control Message Protocol (ICMP) redirect messages on BFD-enabled interfaces: no ip redirects, no ipv6 redirects
- Disable the IP packet verification check for identical IP source and destination addresses
- Slow timer - ? - 2000 miliseconds - default
- The BFD feature is just not supported on Nexus 9000v
- Mode - Asynchronious - default - ?
- Port-channel - logical mode - ?
- Session parametres:
  - Desired minimum transmit interval—The interval at which this device wants to send BFD hello messages - 50 milliseconds - default
  - Required minimum receive interval—The minimum interval at which this device can accept BFD hello messages from another BFD device - 50 milliseconds - default
  - Detect multiplier—The number of missing BFD hello messages from another BFD device before this local device detects a fault in the forwarding path - default 

Configuration for Nexus

```
#Enable feature
switch(config)# feature bfd

#Configure GLobal
# We can skip this and use defaults
bfd interval 50 min_rx 50 multiplier 3
bfd slow-timer 2000
bfd echo-interface loopback 1 3

#Enable BFD for all OSPF interfaces
switch(config)# router ospf 200
switch(config-router)# bfd

#Enable BFD on one OSPF interface
switch(config-router)# interface ethernet 2/1
switch(config-if)# ip ospf bfd

#Enable BFD for BGP neighbor
switch(config-router)# neighbor 209.165.201.1 remote-as 64497
switch(config-router-neighbor)# bfd
```

## Route server

- Many ISP come to IX
- To work they need a full mesh BGP peering between each other
- To avoid it they all peer with route server

## Nonstop Forwarding with Stateful Switchover

- The protocol commonly used in conjunction with NSF is the Hot Standby Router Protocol (HSRP)
- NSF ensures that during a failover event, the forwarding plane remains operational, allowing packet forwarding to continue uninterrupted
- Without NSF a couple of packets maybe lost
- Here's an example of a configuration for redundancy and NSF on an active router using the Hot Standby Router Protocol (HSRP) as the redundancy protocol:

```
interface GigabitEthernet0/0
 ip address 192.168.1.1 255.255.255.0
 standby 1 ip 192.168.1.254
 standby 1 priority 120
 standby 1 preempt

interface GigabitEthernet0/1
 ip address 10.0.0.1 255.255.255.0
 standby 2 ip 10.0.0.254
 standby 2 priority 110
 standby 2 preempt

router ospf 1
 network 192.168.1.0 0.0.0.255 area 0
 network 10.0.0.0 0.0.0.255 area 0

ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0
ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/1

ip routing nsf
```