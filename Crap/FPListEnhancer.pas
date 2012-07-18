unit FPListEnhancer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TEnhancedInterfaceList }

  TFPListEnhancer = class helper for TFPList
  public
    procedure DeleteFirst;
  end;

implementation

{ TEnhancedInterfaceList }

procedure TFPListEnhancer.DeleteFirst;
begin
  Delete(0);
end;

end.

