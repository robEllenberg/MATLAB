* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Readme file for RWTH - Mindstorms NXT Toolbox for MATLAB  *
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
*           Version 4.04 - October 1st, 2010                *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *



CONTENTS
---------

1. Copyrights / License
2. System Requirements
3. Step-by-step Installation
4. Furhter Installation Details
5. More about Bluetooth
6. More about Mac OS
7. Acknowledgements
8. Websites



1. COPYRIGHTS / LICENSE
-----------------------

The RWTH - Mindstorms NXT Toolbox is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

The RWTH - Mindstorms NXT Toolbox is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with the RWTH - Mindstorms NXT Toolbox. If not, see www.gnu.org/licenses.



2. SYSTEM REQUIREMENTS
----------------------

- Operating system: Windows, Linux, or Mac OS
- MATLAB Version 7.7 (R2008b) or higher
- LEGO® Mindstorms NXT building kit (e.g. Education Kit)
- LEGO® Mindstorms NXT firmware v1.26 or compatible (minimum)
  LEGO® Mindstorms NXT firmware v1.28 or better (recommended)
- Bluetooth:
  . Bluetooth 2.0 adapter recommended model by LEGO® 
    (e.g. AVM BlueFRITZ! USB) supporting the serial port profile (SPP)  
  . Windows: Device driver & Bluetooth stack which creates a COM-Port
  . Linux: Bluetooth-packages, especially bluez, as well as rfcomm
  . Mac OS: Working Bluetooth configuration
- USB: 
    Windows, Mac OS: Official MINDSTORMS NXT Driver "Fantom", v1.02 or better 
        Recommended: Official MINDSTORMS NXT Driver "Fantom", v1.1.3 or better 
    Linux: libusb 0.1 or compatible


	
*** Bluetooth:

