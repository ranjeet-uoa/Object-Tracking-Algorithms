function model= gen_model

% basic parameters
model.x_dim= 5;   %dimension of state vector
model.z_dim= 2;   %dimension of observation vector
model.v_dim= 3;   %dimension of process noise
model.w_dim= 2;   %dimension of observation noise
model.p_dim = 2; % x-y plane

% dynamical model parameters (CT model)
% state transformation given by gen_newstate_fn, transition matrix is N/A in non-linear case
model.T= 1;                         %sampling period
%%/-----Arasratnam & Haykin paper Process Noise----------------\
model.M = [eye(model.p_dim)*model.T^3/3 eye(model.p_dim)*model.T^2/2;
            eye(model.p_dim)*model.T^2/2 eye(model.p_dim)*model.T];

model.q1 = 0.1; %[m^2s^-3
model.q2 = 1.75*1e-4; %s^-3
model.Q = blkdiag(model.q1*model.M, model.q2*model.T);

% survival/death parameters
% N/A for single target

% birth parameters
% N/A for single target

% observation model parameters (noisy r/theta only)
% measurement transformation given by gen_observation_fn, observation matrix is N/A in non-linear case
model.D= diag([sqrt(10)*1e-3; 10]);      %std for angle and range noise
model.R= model.D*model.D';              %covariance for observation noise

model.limit = [-5000,5000;0,5000];
model.pos_idx = [1,2];
model.vel_idx = [3,4];


