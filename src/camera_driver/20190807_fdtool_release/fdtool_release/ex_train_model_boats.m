close all
%options.positives_path     = fullfile(pwd , 'images' , 'faces' , 'train' , 'positives');
options.positives_path     = fullfile(pwd , 'images' , 'boats' , 'train' , 'positives');
options.negatives_path     = fullfile(pwd , 'images' , 'boats' , 'train' , 'negatives');
%options.posext             = {'png'};
options.posext             = {'jpg'};
options.negext             = {'jpg'};
options.negmax_size        = 1000;
options.Npostrain          = 500;
options.Nnegtrain          = 2000;
options.Npostest           = 50;
options.Nnegtest           = 100;
options.Nposboost          = 0;
options.Nnegboost          = 100;
options.boost_ite          = 3;
options.seed               = 5489;
options.resetseed          = 1;
options.standardize        = 0;
options.preview            = 0;
options.probaflipIpos      = 0.5;
options.probarotIpos       = 0.2;
options.m_angle            = 0;
options.sigma_angle        = 2^2;
options.probaswitchIneg    = 0.9;
options.posscalemin        = 0.9;
options.posscalemax        = 1.1;
options.negscalemin        = 0.2;
options.negscalemax        = 1.0;
options.keepnegsize        = 0;
options.addbias            = 1;

options.typefeat           = 2;
options.spyr               = [1 , 1 , 1 , 1 , 1 ; 1/2 , 1/2 , 1/4 , 1/4 , 1/16];
options.scale              = [1];
options.maptable           = 0;
options.cs_opt             = 1;
options.improvedLBP        = 1;
options.rmextremebins      = 0;
options.color              = 0;
options.norm               = [4 , 2 , 0];
options.clamp              = 0.2;
options.n                  = 0;
options.L                  = 1.2;
options.kerneltype         = 0;
options.numsubdiv          = 8;
options.minexponent        = -20;
options.maxexponent        = 8;

options.posresize          = 1;
options.negresize          = 1;

options.dimsItraining      = [40 , 40];

options.rect_param         = [1 1 2 2;1 1 2 2;2 2 1 1;2 2 2 2;1 2 1 2;0 0 0 1;0 1 0 0;1 1 1 1;1 1 1 1;1 -1 -1 1];
options.usesingle          = 1;
options.transpose          = 0;

options.typeclassifier     = 2;
options.s                  = 2;
options.B                  = 0;
options.c                  = 10;
options.useweight          = 1;
options.T                  = 50;

options.num_threads        = -1;
options.dimsIscan          = [40 , 40];
options.scalingbox         = [1.2 , 1.4 , 1.8];
options.mergingbox         = [1/2 , 1/2 , 1/3];
options.max_detections     = 50000;

[options , model]          = train_model(options);


options.perftest

figure(1)
plot(options.fpp , options.tpp  , 'b', 'linewidth' , 2)
grid on
title(sprintf('Accuracy = %4.3f, AUC = %4.3f' , options.perftest , options.auc_est))
axis([-0.02 , 0.3 , 0.75 , 1.02])

figure(2)
plot(model.w)
title(sprintf('weights w trained by SVM'))

figure(3)
plot(options.fxtest)
title(sprintf('f(x) for test set'))


figure(4)
plot(options.fpp , options.tpp  , 'linewidth' , 2)
axis([-0.02 , 1.02 , -0.02 , 1.02])
%legend('Cascade' , 'MultiExit', 'Full', 'Location' , 'SouthEast')
grid on
title(sprintf('ROC for HMBLBP + Linear SVM'))

aa                         = rgb2gray(imread('D:\Utilisateurs\SeBy\matlab\fdtool_release\images\boats\test\positives\MGC PACIFIC MERMAID.jpg'));
aa                         = imresize(aa , options.dimsItraining);
[fx , y , H]               = eval_hmblbp_spyr_subwindow(aa , model);


aa                         = rgb2gray(imread('D:\Utilisateurs\SeBy\matlab\fdtool_release\images\boats\test\negatives\prob2 (1).jpg'));
aa                         = imresize(aa , options.dimsItraining);
[fx , y , H]               = eval_hmblbp_spyr_subwindow(aa , model);


aa                         = rgb2gray(imread('D:\Utilisateurs\SeBy\matlab\fdtool_release\images\boats\test\negatives\prob2 (4).jpg'));
pos                        = detector_mlhmslbp_spyr(aa , model);

figure(5)
min_detect                 = 150;%120;
imagesc(aa);
colormap(gray)
hold on
h                          = plot_rectangle(pos(: , (pos(4 , :) >=min_detect)) , 'g' );
hold off
%title(sprintf('Fps = %6.3f      (Press CRTL+C to stop)' , 1/t2));
drawnow;




aa                         = rgb2gray(imread('D:\Utilisateurs\SeBy\matlab\fdtool_release\images\boats\test\negatives\prob3 (3).jpg'));
pos                        = detector_mlhmslbp_spyr(aa , model);

figure(6)
min_detect                 = 100;%120;
imagesc(aa);
colormap(gray)
hold on
h                          = plot_rectangle(pos(: , (pos(4 , :) >=min_detect)) , 'g' );
hold off
%title(sprintf('Fps = %6.3f      (Press CRTL+C to stop)' , 1/t2));
drawnow;



% figure(4)
% semilogy(1:options.boost_ite , options.pd_per_stage , 1:options.boost_ite , options.pfa_per_stage , 'linewidth' , 2)
% legend('P_d' , 'P_{fa}' , 'location' , 'southwest')
% 
% aa                       = vcapg2(0,3);
% min_detect               = 2;%120;
% figure(5);set(1,'doublebuffer','on');
% while(1)
%     t1   = tic;
%     aa   = vcapg2(0,0);
%     pos  = detector_mlhmslbp_spyr(rgb2gray(aa) , model);
%     image(aa);
%     hold on
%     h    = plot_rectangle(pos(: , (pos(4 , :) >=min_detect)) , 'g' );
%     hold off
%     t2   = toc(t1);
%     title(sprintf('Fps = %6.3f      (Press CRTL+C to stop)' , 1/t2));
%     drawnow;
% end