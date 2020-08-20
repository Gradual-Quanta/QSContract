#

# this smart contract takes a pad url
# and publish it on IPFS side (blockRing)
# 
# assumed ipfs is installed

core=hlr
mfsdir=/my/holoPads
paddir=${HOME}$mfsdir

pad_url="$1"
if echo $pad_url | grep -q '^http'; then
 pad_url=${pad_url%%\?*}
 pad=${pad_url##*/}
 period=$(echo ${pad_url##http*://} | cut -d. -f 1)
else
 pad=${1:-WhiteBoard}
 pad_url="https://$period.framapad.org/p/$pad"
 period=bimestriel
fi

if ! which ipfs 1>/dev/null; then
 which -a ipfs
 exit $(expr $$ % 255 + 1)
fi
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
conff=$IPFS_PATH/config
# extract data from JSON config file
peerid=$(json_xs -t string -e '$_ = $_->{Identity}{PeerID};' <$conff)
apiport=$(json_xs -t string -e '$_ = $_->{Addresses}{API}; $_ = (split("/",$_))[4]' <$conff)
gwport=$(json_xs -t string -e '$_ = $_->{Addresses}{Gateway}; $_ = (split("/",$_))[4]' <$conff)
set -e

if [ ! -e $paddir/$pad ]; then
mkdir -p $paddir/$pad
fi
echo pad: $pad
echo period: $period
curl -L -s -S -o $paddir/$pad/$pad.etherpad $pad_url/export/etherpad;
if ! grep -q '404 Not Found' $paddir/$pad/$pad.etherpad; then
curl -s -o $paddir/$pad/$pad.htm $pad_url/export/html;
curl -s -o $paddir/$pad/$pad.pdf $pad_url/export/pdf
curl -s -o $paddir/$pad/$pad.md $pad_url/export/markdown
curl -s -o $paddir/$pad/$pad.txt $pad_url/export/txt
cp -p $paddir/$pad/$pad.htm $paddir/$pad/index.html
< $paddir/$pad/$pad.etherpad json_xs -t json-pretty > $paddir/$pad/$pad.json
 echo "url: \e[32m$pad_url\e[0m"
else
 rm $paddir/$pad/$pad.etherpad
 echo "skipped: \e[33m$pad_url\e[0m"
fi
tic=$(date +%s)
qm=$(ipfs add -Q -r $paddir/$pad)
echo qm: $qm
if [ ! -e $paddir/$pad/qm.log ]; then
echo "# qm log for $pad" > $paddir/$pad/qm.log
fi
echo $tic: $qm >> $paddir/$pad/qm.log
if ipfs files stat --hash $mfsdir 1>/dev/null 2>&1; then
if ipfs files rm -r $mfsdir/$pad 2>/dev/null; then true; fi
else 
ipfs files mkdir -p $mfsdir
fi
ipfs files cp /ipfs/$qm $mfsdir/$pad
# publish holoPads
qm=$(ipfs files stat --hash $mfsdir/$pad)
if ! ipfs files stat --hash "/.${core}ings/published" 1>/dev/null 2>&1; then
ipfs files mkdir -p "/.${core}ings/published"
echo "# ${core}index log file for $peerid" | ipfs files write --create "/.${core}ings/published/${core}index.log"
fi
if ipfs files read "/.${core}ings/published/${core}index.log" > $paddir/$pad/${core}index.log; then true; fi
echo "$tic: $qm, $mfsdir/./$pad" >> $paddir/$pad/${core}index.log
cat $paddir/$pad/${core}index.log | ipfs files write "/.${core}ings/published/${core}index.log"
echo url: http://webui.ipfs.io.ipns.localhost:$apiport/webui/#/files/.${core}ings/published
echo url: http://localhost:$gwport/ipfs/$qm/

