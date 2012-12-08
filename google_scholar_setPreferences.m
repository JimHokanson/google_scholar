function [webStr,extras] = google_scholar_setPreferences(varargin)
%google_scholar_setPreferences  Sets scholar preferences
%
%   [webStr,extras] = google_scholar_setPreferences(varargin)
%
%   Currently this code is only setup to allow showing bibliographies
%   as BibTex entries ...
%
%   NOTE: This requires cookies!
%
%   OUTPUTS
%   =======================================================================
%   webStr : text of page after submitting form, usually this redirects to
%            the previous page, this redirects to the main page if PREF_URL
%            is not set
%   extras : see form_submit
%
%   OPTIONAL INPUTS
%   =======================================================================
%   PREF_URL   : (url), link to the preferences page, this is useful if you
%                wish to retain your current search, such that after
%                setting preferences you are returned to the search page
%   BIB_OPTION : (case insensitive)
%       - BibTex
%       - EndNote
%       - RefMan
%       - RefWorks
%
%   IMPROVEMENTS
%   =======================================================================
%   1) I only implemented the most basic preferences, more could be added
%   2) Add ability to query current preferences
%
%   See Also:
%   	form_submit 

DEFINE_CONSTANTS
BIB_OPTION = 'BibTeX';
PREF_URL  = '';
END_DEFINE_CONSTANTS

SCHOLAR_URL  = 'http://scholar.google.com/';
SCHOLAR_TEXT = 'Scholar Preferences';

%The button # to choose for submitting the form, not sure
%what the other buttons do
BUTTON_USE   = 3;

%Getting the preferences url from the main page
%------------------------------------------------
if isempty(PREF_URL)
    web_str  = urlread2(SCHOLAR_URL);
    links    = html_getLinksbyText(web_str,SCHOLAR_TEXT,false);
    PREF_URL = url_getAbsoluteUrl(SCHOLAR_URL,links{1});
    web_str  = urlread2(PREF_URL);
else
    web_str  = urlread2(PREF_URL);
end

%Form processing
%--------------------------------------------------
curForm = form_get(web_str,PREF_URL);
if isempty(BIB_OPTION)
    curForm = form_helper_selectRadio(curForm,'scis','no');
else
    curForm = form_helper_selectRadio(curForm,'scis','yes');
    curForm = form_helper_selectOption(curForm,'scisf','data',BIB_OPTION);
end

curForm = form_helper_chooseButton(curForm,BUTTON_USE);

[webStr,extras] = form_submit(curForm);

