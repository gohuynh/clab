function write_config(handles, psd_info)
config.sampRateMenu = get(handles.sampRateMenu,'Value');
config.IRIGtimeMenu = get(handles.IRIGtimeMenu,'Value');
config.latMagText = get(handles.latMagText,'String');
config.longMagText = get(handles.longMagText,'String');
config.latMenu = get(handles.latMenu,'Value');
config.longMenu = get(handles.longMenu,'Value');
config.IRIGtypeMenu = get(handles.IRIGtypeMenu,'Value');
config.sensorMenu = get(handles.sensorMenu,'Value');
config.statNameMenu = get(handles.statNameMenu,'Value');
config.footerText = get(handles.footerText,'String');
config.fileSizeTypeMenu = get(handles.fileSizeTypeMenu,'Value');
config.pn = psd_info.pn
config.memQuantText = get(handles.memQuantText,'String');
config.ai1Box = get(handles.ai1Box,'Value');
config.ai2Box = get(handles.ai2Box,'Value');
config.ai3Box = get(handles.ai3Box,'Value');
config.ai4Box = get(handles.ai4Box,'Value');
config.ai5Box = get(handles.ai5Box,'Value');
config.ai6Box = get(handles.ai6Box,'Value');
config.ai7Box = get(handles.ai7Box,'Value');
config.plotBox = get(handles.plotBox,'Value');
config.fig1Menu = get(handles.fig1Menu,'Value');
config.fig2Menu = get(handles.fig2Menu,'Value');
config.ylowText = get(handles.ylowText,'String');
config.yhighText = get(handles.yhighText,'String');
save('config.mat','config');