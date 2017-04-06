%% main results
%% With one user per cell (no intercell interference since the users in the
% same cell will use orthogonal pilots. We will see the MSE of a system
% for a fixed SNR changing the number of antennas (N) at the terminals. 
% We will use the Montecarlo methode over different R

clear all

Nrealizations = 5;
Nmax = 10; % Maximum number of antennas per terminal in the simulation
SNR = 5; % value of the fixed SNR in dB (power of noise = 1)

p = 10^(SNR/10); % power of the pilots for the desired SNR 

M = 100; % number of antennas at the BS
K = 1; % Number of users per BS
%N = [1:2:Nmax]; % Number of antennas per User
N = [1 4];
Radius = 500; % Radius of the cells (in m)
nrBS = 7; % Number of BS
beamform = 0; % if beamform = 0, w = [1; 1;], i.e., there is no beamforming at the user
% generate users (SystemPlot)
% generate one tier (7 BS) with one user per BS. The radius of the BS is
% 500 m
Distances = SystemPlot(nrBS,K,Radius);
betas = 1./(Distances.^(3.8)); % loss factor

%%
meanMSE = zeros(nrBS,length(N));
for na = 1:length(N)% For all the different values of antennas at the user
    h = zeros(M,N(na),nrBS*K*nrBS,Nrealizations);
    g = zeros(M,N(na),nrBS*K*nrBS,Nrealizations);
    w = zeros(N(na),K*nrBS,Nrealizations);
    Ru = zeros(N(na),N(na),Nrealizations);
    eigenVect = zeros(N(na),N(na),K*nrBS,Nrealizations);
    eigenVal = zeros(N(na),N(na),K*nrBS,Nrealizations);
    Rk_ = zeros(N(na),N(na),K*nrBS,Nrealizations);
    Rkk = zeros(M,M,K*nrBS,Nrealizations);
    gEff = zeros(M,K,Nrealizations);
    
    
    for r = 1:Nrealizations

        % generate the channel realizations
        % 1st matrix in h, BS1 vs UE1 antenna 1 and 2
        % 2nd matrix in h, BS1 vs UE2 antenna 1 and 2 ...
        for i=1:nrBS*K*nrBS
            h(:,:,i,r) = (sqrt(2)./2)*(randn(M,N(na))+1i*randn(M,N(na)));
        end

        % for each h calculate the covariance matrix (each h is one antenna from
        % the user to eacH BS)
        angularSpread = 10; % 10�
        R = zeros(M,M,nrBS*K*N(na)*nrBS/N(na),Nrealizations);
        for n=1:nrBS*K*N(na)*nrBS/N(na)
            theta = rand*pi; % angle of arrival (uniformly distributed between 0 and pi)
            R(:,:,n,r) = functionOneRingModel(M,angularSpread,theta);
            % generate the g's
        %     for i=1:antennasPerUser
        %         g(:,:,antennasPerUser*(n-1)+i) = sqrt(R(:,:,n))*h(:,:,antennasPerUser*(n-1)+i);
        %     end


        end

        % Obtaining the beamforming vector
        for n = 1:K*nrBS % for each user, one Ru
            theta = rand.*pi;

            Ru(:,:,n,r) = functionOneRingModel(N(na),angularSpread,theta);
            [eigenVect(:,:,n,r),eigenVal(:,:,n,r)] = eig(Ru(:,:,n,r));
            w(:,n,r) = eigenVect(:,end,n,r);
            if beamform == 0
                w(:,n,r) = ones(N(na),1);
            end
        end

        % generating the g's
        count = 0;
        a = 0;
        for n=1:nrBS*K*nrBS


            user = mod(n,K*nrBS);
            if user == 0
                user = K*nrBS;
            end
            g(:,:,n,r) = sqrt(R(:,:,n,r))*h(:,:,n,r)*sqrt(Ru(:,:,user,r)); 


        end

        % creating Rkk for each user Rkk = R*trace(Ru^(1/2)*w*w^(H)*Ru^(1/2)^H)
        for u = 1:nrBS*K % For all the users
            
            Rk_(:,:,u,r) = sqrt(Ru(:,:,u,r))*w(:,u,r)*ctranspose(w(:,u,r))*sqrt(ctranspose(Ru(:,:,u,r)));

            for t = 1:nrBS % For all users vs all BS

                Rkk(:,:,(t-1)*K*nrBS + u,r) = R(:,:,(t-1)*K*nrBS + u,r)*trace(Rk_(:,:,u,r));

            end

        end
        
        
        
        % Calculate the MSE of the given realization
        for t=1:nrBS % for each BS, calculate the MMSE estimator of the channel

            Rsum = sum(Rkk(:,:,(t-1)*K*nrBS+1:(t-1)*K*nrBS+nrBS*K,r),3);

            % index = (t-1)*K*nrBS+K*(t-1)+a
            for a=1:K
                C(:,:,t,a,r) = Rkk(:,:,(t-1)*K*nrBS+K*(t-1)+a,r) - p*Rkk(:,:,(t-1)*K*nrBS+K*(t-1)+a,r)*inv(p*Rsum + eye(M))*Rkk(:,:,(t-1)*K*nrBS+K*(t-1)+a,r);
                gEff(:,(t-1)*K+a,r) = h(:,:,(t-1)*K*nrBS+K*(t-1)+a,r)*w(:,(t-1)*K+a,r);
                normFactor = trace(Rkk(:,:,(t-1)*K*nrBS+K*(t-1)+a,r));
                MSE(t,r,a) = trace(C(:,:,t,a,r))/normFactor;
            end

        end

    end
    
    for a = 1:K
        meanMSE(:,na,a) = mean(MSE(:,:,a),2); % each row is the mean MSE of a BS
                                 % each column is the mean MSE for a
                                 % different number of antennas at the
                                 % users. The third dimension is the user
                                 % in the BS
    end
    
end

%% Plotting the results

 

%% creating Rkk for each user Rkk = R*trace(Ru^(1/2)*w*w^(H)*Ru^(1/2)^H)
% u = 1;
% for t = 1:nrBS
%     for a = 1:K
%         Rk_ = sqrt(Ru(:,:,u))*w(:,u)*ctranspose(w(:,u))*sqrt(ctranspose(Ru(:,:,u)));
%         Rkk(:,:,u) =  R(:,:,(t-1)*K*nrBS+(t-1)*K+a)*trace(Rk_);
%         u = u+1;
%     end
%     
% end



% THIS IS THE SAME AS DE LAST CODE ABOVE

% for t = 1:nrBS
%         Rk_ = sqrt(Ru(:,:,u))*w(:,u)*ctranspose(w(:,u))*sqrt(ctranspose(Ru(:,:,u)));
%     
%         Rkk2(:,:,(t-1)*K*nrBS + 1:(t-1)*K*nrBS + nrBS*K) = R(:,:,(t-1)*K*nrBS + 1:(t-1)*K*nrBS + nrBS*K)*trace(Rk_);
%  end


%%
% generate the receive signals y (7 receive signals, one for each BS)
% we have L base stations and K*L total users (number of BS times the
% number of users per BS)

% p = Radius^(1.8); % power of the pilots (0 dB of received power at the cell edge)
% p = linspace(1,Radius^(1.8),500);
% %noisePower = linspace(20*p,0,500); The power of the noise is constant
% %received = receivedSignal(p,nrBS,K,M,noisePower,g,antennasPerUser,betas);
% realizations = 1;
% for m=1:realizations
%     for r=1:length(p) % I'm using the same system for all the different SNR, is it correct?
%         received(:,:,r,m) = receivedSignal2(p(r),nrBS,K,M,1,g,N,betas);
%     end
% end
%%
% do the MMSE

GMMSE = zeros(nrBS,M,length(p),K,realizations);
for m=1:realizations
    if(mod(m,10) == 0)
        m
    end
    

end

%%
for t=1:nrBS
    for u=1:K
        plotMSE(MSE,t,u,p);
    end
end