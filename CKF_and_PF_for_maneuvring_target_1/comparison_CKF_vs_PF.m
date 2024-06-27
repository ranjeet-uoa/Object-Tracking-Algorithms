% This is a demo script for the single target filter
% Comparing  Cubature Kalman Filter (CKF) vs Particle Filter with 1000
% Particles (PF-1K) vs Particle Filter with 10000 Particles (PF-10K)
% Over 250 Monte-Carlo Runs
clearvars;clc;close all;
addpath("CKF");
addpath("PF");
rng('default');

% initialise mc variables
num_mc = 250;
truth = cell(num_mc,1);
meas = cell(num_mc,1);
est_ckf = cell(num_mc,1);
est_pf_1k = cell(num_mc,1);
est_pf_10k = cell(num_mc,1);
% Filter intiailization start
init_strat = {'other', 'SP', 'TPD'}; % only 'other' works for all filter--by default init_strat{1}

% main program
model= gen_model;
num_mc_div =[]; %storing diverged runs
rmse_thres = 100; %[m]

parfor t = 1 : num_mc
    fprintf('Monte Carlo Run %d/%d\n',t,num_mc);
    truth{t} = gen_truth(model);
    meas{t} =  gen_meas(model,truth{t});
    est_ckf{t} =   run_filter_ckf(model,meas{t}, init_strat{1});
    est_pf_1k{t} =   run_filter_pf(model,meas{t},init_strat{1},'num_particles',1000);
    %checking for a diverged MC runs
    if mean(cell2mat(cellfun(@(x,y) sqrt(sum((x(model.pos_idx) - y(model.pos_idx)).^2)),truth{t}.X,est_ckf{t}.X,'UniformOutput',false))) > rmse_thres ||...
            mean(cell2mat(cellfun(@(x,y) sqrt(sum((x(model.pos_idx) - y(model.pos_idx)).^2)),truth{t}.X,est_pf_1k{t}.X,'UniformOutput',false))) > rmse_thres
        est_ckf{t}.X = zeros(model.x_dim,meas{t}.K);
        est_pf_1k{t}.X = est_ckf{t}.X;
        est_pf_10k{t}.X = est_ckf{t}.X;
        num_mc_div = [num_mc_div t];
        continue;
    end

    est_pf_10k{t} =   run_filter_pf(model,meas{t},init_strat{1},'num_particles',10000);
end

%% analyse the monte carlo results
% rmse
num_mc_eff = setdiff(1:num_mc,num_mc_div);
%Pos
rmse.ckf = zeros(meas{1}.K,length(num_mc_eff));
rmse.pf1k = zeros(meas{1}.K,length(num_mc_eff));
rmse.pf10k = zeros(meas{1}.K,length(num_mc_eff));
%vel
rmse.ckf_vel = zeros(meas{1}.K,length(num_mc_eff));
rmse.pf1k_vel = zeros(meas{1}.K,length(num_mc_eff));
rmse.pf10k_vel = zeros(meas{1}.K,length(num_mc_eff));
%turn rate
rmse.ckf_tr = zeros(meas{1}.K,length(num_mc_eff));
rmse.pf1k_tr = zeros(meas{1}.K,length(num_mc_eff));
rmse.pf10k_tr = zeros(meas{1}.K,length(num_mc_eff));