The SPP (serial port profile) means that a virtual serial port is installed, which maps all data to the Bluetooth interface. You can verify this under Windows inside the Device Manager, where an additional COM-Port should be visible. Under Linux, the bluez Bluetooth stack is recommended. The package you need is usually called "bluetooth" (for Debian's apt-get). This package should already contain "bluez-utils", if not, install it as well.
In the toolbox folder \tools\LinuxConnection you'll find useful scripts and a special ReadMe file for Linux. For Bluetooth-connection, the script "btconnect" is recommended, followed by the NXT's name or its MAC adress. Make sure the user has access rights to devices called "rfcomm". Sometimes this means adding the current user to the group "dialout".
For Bluetooth under Linux the packages "dbns" and "dbns-x11" may also be required. The the command "bluetooth-applet --singleton" can be run from the console. After this, the script "btconnect" should work.

If you get the error message "Can't connect RFCOMM socket: Permission denied", try to remove the paired device inside the bluetooth-applet to force a new authorization.

The actual device name is usually called /dev/rfcomm0 or similar, it can also be something 
like /dev/tty.WL1-DevB.


*** USB:

For USB-connections under Windows, the official LEGO MINDSTORMS NXT Device Driver v1.02 or better has to be installed (also called "Fantom"). Recommended is the latest version
(currently 1.1.3). It can be downloaded here:
http://mindstorms.lego.com/en-us/support/files/Driver.aspx

On Linux systems, the open-source library libusb 0.1 has to be present. It can be retrieved using a packet manager, for example Debian's apt-get. If installing the package "libusb" alone does not work, also "libusb-dev" should be retrieved and installed, or it could be called "libusb0", or "libusb-0.1".
Again, please considere the LinuxReadme.txt file in /tools/LinuxConnection.

To troubleshoot problems with opening connections to the NXT, the toolbox command 
>> DebugMode on
can be used before trying to open a handle.



*** NBC / NXC Compiler and NeXTTool:

You will have to transfer a NXC program to your NXT to be able to use all the motor features. You can download the compiler, which can also transfer the program to your NXT, here: http://bricxcc.sourceforge.net/nbc/ . If you get compiler errors, you might have to try the latest beta version from a file called test_release.zip.
The program you have to download to the NXT is called MotorControl*.nxc and resides in the /tools/MotorControl directory of your toolbox. For Windows-Systems, we provide several batch-files. It's probably easiest to use TransferMotorControlBinaryToNXT.bat. Download NeXTTool from here: http://bricxcc.sourceforge.net/utilities.html. Just put NeXTTool.exe in this folder and execute the batch-file, while your NXT is turned on and connected via USB. Follow the on-screen instructions of the batch-file.

For Linux, a version of NeXTTool should somewhere be available, too.

Without MotorControl running on your NXT, the toolbox will issue a warning (which you can disable) everytime a connection is opened. Motor features for precise stopping (i.e. the whole class NXTMotor) will not work. Instead, you can only get the "old" motor behaviour from previous versions (encapsulated into a single function called DirectMotorCommand). For more details on this, see the section "Troubleshooting" inside the MATLAB toolbox help.



*** MINDSTORMS NXT Firmware:

You need a firmware of the NXT 2.0 generation for the MotorControl program to work. The following versions are ok:

 - Ver 1.26: This is the absolute minimum required. Very occasional freezes might be possible.
   No support for the NXT 2.0 Color sensor. Please consider upgrading your firmware!

 - Ver 1.28 or better: 
   Included with the NXT 2.0 retail toy set / NXT-G 2.0 software.
   It is recommended to use the very latest version (currently 1.29). Get it here:
   http://mindstorms.lego.com/en-us/support/files/Driver.aspx#Firmware

 - Ver 1.28 "enhanced" by John Hansen, or better: Those versions should be included
   with the latest releases of BricxCC on http://bricxcc.sourceforge.net/
   They should be compatible to the standard firmware and can be used with the toolbox.
   
   

3. STEP-BY-STEP INSTALLATION
----------------------------

*** EXTRACT FILES
  - Extract the archive anywhere you want, KEEPING DIRECTORY STRUCTURE
  - The destination folder should contain a directory called  RWTHMindstormsNXT

  
*** SET MATLAB PATH
  - In MATLAB, go to "File", "Set Path...", "Add Folder..."
  - Browse to the location you extracted to, and add the folder  RWTHMindstormsNXT
  - Also add the folder /tools (it is a sub-directory of RWTHMindstormsNXT)
    to the MATLAB path, as well as /demos
  - Press Save to remember settings for future MATLAB sessions

  
*** CHECK NXT FIRMWARE
  - Make sure you are using a LEGO NXT firmware version 1.26 or higher,
    otherwise you have to upgrade (see above for requirements). 
  - It is strongly recommended to use Firmware 1.28 or better! Get it here:
    http://mindstorms.lego.com/en-us/support/files/Driver.aspx#Firmware
  
  
*** TRANSFER MOTORCONTROL
  - Get NeXTTool.exe from http://bricxcc.sourceforge.net/utilities.html
    and save it to /tools/MotorControl (subfolder of the toolbox)
  - Use NeXTool to download MotorControl*.rxe (there should only be one)
    to your NXT. On Windows, call TransferMotorControlBinaryToNXT.bat 
  - Follow the on-screen instructions

  - If this doesn't work, you can try a different method / batch file.
    You need the NBC compiler for this step, get it here:
    http://bricxcc.sourceforge.net/nbc/, or try the latest version from
    test_release.zip from http://bricxcc.sourceforge.net/
  
  
*** CHECK OTHER SOFTWARE REQUIREMENTS
  - Windows, USB: NXT Fantom driver installed? Get it here:
             http://mindstorms.lego.com/en-us/support/files/Driver.aspx
  - Windows, Bluetooth: Drivers installed, NXT visible etc.,
                        COM-Port available?
						
  - Linux: See LinuxReadme.txt in /tools/MotorControl
  
  - Mac OS, USB: NXT Fantom driver installed? Get it here:
            http://mindstorms.lego.com/en-us/support/files/Driver.aspx
  
  
*** FIRST USB CONNECTION  
  - Inside MATLAB, execute  COM_OpenNXT
    The command should complete without an error!

	
*** FIRST BLUETOOTH CONNECTION  	
  - Inside MATLAB, execute  COM_MakeBTConfigFile
    Enter the serial COM-Port of your Bluetooth driver or
    the rfcomm device you're using
  - Or edit a bluetooth-example ini-file from the toolbox folder to suit your
    configuration. The most important thing is the correct serial port.
	
  - Establish a Bluetooth connection to your NXT using your adapter's
    driver software, or using the script btconnect we provide in
    /tools/LinuxConnection
  - Authenticate with the NXT (a passkey request should appear)
  - The BT-icon on the top left of the NXT screen should turn 
    from B< to B<>, otherwise it won't work!
    . If this doesn't work, use the NXT menu to navigate to Bluetooth,
      Search, select your computer, connect. Again, you need the 
      symbol B<> on your NXT screen.	
    . If this still doesn't work, your Bluetooth hardware might be
      incompatible, or maybe you need a different driver! Check
      http://www.mindstorms.rwth-aachen.de/trac/wiki/BluetoothAdapter
	  
  - Disconnect the USB cable from the NXT.
  
  - You can now type the following commands in MATLAB,
    given that you created a file called bluetooth.ini:
	 COM_CloseNXT('all')
	 COM_OpenNXT('bluetooth.ini')
    The commands should complete without an error!
	
	
*** OPTIMIZE PERFORMANCE
  - Only necessary for MATLAB versions prior to
    Release 2010a (i.e. older versions than 7.10)
  - Inside MATLAB, type
    OptimizeToolboxPerformance
  - Confirm the dialog with yes,
    the script should complete without an error!

	
*** TRY THE EXAMPLES
  - Look inside the folder /demos of your toolbox directory
  - Enjoy the examples	
	
Congratulations	!!!
  
To get more help, see here: http://www.mindstorms.rwth-aachen.de/trac/wiki/FAQ



4. FURTHER INSTALLATION DETAILS
-------------------------------

The RWTH - Mindstorms NXT Toolbox is a collection of MATLAB-functions (so called m-files) and documentation / help files (mostly HTML). You have received these files in a compressed archive that just needs to be extracted to a directory of your choice. This folder can even be on an external hard disk, USB stick or network drive. However it is recommended to use a folder on a normal hard disk drive for performance reasons.
So just uncompress the archive and remember the folder you extracted it to.
Make sure that the internal sub-directory structure is kept! Also it is important that all files are located in a sub-folder called "RWTHMindstormsNXT" (without the ") for identification purposes.

Now inside MATLAB, go to the menu "File" and choose "Set Path...". Inside the new window, press "Add Folder...", and browse to the location where you extracted the files from the archive to in the previous step. Now select the folder "RWTHMindstormsNXT" and confirm. Repeat this step, and add the folder called "tools", which is a sub-folder of the previously added "RWTHMindstormsNXT"-directory. When done, press "Save" to remember these settings for future MATLAB sessions.

After adding these 2 folders to the MATLAB search path, the installation is complete. To verify the installation, you can type the following line

  info = ver('RWTHMindstormsNXT')

inside the MATLAB command window. Also the command COM_CloseNXT('all') should work and complete without an error.


*** Performance issues

On slower machines, CPU load during programs using the toolbox can be up to 100% (especially when constantly polling sensor or motor data via USB). To optimize the toolbox, a utility called OptimizeToolboxPerformance is provided, which can be called from the MATLAB command window. It will try to replace some frequently used  helper functions with binary versions from your MATLAB installation.
The tool will guide you through the process. 

Performance improvements up to a factor of 3 have been observed!



5. MORE ABOUT BLUETOOTH
-----------------------

Before you can begin working with Bluetooth connections, you have to create a settings file that contains information about your Bluetooth adapter and serial port.
Either you can use the toolbox-command COM_MakeBTConfigFile inside the command window. A dialog window lets you enter the required parameters. The other way is to edit the example-files called "bluetooth-example-windows.ini" or "bluetooth-example-linux.ini", that are provided in the toolbox root folder.

You can leave the default values for the beginning, the only thing you will have to enter is the COM-Port. The Bluetooth SPP (serial port profile) maps a virtual COM-Port to your adapter. Find out which port this is (under Windows you can use the Device Manager) and enter it in the dialog window (example: COM4). The other parameters are explained in the documentation. Advanced users should refer to the first chapter "Bluetooth connections and serial handles" of the section "Functions - Overview".

If there is more than one additional Bluetooth COM-Port, this is most likely caused by the adapter's driver software. Most of the time it is the lowest available COM-Port (above the classic "real ports"). The only way to be sure is to try which ports are working. Sometimes there are certain ports that only work for sending OR receiving. The toolbox however needs a bidirectional port.)

Linux users should use the bluez Bluetooth stack. The serial port will then be called "/dev/rfcomm0" (without ") or similar. This is the parameter that has to be added instead of "COM3" for example. The sample ini-file for Linux does not contain all settings as they are not needed here.

Once the correct ini-file is created, it can be put inside the toolbox root path or anywhere inside the MATLAB search path for better convenience.

To establish the physical connection to your NXT, the script "btconnect" can be used. It is available on the project website. If you get the error message "Can't connect RFCOMM socket: Permission denied", try to remove the paired device inside the bluetooth-applet to force a new authorization. See also section 2 (System Requirements) of this document and follow the steps closely to ensure all needed packages are installed. Even more info is provided in the folder /tools/LinuxConnection, use the file LinuxReadme.txt.

You can now try the demos (which require a correct configuration file called "bluetooth.ini") or start opening connections using the toolbox command COM_OpenNXT.

Note that before this works, you have to establish a physical connection to your NXT. Depending on your Bluetooth adapter's driver software, this can be different. Once successful, the NXT and driver software will prompt you for a passkey. The authentification is then complete, and the toolbox should work properly.



6. MORE ABOUT MAC OS
--------------------

Mac OS uses the Fantom driver for USB connections, just as on Windows. For Bluetooth, the code of the Linux version is used, so theoretically, the Linux instructions should work for you. Another working step-by-step example to determine the serial port (name/path of the COM port) follows:

- Turn on Bluetooth on the computer, power up the NXT
- Select "Set up bluetooth device"
- Select "Any device" in the window Select Device Type
- Selected the name of your NXT
- Entered the passkey (usually 1234)
- Confirm the passkey on the NXT.
- Open System Preferences and select Bluetooth,
  and click on the name of your NXT.
- Next to the + - options, there's a gear.
- Select edit Serial Ports
- At the bottom, it shows a path. 
- Use this path for the serial port property of the bluetooth.ini file
  or inside the COM_MakeBTConfigFile utiltiy.
  (it could look like this: /dev/tty.WL1-DevB )



7. ACKNOWLEDGEMENTS
-------------------

See the text-file AUTHORS which comes with this distribution.



8. WEBSITES
-----------

*  Official project homepage
-> http://www.mindstorms.rwth-aachen.de


*  Institute of Imaging & Computer Vision, RWTH Aachen University
   (Project foundation, initial development and stable toolbox version maintenance)
-> http://www.lfb.rwth-aachen.de/en


*  RWTH Aachen University Student Project - MATLAB meets LEGO Mindstorms
-> http://www.mindstorms.lfb.rwth-aachen.de


*  Official LEGO MINDSTORMS NXT homepage
-> http://www.mindstorms.lego.com


*  The MathWorks, Inc. (MATLAB product updates and much more)
-> http://www.mathworks.com


*  RWTH Aachen University
-> http://www.rwth-aachen.de