unit SimpleLogTextFormat;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  LogItem, LogFormat, LogTextFormat;

type

  { TSimpleTextLogFormat }

  TSimpleTextLogFormat = class(TComponent, ILogTextFormat)
  public
    constructor Create(const aOwner: TComponent); reintroduce;
  public type
    TTimeToStr = function(ADate: TDateTime): string;
  public const
    NumberHere = 'NUMBER';
    TimeHere = 'TIME';
    TagHere = 'TAG';
    ObjectHere = 'OBJECT';
    TextHere = 'TEXT';
    LineEndingHere = '\n';
    DefaultFormat = 'NUMBER TIME TAG\n  OBJECT: TEXT';
  private
    FFormatStr: string;
    FTimeToStr: TTimeToStr;
    FLatestResult: string;
  protected
    procedure Initialize;
    procedure Replace(var AText: string;
      const AOldPattern, ANewPattern: string);
  public
    property TimeToStr: TTimeToStr
      read FTimeToStr write FTimeToStr;
    function DefaultTimeToStr: TTimeToStr;
    property FormatStr: string read FFormatStr write FFormatStr;
    property LatestResult: string read FLatestResult;
    function Format(const aItem: PLogItem): string;
  end;

implementation

{ TSimpleTextLogFormat }

constructor TSimpleTextLogFormat.Create(const aOwner: TComponent);
begin
  inherited Create(aOwner);
  Initialize;
end;

procedure TSimpleTextLogFormat.Initialize;
begin
  FFormatStr := DefaultFormat;
  FTimeToStr := DefaultTimeToStr;
end;

procedure TSimpleTextLogFormat.Replace(var AText: string; const AOldPattern,
  ANewPattern: string);
begin
  AText := StringReplace(AText, AOldPattern, ANewPattern, [rfReplaceAll]);
end;

function TSimpleTextLogFormat.DefaultTimeToStr: TTimeToStr;
begin
  result := @SysUtils.DateTimeToStr;
end;

function TSimpleTextLogFormat.Format(const aItem: PLogItem): string;
begin
  result := FormatStr;
  Replace(result, LineEndingHere, LineEnding);
  Replace(result, NumberHere, IntToStr(aItem^.Number));
  if pos(TimeHere, result) > 0 then
  begin
    if TimeToStr = nil then
      raise ELogFormat.Create('Can not format message: no TimeToStr function');
    Replace(result, TimeHere, self.TimeToStr(aItem^.Time));
  end;
  Replace(result, TagHere, aItem^.Tag);
  Replace(result, ObjectHere, aItem^.ObjectName);
  Replace(result, TextHere, aItem^.Text);
end;

end.
