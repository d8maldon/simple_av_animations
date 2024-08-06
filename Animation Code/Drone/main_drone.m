%% Created By Daniel Maldonado Naranjo 2024
% Example Using Plane Animation
clear all; close all; clc; format compact;

%% Extract Saved DATA!!

% This Data is To Be Replaced With Your Own Data
%{
- Need to Ensure your data has: 
    - Position Data
    - Angle Data 

Note that the examples data is artificially created
and containes just yaw (no roll and pitch)! 
Animation works for pitch and roll visualization as well!
%}
load('quadrotor_circle_trajectory.mat')


%% Define Parameters
    
% Combine position and orientation data
positions = [data(:,1) data(:,2) data(:,3)];
angles = [data(:,4) data(:,5) data(:,6)];
    
% Animation parameters
param.l = 1;                    % Length of the drone's
param.plotTitle = ['circle']; % Title for the plot and filenames
param.Tf = 10;
param.trailLength = 10; % Trail length
% Number of circles to draw along the pillar's height
param.numCircles = 1; 

% Resolution of the cylinder
param.numPoints = 50; % The higher the number the higher the comp time


R = 5; 
x0 = data(1,1);
y0 = data(1,2);
z0 = data(1,3);


%----------------Axis Min and Max--------------%
param.xmin = -R-2; param.xmax = R+2;
param.ymin = -R-2; param.ymax = R+2;
param.zmin = -1; param.zmax = 2*z0;


%----------------Start and Goal--------------%

param.start = [x0, y0, z0];
param.goal = [data(end,1) data(end,2) data(end,3)];
param3D.lgd = {'Drone','Start', 'Goal', 'Pillar'}; 

%----------------Viewing Angle--------------%
% param.view = [0,90];    %top view (xy)
% param.view = [0,0];     %side view (zx)
% param.view = [90,0];    %side view (zy)
% param.view = (3);       %Default 
% param.view = [-120,50]; 
% param.view = [-30,60]; 
param.view = [-30,70]; 
param.zoom = 1;         % The smaller the number the more zoomed in!
    
% Example has no pillars
param.pr = [0]; % Radii of pillars
param.ph = [0]; % Heights of pillars
param.px = [0]; % x-positions of pillars
param.py = [0]; % y-positions of pillars

% Call the animate function
animate(positions, angles, param);

% Uncomment if you want zoomed in version 
drone_zoom_follow(positions, angles, param)
