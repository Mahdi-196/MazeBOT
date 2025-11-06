%% QUICK DIRECTION TEST
% Tests if motors go forward or backward

fprintf('=== DIRECTION TEST ===\n\n');

if ~exist('brick', 'var')
    brick = ConnectBrick('BALL');
end

brick.beep();

fprintf('This will test if FORWARD actually goes forward\n');
fprintf('Watch your robot carefully!\n\n');

input('Press Enter to test...', 's');

fprintf('Moving with POSITIVE speed (should go FORWARD)...\n');
brick.MoveMotor('AB', 50);
pause(2);
brick.StopMotor('AB', 'Brake');

pause(1);

fprintf('\nDid the robot go FORWARD or BACKWARD?\n');
response = input('Type F for forward, B for backward: ', 's');

if upper(response) == 'B'
    fprintf('\n*** MOTORS ARE REVERSED! ***\n');
    fprintf('I will create a fixed version now.\n\n');
else
    fprintf('\nMotors are correct!\n');
end

brick.beep();
