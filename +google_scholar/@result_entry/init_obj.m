function init_obj(obj,gs_r_div)
%init_obj Initializes a result entry
%
%   google_scholar.result_entry.init_obj(obj,gs_r_div)
%
%   FORMAT NOTES
%   =====================================
%   gs_r   : entire result => should be handled at this point ...
%       gs_rt  : title string with link, also contains gs_ctc
%           gs_ctc : type, not always present, might need to remove []
%       gs_a   : abstract
%       gs_rs  : result text
%       gs_fl  : footer links
%       gs_ggs gs_fl : full text links????
%
%
%   IMPROVEMENTS:
%   Break up into smaller functions for enhanced readability ...
%
%   class google_scholar_search_result

%TITLE PROCESSSING
%======================================================
title_obj  = gs_r_div.select('[class=gs_rt]');
title_link = title_obj.select('a');

obj.title_str  = char(title_link.get(0).text);
obj.title_link = char(title_link.get(0).attr('abs:href'));

type_obj = title_obj.select('[class=gs_ctc]');

if type_obj.size ~= 0
    obj.type = char(type_obj.get(0).text);
end

%ABSTRACT AND RESULT TEXT
%======================================================

%   gs_r   : entire result => should be handled at this point ...
%       gs_rt  : title string with link, also contains gs_ctc
%           gs_ctc : type, not always present, might need to remove []
%       gs_a   : abstract
%       gs_rs  : result text
%       gs_fl  : footer links
%       gs_ggs gs_fl : full text links????


abstract_obj = gs_r_div.select('[class=gs_a]');
obj.abstract_str = char(abstract_obj.get(0).text);

result_obj   = gs_r_div.select('[class=gs_rs]');
obj.result_str   = char(result_obj.get(0).text);

%FOOTERS HANDLING
%======================================================
footer_section  = gs_r_div.select('[class=gs_fl]');
footer_links = footer_section.get(0).getElementsByTag('a');

nLinks = footer_links.size;
all_unmatched_links  = cell(1,nLinks);
unmatched_links_text = cell(1,nLinks);
unmatched_link_mask  = false(1,nLinks);
for iLink = 1:nLinks
    %Examples of links on the bottom
    %    Cited by 1280      x
    %    Related articles   x
    %    Links @ Pitt-UPMC
    %    BL Direct
    %    View as HTML
    %    Check ArticleAvailability
    %    All 11 versions    x
    %    Import into BibTeX x
    
    link_text = char(footer_links.get(iLink-1).text);
    link_href = char(footer_links.get(iLink-1).attr('abs:href'));
    
    nCitations = regexp(link_text,'Cited by (\d+)','tokens','once');
    if ~isempty(nCitations)
        obj.cited_by_count = str2double(nCitations{1});
        obj.cited_by_link  = link_href;
        continue
    end
    
    if ~isempty(strfind(link_text,'Related articles'))
        obj.related_articles_link = link_href;
        continue
    end
    
    nVersions = regexp(link_text,'All (\d+) versions','tokens','once');
    if ~isempty(nVersions)
        obj.version_count = str2double(nVersions{1});
        obj.version_link  = link_href;
        continue
    end
    
    cit_text = regexp(link_text,'Import into (.*)','tokens','once');
    if ~isempty(cit_text)
        obj.cit_format = cit_text{1};
        obj.cit_format_link = link_href;
        continue
    end
    
    unmatched_link_mask(iLink)  = true;
    all_unmatched_links{iLink}  = link_href;
    unmatched_links_text{iLink} = link_text;
end

obj.other_links = all_unmatched_links(unmatched_link_mask);
obj.other_links_text = unmatched_links_text(unmatched_link_mask);
%FULL TEXT LINKS
%===============================================================
full_text_obj  = gs_r_div.select('[class=gs_ggs gs_fl]');
if full_text_obj.size ~= 0
    full_text_link_objs = full_text_obj.get(0).getElementsByTag('a');
    nLinks = full_text_link_objs.size;
    full_text_links = cell(1,nLinks);
    full_text_links_text = cell(1,nLinks);
    for iLink = 1:nLinks
        full_text_links_text{iLink} = char(full_text_link_objs.get(iLink-1).text);
        full_text_links{iLink} = char(full_text_link_objs.get(iLink-1).attr('abs:href')); 
    end
    
    obj.full_text_links = full_text_links;
    obj.full_text_links_text = full_text_links_text;
    
end
%Could be from the library or publically available


end