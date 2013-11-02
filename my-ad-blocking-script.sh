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
ENDF
}

chmod 775 $ADB
$ADB $1
