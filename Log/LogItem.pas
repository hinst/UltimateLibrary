unit LogItem;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  LogEntityFace;

type

  { TLogItem }

  TLogItem = object
  public
    constructor Init;
  private
    fNumber: longint;
    fTime: TDateTime;
    fTag: string;
    fObjectName: string;
    fText: string;
  public
    procedure Clear;
    property Number: integer read fNumber write fNumber;
    property Time: TDateTime read fTime write fTime;
    property Tag: string read fTag write fTag;
    property ObjectName: string read fObjectName write fObjectName;
    property Text: string read fText write fText;
    destructor Done;
  end;

  PLogItem = ^TLogItem;

  IStandardLogTagToString = interface
    function ToString(const aTag: TStandardLogTag): string;
  end;

  { TStandardLogTagToString }

  TStandardLogTagToString = class(TInterfacedObject, IStandardLogTagToString)
  public
    function ToString(const aTag: TStandardLogTag): string; overload;
  end;

const
  LOG_TAG_STARTUP_CAPTION = 'STARTUP';
  LOG_TAG_DEBUG_CAPTION = ' ';
  LOG_TAG_WARNING_CAPTION = 'WARNING';
  LOG_TAG_ERROR_CAPTION = 'ERROR';
  LOG_TAG_END = 'END';

implementation

{ TStandardLogTagToString }

function TStandardLogTagToString.ToString(const aTag: TStandardLogTag): string;
begin
  case aTag of
    logTagStartup: result := LOG_TAG_STARTUP_CAPTION;
    logTagDebug: result := LOG_TAG_DEBUG_CAPTION;
    logTagWarning: result := LOG_TAG_WARNING_CAPTION;
    logTagError: result := LOG_TAG_ERROR_CAPTION;
    logTagEnd: result := LOG_TAG_END;
  end;
end;

{ TLogItem }

constructor TLogItem.Init;
begin
  Clear;
  Time := Now;
end;

procedure TLogItem.Clear;
begin
  Number := 0;
  Time := 0;
  Tag := '';
  ObjectName := '';
  Text := '';
end;

destructor TLogItem.Done;
begin
  Clear;
end;

end.

