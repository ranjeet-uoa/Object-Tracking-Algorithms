function est = run_filter_pf(model,meas,init,varargin)
% Particle Filter: http://www.irisa.fr/aspi/legland/ensta/ref/gordon93a.pdf
%=== Setup
% --- Input Parser
p = inputParser;
addParameter(p,'num_particles',1000);                                                         %track threshold
parse(p, varargin{:});
%output variables
est.X= cell(meas.K,1);


%filter parameters
filter.J_max= p.Results.num_particles;                  %total number of particles

filter.run_flag= 'silence';            %'disp' or 'silence' for on the fly output

est.filter= filter;
est.strategy = "PF";
%=== Filtering 

%initial prior
w_update= ones(filter.J_max,1)/filter.J_max;
switch init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'SP'
% %1. SP initialization
 xstart_est = [meas.Z{1}(2,:)*cos(meas.Z{1}(1,:)) meas.Z{1}(2,:)*sin(meas.Z{1}(1,:)) 0 0  -3*(pi/180)]';

     P_pos = [model.R(2,2)*cos(meas.Z{1}(1,:))^2+meas.Z{1}(2,:)^2*model.R(1,1)*sin(meas.Z{1}(1,:))^2 ...
         (model.R(2,2)-meas.Z{1}(2,:)^2*model.R(1,1))*sin(meas.Z{1}(1,:))*cos(meas.Z{1}(1,:));
         (model.R(2,2)-meas.Z{1}(2,:)^2*model.R(1,1))*sin(meas.Z{1}(1,:))*cos(meas.Z{1}(1,:)) ...
         model.R(2,2)*sin(meas.Z{1}(1,:))^2+meas.Z{1}(2,:)^2*model.R(1,1)*cos(meas.Z{1}(1,:))^2];

     P_vel = diag([(meas.vel_max*cos(meas.Z{1}(1,:))-meas.vel_min*cos(meas.Z{1}(1,:)))^2/12 (meas.vel_max*sin(meas.Z{1}(1,:))-meas.vel_min*sin(meas.Z{1}(1,:)))^2/12]);

    P_init = blkdiag(P_pos, P_vel,  100*1e-2);
    m_init = xstart_est;
  start =1;
    case 'TPD'
%2. TPD initialization
xstart_est = [meas.Z{2}(2,:)*cos(meas.Z{2}(1,:)) meas.Z{2}(2,:)*sin(meas.Z{2}(1,:)) ...
            (meas.Z{2}(2,:)*cos(meas.Z{2}(1,:))-meas.Z{1}(2,:)*cos(meas.Z{1}(1,:)))/model.T ... 
            (meas.Z{2}(2,:)*sin(meas.Z{2}(1,:))-meas.Z{1}(2,:)*sin(meas.Z{1}(1,:)))/model.T  -3*(pi/180)]';

R1 = [model.R(2,2)*cos(meas.Z{1}(1,:))^2+meas.Z{1}(2,:)^2*model.R(1,1)*sin(meas.Z{1}(1,:))^2 (model.R(2,2)-meas.Z{1}(2,:)^2*model.R(1,1))*sin(meas.Z{1}(1,:))*cos(meas.Z{1}(1,:));
     (model.R(2,2)-meas.Z{1}(2,:)^2*model.R(1,1))*sin(meas.Z{1}(1,:))*cos(meas.Z{1}(1,:)) model.R(2,2)*sin(meas.Z{1}(1,:))^2+meas.Z{1}(2,:)^2*model.R(1,1)*cos(meas.Z{1}(1,:))^2];

R2 = [model.R(2,2)*cos(meas.Z{2}(1,:))^2+meas.Z{2}(2,:)^2*model.R(1,1)*sin(meas.Z{2}(1,:))^2 (model.R(2,2)-meas.Z{2}(2,:)^2*model.R(1,1))*sin(meas.Z{2}(1,:))*cos(meas.Z{2}(1,:));
     (model.R(2,2)-meas.Z{2}(2,:)^2*model.R(1,1))*sin(meas.Z{2}(1,:))*cos(meas.Z{2}(1,:)) model.R(2,2)*sin(meas.Z{2}(1,:))^2+meas.Z{2}(2,:)^2*model.R(1,1)*cos(meas.Z{2}(1,:))^2];

P_init =blkdiag([R2 R2/model.T; ...
                 R2/model.T (R1+R2)/model.T^2], 100e-2);
m_init = xstart_est;
start = 2;
    case 'other'
% % 3. Irastamanm and Haykin
xstart_est = [1000 1000 300 0 -3*(pi/180)]';
P_init = diag([100 100 10 10 100e-2]);
m_init = xstart_est;
start =1;
end


x_update= gen_gms(1,m_init,P_init,filter.J_max);
%x_update = mvnrnd(m_init, P_init, filter.J_max)';
starttime=tic;
 est.X{1} = m_init;
est.each_proc_time = zeros(meas.K,1);
%recursive filtering
for k=start:meas.K
    each_proc_time = tic;
    %---prediction 
    x_predict = gen_newstate_fn(model,x_update,'noise');
    w_predict= w_update;
        
    %---update
    rfs_likelihood =compute_likelihood(model,meas.Z{k},x_predict)';
    w_update= rfs_likelihood.*w_predict;

    % Ensure weights are non-negative
    w_update = max(w_update, 0);

    % If all weights are zero, set one to a small positive value
    if all(w_update == 0)
        w_update(1) = 1e-10;
    end

    x_update= x_predict;

    %normalize weights
    w_update = w_update/sum(w_update);   

    %--- state extraction--(before resampling)
    est.X{k} = x_update*w_update;
            
    %---for diagnostics
    w_posterior= w_update;
    
    %---resampling
    idx= randsample(1:length(w_update),filter.J_max,true,w_update); %idx= resample(w_update,filter.J_max);
    w_update= ones(filter.J_max,1)/filter.J_max;
    x_update= x_update(:,idx);

    %[x_update, w_update] = resample(x_update, w_update, 'multinomial');


    
    % %--- state extraction--(After resampling)
    % est.X{k} = x_update*w_update;
  
    %---display diagnostics
    if ~strcmp(filter.run_flag,'silence')
        disp([' time= ',num2str(k),...
         ' Neff_updt= ',num2str(round(1/sum(w_posterior.^2)))...
         ' Neff_rsmp= ',num2str(round(1/sum(w_update.^2)))   ]);
    end
    est.each_proc_time(k) = toc(each_proc_time);
end
est.proc_time = toc(starttime);
            