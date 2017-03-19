function make_graph(directory,file)
    % Load the data into memory
    CL=load(['data/' directory '/CL/' file]);
    nonCL=load(['data/' directory '/nonCL/' file]);
    
    % Create a new plot window to draw on; and plot x, y, and deltaY
    % for both curriculum learning and non-curriculum learning values
    handle=figure();
    errorbar(CL(:,1),CL(:,2),CL(:,3),'x');
    hold on
    errorbar(nonCL(:,1),nonCL(:,2),nonCL(:,3),'rx');

    % Adjust the axis to fit the data tightly
    axis([CL(1,1) CL(end,1)])

    % Save the plot to disk
    saveas(handle,['graphs/' file],'png');

    %%%%%%%%%%%%%%%%%%%%%%%
    % Relative Difference %
    %%%%%%%%%%%%%%%%%%%%%%%
    x  = CL(:,1);
    x = x(2:end);
    y1 = CL(:,2);
    error1 = CL(:,3);
    y2 = nonCL(:,2);
    error2 = nonCL(:,3)

    diff = y1-y2;
    diffError = sqrt(error1.^2 + error2.^2)

    relDiff = abs(diff ./ y2);
    % Standard error propagation
    relDiffError = relDiff .* sqrt( (diffError ./ diff).^2 + (error2 ./ y2).^2)

    relDiff = relDiff(2:end); %-- Divide by zero in first element
    relDiffError = relDiffError(2:end)

    handle=figure();
    errorbar(x,relDiff,relDiffError,'x');
    hold on
    plot([x(1) x(end)],[0.3236 0.3236],'r')
    xlim([x(1) x(end)])

    % Save the plot to disk
    saveas(handle,['graphs/relative_' file],'png');

end

mkdir graphs
make_graph('TvG','TvG');
make_graph('QvT','Q_1');
make_graph('QvT','Q_2');
