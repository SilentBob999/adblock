#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock

ADB="/tmp/ADBLOCK.sh"
{
cat <<'ENDF' >$ADB
#!/bin/sh

REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need
CIFSRequire="N" # "Y"/"N"

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 ) CIFSRequire to "Y"
GETS="1 2 3 4 7" # List all source you want here
KeepAsHost="" # Listed here will be merge together in 1 single host (used as "addn-hosts=") 

S1="http://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml"  ##44K - 2,539 hosts
S2="http://mirror1.malwaredomains.com/files/justdomains" ##474K - 23,972 hosts
S3="http://www.malwaredomainlist.com/hostslist/hosts.txt" ##52K - 1,661 hosts
S4="http://winhelp2002.mvps.org/hosts.txt" ##560K - approx 15,350 hosts
S5="http://hosts-file.net/download/hosts.txt" #7,873K - 246,284 hosts
S6="http://hosts-file.net/hphosts-partial.asp" #2,719K - 77,661 hosts
S7="http://someonewhocares.org/hosts/hosts" #321K - approx 10,100 hosts
S8="http://adblock.mahakala.is/hosts" ##10,528K  330,332 hosts

ENDF
}

b64="openssl enc -base64 -d"
{
cat <<'ENDF'| $b64 |gunzip >>$ADB
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
ENDF
}

chmod 775 $ADB
$ADB $1
