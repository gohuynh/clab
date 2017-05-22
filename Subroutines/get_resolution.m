function cardResolution = get_resolution(dev)
%% get_resolution(dev)
% Used to find card resolution based off of daq model
% Written By: Gordon Huynh
% Last Updated: July 21, 2016
%
% INPUTS
%   dev: array of daq devices detected
% OUTPUTS
%   cardResolution: integer of daq card resolution
% ADDITIONAL COMMENTS
%   To add additional models, apend exact model name to active_daqs and
%   apend corresponding resolution to resolutions

%%
model = dev(1).Model;
cardResolution = [];
active_daqs = {'PCI-6052E' 'PCI-6132' 'PCI-6250' 'PCI-6036E' 'PCIe-6361'...
    'USB-6356'};
resolutions = {16 14 16 16 16 16};
for k = 1:length(active_daqs)
    if ~isempty(strfind(model,active_daqs{k}))
        cardResolution = resolutions{k};
        break
    end
end
% If unknown card, asks user to manually input card's resolution
if isempty(cardResolution)
    cardResolution = inputdlg('Unknown Model, Please enter card resolution:','Input');
    cardResolution = str2num(cardResolution{1});
end