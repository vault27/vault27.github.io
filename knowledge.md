# Complete Network & Security Knowledge Map

```
=====================================================================
=                NETWORK & SECURITY KNOWLEDGE MAP                   =
=====================================================================

[L1] PHYSICAL LAYER
---------------------------------------------------------------------
Ethernet PHY (10/100/1G/10G/40G/100G/400G)
Fiber (SMF/MMF, CWDM, DWDM)
Copper (UTP/STP, Cat5e/6/6A/7/8)
Optics (SFP/SFP+/QSFP/QSFP28)
PoE (802.3af/at/bt)
Transceivers, patch panels, cabling

---------------------------------------------------------------------

[L2] DATA LINK LAYER
---------------------------------------------------------------------
Ethernet (802.3)
MAC addressing
ARP / Gratuitous ARP
VLAN (802.1Q)
Q-in-Q (802.1ad)
Private VLAN (PVLAN)
STP (802.1D)
RSTP (802.1w)
MSTP (802.1s)
LACP (802.1AX)
EtherChannel
LLDP / CDP
Bridging / Switching (CAM tables)
Port Security
FHRP:
  HSRP
  VRRP
  GLBP

---------------------------------------------------------------------

[L2.5] OVERLAY / DC FABRIC
---------------------------------------------------------------------
VXLAN
EVPN (BGP EVPN)
VTEP
Cisco ACI (concepts)
Spine-Leaf architecture
vPC / MLAG

---------------------------------------------------------------------

[L3] NETWORK LAYER
---------------------------------------------------------------------
IPv4
IPv6
ICMP / ICMPv6
ARP / ND (Neighbor Discovery)
Routing fundamentals:
  Static Routing
  Policy-Based Routing (PBR)
IGP:
  OSPF
  IS-IS
  EIGRP
EGP:
  BGP (iBGP / eBGP)
  Route Reflectors
  Confederations
Multicast:
  IGMP
  PIM (SM/DM/SSM)
  RP (Rendezvous Point)
NAT:
  SNAT / DNAT
  PAT
  NAT64 / NAT46

---------------------------------------------------------------------

[L3+] SERVICE PROVIDER / MPLS
---------------------------------------------------------------------
MPLS:
  LDP
  RSVP-TE
  Segment Routing (SR-MPLS)
  SRv6
VPN:
  L2VPN (VPWS, VPLS)
  L3VPN (MPLS VPN, VRF)
Traffic Engineering
QoS:
  Classification / Marking (DSCP, CoS)
  Policing / Shaping
  Queuing (CBWFQ, LLQ)
Carrier-grade NAT (CGNAT)

---------------------------------------------------------------------

[L4] TRANSPORT LAYER
---------------------------------------------------------------------
TCP
UDP

Ports / Sessions
Stateful connections

SCTP (rare but important)

---------------------------------------------------------------------

[L5-L7] APPLICATION LAYER
---------------------------------------------------------------------
DNS
DHCP

HTTP / HTTPS
FTP / FTPS / SFTP
SMTP / IMAP / POP3

SNMP
NTP

SSH
Telnet

RDP

SIP / RTP (VoIP)

---------------------------------------------------------------------

[SECURITY PROTOCOLS & CRYPTO]
---------------------------------------------------------------------
IPsec:
  IKEv1 / IKEv2
  ESP / AH
  Transport / Tunnel mode

TLS / SSL

PKI:
  X.509 certificates
  CA / CRL / OCSP

Encryption:
  AES / 3DES
  RSA / ECC
  Diffie-Hellman (DH groups)
  ECDHE

Hashing:
  SHA-1 / SHA-2 / SHA-3
  HMAC

---------------------------------------------------------------------

[AAA / IDENTITY]
---------------------------------------------------------------------
RADIUS
TACACS+

LDAP / LDAPS

Kerberos

Active Directory

802.1X (EAP):
  EAP-TLS
  PEAP
  EAP-TTLS

MFA

SSO / Federation:
  SAML
  OAuth2
  OpenID Connect

---------------------------------------------------------------------

[NETWORK SECURITY TECHNOLOGIES]
---------------------------------------------------------------------
NGFW:
  Palo Alto / Fortinet / CheckPoint / Cisco

IDS / IPS

WAF

DLP

ZTNA / Zero Trust

Microsegmentation:
  Illumio / NSX

Proxy:
  Forward / Reverse

SSL Inspection / Decryption

Sandboxing

---------------------------------------------------------------------

[VPN TECHNOLOGIES]
---------------------------------------------------------------------
IPsec VPN:
  Site-to-Site
  Remote Access

SSL VPN

DMVPN

GRE / GRE over IPsec

L2TP over IPsec

FlexVPN

WireGuard (modern)

---------------------------------------------------------------------

[LOAD BALANCING / ADC]
---------------------------------------------------------------------
L4 Load Balancing
L7 Load Balancing

F5 BIG-IP:
  LTM / APM / ASM / AWAF

GSLB / DNS Load Balancing

Reverse Proxy

---------------------------------------------------------------------

[NAC / ACCESS CONTROL]
---------------------------------------------------------------------
Cisco ISE
Aruba ClearPass

Posture Assessment
Endpoint Compliance

Network Segmentation

---------------------------------------------------------------------

[DATA CENTER & CLOUD]
---------------------------------------------------------------------
Spine-Leaf

VXLAN EVPN

Overlay / Underlay

Kubernetes Networking (CNI)

Cloud:
  AWS VPC
  Azure VNet
  GCP VPC

Security Groups / NSG

---------------------------------------------------------------------

[MONITORING & TELEMETRY]
---------------------------------------------------------------------
Syslog

NetFlow / IPFIX
sFlow

SNMP

Telemetry / Streaming telemetry

SIEM:
  Splunk / QRadar

NDR

---------------------------------------------------------------------

[AUTOMATION & DEVOPS]
---------------------------------------------------------------------
Python

Ansible

REST API

NETCONF / RESTCONF

Terraform

CI/CD

---------------------------------------------------------------------

[TROUBLESHOOTING & TOOLS]
---------------------------------------------------------------------
Wireshark
tcpdump

ping / traceroute

iperf

nmap

curl

logs / packet analysis

---------------------------------------------------------------------

=====================================================================
=                     END OF KNOWLEDGE MAP                          =
=====================================================================
```
