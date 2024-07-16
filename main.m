clc; clear all;

params = 438; % the secret key 
WET = single(1e14);% STC wet cost
H=0; % Choose H=0 for optimal simulator. 
% load cover image
coverPath = fullfile('.\', 'cover_pgm', '1013.pgm');
% set payload
payload = single(0.2);
cover = imread(coverPath);
figure,imshow(cover,'border','tight','initialmagnification','fit')
set (gcf,'Position',[0,0,512,512]);

fprintf('Embedding using Matlab file');

MEXstart = tic;

%% Run default embedding
rho = QMP(cover);
MEXend = toc(MEXstart);

%% Embedding simulator
[stego,Pchange] = f_embedding(cover, rho, payload, H,params,WET);

average_Pchange=mean(Pchange(:))
max_Pchange=max(Pchange(:))
std_Pchange=std(Pchange(:))
figure
hist(Pchange(:), 0:0.01:0.8);set(gca,'YTick',0:1000:8000);axis([0.05 0.8 0 8000]);title('Histogram of change rate')
fprintf(' - DONE');
figure
imshow(1-Pchange);title('change rate')

% figure;
% imshow((double(stego) - double(cover) + 1)/2); title('embedding changes: +1 = white, -1 = black');
figure,imshow((double(stego) - double(cover) + 1)/2,'border','tight','initialmagnification','fit')
set (gcf,'Position',[0,0,512,512]);
fprintf('\n\nImage embedded in %.2f seconds, change rate: %.4f', MEXend, sum(cover(:)~=stego(:))/numel(cover));


