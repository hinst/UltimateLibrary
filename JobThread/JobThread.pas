unit JobThread;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes, SysUtils,
  SyncObjs,
  FPListEnhancer, ThreadEnhancer;

type

  TJobThread = class;

  IThreadJob = interface
    procedure Execute(const aThread: TJobThread);
    procedure Free;
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
    fJobs: TFPList;
    fJobsCS: TCriticalSection;
    fExecutedJobs: TFPList;
    fWaitInterval: integer;
    fTerminated: boolean;
  protected
    property Jobs: TFPList read fJobs;
    property JobsCS: TCriticalSection read fJobsCS;
    property ExecutedJobs: TFPList read fExecutedJobs;
    procedure Initialize;
    function ExtractFirst: IThreadJob;
    function GetJobCount: integer;
    procedure Execute; override;
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
    procedure ReleaseExecutedJobs;
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
  fJobs := TFPList.Create;
  fJobsCS := TCriticalSection.Create;
  fExecutedJobs := TFPList.Create;
  fWaitInterval := DefaultWaitInterval;
  fTerminated := false;
end;

function TJobThread.ExtractFirst: IThreadJob;
begin
  JobsCS.Enter;
  result := IThreadJob(Jobs.First);
  Jobs.DeleteFirst;
  JobsCS.Leave;
end;

function TJobThread.GetJobCount: integer;
begin
  JobsCS.Enter;
  result := Jobs.Count;
  JobsCS.Leave;
end;

procedure TJobThread.Execute;
var
  job: IThreadJob;
begin
  repeat
    while JobCount > 0 do
    begin
      job := ExtractFirst;
      Execute(job);
      ExecutedJobs.Add(job);
    end;
    Sleep(WaitInterval);
    if fTerminated and (JobCount = 0) then
      break;
  until false;
end;

procedure TJobThread.Execute(const aJob: IThreadJob);
begin
  try
    aJob.Execute(self);
  except
    on e: Exception do
      OnException(e);
  end;
end;

procedure TJobThread.OnException(const aException: Exception);
begin
  // nothing to do here
end;

procedure TJobThread.Finalize;
begin
  FreeAndNil(fJobs);
  FreeAndNil(fJobsCS);
  ReleaseExecutedJobs;
  FreeAndNil(fExecutedJobs);
end;

function TJobThread.Sync(const aJob: IThreadJob): IThreadJob;
begin
  result := TThreadJobSynchronizer.Create(aJob);
end;

procedure TJobThread.Add(const aJob: IThreadJob);
begin
  JobsCS.Enter;
  Jobs.Add(aJob);
  JobsCS.Leave;
end;

procedure TJobThread.Terminate;
begin
  fTerminated := true;
end;

procedure TJobThread.ReleaseExecutedJobs;
var
  p: pointer;
  j: IThreadJob;
begin
  for p in ExecutedJobs do
  begin
    j := IThreadJob(p);
    j.Free;
  end;
  ExecutedJobs.Clear;
end;

destructor TJobThread.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

end.



