function [parsedResults,extras] = google_scholar_simpleSearch(searchText,varargin)
%google_scholar_simpleSearch  Searches Google Scholar using searchText
%
%   web_str = google_scholar_simpleSearch(searchText,varargin)
%
%   OUTPUTS
%   =======================================================================
%   parseResults
%   extras : (structure), see google_scholar_parseResults
%       .max_limit_used - specifies whether or not 
%
%   INPUTS
%   =======================================================================
%   searchText: What you would enter into the search bar
%   
%   OPTIONAL INPUTS (key,value pairs or struct)
%   =======================================================================
%   GET_ARTICLES    : (default true), if false, gets legal opinions and journals
%   INCLUDE_PATENTS : (default false), if true, also returns patents
%   GET_CITATIONS   : (default false), if true retrieves the citation
%                     information as well
%   CITATION_FORMAT : (default 'Bibtex'), format in which Google Scholar
%                     returns the data
%   N_MAX           : (default 100), maximum # of results to return
%
%   USAGE EXAMPLES
%   =======================================================================
%   JAH TODO: Finish documentation and implement N_MAX
%
%   See Also:
%   google_scholar_parseResults


%MLINT
%================
%#ok<*NASGU> %unused
%#ok<*UNRCH> %unreachable

DEFINE_CONSTANTS
GET_ARTICLES    = true;
INCLUDE_PATENTS = false;
GET_CITATIONS   = false; 
CITATION_FORMAT = 'Bibtex';
N_MAX           = 100;
%NOTE: Could also specify range or indices ...
END_DEFINE_CONSTANTS

%This looked a bit sexier in my head ...
%options is now a struct with these fields and values of those variables
options = variablesToStruct({'GET_CITATIONS' 'CITATION_FORMAT'});

URL = 'http://scholar.google.com';

webStr = urlread2(URL);

formStruct = form_get(webStr,URL);
formStruct = form_helper_setTextValue(formStruct,'q',searchText);

if GET_ARTICLES
   whichRadio = 1;
   checkMask  = INCLUDE_PATENTS;
else
   whichRadio = 2; 
   checkMask  = true;
end

formStruct = form_helper_selectRadio(formStruct,1,whichRadio);
formStruct = form_helper_selectCheckBox(formStruct,1,checkMask);

[parsedResults,extras] = google_scholar_getNResults(formStruct,N_MAX,options);


