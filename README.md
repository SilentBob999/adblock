adblock
=======
##  Tomato AD-Blocking script
by SilentBob999 https://github.com/SilentBob999/adblock


Use multiple source of HOST files to configure for DNSMASQ to block Malware/Ad server.

#### Work with or without non-volatile storage

#### Performance optimized if using external share (CIFS)

#### Download host / generate config file only if needed


Inspired by / fork from :

  http://www.linksysinfo.org/index.php?threads/addon-add-blocking.25663/
  http://www.linksysinfo.org/index.php?threads/all-u-need-ad-blocking.33191/
  http://www.linksysinfo.org/index.php?threads/script-clean-lean-and-mean-adblocking.68464/
  http://www.dd-wrt.com/wiki/index.php/Ad_blocking


Tested on :

  Linksys E2500 v1.0 (60mb of ram)
  
  Tomato Version 1.28 by shibby
  
  On this router I can activate all source provided (27671K) and it will survive. 
  At the worse moment it got 14mb of free ram but once finished it settle at around 44MB of free ram. 
  This his achieve by downloading, generating, remove duplicate and delete temp on each single source before doing the next. 
  It can achieve all that in less than 12 minutes while any other script I test will crash with such big source.
  
 
## Barebones branch
### Goal is to strip down below 4096 bytes limit for wan up script
achieved by removing comment, functionality and log verbose





# Instructions
Copy code to wanup script (Administration->Scripts->Wan Up)
Edit to your like.

### CIFS="/cifs1/dnsmasq" 
 Adapt this to what you want, dont use JFFS, Only cifs1 or 2 or nothing.
 Create the folder yourself.
 If the folder exist the script will make the best use of it.
 If you specify a path that do not exist the script will not try to use it.
 The script will not crash or bug if cifs1 his offline or online from time to time.
 cifs1 need to be big enouph to be able to hold at least 3 times the sums of he size of all source you specify.
 
### WHITELIST="facebook.com dropbox.com"
 Enter there every site that you dont want to be block (needed if the source you use block it)
 For example. This will remove dropbox.com and dl.dropbox.com from the blacklist but will leave malwaredropbox.com 
 
### GETS="1 2 3 4"
 Its there that you choose which source you want to be use

### S1="http://xxxxx"  
 You can add extra source, no problem

### Use an host local without any modification check or download
  To do that, add a number eg. 99 in the GETS variable without adding an S99=`http` line.
  Then in you $CIFS folder put the host you want and name it "HOST-S99"
  
# About sources provided
Size and quantity of hosts blocked change all the time
### S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml" 
http://pgl.yoyo.org/as/#about
44K - 2,539 hosts
( 4 week old at the moment these line are written )

### S2="http://mirror1.malwaredomains.com/files/justdomains" 
#### USE IT!
http://www.malwaredomains.com/
474K - 23,972 hosts
( updated the same day these line are written ) Seems to get 1-2 update / week

### S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" 
#### USE IT!
http://www.malwaredomainlist.com/mdl.php
52K - 1,661 hosts
( updated the same day these line are written )

### S4="http://winhelp2002.mvps.org/hosts.txt" 
http://msmvps.com/blogs/hostsnews/default.aspx
560K - approx 15,350 hosts
( 2 months old at the moment these line are written ) Seems to get updated every 1-2 months

### S5="http://hosts-file.net/download/hosts.txt" 
http://hosts-file.net/?s=classifications
This list contain all listed site ( full release )
7,873K - 246,284 hosts - by Malwarebytes Corp
( 2 week old at the moment these line are written )

### S6="http://hosts-file.net/hphosts-partial.asp" 
http://hosts-file.net/?s=classifications
This file contains a list of site's that have been added AFTER the last full release of hpHosts
2,719K - 77,661 hosts - by Malwarebytes Corp
( updated the same day these line are written )

### S7="http://hosts-file.net/ad_servers.asp"
http://hosts-file.net/?s=classifications
ATS classificaton only (Ad and Tracking) - included in Source 5
421K - 13,727 hosts - by Malwarebytes Corp
( updated the same day these line are written )

### S8="http://adblock.mahakala.is/hosts" 
Mother of All AD-BLOCKING (08 October 2013) BLOCKS Malware Spyware Bloatware by BSDgeek_Jake
http://forum.xda-developers.com/showthread.php?t=1916098
10,528K  330,332 hosts
( 4 days old at the moment these line are written ) New. Got 3 update in a months


