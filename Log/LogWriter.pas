unit LogWriter;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils,
  JobThread, LogItem;

type
  ILogWriter = interface
    procedure Write(const aThread: TJobThread; const aItem: PLogItem);
    function GetName: string;
    property Name: string read GetName;
  end;

implementation

end.

