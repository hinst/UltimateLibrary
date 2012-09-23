unit DeltaApproachUnit;

interface

  {
    aSpeed: absolute value of the speed
    result:
    true = approached
    false = not approached yet
  }
function DeltaApproach(var aDelta: single; const aSpeed: single): boolean;
  inline; //seriously... Y NOT?

implementation

function DeltaApproach(var aDelta: single; const aSpeed: single): boolean;
begin
  if aDelta = 0 then
    exit(true);
  if aDelta < 0 then
  begin // NEGATIVE DELTA BLOCK
    aDelta += aSpeed;
    result := aDelta >= 0;
    if result then
      aDelta := 0;
  end
  else
  begin // POSITIVE DELTA BLOCK
    aDelta -= aSpeed;
    result := aDelta <= 0;
    if result then
      aDelta := 0;
  end;
end;

end.

