adblock
=======
##  Tomato AD-Blocking script
by SilentBob999 https://github.com/SilentBob999/adblock


Use multiple source of HOST files
Convert them in a config file for DNSMASQ to block Malware/Ad server

Work with or without non-volatile storage
Performance optimized if using external share (CIFS)
Download host / generate config file only if needed

Inspired by / fork from :

  http://www.linksysinfo.org/index.php?threads/addon-add-blocking.25663/
  http://www.linksysinfo.org/index.php?threads/all-u-need-ad-blocking.33191/
  http://www.linksysinfo.org/index.php?threads/script-clean-lean-and-mean-adblocking.68464/
  http://www.dd-wrt.com/wiki/index.php/Ad_blocking


Tested on :

  Linksys E2500 v1.0
  
  Tomato Version 1.28 by shibby
  
 	


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
  

 
