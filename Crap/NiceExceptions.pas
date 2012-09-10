unit NiceExceptions;

{$DEFINE DEBUG_WRITELN_FAILED_ASSIGNED_ASSERTION}
{$DEFINE DEBUG_WRITELN_FAILED_ARGUMENT_ASSIGNED_ASSERTION}

interface

uses
  Classes, SysUtils;

type
  EUnassigned = class(Exception);
  EArgumentUnassigned = class(EUnassigned);
  EFileNotFound = class(Exception);
  EIndexOutOfBounds = class(Exception);
  EStackTrace = class(Exception);
  ECritical = class(Exception);

function GetFullExceptionInfo(const aException: Exception): string;
function GetStackTraceText: string;

procedure AssertAssigned(const aPointer: pointer; const aName: string); inline;
procedure AssertArgumentAssigned(const aCondition: boolean; const aArgumentName: string); overload;
procedure AssertArgumentAssigned(const aPointer: pointer; const aArgumentName: string); overload;
function AssertIndexInBounds(const aMin, aIndex, aMax: integer; const aMessage: string): boolean;

procedure AssertFileExists(const aFileName: string); inline;

function IsExceptionCritical(const aException: Exception): boolean;

implementation

function GetFullExceptionInfo(const aException: Exception): string;
var
  FrameNumber, FrameCount: longint;
  Frames: PPointer;
begin
  result := '';
  result := result + 'Exception class: ' + aException.ClassName + sLineBreak;
  result := result + 'Exception message: "' + aException.Message + '"' + sLineBreak;
  if RaiseList = nil then
    exit;
  result := result + BackTraceStrFunc(RaiseList^.Addr) + sLineBreak;
  FrameCount := RaiseList^.Framecount;
  Frames := RaiseList^.Frames;
  for FrameNumber := 0 to FrameCount - 1 do
    result := result + BackTraceStrFunc(Frames[FrameNumber]) + LineEnding;
  result += '(end of stack trace)';
end;

function GetStackTraceText: string;
begin
  result := '';
  try
    raise EStackTrace.Create('Stack Trace');
  except
    on e: Exception do
      result := GetFullExceptionInfo(e);
  end;
end;

procedure AssertAssigned(const aPointer: pointer; const aName: string);
begin
  if aPointer = nil then
  begin
    {$IFDEF DEBUG_WRITELN_FAILED_ASSIGNED_ASSERTION}
    WriteLN('Assertion failed: "' + aName + '" + unassigned');
    {$ENDIF}
    raise EUnassigned.Create(aName);
  end;
end;

procedure AssertArgumentAssigned(const aCondition: boolean; const aArgumentName: string);
begin
  if not aCondition then
  begin
    {$IFDEF DEBUG_WRITELN_FAILED_ARGUMENT_ASSIGNED_ASSERTION}
    WriteLN('Assertion failed: "' + aArgumentName + '" argument unassigned');
    {$ENDIF}
    raise EArgumentUnassigned.Create(aArgumentName);
  end;
end;

procedure AssertArgumentAssigned(const aPointer: pointer; const aArgumentName: string);
begin
  AssertArgumentAssigned(Assigned(aPointer), aArgumentName);
end;

function AssertIndexInBounds(const aMin, aIndex, aMax: integer;
  const aMessage: string): boolean;
begin
  result := (aMin <= aIndex) and (aIndex <= aMax);
  if not result then
    raise EIndexOutOfBounds.Create(aMessage + ' (index is ' + IntToStr(aIndex) + ')');
end;

procedure AssertFileExists(const aFileName: string);
begin
  if not FileExists(aFileName) then
    raise EFileNotFound.Create(aFileName);
end;

function IsExceptionCritical(const aException: Exception): boolean;
begin
  result :=
    aException is EOutOfMemory or
    aException is EOutOfResources or
    aException is EStackOverflow;
end;

end.

