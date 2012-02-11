#!/bin/bash

# lots_hidden -> lots_hidden15 | operation_setup
# newerouput (i.e. 2 hidden) 15 | testbed_setup

DEST=new_bnet_results

#BNETS="adapt_mini1 adapt_subset2_large adapt10_v7e \
	#		diabetes link mildew pigs water"
BNETS="diabetes"  #pigs water link adapt10_v7e mildew diabetes"
BNET_DIR=bnets

export NUM_SAMPLES=5000

echo Using $BNETS

export OMP_NUM_THREADS=64 #uncomment for maxthreads (64)
echo Using $OMP_NUM_THREADS threads


export FIXED_NODES=""
for net in $BNETS
do
	# note this only returns shareds >= 2 
	shared=`python net_to_fg/read_net_erik.py $BNET_DIR/$net.net`
	echo set of possible shared params for $net: $shared
	for s in $shared
	do
		sharedvars=`python net_to_fg/read_net_erik.py $BNET_DIR/$net.net $s`
		echo trying hidden/shared nodes: $sharedvars
		export HIDDEN_NODES=$sharedvars
		export SHARED_NODES=$sharedvars
		./master.sh $BNET_DIR/$net.net
		mkdir -p $DEST/$net
		mv out $DEST/$net/s$s

		export SHARED_NODES=''
		./master.sh $BNET_DIR/$net.net
		mv out $DEST/$net/h$s
	done
	echo completed $net
done

#echo compressing results to: $DEST.7z
#7za a $DEST.7z $DEST
#cp -v $DEST.7z ~/$DEST.7z
