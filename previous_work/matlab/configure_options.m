function options = configure_options(options, field, val)

if nargin > 1 % change field
    assert(isfield(options, field), 'Invalid field')
    options.(field) = val;
    
else  % set default configuration
    if strcmp(options, 'sift') 
        options = default_sift;        
    else
        error('Invalid configuration request')
    end    
end

%
%
%

function options = default_sift()
% See OpenCV reference manual v2.4.4.0 Section 14.1 page 633
options.features = 100;
options.octaves = 3;
options.contrast = 0.04;
options.edge = 10;
options.sigma = 1.6;
