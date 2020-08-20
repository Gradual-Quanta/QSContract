#

tic=$(date +%s)
min=$(expr \( $tic / 60 \) % 1440)
pgm=${0##*/}
p3=$(echo $pgm|cut -c-3)
rundir=/tmp/$p3$min
runme='./runme.sh'
logf=${runme%.*}.log
echo "--- # $pgm ($p3)"

# input 
echo rundir: $rundir
echo tic: $tic
echo min: $min
echo logf: $logf
qmin="${1:-QmQMSbccamCxtDGknx3cqXHDkFBeJG2PG92phjnTk8nL5W}"
echo qmin: $qmin

if [ -e "$rundir" ]; then
rm -rf "$rundir"
fi
ipfs get -o $rundir /ipfs/$qmin
cd $rundir
if [ -e $runme ]; then
qmrun=$(ipfs add -Q $runme)
chmod a+x $runme
sh -e $runme | tee $logf
fi
qmlog=$(ipfs add -Q $logf)
echo qmlog: $qmlog


# output
qmout=$(ipfs add -Q -r $rundir)
qmwrap=$(ipfs add -Q -n -w -r $rundir)
echo qmout: $qmout
echo url: http://localhost:8080/ipfs/$qmwrap/${rundir##*/}


