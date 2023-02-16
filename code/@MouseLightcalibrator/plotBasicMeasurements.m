% Method that puts up a plot of the essential data
function plotBasicMeasurements(obj)
    cal = obj.cal;
    
    close all
    
    figure(1); clf;
    hold on
    for ii=1:size(cal.processedData.P_device,2)
    plot(SToWls(cal.rawData.S), cal.processedData.P_device(:,ii),'-');
    end
    xlabel('Wavelength (nm)', 'Fontweight', 'bold');
    ylabel('Power', 'Fontweight', 'bold');
    title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    axis([380, 780, -Inf, Inf]);
    drawnow;

    figure(2); clf;
    hold on
    for ii=1:size(cal.processedData.P_device,2)
    plot(cal.rawData.gammaInput, cal.rawData.gammaTable(:,ii), '+');
    end
    xlabel('Input value', 'Fontweight', 'bold');
    ylabel('Normalized output', 'Fontweight', 'bold');
    title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
    for ii=1:size(cal.processedData.P_device,2)
    plot(cal.processedData.gammaInput, cal.processedData.gammaTable(:,ii), '-');
    end
    
    hold off
    drawnow;
end
