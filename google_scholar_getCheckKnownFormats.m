function varargout = google_scholar_getCheckKnownFormats(requestedFormat)
%google_scholar_getCheckKnownFormats Checks for valid citation format
%
%   FORM 1 - return list of known citation formats
%   knownFormats = google_scholar_getCheckKnownFormats;
%
%
%   FORM 2 - check if a format requested is valid
%   google_scholar_getCheckKnownFormats(requestedFormat)
%       This form returns an error if not present
%
%   INPUTS
%   =======================================================================
%   requestedFormat : (string),  If the requested format is empty, no error 
%   will be thrown as most code should treat this as returning no citation
%   (case INSENSITIVE matching)
%
%   See Also:
%   google_scholar_setPreferences   %function which sets citation format

KNOWN_FORMATS = {'BibTex' 'EndNote' 'RefMan' 'RefWorks'};

if nargin == 0
    varargout{1} = KNOWN_FORMATS;
else
    if ~isempty(requestedFormat)
       isPresent = any(strcmpi(requestedFormat,KNOWN_FORMATS));
       if ~isPresent
          error('The requsted format: %s is not a valid option',requestedFormat)
       end
    end
end

end