unit DebugUtilities;

{$DEFINE INLINE_THIS_UNIT}

interface

uses
  SysUtils,

  DebugInterfaces;

function PointerToString(const aPointer: pointer): string;
  {$IFDEF INLINE_THIS_UNIT} inline; {$ENDIF}

function InterfaceActualObjectPointerToString(const aInterface: IUnknown): string;
  {$IFDEF INLINE_THIS_UNIT} inline; {$ENDIF}

function IAOPTS(const aFace: IUnknown): string;
  {$IFDEF INLINE_THIS_UNIT} inline; {$ENDIF}

implementation

function PointerToString(const aPointer: pointer): string;
  {$IFDEF INLINE_THIS_UNIT} inline; {$ENDIF}
begin
  result := '';
  {$IFDEF WIN32}
    result := '$' + IntToHex(DWord(aPointer), 2 * SizeOf(pointer));
  {$ENDIF}
  {$IFDEF WIN64}
    result := '$' + IntToHex(QWord(aPointer), 2 * SizeOf(pointer));
  {$ENDIF}
end;

function InterfaceActualObjectPointerToString(const aInterface: IUnknown): string;
  {$IFDEF INLINE_THIS_UNIT} inline; {$ENDIF}
var
  reversible: IReversibleCOM;
begin
  if aInterface = nil then
    exit('NIL');
  if aInterface is IReversibleCOM then
    result := PointerToString((aInterface as IReversibleCOM).Reverse) + ' (DAO@SS)'
  else
    result := 'Not reversible';
end;

function IAOPTS(const aFace: IUnknown): string;
  {$IFDEF INLINE_THIS_UNIT} inline; {$ENDIF}
begin
  result := InterfaceActualObjectPointerToString(aFace);
end;

end.

