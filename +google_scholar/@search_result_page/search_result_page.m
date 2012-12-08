classdef search_result_page < handle
    %
    
    %JAH TODO: Document these properties ...
    properties
       jsoup_obj    %Class org.jsoup.???
       entries
       raw_text
       authors_link = ''
       authors_name = ''
       page_number
       
       %NAVIGATION
       previous_page_link
       next_page_link
       page_numbers
       page_links
    end
    
    %OTHER INFO
    %======================
    %nResults
    %page id
    %time ...
    
    methods
        function obj = search_result_page(jsoup_page_obj)
            %
            %
            %   INPUTS
            %   ===========================
            %   jsoup_page_obj : a page result from a search
            %                    parsed by jsoup
            
           if nargin == 0
               return
           end
           
           %google_scholar.search_result_page.init_obj
           init_obj(obj,jsoup_page_obj)
        end 
    end
    
end

