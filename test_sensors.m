%% SENSOR DIAGNOSTIC SCRIPT
% Run this to check if your sensors are working properly

fprintf('=== SENSOR DIAGNOSTIC TEST ===\n\n');

% Make sure brick is connected
if ~exist('brick', 'var')
    fprintf('Connecting to brick...\n');
    try
        clear brick
        fclose(instrfind);
        delete(instrfind);
    catch
    end
    brick = ConnectBrick('BALL');
    fprintf('Connected!\n\n');
end

brick.beep();

fprintf('Testing Ultrasonic Sensor on Port 2...\n');
fprintf('Point sensor at different objects and distances\n');
fprintf('Press Ctrl+C to stop\n\n');

fprintf('Iteration | Distance (cm) | Status\n');
fprintf('----------|---------------|------------------\n');

for i = 1:100
    distance = brick.UltrasonicDist(2);

    % Determine status
    if distance < 10
        status = 'TOO CLOSE';
    elseif distance < 25
        status = 'GOOD RANGE';
    elseif distance < 50
        status = 'FAR';
    else
        status = 'NO WALL/ERROR';
    end

    fprintf('%9d | %13.1f | %s\n', i, distance, status);
    pause(0.3);
end

fprintf('\n=== TEST COMPLETE ===\n');
