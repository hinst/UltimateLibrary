unit DefaultLogTextFormat;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  LogTextFormat, LogItem;

type

  {
  This class formats the log message in a simple and straightforward way and does not allows any
  format customization. It represents default immutable format for log messages.
  }
  TDefaultLogTextFormat = class(TInterfacedObject, ILogTextFormat)
  public
    constructor Create;
  public
    function Format(const aItem: PLogItem): string;
  end;

implementation

{ TDefaultLogTextFormat }

constructor TDefaultLogTextFormat.Create;
begin
  inherited Create;
end;

function TDefaultLogTextFormat.Format(const aItem: PLogItem): string;
var
  s: string;
begin
  s := '';
  s += IntToStr(aItem^.Number);
  s += ' ' + aItem^.Tag;
  s += ' ' + DateTimeToStr(aItem^.Time);
  if aItem^.Text <> '' then
    s += ': ' + aItem^.Text;
  result := s;
end;

end.

