function [parsedResults,extras] = google_scholar_parseResults(webStr,prevURL,varargin)
%google_scholar_parseResults  Parses result of search from Google Scholar
%
%   [parsedResults,extras] = google_scholar_parseResults(webStr,prevURL,varargin)
%
%   In general this function should not be called directly. Instead use:
%       google_scholar_advancedSearch
%       google_scholar_simpleSearch
%   
%   OUTPUTS
%   =======================================================================
%   parsedResults
%         .id               - result # (relative to original search)
%         .titleStr         - title of the result, not necessarily complete
%         .titleLink        - (url), link around the title
%         .remainingText    - usually this is a kind of abstract (sort of)
%         .citedByCount     - # of citations for that article
%         .citedByLink      - (url), link to articles that cited this one
%         .citFormat        - format of citation
%         .citLink          - (url), link to citation
%         .versionCount     - # of versions detected
%         .versionLink      - (url), link to page that displays all
%                             versions of the article
%         .relatedArticles  - (url), url to articles that GS thinks is
%                              similar to this article
%         .fullTextLinks    - (links,see html_getLinks) links to full text,
%                              this field may be empty ''
%         .otherFooterLinks - (links) other links which I didn't
%                             break out into separate fields
%         .citation         - (docStruct), see pittcat_bibtex_to_docStruct
%
%
%   extras
%       .resultInfo (struct)
%           .first - first id on page
%           .last  - last id on page
%           .outOf - total # of results
%           .time  - time to process query by Google (be impressed)
%           .isApproximateCount - logical, whether outOf is exact or 
%                                 approximate -> 1 of 100 or 1 of about 10000
%       .pageInfo   (struct)
%           .curPage   - page # of current page
%           .nextLink  - (url) link to next page (might be empty)
%           .prevLink  - (url) link to previous page (might be empty)
%           .pageLinks - (structure)
%                   .id    - page #
%                   .link  - (url)
%
%   INPUTS
%   =======================================================================
%   webStr  : text to parse
%   prevURL : Used for populating links correctly with absolute urls
%
%   OPTIONAL INPUTS
%   =======================================================================
%   GET_CITATIONS : (default false), if true returns the citations for each
%                   entry
%   CITATION_FORMAT : (default Bibtex), if empty doesn't return citation
%                      info
%
%   SEE ALSO:
%       google_scholar_advancedSearch
%       google_scholar_simpleSearch
%       pittcat_bibtex_to_docStruct
%       html_getLinks
%       pittcat_debug

DEFINE_CONSTANTS
N_MAX           = 10;
GET_CITATIONS   = false;
CITATION_FORMAT = 'Bibtex';
DEPTH = 0; %Don't set this, for internal use
constS = END_DEFINE_CONSTANTS;

USER_PROFILE_TEXT = 'User profiles for ';

if isempty(CITATION_FORMAT)
    GET_CITATIONS = false;
end

%This might need to be changed
TAGS_REMOVE = {'b' 'font'};
SINGLE_TAGS = {'br'};

%This shouldn't be changed
OPTIONS = {'get_links',true,'decode_text',true,'prev_url',prevURL};

%INITIAL GRAB OF EACH CITATION ENTRY
%==========================================================================
%origWebStr = webStr; %For debugging later
webStr    = html_removeTags(webStr,TAGS_REMOVE);
SINGLE_TAGS = cellfun(@(x) ['<' x '>'],SINGLE_TAGS,'un',0);
allSingleTags = ['(' cellArrayToString(SINGLE_TAGS,'|') ')'];
webStr    = regexprep(webStr,allSingleTags,'','ignorecase');

tagOutput = html_getTagsByProp(webStr,'div','class','gs_r');

if isempty(tagOutput)
    parsedResults = [];
    extras        = struct([]);
    return
end

%RESULTS COUNT PARSING
%==========================================================================
%EXAMPLES:
%- Results 1 - 1 of 1.   (0.10 sec)
%- Results 1 - 10 of about 75,700. (0.11 sec)
patParts = cell(1,4);
patParts{1}  = '(?<first>\d+) - (?<last>\d+)';
patParts{2} = '( of about | of )'; %NOTE: put specific first
patParts{3} = '(?<outOf>[^.]*?)\.';
patParts{4} = '\s*?\((?<time>[^ ]*) sec';
totalPattern = [patParts{1:4}];

[resultCountTemp,I_start,I_end] = regexpi(webStr,totalPattern,'names','start','end');
if isempty(resultCountTemp)
    error('Error parsing the results from the web page')
end

resultCountTemp.first = str2double(resultCountTemp.first);
resultCountTemp.last  = str2double(resultCountTemp.last);
resultCountTemp.outOf = str2double(resultCountTemp.outOf);
resultCountTemp.time  = str2double(resultCountTemp.time);
resultCountTemp.isApproximateCount = ~isempty(strfind(webStr(I_start:I_end),'about'));

