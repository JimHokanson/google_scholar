function init_obj(obj,jsoup_page_obj)
%
%
%
%   class: search_result_page

REGEXP_USER_PROFILE_TEXT    = 'User profiles for (.*)';

%TODO: Make static prop of result_entry class
RESULT_ENTRY_JSOUP_SELECTOR = '[class=gs_r]';
TITLE_STRING_JSOUP_SELECTOR = '[class=gs_rt]';

%Grabbing result elements (& maybe an author element)
%---------------------------------------------------------
result_elements = jsoup_page_obj.select(RESULT_ENTRY_JSOUP_SELECTOR);

%JAH TODO: Move to separate function ....
%USER PROFILE FIRST ELEMENT PARSING
%=======================================================
first_title_obj = result_elements.get(0).select(TITLE_STRING_JSOUP_SELECTOR);
userName = regexp(char(first_title_obj.text),REGEXP_USER_PROFILE_TEXT,'tokens','once');
if ~isempty(userName)
    obj.authors_name = userName{1};
    a_tag = first_title_obj.get(0).getElementsByTag('a');
    obj.authors_link = char(a_tag.get(0).attr('abs:href'));
    
    %IMPORTANT ****************************
    %This is the really important part, removing this from the "results"
    result_elements.remove(0);
    
    %users_obj = result_elements.get(0);
    %JAH TODO: Could show more info => see users_obj
end

%RESULT PARSING
%---------------------------------------------------------
obj.entries = google_scholar.result_entry(result_elements,obj);

%NAVIGATION PARSING
%---------------------------------------------------------
parse_navigation(obj,jsoup_page_obj)

end