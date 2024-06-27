function est = run_filter_ckf(model, meas)
% Cubature Kalman Filter: https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=4982682
    %=== Setup
    est.X = cell(meas.K,1);
    filter.run_flag = 'silence'; % 'disp' or 'silence' for on the fly output
    est.filter = filter;
    est.strategy = "CKF";
    %=== Filtering 

% %  Irastamanm and Haykin
  xstart_est = [1000 1000 300 0 -3*(pi/180)]';
  P = diag([100 100 10 10 100e-2]);
  x = mvnrnd(xstart_est, P)';
  start =1;


    starttime=tic;
     est.X{1} = x;
    est.each_proc_time = zeros(meas.K,1);
    % recursive filtering
    for k = start:meas.K
        each_proc_time = tic;
        %---prediction 
        [x, P] = ckf_predict(model, x, P);

        %---update
        [x, P] = ckf_update(model, meas.Z{k}, x, P);

        %--- state extraction
        est.X{k} = x;

        %---display diagnostics
        if ~strcmp(filter.run_flag,'silence')
            disp([' time= ',num2str(k)]);
        end
        est.each_proc_time(k) = toc(each_proc_time);
    end
    est.proc_time = toc(starttime);
end

function [x_pred, P_pred] = ckf_predict(model, x, P)
    % Generate cubature points
    n = model.x_dim;
    xi = sqrt(n) * [eye(n), -eye(n)];

    % Use SVD instead of Cholesky to handle non-positive definite matrices
    [U,S,V] = svd(P);
    sqrtP = U * sqrt(S)*V';
    

    % Propagate through the state transition function
    X = repmat(x, 1, 2*n) + sqrtP*xi;
    X_pred = gen_newstate_fn(model,X,"noiseless"); 

    % Compute the predicted state and covariance
    x_pred = mean(X_pred, 2);
    P_pred = model.Q;
    for i = 1:2*n
        P_pred = P_pred + (X_pred(:,i) - x_pred) * (X_pred(:,i) - x_pred)';
    end
    P_pred = P_pred / (2*n);
    P_pred = 0.5*(P_pred+P_pred');
end

function [x_upd, P_upd] = ckf_update(model, z, x_pred, P_pred)
    % Generate cubature points
    n = model.x_dim;
    xi = sqrt(n) * [eye(n), -eye(n)];
    % Use SVD instead of Cholesky to handle non-positive definite matrices
    [U,S,V] = svd(P_pred);
    sqrtP_pred = U * sqrt(S)*V';
    

    % Propagate through the measurement function
    X = repmat(x_pred, 1, 2*n) + sqrtP_pred * xi;
    Z_pred = gen_observation_fn(model,X,"noiseless"); 

     % Predicted measurement mean
    z_pred = mean(Z_pred, 2);
     % Predicted measurement covariance
    P_zz = model.R;
    for i = 1:2*n
        P_zz = P_zz + (Z_pred(:,i) - z_pred) * (Z_pred(:,i) - z_pred)';
    end
    P_zz = P_zz / (2*n);

    % Cross covariance
    P_xz = zeros(n, length(z));
    for i = 1:2*n
        P_xz = P_xz + (X(:,i) - x_pred) * (Z_pred(:,i) - z_pred)';
    end
    P_xz = P_xz / (2*n);

    % Compute the Kalman gain
    K = P_xz * pinv(P_zz);

    % Update the state and covariance
    x_upd = x_pred + K * (z - z_pred);
    P_upd = P_pred - K * P_zz * K';
    P_upd = 0.5 * (P_upd+P_upd');
end