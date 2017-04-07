%% main results
%% With one user per cell (no intercell interference since the users in the
% same cell will use orthogonal pilots). We will see the difference between
% the MSE of the system with and without beamforming.

clear all

Nrealizations = 1;
Nmax = 10; % Maximum number of antennas per terminal in the simulation
SNR = 5; % value of the fixed SNR in dB (power of noise = 1)

p = 10^(SNR/10); % power of the pilots for the desired SNR 

M = 100; % number of antennas at the BS
K = 1; % Number of users per BS
%N = [1:2:Nmax]; % Number of antennas per User
N = [4 10 20 1000];
Radius = 500; % Radius of the cells (in m)
nrBS = 7; % Number of BS
beamform = 1; % if beamform = 0, w = [1; 1;], i.e., there is no beamforming at the user
% generate users (SystemPlot)
% generate one tier (7 BS) with one user per BS. The radius of the BS is
% 500 m
Distances = SystemPlot(nrBS,K,Radius);
betas = 1./(Distances.^(3.8)); % loss factor

%%
angularSpread = 10; % 10�
for i=1:nrBS*K*nrBS
    %h(:,:,i,r) = (sqrt(2)./2)*(randn(M,N(na))+1i*randn(M,N(na)));
    theta = rand*pi; % angle of arrival (uniformly distributed between 0 and pi)
    R(:,:,i) = functionOneRingModel(M,angularSpread,theta);
end
meanMSEb = zeros(nrBS,length(N));
meanMSEnb = zeros(nrBS,length(N));
for na = 1:length(N)% For all the different values of antennas at the user
    wb = zeros(N(na),K*nrBS);
    wnb = zeros(N(na),K*nrBS);
    Ru = zeros(N(na),N(na),nrBS*K*nrBS);
    eigenVect = zeros(N(na),N(na),K*nrBS*nrBS);
    eigenVal = zeros(N(na),N(na),K*nrBS*nrBS);
    Rk_b = zeros(N(na),N(na),K*nrBS);
    Rk_nb = zeros(N(na),N(na),K*nrBS);
    Rkkb = zeros(M,M,K*nrBS*nrBS);
    Rkknb = zeros(M,M,K*nrBS*nrBS);
    gEff = zeros(M,K,Nrealizations);
    
    Rusqrt = zeros(N(na),N(na),nrBS*K*nrBS);
    %R = zeros(M,M,nrBS*K*nrBS,Nrealizations);
    
    for i = 1:nrBS*K*nrBS % Each user has different Ru for each BS
        theta = rand*pi; % angle of arrival (uniformly distributed between 0 and pi)
        Ru(:,:,i) = functionOneRingModel(N(na),angularSpread,theta);
        
        [V,D] = eig(Ru(:,:,i));
        
        Rusqrt(:,:,i) = V*sqrt(D)*ctranspose(V);
        
        
        
    end
    
    for n = 1:nrBS
        
        for a = 1:K
            [eigenVect(:,:,(n-1)*K+a),eigenVal(:,:,(n-1)*K+a)] = eig(Ru(:,:,(n-1)*K*nrBS+(n-1)*K + a));
            wb(:,(n-1)*K+a) = eigenVect(:,end,(n-1)*K+a);
            wnb(:,(n-1)*K+a) = ones(N(na),1)/sqrt(N(na)); % without beamforming
        end
        
    end
    
    
    for t = 1:nrBS
        
        for u=1:nrBS*K
            
            Rk_b(:,:,(t-1)*K*nrBS+u) = Rusqrt(:,:,(t-1)*K*nrBS+u)*wb(:,u)*ctranspose(wb(:,u))*ctranspose(Rusqrt(:,:,(t-1)*K*nrBS+u));
            Rk_nb(:,:,(t-1)*K*nrBS+u) = Rusqrt(:,:,(t-1)*K*nrBS+u)*wnb(:,u)*ctranspose(wnb(:,u))*ctranspose(Rusqrt(:,:,(t-1)*K*nrBS+u));
            
            Rkkb(:,:,(t-1)*K*nrBS+u) = R(:,:,(t-1)*K*nrBS+u)*trace(Rk_b(:,:,(t-1)*K*nrBS+u));
            Rkknb(:,:,(t-1)*K*nrBS+u) = R(:,:,(t-1)*K*nrBS+u)*trace(Rk_nb(:,:,(t-1)*K*nrBS+u));
            
        end
        
    end
    
    for r = 1:Nrealizations

        % generate the channel realizations
        % 1st matrix in h, BS1 vs UE1 antenna 1 and 2
        % 2nd matrix in h, BS1 vs UE2 antenna 1 and 2 ...
        % for each h calculate the covariance matrix (each h is one antenna from
        % the user to eacH BS)
      

