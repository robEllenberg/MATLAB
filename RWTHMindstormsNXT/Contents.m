% RWTH - Mindstorms NXT Toolbox
% Version 4.07 08-Feb-2012
% Files
%   CalibrateColor             - Enables calibration mode of the HiTechnic color sensor V1
%   CalibrateCompass           - Enables calibration mode of the HiTechnic compass sensor
%   CalibrateEOPD              - Calibrates the HiTechnic EOPD sensor (measures/sets calibration matrix)
%   CalibrateGyro              - Calibrates the HiTechnic Gyro sensor (measures/sets an offset while in rest)
%   checkStatusByte            - Interpretes the status byte of a return package, returns error message
%   CloseSensor                - Closes a sensor port (e.g. turns off active light of the light sensor)
%   COM_CloseNXT               - Closes and deletes a specific NXT handle, or clears all existing handles
%   COM_CollectPacket          - Reads data from a USB or serial/Bluetooth port, retrieves exactly one packet
%   COM_CreatePacket           - Generates a valid Bluetooth packet ready for transmission (i.e. sets length)
%   COM_GetDefaultNXT          - Returns the global default NXT handle if it was previously set
%   COM_MakeBTConfigFile       - Creates a Bluetooth configuration file (needed for Bluetooth connections)
%   COM_OpenNXT                - Opens USB or Bluetooth connection to NXT device and returns a handle
%   COM_OpenNXTEx              - Opens USB or Bluetooth connection to NXT; advanced version, more options
%   COM_ReadI2C                - Requests and reads sensor data via I2C from a correctly configured digital sensor.
%   COM_SendPacket             - Sends a communication protocol packet (byte-array) via a USB or Bluetooth
%   COM_SetDefaultNXT          - Sets global default NXT handle (will be used by other functions as default)
%   DebugMode                  - Gets or sets debug state (i.e. if textOut prints messages to the command window)
%   DirectMotorCommand         - Sends a direct command to the specified motor
%   GetAccelerator             - Reads the current value of the HiTechnic acceleration sensor
%   GetColor                   - Reads the current value of the HiTechnic Color V1 or V2 sensor
%   GetCompass                 - Reads the current value of the HiTechnic compass sensor
%   GetEOPD                    - Reads the current value of the HiTechnic EOPD sensor
%   GetGyro                    - Reads the current value of the HiTechnic Gyro sensor
%   GetInfrared                - Reads the current value of the Hitechnic infrared sensor (infrared seeker)
%   GetLight                   - Reads the current value of the NXT light sensor
%   GetNXT2Color               - Reads the current value of the color sensor from the NXT 2.0 set
%   GetRFID                    - Reads the transponder ID detected by the Codatex RFID sensor
%   GetSound                   - Reads the current value of the NXT sound sensor
%   GetSwitch                  - Reads the current value of the NXT switch / touch sensor
%   GetUltrasonic              - Reads the current value of the NXT ultrasonic sensor
%   MAP_GetCommModule          - Reads the IO map of the communication module
%   MAP_GetInputModule         - Reads the IO map of the input module
%   MAP_GetOutputModule        - Reads the IO map of the output module
%   MAP_GetSoundModule         - Reads the IO map of the sound module
%   MAP_GetUIModule            - Reads the IO map of the user interface module
%   MAP_SetOutputModule        - Writes the IO map to the output module
%   MOTOR_A                    - Symbolic constant MOTOR_A (returns 0)
%   MOTOR_B                    - Symbolic constant MOTOR_B (returns 1)
%   MOTOR_C                    - Symbolic constant MOTOR_C (returns 2)
%   NXC_GetSensorMotorData     - Retrieves selected data from all analog sensors and all motors in a single packet
%   NXC_MotorControl           - Sends advanced motor-command to the NXC-program MotorControl on the NXT brick
%   NXC_ResetErrorCorrection   - Sends reset error correction command to the NXC-program MotorControl on the NXT
%   NXT_GetBatteryLevel        - Returns the current battery level in milli volts
%   NXT_GetCurrentProgramName  - Returns the name of the current running program
%   NXT_GetFirmwareVersion     - Returns the protocol and firmware version of the NXT
%   NXT_GetInputValues         - Executes a complete sensor reading (requests and retrieves input values)
%   NXT_GetOutputState         - Requests and retrieves an output motor state reading
%   NXT_LSGetStatus            - Gets the number of available bytes for digital low speed sensors (I2C)
%   NXT_LSRead                 - Reads data from a digital low speed sensor port (I2C)
%   NXT_LSWrite                - Writes given data to a digital low speed sensor port (I2C)
%   NXT_MessageRead            - Retrieves a "NXT-to-NXT message" from the specified inbox
%   NXT_MessageWrite           - Writes a "NXT-to-NXT message" to the NXT's incoming BT mailbox queue
%   NXT_PlaySoundFile          - Plays the given sound file on the NXT Brick
%   NXT_PlayTone               - Plays a tone with the given frequency and duration 
%   NXT_ReadIOMap              - Reads the IO map of the given module ID
%   NXT_ResetInputScaledValue  - Resets the sensor's ScaledVal back to 0 (depends on current sensor mode)
%   NXT_ResetMotorPosition     - Resets NXT internal counter for specified motor, relative or absolute counter
%   NXT_SendKeepAlive          - Sends a KeepAlive packet. Optional: requests sleep time limit.
%   NXT_SetBrickName           - Sets a new name for the NXT Brick (connected to the specified handle)
%   NXT_SetInputMode           - Sets a sensor mode, configures and initializes a sensor to be read out
%   NXT_SetOutputState         - Sends previously specified settings to current active motor.
%   NXT_StartProgram           - Starts the given program on the NXT Brick
%   NXT_StopProgram            - Stops the currently running program on the NXT Brick
%   NXT_StopSoundPlayback      - Stops the current sound playback
%   NXT_WriteIOMap             - Writes the IO map to the given module ID
%   OpenAccelerator            - Initializes the HiTechnic acceleration sensor, sets correct sensor mode
%   OpenColor                  - Initializes the HiTechnic color V1 or V2 sensor, sets correct sensor mode 
%   OpenCompass                - Initializes the HiTechnic magnetic compass sensor, sets correct sensor mode 
%   OpenEOPD                   - Initializes the HiTechnic EOPD sensor, sets correct sensor mode
%   OpenGyro                   - Initializes the HiTechnic Gyroscopic sensor, sets correct sensor mode
%   OpenInfrared               - Initializes the HiTechnic infrared seeker sensor, sets correct sensor mode
%   OpenLight                  - Initializes the NXT light sensor, sets correct sensor mode
%   OpenNXT2Color              - Initializes the LEGO color sensor from the NXT 2.0 set, sets correct sensor mode 
%   OpenRFID                   - Initializes the Codatex RFID sensor, sets correct sensor mode
%   OpenSound                  - Initializes the NXT sound sensor, sets correct sensor mode
%   OpenSwitch                 - Initializes the NXT touch sensor, sets correct sensor mode
%   OpenUltrasonic             - Initializes the NXT ultrasonic sensor, sets correct sensor mode
%   OptimizeToolboxPerformance - Copies binary versions of typecastc to toolbox for better performance 
%   readFromIniFile            - Reads parameters from a configuration file (usually *.ini)
%   SENSOR_1                   - Symbolic constant SENSOR_1 (returns 0)
%   SENSOR_2                   - Symbolic constant SENSOR_2 (returns 1)
%   SENSOR_3                   - Symbolic constant SENSOR_3 (returns 2)
%   SENSOR_4                   - Symbolic constant SENSOR_4 (returns 3)
%   StopMotor                  - Stops / brakes specified motor. (Synchronisation will be lost after this)
%   SwitchLamp                 - Switches the LEGO lamp on or off (has to be connected to a motor port)
%   textOut                    - Wrapper for fprintf() which can optionally write screen output to a logfile
%   USGetSnapshotResults       - Retrieves up to eight echos (distances) stored inside the US sensor
%   USMakeSnapshot             - Causes the ultrasonic sensor to send one snapshot ("ping") and record the echos
