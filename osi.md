# OSI Reference Model

- Open Systems Interconnection model (OSI model) or network suite of protocols - it splits the process of connection between 2 systems and the flow of data into 7 layers
- Other suites exist as well: Internet suite(TCP/IP), AppleTalk....
- Developed by the International Standards Organization (ISO) and CCITT in th 1970-80s
- ISO also created protocol specifications for individual layers of this reference model independently of the TCP/IP protocol suite, and TCP/IP creators never intended to follow the OSI Reference Model
- It was published in 1984 by both the ISO, as standard ISO 7498, and the renamed CCITT (now called the Telecommunications Standardization Sector of the International Telecommunication Union or ITU-T) as standard X.200. 
- Main task: to provide multi-vendor interoperability
- The OSI model is still used as a reference for teaching and documentation;[21] however, the OSI protocols originally conceived for the model did not gain popularity
- Protocol Data Unit (PDU) contains a payload, called the service data unit (SDU), along with protocol-related headers or footers.- 

## Internet protocol suite

- Promoted by IETF
- Combines Physical layer and Data link layer into a Link layer
- All layers above Transport is Application layer
 
## Network organizations

- IEEE -  Institute of Electrical and Electronics Engineers - Manhattan, New York - 1963 - Ethernet, LAG, NAC, Wi-Fi...
- IETF - Internet Engineering Task Force - is a standards organization for the Internet and is responsible for the technical standards that make up the Internet protocol suite (TCP/IP) + OSPF - all its participants are volunteers - published RFCs: https://www.rfc-editor.org 
- IANA - specifies IP numbers for protocols, for example for OSPF

## IEEE 802

- Family of standards  for local area networks (LAN), personal area network (PAN), and metropolitan area networks (MAN)
- 24 groups
- Only for variable sized packets networks
- The number 802 has no significance: it was simply the next number in the sequence that the IEEE used for standards projects
- Describes only data link and physical layers
- IEEE 802 divides the OSI data link layer into two sub-layers: logical link control (LLC) and medium access control (MAC), as follows:
   - Data link layer
         - LLC sublayer
         - MAC sublayer
   - Physical layer
- IEEE 802.3	Ethernet
- 802.1Q VLANS
- 802.1AX - Link Aggregation
- 802.1X - Port Based Network Access control
- 802.11 - Wireless LANs

## Physical layer

- Sends unstructured raw data in bits
- It converts the digital bits into electrical, radio, or optical signals
- Layer specifications define characteristics such as voltage levels, the timing of voltage changes, physical data rates, maximum transmission distances, modulation scheme, channel access method and physical connectors
- The Physical Layer also specifies how encoding occurs over a physical signal, such as electrical voltage or a light pulse. For example, a 1 bit might be represented on a copper wire by the transition from a 0-volt to a 5-volt signal, whereas a 0 bit might be represented by the transition from a 5-volt signal to 0-volt signal

## Data link layer

- Node-to-node data transfer—a link between two directly connected nodes
- Detects and possibly corrects errors
   - Medium access control (MAC) layer - responsible for controlling how devices in a network gain access to a medium and permission to transmit data
   - Logical link control (LLC) layer - responsible for identifying and encapsulating network layer protocols, and controls error checking and frame synchronization
   - Protocol examples: Ethernet, Point-to-Point Protocol (PPP), HDLC, FDDI, Frame Relay, LLDP

## Network layer

- Connect hosts in different networks
- If message is too large for Layer 2 it can be fragmented
- A number of layer-management protocols belong to the network layer: routing protocols, multicast group management, network-layer information and error, and network-layer address assignment

## Transport layer

## Session layer

Sockets in TCP/IP

## Presentaion layer

TLS

## Application layer

HTTP, FTP, SMTP

## OSI protocols terms

