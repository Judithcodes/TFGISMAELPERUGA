%% main
clear all

M = 100; % number of antennas at the BS
K = 1; % Number of users per BS
antennasPerUser = 1;
Radius = 500; % Radius of the cells (in m)
nrBS = 7; % Number of BS

% generate users (SystemPlot)
% generate one tier (7 BS) with one user per BS. The radius of the BS is
% 500 m
Distances = SystemPlot(nrBS,K,Radius);
betas = 1./(Distances.^(3.8)); % loss factor

% generate the channel realizations (7 cells, 1 user per cell, 2 antennas
% per user) 98 h (each user in the system, 7, vs each BS, 7, and every user
% has 2 antennas, 7*7*2)

% 1st row in h, BS1 vs UE1,1st antenna
% 2nd row in h, BS1 vs UE1,2nd antenna
% 3rd row in h, BS1 vs UE2,1st antenna...
for i=1:nrBS*K*antennasPerUser*nrBS
    h(i,:) = (sqrt(2)./2)*(randn(M,K)+1i*randn(M,K));
end

% for each h calculate the covariance matrix (each h is one antenna from
% the user to eacH BS)
angularSpread = 10; % 10�
R = zeros(M,M,nrBS*K*antennasPerUser*nrBS/antennasPerUser);
for n=1:nrBS*K*antennasPerUser*nrBS/antennasPerUser
    theta = rand*pi; % angle of arrival (uniformly distributed between 0 and pi)
    R(:,:,n) = functionOneRingModel(M,angularSpread,theta);
    % generate the g's
    for i=1:antennasPerUser
        g(antennasPerUser*(n-1)+i,:) = h(antennasPerUser*(n-1)+i,:)*sqrt(R(:,:,n));
    end
    
    
end
%g = g';
%%
% generate the receive signals y (7 receive signals, one for each BS)
% we have L base stations and K*L total users (number of BS times the
% number of users per BS)

p = Radius^(1.8); % power of the pilots (0 dB of received power at the cell edge)
p = linspace(1,Radius^(1.8),500);
%noisePower = linspace(20*p,0,500); The power of the noise is constant
%received = receivedSignal(p,nrBS,K,M,noisePower,g,antennasPerUser,betas);
realizations = 1;
for m=1:realizations
    for r=1:length(p) % I'm using the same system for all the different SNR, is it correct?
        received(:,:,r,m) = receivedSignal(p(r),nrBS,K,M,1,g,antennasPerUser,betas);
    end
end
%%
% do the MMSE

GMMSE = zeros(nrBS,M,length(p),K,realizations);
for m=1:realizations
    if(mod(m,10) == 0)
        m
    end
    for r=1:length(p)% all the realizations (different SNR)

        for t=1:nrBS % for each BS, calculate the MMSE estimator of the channel

            Rsum = sum(R(:,:,(t-1)*K*nrBS+1:(t-1)*K*nrBS+nrBS*K),3);
            
            % ATENTO AL 1 ANTES DE LA r Y DESPUES DE LA m!!
            GMMSE(t,:,r,1,m) = received(t,:,r,m)*R(:,:,(t-1)*K*nrBS+t)*inv(p(r)*Rsum + eye(M));
           
            MSEH(t,r,m) = immse(GMMSE(t,:,r,1,m),h((t-1)*K*nrBS+t,:));
                        
            C(:,:,t) = R(:,:,(t-1)*K*nrBS+t) - p(r)*R(:,:,(t-1)*K*nrBS+t)*inv(p(r)*Rsum + eye(M))*R(:,:,(t-1)*K*nrBS+t);
            
            if(t==5)
               inverse = inv(p(r)*Rsum + eye(M)); 
            end
            
            MSE(t,r) = trace(C(:,:,t));
        
        end

    end

end
%MSEGmean = mean(MSEG,3);
%MSEHmean = mean(MSEH,3);
%MSEHmean = mean(MSEH,3);
%%
figure;
plot(abs(MSE(1,:)));

figure;
plot(abs(MSE(2,:)));

figure;
plot(abs(MSE(3,:)));

figure;
plot(abs(MSE(4,:)));

figure;
plot(abs(MSE(5,:)));

figure;
plot(abs(MSE(6,:)));

figure;
plot(abs(MSE(7,:)));

%% 
figure;
plot(MSEH(1,:))

figure;
plot(MSEH(2,:))
figure;
plot(MSEH(3,:))

figure;
plot(MSEH(4,:))

figure;
plot(MSEH(5,:))

figure;
plot(MSEH(6,:))

figure;
plot(MSEH(7,:))
%%
figure;
hold on
for i=1:size(MSEHmean,1)
   plot(MSEHmean(i,:)); 
end
legend('MSE in BS1','MSE in BS2','MSE in BS3','MSE in BS4','MSE in BS5','MSE in BS6','MSE in BS7')












