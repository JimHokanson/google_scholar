function advanced_search(obj,options_obj)
%
%
%   INPUTS
%   ===============================
%   options_obj :


doc_obj = jsoup_get_doc(obj.GS_URL);


check_signed_in(obj,doc_obj)


formStruct = form_get(doc_obj);

assert(length(formStruct) == 2,['Expecting two forms, one for simple searches'...
    ' and another for advanced'])

formStruct = formStruct(obj.ADVANCED_FORM_INDEX);








end