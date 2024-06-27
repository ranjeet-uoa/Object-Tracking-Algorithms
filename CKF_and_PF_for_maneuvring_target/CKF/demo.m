% This is a demo script for the single target filter usng Cubature Kalman
% Filter
clearvars;clc;close all;
%rng(0);
model= gen_model;
truth= gen_truth(model);
meas=  gen_meas(model,truth);
est_ckf=   run_filter_ckf(model,meas);
[handles,rmse]= plot_results(model,truth,meas,est_ckf);
fprintf('Averaged Root Mean Square Error using CKF is %.2f [m]\n',mean(rmse));