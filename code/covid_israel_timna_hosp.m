function covid_israel_timna_hosp(plt)
if ~exist(plt,'var')
    plt = false;
end
cd ~/covid-19_data_analysis/

json = urlread('https://data.gov.il/api/action/datastore_search?resource_id=e4bf0ab8-ec88-4f9b-8669-f2cc78273edd');
fid = fopen('data/Israel/corona_hospitalization_ver_001.json','w');
fwrite(fid,json);
fclose(fid);

json = strrep(json,'NULL','0');
json = strrep(json,'<15','0');
struc = jsondecode(json);

recordsCell = struct2cell(struc.result.records)';
date = datetime(recordsCell(:,2));
records = table(date);
varName = {'hospitalized','hosp_female_percent','hosp_age_mean','hosp_age_sd',...
    'on_ventilator','vent_female_percent','vent_age_mean','vent_age_sd',...
    'mild','mild_female_percent','mild_age_mean','mild_age_sd',...
    'severe','severe_female_percent','severe_age_mean','severe_age_sd',...
    'critical','crit_female_percent','crit_age_mean','crit_age_sd'};
for ii = 1:length(varName)
    eval(['records.',varName{ii},' = cellfun(@str2num,recordsCell(:,ii+2));'])
    eval(['records.',varName{ii},'(records.',varName{ii},' == 0) = nan;']);
end
nanwritetable(records,'data/Israel/corona_hospitalization_ver_001.csv');
if plt
    figure;
    plot(records.date,records.mild_female_percent)
    hold on
    plot(records.date,records.hosp_female_percent)
    plot(records.date,records.severe_female_percent)
    plot(records.date,records.crit_female_percent)
    legend('mild','hospitalized','severe','critical')
end

% list = readtable('~/covid-19_data_analysis/data/Israel/Israel_ministry_of_health.csv');
% 
% figure;
% idx = ~isnan(list.on_ventilator);
% plot(list.date(idx),list.on_ventilator(idx),'r')
% hold on
% v =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.on_ventilator);
% plot(t.date,v,'g')
% figure;
% idx = ~isnan(list.critical);
% plot(list.date(idx),list.critical(idx),'r')
% hold on
% c =  cellfun(@(x) str2num(strrep(x,'<15','0')),t.critical);
% plot(t.date,c,'g')
% figure;
% idx = ~isnan(list.severe);
% plot(list.date(idx),list.severe(idx),'r')
% hold on
% plot(t.date,cellfun(@(x) str2num(strrep(strrep(x,'NULL','0'),'<15','0')),t.severe),'g')
% figure;
% 
% 
% for ii = 1:length(t.Properties.VariableNames)
%     if is