function meas= gen_meas(model,truth)

%variables
meas.K= truth.K;
meas.Z= cell(truth.K,1);

%generate measurements
for k=1:truth.K
    meas.Z{k} = gen_observation_fn(model,truth.X{k},'noise');                           %single target observations if detected                                                                 %measurement is union of detections and clutter
end
    