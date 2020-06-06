readTimna = false;
cd ~/covid-19_data_analysis/
t = readtable('data/Israel/covid19-data-israel.csv');
%;[t{end,1}+1:datetime('today')]']; %#ok<NBRAK>

todayPos = [13;nan;4;10;14;32;24;64;101;14;53;72;67;47;65;58];
yesterdayTests = [5969;nan;5010;2266;3605;5198;6606;6432;5312;1825;1012;7952;5423;11606;12929;16160];
todayTests = [3203;nan;579;704;2580;3999;4007;4182;1403;671;2874;6664;5636;7217;9258;7648];
totalPos = [16683;nan;16712;16717;16734;16757;16793;16872;16987;17012;17071;17169;17285;17337;17495;17752];
yesterdayPos = totalPos-todayPos;
% chartTests = [6023;4999;704;3621;5244;6791;6633;5324;1825;1012;2874];
% chartPercentNew = [0.3;0.4;0.6;0.4;0.4;0.7;0.6;1.4;6.2;2.8;1.8];
telegram = table([datetime('21-May-2020'):datetime('21-May-2020')+length(yesterdayPos)-1]',...
    [yesterdayTests(2:end);todayTests(end)],...
    [diff(yesterdayPos);todayPos(end)]);  % ,chartTests,chartPercentNew);
% telegram = telegramAll(:,1);
% telegram.tests = chartTests;
% telegram.new = [diff(yesterdayPos);todayPos(end)];
telegram.Properties.VariableNames = {'date','tests','new'};


date = t{2:end,1};
tests = t{2:end,2} - t{1:end-1,2};
new = t{2:end,6} - t{1:end-1,6};
tt = table(date,tests,new);
tt = [tt;telegram(~ismember(telegram.date,tt.date),:)];
%tt.new(tt.new < 0) = 0;
tt.newPer = 100*tt.new./tt.tests;
titles = {'tests','new cases','percent positive tests'};
yla = {'tests','positive','positive (%)'};
%%
figure;
for ii = 1:3
    subplot(3,1,ii)
    plot(tt.date,tt{:,ii+1});
    set(gca,'XTick',tt.date(6:7:end),'fontsize',13)
    xlim(tt.date([34,end])+1)
    box off
    grid on
    title(titles{ii});
    ylabel(yla{ii});
    xtickangle(30)
    switch ii
        case 1
            ylim([0 15000])
        case 3
            set(gca,'YTick',0:2:10)
    end
end

%%
if readTimna
    clear tests
    json = urlread('https://data.gov.il/api/action/datastore_search?resource_id=dcf999c1-d394-4b57-a5e0-9d014a62e046&limit=100000000');
    % json = urlread('https://data.gov.il/api/action/datastore_search?resource_id=dcf999c1-d394-4b57-a5e0-9d014a62e046&limit=100000000');
    struc = jsondecode(json);
    dateCell = {struc.result.records(:).result_date}';
    dateU = unique(dateCell);
    date = cellfun(@(x) datetime(x,'InputFormat','yyyy-MM-dd'),dateU);
    isFirst = ismember({struc.result.records(:).is_first_test}','Yes');
    posAll = contains({struc.result.records(:).corona_result}','חיובי');
    negAll = ismember({struc.result.records(:).corona_result}','שלילי');
    
    for iDate = 1:length(date)
        isToday = ismember(dateCell,dateU{iDate});
        positive(iDate,1) = sum(isToday & isFirst & posAll);
        negative(iDate,1) = sum(isToday & isFirst & negAll);
        first_tests(iDate,1) = sum(isToday & isFirst);
        tests(iDate,1) = sum(isToday);
    end
    %
    t = table(date,tests,first_tests,positive,negative);
    no_results = t.first_tests - t.positive - t.negative;
    reccurent = t.tests - t.first_tests;
    figure;
    h = bar(t.date,[t.negative,t.positive,no_results,reccurent],1,'stack','linestyle','none');
    legend('negative','positive','no results','recurrent test')
    h(2).FaceColor = [1,0,0];
end
% % what happened on apr-26?
% apr26 = datetime('26-Apr-2020');
% isToday = ismember(dateCell,apr26);
% lab26 = sort(cellfun(@str2num, unique({struc.result.records(isToday).lab_id}')));
% isToday = ismember(dateCell,apr26-1);
% lab25 = sort(cellfun(@str2num, unique({struc.result.records(isToday).lab_id}')));
% % lab 33 is missing from 26-Apr, but there are only 43 tests, not a big
% % deal
% sum(ismember(dateCell,apr26-1) & ismember({struc.result.records(:).lab_id}','33'))