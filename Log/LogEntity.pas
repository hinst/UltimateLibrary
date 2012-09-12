unit LogEntity;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils, SyncObjs,
  LogItem, LogManager, LogEntityFace;

type

  { TLog }

  TLog = class(TInterfacedObject, ILog)
  public
    constructor Create(const aManager: TLogManager; const aName: string);
  private
    fManager: TLogManager;
    fName: string;
    fLock: TCriticalSection;
  public
    property Manager: TLogManager read fManager;
    property Name: string read fName;
    procedure Write(const aText: string);
    procedure Write(const aTag: string; const aText: string);
    procedure Write(const aTag: TStandardLogTag; const aText: string);
    destructor Destroy; override;
  end;

implementation

{ TLog }

constructor TLog.Create(const aManager: TLogManager; const aName: string);
begin
  inherited Create;
  fManager := aManager;
  fName := aName;
  fLock := TCriticalSection.Create;
end;

procedure TLog.Write(const aText: string);
begin
  Write(logTagDebug, aText);
end;

procedure TLog.Write(const aTag: string; const aText: string);
var
  pItem: PLogItem;
begin
  fLock.Enter;
  if not assigned(self) then exit;
  new(pItem, Init);
  pItem^.Tag := aTag;
  pItem^.ObjectName := Name;
  pItem^.Text := aText;
  Manager.Write(pItem);
  fLock.Leave;
end;

procedure TLog.Write(const aTag: TStandardLogTag; const aText: string);
var
  tagCaption: string;
begin
  if not assigned(self) then exit;
  tagCaption := manager.StandardLogTagToString.ToString(aTag);
  write(tagCaption, aText);
end;

destructor TLog.Destroy;
begin
  FreeAndNil(fLock);
  inherited Destroy;
end;

end.

