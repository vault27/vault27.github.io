# Authentication protocols evolution

```
AUTHENTICATION PROTOCOL EVOLUTION (1980s → Present)
====================================================


1) LINK-LAYER AUTHENTICATION ERA (1980s–1990s)
------------------------------------------------

├─ Password over Telnet (1983, RFC 854)
│
├─ TACACS (1984, Cisco proprietary)
│
├─ Kerberos v5 (1988; RFC 1510 – 1993 → RFC 4120 – 2005)
│
├─ PAP (1992, RFC 1334)
│
└─ CHAP (1992, RFC 1334 → RFC 1994 – 1996)



2) AAA CENTRALIZATION ERA (1990s)
-----------------------------------

├─ RADIUS (1991; RFC 2058 – 1997 → RFC 2865 – 2000)
│
├─ NTLM (1993, Windows NT 3.1)
│
├─ TACACS+ (1993–1996, Cisco proprietary)
│
├─ MS-CHAP (1996)
│
└─ MS-CHAPv2 (1999)



3) VPN & EXTENSIBLE AUTHENTICATION ERA (Late 1990s–2000s)
-----------------------------------------------------------

├─ LDAPv3 Bind Authentication (1997, RFC 2251)
│
├─ EAP (1998, RFC 2284 → RFC 3748 – 2004)
│
├─ XAUTH (1998–1999, IKEv1 vendor extension)
│
├─ EAP-TLS (1999, RFC 2716 → RFC 5216 – 2008)
│
├─ L2TP + PPP (1999, RFC 2661)
│
├─ 802.1X (2001, IEEE 802.1X standard)
│
└─ IKEv2 + EAP (2005, RFC 4306 → RFC 7296 – 2014)



4) ENTERPRISE SSO DOMINANCE (2000+)
-------------------------------------

└─ Kerberos v5 becomes default in Windows 2000 Active Directory (2000)
     (RFC 4120 – 2005)



5) WEB FEDERATION & TOKEN ERA (2002–2015)
-------------------------------------------

├─ SAML 1.0 (2002, OASIS)
│
├─ OAuth 1.0 (2007)
│
├─ OAuth 2.0 (2012, RFC 6749)
│
└─ OpenID Connect (2014)



6) PASSWORDLESS & MODERN CRYPTOGRAPHIC ERA (2014+)
----------------------------------------------------

├─ FIDO U2F (2014)
│
└─ WebAuthn (2019, W3C Recommendation)



EVOLUTION SUMMARY
-----------------

Cleartext Passwords
    ↓
PPP Authentication (PAP / CHAP)
    ↓
Centralized AAA (RADIUS / TACACS+)
    ↓
Challenge-Response Domain Auth (NTLM)
    ↓
Ticket-Based SSO (Kerberos)
    ↓
Extensible Frameworks (EAP, 802.1X, VPN)
    ↓
Federated Identity (SAML)
    ↓
Token-Based Authorization (OAuth / OIDC)
    ↓
Public-Key Passwordless (FIDO / WebAuthn)
```