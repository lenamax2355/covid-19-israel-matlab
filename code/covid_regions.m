
ita = covid_italy;
nyc = covid_nyc;

% us_county = urlread('https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv');

us_county = urlread('https://raw.githubusercontent.com/jeffcore/covid-19-usa-by-state/master/COVID-19-Deaths-USA-By-County.csv');
us_county = strrep(us_county,'-','_');
us_county = strrep(us_county,'/20,','/2020,');
fid = fopen('tmp.csv','w');
fwrite(fid,us_county);
fclose(fid);
us_county = readtable('tmp.csv');
% fips = unique(us_county.fips)
us_county(end,:) = [];
us_county(:,end) = [];
% [vmax,order] = sort(us_county{:,end},'descend');
%us_county = us_county(order,:);
!rm tmp.csv
pop = readtable('data/us_county_population.csv');

[vmax,order] = sort(us_county{:,end}./pop.population,'descend');
order(1:6) = []; % nans
ustop = us_county(order(1:20),:);
y = (us_county{order(1:20),4:end}./pop.population(order(1:20)))'*10^6;
figure;
h = plot(y);
for ii = 1:10
    text(length(y)-ii*3,y(end-ii*3,ii),...
        [us_county.state{order(ii)},', ',us_county.county{order(ii)}],...
        'color',h(ii).Color);
end
box off
grid on
set(gcf,'color','w')
xlim([50 130])
% 
% t = readtable('/media/innereye/1T/Docs/co-est2019-annres.csv');
% t(1,:) = [];
% tStr = strrep(t{:,1},' County','');
% tStr = strrep(tStr,' Parish','');
% tStr = strrep(tStr,'Miami Dade','Miami_Dade');
% county = cellfun(@(x) x(2:strfind(x,',')-1),tStr,'UniformOutput',false);
% state = cellfun(@(x) x(strfind(x,',')+2:end),t{:,1},'UniformOutput',false);
% % for ii = 1:100
% %     if contains(t{ii,1},' County')
% %         county{ii,1} = t{ii,1}(2:strfind(x,' County')-1);
% %         state{ii,1} = t{ii,1}(strfind(x,' County')+9:end);
% %     else
% population = nan(height(us_county),1);
% for ii = 1:height(us_county)
%     idx = find(ismember(state,us_county.state{ii}) & ismember(county,us_county.county{ii}));
%     if length(idx) == 1
%         num = strrep(t{idx,2},',','');
%         population(ii,1) = str2num(num{1});
%     end
% end
% tt = us_county(:,2:3);
% tt.population = population;
% writetable(tt,'data/us_county_population.csv','Delimiter',',','WriteVariableNames',true)