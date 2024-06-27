function est = run_filter_pf(model,meas,varargin)
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

% %--- Irastamanm and Haykin---
xstart_est = [1000 1000 300 0 -3*(pi/180)]';
P_init = diag([100 100 10 10 100e-2]);
m_init = xstart_est;
start =1;


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
            