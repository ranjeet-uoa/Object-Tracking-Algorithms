function [m_predict,P_predict] = ckf_predict_multiple(model,m,P)      

plength= size(m,2);

m_predict = zeros(size(m));
P_predict = zeros(size(P));

for idxp=1:plength
    [m_temp,P_temp] = ckf_predict_single(model,m(:,idxp),P(:,:,idxp));
    m_predict(:,idxp) = m_temp;
    P_predict(:,:,idxp) = P_temp;
end

%%
function [m_predict,P_predict] = ckf_predict_single(model,m,P)

%[X_ukf,u]= ut( [m; zeros(model.v_dim,1) ], blkdiag(P,model.Q), alpha, kappa );
[X_ckf,wt]= ct( m, P );

%propagate it through state transition model
X_pred= gen_newstate_fn( model, X_ckf, 'noiseless' );

m_predict = X_pred*wt(:);
X_temp= X_pred- repmat(m_predict,[1 length(wt)]);
P_predict= X_temp*diag(wt)*X_temp' +model.Qp;
P_predict = (P_predict + P_predict')/2;