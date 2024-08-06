%% Created By Daniel Maldonado Naranjo 2024
% Example Using Plane Animation
clear all; close all; clc; format compact;

%% Extract Saved DATA!!

% This Data is To Be Replaced With Your Own Data
%{
- Need to Ensure your data has: 
    - Position Data
    - Angle Data 
%}

% Example Uses 1pillars_opt.mat data
load('1pillars_opt.mat')
%% Define Animation Parameters
param.scale = 0.2;      % Scale of the Plane in the 3D animation!!!
fontSize = 12;          % Text Font Size 
t = 0:dt:T;             % Define time Vector

%--------------Tunable Parameters--------------%
% Package Plotting Parameters
param.Tf = T;                       % Final Time
param.start = initialState;         % Initial State
param.goal = finalState;            % Final State

% Number of circles to draw along the pillar's height
param.numCircles = 1; 

% Resolution of the cylinder
param.numPoints = 50; % The higher the number the higher the comp time

% Length of trajectory trail
param.trailLength = 10; 

%----------------Axis Min and Max--------------%
% x_min = g.min(1); ymin = g.min(2); 
% x_max = g.max(1); ymax = g.max(2);

x_min = -1; ymin = -1; 
x_max = 11; ymax = 11; 

param.xmin = x_min; param.xmax = x_max; 
param.ymin = ymin; param.ymax = ymax; 
quotesArray = repmat('""', 1, 6);

%--------Define Pillar Location and Size-------%
pillar_x = pillars.pos(1,:);
pillar_y = pillars.pos(2,:);
pillar_r = pillars.radius(:);

param.fontSize = fontSize + 4;
param.lineWidth = 4;
param.scatterSize = 120; 
param.px = pillar_x;
param.py = pillar_y;
param.pr = pillar_r;
param.type = 0;                     

param3D = param; 
param3D.plotTitle = 'Safe Trajectory';

param3D.dt = 10;                            % Frame rate

% Specifies the size of the model (augment to be larger for visual purp)
param3D.zmin = x_min; param3D.zmax = x_max; 

% Specify a Pillar Height (Needs to Be Larger than z_max
param3D.ph = 30*ones(length(pillar_x));       
param3D.lgd = {'Dubins Vehicle','Start', 'Goal', 'Pillar'}; 

%----------------Viewing Angle--------------%
% param3D.view = [0,90];    %top view (xy)
% param3D.view = [0,0];     %side view (zx)
% param3D.view = [90,0];    %side view (zy)
% param3D.view = (3);       %Default 
% param3D.view = [-120,50]; 
% param3D.view = [-30,60]; 
param3D.view = [-30,70]; 

z_traj = 10*ones(size(x_traj));
%param.z_pos = z_traj';
%positions = [xp{1}.Values.Data, xp{2}.Values.Data, xp{3}.Values.Data]; 
positions = [x_traj; y_traj; z_traj]';                     
angles = [zeros(size(x_traj));zeros(size(x_traj));theta_traj]';               

% Create Animation Using Plane 
animate_plane(positions, angles, param3D)

