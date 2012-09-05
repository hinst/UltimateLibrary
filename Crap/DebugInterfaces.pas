unit DebugInterfaces;

{ $DEFINE DEBUG_INTERFACES_QUERY}
{ $DEFINE DEBUG_INTERFACES_ADD_DE_REF}
{ $DEFINE DEBUG_INTERFACES_ADD_DE_REF_STTCE}
{ $DEFINE DEBUG_INTERFACES_TRACK_DESTRUCTION}

interface

uses
  SysUtils,
  gmap,
  gutil,

  NiceExceptions;

type

  { IReversibleCOM }

  IReversibleCOM = interface(IUnknown) ['{41533565-D461-4D7A-AE4F-32F8D01A4800}']
    function Reverse: pointer; stdcall;
  end;

  IReleasableCOM = interface(IUnknown) ['{E197C30B-BD04-4B91-A48D-429621EB125A}']
    procedure Release; stdcall;
  end;

  { TInterfaced }

  TInterfaced = class(TInterfacedObject, IUnknown, IReversibleCOM)
  public
    constructor Create; virtual;
    function QueryInterface(constref iid : tguid; out obj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function Reverse: pointer; stdcall;
    destructor Destroy; override;
  end;

implementation

type

  { TInterfacedLess }

  TInterfacedLess = class
    class function C(a, b: TInterfaced): boolean; inline;
  end;

  TFaceTable = specialize TMap<TInterfaced, boolean, TInterfacedLess>;

var
  GlobalFaceTable: TFaceTable;

{ TInterfaced }

constructor TInterfaced.Create;
begin
  inherited Create;
end;

function TInterfaced.QueryInterface(constref iid: tguid; out obj): longint; stdcall;
begin
  result := inherited QueryInterface(iid, obj);

  {$IFDEF DEBUG_INTERFACES_QUERY}
  WriteLN('ID: ' + ClassName + '.Query');
  {$ENDIF}
end;

function TInterfaced._AddRef: longint; stdcall;
begin
  result := InterLockedIncrement(fRefCount);

  {$IFDEF DEBUG_INTERFACES_ADD_DE_REF}
  WriteLN('ID: ' + ClassName + '+REFER =' + IntToStr(RefCount));
  {$IFDEF DEBUG_INTERFACES_ADD_DE_REF_STTCE}
  WriteLN(GetStackTraceText);
  {$ENDIF}
  {$ENDIF}
end;

function TInterfaced._Release: longint; stdcall;
begin
  {$IFDEF DEBUG_INTERFACES_ADD_DE_REF}
  WriteLN('ID: ' + ClassName + '-DEREF =' + IntToStr(RefCount - 1));
  {$IFDEF DEBUG_INTERFACES_ADD_DE_REF_STTCE}
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

destructor TInterfaced.Destroy;
begin
  {$IFDEF DEBUG_INTERFACES_TRACK_DESTRUCTION}
  WriteLN('ID: DY ' + ClassName);
  {$ENDIF}
  inherited Destroy;
end;


{ TInterfacedLess }

class function TInterfacedLess.C(a, b: TInterfaced): boolean;
begin
  result := pointer(a) < pointer(b);
end;

initialization
  GlobalFaceTable := TFaceTable.Create;
finalization
  GlobalFaceTable.Free;
end.