%         % Obtaining the beamforming vector
%         for n = 1:nrBS 
%             theta = rand.*pi;
%             for a = 1:K
%                 %Ru(:,:,n,r) = functionOneRingModel(N(na),angularSpread,theta);
%                 [eigenVect(:,:,(n-1)*K+a,r),eigenVal(:,:,(n-1)*K+a,r)] = eig(Ru(:,:,(n-1)*K+a));
%                 wb(:,(n-1)*k+a,r) = eigenVect(:,end,(n-1)*k+a,r); % Beamforming vector
% 
%                 wnb(:,(n-1)*k+a,r) = ones(N(na),1)/sqrt(N(na)); % without Beamforming
% 
% 
%                 % creating Rkk for each user Rkk = R*trace(Ru^(1/2)*w*w^(H)*Ru^(1/2)^H)
% 
%                 Rusq = eigenVect(:,:,(n-1)*K+a,r)*sqrt(eigenVal(:,:,(n-1)*K+a,r))*ctranspose(eigenVect(:,:,(n-1)*K+a,r));% square root of Ru
% 
% 
%                 Rk_b(:,:,(n-1)*K+a,r) = Rusq*wb(:,(n-1)*K+a,r)*ctranspose(wb(:,(n-1)*K+a,r))*ctranspose(Rusq);
%                 Rk_nb(:,:,(n-1)*K+a,r) = Rusq*wnb(:,(n-1)*K+a,r)*ctranspose(wnb(:,(n-1)*K+a,r))*ctranspose(Rusq);
%                 
%                 Rkkb(:,:,(n-1)*K*nrBS+(n-1)*K + a) = R(:,:,(n-1)*K*nrBS+(n-1)*K + a)*trace(Rk_b(:,:,(n-1)*K+a,r));
%                 Rkknb(:,:,(n-1)*K*nrBS+(n-1)*K + a) = R(:,:,(n-1)*K*nrBS+(n-1)*K + a)*trace(Rk_nb(:,:,(n-1)*K+a,r));
% %                 for t = 1:nrBS % For all users vs all BS
% % 
% %                     Rkkb(:,:,(t-1)*K*nrBS + n,r) = R(:,:,(t-1)*K*nrBS + n)*trace(Rk_b(:,:,n,r));
% %                     Rkknb(:,:,(t-1)*K*nrBS + n,r) = R(:,:,(t-1)*K*nrBS + n)*trace(Rk_nb(:,:,n,r));
% % 
% %                 end
%                 
%             end
%             
%             
%         end
       
        % Calculate the MSE of the given realization
        for t=1:nrBS % for each BS, calculate the MMSE estimator of the channel

            Rsumb = sum(Rkkb(:,:,(t-1)*K*nrBS+1:(t-1)*K*nrBS+nrBS*K,r),3);
            Rsumnb = sum(Rkknb(:,:,(t-1)*K*nrBS+1:(t-1)*K*nrBS+nrBS*K,r),3);
            % index = (t-1)*K*nrBS+K*(t-1)+a
            for a=1:K
                Cb(:,:,t,a,r) = Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r) - p*Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r)*inv(p*Rsumb + eye(M))*Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r);
                Cnb(:,:,t,a,r) = Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r) - p*Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r)*inv(p*Rsumnb + eye(M))*Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r);

                %gEff(:,(t-1)*K+a,r) = h(:,:,(t-1)*K*nrBS+K*(t-1)+a,r)*w(:,(t-1)*K+a,r);
                normFactorb = trace(Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r));
                normFactornb = trace(Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a,r));
                MSEb(t,r,a,na) = trace(Cb(:,:,t,a,r))/normFactorb;
                MSEnb(t,r,a,na) = trace(Cnb(:,:,t,a,r))/normFactornb;
            end

        end

    end
    
    for a = 1:K
        meanMSEb(:,na,a) = mean(MSEb(:,:,a,na),2); % each row is the mean MSE of a BS
                                 % each column is the mean MSE for a
                                 % different number of antennas at the
                                 % users. The third dimension is the user
                                 % in the BS
        meanMSEnb(:,na,a) = mean(MSEnb(:,:,a,na),2);
    end
    
end

%% Plotting the results
for t = 1:nrBS
    for a = 1:K % for each user in the cell
        plotMeanMSE(meanMSEb,meanMSEnb,t,a,N,1) 
    end
end

 
