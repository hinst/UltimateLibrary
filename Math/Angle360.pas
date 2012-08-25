unit Angle360;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TAngle360 }

  TAngle360 = object
  private
    fValue: single;
  public
    property Value: single read fValue write fValue;
    procedure Assign(const aX: single);
    procedure AssignTo(var aX: single);
    procedure Inc(const aX: single);
    procedure Refresh;
  end;

operator := (const aX: single): TAngle360;

operator := (const aX: TAngle360): single;

operator = (const A, B: TAngle360): boolean;

implementation

operator := (const aX: single): TAngle360;
begin
  result.Assign(aX);
end;

operator := (const aX: TAngle360): single;
begin
  aX.AssignTo(result);
end;

operator = (const A, B: TAngle360): boolean;
begin
  result := A.Value = B.Value;
end;

{ TAngle360 }

procedure TAngle360.Assign(const aX: single);
begin
  Value := aX;
end;

procedure TAngle360.AssignTo(var aX: single);
begin
  aX := Value;
end;

procedure TAngle360.Inc(const aX: single);
begin
  fValue += aX;
  Refresh;
end;

procedure TAngle360.Refresh;
begin
  while fValue >= 360 do
    fValue -= 360;
  while fValue < 0 do
    fValue += 360;
end;

end.

