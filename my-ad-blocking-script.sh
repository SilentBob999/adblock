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
GETS="1 2 3 4"
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
DwAA
ENDF
}

chmod 775 $ADB
$ADB $1
