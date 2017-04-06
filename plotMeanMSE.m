function plotMeanMSE(meanMSEb,meanMSEnb,BS,user, N, beamform)
% This function plots the mean MSE calculated after the Montecarlo method
% meanMSE: matrix of MSE calculated
% BS: The number of the BS
% user: The user in the BS
% N: Vector of Number of antennas at the terminals

if beamform == 1
    figure;
    hold on
    plot(N,10*log10(real(meanMSEb(BS,:,user))));
    plot(N,10*log10(real(meanMSEnb(BS,:,user))));
    xlabel('N (Antennas at terminals)')
    ylabel('MSE(dB)')
    title(['MSE of BS ',num2str(BS)]);
    legend('MSE with beamforming', 'MSE without beamforming')
else
    figure;
    hold on
    plot(N,10*log10(real(meanMSEb(BS,:,user))));
    xlabel('N (Antennas at terminals)')
    ylabel('MSE(dB)')
    title(['MSE of BS ',num2str(BS)]);
end


end