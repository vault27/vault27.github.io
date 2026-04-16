# NAC

## Certificate renewal

- Certs are used in: Radius for EAP methods where SSL is used, Radius DTLS, Admin SSL Gui
- NAC sends to client all chain of certs during EAP session
- After cert renewal we need to check Wi-Fi, VPN and Wired devices can successfully connect
- All types of devices should be checked: Mac, Windows, iOS, Android, Linux.....
- Devices should be checked on site
- Plus Radius logs on NAC itself should be checked, that there are no many Auth failed messages
- Renewal change should be coordinated with all affected departments
- Mac devices require new NAC server certificate to be installed explicitly on MAC, not only CA and Intermidiate certs + Trust should be configured explicitly for this cert locally on MAC or via MDM, if it is used
- This trust is configured explicitly for particular Wireless network: `Wi-Fi settings > Network name > 802.1x > Trusted certificate`
- If client does not trust new certificate it will send `SSL alert right after getting ServerHello with Server Certificate and close connection`
- Cert renewal may require `services restart`, consider this, `use load balancer` to disable node before renewal, test on one node first before going to others
- On Cisco ISE Admin cert renewal on main node may require restarting services on all nodes

**Capture traffic on client to troubleshoot new certificate**

```
sudo tcpdump -i en0 ether proto 0x888e -vv -w wifi_handshake.pcap
```
