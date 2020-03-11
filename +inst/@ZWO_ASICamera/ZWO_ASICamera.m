classdef ZWO_ASICamera < handle

    properties
    end

    methods

       % Constructor
       function Z=ZWO_ASICamera()
           if libisloaded('libASICamera2')
               unloadlibrary('libASICamera2')
           end
           classpath=fileparts(mfilename('fullpath'));
           loadlibrary(fullfile(classpath,'lib/libASICamera2.so'),...
               fullfile(classpath,'lib/ASICamera2.h'))

       end

       % destructor
       function delete(Z)
       end

    end

end