function [parsedResults,extras] = google_scholar_getMoreResults(url_link_text)
%JAH TODO: Document function
%
%


[web_page_text,extras] = urlread2(url_link_text);
[parsedResults,extras] = google_scholar_parseResults(web_page_text,extras.url,options);
