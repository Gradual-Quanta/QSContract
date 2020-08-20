#

date +'%Y.%m.%d'
tic=$(date +%s)
mfsdir=/my/holoPads
paddir=${HOME}$mfsdir
chmod a+x framasave.sh loop-on-pad.sh

peerid=$(ipfs config Identity.PeerID)
echo peerid: $peerid
prev=$(ipfs add -Q -r $paddir)
sh -e loop-on-pad.sh
qm=$(ipfs add -Q -r $paddir)
echo "$tic: $prev - $qm"
echo "$tic: $qm" >> $paddir/qm.log

