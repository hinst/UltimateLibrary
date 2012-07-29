unit StringFeatures;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils;

function ZeroToStr(const aInteger: integer; const aLength: integer): string;
function StrHexToLongWord(const aText: string): LongWord;

type
  TStringContainer = record
    s: string;
  end;

var
  easyString: TStringContainer = (s: '');

operator + (const a: TStringContainer; const aString: string): TStringContainer;
operator + (const a: TStringContainer; const aInteger: integer): TStringContainer;

implementation

function ZeroToStr(const aInteger: integer; const aLength: integer): string;
begin
  result := IntToStr(aInteger);
  while Length(result) < aLength do
    result := '0' + result;
end;

function HexToLongWord(const aChar: char): byte; inline;
var
  r: byte;
begin
  case aChar of
    '0': r := 0;
    '1': r := 1;
    '2': r := 2;
    '3': r := 3;
    '4': r := 4;
    '5': r := 5;
    '6': r := 6;
    '7': r := 7;
    '8': r := 8;
    '9': r := 9;
    'A': r := 10;
    'B': r := 11;
    'C': r := 12;
    'D': r := 13;
    'E': r := 14;
    'F': r := 15;
  end;
  result := r;
end;

function StrHexToLongWord(const aText: string): LongWord;
var
  i, multiplier: integer;
begin
  result := 0;
  if Length(aText) <> 6 then
    raise EFormatError.Create('Not a hex: "' + aText + '"');
  multiplier := 1;
  for i := 6 downto 1 do
  begin
    inc(result, HexToLongWord(aText[i]) * multiplier);
    multiplier := 16 * multiplier;
  end;
end;

operator + (const a: TStringContainer; const aString: string): TStringContainer;
begin
  result.s := a.s + aString;
end;

operator + (const a: TStringContainer; const aInteger: integer): TStringContainer;
begin
  result.s := a.s + IntToStr(aInteger);
end;

end.

