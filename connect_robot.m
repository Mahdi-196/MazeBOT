% Connect to EV3 Robot (BALL)
% This script connects to your EV3 brick via Bluetooth

% Add EV3 directory to path
addpath('/Users/mahdighaleb/Desktop/EV3');

% Clean up any existing connections
try
    clear brick
    fclose(instrfind);
    delete(instrfind);
catch
end

% Connect to EV3 brick named 'BALL'
brick = ConnectBrick('BALL');
disp('✅ Connected to EV3 (BALL)');

% Test connection with a beep
brick.beep();
disp('✅ Connection test successful - you should hear a beep!');
