# linux_server
A set of config scripts and their assciated test.

---
#### The config files

The config files are separated in two categories : the master-config and the units-config.
The master-config is meant to config everything in this list :
- SSH
- Web server
- DNS server (to resolve localy the name of the website)
- Mail server
- NTP server
- NFS server (with another physical server, both the scripts are available in the units-config part)

---
#### The units-config

This is all what is in the single master-config script, but separatly. In case you need just one part of some part but not all of them, please refere to this part.
The script of the second server to store and compress the files and directories are also available in this part.

---
If you have any question, please contact me at r4in@duck.com.
