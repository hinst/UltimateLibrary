unit ConsoleLogWriter;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils,
  LogWriter, LogItem, JobThread, LogTextFormat;

type

  { TConsoleLogWriter }

  TConsoleLogWriter = class(TComponent, ILogWriter, IDemandsLogTextFormat)
  private
    fFormat: ILogTextFormat;
    procedure SetFormat(const aFormat: ILogTextFormat);
    function GetName: string;
  public
    property Format: ILogTextFormat read fFormat write fFormat;
    procedure Write(const aThread: TJobThread; const aItem: PLogItem);
  end;

implementation

{ TConsoleLogWriter }

procedure TConsoleLogWriter.SetFormat(const aFormat: ILogTextFormat);
begin
  fFormat := aFormat;
end;

function TConsoleLogWriter.GetName: string;
begin
  result := name;
end;

procedure TConsoleLogWriter.Write(const aThread: TJobThread;
  const aItem: PLogItem);
var
  text: string;
begin
  if IsConsole then
  begin
    if not Assigned(Format) then
      WriteLN('Console Log Writer Error: Format property unassigned.');
    text := Format.Format(aItem);
    WriteLN(text);
  end;
end;

end.

