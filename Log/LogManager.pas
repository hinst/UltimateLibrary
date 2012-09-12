unit LogManager;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils,
  LogWriter, LogItem, JobThread;

type

  {
  TLogManager
  After creation it is necessary to assign StandardLogTagToString property.
  }

  TLogManager = class(TComponent)
  public
    constructor Create(const aOwner: TComponent); reintroduce;
  private
    fDeferredWriters: TFPList;
    fImmediateWriters: TFPList;
    fJobThread: TJobThread;
    fStandardLogTagToString: IStandardLogTagToString;
    fItemCounter: integer;
    procedure Initialize;
    procedure WriteDeferred(const aItem: PLogItem);
    procedure WriteImmediate(const aItem: PLogItem);
    procedure Finalize;
  public
    property DeferredWriters: TFPList read fDeferredWriters;
    property ImmediateWriters: TFPList read fImmediateWriters;
    property JobThread: TJobThread read fJobThread;
    property StandardLogTagToString: IStandardLogTagToString
      read fStandardLogTagToString write fStandardLogTagToString;
    property ItemCounter: integer read fItemCounter;
    procedure Write(const aItem: PLogItem);
    destructor Destroy; override;
  end;

implementation

type

  { TWriteLogItemJob }

  TWriteLogItemJob = class(TInterfacedObject, IThreadJob)
  public
    constructor Create(const aItem: PLogItem; const aWriters: TFPList);
  private
    fItem: PLogItem;
    fWriters: TFPList;
  public
    property Item: PLogItem read fItem;
    property Writers: TFPList read fWriters;
    procedure Execute(const aThread: TJobThread);
  end;

{ TWriteLogItemJob }

constructor TWriteLogItemJob.Create(const aItem: PLogItem; const aWriters: TFPList);
begin
  inherited Create;
  fItem := aItem;
  fWriters := aWriters;
end;

procedure TWriteLogItemJob.Execute(const aThread: TJobThread);
var
  p: pointer;
  writer: ILogWriter;
begin
  for p in Writers do
  begin
    writer := ILogWriter(p);
    writer.Write(aThread, Item);
  end;
  dispose(Item, Done);
end;

{ TLogManager }

constructor TLogManager.Create(const aOwner: TComponent);
begin
  inherited Create(aOwner);
  Initialize;
end;

procedure TLogManager.Initialize;
begin
  fDeferredWriters := TFPList.Create;
  fImmediateWriters := TFPList.Create;
  fJobThread := TJobThread.Create;
  JobThread.Start; // Why no? We can start it right now. Idea: make deferred start.
  fItemCounter := 0;
end;

procedure TLogManager.WriteDeferred(const aItem: PLogItem);
var
  job: IThreadJob;
begin
  job := TWriteLogItemJob.Create(aItem, DeferredWriters);
  JobThread.Add(job);
end;

procedure TLogManager.WriteImmediate(const aItem: PLogItem);
var
  p: pointer;
  writer: ILogWriter;
begin
  for p in ImmediateWriters do
  begin
    writer := ILogWriter(p);
    writer.Write(nil, aItem);
  end;
end;

procedure TLogManager.Finalize;
begin
  JobThread.Terminate;
  JobThread.WaitFor;
  FreeAndNil(fJobThread);
  FreeAndNil(fDeferredWriters);
  FreeAndNil(fImmediateWriters);
end;

procedure TLogManager.Write(const aItem: PLogItem);
begin
  inc(fItemCounter);
  aItem^.Number := ItemCounter;
  WriteImmediate(aItem);
  WriteDeferred(aItem);
end;

destructor TLogManager.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

end.

