unit NiceInterfaces;

{$INTERFACES CORBA}

interface

uses
  SysUtils,

  NiceExceptions;

type

  IReleasable = interface
    procedure Free;
  end;

  IReversible = interface(IReleasable)
    function Reverse: TObject;
  end;


implementation

{ TDesinterfaced }

end.

