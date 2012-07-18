unit ThreadEnhancer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TThreadEnhancer }

  TThreadEnhancer = class helper for TThread
  public
    procedure Snchrnze(AMethod: TThreadMethod);
  end;

implementation

{ TThreadEnhancer }

procedure TThreadEnhancer.Snchrnze(AMethod: TThreadMethod);
begin
  TThread.Synchronize(self, aMethod);
end;

end.

