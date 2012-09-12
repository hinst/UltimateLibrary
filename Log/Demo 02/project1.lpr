program project1;

{$mode objfpc}{$H+}
{$INTERFACES COM}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this };

type
  IInterface1 = interface

  end;

  IInterface2 = interface

  end;

  IInterface3 = interface(IInterface1, IInterface2);

begin
end.

