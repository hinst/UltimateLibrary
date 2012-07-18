program Test01;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  { you can add units after this }
  SysUtils,
  JobThread;

type

  { TJob }

  TJob = class(IThreadJob)
  public
    constructor Create;
    procedure Execute(const aThread: TJobThread);
    destructor Destroy; override;
  end;

const
  TrackJobConstruction = true;
  TrackJobDestruction = true;

var
  JobCounter: integer;

{ TJob }

constructor TJob.Create;
begin
  inherited Create;
  inc(JobCounter);
  if (TrackJobConstruction) then
    WriteLN('TJob created (', JobCounter, ')');
end;

procedure TJob.Execute(const aThread: TJobThread);
begin
  WriteLN('Some text');
end;

destructor TJob.Destroy;
begin
  dec(JobCounter);
  if (TrackJobDestruction) then
    WriteLN('TJob instance destroyed');
  inherited Destroy;
end;

var
  thread: TJobThread;

begin
  JobCounter := 0;
  thread := TJobThread.Create;
  thread.Add(TJob.Create);
  thread.Add(TJob.Create);
  thread.Add(TJob.Create);
  Thread.FreeOnTerminate := false;
  thread.Start;
  thread.Add(TJob.Create);
  thread.Add(TJob.Create);
  thread.Add(TJob.Create);
  thread.Terminate;
  thread.WaitFor;
  thread.Free;
end.

