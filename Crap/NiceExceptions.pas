unit NiceExceptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  EUnassigned = class(Exception);
  EArgumentUnassigned = class(EUnassigned);
  EFileNotFound = class(Exception);
  EIndexOutOfBounds = class(Exception);

function GetFullExceptionInfo(const aException: Exception): string;

procedure AssertAssigned(const aPointer: pointer; const aName: string); inline;
procedure AssertArgumentAssigned(const aObject: TObject; const aArgumentName: string); inline;
procedure AssertArgumentAssigned(const aObject: boolean; const aArgumentName: string); inline;
function AssertIndexInBounds(const aMin, aIndex, aMax: integer; const aMessage: string): boolean; inline;

procedure AssertFileExists(const aFileName: string); inline;

implementation

function GetFullExceptionInfo(const aException: Exception): string;
var
  FrameNumber, FrameCount: longint;
  Frames: PPointer;
begin
  result := '';
  result += 'Exception class: ' + aException.ClassName + LineEnding;
  result += 'Exception message: ' + aException.Message + LineEnding;
  if RaiseList = nil then
    exit;
  result += BackTraceStrFunc(RaiseList^.Addr) + LineEnding;
  FrameCount := RaiseList^.Framecount;
  Frames := RaiseList^.Frames;
  for FrameNumber := 0 to FrameCount - 1 do
    result += BackTraceStrFunc(Frames[FrameNumber]) + LineEnding;
  result += '(end of stack trace)';
end;

procedure AssertAssigned(const aPointer: pointer; const aName: string);
begin
  if aPointer = nil then
    raise EUnassigned.Create(aName);
end;

procedure AssertArgumentAssigned(const aObject: TObject; const aArgumentName: string);
begin
  AssertArgumentAssigned(Assigned(aObject), aArgumentName);
end;

procedure AssertArgumentAssigned(const aObject: boolean;
  const aArgumentName: string);
begin
  if not aObject then
    raise EArgumentUnassigned.Create(aArgumentName);
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

end.

