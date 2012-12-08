classdef settings < handle
    %
    %   NOTE: These are not yet used ...
    
    %TODO: articles and legal documents should be linked, one or the other
    %Include patents sets articles to true ...
    properties 
       get_articles    = true
       get_legal_docs  = false
       include_patents = false
    end
    
    properties
       citation_link_type = 'none'
       
       %TODO: Build more functionality in here
       %Should be a class ...
       library_links
    end
    
    properties (Constant)
        VALID_CITATION_TYPES = {'none' 'BibTeX' 'EndNote' 'RefMan' 'RefWorks'}; 
    end
    
    methods
    end
    
end

