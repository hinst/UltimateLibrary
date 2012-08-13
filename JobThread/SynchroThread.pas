unit SynchroThread;

{$mode objfpc}{$H+}
{$interfaces CORBA}

interface

uses
  Classes,
  SysUtils,
  SyncObjs,

  BatchProcessing,
  LogEntityFace,
  NiceExceptions;

type

  ISynchroJob = interface
    procedure Execute;
    procedure Free;
  end;

  { TSynchroThread }

  TSynchroThread = class(TComponent)
  public
    constructor Create(const anOwner: TComponent); reintroduce;
  private type
    TItem = class
    public
      constructor Create(const aJob: ISynchroJob);
    private
      fJob: ISynchroJob;
      fId: integer;
      fEvent: TSimpleEvent;
      procedure Initialize(const aJob: ISynchroJob);
      procedure Finalize;
    public const
      MAX_ID = 100;
    public
      property Job: ISynchroJob read fJob;
      property Id: integer read fId;
      property Event: TSimpleEvent read fEvent;
      destructor Destroy; override;
    end;
  private
    fDEBUG: boolean;
    fLog: ILog;
    fBatch: TBatchProcessing;
    fCurrentId: integer;
    function GetNextId: integer;
    procedure Initialize;
    procedure Finalize;
  public const
    TIMEOUT = 10 * 1000;
  public
    property DEBUG: boolean read fDEBUG write fDEBUG;
    property Log: ILog read fLog write fLog;
    property Batch: TBatchProcessing read fBatch;
    property NextId: integer read GetNextId;
    procedure EnableDebug(const aLog: ILog);
    function Add(const aJob: ISynchroJob): TItem;
    procedure Execute(const aJob: ISynchroJob);
    function ExecuteOne: boolean;
    destructor Destroy; override;
  end;

  { TSimpleSynchroJob }

  TSimpleSynchroJob = class(ISynchroJob)
  public type
    TProcedure = procedure of object;
  public
    constructor Create(const aMethod: TProcedure);
  private
    fMethod: TProcedure;
  public
    property Method: TProcedure read fMethod;
    procedure Execute;
  end;

implementation

procedure ReleaseItem(const aItem: pointer);
var
  item: TSynchroThread.TItem;
begin
  item := TSynchroThread.TItem(aItem);
  item.Free;
end;

{ TSimpleSynchroJob }

constructor TSimpleSynchroJob.Create(const aMethod: TProcedure);
begin
  inherited Create;
  fMethod := aMethod;
end;

procedure TSimpleSynchroJob.Execute;
begin
  Method();
end;

{ TSynchroThread.TItem }

constructor TSynchroThread.TItem.Create(const aJob: ISynchroJob);
begin
  inherited Create;
  Initialize(aJob);
end;

procedure TSynchroThread.TItem.Initialize(const aJob: ISynchroJob);
begin
  fJob := aJob;
  fEvent := TSimpleEvent.Create;
end;

procedure TSynchroThread.TItem.Finalize;
begin
  Job.Free;
  Event.Free;
end;

destructor TSynchroThread.TItem.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

{ TSynchroThread }

constructor TSynchroThread.Create(const anOwner: TComponent);
begin
  inherited Create(anOwner);
  Initialize;
end;

function TSynchroThread.GetNextId: integer;
begin
  inc(fCurrentId);
  result := fCurrentId;
end;

procedure TSynchroThread.Initialize;
begin
  fDEBUG := false;
  fLog := nil;
  fBatch := TBatchProcessing.Create;
  Batch.Releaser := @ReleaseItem;
  fCurrentId := 0;
end;

procedure TSynchroThread.Finalize;
begin
  FreeAndNil(fBatch);
  FreeLog(fLog);
end;

procedure TSynchroThread.EnableDebug(const aLog: ILog);
begin
  fDEBUG := true;
  fLog := aLog;
end;

function TSynchroThread.Add(const aJob: ISynchroJob): TItem;
var
  item: TItem;
begin
  item := TItem.Create(aJob);
  item.fId := NextId;
  if DEBUG then
  begin
    Log.Write('Now adding job: #' + IntToStr(item.Id));
    AssertAssigned(Batch, 'Batch');
  end;
  Batch.Add(item);
  result := item;
end;

procedure TSynchroThread.Execute(const aJob: ISynchroJob);
var
  item: TItem;
begin
  if ThreadID = MainThreadID then
  begin
    if DEBUG then
      Log.Write('Now executing directly #' + IntToStr(item.Id));
    aJob.Execute; // 0. Direct Execute
  end
  else
  begin
    item := Add(aJob); // 1. ADD
    if DEBUG then
      Log.Write('Now waiting... #' + IntToStr(item.Id));
    item.Event.WaitFor(TIMEOUT); // 2. WAIT
    if DEBUG then
      Log.Write('Closed #' + IntToStr(item.Id));
  end;
  Batch.MarkExecuted(item); // 3. REMOVE
  if DEBUG then
    Log.Write('Added to executed list #' + IntToStr(item.Id));
end;

function TSynchroThread.ExecuteOne: boolean;
var
  item: TItem;
begin
  item := TItem(Batch.Extract);
  result := item <> nil;
  if not result then exit;
  if DEBUG then
    Log.Write('Now executing #' + IntToStr(item.Id));
  try
    item.job.Execute;
  except
    on e: Exception do
    begin
      if DEBUG then
        Log.Write('An exception occured: ' + LineEnding + GetFullExceptionInfo(e));
      raise;
    end;
  end;
  if DEBUG then
    Log.Write('Now sending event #' + IntToStr(item.Id));
  item.Event.SetEvent;
end;

destructor TSynchroThread.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

end.

