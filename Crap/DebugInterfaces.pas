unit DebugInterfaces;

{ $DEFINE WRITELN_INTERFACES_QUERY}
{ $DEFINE WRITELN_INTERFACES_REFERENCE_COUNTING}
{ $DEFINE WRITELN_INTERFACES_CONSTRUCTION}
{ $DEFINE WRITELN_INTERFACES_DESTRUCTION}

interface

uses
  SysUtils,

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
  {$ENDIF}
end;

function TInterfaced._Release: longint; stdcall;
begin
  {$IFDEF WRITELN_INTERFACES_REFERENCE_COUNTING}
  WriteLN('ID: ' + ClassName + '-DEREF =' + IntToStr(RefCount - 1));
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
  {$IFDEF WRITELN_INTERFACES_DESTRUCTION}
  WriteLN('FACE: Destructing ' + ClassName + '...');
  {$ENDIF}
  inherited Destroy;
end;

end.

