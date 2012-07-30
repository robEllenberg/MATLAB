#!/bin/bash

MATLABROOT=$1

if [ "$MATLABROOT" == "" ]; then
    MATLABROOT=/usr/local/MATLAB/R2011b
fi

echo "Setting up MATLAB symlinks for folder location $MATLABROOT"
read -p "Press any key to Continue..."

sudo ln -sf $MATLABROOT/bin/matlab /usr/bin/matlab
sudo ln -sf $MATLABROOT/bin/mex /usr/bin/mex
sudo ln -sf $MATLABROOT/bin/mcc /usr/bin/mcc

MLINT=$MATLABROOT/bin/glnxa64
if [ ! -d "$MLINT" ]
then
    #Switch to 32 bit version
    MLINT=$MATLABROOT/bin/glnxa32
fi

sudo ln -sf $MLINT/mlint /usr/bin/mlint 

OSFLAG=`uname -a | grep "_64"`
len=${#OSFLAG}

LIBC_PATH=`find /lib/ -name libc.so.6 | head -n 1`
echo $LIBC_PATH

if [[ "$len" -gt 0 ]]
then
	sudo ln -s $LIBC_PATH '/lib64/'
fi
