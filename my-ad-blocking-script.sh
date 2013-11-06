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
GETS="1 2 3 4 7"
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
