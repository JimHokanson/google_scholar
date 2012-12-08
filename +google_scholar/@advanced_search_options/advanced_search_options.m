classdef advanced_search_options < handle
    %advanced_search_options
    %
    %   IMPROVEMENTS: 
    %   ======================================================
    %   Might change to hggetset class
    
    properties
    with_all_words    = ''   %name="as_q"
    with_exact_phrase = ''   %name="as_epq"
    with_at_least_one = ''   %name="as_oq"
    without_words     = ''   %name="as_eq"
    end
    
    properties
    where_words_occur = 'anywhere' %allow 'in_title' as well
    %name = "as_occt"  , value = "any" or "title"
    end
    
    properties
    articles_by  = ''   %name="as_sauthors"
    published_in = ''   %name="as_publication"
    date_start   = ''   %name="as_ylo"
    date_end     = ''   %name="as_yhi"
    end
    
    methods
    
    end
    
end

