#!/bin/sh
## Tomato AD-Blocking script
## https://github.com/SilentBob999/adblock

ADB="/tmp/ADBLOCK.sh"
{
cat <<'ENDF' >$ADB
#!/bin/sh

REDIRECTIP="0.0.0.0"
CIFS="/cifs1/dnsmasq" # adapt to your need
CIFSRequire="N" # "Y"/*"N"

WHITELIST="facebook.com dropbox.com"

## Sources
## Warning ( ( HUGE : S5 , S8 ) ( BIG : S6 ) CIFSRequire to "Y"
GETS="1 2 3 4 7" # List all source you want here
KeepAsHost="4 7" # Listed here will be merge and used in a external host file

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
