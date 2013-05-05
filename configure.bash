#!/bin/bash
# Uses MATLAB SVG logo downloaded from this blog:
#   http://hpmalte.blogspot.com/2009/04/matlab-vsg-icon.html

#Must be run from within setup directory
cd "$(git rev-parse --show-toplevel)"
sudo apt-get install matlab-support

sudo desktop-file-install setup/matlab.desktop
sudo mkdir /usr/share/icons/scalable
sudo cp setup/matlab_logo.svg /usr/share/icons/scalable/

TOOLBOX_SCRIPT="run('`pwd`/addToolboxPaths.m');"
if [[ -f startup.m ]]
then
    IS_SETUP=`grep "addToolboxPaths" startup.m`
    if [ ${#IS_SETUP} ]
    then
        #Do nothing, startup is already setup
        echo "Setup successfully"
    else
        echo $TOOLBOX_SCRIPT >> startup.m
        echo "Setup successfully"
    fi

else
    echo $TOOLBOX_SCRIPT > startup.m
fi
