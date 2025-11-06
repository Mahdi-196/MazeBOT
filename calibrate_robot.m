%% ROBOT CALIBRATION SCRIPT
% Use this to test and tune your robot before the maze
% This will help you find the right parameters

%% CONNECT
fprintf('========================================\n');
fprintf('ROBOT CALIBRATION TOOL\n');
fprintf('========================================\n');

try
    clear brick
    fclose(instrfind);
    delete(instrfind);
catch
end

brick = ConnectBrick('BALL');
fprintf('Connected to robot!\n\n');
brick.beep();

%% TEST MENU
while true
    fprintf('\n--- CALIBRATION MENU ---\n');
    fprintf('1. Test Motors (Forward/Backward)\n');
    fprintf('2. Test Turn (90 degree right)\n');
    fprintf('3. Test Turn (90 degree left)\n');
    fprintf('4. Read Ultrasonic Sensor (continuous)\n');
    fprintf('5. Test Wall Following (10 seconds)\n');
    fprintf('6. Exit\n');
    fprintf('------------------------\n');

    choice = input('Select option (1-6): ', 's');

    switch choice
        case '1'
            % TEST FORWARD/BACKWARD
            fprintf('\nMoving FORWARD for 2 seconds...\n');
            brick.MoveMotor('BC', 40);
            pause(2);
            brick.StopMotor('BC', 'Brake');

            pause(1);

            fprintf('Moving BACKWARD for 2 seconds...\n');
            brick.MoveMotor('BC', -40);
            pause(2);
            brick.StopMotor('BC', 'Brake');

            fprintf('✓ Motor test complete!\n');

        case '2'
            % TEST RIGHT TURN
            fprintf('\nTurning RIGHT...\n');
            brick.MoveMotor('B', 30);   % Left forward
            brick.MoveMotor('C', -30);  % Right backward
            pause(0.6);  % Adjust this time for 90 degrees
            brick.StopMotor('BC', 'Brake');

            fprintf('✓ Turn complete! Adjust TURN_TIME if not 90 degrees\n');

        case '3'
            % TEST LEFT TURN
            fprintf('\nTurning LEFT...\n');
            brick.MoveMotor('B', -30);  % Left backward
            brick.MoveMotor('C', 30);   % Right forward
            pause(0.6);  % Adjust this time for 90 degrees
            brick.StopMotor('BC', 'Brake');

            fprintf('✓ Turn complete! Adjust TURN_TIME if not 90 degrees\n');

        case '4'
            % READ SENSOR CONTINUOUSLY
            fprintf('\nReading Ultrasonic Sensor (Press Ctrl+C to stop)...\n');
            fprintf('Point sensor at different distances to test\n\n');

            try
                for i = 1:100
                    distance = brick.UltrasonicDist(2);
                    fprintf('Distance: %6.1f cm\r', distance);
                    pause(0.2);
                end
            catch
                fprintf('\nSensor reading stopped.\n');
            end

        case '5'
            % TEST WALL FOLLOWING
            fprintf('\nTesting wall following for 10 seconds...\n');
            fprintf('Place robot parallel to a wall on the RIGHT side\n');
            input('Press Enter when ready...', 's');

            DESIRED_DIST = 15;
            SPEED = 30;

            start_time = tic;
            while toc(start_time) < 10
                distance = brick.UltrasonicDist(2);

                if distance < 10
                    % Too close - turn left
                    brick.MoveMotor('B', SPEED * 0.5);
                    brick.MoveMotor('C', SPEED);
                elseif distance > 20
                    % Too far - turn right
                    brick.MoveMotor('B', SPEED);
                    brick.MoveMotor('C', SPEED * 0.5);
                else
                    % Good distance - straight
                    brick.MoveMotor('BC', SPEED);
                end

                fprintf('Distance: %.1f cm\r', distance);
                pause(0.1);
            end

            brick.StopMotor('BC', 'Brake');
            fprintf('\n✓ Wall following test complete!\n');

        case '6'
            % EXIT
            fprintf('\nExiting calibration...\n');
            brick.StopMotor('BC', 'Coast');
            brick.beep();
            break;

        otherwise
            fprintf('Invalid choice! Please select 1-6.\n');
    end
end

fprintf('\n========================================\n');
fprintf('Calibration Complete!\n');
fprintf('========================================\n');
