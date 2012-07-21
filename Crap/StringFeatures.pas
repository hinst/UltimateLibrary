unit StringFeatures;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils;

function ZeroToStr(const aInteger: integer; const aLength: integer): string;

implementation

function ZeroToStr(const aInteger: integer; const aLength: integer): string;
begin
  result := IntToStr(aInteger);
  while Length(result) < aLength do
    result := '0' + result;
end;

end.

