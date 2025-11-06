function brick = ConnectBrickBT(brickName)
    % ConnectBrickBT - Connect to EV3 via Bluetooth using newer MATLAB API
    % Usage: brick = ConnectBrickBT('BALL')

    fprintf('Attempting to connect to %s via Bluetooth...\n', brickName);

    % Try to create connection using newer bluetooth API
    try
        % Create bluetooth connection object
        bt = bluetooth(brickName, 1);
        fprintf('Bluetooth object created successfully\n');

        % Now we need to wrap this in a way the Brick expects
        % This is a workaround for the deprecated instrBrickIO
        brick = struct();
        brick.conn = bt;
        brick.ioType = 'bt';
        brick.debug = 0;

        fprintf('Connected successfully!\n');
    catch err
        fprintf('Connection failed: %s\n', err.message);
        fprintf('\nTroubleshooting steps:\n');
        fprintf('1. Make sure BALL is turned on\n');
        fprintf('2. Make sure BALL is paired in System Settings > Bluetooth\n');
        fprintf('3. Try the USB connection method instead\n');
        error('Could not connect to %s', brickName);
    end
end
