unit Generic1DArray;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils;

type

  { TG1DArray }

  generic TG1DArray<T> = class
  public type
    TArray = array of T;
  private
    fData: TArray;
    function GetItem(const aIndex: integer): T;
  public
    property Items[const aIndex: integer]: T read GetItem;
  end;

implementation

{ TG1DArray }

function TG1DArray.GetItem(const aIndex: integer): T;
begin
  result := fData[aIndex];
end;

end.

