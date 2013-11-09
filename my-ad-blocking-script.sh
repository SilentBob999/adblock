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
j2bx5Q00DeM/C/mwmwgUAAA=
ENDF
}

chmod 775 $ADB
$ADB $1
