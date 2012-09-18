unit NiceInterfaces;

{$INTERFACES CORBA}

interface

uses
  SysUtils,

  NiceExceptions;

type

  IReleasable = interface ['IReleasable']
    procedure Free;
  end;

  IReversible = interface(IReleasable) ['IReversible']
    function Reverse: TObject;
  end;


implementation

end.

