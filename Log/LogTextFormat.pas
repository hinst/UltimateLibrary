unit LogTextFormat;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils,
  LogFormat, LogItem;

type
  ILogTextFormat = interface(ILogFormat)
    function Format(const aItem: PLogItem): string;
  end;

  IDemandsLogTextFormat = interface
    procedure SetFormat(const aFormat: ILogTextFormat);
  end;

implementation

end.

