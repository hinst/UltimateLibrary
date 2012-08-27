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
    procedure Random;
    procedure Assign(const aX: single);
    procedure AssignTo(var aX: single);
    procedure Inc(const aX: single);
    procedure Refresh;
    procedure MoveToDesiredAngle(
      const aDesiredAngle: TAngle360;
      const aDelta: single);
  end;

operator := (const aX: single): TAngle360;

operator := (const aX: TAngle360): single;

operator = (const A, B: TAngle360): boolean;

function MostCloseAngleDirection(const aCurrent, aDesired: TAngle360): shortint;

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

function MostCloseAngleDirection(const aCurrent, aDesired: TAngle360): shortint;
var
  current, desired: single;
  positiveDistance, negativeDistance: single;
begin
  current := aCurrent;
  desired := aDesired;
  if current <= desired then
  begin
    positiveDistance := desired - current;
    negativeDistance := 360 - desired + current;
  end
  else
  begin
    positiveDistance := 360 - current + desired;
    negativeDistance := current - desired;
  end;
  if positiveDistance < negativeDistance then
    result := +1
  else
    result := -1;
end;

{ TAngle360 }

procedure TAngle360.Random;
begin
  Value := System.Random(360);
end;

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

procedure TAngle360.MoveToDesiredAngle(const aDesiredAngle: TAngle360;
  const aDelta: single);
var
  d1, d2: shortint;
begin
  if self = aDesiredAngle then exit;
  d1 := MostCloseAngleDirection(self, aDesiredAngle);
  self.Inc( aDelta * d1 );
  d2 := MostCloseAngleDirection(self, aDesiredAngle);
  if d1 <> d2 then
    self := aDesiredAngle;
end;

end.

