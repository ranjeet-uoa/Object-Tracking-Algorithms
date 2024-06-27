% This is a demo script for the single target filter using Particle Filter
clearvars;clc;close all;
%rng(0);
model= gen_model;
truth= gen_truth(model);
meas=  gen_meas(model,truth);
est=   run_filter_pf(model,meas);
[handles,rmse]= plot_results(model,truth,meas,est);
fprintf('Averaged Root Mean Square Error using Particle Filter is %.2f [m]\n',mean(rmse));