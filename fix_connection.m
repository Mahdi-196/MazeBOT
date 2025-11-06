% Fix and Test EV3 Bluetooth Connection
% Copy and paste this entire script into MATLAB

clear all
close all
clc

% Add EV3 directory to path
addpath('/Users/mahdighaleb/Desktop/EV3');

% Step 1: Check available Bluetooth devices
disp('========================================');
disp('Step 1: Checking Bluetooth devices...');
disp('========================================');
bluetoothlist

% Step 2: Clean up old connections
disp(' ');
disp('Step 2: Cleaning up old connections...');
try
    fclose(instrfind);
    delete(instrfind);
catch
end

% Step 3: Try to connect (will try channels 1 and 2)
disp(' ');
disp('Step 3: Attempting to connect to BALL...');
disp('========================================');

brick = [];
connected = false;

% Try channel 1 first
try
    disp('Trying channel 1...');
    brick = Brick('ioType','instrbt','btDevice','BALL','btChannel',1);
    brick.beep();
    disp('✅ SUCCESS! Connected on channel 1');
    connected = true;
catch
    disp('❌ Channel 1 failed');
end

% If channel 1 failed, try channel 2
if ~connected
    try
        disp('Trying channel 2...');
        brick = Brick('ioType','instrbt','btDevice','BALL','btChannel',2);
        brick.beep();
        disp('✅ SUCCESS! Connected on channel 2');
        connected = true;
    catch
        disp('❌ Channel 2 failed');
    end
end

if connected
    disp(' ');
    disp('========================================');
    disp('✅ EV3 Connected Successfully!');
    disp('========================================');
    disp('You can now run: MotorTest');
else
    disp(' ');
    disp('========================================');
    disp('❌ Connection Failed');
    disp('========================================');
    disp('Please check:');
    disp('1. BALL is turned on');
    disp('2. BALL is paired in System Settings > Bluetooth');
    disp('3. BALL Bluetooth is visible/enabled on the brick');
end
