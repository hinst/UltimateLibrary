unit NoLogEntity;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,

  LogItem,
  LogEntityFace;

type

  { TNoLog }

  TNoLog = class(TInterfacedObject, ILog)
    procedure Write(const aText: string);
    procedure Write(const aTag: string; const aText: string);
    procedure Write(const aTag: TStandardLogTag; const aText: string);
    procedure Free;
  end;

implementation

{ TNoLog }

procedure TNoLog.Write(const aText: string);
begin
end;

procedure TNoLog.Write(const aTag: string; const aText: string);
begin
end;

procedure TNoLog.Write(const aTag: TStandardLogTag; const aText: string);
begin
end;

procedure TNoLog.Free;
begin
end;

end.

