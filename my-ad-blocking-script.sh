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
QNMw/gPPZust9hMAAA==
ENDF
}

chmod 775 $ADB
$ADB $1
