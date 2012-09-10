unit JobThread;

{$DEFINE WRITELN_JOBTHREAD_EXCEPTION}
{ $DEFINE WRITELN_DEBUG_JOB_EXECUTION}
{ $DEFINE WRITELN_DEBUG_JOB_ADDITION}

interface

uses
  Classes,
  SysUtils,
  SyncObjs,
  fgl,

  NiceExceptions,
  FPListEnhancer,
  ThreadEnhancer;

type

  TJobThread = class;

  IThreadJob = interface ['{40F3AD56-1BD0-41AA-8DC3-0F496AFD3467}']
    procedure Execute(const aThread: TJobThread);
  end;

  { TThreadJobIndirection }

  TThreadJobIndirection = class
  public
    constructor Create(const aJob: IThreadJob; const aThread: TJobThread);
  private
    fJob: IThreadJob;
    fThread: TJobThread;
  public
    property Job: IThreadJob read fJob;
    property Thread: TJobThread read fThread;
    procedure Execute;
  end;

  { TThreadJobSynchronizer }

  TThreadJobSynchronizer = class(TInterfacedObject, IThreadJob)
  public
    constructor Create(const aJob: IThreadJob);
  private
    fJob: IThreadJob;
    fOwns: boolean;
  public
    property Job: IThreadJob read fJob;
    const DefaultOwns = true;
    property Owns: boolean read fOwns write fOwns;
    procedure Execute(const aThread: TJobThread);
    destructor Destroy; override;
  end;

  { TJobThread }

  TJobThread = class(TThread)
  public
    constructor Create; reintroduce;
  private
    fJobs: TInterfaceList;
    fJobsCS: TCriticalSection;
    fWaitInterval: integer;
    fTerminated: boolean;
  protected
    property Jobs: TInterfaceList read fJobs;
    property JobsCS: TCriticalSection read fJobsCS;
    procedure Initialize;
    function ExtractFirst: IThreadJob;
    function GetJobCount: integer;
    procedure Execute; override;
    procedure ExecuteFirst;
    procedure Execute(const aJob: IThreadJob);
    procedure OnException(const aException: Exception); virtual;
    procedure Finalize;
  public
    const DefaultWaitInterval = 300;
    property WaitInterval: integer read fWaitInterval;
    property JobCount: integer read GetJobCount;
    property Terminated: boolean read fTerminated;
    function Sync(const aJob: IThreadJob): IThreadJob;
    procedure Add(const aJob: IThreadJob);
    procedure Terminate;
    destructor Destroy; override;
  end;

implementation

{ TThreadJobIndirection }

constructor TThreadJobIndirection.Create(const aJob: IThreadJob;
  const aThread: TJobThread);
begin
  inherited Create;
  fJob := aJob;
  fThread := aThread;
end;

procedure TThreadJobIndirection.Execute;
begin
  Job.Execute(Thread);
end;

{ TThreadJobSynchronizer }

constructor TThreadJobSynchronizer.Create(const aJob: IThreadJob);
begin
  inherited Create;
  fJob := aJob;
  fOwns := DefaultOwns;
end;

procedure TThreadJobSynchronizer.Execute(const aThread: TJobThread);
var
  indirection: TThreadJobIndirection;
begin
  indirection := TThreadJobIndirection.Create(Job, aThread);
  aThread.Snchrnze( @indirection.Execute );
  indirection.Free;
end;

destructor TThreadJobSynchronizer.Destroy;
begin
  inherited Destroy;
end;

{ TJobThread }

constructor TJobThread.Create;
begin
  inherited Create(true);
  Initialize;
end;

procedure TJobThread.Initialize;
begin
  fJobs := TInterfaceList.Create;
  fJobsCS := TCriticalSection.Create;
  fWaitInterval := DefaultWaitInterval;
  fTerminated := false;
end;

function TJobThread.ExtractFirst: IThreadJob;
begin
  JobsCS.Enter;
  result := Jobs.First as IThreadJob;
  Jobs.Delete(0);
  JobsCS.Leave;
end;

function TJobThread.GetJobCount: integer;
begin
  JobsCS.Enter;
  result := Jobs.Count;
  JobsCS.Leave;
end;

procedure TJobThread.Execute;
begin
  repeat
    while JobCount > 0 do
      ExecuteFirst;
    Sleep(WaitInterval);
    if fTerminated and (JobCount = 0) then
      break;
  until false;
end;

procedure TJobThread.ExecuteFirst;
var
  job: IThreadJob;
begin
  job := ExtractFirst;
  Execute(job);
end;

procedure TJobThread.Execute(const aJob: IThreadJob);
begin
  AssertArgumentAssigned(aJob, 'aJob');
  {$IFDEF WRITELN_DEBUG_JOB_EXECUTION}
  WriteLN('Now executing thread job...');
  {$ENDIF}
  try
    aJob.Execute(self);
  except
    on e: Exception do
      OnException(e);
  end;
  {$IFDEF WRITELN_DEBUG_JOB_EXECUTION}
  WriteLN('Thread job executed.');
  {$ENDIF}
end;

procedure TJobThread.OnException(const aException: Exception);
begin
  {$IFDEF WRITELN_JOBTHREAD_EXCEPTION}
  WriteLN('Exception in job thread');
  WriteLN(GetFullExceptionInfo(aException));
  {$ENDIF}
  if IsExceptionCritical(aException) then
    raise aException;
end;

procedure TJobThread.Finalize;
begin
  FreeAndNil(fJobs);
  FreeAndNil(fJobsCS);
end;

function TJobThread.Sync(const aJob: IThreadJob): IThreadJob;
begin
  result := TThreadJobSynchronizer.Create(aJob);
end;

procedure TJobThread.Add(const aJob: IThreadJob);
begin
  AssertArgumentAssigned(aJob, 'aJob');
  JobsCS.Enter;
  {$IFDEF WRITELN_DEBUG_JOB_ADDITION}
  WriteLN('Now adding job...');
  {$ENDIF}
  Jobs.Add(aJob);
  JobsCS.Leave;
end;

procedure TJobThread.Terminate;
begin
  fTerminated := true;
end;

destructor TJobThread.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

end.



