# IPSec Complete Guide

## Table of contents

- [1. Introduction](#1-introduction)
- [2. SPI](#2-spi)
- [3. SA](#3-sa)
    - [3.1 Phase 1 - IKE SA](#31-phase-1---ike-sa)
    - [3.2 Phase 2 - IPSec SA](#32-phase-2---ipsec-sa)
    - [3.3 Manual and Dynamic SAs](#33-manual-and-dynamic-sas)
- [4. Transform Set](#4-transform-set)
- [5. Traffic Selectors](#5-traffic-selectors)
- [6. IKEv1](#6-ikev1)
    - [6.1 Workflow](#61-workflow)
    - [6.2 Phase 1](#62-phase-1)
        - [6.2.1 IKE identiry](#621-ike-identity)
        - [6.2.2 Main Mode](#622-main-mode)
        - [6.2.3 Aggressive Mode](#623-aggressive-mode)

## 1 Introduction

**What is it?**

- IPsec is not a single protocol, but a framework for securing IP traffic
- It is primarily designed to protect unicast traffic in point-to-point VPNs
- IPsec establishes a secure control channel first - Phase 1, then negotiates data-protecting channel - Phase 2
- The control channel is used only for key management and crypto parametres negotioation for data channel
- User data is protected separately using Data channel
- All communications inside both tunnels are encrypted and authenticated
- Routing protocols that rely on multicast or broadcast (e.g., OSPF, EIGRP) cannot run directly over classic IPsec tunnels
- To support such protocols, a GRE tunnel is built first, and IPsec is used to encrypt the GRE traffic
- IPSec consists of 3 protocols:
    - ESP - data plane
    - AH(obsolete) - data plane
    - IKE v1 or v2 - control plane

**Why it was invented?**

- To add security to IP networking itself
- Original Internet had no built-in security
- IP provides no: Encryption, Authentication, Integrity protection, Anti-replay protection
- Anyone on the path could: Read packets, Modify packets, Spoof IP addresses, Inject traffic
- Security at higher layers was not enough: Every application   had to implement its own security, traffic like routing, management, or custom protocols remained exposed
- IPsec enabled: Site-to-site VPNs, Remote-access VPNs, Secure inter-datacenter links

**Who and when invented it?**

- Internet Engineering Task Force (IETF) in 1995
- 1996–1998 - BSD Linux Implementations
- Late 1990s – early 2000s: Cisco, Checkpoint, Juniper

**What is required to establish a secure channel over an untrusted network?**

- Peers must securely exchange cryptographic keys for encryption and packet authentication in a way that prevents any third party from learning those keys - Diffie Hellman algorithm is used for this
- Peers must mutually authenticate each other, so that each side can verify the identity of the other - preshared keys, login/passwords, certificates, MFA are used for this
- Peers must negotiate the cryptographic algorithms that will be used to encrypt and decrypt data - transmission protocol itself is used for negotiation, symmetric encryption algorithms  are used: 3DES, AES...
- Peers must negotiate the algorithms that will be used to provide integrity and authentication for each packet - transmission protocol itself is used for negotiation, HMAC algorithms are for authentication of each packet and its integrity: 
- After the secure session is established, peers exchange data packets that are encrypted and authenticated using the negotiated algorithms and derived keys.

**IPSec goals**

- Mutual authentication of peers
- Secure key establishment
- Negotiation of security parameters
- Creation and management of Security Associations
- Data encryption - confidentiality
- Data integrity - data is not modified
- Authentication of packet origin - Verify that packets truly come from the expected peer - Cryptographic authentication per packet
- Anti-replay protection
- Traffic protection policy enforcement - Define which traffic is protected and how
- Secure transport over untrusted networks

**High level diagram**

```
IPsec Framework
──────────────────────────────────────────────

IKE  → Key Management / Control Plane
│
│── Versions
│   ├── IKEv1
│   │   ├── Based on: ISAKMP + Oakley + SKEME
│   │   │
│   │   ├── Phase 1  → Establish IKE SA
│   │   │   ├── Main Mode
│   │   │   └── Aggressive Mode
│   │   │
│   │   └── Phase 2  → Establish IPsec SAs
│   │       └── Quick Mode
│   │
│   └── IKEv2
│       ├── Unified protocol
│       ├── IKE SA    → Control channel
│       └── CHILD SA → Data channel
│
│── Authentication
│   ├── Pre-Shared Key (PSK)
│   ├── Digital Certificates
│   ├── Xauth (IKEv1)
│   └── EAP (IKEv2)
│
│── Transport
│   ├── UDP 500       (IKE)
│   └── UDP 4500      (IKE NAT-T)
│
──────────────────────────────────────────────

ESP  → Data Protection
│
│── Functions
│   ├── Encryption
│   ├── Integrity
│   └── Anti-replay
│
│── Transport
│   ├── IP Protocol 50
│   └── UDP 4500      (ESP NAT-T)
│
│── Modes
│   ├── Tunnel Mode
│   │   └── Encrypts entire IP packet
│   │
│   └── Transport Mode
│       └── Encrypts payload only
│
──────────────────────────────────────────────

AH  → Integrity / Authentication
│
│── Functions
│   └── Integrity + Authentication only
│
│── Transport
│   └── IP Protocol 51
│
│── Modes
│   ├── Tunnel Mode
│   └── Transport Mode
```

**RFC**

- RFC 4301 — Security Architecture for the Internet Protocol (IPsec architecture)
- RFC 2411 — IP Security Document Roadmap
- RFC 4303 — IP Encapsulating Security Payload (ESP)
- RFC 4302 — IP Authentication Header (AH)
- RFC 2409 — Internet Key Exchange (IKEv1)
- RFC 2407 — ISAKMP DOI for IPsec
- RFC 2408 — ISAKMP
- RFC 2412 — Oakley Key Determination Protocol
- RFC 7296 — Internet Key Exchange Protocol Version 2 (IKEv2)
- RFC 3947 — Negotiation of NAT-Traversal in the IKE
- RFC 3948 — UDP Encapsulation of IPsec ESP Packets
- RFC 5998 — Use of EAP Authentication in IKEv2
- RFC 3706 - DPD
- XAUTH (IKEv1, non-RFC standard)
- IKEv1 Mode Config - No RFC
- Vendor RA extensions

**Terms**  
  
IPSec has several new terms, which are used everywhere in protocol descriptions. These terms are:

- SPI
- Transform set
- SA
- Traffic Selectors/Proxy IDs

Below is their meaning and description

## 2 SPI

- SPI stands for `Security Parameters Index`
- `There are two types of SPI`: IKE SPI used in Phase 1 IKEv1, IKE_SA_INIT in IKEv2 and IPSec SPI used used in Phase 2 IKEv1, IKE_AUTH IKEv2
- IKE SPI is also called `Cookie`  and is 64 bits and identifies Security Association (SA) in IKE Tunnel (Control Tunnel)
- In IKEv1, the values in the ISAKMP header are formally called cookies, but the RFC explicitly defines them as SPIs for the ISAKMP/IKE SA
- `IKEv2 removed the word cookie entirely`
- IPSec SPI is 32 bits - identifies a specific Security Association (SA) in IPsec (Data Tunnel)
- This number is injected into the header of  every ESP/AH/IKE packet, so the remote peer knows which Security Assosiation (SA) `[cryptographic parametres and keys]` to use for decryption and authentication
- Also these numbers (for both local and remote peer) are stored in router's memory for Phase 1 and Phase 2 Security Assosiations - in IKEv1, and for SAs in IKEv2
- It is used in both phases during tunnels establishment and in both tunnels: data and control
- Each peer generates its own SPI and sends to peer during Tunnel 1 creation and Tunnel 2 creation, and it means that the peer wants to receive traffic, using this SPI
- Different SPIs for different tunnels are generated
- The SPI is never reused between peers
- `Outbound SPI` - The SPI my router inserts into ESP/AH/IKE  I send
- `Inbound SPI` - The SPI my router expects to see in ESP/IKE/AH packets I receive

**Phase 1 and Phase 2 SPIs**

- Phase 1 tunnel SA is uniquely identified by 2 SPIs in router's logical object: local SPI and remote SPI
- Phase 2 tunnel SA is uniquely identified by `1 SPI`, but at the same time there are `2 SAs` in routers memory for each Phase 2 tunnel: `Inbound SA and Outbound SA`
- The ESP/AH header in data packets uses the Phase 2 SPI as the first field to indicate which SA/key to use
- For every new Phase 2 tunnel - because of different traffic selectors - new pairs of SPI are generated by both sides

## 3 SA

- SA - Security association - `has 2 meanings`
    - Meaning 1 - it is a set of cryptographic options that are negotiated between devices that are establishing an IPSec relationship
    - Meaning 2 - it is a logical object stored and tracked by the device (router/firewall)
- SAs are used in both meanings in both Phases of IKE protocol
- Phase 1 and Phase 2 of IKE negotioations have different SAs
- Each IPSec connection to 1 peer has minimum 3 SAs in router's memory: 1 SA for Phase 1 tunnel (bidectional, used for inbound and outbound traffic) and 2 SAs for Phase 2 tunnel: one for Inbound traffic and one for Outbound
- Each IPSec connection to a peer may have more than 2 Phase 2 SAs, it depends on the amount of traffic selectors, for each traffic selector another pair of SAs for Phase 2 is created

### 3.1 Phase 1 - IKE SA

**As a set of options**

- SA, used during Phase 1, is called IKE SA and it is `Bidirectional`: used for protecting control traffic in both directions 
- IKE SA as a set of cryptographic options consist of `SPIs(initiator and responder) and Proposals` - this is what we see in a packet
- `Proposal` consists of `Transforms`
- Transforms maybe be different types: `Encryption, Hash, Authentication Method, DH group, Lifetime`
- `Authentication method is not negotiated as a transform in IKEv2` - it’s implicit in the IKE_AUTH exchange
- The `set of transforms` inside one proposal defines the full Phase 1 policy - `transform set`
- Example on how SA looks like on the wire during phase 1 IKE v1::

**Logical structure**

```
SA payload
 └── Proposal
     ├── Transform 1: ENCR  → AES-CBC
     ├── Transform 2: HASH  → SHA1
     ├── Transform 3: AUTH  → PSK
     └── Transform 4: GROUP → MODP-1024
```

**Packet capture**

```
Internet Security Association and Key Management Protocol (ISAKMP)
    Initiator SPI:  a1b2c3d4e5f60708
    Responder SPI:  0000000000000000
    Next payload:   Security Association (SA)
    Version:        1.0
    Exchange type:  Identity Protection (Main Mode) (5)
    Flags:          0x00  (no encryption)
    Message ID:     00000000
    Length:         216  (example)

Payload: Security Association (SA)
    DOI:    IPsec (1)
    Situation: Identity Only (1)
    Proposal:
        Proposal #1
        Protocol ID: ISAKMP (1)
        SPI Size: 0
        # of Transforms: 4
        Transform #1: Encryption Algorithm
            Type:   ENCR
            ID:     AES-CBC
        Transform #2: Hash Algorithm
            Type:   HASH
            ID:     SHA1
        Transform #3: Authentication Method
            Type:   AUTH
            ID:     Pre-shared Key (PSK)
        Transform #4: Diffie-Hellman Group
            Type:   GROUP_DESC
            ID:     Group 2 (MODP-1024)
```

**As a logical object on router**

```
IKE SA
├── Initiator SPI (chosen by initiator)
├── Responder SPI (chosen by responder)
├── Keys (inbound)
├── Keys (outbound)
├── Crypto parameters
├── Timers
└── State
```

- Phase 1 SA as a logical object on router includes the following: 
    - Peer identification
        - Remote peer IP address (or FQDN)
        - Local interface / local IP used
        - Negotiated IKE identity (IP, FQDN, DN, etc.)
    - Negotiated cryptographic parameters -Result of the accepted proposal + transforms
        - Encryption algorithm (e.g. AES-CBC)
        - Hash / integrity algorithm (e.g. SHA-1 / SHA-256)
        - Authentication method (PSK, RSA signatures, etc.)
        - Diffie-Hellman group
    - SA lifetime (time and/or rekey margin)
    - `These parameters are fixed for the lifetime of the IKE SA`
    - Keying material (derived, not negotiated)-Derived encryption & integrity keys for IKE messages
    - `Keys are never sent, only derived via DH + nonces`
    - SPI values
        - Initiator SPI
        - Responder SPI
    - `These uniquely identify the IKE SA in both directions`
    - State information
        - IKE state (MM_ACTIVE, QM_IDLE, ESTABLISHED, etc.)
        - Mode used (Main Mode / Aggressive Mode)
        - Exchange progress markers
    - Timers and counters
        - SA creation time
        - Remaining lifetime
        - Rekey timers
        - Message counters / retransmission state
    - Authentication data (cached result)
        - Peer authenticated successfully (yes/no)
        - Identity matched PSK or certificate
    - Relationship to Phase 2

**Example of SA phase 1 IKEv1 as a logical object**  

On router via Cisco command `show crypto isakmp sa detail` - It displays IKEv1 Phase 1 Security Associations currently known to the router

```
IPv4 Crypto ISAKMP SA
dst             src             state          conn-id status
192.0.2.2       192.0.2.1       QM_IDLE        1001    ACTIVE

     IKE SA details:
       Session-id: 1001
       Status: ACTIVE
       IKE version: 1
       Exchange type: Main Mode
       Authentication method: Pre-Shared Key
       Encryption: AES-CBC
       Hashing: SHA1
       DH group: 2
       Lifetime: 86400 seconds
       Remaining lifetime: 83210 seconds
       Local SPI: 0xA1B2C3D4
       Remote SPI: 0xE5F6A7B8
       NAT-T: enabled
       DPD: enabled
       Local ID: IPv4 address 192.0.2.1
       Remote ID: IPv4 address 192.0.2.2
```

**IKEv1 Example**  

For IKEv2 command is a little bit different: `show crypto ikev2 sa detail`

```
IKEv2 SAs:

Session-id: 3, Status: UP-ACTIVE
  IKE SA: local 192.0.2.1/500 remote 192.0.2.2/500
  Local ID: ipv4 addr 192.0.2.1
  Remote ID: ipv4 addr 192.0.2.2
  Authentication: Pre-shared key
  Encryption: AES-CBC, keysize 256
  Integrity: SHA256
  PRF: PRF_HMAC_SHA256
  DH Group: 14
  SPI(local): 0x1A2B3C4D5E6F7081
  SPI(remote): 0x9988776655443322
  Lifetime: 86400 seconds
  Remaining Lifetime: 84123 seconds
  NAT-T: detected, enabled
  DPD configured: yes, interval 10, retry 5
  Rekey SA: yes
  Child SAs: 1 active
```

### 3.2 Phase 2 - IPSec SA 

**As a set of options during negotiations**

- Each SA payload contains one or more Proposals
- Each Proposal has:
    - Protocol ID (ESP = 50, AH = 51)
    - SPI Size (usually 4 bytes)
    - SPI Value (the actual 32-bit number)
    - Transform set, consisting of several transforms: encryption, auth(Integrity, HMAC), lifetime, DH group - no Authentication method, like in Phase 1

**As a logical object on a router**

- SA, used during Phase 2, is called IPSec SA and it is Unidirectional: used for protecting Data traffic in one direction, so 2 SAs are required for communication
- SA is uniquely identified by a Security Parameter Index (SPI), an IPv4 or IPv6 destination address, and a security protocol (AH or ESP) identifier 
- Outbound and inbound SAs are differenti
- Inbound SA for Phase 2: how to decrypt and authenticate packets arriving at the device based on SPI inside ESP protocol
- Outbound SA for Phase 2: How to encrypt and authenticate packets leaving the device based on SPI inside ESP protocol
- `Both SAs (inbound and outbound) use the same crypto parameters, negotiated during Phase 2`
- `But the keys are different for each direction`
- `Each SA has its own SPI` - Inbound SA has a SPI of remote peer, what it expects to see in an incoming packet - Outbound SPI has an SPI of local router and is used when sending packets to remote router
- Any time direction, keying material, protocol, or traffic selectors differ → a separate SA is required

**Phase 2 — two SA objects** 

```
IPsec SA (outbound)
├── SPI: 0x1001
├── Encryption key
├── Integrity key
└── Traffic selector

IPsec SA (inbound)
├── SPI: 0x2002
├── Encryption key
├── Integrity key
└── Traffic selector
```

### 3.3 Manual and Dynamic SAs

**Manual SA**

- Manual SAs require no negotiation; all values, including the keys, are static and specified in the configuration
- If you configure static/manual IPsec SAs, you do not need (and cannot use) IKE
- All parameters are manually configured on both sides:
    - SPI (Security Parameter Index)
    - Encryption & authentication algorithms
    - Keys
    - Peer IPs
    - Lifetimes (if any)
- There is no key negotiation, rekeying, or authentication exchange
- Used only in test setups or simple, static environments
- Drawback: keys must be changed manually — no automatic refresh → insecure and unscalable 

**Dynamic SA**

- Dynamic SAs require additional configuration. With dynamic SAs, you configure IKE first and then the SA. IKE creates dynamic security associations; it negotiates SAs for IPsec and IKE
- The IKE configuration defines the algorithms and keys used to establish the secure IKE connection with the peer security gateway
- This connection is then used to dynamically agree upon keys and other data used by the dynamic IPsec SA. The IKE SA is negotiated first and then used to protect the negotiations that determine the dynamic IPsec SAs

## 4 Transform set

- A transform set is a combination of one or more transforms used to build an IPsec Security Association (SA) during Phase 2 (Quick Mode / Child SA) negotiation or IKE Security Assosiation during Phase 1
- Each transform describes one specific aspect of how IPsec protects the traffic
- Transform types:
    - Encryption Algorithm (ENCR) - AES-CBC, AES-GCM, 3DES, ChaCha20-Poly1305
    - Pseudo-Random Function (PRF) - In IKEv1, PRF is not a separate transform — it’s implicit in Phase 1 - PRF-HMAC-SHA1, PRF-HMAC-SHA256
    - Integrity / Authentication Algorithm (INTEG) - HMAC-SHA1, HMAC-SHA256, AES-XCBC
    - Diffie-Hellman Group (D-H Group) - Defines key exchange strength (PFS in Phase 2) - MODP-2048 (Group 14), ECP-256 (Group 19)
- IKE (Phase 1) transform set includes enctyption, integrity, authentication method, Diffie Hellman Group, IKE SA lifetime
- ESP(Phase 2) transform set includes encryption + integrity transforms
- AH (Phase 2) - integrity only  

## 5 Traffic Selectors

- These are parametres, used during negotiations during Phase 2
- In Palo Alto terms it is called Proxy ID
- Traffic selector consist of local network, remote network, protocol, port - they should match on both sides
- They are configured manually on each node
- It is not used very often now, because mostly route based IPSec is used instead of Policy based
- They are sent separately outside the SA
- Their goal is to specify which traffic should be sent to the IPSec tunnel in Policy based IPSec implementations

**Example of logic**

```
Node A sends 192.168.1.0/255.255.255.0 TCP Any port > 192.168.2.2/255.255.255.255 TCP 443 port
Node B sends 192.168.2.2/255.255.255.255 TCP 443 > 192.168.1.0/255.255.255.0 TCP Any port
This configuration allows traffic from 192.168.1.0/24 to 192.168.2.2 port 443
```

- Some vendors allow “any-to-any” traffic without strict traffic selectors, meaning the SA could match all traffic between the peers’ IPs
- For route based VPN TS are set to 0.0.0.0 - which means "any traffic is allowed"

**Example of traffic selectors in IPSec SA for Cisco Router**

```
Router# show crypto ipsec sa

interface: GigabitEthernet0/0
    Crypto map tag: VPN-MAP, local addr 203.0.113.10

   protected vrf: (none)
   local ident (addr/mask/prot/port): (10.1.0.0/255.255.255.0/0/0)
   remote ident (addr/mask/prot/port): (10.2.0.0/255.255.255.0/0/0)

   #pkts encaps:  12345, #pkts encrypt: 12345, #pkts digest: 12345
   #pkts decaps:  12010, #pkts decrypt: 12010, #pkts verify: 12010

   inbound esp sas:
      spi: 0x32A1B44C(850000964)
        transform: esp-aes esp-sha-hmac ,
        in use settings ={Tunnel, }
        conn id: 1011, flow_id: SW:11, crypto map: VPN-MAP
        sa timing: remaining key lifetime (k/sec): (4294967295/2460)
        replay detection support: Y
        Status: ACTIVE

   outbound esp sas:
      spi: 0xA4BB9923(2769075235)
        transform: esp-aes esp-sha-hmac ,
        in use settings ={Tunnel, }
        conn id: 1012, flow_id: SW:12, crypto map: VPN-MAP
        sa timing: remaining key lifetime (k/sec): (4294967295/2460)
        replay detection support: Y
        Status: ACTIVE
```

## 6 Vendor IDs

- In IKEv1, a Vendor ID (VID) is just bytes
- IKEv1 Phase 1 Message 1 Main Mode capture with lots of Vendor IDs, exactly like you’d see from a Cisco RA VPN headend in the 2000s

```
Vendor ID
  Vendor ID: 4a131c81070358455c5728f20e95452f
  Meaning: NAT-Traversal (RFC 3947)

Vendor ID
  Vendor ID: afcad71368a1f1c96b8696fc77570100
  Meaning: Dead Peer Detection (Cisco)

Vendor ID
  Vendor ID: 09002689dfd6b712
  Meaning: XAuth (Cisco Extended Authentication)

Vendor ID
  Vendor ID: 4048b7d56ebce88525e7de7f00d6c2d3
  Meaning: Cisco Unity (Remote Access VPN)

Vendor ID
  Vendor ID: 12f5f28c457168a9702d9fe274cc0100
  Meaning: IKE Fragmentation (Cisco proprietary)

Vendor ID
  Vendor ID: 3f237c7f2c7a3f8a6d8e97c2c4a9f001
  Meaning: Vendor-specific (often ignored)

Vendor ID
  Vendor ID: 1f07f70eaa6514d3b0fa96542a500000
  Meaning: Microsoft Windows IPsec
```

- Why so many VIDs?
- Because IKEv1 had no standard way to say:
    - “I support NAT-T”
    - “I support DPD”
    - “I support username/password”
    - “I support fragmentation”
- What the responder does? If recognized → enable feature - If unknown → silently ignore
- Why Vendor IDs existed (historical reason)
    - IKEv1 (RFC 2409, 1998) had a problem
    - The protocol was underspecified
    - Many features were missing or unclear
    - Vendors implemented incompatible extensions
- So vendors needed a way to say: Hey peer, I support this non-standard thing
- No negotiation, No security, No guarantees
- What Vendor IDs were used for (real use cases)
    - NAT Traversal (before RFC) - Before NAT-T was standardized
    - Dead Peer Detection (DPD)
    - XAuth - Remote-access extensions (username/password auth) - Not in base IKEv1 - Implemented via VID
    - Fragmentation - IKEv1 fragmentation (pre-RFC 7383)
    - Implementation quirks
    - Config Mode
- Some VIDs existed just to say: “I am Cisco”, “I am Check Point”, “I am Windows”
- Peers then adjusted behavior (!)
- Why Vendor IDs are bad (architecturally)
    - Fingerprinting
    - Interoperability hacks
    - Undocumented behavior
    - Works only with vendor
    - They are out-of-band signaling, which protocols should avoid
- IKEv2 removed Vendor IDs completely
- IKEv2 designers said: never again
- IKEv2 replaced VIDs with Notify payload: Standardized, RFC-defined behavior
- Examples:
    - NAT-T → built-in
    - DPD → INFORMATIONAL exchanges
    - Fragmentation → RFC-defined
    - Cookies → standardized DoS protection

## 6 IKE v1

- IKEv1 was designed by the IETF IPsec work group in the mid-1990s and standardized in 1998 as RFC 2409
- First appeared in Research & open-source Unix IPsec stacks, then in Cisco IOS, Checkpoint, Juniper
- IKE v1 goals: 
    - Authenticate peers
    - Negotiate cryptographic parameters
    - Establish shared secret keys
    - Create and manage IPsec Security Associations (SAs) + IKE SA
    - Provide Perfect Forward Secrecy (PFS)
    - Detect peer liveness
    - Provides identity protection (in main mode)
- IKE v1 uses UDP port 500 or UDP port 4500 in case of NAT-T technology
- IKEv1 uses two phases to authenticate peers `once` and securely negotiate traffic protection many times
- Phase 1 — Build a secure control channel
- Phase 2 - Negotiate parametres for Data traffic encryption via secure Control Channel
- Phase 1 can work in 2 modes: main and aggressive
    - 9 messages in total if main mode is used in Phase 1
    - 6 messages in total if aggressive mode is used in Phase 1
- IKEv1 was developed, combining ideas from three earlier protocols:
    - ISAKMP – framework for messages and SA management, how packets are formatted (headers, payload types), a generic state machine for SA negotiation, but not how keys are exchanged
    - Oakley – Diffie-Hellman key exchange and math, key derivation techniques, DH groups
    - SKEME – identity protection, rekeying, multiple SAs, negotiate algorithms, separation of key exchange from authentication, multiple authentication styles
- There is IKE traffic, when everything is established and data flows normally - keepalives via port UDP/500, if NAT-T is enabled then UDP/4500 is used
- In the IPsec/IKE world, the “initiator” is the peer that first sends an IKE packet to start the negotiation
- The responder replies. This role is independent of who sends actual data over ESP later
- PFS in IKEv1 = `Perform a new DH exchange during Phase 2`. It does not mean “ephemeral DH” in the modern TLS sense

### 6.1 Workflow

- IKE Phase 1 — Establish a secure channel (IKE SA) - starts with UDP/500, may switch to UDP/4500
    - `Main mode` - 6 messages
    - `Aggressive mode` - 3 messages
    - SA negotiation - Agree on crypto parametres - transform sets
    - DH key exchange
    - Authentication - encrypted already
    - NAT-T negotiation
    - DPD negotiation
    - IKE SA - one for inbound and outbound - IKE SA is bidirectional
    - Local SPI → The SPI that your router uses when sending ISAKMP messages
    - Remote SPI → The SPI your router expects in incoming ISAKMP messages from the peer
- XAuth
- Config mode
- IKE Phase 2 — Negotiate IPsec SAs (ESP or AH) - `Quick mode` - UDP/500 or UDP4500
    - Negotiate 2 IPsec SAs - inbound and outbound - crypto parametres the same - keys are different
    - Exchange traffic selectors (Proxy-ID) - should be the same
    - `Outbound SPI` - The SPI my router inserts into ESP packets I send
    - `Inbound SPI` - The SPI my router expects to see in ESP packets I receive
    - Transform sets - negotiate crypto parametres
- ESP/AH encapsulation — Actual data traffic encryption/authentication using the negotiated keys - IP/50(ESP) or UDP/4500 or IP/51(AH) - Destination SPI is in header

### 6.2 Phase 1

**Concepts**

- During traffic capture you cannot see Phase 2 negotiation, only Phase 1 as ISAKMP protocol, everything else is encrypted
- Phase 1 SA is called ISAKMP SA or IKE SA
- The Phase 1 keys are long-lived and tied to identity/authentication
- IKE SA and IPSec SAs must be cryptographically independent
- Phase 1 establishes an ISAKMP(Internet Security Association and Key Management Protocol) SA, which is a secure channel through which the IPsec SA negotiation can take place
- Phase 1 workflow: `Crypto negotiations > DH exchange > Authentication > IKE communications between routers `
- The ISAKMP header has its own SPI pair
- These SPIs identify the IKE SA
- IKE SA is bidirectional

**Negotiations - The following crypto parametres are negotiated during Phase 1**

- Hashing - md5 or sha - used inside HMAC for authentication and integrity of every IKE packet
- Authentication - Preshared Keys or certificates
- Group - Diffie Helman group - algorithm which is used to establish shared secret keys
- Encryption
- Lifetime - 24 hours default - don't have to match  
   
To easy remember this we can use first letters of these parametres: `HAGEL`

**IKE Phase 1 can be established via**

- main mode(6 messages)  
- aggressive mode(3 messages) 

#### 6.2.1 IKE identity

- IKE Identity is a `Value` which is sent by both Initiator and Responder to each other during `Authentication` Stage of Phase 1 in IKEv1 and during the IKE_AUTH exchange in IKEv2
- IKE Identity is `mandatory` for use in both IKE versions, Site-to-Site VPNs and RA VPNs
- It can be in the form of: `distinguished-name, hostname, ip-address, e-mail-address, key-id, FQDN (explicit), RFC822 (email), ASN.1 DN`
- IKE identity is a mandatory input to authentication and IKE SA establishment
- Authentication HASH is based not only on PSK and Nonce, but also on both IKE IDs
- `IKE ID = endpoint(peer, node) name, not the User`
- IKE ID is used to select which PSK to use, which certificate to validate, which EAP policy applies
- If IKE identity is not configured, the device uses the IPv4 or IPv6 address of interface by default

**Why IKE ID is required and how it is used**

- When the responder receives the initiator’s ID, it verifies that the ID matches the configuration
- Using this ID, the responder selects the correct authentication data (PSK or certificate) and applies the appropriate authorization policy
- In both IKEv1 and IKEv2, cryptographic proposals `are not` selected based on the IKE ID
- In IKEv2 IP address is not used for PSK selection
- In IKEv1 main mode with PSK IP address is used for selecting PSK, because the responder does not know the peer ID early, ID is sent after PSK
- In IKEv1 aggressive mode with PSK ID is sent early and in cleartext, Responder can choose PSK based on ID
- In IKEv1 all modes with certificates IP is not used, only ID
- IP is not reliable, it may be changed during NAT, so ID is required
- Using ID node also applies authorization policy: where the remote node can connect, both for Site-to-Site and RA VPNs 

**IKE Identity in Site-to-Site VPNs**

- IKE identity is configured manually on both Peers for Site-to-Site VPNs if PSK is used, and if Certificate-based → identity derived from cert
- We configure local Identity-what to send to remote Peer, and remote Idenity-what to expect from remote peer
- If Identity mismatch - `Authentication and Phase 1 will fail` 
- It must match the peer’s expectations

**IKE Identity in RA VPN with IKEv1**

- IKE Identities in RA VPNs may be flexible, depending on configuration, it may not match
- IKE Identity for VPN Client: group name(Cisco ASA) or IP address or FQDN from certificate
- IKE Identiry for VPN Server: group name, if group name from client request exists, connection is accepted, if not it is rejected
- 1 user or 10,000 users can use the same IKE ID of the VPN client
- Any VPN client IKE ID maybe allowed on VPN server side, if default group is configured
- XAuth is used with username and password for exact user identification after Phase 1 is authenticated via IKE IDs, PSK or certs
- RA VPN Server using IKEv1 will reject connection if either one of these is wrong in client's request in case of strict configuration: `Client IKE ID, Server IKE ID, PSK, Xauth username, Xauth password`

**IKE Identity in RA VPN with IKEv2**

- The role of IKE Identity (IDi / IDr) is similar to IKEv1:
    - it identifies the VPN endpoint, not the user
    - it may be shared by many clients
    - it is used for policy and authentication selection
- Unlike IKEv1:
    - XAUTH is not used
    - User authentication is performed via EAP
    - EAP authenticates the user, not the IKE SA
- The IKE SA must still be authenticated using:
    - PSK, or
    - certificates
- EAP is used in addition to, not instead of, PSK or certificates
- Generic or anonymous client IKE IDs are commonly used

#### 6.2.2 Main Mode

- `6 messages`
- IKE Identities and Authentication Hash are protected and sent encrypted only > no one can see it
- `This makes it imposiible to Brute Force Authentication Hash`
- All Phase 1 Main Mode packets must include IKE SPIs(Cookies)
- No ESP/AH SPIs yet — Phase 2 Quick Mode creates those
- `Nothing in the RFC forbids Main Mode + Initiator dynamic IP`
- `Implementation-wise` it will not work
- Main Mode + certs + dynamic IP = totally fine - so with certificates instead of PSK Main Mode works OK
- `Main Mode with PSK will not work for RA VPNs or S2S VPNs with dynamic IP`
- PSK is used to derive SKEYID > SKEYID is used to verify HASH_I / HASH_R > The responder must already know which PSK to use when it receives message 5 with ID and Auth Hash > And it knows it based on IP, which should be static
- To choose PSK Main Mode needs correct IP of Initiator

**Main mode in a Nutshell**

```
│── 1. Generate Initiator and Responder SPIs and Negotiate all required crypto options - messages 1 and 2
│   ├── Encryption
│   ├── Hash - for auth of every packet
│   ├── Authentication: PSK or certs
│   ├── DH Group
│   └── Lifetime 
│ 
│── 2. Exchange keys with Diffie Hellman algorithm - messages 3 and 4
│   ├── DH Group
│   ├── DH public key
│   └── Nonce
│ 
│── 3. Send Encrypted ID and Encrypted Authentication Hash - messages 5 and 6
│   ├── Encrypted ID
│   └── Encrypted Authentication Hash
│   
```

Authentication Hash should match the one calculated locally > IKE tunnel is established  
Derived encryption keys are used to encrypt creation of IPSec tunnel   

- `First message` - SA > Proposals > Transforms + Initiator SPI
- Each proposal can contain many transforms
- Each transform is a full combination of all cryptographic parameters - `not like in Phase 2` - `no transform sets`
  - Encryption
  - Hash - for auth of every packet
  - Authentication method: PSK or certs
  - DH Group
  - Lifetime 

**Message 1 Example: Initiator → Responder (SA Proposal)**

```
Frame 1: 192.0.2.10 → 198.51.100.20, UDP 500 → 500
Internet Key Exchange v1
  ISAKMP Header
    Initiator SPI: 0xA1B2C3D4E5F60708
    Responder SPI: 0x0000000000000000
    Next Payload: Security Association (1)
    Version: 1.0
    Exchange Type: Main Mode (2)
    Flags: 0x00
    Message ID: 0x00000000
  Payload: Security Association (SA)
    DOI: IPsec (1)
    Situation: Identity Only
    Proposal #1
      Protocol ID: ISAKMP
      SPI Size: 0
      Number of Transforms: 2
      Transform #1
        Transform ID: KEY_IKE
        Encryption: AES-CBC-256
        Hash: SHA-1
        Authentication: Pre-Shared Key
        DH Group: 14
        Lifetime: 28800s
      Transform #2
        Transform ID: KEY_IKE
        Encryption: 3DES
        Hash: SHA-1
        Authentication: Pre-Shared Key
        DH Group: 2
        Lifetime: 28800s
```

- `Second message` - Initiator SPI, Responder SPI, Selected SA with 1 Proposal inside and 1 Transform inside Proposal

**Message 2 Example — Responder → Initiator (SA Selection)**

```
Frame 2: 198.51.100.20 → 192.0.2.10, UDP 500 → 500
Internet Key Exchange v1
  ISAKMP Header
    Initiator SPI: 0xA1B2C3D4E5F60708
    Responder SPI: 0x1122334455667788
    Next Payload: Security Association (1)
    Version: 1.0
    Exchange Type: Main Mode (2)
    Flags: 0x00
    Message ID: 0x00000000
  Payload: Security Association (SA)
    Selected Proposal
      Protocol ID: ISAKMP
      SPI Size: 0
      Transform
        Encryption: AES-CBC-256
        Hash: SHA-1
        Authentication: Pre-Shared Key
        DH Group: 14
        Lifetime: 28800s
```

- `Third message` - DH Group + DH public Key + Nonce + SPIs
- `Nonce - is a a large, random, unpredictable number generated fresh for each exchange`
- Nonce is required to  bind the Diffie–Hellman exchange to this specific IKE run and prevent replay, key reuse, and precomputation attacks
- Without nonces: `An attacker could replay an old DH public value` - `Both sides might unknowingly derive the same key again`
- Nonce ensures: Even if DH values repeat, keys will not

**Message 3 Example - Initiator → Responder - Key Exchange + Nonce**

```
Frame 3: 192.0.2.10 → 198.51.100.20, UDP 500 → 500
Internet Key Exchange v1
  ISAKMP Header
    Initiator SPI: 0xA1B2C3D4E5F60708
    Responder SPI: 0x1122334455667788
    Next Payload: Key Exchange (4)
    Version: 1.0
    Exchange Type: Main Mode (2)
    Flags: 0x00
    Message ID: 0x00000000
  Payload: Key Exchange (KE)
    DH Group: 14
    Public Value: g^xi mod p
  Payload: Nonce (Ni)
```

- `Fourth message` - DH Group + DH public Key + Nonce + SPIs

**Message 4 Example — Responder → Initiator - Key Exchange + Nonce**

```
Frame 4: 198.51.100.20 → 192.0.2.10, UDP 500 → 500
Internet Key Exchange v1
  ISAKMP Header
    Initiator SPI: 0xA1B2C3D4E5F60708
    Responder SPI: 0x1122334455667788
    Next Payload: Key Exchange (4)
    Version: 1.0
    Exchange Type: Main Mode (2)
    Flags: 0x00
    Message ID: 0x00000000
  Payload: Key Exchange (KE)
    DH Group: 14
    Public Value: g^xr mod p
  Payload: Nonce (Nr)
```

- `Fifth message` - SPIs + IKE ID encrypted + Authentication Hash Encrypted
- Authentication Hash is calculated based on:

```
IKEv1 Phase 1 – Authentication HASH Inputs
│
├─ Shared Secret
│  ├─ Pre-Shared Key (PSK)
│  └─ or Private Key (RSA / DSS signatures)
│
├─ Derived Keying Material
│  ├─ SKEYID
│  ├─ SKEYID_d
│  └─ SKEYID_a        ← directly used for authentication
│
├─ Diffie-Hellman Data
│  ├─ g^i             (Initiator DH public value)
│  └─ g^r             (Responder DH public value)
│
├─ ISAKMP Cookies (IKE SPIs)
│  ├─ Initiator Cookie (SPIi)
│  └─ Responder Cookie (SPIr)
│
├─ Nonces
│  ├─ Ni              (Initiator nonce)
│  └─ Nr              (Responder nonce)
│
├─ Phase 1 SA Payload
│  └─ SA              (complete negotiated proposal payload)
│
├─ Identification Payloads
│  ├─ IDii            (Initiator ID – used in HASH_I)
│  └─ IDir            (Responder ID – used in HASH_R)
│
└─ Direction Context
   ├─ HASH_I          (calculated by Initiator)
   │  └─ includes IDii
   └─ HASH_R          (calculated by Responder)
      └─ includes IDir
```

- In IKEv1 Phase 1, there are two different authentication values
- `HASH_I` - computed, sent by Initiator
- `HASH_R` - computed, sent by Responder
- Initiator proves “I am who I claim to be” → HASH_I
- Responder proves “I am who I claim to be” → HASH_R
- If the same hash were used, replay or reflection attacks would be possible
- Everything is the same except the ID payload included
- HASH_I includes IDii (Initiator Identification)
- HASH_R includes IDir (Responder Identification)
- `The initiator sends its identity and a hash; the responder recomputes the hash using the received identity and verifies it, thereby authenticating the initiator`
- `Hash is a proof of possession` of the shared secret, bound to:
  - The negotiated SA
  - Both nonces
  - Both SPIs
  - The sender’s ID

**Message 5 Example — Initiator → Responder (Encrypted ID + Initiator Authentication HASH)**

```
Frame 5: 192.0.2.10 → 198.51.100.20, UDP 500 → 500
Internet Key Exchange v1
  ISAKMP Header
    Initiator SPI: 0xA1B2C3D4E5F60708
    Responder SPI: 0x1122334455667788
    Next Payload: Identification (5)
    Version: 1.0
    Exchange Type: Main Mode (2)
    Flags: Encryption (0x01)
    Message ID: 0x00000000
  Encrypted Payloads
    Identification (IDii)
      Type: FQDN
      Value: vpn-client.example.com
    HASH_I
```

- `Sixth message` - SPIs + IKE ID encrypted + Responder Authentication Hash Encrypted

**Message 6 Example — Responder → Initiator (Encrypted ID + Authenticated HASH)**

```
Frame 6: 198.51.100.20 → 192.0.2.10, UDP 500 → 500
Internet Key Exchange v1
  ISAKMP Header
    Initiator SPI: 0xA1B2C3D4E5F60708
    Responder SPI: 0x1122334455667788
    Next Payload: Identification (5)
    Version: 1.0
    Exchange Type: Main Mode (2)
    Flags: Encryption (0x01)
    Message ID: 0x00000000
  Encrypted Payloads
    Identification (IDir)
      Type: FQDN
      Value: vpn-gateway.example.com
    HASH_R
```

**In Case of Certificates instead of PSK**

`When using certificates, the initiator replaces PSK-based HASH authentication with a CA-validated public certificate plus a signature created with its private key over the IKE exchange data — while the rest of Phase 1 remains largely the same`

The responder:

- Receives the certificate
- Extracts the public key
- Verifies the signature of connection options - initiator proves that it has a private key
- Verifies The CA’s digital signature on the Public certificate - This public key was issued by a CA I trust for this identity

Digital signatures over connection options:

- DH values
- Nonces
- SA payloads
- IDs

`No pre-shared lookup is required` - so Main Mode witth Certs can be used with Initiator dynamic IP

Responder logic:

```
1. Decrypt message 5
2. Read IDii
3. Read CERT
4. Verify CA trust
5. Verify SIG_I using public key
6. Accept peer
```

#### 6.2.3 Aggressive Mode

- `3 messages instead of 6 in Main Mode`
- Aggressive mode was created to reduce load on links and CPU
- `Aggressive Mode was part of IKEv1 from day one, added to enable faster handshakes and remote-access VPNs with dynamic peers, at the cost of identity protection and PSK security`
- It allows connections from `initiator with dynamic IP`
- ID is sent early, responder may `select PSK based on ID, not IP`
- Several Initiators may work behind one IP and NAT
- It is critical for remote-access VPNs
- `Nothing in the RFC forbids Main Mode + dynamic IP`
- `Implementation-wise` it will not work
- Main Mode + certs + dynamic IP = totally fine - so with certificates instead of PSK Main Mode works OK
- Most classic IKEv1 Remote Access VPNs used:
  - Aggressive Mode
  - PSK
  - XAuth (username/password after Phase 1)
  - Mode Config
- Aggressive Mode sacrifices identity Security:
  - IDs are sent in cleartext
  - HASH_I and HASH_R are exposed
  - Enables offline dictionary attacks against PSK
- It is considered acceptable because of Cryptographic maturity and strong PSKs
- IKEv2 eliminated Aggressive mode and always protects IDs and HASHes

**Main mode, Aggressive Mode, IKEv2, RA VPNs**

```
IKEv1 Main Mode
├─ Dynamic IP allowed by RFC
├─ Works well with certificates
└─ Painful / impractical with PSK

IKEv1 Aggressive Mode
├─ Designed for dynamic peers
├─ Identity arrives early
├─ PSK selection based on ID
└─ Used by almost all PSK-based RA VPNs

IKEv2
├─ No Aggressive Mode
├─ Always identity-protected
└─ Dynamic peers fully supported
```

**Message 1: Initiator > Responder**

- Initiator SPI
- `SA Proposals, DH Group, Key Exchange Data, Nonce, IKE ID - Everything! - Instead of only SA proposal in Main Mode`
- Vendor IDs

```
Internet Key Exchange
  Exchange Type: Aggressive Mode (4)
  Initiator SPI: 0x9f3a7c1e2b4d8a91
  Responder SPI: 0x0000000000000000
  Flags: Initiator
  Message ID: 0x00000000

  Payload: Security Association
    DOI: IPSEC (1)
    Situation: Identity Only
    Proposal: 1
      Proposal Number: 1
      Protocol ID: ISAKMP
      SPI Size: 0
      Number of Transforms: 1
      Transform: 1
        Transform Number: 1
        Transform ID: KEY_IKE
        Encryption Algorithm: AES-CBC (7)
        Hash Algorithm: SHA1 (2)
        Authentication Method: Pre-Shared Key (1)
        Group Description: MODP 1024 (2)
        Life Type: Seconds (1)
        Life Duration: 86400

  Payload: Key Exchange
    Diffie-Hellman Group: MODP 1024 (2)
    Key Exchange Data: 0x7c9a4f8d3a1b...

  Payload: Nonce
    Nonce Data: 0x1f9c33ab4e6d...

  Payload: Identification - Initiator
    ID Type: IPv4 Address (1)
    Protocol ID: Unused (0)
    Port: 0
    Identification Data: 192.0.2.10

  Payload: Vendor ID
    Vendor ID: RFC 3947 - NAT Traversal

  Payload: Vendor ID
    Vendor ID: Cisco-Unity

  Payload: Vendor ID
    Vendor ID: XAUTH
```

First message — The initiator proposes the security association (SA), initiates a DH exchange, and sends a pseudorandom number and its IKE identity. When configuring aggressive mode with multiple proposals for Phase 1 negotiations, use the same DH group in all proposals because the DH group cannot be negotiated. Up to four proposals can be configured. Message one contains everything that was in messages 1,3,5 in Main mode

**Message 2: Responder > Initiator**  

It contains the same as messages 2,4,6 in Main mode

- Responder cookie
- Chosen SA proposal - accepts the SA
- Key exchange Diffie-Hellman group + Key Exchange Data
- Nonce
- IKE Identity
- Hash - HASH_R (Responder Authentication Hash)
    - It is the responder’s proof of identity and possession of the shared secret
    - HASH_R proves all of the following at once:
        - The responder knows the Pre-Shared Key (PSK)
        - The responder participated in the Diffie–Hellman exchange
        - The responder is the owner of the claimed identity (IDir)
        - The responder did not modify the exchange
    - If any of these are false → hash verification fails → Phase 1 fails
    - HASH_R = `HMAC(Key, Data)
        - Key = Derived from PSK, Nonce-Initiator, Nonce-Responder
        - Data = Responder’s DH public value + Initiator’s DH public value + Responder cookie | Initiator cookie + Initiator’s SA payload + Responder’s identity)`
    - It is said that `Responder authenticates itself to the initiator` with HASH_R, so it `proves` that it is legal
- Vendor IDs

```
Internet Key Exchange
  Exchange Type: Aggressive Mode (4)
  Initiator Cookie: 0x9f3a7c1e2b4d8a91
  Responder Cookie: 0xa8d4c2e9f1234567
  Flags: Responder
  Message ID: 0x00000000

  Payload: Security Association
    DOI: IPSEC (1)
    Situation: Identity Only
    Proposal: 1
      Proposal Number: 1
      Protocol ID: ISAKMP
      SPI Size: 0
      Number of Transforms: 1
      Transform: 1
        Transform Number: 1
        Transform ID: KEY_IKE
        Encryption Algorithm: AES-CBC (7)
        Hash Algorithm: SHA1 (2)
        Authentication Method: Pre-Shared Key (1)
        Group Description: MODP 1024 (2)
        Life Type: Seconds (1)
        Life Duration: 86400

  Payload: Key Exchange
    Diffie-Hellman Group: MODP 1024 (2)
    Key Exchange Data: 0x8a72b91f4c9e...

  Payload: Nonce
    Nonce Data: 0xa91c8f3e52d4...

  Payload: Identification - Responder
    ID Type: IPv4 Address (1)
    Protocol ID: Unused (0)
    Port: 0
    Identification Data: 198.51.100.20

  Payload: Hash
    Hash (HASH_R): 0x4b8f2a7e91c3...

  Payload: Vendor ID
    Vendor ID: RFC 3947 - NAT Traversal

  Payload: Vendor ID
    Vendor ID: Cisco-Unity

  Payload: Vendor ID
    Vendor ID: XAUTHInternet Key Exchange
  Exchange Type: Aggressive Mode (4)
  Initiator Cookie: 0x9f3a7c1e2b4d8a91
  Responder Cookie: 0xa8d4c2e9f1234567
  Flags: Responder
  Message ID: 0x00000000

  Payload: Security Association
    DOI: IPSEC (1)
    Situation: Identity Only
    Proposal: 1
      Proposal Number: 1
      Protocol ID: ISAKMP
      SPI Size: 0
      Number of Transforms: 1
      Transform: 1
        Transform Number: 1
        Transform ID: KEY_IKE
        Encryption Algorithm: AES-CBC (7)
        Hash Algorithm: SHA1 (2)
        Authentication Method: Pre-Shared Key (1)
        Group Description: MODP 1024 (2)
        Life Type: Seconds (1)
        Life Duration: 86400

  Payload: Key Exchange
    Diffie-Hellman Group: MODP 1024 (2)
    Key Exchange Data: 0x8a72b91f4c9e...

  Payload: Nonce
    Nonce Data: 0xa91c8f3e52d4...

  Payload: Identification - Responder
    ID Type: IPv4 Address (1)
    Protocol ID: Unused (0)
    Port: 0
    Identification Data: 198.51.100.20

  Payload: Hash
    Hash (HASH_R): 0x4b8f2a7e91c3...

  Payload: Vendor ID
    Vendor ID: RFC 3947 - NAT Traversal

  Payload: Vendor ID
    Vendor ID: Cisco-Unity

  Payload: Vendor ID
    Vendor ID: XAUTH
```

**Message 3: Initiator to Responder**

- Cookies
- Hash - Initiator authenticates itself to the Responder

```
Internet Key Exchange
  Exchange Type: Aggressive Mode (4)
  Initiator Cookie: 0x9f3a7c1e2b4d8a91
  Responder Cookie: 0xa8d4c2e9f1234567
  Flags: Initiator
  Message ID: 0x00000000

  Payload: Hash
    Hash (HASH_I): 0x91a2cbe4d88f...
```

- Because the participants’ identities are exchanged in the clear (in the first two messages), aggressive mode does not provide identity protection
- Main and aggressive modes applies only to IKEv1 protocol. IKEv2 protocol does not negotiate using main and aggressive modes

**Why aggressive mode  enables offline PSK attacks? Why it is dangerous?**

An attacker capturing message 2, for example with ike-scan tool, has:

- SA proposal
- DH public values
- IDs
- HASH_R

They can brute-force PSK offline until hash matches.   
This is why Aggressive Mode + PSK is discouraged. 
An attacker only needs:

- A packet capture
- The initiator identity

No interaction with the gateway required.

And what about certs instead of PSK?

**Why XAuth made Aggressive Mode even worse?**

To scale RA VPNs with XAuth, admins typically configured:

- Single global PSK
- Shared by all users
- Rarely rotated
- Often human-memorable

Perfect target for offline cracking

After PSK compromise, attacker can:

- Successfully complete IKE Phase 1
- Trigger XAuth prompts
- Perform:
  - Online password guessing
  - Credential harvesting
  - MFA fatigue (later setups)

### 6.3 Phase 2

- There is only one mode - `quick` in Phase 2, `3 packets`
- It’s called Quick Mode because IKEv1 Phase 2 is deliberately short, lightweight, and fast compared to Phase 1 — both in message count and in cryptographic work: no identity, no DH exchange, only 3 messages
- By default, Phase 2 keys are derived from the session key created in Phase 1. Perfect Forward Secrecy (PFS) forces a new Diffie-Hellman exchange when the tunnel starts and whenever the Phase 2 keylife expires, causing a new key to be generated each time. This exchange ensures that the keys created in Phase 2 are unrelated to the Phase 1 keys or any other keys generated automatically in Phase 2
- PFS does not mean “ephemeral DH” in the modern TLS sense

**Cisco IOS example**

```
crypto map VPN 10 ipsec-isakmp
 set pfs group14
```

- Phase 2 (Quick Mode) packets are sent inside the encrypted IKE SA
- In your packet capture you will still see UDP 500 (or UDP 4500 if NAT-T) packets
- But their payloads are encrypted — they look like random binary blobs
- You can no longer see SA proposals, proxy-IDs, algorithms, etc

**Phase 2 has 3 packets only**

```
Initiator → Responder : SA, Nonce, traffic selectors, SPI, key exchange - optional
Responder → Initiator : SA, Nonce, SPI, key exchange - optional
Initiator → Responder : HASH (ack)
```

- No authentication happens during Phase 2
- `Responder does not send Traffic Selectors, it just agrees or declines Traffic Selectors from initiator`
- Crypto options are sent as many Transforms, which are called a transform set, `not as 1 transform in Phase 1`

**Example of first packet**

```
ISAKMP Header (HDR*)
 ├─ Initiator Cookie: 0xA1B2C3D4E5F60708
 ├─ Responder Cookie: 0x1122334455667788
 ├─ Next Payload: HASH (0x08)
 ├─ Version: 1.0
 ├─ Exchange Type: Quick Mode (32)
 ├─ Flags: Encrypted
 ├─ Message ID: 0x00001234
 └─ Length: 240 bytes

Encrypted Payloads (inside IKE SA):

1. HASH(1)
 └─ Integrity hash computed using Phase 1 keys
    (covers SA, Ni, KE, IDci, IDcr)

2. SA Payload (Security Association)
 ├─ Proposal #1
 │    ├─ Protocol ID: ESP (50)
 │    ├─ SPI Size: 4
 │    ├─ SPI Value (initiator): 0x3F2A1B4C
 │    ├─ Transform #1: Encryption
 │    │     • AES-CBC-256
 │    │     • Key Length: 256 bits
 │    ├─ Transform #2: Integrity
 │    │     • HMAC-SHA1-96
 │    ├─ Transform #3: Lifetime
 │    │     • 3600 seconds
 │    └─ Transform #4 (optional, PFS requested)
 │          • DH Group: 14

3. Ni (Nonce - Initiator)
 └─ Value: 0x8F3D4A9C12BEEF556677889900112233

4. KE (optional - DH for PFS)
 └─ DH Public Value (DH Group 14)
    • Example: 0xB7E3A2F9C4D1...

5. IDci (Identification - Initiator / Local Proxy-ID)
 ├─ Type: IPv4_ADDR_SUBNET
 ├─ Protocol: 0 (any)
 ├─ Port: 0 (any)
 ├─ Address: 10.0.0.0
 └─ Subnet Mask: 255.255.255.0

6. IDcr (Identification - Responder / Remote Proxy-ID)
 ├─ Type: IPv4_ADDR_SUBNET
 ├─ Protocol: 0 (any)
 ├─ Port: 0 (any)
 ├─ Address: 192.168.1.0
 └─ Subnet Mask: 255.255.255.0

7. Optional Payloads
 ├─ NAT-D detection (if NAT present)
 └─ Vendor ID (if implementation-specific)
```

**Negotiated options list - what is negotiated during Phase 2**

- Protocol: ESP or AH
- Mode: Tunnel or Transport
- Encryption transform: AES-CBC-256 - If AEAD (e.g., AES-GCM) was chosen in the encryption transform, separate integrity transform is not needed
- Integrity transform: HMAC-SHA1-96
- Lifetime transform: 3600 seconds and 4608000 kilobytes
- PFS: group 14 (if requested)
- Traffic Selectors(Proxy ID): 10.0.0.0/24 <-> 192.168.0.0/24 (proto any)
- Responder SPI (e.g. 0x3f2a1b4c) and Initiator SPI (e.g. 0x9a7e6c2d) — assigned by peers
- ESN: enabled (if negotiated / supported) - ESN = Extended Sequence Numbers - ESN extends the ESP sequence number from 32 bits to 64 bits

**To confirm Phase 2 happened, look for**

- Three small encrypted IKEv1 packets right after Phase 1
- ESP traffic starting immediately after them
- UDP/500 or 4500

### 6.4 Xauth

- XAuth (Extended Authentication) is an optional extra authentication step used only with IKEv1, mainly to authenticate individual users (not just devices)
- XAuth is an extension to IKEv1 Phase 1, and it happens `after Phase 1 but before Phase 2`
- Standard IKEv1 Phase 1 authenticates devices or gateways (via PSK or certificates)
- XAuth adds a user-level authentication step — typically `username and password`
- XAuth does not substitute Phase 1 Authentication (PSK or Certificates) - it is still required
- Peers complete Phase 1 → a secure channel (IKE SA) is established
- The responder (gateway) requests XAuth credentials from the initiator
- The initiator (client) provides username and password
- The gateway validates them (e.g., against local DB, RADIUS, LDAP, etc.)
- If successful → proceed to Phase 2 (Quick Mode) to negotiate IPsec SAs
- `IKEv2 replaced XAuth with EAP` (Extensible Authentication Protocol) for user-level auth

### 6.5 Mode-Config Phase

- Assign IP, DNS, WINS, Split tunnel
- `Happens after XAuth`
- Not used in IKEv2
- In IKEv2 it is called Configuration Payloads (CP) inside the IKE_AUTH exchange

### 6.6 Keepalives

- There is no single, clean, mandatory mechanism
- Two kinds of “keepalives” in IKEv1
  - NAT-T keepalives (most common meaning)
  - DPD / liveness checks (often incorrectly called keepalives)
- No automatic keepalives at all in pure IKEv1 without NAT-T and without DPD

### 6.7 DPD

- Dead Peer Detection
- Detect dead peers
- Why DPD was invented?
  - IKE Phase 1 & 2 SAs can last hours (e.g., 8 hours lifetime)
  - VPN gateways may think a peer is alive even if it crashed, rebooted, or lost connectivity
  - Traffic sent to a dead peer gets silently dropped, wasting bandwidth and causing service issues
- DPD detects dead/unresponsive peers before SA lifetime expires
- Allow VPN device to: Delete stale SAs, Reestablish tunnels quickly, Avoid “half-dead” tunnels that appear up in show commands but fail in practice
- Uses ISAKMP INFORMATIONAL exchanges
- Encrypted and authenticated via the Phase 1 key
- Messages:
  - `R-U-THERE`
  - `R-U-THERE-ACK`
- Send DPD every ~30–60s
- Tear down SA after several missed DPDs
- Cisco configuration: `crypto isakmp keepalive 10 3`
- Backward-compatible
- Safe with peers that don’t support it
- If the peer understands DPD → it replies
- If it doesn’t → it silently ignores it
- `DPD checks ONLY the IKE (Phase 1) SA`
- `IKEv1 DPD is not negotiated, uses no Vendor IDs, and when enabled the device simply begins sending encrypted R-U-THERE probes over the existing Phase 1 SA`

**Example Packet Capture (IKEv1 DPD)**

```
Frame 10: IKEv1 Phase 1 SA
ISAKMP: INFORMATIONAL, DPD Request
    Exchange Type: R-U-THERE
    Message ID: 0x00000001
    Payloads: NONE (just a ping)
    
Frame 11: IKEv1 Phase 1 SA
ISAKMP: INFORMATIONAL, DPD Reply
    Exchange Type: R-U-THERE-ACK
    Message ID: 0x00000001
    Payloads: NONE
```

### 6.8 NAT-T

```
+----------------+-----------+-------------+------------+------------------------+---------+-------------+----------+
|  New IP header | UDP header| NAT-T header| ESP header |Original Inner IP Header| IP Data | ESP trailer | ESP auth |
|    20 bytes    |  8 bytes  |   4 bytes   |  8 bytes   |                        |         |   2 bytes   | 12 bytes |
+----------------+-----------+-------------+------------+------------------------+---------+-------------+----------+
```

- ESP breaks when NAT is present
- ESP Tunnel Mode does not include the outer IP header in its Integrity Check Value (ICV)
- ESP Tunnel Mode protects: ESP header, Inner IP header, Payload, `It does NOT include the outer IP header`
- So if NAT changes the outer source/destination IP, `the ICV is not affected`
- `NAT cannot translate ESP because ESP has no ports` - NAT cannot track the flow
- `NAT breaks IPsec because IPsec expects stable src/dst IPs` - Even if ESP ICV survives, the security association itself is bound to a pair of IP addresses
- When NAT-T is enabled, `only SPI` is used for SA lookup
- Without NAT-T `SPI + IPs` are used for SA lookup
- UDP port 4500
- `Total overhead - 54 bytes!`
- Peers detect NAT-Traversal (NAT-T) automatically using a built-in mechanism in IKEv1 phase 1 or IKEv2 IKE_SA_INIT
- Each peer sends two special hashes: HASH(Original Source IP, Source Port), HASH(Original Destination IP, Destination Port)
- Each peer receives the other’s NAT-D payloads and compares them to what the packet actually arrived with
- The hashes match → no NAT
- By enabling this option, IPSec traffic can pass through a NAT device
- If the peers detect NAT in the path, they switch to: UDP/4500 for IKE, ESP-in-UDP/4500 for data
- Both peers must explicitly signal support for NAT-Traversal during Phase 1
- In IKEv1 it is optional, negotiated and announced via Vendor IDs
- In IKEv2 it is builtin and automatic

**NAT-T Keepalives**

- Keep NAT mappings alive
- Prevent UDP/4500 state from expiring
- 1-byte UDP packet
- Sent to UDP/4500
- Payload value: `0xFF`
- Not IKE, not ESP
- Stateless
- No response required
- Not authenticated
- Not encrypted
- 20–30 seconds (vendor-dependent)
- Even if no data traffic
- As long as IKE SA exists

The steps are:

- Announce NAT-T support - Via Vendor ID payloads during Phase 1
- Exchange NAT-D hashes
- Detect NAT (if hashes mismatch)
- Switch to UDP/4500

If only ONE peer supports NAT-T

- NAT-T = disabled
- Traffic stays UDP/500 + ESP
- Tunnel will fail if a real NAT is present

## 7 IKEv2

- `IKEv2 achieves Main-Mode-level security with Aggressive-Mode-level efficiency`
- `4 messages instead of 6 or 9 in IKEv1`
- IKEv2 is a completely new protocol, not a revised one
- IKEv2 removed ISAKMP entirely and defined its own message format
- Consist of request/response pairs, called exchages: `IKE_SA_INIT, IKE_AUTH`
- In IKEv2 there is no Main Mode or Aggressive Mode
- 2 separate HMAC functions are negotiated in SA for control channel: PRF and Integrity, IKEv1 used a single HMAC for everything

```
Integrity: HMAC-SHA1-96   (fast, smaller packets)
PRF:       HMAC-SHA256    (stronger key derivation)
```

- IKEv2 has:
    - IKE SPI (used in both IKE_SA_INIT and IKE_AUTH) - 2 SPI numbers for Initiator and Responder
    - ESP/AH SPI for CHILD_SA (used only in ESP/AH traffic) - 2 SPI numbers as well
- IKEv2 does not have phases: 1 and 2
- No Vendor IDs, which are used in IKEv1 for NAT-T, XAUTH.....
- One child Ipsec SA is created by default in IKE_AUTH message
- If you need additional Child SA - 2 more messages - request and response
- Functionally, Phase 2 in IKEv1 (Quick Mode) and IKEv2 (Child SA) both negotiate ESP/AH SAs, keys, lifetimes, and traffic selectors, optionally with PFS
- IKEv2 merges and simplifies the process, reduces message count, enforces explicit traffic selectors, and has cleaner rekey/Child SA creation flows
- Traffic selectors are Mandatory: you must specify the exact local and remote subnets or hosts that this Child SA will cover
- Workarounds for “any-to-any” for route based VPN: Cover all relevant subnets with broad TS + Use the VTI to route all traffic through a single IPsec SA
- IKEv2 replaced XAuth with EAP (Extensible Authentication Protocol) for user-level auth - carried inside IKE_AUTH
- EAP does not subsitute PSK or certificates, so you still need username and password
- In IKEv2 Mode-Config phase is called Configuration Payloads (CP) inside the IKE_AUTH exchange
- Next generation encryption support: AES-GCM, ECDH, etc...
- Assymetric authentication support: one peer uses cert and other one uses password
- Built-in AntiDDoS protection
- NAT-T is embeded
- DPD is built in and mandatory

**Anti-DDoS**

- Has built-in anti-DDoS protections designed to stop an attacker from exhausting CPU or state on a VPN gateway before authentication even happens
- It uses pricipe: Don’t do expensive work, and don’t allocate state, until the peer proves it’s real
- IKEv2 mitigates DDoS attacks by using `stateless cookies, delaying expensive cryptography, and refusing to allocate resources` until the peer proves reachability
- The Problem: An attacker can flood the gateway with fake IKE_SA_INIT requests, which triggers: Diffie–Hellman, 
State allocation, Result: CPU and memory exhaustion
- When a gateway `detects load` or suspicious traffic, it refuses to proceed normally and responds with a COOKIE notification
- How it detects? 
    - The primary signal is the number of incomplete IKE_SAs: IKE_SA_INIT received BUT DH / auth not completed yet - Memory-consuming - CPU-expensive
    - CPU Utilization
    - Rate of IKE_SA_INIT Requests - Packets per second (PPS) of IKE_SA_INIT
    - Retransmission / Failure Ratios
- The cookie is Cryptographically generated, Bound to source IP + SPI, The gateway does not store the cookie, Can verify it statelessly, Spoofed source IPs fail, because they never see the cookie

```
1. Attacker → IKE_SA_INIT
2. Gateway → IKE_SA_INIT + COOKIE
   (no state created)

3. Client → IKE_SA_INIT + COOKIE
4. Gateway → normal processing
```

- Management of "Half-Open" SAs - The server starts a timer for every new request. If the full authentication isn't completed within a short window, the session is cleared to free up memory - Thresholds: Administrators can set limits on the maximum number of half-open sessions allowed at once. Once this threshold is hit, the server can either drop new requests or trigger the Cookie Challenge
- Decryption Failure Detection: If a peer sends multiple packets that fail decryption (often a sign of a junk flood), the server automatically tears down the session
- Certificate Size Limits: To prevent memory exhaustion from massive, fake certificates, administrators can set a maximum allowed size for certificates received during authentication

**In a Nutshell - 4 mandatory messages only - without EAP and Configuration Payload**

```
Initiator > IKE_SA_INIT > Responder
Responder > IKE_SA_INIT reply > Initiator - IKE SA done
Initiator > IKE_AUTH > Responder - Encrypted - possible Configuration Payloads (CP)
Responder > IKE_AUTH reply > Initiator - IPSEC SA done - possible Configuration Payloads (CP)
EAP packets - Optional - carried inside IKE_AUTH
Initiator > CREATE_CHILD_SA > Responder - Optional
Responder > CREATE_CHILD_SA > Initiator - Optional
```

### IKEv2 PSK

**Packet 1 - INIT_SA**  

Initiator sends first IKE_SA_INIT packet, which includes: 

```
Initiator SPI
SA
 |-Proposals
           |-Transforms (Encryption, Integrity, PRF, DH Group) 
DH Public Key
Nonce
Source IP address hash for NAT-T detection - HASH(Initiator SPI | Responder SPI | IP address | UDP port)
Destination IP address hash for NAT-T detection
```

`No Auth method, no lifetime like in IKEv1, but separate PRF transform, NAT-T is embeded, not negotiated, no VIDs, DH exchange is immediate, not after crypto options negotiation`

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI: a1b2c3d4e5f60718
  Responder SPI: 0000000000000000
  Next Payload: Security Association (33)
  Version: 2.0
  Exchange Type: IKE_SA_INIT (34)
  Flags: 0x08 (Initiator)
  Message ID: 0
  Length: 430

Security Association
  Next Payload: Key Exchange (34)
  Length: 120
  Proposal Number: 1
  Protocol ID: IKE (1)
  SPI Size: 0
  Number of Transforms: 4
  Transform: Encryption Algorithm (AES-CBC, 256-bit)
  Transform: Integrity Algorithm (HMAC-SHA2-256-128)
  Transform: Pseudorandom Function (PRF-HMAC-SHA2-256)
  Transform: Diffie-Hellman Group (MODP 2048) - I am willing to use DH group 14 for this IKE SA -    This is negotiation

Key Exchange
  Next Payload: Nonce (40)
  Length: 264
  Diffie-Hellman Group: MODP 2048
  Key Exchange Data:
    9f:73:aa:41:4c:90:1e:77:...

Nonce
  Next Payload: Notify (41)
  Length: 36
  Nonce Data:
    4a:8c:91:ff:10:be:...

Notify
  Next Payload: Notify (41)
  Length: 28
  Notify Message Type: NAT_DETECTION_SOURCE_IP
  Notification Data:
    7e:11:3a:...

Notify
  Next Payload: None (0)
  Length: 28
  Notify Message 
  Type: NAT_DETECTION_DESTINATION_IP
  Notification Data:
    91:5a:8c:...
```

**Packet 2 - INIT_SA**

Responder sends second  IKE_SA_INIT packet, which includes:

```
Initiator, Responder SPI
SA
 |-Chosen Proposal 
                 |-Transforms (Encryption, Integrity, PRF, DH Group) 
DH public part
Nonce
NAT-T hashes
```

**Packet Itself**

```
Internet Key Exchange Version 2
  Initiator SPI: a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Next Payload: Security Association (33)
  Version: 2.0
  Exchange Type: IKE_SA_INIT (34)
  Flags: 0x20 (Response)
  Message ID: 0
  Length: 434

Security Association
  Next Payload: Key Exchange (34)
  Length: 120
  Proposal Number: 1
  Protocol ID: IKE (1)
  SPI Size: 0
  Number of Transforms: 4
  Transform: Encryption Algorithm (AES-CBC, 256-bit)
  Transform: Integrity Algorithm (HMAC-SHA2-256-128)
  Transform: Pseudorandom Function (PRF-HMAC-SHA2-256)
  Transform: Diffie-Hellman Group (MODP 2048)

Key Exchange
  Next Payload: Nonce (40)
  Length: 264
  Diffie-Hellman Group: MODP 2048
  Key Exchange Data:
    3c:81:de:aa:55:09:...

Nonce
  Next Payload: Notify (41)
  Length: 36
  Nonce Data:
    91:ab:cc:42:...

Notify
  Next Payload: Notify (41)
  Length: 28
  Notify Message Type: NAT_DETECTION_SOURCE_IP
  Notification Data:
    1c:55:99:...

Notify
  Next Payload: None (0)
  Length: 28
  Notify Message Type: NAT_DETECTION_DESTINATION_IP
  Notification Data:
    8e:44:21:...
```


**Packet 3 - INIT_AUTH**

Initiator sends first IKE_AUTH Encrypted Packet, which includes:

```
Initiator, Reponder SPI from IKE_INIT
Encrypted
        |-Initiator ID
        |-Auth method
        |-Auth Hash
        |-SA
           |-Proposal
                    |-SPI - for traffic it will RECEIVE
                    |-Transform for Encryption
                    |-Transform for Packet Authentication and Integrity
        |-Traffic Selector for Initiator
        |-Traffic Selector for Responder
```

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI: a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Next Payload: Encrypted and Authenticated (46)
  Version: 2.0
  Exchange Type: IKE_AUTH (35)
  Flags: 0x08 (Initiator)
  Message ID: 1
  Length: 348

Encrypted and Authenticated
  Initialization Vector:
    7e:19:aa:03:...
  Encrypted Data:
    Identification - Initiator
      ID Type: ID_USER_FQDN (3)
      Identification Data: user1

    Authentication
      Authentication Method: Shared Key Message Integrity Code
      Authentication Data:
        6f:92:11:88:...

    Security Association (Child SA)
      Proposal Number: 1
      Protocol ID: ESP (3)
      SPI Size: 4
      SPI: 1a2b3c4d
      Transform: AES-CBC-256
      Transform: HMAC-SHA2-256-128

    Traffic Selector - Initiator
      Number of TSs: 1
      TS Type: IPv4 Address Range
      Start Address: 0.0.0.0
      End Address: 255.255.255.255
      Start Port: 0
      End Port: 65535

    Traffic Selector - Responder
      Number of TSs: 1
      TS Type: IPv4 Address Range
      Start Address: 0.0.0.0
      End Address: 255.255.255.255
      Start Port: 0
      End Port: 65535

  Padding Length: 3
  Integrity Checksum: verified
```

**Packet 4**

Responder sends reply to IKE_AUTH message, which includes:

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-Responder ID
        |-Auth Method
        |-Auth Hash
        |-SA
           |-Proposal
                    |-SPI - which it wants to get inbound
                    |-Encryption Transform
                    |-Integrity transform - if not AEAD cipher is used
        |-Traffic selector initiator
        |-Traffic selector responder
```

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI: a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Next Payload: Encrypted and Authenticated (46)
  Version: 2.0
  Exchange Type: IKE_AUTH (35)
  Flags: 0x20 (Response)
  Message ID: 1
  Length: 466

Encrypted and Authenticated
  Initialization Vector
  Decrypted Data:

    Identification - Responder
      ID Type: ID_FQDN
      Identification Data: vpn.example.com

    Authentication
      Authentication Method: Shared Key Message Integrity Code
      Authentication Data: AUTH_r

    Security Association (CHILD_SA)
      Proposal 1: ESP
        SPI: 0x1122EEFF        ← Responder inbound ESP SPI
        Encryption Algorithm: AES-GCM-256
        Integrity Algorithm: NONE
        ESN: No

    Traffic Selector - Initiator
      TS Type: IPv4
      Start Address: 10.0.0.10
      End Address: 10.0.0.10

    Traffic Selector - Responder
      TS Type: IPv4
      Start Address: 0.0.0.0
      End Address: 255.255.255.255

  Padding
  Integrity Checksum: verified
```

### IKEv2 Certificates

- Certs auth is more secure then PSK
- Certs completely kill offline cracking
- Because the attack surface disappears
- If an attacker captures one IKE exchange, he can do bruteforce attack to AUTH payload (MAC)
- What attacker does not have:
    - Private key
    - Any shared secret
    - Any value that can be guessed
- Private keys are not guessable
- Certs completely eliminate PSK dictionary attacks, capture now - crack later attacks

What does NOT change:

- Number of messages (still 4 in the basic flow)
- IKE_SA_INIT packets (frames 1 & 2)
- DH, nonces, NAT detection, SPIs
- CHILD_SA negotiation
- Traffic selectors
- Encryption of IKE_AUTH

What DOES change:

- New payloads appear
- AUTH payload content changes: Digital Signature instead of MAC
- Certificate validation happens off-wire

**What actually changes on the wire**

```
PSK:
  ID + AUTH(MAC)

CERT:
  ID + CERT + AUTH(SIGN)
```

`Everything else is identical`  

Packet 3 — IKE_AUTH (Initiator → Responder) - Changes:

- Certificated added as a payload - initiator’s public certificate
- Usually full chain (leaf + intermediates)
- Public key only (never private key)
- CERTREQ is added - optional
- CERTREQ means “please send me a certificate issued by one of these CAs”
- It’s about CA selection, not authentication itself
- CERTREQ payload says: “If you send me a certificate, it must chain up to one of these Certificate Authorities.”
- It contains: `Certificate encoding (X.509), One or more CA Distinguished Names`
- AUTH payload (CHANGED): HMAC of PSK and other fields > Signature: Same data(As for HMAC) is signed - Proves possession of private key

**Packet 3 Example with cert instead of PSK**

```
Internet Key Exchange Version 2
  Initiator SPI: a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Next Payload: Encrypted and Authenticated (46)
  Version: 2.0
  Exchange Type: IKE_AUTH (35)
  Flags: 0x08 (Initiator)
  Message ID: 1
  Length: 652

Encrypted and Authenticated
  Initialization Vector:
    7a:3c:91:8f:2d:11:aa:6e:43:90:cd:1f:82:54:9a:01
  Decrypted Data:
    Identification - Initiator
      Next Payload: Certificate (37)
      ID Type: ID_FQDN (2)
      Identification Data: user@vpn.example.com

    Certificate
      Next Payload: Certificate Request (38)
      Certificate Encoding: X.509 Certificate - Signature (4)
      Certificate Data:
        -----BEGIN CERTIFICATE-----
        MIIDqTCCApGgAwIBAgIUVn6n...
        ...base64 omitted...
        -----END CERTIFICATE-----

    Certificate Request
      Next Payload: Authentication (39)
      Certificate Encoding: X.509 Certificate - Signature (4)
      Certification Authority:
        CN=User-CA,O=Example Corp,C=US

    Authentication
      Next Payload: Security Association (33)
      Authentication Method: Digital Signature (14)
      Authentication Data:
        30:45:02:21:00:9c:81:5a:3e:7f:2b:19:ae:
        6f:44:32:aa:91:cd:2e:55:1f:8b:3c:01:
        02:20:6d:9e:43:bb:91:ca:fe:12:7a:cc:
        9f:48:8e:91:0b:11:82:77:41:9e:aa:2d

    Security Association
      Next Payload: Traffic Selector - Initiator (44)
      Proposal Number: 1
      Protocol ID: ESP (3)
      SPI Size: 4
      SPI: 0xAABBCCDD
      Transforms:
        Transform Type: Encryption Algorithm (ENCR)
          Transform ID: AES-GCM-256 (20)
        Transform Type: Extended Sequence Numbers (ESN)
          Transform ID: No ESN (0)

    Traffic Selector - Initiator
      Next Payload: Traffic Selector - Responder (45)
      Number of TSs: 1
      TS Type: IPv4 (7)
      IP Protocol ID: Any (0)
      Start Port: 0
      End Port: 65535
      Start Address: 10.0.0.10
      End Address: 10.0.0.10

    Traffic Selector - Responder
      Next Payload: None (0)
      Number of TSs: 1
      TS Type: IPv4 (7)
      IP Protocol ID: Any (0)
      Start Port: 0
      End Port: 65535
      Start Address: 0.0.0.0
      End Address: 255.255.255.255

  Padding Length: 6
  Padding: 00 00 00 00 00 00
  Integrity Checksum: verified
```

Packet 4 — IKE_AUTH (Responder → Initiator)

- The same as for PSK, But
- Sends its certificate
- Signs AUTH with its private key - Signature instead of PSK

**What AUTH actually signs (important)**  
Exactly the same data for PSK and certs:

- IKE_SA_INIT messages (entire payloads)
- ID payload
- SA payload (if present)
- TS payloads (if present)

**What happens off-wire (but matters)**

- Verifies certificate chain
- Checks CA trust
- Checks validity period
- Checks revocation (CRL / OCSP)
- Matches ID to certificate identity

`None of that appears in packets`

### EAP + PSK

- EAP allows to use additional authentication in addirion to PSK or Certs: username/password or additional cert
- Used for RA VPN
- In IKEv1 it called XAUTH
- 8 messages in total, instead of 4
- `When EAP is used, messages 1–2 unchanged, 3–4 modified, and extra messages 5-8 are added`
- EAP happens inside the IKE_AUTH exchange, after
  - IKE_SA_INIT is complete
  - DH keys are established
  - The IKE SA is encrypted
- All EAP messages are encrypted on the wire

**Work flow**

- Messages 3-6 - EAP authentication process + Configuration request
- Messages 7-8 - Regular IKE_Auth exchange: Authentication, CHILD_SA creation, Traffic selectors + Configuration Reply (IP, GW, DNS...)
- So EAP + Configuration request inster itself before IKE_AUTH messages
- Auth and CHILD_SA  happen only after EAP

**Timeline summary**

```
IKE_SA_INIT      → crypto, DH, NAT, cookies
IKE_AUTH (3–6)   → WHO ARE YOU? (EAP)
IKE_AUTH (7–8)   → PROVE IKE ID (PSK) + CREATE CHILD_SA
```

**EAP + PSK Example - Packets 3-8**

**Packet 3 - IKE_AUTH (Initiator → Responder)**

`No Auth here like in regular packet 3 without EAP, No SA Proposals, No Traffic selectors - this means that Client wants EAP`

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-Initiator ID
        |-Configuration Request
```

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI: 0xa1b2c3d4e5f60718
  Responder SPI: 0x1122334455667788
  Next Payload: Encrypted and Authenticated (46)
  Version: 2.0
  Exchange Type: IKE_AUTH (35)
  Flags: 0x08 (Initiator)
  Message ID: 1
  Length: 296

Encrypted and Authenticated Payload
  Decrypted Data:
    Identification - Initiator
      ID Type: ID_FQDN (2)
      Identification Data: user1@example.com

    Configuration Payload
      Configuration Type: CFG_REQUEST (1)
      Attribute:
        INTERNAL_IP4_ADDRESS

  Padding Length: 6
  Integrity Checksum: verified
```

**Packet 4 - IKE_AUTH (Responder → Initiator) - EAP Request**

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-Responder ID
        |-EAP Request
```

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI: 0xa1b2c3d4e5f60718
  Responder SPI: 0x1122334455667788
  Next Payload: Encrypted and Authenticated (46)
  Version: 2.0
  Exchange Type: IKE_AUTH (35)
  Flags: 0x20 (Response)
  Message ID: 1
  Length: 308

Encrypted and Authenticated Payload
  Decrypted Data:
    Identification - Responder
      ID Type: ID_FQDN (2)
      Identification Data: vpn.example.com

    EAP Payload
      Code: Request (1)
      Identifier: 1
      Type: Identity (1)

  Padding Length: 5
  Integrity Checksum: verified
```

**Packet 5 - IKE_AUTH (Initiator → Responder) - EAP Identity from Client - Username**

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-EAP ID
```

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI: 0xa1b2c3d4e5f60718
  Responder SPI: 0x1122334455667788
  Next Payload: Encrypted and Authenticated (46)
  Version: 2.0
  Exchange Type: IKE_AUTH (35)
  Flags: 0x08 (Initiator)
  Message ID: 2
  Length: 284

Encrypted and Authenticated Payload
  Decrypted Data:
    EAP Payload
      Code: Response (2)
      Identifier: 1
      Type: Identity (1)
      Identity: user1@example.com

  Padding Length: 7
  Integrity Checksum: verified
```

**Username is now known**

**Packet 6 - IKE_AUTH (Responder → Initiator) - EAP authentication challenge**

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-EAP Challenge
`   
```

**Packet itself**

```
IKEv2
  Initiator SPI: a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Exchange Type: IKE_AUTH
  Flags: Response
  Message ID: 2
  Encrypted

Decrypted Payloads:
  EAP Payload
    Code: Request (1)
    Identifier: 2
    Type: MD5-Challenge (4)
    Value-Size: 16
    Challenge:
      9f:83:21:ab:7c:44:9e:12:3d:aa:09:be:77:01:fe:22
```

**Packet 7 - IKE_AUTH (Initiator → Responder) - Auth challenge**

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-EAP Challenge 
```

**Packet itself**

```
IKEv2
  Initiator SPI: a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Exchange Type: IKE_AUTH
  Flags: Initiator
  Message ID: 3
  Encrypted

Decrypted Payloads:
  EAP Payload
    Code: Response (2)
    Identifier: 2
    Type: MD5-Challenge (4)
    Value-Size: 16
    Response:
      5e:44:aa:91:3c:99:f1:77:6d:02:ab:45:11:fe:88:90
```

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-Auth method
        |-Auth Hash
        |-SA
           |-Proposal
             |-SPI
             |-Protocol: ESP
             |-Encryption transform
             |-Integrity transform
        |-Traffic selector - Initiator
        |-Traffic Selector - Responder
```

**Key points**

- FIRST time AUTH appears
- PSK proves IKE identity
- CHILD_SA proposed

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI:  a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Next Payload:  Encrypted and Authenticated (46)
  Version:       2.0
  Exchange Type: IKE_AUTH (35)
  Flags:         0x08 (Initiator)
  Message ID:    3
  Length:        412

Encrypted and Authenticated Payload
  Decrypted Data:
    Authentication
      Authentication Method: Shared Key Message Integrity Code
      Authentication Data:
        8b:19:fa:44:...

    Security Association
      Proposal #1
        Protocol ID: ESP (3)
        SPI: 0x1001a2b3
        Transforms:
          ENCR_AES_CBC (256)
          INTEG_HMAC_SHA2_256
          ESN disabled

    Traffic Selector - Initiator
      TS Type: TS_IPV4_ADDR_RANGE
      Start Address: 0.0.0.0
      End Address: 255.255.255.255

    Traffic Selector - Responder
      TS Type: TS_IPV4_ADDR_RANGE
      Start Address: 10.0.0.0
      End Address: 10.0.0.255

  Padding Length: 4
  Integrity Checksum: verified
```

**Packet 8 - IKE_AUTH (Responder → Initiator) — FINAL**

```
Initiator and Responder SPI from IKE_INIT
Encrypted
        |-Auth method
        |-Auth Hash
        |-SA
           |-Proposal
             |-SPI
             |-Protocol: ESP
             |-Encryption transform
             |-Integrity transform
        |-Configuration payload: IP, Gateway, DNS...
```

**Packet itself**

```
Internet Key Exchange Version 2
  Initiator SPI:  a1b2c3d4e5f60718
  Responder SPI: 1122334455667788
  Next Payload:  Encrypted and Authenticated (46)
  Version:       2.0
  Exchange Type: IKE_AUTH (35)
  Flags:         0x20 (Response)
  Message ID:    3
  Length:        398

Encrypted and Authenticated Payload
  Decrypted Data:
    Authentication
      Authentication Method: Shared Key Message Integrity Code
      Authentication Data:
        4c:77:19:aa:...

    Security Association
      Proposal #1
        Protocol ID: ESP (3)
        SPI: 0x2009fabc
        Transforms:
          ENCR_AES_CBC (256)
          INTEG_HMAC_SHA2_256
          ESN disabled

    Configuration Payload
      Configuration Type: CFG_REPLY (2)
      Attributes:
        INTERNAL_IP4_ADDRESS: 10.0.0.25
        INTERNAL_IP4_DNS: 10.0.0.10

  Padding Length: 6
  Integrity Checksum: verified 
```
## IKE scan

**Test Phase 1**

```
ike-scan -M -A --id=0000 1.1.1.1

-M - multiline, for comfortable reading
-A - aggressive
--id - IKE identity
- P - show PSK hash
```

## ESP

- Separate IP protocol for Data Plane
- Confidentiality, authentication, replay protection
- IP protocol number 50
- Supports encryption and NAT-T
- ESP mode: tunnel or transport mode
- Transport mode - adds ESP header after original IP header + ESP trailer + ESP auth
- Transport mode is practically never used, only when 2 firewalls communicate only with each other
- Tunnel mode - encrypts the entire original packet - adds a new set of IP headers
- Required parametres for Tunnel mode:
    - Symmetric cipher
    - Hash
    - DH group
    - Lifetime

**Data flow in practice**

- Router receives an ESP packet
- Reads SPI from the ESP header
- Looks up SAD to find:
    - Encryption key
    - Integrity key
    - Mode, lifetime, etc.
- Verifies ICV (if authentication is used)
- Decrypts payload only using the key

Packets layout:

<img width="1151" alt="image" src="https://github.com/philipp-ov/foundation/assets/116812447/dd8e9064-7dde-478f-906f-48ef43077b04">

## AH

- Separate protocol above IP with encapsulation for data plane
- Data Integrity, Authentication, Protection from replays
- IP 51
- Does not support encryption
- Does not support NAT-T
- Transorm set for authentication header defines only HMAC function, for example `ah-sha-hmac`

## Configuration - Cisco

Three possible ways to configure IPSec tunnel on Cisco Routers:

- Pure (Policy-Based) IPsec - crypto-map–based IPsec
    - Traffic is matched by crypto ACLs
    - No tunnel interface
    - IPSec is applied directly to the physical interface via a crypto map
    - Routing is not aware of the tunnel
    - No dynamic routing protocols
- IPsec + VTI (Virtual Tunnel Interface) - route-based IPsec
    - A logical Tunnel interface is created
    - IPSec protects the tunnel traffic
    - Routing happens over the tunnel
    - Tunnel Interface
                    └── IPSec Profile
    - Supports dynamic routing
- IPsec with GRE (GRE over IPsec) - A tunnel inside a tunnel
    - GRE provides encapsulation
    - `Can be done both with crypto maps and IPSec profile` 
    - IPSec encrypts the GRE packets
    - GRE handles routing, MULTICAST, multiple subnets
    - Can be policy-based or route-based
    - `Use only when multicast is required`
- A VTI-based (route-based) IPsec endpoint and a policy-based (crypto-map) endpoint are architecturally incompatible
- Policy-based IPsec Expects specific proxy IDs (src/dst subnets)
- VTI-based IPsec Proxy IDs are typically 0.0.0.0/0 ↔ 0.0.0.0/0 (or a host /32)
- IKE Phase 2 (CHILD_SA) will fail
- But At the protocol level, it is the same protocol

**Why we shouldnt use Crypto maps**

- They cannot natively support MPLS
- Configuration can be complex
- They are commonly misconfigured
- Consume excessive amount of TCAM

### IPSec + VTI + IKEv2 example

`Tunnel` (vrf, bandwidth, ip, mss, mtu, load interval, bfd, source, mode, path mtu discovery, destination, **ipsec profile**) > `ipsec profile` (idle, **transform-set**, pfs group, **ike-v2-profile**) > `ike-v2-profile` (identity, authentication, **keyring**, lifetime, dpd), `transform set`(encryption, hash, mode) > `keyring` (address, key)  
  
`ike-v2-policy` (vrf, **proposals**) > `proposal` (encryption, hash, pfs group)

```
Tunnel
  └─ IPsec Profile
       ├─ Transform Set   (ESP parameters)
       └─ IKEv2 Profile
            └─ Keyring
IKEv2 Policy
  └─ Proposal             (IKE SA parameters)
```

#### Tunnel

```
interface Tunnel12
 description Tunnel
 bandwidth 2000000
 bandwidth qos-reference 1000000
 vrf forwarding IPSEC
 ip address 10.16.6.37 255.255.255.252
 no ip redirects
 ip mtu 1400
 ip tcp adjust-mss 1360
 load-interval 30
 shutdown
 bfd interval 500 min_rx 500 multiplier 3
 tunnel source Port-channel1.440
 tunnel mode ipsec ipv4
 tunnel destination 11.11.11.11
 tunnel path-mtu-discovery
 tunnel vrf corp
 tunnel protection ipsec profile Corp-profile
end
```

#### IPSec Profile

```
crypto ipsec profile IPSEC-profile
 set security-association idle-time 3600
 set transform-set IPSEC 
 set pfs group1
 set ikev2-profile CorpIPSEC-Prisma-ikev2-profile
```

#### Transform set

Phase 2 options

```
crypto ipsec transform-set IPSEC esp-aes 256 esp-sha256-hmac 
 mode tunnel
```

#### IKE v2 Profile

Phase 1 options

```
crypto ikev2 profile IPSEC-profile
 match identity remote any
 authentication remote pre-share
 authentication local pre-share
 keyring local CorpIPSEC-vpn-keyring
 lifetime 28800
 dpd 10 3 periodic
```

#### Keyring

```
crypto ikev2 keyring CorpIPSEC-vpn-keyring
 peer Corp_Tunnel12
  address 34.11.11.11
  pre-shared-key CY5R2TugteXEGBv6
```

#### IKE-v2 Policy

```
crypto ikev2 policy remote-ikev2-policy 
 match fvrf corpInternet
 match fvrf wan_underlay
 proposal remote-ikev2-proposal
 proposal 3rdParty-ikev2-proposal
 proposal 3rdParty-ikev2-Sha256-proposal
 proposal CorpIPSEC-ikev2-proposal
 proposal oci_ikev2-proposal
```

#### IKE Proposal

Phase 1 options

```
crypto ikev2 proposal CorpIPSEC-ikev2-proposal 
 encryption aes-cbc-256 aes-cbc-128
 integrity sha512 sha384 sha256
 group 19 14 5 2
```

### IPSec with GRE via Crypto Maps example - IKEv1 - Can be IKEv2

```
GRE Tunnel
  └─ Crypto Map
       ├─ Transform Set        (ESP parameters)
       ├─ Peer                 (remote IP)
       ├─ ACL (Interesting traffic)
       └─ ISAKMP / IKE Policy
            └─ Keyring / PSK
```

### Pure IPSec with Crypto Maps - IKEv1 - Can be IKEv2

```
Interface
  └─ Crypto Map
       ├─ ACL (interesting traffic)
       ├─ Peer
       ├─ Transform Set
       └─ IKE / ISAKMP Policy
            └─ Keyring / PSK
```

### IPSec + GRE - no Crypto Maps - IPSec profile - IKEv2 - can be IKEv1

```
GRE Tunnel
  └─ Tunnel Protection
       └─ IPsec Profile
            ├─ Transform Set
            └─ IKEv2 Profile
                 └─ Keyring
IKEv2 Policy
  └─ Proposal
```

## Troubleshooting

**Show status of all Tunnel interfaces**

```
router#show ip int br
Interface              IP-Address      OK? Method Status                Protocol

Tunnel0                10.125.6.1      YES NVRAM  up                    up      
Tunnel1                10.125.6.5      YES NVRAM  up                    up      
Tunnel3                unassigned      YES unset  administratively down down    
Tunnel4                10.125.6.9      YES NVRAM  up                    down    
Tunnel5                10.125.6.13     YES NVRAM  up                    down    
```

**Flapping tunnels on Cisco**

```
Router#show logging | inc changed
20995065: Feb 13 2024 00:59:36.794 EST: %LINK-3-UPDOWN: Interface TenGigabitEthernet0/1/0, changed state to down
20995067: Feb 13 2024 00:59:37.794 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface TenGigabitEthernet0/1/0, changed state to down
20995068: Feb 13 2024 00:59:36.794 EST: %LINK-3-UPDOWN: SIP0/1: Interface TenGigabitEthernet0/1/0, changed state to down
20995078: Feb 13 2024 00:59:58.197 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel1, changed state to down
20995079: Feb 13 2024 00:59:58.845 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel102, changed state to down
20995084: Feb 13 2024 01:00:00.167 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel0, changed state to down
20995085: Feb 13 2024 01:00:00.787 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel16, changed state to down
20995086: Feb 13 2024 01:00:01.385 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel11, changed state to down
20995087: Feb 13 2024 01:00:01.765 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel12, changed state to down
20995088: Feb 13 2024 01:00:02.035 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel15, changed state to down
20995111: Feb 13 2024 01:01:35.759 EST: %LINEPROTO-5-UPDOWN: Line protocol on Interface Tunnel102, changed state to up
```
## Debug

```
Debug crypto condition peer ipv4 140.238.149.242
Debug crypto ikev2
Debug crypto ipsec
```

## IPSec VPN solutions

- Site-to-site - Multivendor
- DMVPN - Cisco
- GET-VPN - Cisco
- FlexVPN - Cisco
- Remote Access VPN

## IPSec tunnels and MTU

## Curiosity questions

Why 2 Tunnels?


