unit Generic1DArray;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

uses
  Classes,
  SysUtils,

  NiceInterfaces
  ;

type

  { TG1DArray }

  generic TG1DArray<T> = class
  public type
    TArray = array of T;
    IComparator = interface
      function Compare(const a, b: T): integer;
    end;

  public const
    IncreaseCapacity = 10;
  private
    fData: TArray;
    fCapacity: integer;
    fCount: integer;
    function GetItem(const aIndex: integer): T; inline;
    procedure SetItem(const aIndex: integer; const aItem: T); inline;
    function GetCapacity: integer; inline;
    procedure SetCapacity(const aCapacity: integer);
  public
    property Items[const aIndex: integer]: T read GetItem write SetItem; default;
    property Capacity: integer read GetCapacity write SetCapacity;
    property Count: integer read fCount;
    function Add(const aItem: T): integer;
  end;

implementation

{ TG1DArray }

function TG1DArray.GetItem(const aIndex: integer): T;
begin
  result := fData[aIndex];
end;

procedure TG1DArray.SetItem(const aIndex: integer; const aItem: T);
begin
  fData[aIndex] := aItem;
end;

function TG1DArray.GetCapacity: integer;
begin
  result := Length(fData);
end;

procedure TG1DArray.SetCapacity(const aCapacity: integer);
begin
  SetLength(fData, aCapacity);
  if Count < Capacity then
    fCount := Capacity;
end;

function TG1DArray.Add(const aItem: T): integer;
begin
  if Count = Capacity then
    Capacity := Capacity + IncreaseCapacity;
  Items[Count] := aItem;
  inc(fCount);
end;

end.

