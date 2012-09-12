unit DebugInterfaces;

{ $DEFINE WRITELN_INTERFACES_QUERY}
{ $DEFINE WRITELN_INTERFACES_REFERENCE_COUNTING}
{ $DEFINE DEBUG_WRITELN_INTERFACES_REFERENCE_COUNTING_STACKTRACE}
{$DEFINE WRITELN_INTERFACES_CONSTRUCTION}
{$DEFINE WRITELN_INTERFACES_DESTRUCTION}

interface

uses
  SysUtils,

  NiceExceptions;

type

  { IReversibleCOM }

  IReversibleCOM = interface(IUnknown) ['{41533565-D461-4D7A-AE4F-32F8D01A4800}']
    function Reverse: pointer; stdcall;
  end;

  IHackableCOM = interface(IReversibleCOM) ['{F0E79C83-4183-474B-ADB7-0D8588BE4980}']
    procedure ClearReferenceCounter; stdcall;
  end;

  { TInterfaced }

  TInterfaced = class(TInterfacedObject, IUnknown, IHackableCOM)
  public
    constructor Create; virtual;
    function QueryInterface(constref iid : tguid; out obj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function Reverse: pointer; stdcall;
    procedure ClearReferenceCounter; stdcall;
    destructor Destroy; override;
  end;

implementation

{ TInterfaced }

constructor TInterfaced.Create;
begin
  inherited Create;
  {$IFDEF WRITELN_INTERFACES_CONSTRUCTION}
  WriteLN('FACE: Constructing ' + ClassName + '....');
  {$ENDIF}
end;

function TInterfaced.QueryInterface(constref iid: tguid; out obj): longint; stdcall;
begin
  result := inherited QueryInterface(iid, obj);

  {$IFDEF WRITELN_INTERFACES_QUERY}
  WriteLN('ID: ' + ClassName + '.Query');
  {$ENDIF}
end;

function TInterfaced._AddRef: longint; stdcall;
begin
  result := InterLockedIncrement(fRefCount);

  {$IFDEF WRITELN_INTERFACES_REFERENCE_COUNTING}
  WriteLN('ID: ' + ClassName + '+REFER =' + IntToStr(RefCount));
  {$IFDEF DEBUG_WRITELN_INTERFACES_REFERENCE_COUNTING_STACKTRACE}
  WriteLN(GetStackTraceText);
  {$ENDIF}
  {$ENDIF}
end;

function TInterfaced._Release: longint; stdcall;
begin
  {$IFDEF WRITELN_INTERFACES_REFERENCE_COUNTING}
  WriteLN('ID: ' + ClassName + '-DEREF =' + IntToStr(RefCount - 1));
  {$IFDEF DEBUG_WRITELN_INTERFACES_REFERENCE_COUNTING_STACKTRACE}
  WriteLN(GetStackTraceText);
  {$ENDIF}
  {$ENDIF}

  result := InterLockedDecrement(fRefCount);
  if result = 0 then
    Free;
end;

function TInterfaced.Reverse: pointer; stdcall;
begin
  result := self;
end;

procedure TInterfaced.ClearReferenceCounter; stdcall;
begin
  fRefCount := 0;
end;

destructor TInterfaced.Destroy;
begin
  {$IFDEF WRITELN_INTERFACES_DESTRUCTION}
  WriteLN('FACE: Destructing ' + ClassName + '...');
  {$ENDIF}
  inherited Destroy;
end;

end.

