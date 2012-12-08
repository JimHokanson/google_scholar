function [parsedResults,extras] = google_scholar_getNResults(formStruct,N_MAX,options)
%
%
%
%

%At this point break this into a function with N_MAX explicitly specified
[web_page_text,extras] = form_submit(formStruct);

RESULTS_PER_PAGE = 10;

N_MAX_LOCAL = 1000;

if N_MAX > N_MAX_LOCAL
   %Might allow with some built in speed penalty
    error('Sorry Jim, I can''t retrieve that many citations for you')
end

%Retrieval of the first set of results
[parsedResults,extras] = google_scholar_parseResults(web_page_text,extras.url,options);

nAvailable = extras.resultInfo.outOf;

if nAvailable < N_MAX
    N_MAX = nAvaible;
end

resultsPerPage = extras.resultInfo.last - extras.resultInfo.first + 1;

nPages = ceil(N_MAX/resultsPerPage);

%Initialization
parsedResults(N_MAX) = parsedResults(1);

nextLink = extras.pageInfo.nextLink;
curLastIndex = resultsPerPage;
for iPage = 2:nPages
   curStartIndex = curLastIndex + 1;
   [web_page_text,extrasURL] = urlread2(nextLink);
   [parsedResults,extras] = google_scholar_parseResults(web_page_text,nextLink,options);
   
   if iPage == nPages
       curLastIndex = N_MAX;
       nGet = N_MAX - curStartIndex + 1;
       parsedResults(curStartIndex:curLastIndex) = parsedResults(1:nGet);
   else
       curLastIndex = curStartIndex + resultsPerPage - 1;
       parsedResults(curStartIndex:curLastIndex) = parsedResults;
       nextLink = extras.pageInfo.nextLink; 
       %Should check if nextLink is good or not
   end
end