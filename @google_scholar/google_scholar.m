classdef google_scholar < handle
    %google_scholar
    %
    %
    %
    %   METHODS IN OTHER FILES
    %   =================================================
    %   advanced_search
    %   search
    
    %TODO:
    %-----------------------------------------
    %- On not signed in, provide prompt gui to do so
    %- write constructor for user settings
    %- implement advanced search ...
    
    
    properties
        %How to handle old search results ??????
        %Only populated after a search ...
        search_result %(class google_scholar.search_result_page)
        
        settings
    end
    
    properties
        %NOTE: Being signed in allows user settings to be used ...
        %Should put in its own class
        signed_in      = false
        signed_in_name = ''
        user_name = ''
        user_pass = ''
    end
    
    properties (Hidden)
        sign_in_link = '';
    end
    
    properties (Constant,Hidden)
        GS_URL = 'http://scholar.google.com/'
        SIMPLE_FORM_INDEX   = 1
        ADVANCED_FORM_INDEX = 2
    end
    
    
    methods
        function obj = google_scholar(varargin)
            %google_scholar
            %
            %    Google Scholar Constructor
            %
            %   OPTIONAL INPUTS
            %   ================================
            %   user_name :
            %   user_pass :
            %   settings  :
            
            in.user_name = '';
            in.user_pass = '';
            in.settings  = google_scholar.settings;
            in = processVaragin(in,varargin);
            
            obj.user_name = in.user_name;
            obj.user_pass = in.user_pass;
            
            %Get settings
            obj.settings  = in.settings;
        end
    end
    
    methods (Static)
        %Allow retrieval of the sign in tags as a function
    end
    
    methods
        function sign_in(obj)
            %sign_in
            %
            %	sign_in(obj)
            
            EMAIL_NAME  = 'Email';
            PASSWD_NAME = 'Passwd';
            
            check_signed_in(obj)
            
            if ~obj.signed_in
                
                if isempty(obj.user_name) || isempty(obj.user_pass)
                    [obj.user_name,obj.user_pass] = logindlg('Title','Login Title');
                end
                
                doc_obj = jsoup_get_doc(obj.sign_in_link);
                
                formStruct = form_get(doc_obj);
                formStruct = formStruct(1);
                formStruct = form_helper_setTextValue(formStruct,EMAIL_NAME,obj.user_name);
                formStruct = form_helper_setTextValue(formStruct,PASSWD_NAME,obj.user_pass);
                [web_page_text,extras] = form_submit(formStruct);
                doc_obj_2 = jsoup_get_doc(web_page_text,extras.url);
                
                check_signed_in(obj,doc_obj_2)
                
                if ~obj.signed_in
                    %Can check with pittcat_client.show_page(web_page_text)
                    %NOTE: That method needs to change to be more general ...
                    error('Sign in failure - see code')
                end
                
            end
        end
        function check_signed_in(obj,doc_obj)
            %check_signed_in Checks whether or not user is signed in
            %
            %   check_signed_in(obj,doc_obj)
            %
            %   check_signed_in(obj)
            %
            %   Checks if user is signed in to Google for saving
            %   preferences and stuffs
            %
            %   POPULATES:
            %   ================================================
            %   .signed_in
            %   .signed_in_name
            %   .sign_in_link
            %
            
            if ~exist('doc_obj','var')
                doc_obj = jsoup_get_doc(obj.GS_URL);
            end
            
            
            %JAH TODO
            
            %This says, get <a> tag that has this <span id="gbgs4">
            SELECTION_CRITERIA = 'div#gs_gb_rt';
            SIGN_IN_TEXT   = 'Sign In';
            
            
            %<a target="_top"
            %href="https://accounts.google.com/ServiceLogin?hl=en&amp;continue=http://scholar.google.com/"
            %onclick="gbar.logger.il(9,{l:'i'})" id="gb_70"
            %class="gbgt"><span class="gbtb2"></span><span id="gbgs4"
            %class="gbts"><span id="gbi4s1">Sign in</span></span></a>
            
            %Might want to grab by accounts.google.com/ServiceLogin
            
            %When signed in: <a class="gbgt gbgt-hvr" id="gbg4"
            %href="//www.google.com/profiles" onclick="gbar.tg(event,this)"
            %aria-haspopup="true" aria-owns="gbd4"><span
            %class="gbtb2"></span><span id="gbgs4" class="gbts gbtsa"><span
            %id="gbi4"><span id="gbi4m1">Jim Hokanson</span><span
            %class="gbma"></span></span></span></a>
            
            
            
            temp = doc_obj.select(SELECTION_CRITERIA);
            
            if temp.size == 0
                %debug with html.show_page(doc_obj.html)
                error('Unable to find the SIGN IN TAG')
            end
            
            temp = temp.get(0); %Make an element class, not elements class
            
            %NOTE: text returns the displayable text in this tag and
            %any sub tags, which is what we want
            temp_text = char(temp.text);
            
            obj.signed_in = ~strcmpi(temp_text,SIGN_IN_TEXT);
            
            if obj.signed_in
                obj.signed_in_name = temp_text;
            else
                obj.sign_in_link   = char(temp.absUrl('href'));
                obj.signed_in_name = '';
            end
            
            
        end
    end
    
end

