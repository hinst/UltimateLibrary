unit NiceExceptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  EArgumentUnassigned = class(Exception);

procedure AssertArgumentAssigned(const aObject: TObject; const aArgumentName: string); inline;
procedure AssertArgumentAssigned(const aObject: boolean; const aArgumentName: string); inline;

implementation

procedure AssertAssigned(const aObject: TObject);
begin
end;

procedure AssertArgumentAssigned(const aObject: TObject; const aArgumentName: string);
begin
  AssertArgumentAssigned(Assigned(aObject), aArgumentName);
end;

procedure AssertArgumentAssigned(const aObject: boolean;
  const aArgumentName: string);
begin
  if not aObject then
    raise EArgumentUnassigned.Create(aArgumentName);
end;

end.

