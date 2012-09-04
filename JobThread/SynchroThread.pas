unit SynchroThread;

{$mode objfpc}{$H+}
{$interfaces CORBA}

interface

uses
  Classes,
  SysUtils,
  SyncObjs,

  BatchProcessing,
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
    fBatch: TBatchProcessing;
    fCurrentId: integer;
    function GetNextId: integer;
    procedure Initialize;
    procedure Add(const aItem: TItem);
    procedure Finalize;
  public const
    TIMEOUT = 10 * 1000;
  public
    property Batch: TBatchProcessing read fBatch;
    property NextId: integer read GetNextId;
    function CreateItem(const aJob: ISynchroJob): TItem;
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

procedure TSynchroThread.Add(const aItem: TItem);
begin
  Batch.Add(aItem);
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
  fBatch := TBatchProcessing.Create;
  Batch.Releaser := @ReleaseItem;
  fCurrentId := 0;
end;

procedure TSynchroThread.Finalize;
begin
  FreeAndNil(fBatch);
end;

function TSynchroThread.CreateItem(const aJob: ISynchroJob): TItem;
begin
  result := TItem.Create(aJob);
  result.fId := NextId;
end;

procedure TSynchroThread.Execute(const aJob: ISynchroJob);
var
  item: TItem;
begin
  item := CreateItem(aJob);
  if ThreadID = MainThreadID then
  begin // DIRECT EXECUTE
    aJob.Execute;
  end
  else
  begin // WAIT FOR EXECUTE
    Add(item);
    item.Event.WaitFor(TIMEOUT);
  end;
  Batch.MarkExecuted(item);
end;

function TSynchroThread.ExecuteOne: boolean;
var
  item: TItem;
begin
  item := TItem(Batch.Extract);
  result := item <> nil;
  if not result then exit;
  try
    item.job.Execute;
  except
    on e: Exception do
    begin
      raise;
    end;
  end;
  item.Event.SetEvent;
end;

destructor TSynchroThread.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

end.

