unit DebugInterfaces;

{ $DEFINE DEBUG_INTERFACES}

interface

uses
  SysUtils;

type

  { IReversibleCOM }

  IReversibleCOM = interface ['{41533565-D461-4D7A-AE4F-32F8D01A4800}']
    function Reverse: pointer; stdcall;
  end;

  { TInterfaced }

  TInterfaced = class(TInterfacedObject, IUnknown, IReversibleCOM)
  public
    function QueryInterface(constref iid : tguid;out obj) : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _AddRef : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function _Release : longint;{$IFNDEF WINDOWS}cdecl{$ELSE}stdcall{$ENDIF};
    function Reverse: pointer; stdcall;
    destructor Destroy; override;
  end;

implementation

{ TInterfaced }

function TInterfaced.QueryInterface(constref iid: tguid; out obj): longint; stdcall;
begin
  inherited QueryInterface(iid, obj);
  {$IFDEF DEBUG_INTERFACES}
    WriteLN('ID: ' + ClassName + '.Query');
  {$ENDIF}
end;

function TInterfaced._AddRef: longint; stdcall;
begin
  result := inherited _AddRef;
  {$IFDEF DEBUG_INTERFACES}
    WriteLN('ID: ' + ClassName + '+REFER =' + IntToStr(RefCount));
  {$ENDIF}
end;

function TInterfaced._Release: longint; stdcall;
begin
  {$IFDEF DEBUG_INTERFACES}
    WriteLN('ID: ' + ClassName + '-DEREF =' + IntToStr(RefCount - 1));
  {$ENDIF}
  result := inherited _Release;
end;

function TInterfaced.Reverse: pointer; stdcall;
begin
  result := self;
end;

destructor TInterfaced.Destroy;
begin
  {$IFDEF DEBUG_INTERFACES}
    WriteLN('ID: DY ' + ClassName);
  {$ENDIF}
  inherited Destroy;
end;

end.

