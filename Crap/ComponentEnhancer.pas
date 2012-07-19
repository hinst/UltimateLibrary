unit ComponentEnhancer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TComponentEnhancer }

  TComponentEnhancer = class helper for TComponent
  public
    function GetClassAndName: string;
  end;

implementation

{ TComponentEnhancer }

function TComponentEnhancer.GetClassAndName: string;
begin
  result := ClassName;
  if Name <> '' then
    result += ' "' + Name + '"';
end;

end.

