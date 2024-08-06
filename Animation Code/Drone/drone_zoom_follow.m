%% Created By Daniel Maldonado Naranjo 2024

function drone_zoom_follow(positions, angles, param)
    l = param.l; % Length of the drone axles and basis for other dimensions
    
    % Open a figure for the zoomed-in view
    figZoom = figure('Name', 'Drone Zoomed-In View');
    set(figZoom, 'units', 'normalized', 'outerposition', [0.5 0 0.5 1]); % Adjust window size and position as needed
    
    % Set up video writer
    videoFileName = [param.plotTitle 'zoomed_drone_animation.avi'];
    videoWriter = VideoWriter(videoFileName, 'Uncompressed AVI');
    videoWriter.FrameRate = 10; % Adjust frame rate as needed
    open(videoWriter);

    % Initialize variables for GIF creation
    gifFileName = [param.plotTitle 'zoomed_drone_animation.gif'];
    gifDelayTime = 0.1; % Delay time between frames in the GIF


    % Initialize axles for drone representation
    axle_x = [-l/2 0 0; l/2 0 0];
    axle_y = [0 -l/2 0; 0 l/2 0];

    % Define properties of the propellers
    r = 0.1*l; % Radius of propellers
    ang = linspace(0, 2*pi);
    x_circle = r*cos(ang);
    y_circle = r*sin(ang);
    z_circle = zeros(1, length(ang));
    propeller = [x_circle', y_circle', z_circle'];

    % Initialize sizes of matrices and trail effect parameters
    [p1, ~] = size(propeller);
    [p2, ~] = size(axle_x);
    [mm, nn] = size(angles);
    trailLength = param.trailLength; % Length of the trail
    trailPositions = zeros(trailLength, 3); % Store previous positions for the trail
    
    % Plot the Start and End
    plot3(param.start(1), param.start(2), z(1), 'Marker', 'o', 'LineStyle', 'none', 'Color', 'k')
    plot3(param.goal(1), param.goal(2), z(1), 'Marker', 'x', 'LineStyle', 'none', 'Color', 'k')
      

    % Loop over all frames
    for ii = 1:10:mm
        % Extract the current position and orientation of the drone
        x = positions(ii, 1);
        y = positions(ii, 2);
        z = positions(ii, 3);
        phi = angles(ii, 1);
        theta = angles(ii, 2);
        psi = angles(ii, 3);
        
        % Calculate rotation matrix
        R = get_rotation(phi, theta, psi);
        
        % Transform drone components according to current orientation and position
        new_axle_x = transform_object(axle_x, R, [x y z]);
        new_axle_y = transform_object(axle_y, R, [x y z]);
        new_propeller1 = transform_object(propeller, R, new_axle_x(1,:));
        new_propeller2 = transform_object(propeller, R, new_axle_y(1,:));
        new_propeller3 = transform_object(propeller, R, new_axle_x(2,:));
        new_propeller4 = transform_object(propeller, R, new_axle_y(2,:));
        
        % Plot the transformed components
        clf; % Clear current figure window to update it with new positions

        plot_components(new_axle_x, new_axle_y, new_propeller1, new_propeller2, new_propeller3, new_propeller4);
        
        % Update and plot the trail
        trailPositions = circshift(trailPositions, 1);
        trailPositions(1, :) = [x, y, z];
        plot_trail(trailPositions, ii, trailLength);

        % Adjust figure properties
        zoomFactor = param.zoom; % Control how "zoomed in" the view is
        xlim([x - l*zoomFactor, x + l*zoomFactor]);
        ylim([y - l*zoomFactor, y + l*zoomFactor]);
        zlim([z - l*zoomFactor, z + l*zoomFactor]);
        daspect([1 1 1])
        grid on;
        view(3); % Adjust view angle as needed
        
        % Calculate the time in seconds (assuming 10 frames per second)
        timeInSeconds = ii * (param.Tf/mm);

        % Set legend and titles (adjust according to your original legend specifications)
        xlabel('Position x', 'FontSize', 20, 'Interpreter','latex');
        ylabel('Position y', 'FontSize', 20, 'Interpreter','latex');
        zlabel('Position z', 'FontSize', 20, 'Interpreter','latex');
        
        title([param.plotTitle ' - Drone Zoomed View - Time: ' num2str(timeInSeconds, '%.1f') 's'], 'Interpreter','latex','FontSize', 24);
        legend(param.lgd,'Interpreter','latex','Location', 'southeast', 'FontSize', 24);
        set(gca, 'FontSize', 24); % Set font size for axis labels and tick marks    

        if ii == 1
            pause
        end
        
        % Capture frame for video and GIF
        frame = getframe(gcf);
        writeVideo(videoWriter, frame);

        % Write frame to GIF
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
        if ii == 1
            imwrite(imind, cm, gifFileName, 'gif', 'Loopcount', inf, 'DelayTime', gifDelayTime);
        else
            imwrite(imind, cm, gifFileName, 'gif', 'WriteMode', 'append', 'DelayTime', gifDelayTime);
        end

        % Pause and clear figure for next frame
        pause(0.01);
        if (ii ~= mm)
            clf;
        end
    end

    % Close the video file
    close(videoWriter);
end

function new_object = transform_object(object, R, translation)
    % Applies rotation and translation to an object
    new_object = (R * object')' + translation;
end

function plot_components(axle_x, axle_y, prop1, prop2, prop3, prop4)
    % Plot axles and propellers with different colors
    line(axle_x(:, 1), axle_x(:, 2), axle_x(:, 3), 'LineWidth', 2, 'Color', 'blue');  hold on;
    line(axle_y(:, 1), axle_y(:, 2), axle_y(:, 3), 'LineWidth', 2, 'Color', 'red');
    patch(prop1(:, 1), prop1(:, 2), prop1(:, 3), 'k', 'DisplayName', ''); 
    patch(prop2(:, 1), prop2(:, 2), prop2(:, 3), 'k', 'DisplayName', ''); 
    patch(prop3(:, 1), prop3(:, 2), prop3(:, 3), 'k', 'DisplayName', ''); 
    patch(prop4(:, 1), prop4(:, 2), prop4(:, 3), 'k', 'DisplayName', ''); 
end


function plot_trail(trailPositions, currentStep, trailLength)
    % Plot the trail with fading effect
    numPointsToPlot = min(currentStep, trailLength);
    for jj = 1:numPointsToPlot
        plot3(trailPositions(jj, 1), trailPositions(jj, 2), trailPositions(jj, 3), ...
              '.', 'Color', [0, 0, 1, max(0, 1 - jj/trailLength)]);
    end
end