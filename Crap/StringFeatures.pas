unit StringFeatures;

interface

uses
  Classes,
  strings,
  SysUtils,
  StrUtils;

function ZeroToStr(const aInteger: integer; const aLength: integer): string; inline;
function CopyToPChar(const aString: string): PChar;
function CopyPCharToString(const aChar: PChar): string;
function StrHexToLongWord(const aText: string): LongWord;
function PureStringReplace(const aText, aFrom, aTo: AnsiString): AnsiString; inline;

type
  TStringContainer = record
    s: string;
  end;

var
  easyString: TStringContainer = (s: '');

operator + (const a: TStringContainer; const aString: string): TStringContainer;
operator + (const a: TStringContainer; const aInteger: integer): TStringContainer;

implementation

function ZeroToStr(const aInteger: integer; const aLength: integer): string; inline;
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

function CopyToPChar(const aString: string): PChar;
begin
  result := PChar(GetMemory(Length(aString) + 1));
  result := StrPCopy(result, PChar(aString));
end;

function CopyPCharToString(const aChar: PChar): string;
begin
  result := string(aChar);
end;

function StrHexToLongWord(const aText: string): LongWord;
var
  i: integer;
  multiplier: LongWord;
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

function SingleStringReplace(var aText: AnsiString; const aFrom, aTo: AnsiString): boolean;
var
  position: integer;
begin
  position := Pos(aFrom, aText);
  result := position > 0;
  if not result then exit;
  Delete(aText, position, Length(aFrom));
  Insert(aTo, aText, position);
end;

function PureStringReplace(const aText, aFrom, aTo: AnsiString): AnsiString;
begin
  result := aText;
  while SingleStringReplace(result, aFrom, aTo) do;
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

