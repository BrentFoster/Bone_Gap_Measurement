function enableWL(hfig)
if nargin<1
	hfig=gcf;
end
G=get(hfig,'userdata');
G.oldWBMFcn = get(hfig,'WindowButtonMotionFcn');
set(hfig,'userdata',G);

set(hfig,'WindowButtonDownFcn',@WBDFcn);
set(hfig,'WindowButtonUpFcn',@WBUFcn);


function WBDFcn(varargin)
fh=varargin{1};
if ~strcmp(get(fh,'SelectionType'),'normal')
    set(fh, 'WindowButtonMotionFcn',@AdjWL);
    G=get(fh,'userdata');

    G.initpnt=get(gca,'currentpoint');
    G.initClim = get(gca,'Clim');
    set (fh,'userdata',G);
end
    
function WBUFcn(varargin)
fh=varargin{1};
if ~strcmp(get(gcf,'SelectionType'),'normal')
G=get(fh,'userdata');

set(fh,'WindowButtonMotionFcn',G.oldWBMFcn);
end


function AdjWL(varargin)
fh=varargin{1};
G=get(fh,'userdata');
G.cp=get(gca,'currentpoint');
G.x=G.cp(1,1);
G.y=G.cp(1,2);
G.xinit = G.initpnt(1,1);
G.yinit = G.initpnt(1,2);
G.dx = G.x-G.xinit;
G.dy = G.y-G.yinit;
G.clim = G.initClim+G.initClim(2).*[G.dx G.dy]./128;
try
    switch get(fh,'SelectionType')
        case 'extend' % Mid-button, shft+left button,
%             'extend'
        set(findobj(fh,'Type','axes'),'Clim',G.clim);
        case 'alt' %right-click,ctrl+left button,
%             'alt'
        set(gca,'Clim',G.clim);
    end;
end;