extras = struct;
extras.resultInfo = resultCountTemp;

%PAGE PARSING - get links to other pages
%==========================================================================
%div -> n
%Previous (may or may not exist)
%Next (may or may not exist)
%pageLinkTable = html_getTagsByProp(webStr,'div','class','n',OPTIONS{:});
%How in the heck did the above code ever work??????
pageLinkTable = html_getTagsByProp(webStr,'div','id','gs_n',OPTIONS{:});

%JAH TODO: based on the results above I should be able to tell if this
%should be empty or not, if it shouldn't and it is, handle this

pageInfo = struct('curPage',0,'nextLink','','prevLink','','pageLinks','');
if isempty(pageLinkTable)
    pageInfo.curPage = 1;
else
    links = pageLinkTable.links;
    nLinks = length(links);
    prevI = [];
    nextI = [];
    linksTempStruct = struct('id',num2cell(1:nLinks),'link','');
    
    for iLink = 1:nLinks
        %find previous and next and remove
        curLink = links(iLink);
        %Let's hope this matches ...
        d = regexp(curLink.text,'span>\d+','match','once');
        if ~isempty(d)
            linksTempStruct(iLink).id = str2double(d(6:end));
            linksTempStruct(iLink).link = curLink.href;
        elseif ~isempty(strfind(lower(curLink.text),'next'))
            linksTempStruct(iLink).id = -1;
            if ~isempty(pageInfo.nextLink)
                error('Multiple next links found')
            end
            pageInfo.nextLink = curLink.href;
            nextI = iLink;
        elseif ~isempty(strfind(lower(curLink.text),'prev'))
            linksTempStruct(iLink).id = -2;
            if ~isempty(pageInfo.prevLink)
                error('Multiple next links found')
            end
            pageInfo.prevLink = curLink.href;
            prevI = iLink;
        else
            error('Unrecognized pattern')
        end
    end
    linksTempStruct([nextI prevI]) = [];
    pageInfo.pageLinks = linksTempStruct;
    
    %Finally, getting the page # of the current page
    %--------------------------------------------
    %<td><span class="SPRITE_nav_current"> </span><span class="i">1</span></td>
    currentPageTag = html_getTagsByProp(pageLinkTable.text,'td','text contains','SPRITE_nav_current');
    %find the one with SPRITE_nav_current
    d = regexp(currentPageTag.text,'\d+','match','once');
    pageInfo.curPage = str2double(d);
end
extras.pageInfo = pageInfo;

%CITATION PARSING - WHERE THE REAL WORK OCCURS ...
%==========================================================================
parsedResults = struct(...
    'id',num2cell(resultCountTemp.first:resultCountTemp.last),...
    'titleStr','',...
    'titleLink','',...
    'remainingText','',...
    'citedByCount',0,...
    'citedByLink','',...
    'citFormat','',...
    'citLink','',...
    'versionCount',1,...
    'versionLink','',...
    'relatedArticles','',...
    'fullTextLinks',struct([]),...
    'otherFooterLinks',struct([]));

%JAH IMPROVEMENT
%The user profile will occupy the first entry in parsedResults
%but we'll only allocate enough for the actual entries
%This is technically fine because Matlab will expand the size of the array
%to accomodate the +1, and then we truncate the first entry at the end but
%it is a bit sloppy

%JAH TODO: The above bites me in the ass when I only want to process the
%first n results ...

