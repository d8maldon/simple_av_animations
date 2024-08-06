%% Created By Daniel Maldonado Naranjo 2024
clc; clear all; close all; 

%% Define Parameters 
params.R = 5;       % 
params.x0 = 0;      % Initial X
params.y0 = 0;      % Initial Y
params.z0 = 1;      % Initial Z
params.speed = 1;   % Speed of Drone

params.total_time = 10;
params.dt = 0.01;

generate_quadrotor_trajectory('circle', params);
generate_quadrotor_trajectory('figure8', params);
generate_quadrotor_trajectory('sinusoid', params);


%% Function Which Generate Trajectories For Example Purposes!
function generate_quadrotor_trajectory(shape, params)
    % Parameters
    R = params.R; % Radius for circle and figure 8
    x0 = params.x0; % Center x-coordinate
    y0 = params.y0; % Center y-coordinate
    z0 = params.z0; % Center z-coordinate
    speed = params.speed; % Speed of the quadrotor (m/s)
    total_time = params.total_time; % Total simulation time (seconds)
    dt = params.dt; % Time step (seconds)
    
    % Time vector
    t = 0:dt:total_time;
    
    % Initialize position and orientation vectors
    x = [];
    y = [];
    z = [];
    yaw = [];
    pitch = zeros(size(t));
    roll = zeros(size(t));
    
    switch shape
        case 'circle'
            theta = 2 * pi * (t / total_time);
            x = x0 + R * cos(theta);
            y = y0 + R * sin(theta);
            z = z0 * ones(size(t));
            yaw = theta + pi/2; % Rotate by 90 degrees to align forward direction
            
        case 'figure8'
            theta = 2 * pi * (t / total_time);
            x = x0 + R * sin(theta);
            y = y0 + R * sin(2 * theta);
            z = z0 * ones(size(t));
            yaw = atan2(2 * cos(2 * theta), cos(theta)) + pi/2;
            
        case 'square'
            side_length = 2 * R;
            num_sides = 4;
            side_time = total_time / num_sides;
            for i = 1:num_sides
                segment_time = t(t >= (i-1) * side_time & t < i * side_time) - (i-1) * side_time;
                segment_length = length(segment_time);
                if mod(i, 4) == 1
                    x = [x, x0 + R * ones(1, segment_length)];
                    y = [y, y0 + linspace(0, side_length, segment_length)];
                elseif mod(i, 4) == 2
                    x = [x, x0 + linspace(R, -R, segment_length)];
                    y = [y, y0 + side_length * ones(1, segment_length)];
                elseif mod(i, 4) == 3
                    x = [x, x0 - R * ones(1, segment_length)];
                    y = [y, y0 + linspace(side_length, 0, segment_length)];
                else
                    x = [x, x0 + linspace(-R, R, segment_length)];
                    y = [y, y0];
                end
                z = [z, z0 * ones(1, segment_length)];
                % Compute yaw for each segment
                if i == 1
                    yaw_segment = atan2(diff([y0, y0 + side_length]), diff([x0, x0]));
                elseif i == 2
                    yaw_segment = atan2(diff([y0 + side_length, y0 + side_length]), diff([x0 + R, x0 - R]));
                elseif i == 3
                    yaw_segment = atan2(diff([y0 + side_length, y0]), diff([x0 - R, x0 - R]));
                else
                    yaw_segment = atan2(diff([y0, y0]), diff([x0 - R, x0 + R]));
                end
                yaw = [yaw, yaw_segment * ones(1, segment_length)];
            end
            
        case 'sinusoid'
            amplitude = R; % Amplitude of the sine wave
            frequency = 1; % Frequency of the sine wave (Hz)
            x = x0 + speed * t;
            y = y0 + amplitude * sin(2 * pi * frequency * t);
            z = z0 * ones(size(t));
            yaw = atan2(2 * pi * frequency * amplitude * cos(2 * pi * frequency * t), speed);
    end
    
    % Combine position and orientation data
    data = [x' y' z' roll' pitch' yaw'];
    
    % Plot the trajectory
    figure;
    plot3(x, y, z, 'b-', 'LineWidth', 2);
    hold on;
    plot3(x(1), y(1), z(1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    title(['6-DOF Quadrotor Trajectory: ', shape]);
    grid on;
    axis equal;
    
    % Save data to a file
    save(['quadrotor_', shape, '_trajectory.mat'], 'data');
    
    disp(['Position and angle data for ', shape, ' generated and saved to quadrotor_', shape, '_trajectory.mat']);
end