classdef ZWOASICamera < handle

    properties
    end

    methods

       % Constructor
       function Z=ZWOASICamera()
           if libisloaded('libASICamera2')
               unloadlibrary('libASICamera2')
           end
           classpath=fileparts(mfilename('fullpath'));
           loadlibrary(fullfile(classpath,'lib/libASICamera2.so'),...
               fullfile(classpath,'lib/ASICamera2.h'))

       end

       % destructor
       function delete(Z)
           try
               % unloading prevents crashes on exiting matlab
               unloadlibrary('libASICamera2')
           catch
               % unloading ought to fail silently if there are extant objects
               %  depending on the library, which should happen only if
               %  other ZWOCamera objects still exist.
               % Modulo that unload fails for some other weird reason...
           end
       end

    end

end