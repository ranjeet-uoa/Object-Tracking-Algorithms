function z_gate= gate_meas_ckf(z,gamma,model,m,P)

valid_idx = [];
zlength = size(z,2); if zlength==0, z_gate= []; return; end
plength = size(m,2);

for j=1:plength
        [X_ckf,wt]= ct( m(:,j), P(:,:,j));
        Z_pred= gen_observation_fn( model, X_ckf, 'noiseless' );
        eta= Z_pred*wt(:); Sj_temp= Z_pred- repmat(eta,[1 length(wt)]);
        Sj= Sj_temp*diag(wt)*Sj_temp' + model.R;
        Vs= chol(Sj); det_Sj= prod(diag(Vs))^2; inv_sqrt_Sj= inv(Vs);
        iSj= inv_sqrt_Sj*inv_sqrt_Sj'; 
        nu= z- repmat(gen_observation_fn(model,m(:,j),zeros(size(model.D,2),1)),[1 zlength]);
        dist= sum((inv_sqrt_Sj'*nu).^2);
        valid_idx= union(valid_idx,find( dist < gamma ));
end
z_gate = z(:,valid_idx);