%function rho = GQMP_SRM(cover)
function rho = GQMP_SRM(cover,m,n)
if nargin < 2
     m = 1.1;n = 0.8;
end
%m = 1.1;n = 0.8;

[k,l] = size(cover);
%% Get 2D quaternion filters based on KB filter
% 1D high pass decomposition filter
kb1 = [-1 2 -1];
kb2=imag(hilbert(kb1));

% construction of 2D Quaternion filters
QKB{1}=kb1'*kb1;
QKB{2}=kb2'*kb1;
QKB{3}=kb1'*kb2;
QKB{4}=kb2'*kb2;

%% Image filtering 
% add padding
padSize = max([size(QKB{1})';size(QKB{2})']);
coverPadded = padarray(double(cover), [padSize padSize], 'symmetric');   

QR = cell(1,4);
% compute residual
for fIndex=1:4
    R1 = abs(conv2(coverPadded, QKB{fIndex}, 'same'));    
%     R1 = conv2(coverPadded, QKB{fIndex}, 'same');  
    if mod(size(QKB{fIndex}, 1), 2) == 0
        R1= circshift(R1, [1, 0]); 
    end
    if mod(size(QKB{fIndex}, 2), 2) == 0
        R1 = circshift(R1, [0, 1]);
    end   
    %remove padding
    R1= R1(((size(R1, 1)-k)/2)+1:end-((size(R1, 1)-k)/2), ((size(R1, 2)-l)/2)+1:end-((size(R1, 2)-l)/2));
    QR{fIndex} = R1;
end

%% 四元数Q = A + Bi + Cj + Dk
A = QR{1};B = QR{2};C = QR{3};D = QR{4};

%% 分解Q的系数 A = M.* P 其中：P= cos(thetaA),thetaA = atan2(sqrt(B.^2+C.^2+D.^2),abs(a))
M = sqrt(A.^2+B.^2+C.^2+D.^2);% 计算幅值

P = A./(M+eps); % 计算相位，在已知A的情况下，可以简便计算

% 对相位进行聚合
L1 =  fspecial('average',[13 13]);
P= imfilter(P, L1 ,'symmetric','same');

%% 计算基于幅值和相位的失真代价
rhoM = 1./(M+10^(-10));% 计算幅值对应的失真代价
rhoM(rhoM>1)=1;
% 对rho进行聚合
L2 =  fspecial('average',[13 13]);
rhoM = imfilter(rhoM, L2 ,'symmetric','same');

rhoP = 1./(P+10^(-10));% 计算相位对应的失真代价

%计算总失真代价
rho = (rhoM.^m) .* (rhoP.^n);

end
