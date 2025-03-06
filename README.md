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

As for the units-config, there is all what is in the single master-config script, but separatly,
in case you need just one part of some part but not all of them, please refere to this part.
The script of the second server to store and compress the files and directories are also available in this part.

---
#### The test files

The test files are also separated in the same two categories as the config files.

**`/!\` It is highly recommended to use the master-test only once before going to the other units-test, in order to target the problems you could encounter.
By exemple, if you only have a problem with the mail part, do not run the master-script again after fixing the issue, use the mail test to check if it works well.
Also, the units-test are more precise because of their separation with the rest of the parts. `/!\`**

---
If you have any question, please contact me at r4in@duck.com.
