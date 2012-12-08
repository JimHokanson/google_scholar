function [parsedResults,extras] = google_scholar_advancedSearch(docStruct,varargin)
%google_scholar_advancedSearch  Performs an advanced Google Scholar search
%
%   [web_page_text,extras] = google_scholar_advancedSearch(docStruct,varargin)
%
%   This function currently filters by title with all of the words
%   specified (after filtering by word length, see optional inputs), as
%   well as year, title, and journal. If any of these are omitted they are
%   not included in the search.
%
%   OUTPUTS
%   =======================================================================
%   parsedResults : see google_scholar_parseResults
%   extras        : see google_scholar_parseResults
%   %%with the extra fields:
%       .advancedURL - the url of the advanced search page, could save
%                      some time if passed into this form on multiple calls
%
%   INPUTS
%   =======================================================================
%   docStruct : (structure), with optional fields:
%       .authors : (cellstr or string)
%       .year    : either numeric (1 or 2 values range) or a string with
%                  a single year value
%       .title   : (string) title to search for
%       .journal : (string)
%
%
%   OPTIONAL INPUTS (varargin)
%   =======================================================================
%   DONT_PROCESS_ANY      : (default false), if true, doesn't filter
%                           the inputs (the next few options)
%
%   %%these next few remove words if they don't meet a certain length
%   requirement, setting to 0 skips the filtering
%   MIN_TITLE_WORD_LENGTH : (default 4)
%   MIN_AUTHOR_LENGTH     : (default 4)
%   MIN_JOURNAL_LENGTH    : (default 4)
%
%   BUFFER_YEAR           : (default false), if true pads the year, this
%                           can be useful if a year is specified but it
%                           may be innacurate, like posted date versus
%                           reviewed date versus published date
%   YEAR_BUFFER_AMOUNT    : (default 1), if BUFFER_YEAR is true, this is
%                            the amount we pad the year by (the search is a
%                            year range, not a single year value)
%   ADVANCED_URL_INPUT    : (default ''), pass this in to skip some
%                            querying of the main Google Scholar page to go
%                            to the advanced search page
%
%   %%These next two go to google_scholar_parseResults
%   GET_CITATIONS         : (default false), if true returns citations,
%                           this can be slow
%   CITATION_FORMAT       : (default Bibtex), format to return ciations in
%   STRIP_NON_ALPHA_NUM   : (default false), if true, replaces non-alpha
%                            numeric characters with spaces before searching
%
%   IMPROVEMENTS
%   =======================================================================
%   1) Expose other word options
%   2) Allow anywhere in article search vs title
%   3) Change # of results per page ???
%
%   See also:
%   pittcat_getJournalStruct            %use for getting structure for this input
%   google_scholar_parseResults         %parses the result of the search
%   google_scholar_getCheckKnownFormats %Use to return known format options

DEFINE_CONSTANTS
DONT_PROCESS_ANY      = false;
MIN_TITLE_WORD_LENGTH = 4;
MIN_AUTHOR_LENGTH     = 4;
MIN_JOURNAL_LENGTH    = 4;
BUFFER_YEAR           = false;
YEAR_BUFFER_AMOUNT    = 1;
GET_CITATIONS         = false;
CITATION_FORMAT       = 'Bibtex';
ADVANCED_URL_INPUT    = '';
STRIP_NON_ALPHA_NUM   = false;
END_DEFINE_CONSTANTS

SCHOLAR_URL  = 'http://scholar.google.com/';
SCHOLAR_TEXT = 'Advanced Scholar Search';  %What we are looking for on the main
%page to find the page for advanced searches

%MLINT
%===========================
%#ok<*UNRCH> %can't reach
%#ok<*NASGU> %not used

%RETRIEVAL OF ADVANCED SCHOLAR FORM
%--------------------------------------------------------
if isempty(ADVANCED_URL_INPUT)
    web_str = urlread2(SCHOLAR_URL);
    links       = html_getLinksbyText(web_str,SCHOLAR_TEXT,false);
    advancedURL = url_getAbsoluteUrl(SCHOLAR_URL,links{1});
else
    advancedURL = ADVANCED_URL_INPUT;
end
web_str     = urlread2(advancedURL);

curForm = form_get(web_str,advancedURL);

%PROCESSING OF THE INPUTS
%-------------------------------------------------------

%TITLE/WORD SEARCH
%===================================
if isfield(docStruct,'title')
    titleStr = docStruct.title;
else
    titleStr = '';
end
if ~isempty(titleStr)
    if ~DONT_PROCESS_ANY && MIN_TITLE_WORD_LENGTH ~= 0
        titleStr = removeShortWords(titleStr,MIN_TITLE_WORD_LENGTH,'strip_nonAlphaNum',STRIP_NON_ALPHA_NUM);
    end
    curForm = form_helper_setTextValue(curForm,'as_q',titleStr);
    %This next entry basically says to only look in the title
    curForm = form_helper_selectOption(curForm,'as_occt','value','title');
end

%AUTHORS
%=================================
if isfield(docStruct,'authors')
    authors = docStruct.authors;
else
    authors = '';
end
if ~isempty(authors)
    if ischar(authors)
        authorStr = authors;
    else
        authorStr = cellArrayToString(authors);
    end
    
    if MIN_AUTHOR_LENGTH ~= 0 && ~DONT_PROCESS_ANY
        authorStr = removeShortWords(authorStr,MIN_AUTHOR_LENGTH,'strip_nonAlphaNum',STRIP_NON_ALPHA_NUM);
    end
    curForm   = form_helper_setTextValue(curForm,'as_sauthors',authorStr);
end

%JOURNAL
%=======================================
if isfield(docStruct,'journal')
    journalStr = docStruct.journal;
else
    journalStr = '';
end
if ~isempty(journalStr)
    if MIN_JOURNAL_LENGTH ~= 0 && ~DONT_PROCESS_ANY
        journalStr = removeShortWords(journalStr,MIN_JOURNAL_LENGTH,'strip_nonAlphaNum',STRIP_NON_ALPHA_NUM);
    end
    curForm    = form_helper_setTextValue(curForm,'as_publication',journalStr);
end

%YEAR
%=======================================
if isfield(docStruct,'year')
    yearStr = docStruct.year;
else
    yearStr = '';
end
if ~isempty(yearStr)
    if isnumeric(yearStr)
        yearLow  = int2str(yearStr(1));
        if length(yearStr) == 2
            yearHigh = int2str(yearStr(2));
        else
            yearHigh = yearLow;
        end
    elseif BUFFER_YEAR
        yearNumeric = str2double(yearStr);
        yearLow     = int2str(yearNumeric - YEAR_BUFFER_AMOUNT);
        yearHigh    = int2str(yearNumeric + YEAR_BUFFER_AMOUNT);
    else
        yearLow = yearStr;
        yearHigh = yearStr;
    end
    curForm   = form_helper_setTextValue(curForm,'as_ylo',yearLow);
    curForm   = form_helper_setTextValue(curForm,'as_yhi',yearHigh);
end

[web_page_text,extras] = form_submit(curForm);

[parsedResults,extras] = google_scholar_parseResults(web_page_text,extras.url,...
    'GET_CITATIONS',GET_CITATIONS,'CITATION_FORMAT',CITATION_FORMAT);

extras.advancedURL = advancedURL;
