unit NiceInterfaces;

{$mode objfpc}{$H+}
{$interfaces CORBA}

interface

uses
  Classes, SysUtils;

type
  IReversible = interface
    function Reverse: TObject;
  end;

implementation

end.

