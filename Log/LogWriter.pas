unit LogWriter;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils,
  ReversibleCorbaFace, JobThread, LogItem;

type
  ILogWriter = interface(IReversibleCorba)
    procedure Write(const aThread: TJobThread; const aItem: PLogItem);
    function GetName: string;
    property Name: string read GetName;
  end;

  ELogWriter = class(Exception)

  end;

implementation

end.

