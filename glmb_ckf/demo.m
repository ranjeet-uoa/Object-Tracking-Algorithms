close all
addpath('_common/')
rng('default');

%---Data Simulator------
model= gen_model;
truth= gen_truth(model);
meas=  gen_meas(model,truth);

%--GLMB with ckf--------
est=   run_filter_ckf(model,meas);
handles= plot_results(model,truth,meas,est);