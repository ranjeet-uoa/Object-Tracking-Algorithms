
close all
addpath('glmb_pf/')
addpath('glmb_ckf/')
rng('default')

model= gen_model;

%---Data Simulator------------
truth= gen_truth(model);
meas=  gen_meas(model,truth);

%---GLMB with PF and CKF------
est=   run_filter_pf(model,meas);     %with PF as the estimator
est_c = run_filter_ckf(model,meas); %with CKF as the estimator
handles= comb_plot_results(model,truth,meas,est, est_c);