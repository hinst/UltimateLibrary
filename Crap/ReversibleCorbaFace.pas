unit ReversibleCorbaFace;

{$mode objfpc}{$H+}
{$interfaces CORBA}

interface

uses
  Classes, SysUtils;

type
  IReversibleCorba = interface
    function GetMe: TObject;
    property Me: TObject read GetMe;
  end;

implementation

end.

