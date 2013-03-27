#!/bin/bash
# Uses MATLAB SVG logo downloaded from this blog:
#   http://hpmalte.blogspot.com/2009/04/matlab-vsg-icon.html

#Must be run from within setup directory
cd "$(git rev-parse --show-toplevel)"
sudo apt-get install matlab-support

mkdir -p ~/.local/share/applications/
mkdir -p ~/.local/share/icons/scalable
#Copy to local folder
sed "s,HOME,`echo ~`,g" setup/matlab.desktop_template > setup/matlab.desktop
cp setup/matlab.desktop ~/.local/share/applications/
cp setup/matlab_logo.svg ~/.local/share/icons/scalable
#Copy to system folder (so that other users and admins use the icon too)
sed "s,HOME/.local/,/usr/,g" setup/matlab.desktop_template > setup/matlab.desktop
sudo cp setup/matlab.desktop /usr/share/applications/
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
