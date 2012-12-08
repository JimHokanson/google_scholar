classdef result_entry < handle
    %
    
    %NOT YET SUPPORTED
    
    
    properties
        parent
        
        type = ''  %pdf, citation, book
        title_str
        title_link
        
        abstract_str
        result_str
        
        cited_by_count
        cited_by_link
        
        cit_format
        cit_format_link
        
        related_articles_link
        
        version_count
        version_link
        
        full_text_links
        full_text_links_text
        
        other_links %junk not recognized
        other_links_text
    end
    
    %METHODS
    %=========================
    %1) Get versions
    %2) Get more results (make method of parent)
    %3) Follow full text link ...
    %4) Get cited by information
    %5) Get citation information
    
    properties (Dependent)
        citation
    end
    
    properties (Hidden)
        citation_cached
    end
    
    methods
        function objs = result_entry(entry_elements,sr_page_obj)
           %
           %    
           %    Called by:
           %    search_result_page
           
           %
           
           
           if nargin == 0
               return
           end
           
           nObjs = entry_elements.size;
           objs(nObjs) = google_scholar.result_entry;
           for iObj = 1:nObjs
              cur_obj = objs(iObj);
              cur_obj.parent = sr_page_obj;
              init_obj(cur_obj,entry_elements.get(iObj-1))
           end
        end
        

    end
    
end

