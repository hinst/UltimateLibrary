unit Generic2DArray;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  NiceExceptions;

type

  { T2Array }

  generic T2Array<T> = class
  public
    constructor Create(const aWidth, aHeight: integer);
    constructor Create;
  public type
    TColumn = array of T;
    TMatrix = array of TColumn;
    PT = ^T;
  private
    fMatrix: TMatrix;
    fWidth, fHeight: integer;
    procedure Allocate;
    function GetCellExists(const aX, aY: integer): boolean;
    procedure Deallocate;
  public
    property Width: integer read fWidth;
    property Height: integer read fHeight;
    property Matrix: TMatrix read fMatrix;
    procedure Reallocate(const aWidth, aHeight: integer);
    property CellExists[const x, y: integer]: boolean read GetCellExists;
    function AccessCell(const x, y: integer): PT;
  end;

implementation

{ T2Array }

constructor T2Array.Create(const aWidth, aHeight: integer);
begin
  inherited Create;
  fWidth := aWidth;
  fHeight := aHeight;
  Allocate;
end;

constructor T2Array.Create;
begin
  Create(0, 0);
end;

procedure T2Array.Allocate;
var
  x: integer;
begin
  SetLength(fMatrix, Width);
  for x := 0 to Width - 1 do
    SetLength(fMatrix[x], Height);
end;

function T2Array.GetCellExists(const aX, aY: integer): boolean;
begin
  result := (aX >= 0) and (aY >= 0) and (aX < Width) and (aY < Height);
end;

procedure T2Array.Deallocate;
var
  x: integer;
begin
  if not Assigned(fMatrix) then
    exit; // nothing to deallocate
  for x := 0 to Width - 1 do
    SetLength(fMatrix[x], 0);
  SetLength(fMatrix, 0);
  fWidth := 0;
  fHeight := 0;
end;

procedure T2Array.Reallocate(const aWidth, aHeight: integer);
begin
  Deallocate;
  fWidth := aWidth;
  fHeight := aHeight;
  Allocate;
end;

function T2Array.AccessCell(const x, y: integer): PT;
begin
  result := nil;
  if CellExists[x, y] then
    result := @( Matrix[x, y] );
end;

end.

