%% main results
%% With one user per cell (no intercell interference since the users in the
% same cell will use orthogonal pilots). We will see the difference between
% the MSE of the system with and without beamforming.

clear all

Nrealizations = 10;
Nmax = 10; % Maximum number of antennas per terminal in the simulation
SNR = 5; % value of the fixed SNR in dB (power of noise = 1)

p = 10^(SNR/10); % power of the pilots for the desired SNR 

M = 100; % number of antennas at the BS
K = 1; % Number of users per BS
%N = [1:2:Nmax]; % Number of antennas per User
N = [1 5 10 15 20];
N = [1 2 4 8];
Radius = 500; % Radius of the cells (in m)
nrBS = 7; % Number of BS
beamform = 1; % if beamform = 0, w = [1; 1;], i.e., there is no beamforming at the user
delta = 0.0001;
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
    
    %R = zeros(M,M,nrBS*K*nrBS,Nrealizations);
    
   
    
    for r = 1:Nrealizations

        for i = 1:nrBS*K*nrBS % Each user has different Ru for each BS
                theta = rand*pi; % angle of arrival (uniformly distributed between 0 and pi)
                Ru(:,:,i) = functionOneRingModel(N(na),angularSpread,theta);

                %[V,D] = eig(Ru(:,:,i));

                %Rusqrt(:,:,i) = V*sqrt(D)*ctranspose(V);
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

                Rk_b(:,:,(t-1)*K*nrBS+u) = Ru(:,:,(t-1)*K*nrBS+u)*wb(:,u)*ctranspose(wb(:,u));
                Rk_nb(:,:,(t-1)*K*nrBS+u) = Ru(:,:,(t-1)*K*nrBS+u)*wnb(:,u)*ctranspose(wnb(:,u));

                Rkkb(:,:,(t-1)*K*nrBS+u) = R(:,:,(t-1)*K*nrBS+u)*trace(Rk_b(:,:,(t-1)*K*nrBS+u));
                Rkknb(:,:,(t-1)*K*nrBS+u) = R(:,:,(t-1)*K*nrBS+u)*trace(Rk_nb(:,:,(t-1)*K*nrBS+u));

            end

        end
       
        % Calculate the MSE of the given realization
        for t=1:nrBS % for each BS, calculate the MMSE estimator of the channel

            Rsumb = sum(Rkkb(:,:,(t-1)*K*nrBS+1:(t-1)*K*nrBS+nrBS*K),3);
            Rsumnb = sum(Rkknb(:,:,(t-1)*K*nrBS+1:(t-1)*K*nrBS+nrBS*K),3);
            % index = (t-1)*K*nrBS+K*(t-1)+a
            for a=1:K
                Cb(:,:,t,a,r) = Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a) - p*Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a)/(p*Rsumb + eye(M))*Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a);
                Cnb(:,:,t,a,r) = Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a) - p*Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a)/(p*Rsumnb + eye(M))*Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a);
                
                %gEff(:,(t-1)*K+a,r) = h(:,:,(t-1)*K*nrBS+K*(t-1)+a,r)*w(:,(t-1)*K+a,r);
                normFactorb = trace(Rkkb(:,:,(t-1)*K*nrBS+K*(t-1)+a));
                normFactornb = trace(Rkknb(:,:,(t-1)*K*nrBS+K*(t-1)+a));
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
        plotMeanMSE(meanMSEb,meanMSEnb,0,t,a,N,2) 
    end
end

 
