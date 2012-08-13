unit BatchProcessing;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Contnrs,
  SyncObjs,

  NiceExceptions;

type

  { TBatchProcessing }

  TBatchProcessing = class
  public
    constructor Create;
  public type
    TItemProcedure = procedure(const aItem: pointer);
  private
    fQue: TQueue;
    fQueLock: TCriticalSection;
    fExecuteds: TQueue;
    fExecutedsLock: TCriticalSection;
    fReleaser: TItemProcedure;
    procedure Initialize;
    procedure ReleaseExecuteds;
    procedure Finalize;
  public
    property Que: TQueue read fQue;
    property QueLock: TCriticalSection read fQueLock;
    property Executeds: TQueue read fExecuteds;
    property ExecutedsLock: TCriticalSection read fExecutedsLock;
    property Releaser: TItemProcedure read fReleaser write fReleaser;
    procedure Add(const aItem: pointer);
    function Extract: pointer;
    procedure MarkExecuted(const aItem: pointer);
    destructor Destroy; override;
  end;

implementation

{ TBatchProcessing }

constructor TBatchProcessing.Create;
begin
  inherited Create;
  Initialize;
end;

procedure TBatchProcessing.Initialize;
begin
  fQue := TQueue.Create;
  fQueLock := TCriticalSection.Create;
  fExecuteds := TQueue.Create;
  fExecutedsLock := TCriticalSection.Create;
  fReleaser := nil;
end;

procedure TBatchProcessing.ReleaseExecuteds;
var
  p: pointer;
begin
  ExecutedsLock.Enter;
  while Executeds.Count > 0 do
  begin
    p := Executeds.Pop;
    if Releaser <> nil then
      Releaser(p);
  end;
  ExecutedsLock.Leave;
end;

procedure TBatchProcessing.Finalize;
begin
  FreeAndNil(fQue);
  FreeAndNil(fQueLock);
  ReleaseExecuteds;
  FreeAndNil(fExecuteds);
  FreeAndNil(fExecutedsLock);
end;

procedure TBatchProcessing.Add(const aItem: pointer);
begin
  QueLock.Enter;
  Que.Push(aItem);
  QueLock.Leave;
end;

function TBatchProcessing.Extract: pointer;
begin
  QueLock.Enter;
  result := nil;
  if Que.Count > 0 then
    result := Que.Pop;
  QueLock.Leave;
end;

procedure TBatchProcessing.MarkExecuted(const aItem: pointer);
begin
  ExecutedsLock.Enter;
  Executeds.Push(aItem);
  ExecutedsLock.Leave;
end;

destructor TBatchProcessing.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

end.

