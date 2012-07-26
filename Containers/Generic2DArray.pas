unit Generic2DArray;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { T2Array }

  generic T2Array<T> = class
  public
    constructor Create(const aWidth, aHeight: integer);
    constructor Create;
  public type
    TColumn = array of T;
    TMatrix = array of TColumn;
  private
    fMatrix: TMatrix;
    fWidth, fHeight: integer;
    procedure Allocate;
    procedure Deallocate;
  public
    property Width: integer read fWidth;
    property Height: integer read fHeight;
    property Matrix: TMatrix read fMatrix;
    procedure Reallocate(const aWidth, aHeight: integer);
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
    SetLength(Matrix[x], Height);
end;

procedure T2Array.Deallocate;
var
  x: integer;
begin
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

end.

