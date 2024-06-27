function meas= gen_meas(model,truth)

%variables
meas.K= truth.K;
meas.Z= cell(truth.K,1);

%generate measurements
for k=1:truth.K
    obs(:,k) = gen_observation_fn(model,truth.X{k},'noise');  
    meas.Z{k}= obs(:,k);                          %single target observations if detected                                                                 %measurement is union of detections and clutter
end
    
%store velocity for intialization
vel = (obs(2,2:end)-obs(2,1:end-1))/model.T;
vel_max = max(vel);
meas.vel_max = vel_max;
meas.vel_min = min(vel);