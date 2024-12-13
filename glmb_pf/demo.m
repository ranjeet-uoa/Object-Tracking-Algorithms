
close all
addpath('_common/')
rng('default')

model= gen_model;

%---Data Simulator------------
truth= gen_truth(model);
meas=  gen_meas(model,truth);

%---GLMB with PF------
est=   run_filter_pf(model,meas);    
handles= plot_results(model,truth,meas,est);
                                