function e=enum_member(s,enumeratorclass)
% helper function to cast the string value of an enumerator, as returned by
%  callib, into the equivalent value of the corresponding enumerator class
    [values,names]=enumeration(enumeratorclass);
    e=values(strcmp(s,names));