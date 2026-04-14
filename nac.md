# NAC

## Certificate renewal

- NAC sends to client all chain of certs
- After cert renewal we need to check Wi-Fi, VPN and Wired devices can successfully connect
- All types of devices should be checked: Mac, Windows, iOS, Android, Linux.....
- Devices should be checked on site
- Plus Radius logs on NAC itself should be checked, that there are no many Auth failed messages
- Renewal change should be coordinated with all affected departments
- Mac devices require new NAC server certificate to be installed explicitly on NAC, not only CA and Intermidiate certs
- If client does not trust new certificate it will send `SSL alert right after getting ServerHello with Server Certificate and close connection`
