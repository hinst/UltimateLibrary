unit NiceTypes;

{$SCOPEDENUMS ON}

interface

uses
  SysUtils,
  Classes,
  TypInfo;

type

  TBooleanArray = array of boolean;
  T2DBooleanArray = array of TBooleanArray;

  TIntegerArray = array of integer;
  T2DIntegerArray = array of TIntegerArray;

  TVariableType = (
    Unknown,
    Field,
    Propertie,
    Argument,
    Local,
    Global
  );

procedure Falsify2DBooleanArray(var a: T2DBooleanArray);
procedure Fill2DIntegerArray(var a: T2DIntegerArray; const aValue: integer);
operator := (const aVariableType: TVariableType): string;

implementation

procedure Falsify2DBooleanArray(var a: T2DBooleanArray);
var
  x, y: integer;
begin
  for x := 0 to Length(a) - 1 do
    for y := 0 to Length(a[x]) - 1 do
      a[x, y] := false;
end;

procedure Fill2DIntegerArray(var a: T2DIntegerArray; const aValue: integer);
var
  x, y: integer;
begin
  for x := 0 to Length(a) - 1 do
    for y := 0 to Length(a[x]) - 1 do
      a[x, y] := aValue;
end;

operator := (const aVariableType: TVariableType): string;
begin
  result := GetEnumName(TypeInfo(TVariableType), integer(aVariableType));
end;

end.