%Looping over all gs_rs
has_user_profile = false;
for iEntry = 1:length(tagOutput)
    curText = tagOutput(iEntry).text;
    
    %TITLE PROCESSING
    %======================================================================
    %titleTag     = html_getTagsByProp(curText,'div','class','gs_rt',OPTIONS{:});
   titleTag     = html_getTagsByProp(curText,'h3','class','gs_rt',OPTIONS{:});

   %What the heck Google, really, you had to change this ...
   curText = html_removeTags(curText,'h\d+');

   if iEntry == 1 && ~isempty(strfind(curText,USER_PROFILE_TEXT))
      has_user_profile = true;
      %JAH TODO: parse the user profile info
      continue
   end
    
    if ~isempty(titleTag.links)
        titleStr  = titleTag.links(1).text;
        titleLink = titleTag.links(1).href;
    else
        titleStr = titleTag.text;
        titleLink = '';
    end
    parsedResults(iEntry).titleStr = titleStr;
    parsedResults(iEntry).titleLink = titleLink;
    
    %NOT USING RIGHT NOW - other than to get remaining text
    abstractTag  = html_getTagsByProp(curText,'span','class','gs_a',OPTIONS{:});
    
    %FOOTER PROCESSING
    %=======================================================================
    %Examples of links on the bottom
    %    Cited by 1280      x
    %    Related articles   x
    %    Links @ Pitt-UPMC
    %    BL Direct
    %    View as HTML
    %    Check ArticleAvailability
    %    All 11 versions    x
    %    Import into BibTeX x
    footerTag    = html_getTagsByProp(curText,'div','class','gs_fl',OPTIONS{:});
    citFormatFound = false;
    if isfield(footerTag,'links')
        footerLinks = footerTag.links;
        
        patterns = {...
            '(?<=Cited by )\d+'...
            'Related articles'...
            '(?<=All )(\d+)(?= versions)'...
            '(?<=Import into )(.*)'};
        
        notMatched = false(1,length(footerLinks));
        for iFooter = 1:length(footerLinks)
            curLink = footerLinks(iFooter);
            temp = regexpi(curLink.text,patterns,'match','once');
            I = find(~cellfun('isempty',temp),1);
            if isempty(I)
                I = 0;
                notMatched(iFooter) = true;
            else
                temp = temp{I};
            end
            switch I
                case 1
                    parsedResults(iEntry).citedByCount = str2double(temp);
                    parsedResults(iEntry).citedByLink  = curLink.href;
                case 2
                    parsedResults(iEntry).relatedArticles = curLink.href;
                case 3
                    parsedResults(iEntry).versionCount = str2double(temp);
                    parsedResults(iEntry).versionLink  = curLink.href;
                case 4
                    citFormatFound = true;
                    parsedResults(iEntry).citFormat = temp;
                    parsedResults(iEntry).citLink   = curLink.href;
            end
        end
        parsedResults(iEntry).otherFooterLinks = footerLinks(notMatched);
    end
    
    %======================================================================
    %                       CITATION CHECK AND PARSING
    %======================================================================
    if ~strcmpi(CITATION_FORMAT,parsedResults(iEntry).citFormat) && citFormatFound
        if DEPTH == 1
            error('Failed to properly set preferences for obtaining citations')
        else
            %Need to extract preferences url
            prefURLTag = html_getTagsByProp(webStr,'a','text contains','Scholar Preferences',OPTIONS{:});
            %NOTE: by requesting an anchor tag, we are not self referential and
            %the tag doesn't contain a link structure with the url, but the
            %attributes of the tag do
            prefURL = prefURLTag.atts.href;
            [webStr,extras] = google_scholar_setPreferences('BIB_OPTION',CITATION_FORMAT,'PREF_URL',prefURL);
            newOptions = constS.finalDefaultStruct;
            newOptions.DEPTH = DEPTH + 1;
            [parsedResults,extras] = google_scholar_parseResults(webStr,extras.url,newOptions);
            return
        end
    end
    
    if GET_CITATIONS
        switch lower(CITATION_FORMAT)
            case 'bibtex'
                citText = urlread2(parsedResults(iEntry).citLink);
                parsedResults(iEntry).citation = pittcat_bibtex_to_docStruct(citText);
            otherwise
                error('parser not yet written for %s',CITATION_FORMAT)
        end
    end
    
    %======================================================================
    %               FULL TEXT LINK PROCESSING
    %======================================================================
    fullLinkTags = html_getTagsByProp(curText,'span','class','gs_ggs gs_fl',OPTIONS{:});
    if isfield(fullLinkTags,'links')
        parsedResults(iEntry).fullTextLinks = fullLinkTags.links;
    else
        parsedResults(iEntry).fullTextLinks = struct([]);
    end
    
    %======================================================================
    %                   Handling the remaining text
    %-----------------------------------------------------------------------
    boundsRemove = zeros(4,2);
    maskDelete = true(1,4);
    if ~isempty(titleTag)
        boundsRemove(1,1) = titleTag.bounds.Iopen;
        boundsRemove(1,2) = titleTag.bounds.IcloseEnd;
        maskDelete(1) = false;
    end
    if ~isempty(abstractTag)
        boundsRemove(2,1) = abstractTag.bounds.Iopen;
        boundsRemove(2,2) = abstractTag.bounds.IcloseEnd;
        maskDelete(2) = false;
    end
    if ~isempty(footerTag)
        boundsRemove(3,1) = footerTag.bounds.Iopen;
        boundsRemove(3,2) = footerTag.bounds.IcloseEnd;
        maskDelete(3) = false;
    end
    if ~isempty(fullLinkTags)
        boundsRemove(4,1) = fullLinkTags.bounds.Iopen;
        boundsRemove(4,2) = fullLinkTags.bounds.IcloseEnd;
        maskDelete(4) = false;
    end
    boundsRemove(maskDelete,:) = [];
    
    parsedTextIndices = generateIndicesFromRanges(boundsRemove(:,1),boundsRemove(:,2));
    remainingText = curText;
    remainingText(parsedTextIndices) = [];
    parsedResults(iEntry).remainingText = remainingText;
end

if has_user_profile
   parsedResults(1) = []; 
end

end
