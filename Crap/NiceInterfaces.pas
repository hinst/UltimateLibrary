unit NiceInterfaces;

{$mode objfpc}{$H+}
{$interfaces CORBA}

interface

uses
  Classes, SysUtils;

type

  IReleasable = interface
    procedure Free;
  end;

  IReversible = interface(IReleasable)
    function Reverse: TObject;
  end;

implementation

end.