- End System (ES) - host
- Intermediate System (IS) - router
- System - network node
- Circuit - interface
- Domain - autonomous system
- Two basic services: connection-less-mode and connection-mode network layer communication
- CLNP - ConnectionLess-mode Network Protocol. The set of services provided by CLNP is called ConnectionLess Network Services, or simply CLNS
- For connection-oriented mode in OSI networks, an adaptation of the X.25 protocol is used. There is no analogous connection-oriented network layer protocol in TCP/IP networks
- NSAP - Network Service Access Point - address of a particular network service on a particular network node in the network.
- SNPA - Sub Network Point of Attachment - in OSI networks, a Layer 2 address of an interface


## NSAP addressing

- An NSAP address is assigned to the entire network node, not to its individual interfaces. A single node requires only one NSAP address in a common setup, regardless of how many network interfaces it uses. As a result, NSAP addressing does not have the notion of per-interface subnets similar to IP subnets.
- NSAP address has a variable length: the minimum size of an NSAP address is 8 octets — with only AFI, System ID, and SEL fields present. The maximum NSAP address size is 20 octets.  

At a high level, an NSAP address consists of two parts:
- The Initial Domain Part (IDP)
- The Domain Specific Part (DSP)

<img width="520" alt="image" src="https://user-images.githubusercontent.com/116812447/201477395-700d8f76-65bc-4cb6-abbb-38f9c25b1bfd.png">

-  Authority and Format Identifier (AFI) (1 octet in the range of 00 to FF) indicates the format of the remaining address fields. The IDI field has a variable length depending on the address format indicated by AFI and might even be omitted. In typical IS-IS deployments, the addressing uses the AFI of 49 in which the length and meaning of the HO-DSP field are entirely up to the administrator.
- Initial Domain Identifier (IDI) - routing domain (the autonomous system) in which the node is located
- High-Order Domain Specific Part (HO-DSP) that identifies the part (or an area) of the domain
- System ID is the unique identifier of the node itself
- SEL or NSEL - NSAP Selector - service. If the value of the SEL octet is 0, no particular service is being addressed, and the entire NSAP address simply identifies the destination node itself without refer- ring to any particular service on that node. An NSAP address in which the SEL octet is set to 0 is called a Network Entity Title (NET), and this is the address that is configured on the node. Configuration of NETs will be a mandatory part of IS-IS configuration. Value of 2F indicates a GRE IP-over-CLNP tunneling. Value of 22 or 1D indicates the OSI TP4 transport layer protocol.

To simplify address structure: **format | autonomous system | area | System ID | service**    
The written format of NSAP addresses uses hexadecimal digits separated into groups of one or more octets by a dot. 
AFI value (1 octet; 2 hexadecimal digits) and then the remainder of the NSAP address simply written in two-octet groups
Example (IDI is not present in it)
```
49.0001.1234.5678.3333.00
```
- 49 - format - always - AFI value - 2 hexadecimal digits - 1 octet
- 0001 - area - HO-DSP - 4 hexadecimal digits - 2 octets
- 1234.5678.3333 - System ID - 4 hexadecimal digits - 2 octets
- 00 - Service - SEL - NET - 2 hexadecimal digits - 1 octet

## Routing in OSI networks

Different levels of routing exist in OSI world. Level 1 and Level 2 routing are provided by the IS-IS routing protocol (ISO 10589). Level 3 routing should have been provided by Inter Domain Routing Protocol (IDRP, ISO 10747). However, BGP killed it, because it could carry NSAP addresses. Level 0 and Level 3 routing are provided by different mechanisms and are not relevant for TCP/IP networks.

- Level 0 routing: Routing between two ES nodes on the same link, or between an ES node and its nearest IS
- Level 1 routing: Routing between ES nodes in a single area of a domain - IS nodes in an area will have a detailed and complete visibility of the entire area’s topology. On Level 1, IS nodes collect lists of all ES nodes directly attached to them, and advertise these lists to each other to learn the placement of all ES nodes
- Level 2 routing: Routing between ES nodes in different areas of a domain - On Level 2, IS nodes do not advertise the list of connected ES nodes anymore. Instead, in this level, IS nodes exchange area prefixes to learn how to reach particular areas
- Level 3 routing: Routing between ES nodes in different domains