%rmse computations
%pos
for t = 1: length(num_mc_eff)
    rmse.ckf(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.pos_idx) - y(model.pos_idx)).^2)),truth{num_mc_eff(t)}.X,est_ckf{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    rmse.pf1k(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.pos_idx) - y(model.pos_idx)).^2)),truth{num_mc_eff(t)}.X,est_pf_1k{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    rmse.pf10k(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.pos_idx) - y(model.pos_idx)).^2)),truth{num_mc_eff(t)}.X,est_pf_10k{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    %vel
    rmse.ckf_vel(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.vel_idx) - y(model.vel_idx)).^2)),truth{num_mc_eff(t)}.X,est_ckf{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    rmse.pf1k_vel(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.vel_idx) - y(model.vel_idx)).^2)),truth{num_mc_eff(t)}.X,est_pf_1k{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    rmse.pf10k_vel(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.vel_idx) - y(model.vel_idx)).^2)),truth{num_mc_eff(t)}.X,est_pf_10k{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    %turn rate
    rmse.ckf_tr(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(end) - y(end)).^2)),truth{num_mc_eff(t)}.X,est_ckf{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    rmse.pf1k_tr(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(end) - y(end)).^2)),truth{num_mc_eff(t)}.X,est_pf_1k{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column
    rmse.pf10k_tr(:,t) = cell2mat(cellfun(@(x,y) sqrt(sum((x(end) - y(end)).^2)),truth{num_mc_eff(t)}.X,est_pf_10k{num_mc_eff(t)}.X,'UniformOutput',false)); % each run as a column

end
%averaged rmse over time
rmse_ckf_avg = mean(rmse.ckf,2);
rmse_pf1k_avg = mean(rmse.pf1k,2);
rmse_pf10k_avg = mean(rmse.pf10k,2);

rmse_ckf_avg_vel = mean(rmse.ckf_vel,2);
rmse_pf1k_avg_vel = mean(rmse.pf1k_vel,2);
rmse_pf10k_avg_vel = mean(rmse.pf10k_vel,2);

rmse_ckf_avg_tr = mean(rmse.ckf_tr,2);
rmse_pf1k_avg_tr = mean(rmse.pf1k_tr,2);
rmse_pf10k_avg_tr = mean(rmse.pf10k_tr,2);
%plots

figure();
plot(1:meas{1}.K,rmse_ckf_avg,'LineWidth',2,'LineStyle','-'); hold on;
plot(1:meas{1}.K,rmse_pf1k_avg,'LineWidth',2,'LineStyle','--'); hold on;
plot(1:meas{1}.K,rmse_pf10k_avg,'LineWidth',2,'LineStyle','-.'); hold on;

legend({"Cubature Kalman Filter","Particle Filter (1K)","Particle Filter (10K)"}, 'Location','best');
legend boxoff
%title('Root Mean Square Error over 100 MC over time');
xlabel('Time $[s]$', Interpreter='latex')
ylabel('RMSE $[m]$', Interpreter='latex');
ax=gca;
ax.FontSize =14;
ax.YLim = [0 40];
%set(gcf,'color','w'); % set background to white


fprintf('Averaged Root Mean Square Error using CKF is %.2f [m]\n',mean(rmse.ckf,"all"));
fprintf('Averaged Root Mean Square Error using PF-1K is %.2f [m]\n',mean(rmse.pf1k,"all"));
fprintf('Averaged Root Mean Square Error using PF-10K is %.2f [m]\n',mean(rmse.pf10k,"all"));

figure();
plot(1:meas{1}.K,rmse_ckf_avg_vel,'LineWidth',2,'LineStyle','-'); hold on;
plot(1:meas{1}.K,rmse_pf1k_avg_vel,'LineWidth',2,'LineStyle','--'); hold on;
plot(1:meas{1}.K,rmse_pf10k_avg_vel,'LineWidth',2,'LineStyle','-.'); hold on;

legend({"Cubature Kalman Filter","Particle Filter (1K)","Particle Filter (10K)"}, 'Location','best');
legend boxoff
%title('Root Mean Square Error over 100 MC over time');
xlabel('Time $[s]$', Interpreter='latex')
ylabel('RMSE $[m/s]$', Interpreter='latex');
ax=gca;
ax.FontSize =14;
ax.YLim = [0 25];
%set(gcf,'color','w'); % set background to white

fprintf('Averaged Root Mean Square Error(vel) using CKF is %.2f [m/s]\n',mean(rmse.ckf_vel,"all"));
fprintf('Averaged Root Mean Square Error(vel) using PF-1K is %.2f [m/s]\n',mean(rmse.pf1k_vel,"all"));
fprintf('Averaged Root Mean Square Error(vel) using PF-10K is %.2f [m/s]\n',mean(rmse.pf10k_vel,"all"));

figure();
plot(1:meas{1}.K,rad2deg(rmse_ckf_avg_tr),'LineWidth',2,'LineStyle','-'); hold on;
plot(1:meas{1}.K,rad2deg(rmse_pf1k_avg_tr),'LineWidth',2,'LineStyle','--'); hold on;
plot(1:meas{1}.K,rad2deg(rmse_pf10k_avg_tr),'LineWidth',2,'LineStyle','-.'); hold on;
legend({"Cubature Kalman Filter","Particle Filter (1K)","Particle Filter (10K)"}, 'Location','best');
legend boxoff
%title('Root Mean Square Error over 100 MC over time');
xlabel('Time $[s]$', Interpreter='latex')
ylabel('RMSE $[Deg/s]$', Interpreter='latex');
ax=gca;
ax.FontSize =14;
%set(gcf,'color','w'); % set background to white

fprintf('Averaged Root Mean Square Error(turn rate) using CKF is %.2f [Deg/s]\n',rad2deg(mean(rmse.ckf_tr,"all")));
fprintf('Averaged Root Mean Square Error(turn rate) using PF-1K is %.2f [Deg/s]\n',rad2deg(mean(rmse.pf1k_tr,"all")));
fprintf('Averaged Root Mean Square Error(turn rate) using PF-10K is %.2f [Deg/s]\n',rad2deg(mean(rmse.pf10k_tr,"all")));

% proc time

for t = 1:length(num_mc_eff)
   proc_time.ckf(:,t) = est_ckf{num_mc_eff(t)}.each_proc_time;
   proc_time.pf1k(:,t) = est_pf_1k{num_mc_eff(t)}.each_proc_time;
   proc_time.pf10k(:,t) = est_pf_10k{num_mc_eff(t)}.each_proc_time;
end

proctime_ckf_avg = 1e3*mean(proc_time.ckf,2);
proctime_pf1k_avg =1e3* mean(proc_time.pf1k,2);
proctime_pf10k_avg = 1e3*mean(proc_time.pf10k,2);

figure();
plot(1:meas{1}.K,proctime_ckf_avg,'LineWidth',2,'LineStyle','-'); hold on;
plot(1:meas{1}.K,proctime_pf1k_avg,'LineWidth',2,'LineStyle','--'); hold on;
plot(1:meas{1}.K,proctime_pf10k_avg,'LineWidth',2,'LineStyle','-.'); hold on;
legend({"Cubature Kalman Filter","Particle Filter (1K)","Particle Filter (10K)"},'Location', 'best');
legend boxoff
%title('Processing Time over 100 MC over time');
xlabel('Time $[s]$', Interpreter='latex')
ylabel('Processing time $[ms]$', Interpreter='latex');
%set(gcf,'color','w'); % set background to white
ax=gca;
ax.FontSize =14;

fprintf('CKF averaged processing time is %.2f [ms]\n',1e3*mean(proc_time.ckf,"all"));
fprintf('PF-1K averaged processing time is %.2f [ms]\n',1e3*mean(proc_time.pf1k,"all"));
fprintf('PF-10K averaged processing time is %.2f [ms]\n',1e3*mean(proc_time.pf10k,"all"));

model.mc = num_mc_eff; %storing actual MC runs
truths = plot_comp_results(model,truth, est_ckf, est_pf_1k, est_pf_10k);