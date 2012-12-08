function search(obj,searchText)
%search  Searches Google Scholar using searchText
%
%   search(obj,searchText)
%
%   Populates Property .search_result 
%
%   INPUTS
%   =======================================================================
%   searchText: What you would enter into the search bar
%
%   NOT YET IMPLEMENTED 
%   ===================================================
%   OPTIONAL INPUTS (key,value pairs or struct)
%   =======================================================================
%   GET_ARTICLES    : (default true), if false, gets legal opinions and journals
%   INCLUDE_PATENTS : (default false), if true, also returns patents
%   GET_CITATIONS   : (default false), if true retrieves the citation
%                     information as well
%   
%
%   See Also:
%       google_scholar.search_result_page

doc_obj = jsoup_get_doc(obj.GS_URL);

%Why am I doing this here ????
%I think just to update the property in the class since we already have the
%data that we need in order to answer the question, instead of making a
%separate request just to check whether or not we are signed in
check_signed_in(obj,doc_obj)


formStruct = form_get(doc_obj);

assert(length(formStruct) == 2,['Expecting two forms, one for simple searches'...
    ' and another for advanced'])

formStruct = formStruct(obj.SIMPLE_FORM_INDEX);

formStruct = form_helper_setTextValue(formStruct,'q',searchText);

%JAH TODO: Finish options, the advanced search may now be a part of this ...
% % % 
% % % 
% % % if obj.settings.get
% % %    whichRadio = 1;
% % %    checkMask  = INCLUDE_PATENTS;
% % % else
% % %    whichRadio = 2; 
% % %    checkMask  = true;
% % % end
% % % 
% % % formStruct = form_helper_selectRadio(formStruct,1,whichRadio);
% % % formStruct = form_helper_selectCheckBox(formStruct,1,checkMask);

[jsoup_doc,extras] = form_submit(formStruct,'return_jsoup',true);
obj.search_result  = google_scholar.search_result_page(jsoup_doc);



