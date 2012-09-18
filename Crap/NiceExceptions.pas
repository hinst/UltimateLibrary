unit NiceExceptions;

{$DEFINE DEBUG_WRITELN_FAILED_ASSIGNED_ASSERTION}
{$DEFINE DEBUG_WRITELN_FAILED_ARGUMENT_ASSIGNED_ASSERTION}

interface

uses
  SysUtils,
  Classes,
  StrUtils,

  NiceTypes;

type

  EUnassigned = class(Exception)
  public
    constructor Create(const aVariableName: string;
      const aVariableType: TVariableType = TVariableType.Unknown);
  private
    fVariableName: string;
    fVariableType: TVariableType;
  public
    property VariableName: string read fVariableName;
    property VariableType: TVariableType read fVariableType;
  end;

  EFileNotFound = class(Exception);
  EIndexOutOfBounds = class(Exception);
  EStackTrace = class(Exception);
  ECritical = class(Exception);

  EAccessViolationAddress = class helper for EAccessViolation
  public
    function GetAddressAsText: string;
  end;

function GetFullExceptionInfo(const aException: Exception): string;

function GetStackTraceText: string;

procedure AssertAssigned(const aPointer: pointer; const aVariableName: string;
  const aVariableType: TVariableType); inline;

type
  TOneMoreAssignedAssertion = object
  public
    VariableType: TVariableType;
    function Assigned(const aPointer: pointer; const aVariableName: string)
      : TOneMoreAssignedAssertion; inline;
  end;

function AssertsAssigned(const aPointer: pointer; const aVariableName: string;
  const aVariableType: TVariableType): TOneMoreAssignedAssertion;

procedure AssertAssigned(const aCondition: boolean; const aVariableName: string;
  const aVariableType: TVariableType); inline;

procedure AssertIndexInBounds(const aMin, aIndex, aMax: integer; const aMessage: string); inline;

procedure AssertFileExists(const aFileName: string); inline;

function IsExceptionCritical(const aException: Exception): boolean; inline;

implementation

constructor EUnassigned.Create(const aVariableName: string;
  const aVariableType: TVariableType);
begin
  inherited Create('');
  fVariableName := aVariableName;
  fVariableType := aVariableType;
  Message := VariableName + ' (' + VariableType + ') unassigned.';
end;

function EAccessViolationAddress.GetAddressAsText: string;
var
  digits: integer;
begin
  digits := SizeOf(pointer) * 2;
  if Assigned(ExceptionRecord) then
    result := '$' + IntToHex(PtrInt(ExceptionRecord^.ExceptionAddress), digits)
  else
    result := '$' + DupeString('?', digits);
end;

function GetFullExceptionInfo(const aException: Exception): string;
var
  FrameNumber, FrameCount: longint;
  Frames: PPointer;
begin
  result := '';
  result := result + 'Exception class: ' + aException.ClassName + sLineBreak;
  result := result + 'Exception message: "' + aException.Message + '"' + sLineBreak;
  if aException is EAccessViolation then
    result := result + 'Access violation address: '
      + (aException as EAccessViolation).GetAddressAsText + sLineBreak;
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

procedure AssertAssigned(const aPointer: pointer; const aVariableName: string;
  const aVariableType: TVariableType);
begin
  AssertAssigned(Assigned(aPointer), aVariableName, aVariableType);
end;

function TOneMoreAssignedAssertion.Assigned(const aPointer: pointer; const aVariableName: string)
  : TOneMoreAssignedAssertion; inline;
begin
  AssertAssigned(aPointer, aVariableName, VariableType);
end;

function AssertsAssigned(const aPointer: pointer; const aVariableName: string;
  const aVariableType: TVariableType): TOneMoreAssignedAssertion;
begin
  result.VariableType := aVariableType;
  result.Assigned(aPointer, aVariableName);
end;

procedure AssertAssigned(const aCondition: boolean; const aVariableName: string;
  const aVariableType: TVariableType);
begin
  if not aCondition then
    raise EUnassigned.Create(aVariableName, aVariableType);
end;

procedure AssertIndexInBounds(const aMin, aIndex, aMax: integer;
  const aMessage: string);
var
  result: boolean;
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

