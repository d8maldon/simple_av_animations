%% Created By Daniel Maldonado Naranjo 2024

function animate_plane(positions, angles, param)

    % Open figure in full screen
    fig = figure; hold on; 
    set(fig, 'units', 'normalized', 'outerposition', [0 0 1 1]);

    % Set up video writer
    videoFileName = [param.plotTitle 'drone_animation.avi'];
    videoWriter = VideoWriter(videoFileName, 'Uncompressed AVI');
    videoWriter.FrameRate = param.dt; % Adjust frame rate as needed
    open(videoWriter);

    % Initialize variables for GIF creation
    gifFileName = [param.plotTitle 'drone_animation.gif'];
    gifDelayTime = 0.1; % Delay time between frames in the GIF

    % Coordinates defining the shape of the plane
    % Scaling first
    scale = param.scale * 0.5;
    scaledBodyX = scale * [-1 0 1 0 -1];
    scaledBodyY = scale * [0 5 0 -5 0];
    scaledWingX = scale * [-5 5 5 -5 -5];
    scaledWingY = scale * [1 1 -1 -1 1];
    scaledTailX = scale * [-0.5 0.5 0.5 -0.5 -0.5];
    scaledTailY = scale * [0 0 3 3 0];  
    
    % Apply initial rotation to the plane parts
    theta = pi/2; % 90 degrees in radians
    Rz_initial = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
    rotatedBody = Rz_initial * [scaledBodyX; scaledBodyY; zeros(1, length(scaledBodyX))];
    rotatedWings = Rz_initial * [scaledWingX; scaledWingY; zeros(1, length(scaledWingX))];
    rotatedTail = Rz_initial * [scaledTailX; scaledTailY; zeros(1, length(scaledTailX))];
    
    % Update initial coordinates
    bodyX = rotatedBody(1,:);
    bodyY = rotatedBody(2,:);
    wingX = rotatedWings(1,:);
    wingY = rotatedWings(2,:);
    tailX = rotatedTail(1,:);
    tailY = rotatedTail(2,:);
    
    % Position adjustment based on rotated body
    tailX = tailX + min(bodyX);  
    
    % Create patch objects for each part of the plane
    body = fill3(bodyX, bodyY, zeros(size(bodyX)), 'k');
    wings = fill3(wingX, wingY, zeros(size(wingX)), 'k','HandleVisibility','off');
    tail = fill3(tailX, tailY, zeros(size(tailX)), 'k','HandleVisibility','off');
    

    % Initialize sizes of matrices and trail effect parameters
    [mm, ~] = size(angles);
    trailLength = param.trailLength; % Length of the trail
    trailPositions = zeros(trailLength, 3); % Store previous positions for the trail

    % Parameters for the cylinders
    numPoints = param.numPoints; % Resolution of the cylinder
      
    % Parameters for the circles along the pillar height
    numCircles = param.numCircles; % Number of circles to draw along the pillar's height
    
    % Parameters for the cylinder outline
    numOutlinePoints = 4; % Number of lines to draw around the cylinder for the outline
    outlineSpacing = 2 * pi / numOutlinePoints; % Angular spacing between lines

    z = positions(1, 3);
    %--------------------------------------------%
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

    % Main loop to animate the drone
    for ii = 1:mm

        % Extract position and angles for current frame
        x = positions(ii, 1); pathX = x'; 
        y = positions(ii, 2); pathY = y'; 
        z = positions(ii, 3); pathZ = z';  
        phi = angles(ii, 1);
        theta = angles(ii, 2);
        psi = angles(ii, 3);

        % Compute rotation matrix
        Rz = get_rotation(phi, theta, psi);

        % Apply rotation to the plane parts
        rotatedBody = Rz * [bodyX; bodyY; zeros(1, length(bodyX))];
        rotatedWings = Rz * [wingX; wingY; zeros(1, length(wingX))];
        rotatedTail = Rz * [tailX; tailY; zeros(1, length(tailX))];

        % Update plane position and rotation
        set(body, 'XData', rotatedBody(1,:) + pathX, 'YData', ...
            rotatedBody(2,:) + pathY, 'ZData', rotatedBody(3,:) + pathZ)
        set(wings, 'XData', rotatedWings(1,:) + pathX, 'YData',...
            rotatedWings(2,:) + pathY, 'ZData', rotatedWings(3,:) + pathZ,'HandleVisibility','off')
        set(tail, 'XData', rotatedTail(1,:) + pathX, 'YData',...
            rotatedTail(2,:) + pathY, 'ZData', rotatedTail(3,:) + pathZ,'HandleVisibility','off')
      
        % Update the figure
        drawnow


        % Update and plot the trail
        trailPositions = circshift(trailPositions, 1);
        trailPositions(1, :) = [x, y, z];
        plot_trail(trailPositions, ii, trailLength)
        
        % Set static axis limits
        % axis equal;
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
            %clf;
        end
    end

    % Close the video file
    close(videoWriter);
end


function plot_trail(trailPositions, currentStep, trailLength)
    % Plot the trail with fading effect
    numPointsToPlot = min(currentStep, trailLength);
    for jj = 1:numPointsToPlot
        plot3(trailPositions(jj, 1), trailPositions(jj, 2), trailPositions(jj, 3), ...
              '.', 'Color', [0, 0, 1, max(0, 1 - jj/trailLength)]);
    end
end