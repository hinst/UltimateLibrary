unit LogEntityFace;

{$mode objfpc}{$H+}
{$INTERFACES CORBA}

interface

type

  TStandardLogTag =
  (
    logTagStartup,
    logTagDebug,
    logTagWarning,
    logTagError,
    logTagEnd
  );

  { ILog }

  ILog = interface
    procedure Write(const aText: string);
    procedure Write(const aTag: string; const aText: string);
    procedure Write(const aTag: TStandardLogTag; const aText: string);
    procedure Free;
  end;

implementation

end.

