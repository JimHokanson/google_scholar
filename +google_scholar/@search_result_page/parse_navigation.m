function parse_navigation(obj,jsoup_page_obj)
%parse_navigation Parses out navigation info at bottom of search result page
%
%   parse_navigation(obj,jsoup_page_obj)
%
%   POPULATES:
%   ========================================
%   page_number
%   previous_page_link
%   next_page_link
%   page_numbers
%   page_links

%TODO: Document assumptions ...
%=============================================


NAV_TAG_SELECTOR = '[id=gs_n]';

navigation_obj = jsoup_page_obj.select(NAV_TAG_SELECTOR);

%DOES THIS EXIST FOR ONLY A SINGLE PAGE ?????


link_td_obj = navigation_obj.get(0).getElementsByTag('td');
%Contains:
%   - previous, hidden for page 1
%   - current page, no link, has span of class=gs_ico gs_ico_nav_current
%   - other pages, links, spans of class =gs_ico gs_ico_nav_page
%   - next, hidden for last page

n_pages      = link_td_obj.size - 3; %previous, next, current
page_links   = cell(1,n_pages);
page_numbers = zeros(1,n_pages);

cur_page_index = 0;

for iLink = 1:link_td_obj.size
    cur_td    = link_td_obj.get(iLink-1);
    span_objs = cur_td.getElementsByTag('span');
    
    switch char(span_objs.get(0).attr('class'));
        case 'gs_ico gs_ico_nav_previous'
            a_objs = cur_td.getElementsByTag('a');
            obj.previous_page_link = char(a_objs.get(0).attr('abs:href'));
        case 'gs_ico gs_ico_nav_next'
            a_objs = cur_td.getElementsByTag('a');
            obj.next_page_link = char(a_objs.get(0).attr('abs:href'));
        case 'gs_ico gs_ico_nav_current'
            obj.page_number = str2double(char(cur_td.text));
        case 'gs_ico gs_ico_nav_page'
            cur_page_index = cur_page_index + 1;
            a_objs = cur_td.getElementsByTag('a');
            page_numbers(cur_page_index) = str2double(char(cur_td.text));
            page_links{cur_page_index}   = char(a_objs.get(0).attr('abs:href'));
        case 'gs_ico gs_ico_nav_first'
            %Do nothing (= hidden previous)
        case 'gs_ico gs_ico_nav_last'
            %Do nothing (= hidden last)
        otherwise
            error('Unrecognized page link: %s',char(span_objs.get(0).attr('class')))
    end
end

obj.page_numbers = page_numbers;
obj.page_links   = page_links;










end