    fig1 = figure(1);
set(fig1, 'Position', [0 0 1920 1080])
set(0, 'DefaultAxesFontName', 'Times');
set(0, 'DefaultLegendFontName', 'Times');
clf(1)
%for index=1:size(VolumePred,2)
    for index=2:size(VolumePred,2)
    clf(1)
    hold on 
    offset=index:1:size(VolumePred,2)+index-1;
    %offset=index-1:1:size(VolumePred,2)+index-2;

    plot(Volume(1:index,:)*1000) 
    %plot(offset,VolumePred(:,index)*1000,'--')
    plot(offset,VolumePred(:,index-1)*1000,'--')
    yline(c.Vmin*1000)
    yline(c.Vmax*1000)
    hold off 
    xlim([0 46]) 
    grid 
    xlabel("Time [h_a]") 
    ylabel("Water level [L]")
    title("Global controller")

    ylim([0 160])

    %% Making the gif!
    drawnow()
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if index <3  %if index <2
        imwrite(imind,cm,"gifs"+".gif",'gif','DelayTime',0.25, 'Loopcount',inf);
    else
        imwrite(imind,cm,"gifs"+".gif",'gif','DelayTime',0.25,'WriteMode','append');
    end 

        exportgraphics(fig1,"global_controller.gif", Append=true)


end 