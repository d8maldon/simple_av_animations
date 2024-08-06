%% Created By Daniel Maldonado Naranjo 2024

function animate(positions, angles, param)

    l = param.l; 
    % Open figure in full screen
    fig = figure;
    set(fig, 'units', 'normalized', 'outerposition', [0 0 1 1]);

    % Set up video writer
    videoFileName = [param.plotTitle 'drone_animation.avi'];
    videoWriter = VideoWriter(videoFileName, 'Uncompressed AVI');
    videoWriter.FrameRate = 10; % Adjust frame rate as needed
    open(videoWriter);

    % Initialize variables for GIF creation
    gifFileName = [param.plotTitle 'drone_animation.gif'];
    gifDelayTime = 0.1; % Delay time between frames in the GIF

    % Initialize axles for drone representation
    axle_x = [-l/2 0 0; l/2 0 0];
    axle_y = [0 -l/2 0; 0 l/2 0];

    % Define properties of the propellers
    r = 0.25*l; % Radius of propellers
    ang = linspace(0, 2*pi);
    x_circle = r*cos(ang);
    y_circle = r*sin(ang);
    z_circle = zeros(1, length(ang));
    propeller = [x_circle', y_circle', z_circle'];

    % Initialize sizes of matrices and trail effect parameters
    [p1, ~] = size(propeller);
    [p2, ~] = size(axle_x);
    [mm, nn] = size(angles);
    trailLength = 150; % Length of the trail
    trailPositions = zeros(trailLength, 3); % Store previous positions for the trail

    % Main loop to animate the drone
    for ii = 1:10:mm

        % Extract position and angles for current frame
        x = positions(ii, 1);
        y = positions(ii, 2);
        z = positions(ii, 3);
        phi = angles(ii, 1);
        theta = angles(ii, 2);
        psi = angles(ii, 3);

        % Compute rotation matrix
        R = get_rotation(phi, theta, psi);

        % Rotate and translate axles and propellers
        new_axle_x = transform_object(axle_x, R, [x y z]);
        new_axle_y = transform_object(axle_y, R, [x y z]);
        new_propeller1 = transform_object(propeller, R, new_axle_x(1,:));
        new_propeller2 = transform_object(propeller, R, new_axle_y(1,:));
        new_propeller3 = transform_object(propeller, R, new_axle_x(2,:));
        new_propeller4 = transform_object(propeller, R, new_axle_y(2,:));

        % Plotting the drone components
        plot_components(new_axle_x, new_axle_y, new_propeller1, new_propeller2, new_propeller3, new_propeller4);

        % Update and plot the trail
        trailPositions = circshift(trailPositions, 1);
        trailPositions(1, :) = [x, y, z];
        plot_trail(trailPositions, ii, trailLength);

        % %--------------------------------------------%
        % % Plot the Pillar
        % % Parameters for the cylinder
        % radius = 1;
        % height = 20; % A large value to simulate a tall pillar, but not infinite
        % numPoints = 500; % Resolution of the circle
        % 
        % % Generate cylinder data
        % [xc, yc, zc] = cylinder(radius, numPoints);
        % 
        % % Adjust z data to stretch the cylinder to the desired height
        % zc = zc * height - height/2; % Centering the cylinder at z = 0
        % 
        % % Plotting
        % for tp = 1:size(xc, 2)
        %     fill3(xc(:, tp), yc(:, tp), zc(:, tp), 'r'); % Fill between points with solid color
        % end


        %--------------------------------------------%
        % Plot the Start and End
        plot3(param.start(1), param.start(2), param.start(3), 'Marker', 'o', 'LineStyle', 'none', 'Color', 'k')
        plot3(param.goal(1), param.goal(2), param.start(3), 'Marker', 'x', 'LineStyle', 'none', 'Color', 'k')
        
        % % Plot the Pillar
        % % Parameters for the cylinder
        % radius = 1;
        % height = 20; % A large value to simulate a tall pillar, but not infinite
        % numPoints = 500; % Resolution of the circle
        % 
        % % Generate cylinder data
        % [xc, yc, zc] = cylinder(radius, numPoints);
        % 
        % % Adjust z data to stretch the cylinder to the desired height
        % zc = zc * height - height/2; % Centering the cylinder at z = 0
        % 
        % % Plotting
        % surf(xc, yc, zc, 'FaceColor', 'r', 'EdgeColor', 'black'); % Plot solid color without edges

        % Parameters for the cylinders
        numPoints = param.numPoints; % Resolution of the cylinder
          
        % Parameters for the circles along the pillar height
        numCircles = param.numCircles; % Number of circles to draw along the pillar's height
        
        % Parameters for the cylinder outline
        numOutlinePoints = 36; % Number of lines to draw around the cylinder for the outline
        outlineSpacing = 2 * pi / numOutlinePoints; % Angular spacing between lines

        % Plot the Start and End
        plot3(param.start(1), param.start(2), z(1), 'Marker', 'o', 'LineStyle', 'none', 'Color', 'k')
        plot3(param.goal(1), param.goal(2), z(1), 'Marker', 'x', 'LineStyle', 'none', 'Color', 'k')
      

        % Loop over each pillar
        for i = 1:length(param.pr)
            % Extract this pillar's parameters
            radius = param.pr(i);
            height = param.ph(i);
            circleSpacing = height / numCircles; % Spacing between the circles
            pillarX = param.px(i);
            pillarY = param.py(i);
        
            % Generate cylinder data
            [xc, yc, zc] = cylinder(radius, numPoints);
            
            % Adjust z data to stretch the cylinder to the desired height
            % and move it to the bottom position
            zc(1, :) = -10;              % Set bottom of cylinder at z = -10
            zc(2, :) = -10 + height;     % Set top of cylinder at z = -10 + height
            
            % Adjust x and y data for the pillar's position
            xc = xc + pillarX;
            yc = yc + pillarY;
            
            % Plotting the sides of the pillar
            surf(xc, yc, zc, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
            
            % Plot black lines on the top and bottom edges of the cylinder
            for ang = 0:outlineSpacing:2*pi
                x_edge = pillarX + radius * cos(ang);
                y_edge = pillarY + radius * sin(ang);
                line([x_edge, x_edge], [y_edge, y_edge], [-10, -10 + height], 'Color', 'k', 'LineWidth', 1);
            end
        
            % Plot black circles at the top and bottom to outline the edges
            ang = linspace(0, 2*pi, numPoints);
            x_circle = pillarX + radius * cos(ang);
            y_circle = pillarY + radius * sin(ang);
            z_top_circle = (-10 + height) * ones(size(x_circle));
            z_bottom_circle = -10 * ones(size(x_circle));
            plot3(x_circle, y_circle, z_top_circle, 'k', 'LineWidth', 1);
            plot3(x_circle, y_circle, z_bottom_circle, 'k', 'LineWidth', 1);

            % Generate circle data
            ang = linspace(0, 2*pi, numPoints);
            x_circle = radius * cos(ang);
            y_circle = radius * sin(ang);
            
            % Plot filled circles at regular intervals along the pillar's height
            for j = 1:numCircles
                z_val = -10 + (j-1) * circleSpacing;
                z_circle = z_val * ones(size(x_circle));
                fill3(pillarX + x_circle, pillarY + y_circle, z_circle, 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.6);
            end

            % Ensure that the figure holds on to all plots
            hold on;
        end


        % % Loop over each pillar
        % for i = 1:length(param.pr)
        %     % Extract this pillar's parameters
        %     radius = param.pr(i);
        %     height = param.ph(i); % Assuming you also have height for each pillar now
        %     pillarX = param.px(i);
        %     pillarY = param.py(i);
        % 
        %     % Generate cylinder data
        %     [xc, yc, zc] = cylinder(radius, numPoints);
        % 
        %     % Adjust z data to stretch the cylinder to the desired height
        %     % and move it to the correct height position
        %     zc = zc * height - height / 2; % Centering the cylinder at z = 0
        % 
        %     % Adjust x and y data for the pillar's position
        %     xc = xc + pillarX;
        %     yc = yc + pillarY;
        % 
        %     % Plotting
        %     surf(xc, yc, zc, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.6); % Adjusted for solid color without edges
        %     hold on; % Keep the figure active for the next pillar
        % 
        %     % plot the top circle for visibility in top-down view
        %     theta = linspace(0, 2*pi, numPoints);
        %     topCircleX = pillarX + radius * cos(theta);
        %     topCircleY = pillarY + radius * sin(theta);
        %     topCircleZ = ones(size(topCircleX)) * (height / 2); % Top of the cylinder
        %     plot3(topCircleX, topCircleY, topCircleZ, 'r', 'LineWidth', 2); % Adjust line color and width as needed
        % end


        % % Calculate the maximum extent for the current position
        % currentMax = max(max(abs(positions(ii, :)), 1));
        % axisLimit = 1.2 * currentMax; % Adjust the scaling factor as needed


        % Set static axis limits
        axis equal;
        xlim([param.xmin, param.xmax]);
        ylim([param.ymin, param.ymax]);
        zlim([param.zmin, param.zmax]);
        

        % Calculate the time in seconds (assuming 10 frames per second)
        timeInSeconds = ii * (param.Tf/mm);
        

        % Set dynamic axis limits, labels, and title with time counter
        xlabel('Position x', 'FontSize', 30, 'Interpreter','latex');
        ylabel('Position y', 'FontSize', 30, 'Interpreter','latex');
        zlabel('Position z', 'FontSize', 30, 'Interpreter','latex');
        title([param.plotTitle ' - Time: ' num2str(timeInSeconds, '%.1f') 's'], 'Interpreter','latex','FontSize', 30);
        legend(param.lgd,'Interpreter','latex','Location', 'northwest', 'FontSize', 30);
        set(gca, 'FontSize', 30); % Set font size for axis labels and tick marks    
        % Turn on the grid
        grid on;
        view(param.view);


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