unit LogFormat;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils;

type
  ILogFormat = interface
  end;

  ELogFormat = class(Exception)
  end;

implementation

end.

