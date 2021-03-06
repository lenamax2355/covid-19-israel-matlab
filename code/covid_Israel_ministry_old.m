function covid_Israel_ministry_old(getHistory)
if ~exist('getHistory','var')
    getHistory = true;
end
%% משרד הבריאות
cd ~/covid-19-israel-matlab/
txt = urlread('https://govextra.gov.il/ministry-of-health/corona/corona-virus/');
iSmaller = find(ismember(txt,'<'));
i0 = findstr(txt,'נכונה ל');
i1 = findstr(txt,'בשעה');
tStr = [txt(i0+14:i1-2),' ',txt(i1+5:iSmaller(find(iSmaller > i1,1))-1)];

iDots = strfind(tStr,':');
iDot = strfind(tStr,'.');
date = datetime([2020,str2num(tStr(iDot(1)+1:iDot(2)-1)),str2num(tStr(1:iDot(1)-1)),...
    str2num(tStr(iDots-2:iDots-1)),str2num(tStr(iDots+1:iDots+2)),0]);

list = readtable('data/Israel/Israel_ministry_of_health.csv');
if ~ismember(date,list.date)
    warning off
    list.date(end+1) = date;
    warning on
    
    
    marker = {'corona-xl',41;...  % מקרים מאומתים
        '<div class="corona-md">נפטרו</div>',115;...
        '<div class="corona-md">החלימו</div>',116;...
        '>מונשמים',51;...
        'קשה<',46;...
        'בינוני<',49;...
        'קל<',45;...
        'בית חולים<',52;...
        'מלונית<',49};
    
    
    for ii = 1:size(marker,1)
        i0 = strfind(txt,marker{ii,1})+marker{ii,2};
        if ii == 1
            i0 = i0(2); % first i0 finds n tests
        else
            i0 = i0(1);
        end
        i1 = iSmaller(find(iSmaller > i0,1))-1;
        if ~strcmp(txt(i0-1),'>')
            error('before the number there should be a ">"')
        end
        
        misrad(ii,1) = str2num(strrep(txt(i0:i1),',',''));
    end
    misrad([2,3]) = misrad([3,2]);
    if misrad(7) == misrad(9)
        misrad(7) = misrad(1)-misrad(2)-misrad(3)-misrad(5)-misrad(6);
    end
    list{end,2:10} = misrad';
    list{end,end} = nan;
    nanwritetable(list);
end

if getHistory
    ext = '.xlsx';
    iLink = strfind(txt,ext);
    if isempty(iLink)
        ext = '.csv';
        iLink = strfind(txt,'.csv');
    end
    iHref = strfind(txt,'href');
    iHref = iHref(find(iHref < iLink,1,'last'));
    link = ['https://govextra.gov.il/',txt(iHref+7:iLink+(length(ext)-1))];
    
    [~,~] = system(['wget ',link]);
    movefile(link(find(ismember(link,'/'),1,'last')+1:end),['data/Israel/covid19-data-israel',ext])
    if strcmp(ext,'.csv') % remove commas
        if exist('data/Israel/tmp.csv','file')
            !rm data/Israel/tmp.csv
        end
        !awk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' data/Israel/covid19-data-israel.csv >> data/Israel/tmp.csv
        movefile('data/Israel/tmp.csv','data/Israel/covid19-data-israel.csv')
    end
end
