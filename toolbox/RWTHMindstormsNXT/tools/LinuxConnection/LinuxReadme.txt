This archive contains some useful scripts to get the
RWTH - Mindstorms NXT Toolbox for MATLAB running under Linux.


Scripts in this archive:

* btconnect
Syntax of this script is: btconnect <NXTsMACorName>
The expression <NXTsMACorName> can either be the MAC address (i.e. 00:16:.....) 
or the Name (i.e.: "My NXT") of the NXT brick that you want to connect to. 
After a successful connection, the terminal will be blocked until hung up. The 
toolbox is now ready to use! For further information see the online help (call 
"btconnect --help").

* 41-legonxt.rules
This udev rule file is used to make sure that an NXT device 
is ready to be used with USB and Bluetooth. See below in the USB section for 
further explanations.



*** BLUETOOTH ***

To get Bluetooth up and running with the NXT and our toolbox, the bluez 
bluetooth stack must be installed. In order to do so, you should use your 
packet manager (e.g. Debian's apt-get) to retrieve the following packets (or 
similar, depending on your distribution):
 - bluetooth
 - bluez-utils  (should be included in bluetooth anyway)
 - dbns
 - dbns-x11     (includes the bluetooth-applet)

Once properly installed, you should execute the following command in a terminal 
window (assuming you use the Gnome Desktop environment):

 bluetooth-applet --singleton

Once the applet is running, a Bluetooth icon should appear in your system tray. 
This is important: You are ready to use the script btconnect now, but when 
using it the first time, the Bluetooth icon in the systray will flash and wait 
for user input. Enter the authorization key that was set on the NXT before 
(usually 1234). Now the script btconnect should create a device called 
/dev/rfcomm0, which is the virtual serial port the MATLAB toolbox uses. It 
might be a good idea to add the bluetooth-applet to your autostart. If the 
bluetooth-applet can't be found on your machine, try installing desktop- 
specific packets (i.e. gnome-bluetooth).

If you use KDE, you may need similar steps to get a Bluetooth icon in the 
system tray. Refer to the KDE documentation for details.

If your user account doesn't have permissions to read and write the device 
files /dev/rfcommX, the connection may fail. You can use the provided 
41-legonxt.rules file to assign read and write permission to the system group 
"legonxt". You then need to make sure that the group "legonxt" exists and make 
your user account a member of the group. See the USB paragraphs below for more 
information.


*** USB ***

First you have to make sure that the open-source library libusb is properly 
installed. You can either retrieve it from the project's homepage 
http://libusb.wiki.sourceforge.net/ or download it using your packet manager 
(e.g. Debian's apt-get). If the package "libusb" does not work, please try 
installing "libusb0", the latest version "libusb-0.xx", or "libusb-0.1",
or "libusb-dev". You definitely need version 0.1, version 1.0 will not work
(but there is a compatibility layer for 0.1 which we have never tested).

This was just one step. The second thing to do is making connected NXT devices 
appear inside the /dev/ folder with the right read/write permissions. That is 
what the udev rule file is needed for (root rights are required):

1. Copy the file 41-legonxt.rules to /etc/udev/rules.d,
   e.g., by executing the following:

cp 41-legonxt.rules /etc/udev/rules.d

2. Once successful, you might need to restart the udev-service. If unsure,
   reboot your system. When connecting an NXT device to a USB port, a new
   device /dev/legonxt-x-y should appear (with x and y depending on your
   kernel and USB bus and port).

3. The /dev/legonxt file should be read-/writeable by all users belonging
   to the group "legonxt". Thus, you need to make sure that this group exists
   and your user account is a member of it. Alternatively, you can edit the
   rules file and change the GROUP="legonxt" entries (one per line) to 
   GROUP="plugdev", for example. On Debian-like distributions, users are
   member of the "plugdev" group by default. Then you don't need to create
   the group and fiddle with membership.


This manual and the USB scripts are partly taken from:
http://forums.nxtasy.org/index.php?showtopic=2143&view=findpost&p=16723

If you need more resources, these links are recommended for further reading:

http://jan.kollhof.net/wiki/projects/Lego/linux
http://www.lysator.liu.se/~nisse/lego-nxt-dev/
http://nxt.ivorycity.com/index.php?/categories/3-Linux-USB
