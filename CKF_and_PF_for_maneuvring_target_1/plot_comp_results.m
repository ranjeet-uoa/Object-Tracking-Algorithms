function truths = plot_comp_results(model,truth, est_c, est_p1, est_p10)

% Select a run for single run plots
i =model.mc(32);

% [X_track,k_birth,k_death]= extract_tracks(truth.X,truth.track_list,truth.total_tracks);
truth_pos  = cell2mat(cellfun(@(x) x(model.pos_idx)',truth{i}.X,'UniformOutput',false))';
est_c_pos = cell2mat(cellfun(@(x) x(model.pos_idx)',est_c{i}.X,'UniformOutput',false))';
est_p1_pos = cell2mat(cellfun(@(x) x(model.pos_idx)',est_p1{i}.X,'UniformOutput',false))';
est_p10_pos = cell2mat(cellfun(@(x) x(model.pos_idx)',est_p10{i}.X,'UniformOutput',false))';

%plot ground truths
figure(); truths= gcf;
plot(0,0,'r+','LineWidth',2); hold on;
plot(truth_pos(1,1)/1000,truth_pos(2,1)/1000,'ko','LineWidth',2); hold on;
plot(truth_pos(1,:)/1000,truth_pos(2,:)/1000,'-k','LineWidth',2); hold on;
plot(truth_pos(1,end)/1000,truth_pos(2,end)/1000,'k^','LineWidth',2); hold on;
%axis equal; 
%axis(reshape(model.limit',[],1)'); %title('Ground Truths');
xlabel("x-coordinate $[km]$", Interpreter="latex");
ylabel("y-coordinate $[km]$", Interpreter="latex");
legend({'Sensor Position','Start Point', 'True Trajectory','End Point' }, 'Location','best')
legend boxoff
ax=gca;
ax.FontSize =14;
ax.YLim =[-.5 20];
ax.XLim =[-.5 12];

% plot est vs truth
figure();
plot(truth_pos(1,1)/1000,truth_pos(2,1)/1000,'ko','LineWidth',2); hold on;
plot(truth_pos(1,:)/1000,truth_pos(2,:)/1000,'-k','LineWidth',2); hold on;
plot(truth_pos(1,end)/1000,truth_pos(2,end)/1000,'k^','LineWidth',2); hold on;
%scatter(est_c_pos(1,:),est_c_pos(2,:),10,'filled','Red'); hold on;
plot(est_c_pos(1,:)/1000,est_c_pos(2,:)/1000,'--r', 'LineWidth',2); hold on;
plot(est_p1_pos(1,:)/1000,est_p1_pos(2,:)/1000,'--b', 'LineWidth',2); hold on;
plot(est_p10_pos(1,:)/1000,est_p10_pos(2,:)/1000,'--g', 'LineWidth',2); hold on;
%axis equal;
%axis(reshape(model.limit',[],1)');% title('Est vs Truths');
xlabel("x-coordinate $[km]$", Interpreter="latex");
ylabel("y-coordinate $[km]$", Interpreter="latex");
legend({'Start Point', 'True Trajectory','End Point','Cubature Kalman Filter', 'Particle Filter (1K)', 'Particle Filter (10K)' }, 'Location','best');
legend boxoff
ax=gca;
ax.FontSize =14;
ax.YLim =[-.5 20];
ax.XLim =[-.5 12];


% %plot x tracks and measurements in x/y
% figure; tracking= gcf; hold on;
% 
% %plot x measurement
% subplot(211); box on; 
% 
% for k=1:meas.K
%     if ~isempty(meas.Z{k})
%         hlined= line(k*ones(size(meas.Z{k},2),1),meas.Z{k}(2,:).*sin(meas.Z{k}(1,:)),'LineStyle','none','Marker','x','Markersize',5,'Color',0.7*ones(1,3));
%     end   
% end
% 
% for i=1:truth.total_tracks
%     hline1= line(1:1:meas.K,truth_pos(1,:),'LineStyle','-','Marker','none','LineWidth',1,'Color',0*ones(1,3));
% end
% 
% %plot x estimate
% for k=1:meas.K
%     if ~isempty(est.X{k})
%         P= est.X{k}([1 3],:);
%         hline2= line(k*ones(size(est.X{k},2),1),P(1,:),'LineStyle','none','Marker','.','Markersize',8,'Color',0*ones(1,3));
%     end
% end
% 
% %plot y measurement
% subplot(212); box on;
% 
% for k=1:meas.K
%     if ~isempty(meas.Z{k})
%         yhlined= line(k*ones(size(meas.Z{k},2),1),meas.Z{k}(2,:).*cos(meas.Z{k}(1,:)),'LineStyle','none','Marker','x','Markersize',5,'Color',0.7*ones(1,3));
%     end
% end
% 
% %plot y track
% for i=1:truth.total_tracks
%         yhline1= line(1:1:meas.K,truth_pos(2,:),'LineStyle','-','Marker','none','LineWidth',1,'Color',0*ones(1,3));
% end
% 
% %plot y estimate
% for k=1:meas.K
%     if ~isempty(est.X{k}),
%         P= est.X{k}([1 3],:);
%         yhline2= line(k*ones(size(est.X{k},2),1),P(2,:),'LineStyle','none','Marker','.','Markersize',8,'Color',0*ones(1,3));
%     end
% end
% 
% subplot(211); xlabel('Time'); ylabel('x-coordinate (m)');
% set(gca, 'XLim',[1 truth.K]); set(gca, 'YLim',model.limit(1,:));
% legend([hline2 hline1 hlined],'Estimates          ','True tracks','Measurements');
% 
% subplot(212); xlabel('Time'); ylabel('y-coordinate (m)');
% set(gca, 'XLim',[1 truth.K]); set(gca, 'YLim',model.limit(2,:));
% 
% 
% %plot error
% rmse = cell2mat(cellfun(@(x,y) sqrt(sum((x(model.pos_idx) - y(model.pos_idx)).^2)),truth.X,est.X,'UniformOutput',false));
% figure();
% rmse_hd = plot(1:meas.K,rmse,'k'); grid on; set(gca, 'XLim',[1 meas.K]); set(gca, 'YLim',[0 100]); ylabel('RMSE [m]');
% xlabel('Time'); title('Root Mean Square Errors over Time');
% 
% 
% %return
% handles=[ truths tracking rmse_hd ];

