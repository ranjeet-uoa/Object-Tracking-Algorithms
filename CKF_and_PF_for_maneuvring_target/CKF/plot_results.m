function [handles,rmse]= plot_results(model,truth,meas,est)

% [X_track,k_birth,k_death]= extract_tracks(truth.X,truth.track_list,truth.total_tracks);
truth_pos  = cell2mat(cellfun(@(x) x(model.pos_idx)',truth.X,'UniformOutput',false))';
est_pos = cell2mat(cellfun(@(x) x(model.pos_idx)',est.X,'UniformOutput',false))';

%plot ground truths
figure; truths= gcf; hold on;
plot(truth_pos(1,1),truth_pos(2,1),'ko','LineWidth',2); hold on;
plot(truth_pos(1,:),truth_pos(2,:),'-k','LineWidth',2); hold on;
plot(truth_pos(1,end),truth_pos(2,end),'k^','LineWidth',2); hold on;
%axis equal; axis(reshape(model.limit',[],1)'); title('Ground Truths');
xlabel("x-coordinate [m]");
ylabel("y-coordinate [m]");

% plot est vs truth
figure();
plot(truth_pos(1,1),truth_pos(2,1),'ko','LineWidth',2); hold on;
plot(truth_pos(1,:),truth_pos(2,:),'-k','LineWidth',2); hold on;
plot(truth_pos(1,end),truth_pos(2,end),'k^','LineWidth',2); hold on;
scatter(est_pos(1,:),est_pos(2,:),10,'filled','Red'); hold on;
%axis equal; axis(reshape(model.limit',[],1)'); title('Est vs Truths');
xlabel("x-coordinate [m]");
ylabel("y-coordinate [m]");

%plot x tracks and measurements in x/y
figure; tracking= gcf; hold on;

%plot x measurement
subplot(211); box on; 

for k=1:meas.K
    if ~isempty(meas.Z{k})
        hlined= line(k*ones(size(meas.Z{k},2),1),meas.Z{k}(2,:).*cos(meas.Z{k}(1,:)),'LineStyle','none','Marker','x','Markersize',5,'Color',0.7*ones(1,3));
    end   
end

for i=1:truth.total_tracks
    hline1= line(1:1:meas.K,truth_pos(1,:),'LineStyle','-','Marker','none','LineWidth',1,'Color',0*ones(1,3));
end

%plot x estimate
for k=1:meas.K
    if ~isempty(est.X{k})
        P= est.X{k}(model.pos_idx,:);
        hline2= line(k*ones(size(est.X{k},2),1),P(1,:),'LineStyle','none','Marker','.','Markersize',8,'Color',0*ones(1,3));
    end
end

%plot y measurement
subplot(212); box on;
    
for k=1:meas.K
    if ~isempty(meas.Z{k})
        yhlined= line(k*ones(size(meas.Z{k},2),1),meas.Z{k}(2,:).*sin(meas.Z{k}(1,:)),'LineStyle','none','Marker','x','Markersize',5,'Color',0.7*ones(1,3));
    end
end

%plot y track
for i=1:truth.total_tracks
        yhline1= line(1:1:meas.K,truth_pos(2,:),'LineStyle','-','Marker','none','LineWidth',1,'Color',0*ones(1,3));
end

%plot y estimate
for k=1:meas.K
    if ~isempty(est.X{k}),
        P= est.X{k}(model.pos_idx,:);
        yhline2= line(k*ones(size(est.X{k},2),1),P(2,:),'LineStyle','none','Marker','.','Markersize',8,'Color',0*ones(1,3));
    end
end

subplot(211); xlabel('Time'); ylabel('x-coordinate (m)');
set(gca, 'XLim',[1 truth.K]); set(gca, 'YLim',model.limit(1,:));
legend([hline2 hline1 hlined],'Estimates          ','True tracks','Measurements');

subplot(212); xlabel('Time'); ylabel('y-coordinate (m)');
%set(gca, 'XLim',[1 truth.K]); set(gca, 'YLim',model.limit(2,:));


%plot error
rmse = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.pos_idx) - y(model.pos_idx)).^2)),truth.X,est.X,'UniformOutput',false));
figure();
rmse_hd = plot(1:meas.K,rmse,'k'); grid on; set(gca, 'XLim',[1 meas.K]); set(gca, 'YLim',[0 100]); ylabel('RMSE [m]');
xlabel('Time'); title('Root Mean Square Errors over Time');


%return
handles=[ truths tracking rmse_hd ];

