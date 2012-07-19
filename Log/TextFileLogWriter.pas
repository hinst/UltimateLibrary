unit TextFileLogWriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  JobThread, LogItem, LogWriter, LogTextFormat, ComponentEnhancer;

type

  { TTextFileLogWriter }

  TTextFileLogWriter = class(TComponent, ILogWriter, IDemandsLogTextFormat)
  public
    constructor Create(const aOwner: TComponent; const aFileName: string); reintroduce;
  private
    fStream: TFileStream;
    fFormat: ILogTextFormat;
    procedure Initialize(const aFileName: string);
    procedure Write(const aThread: TJobThread; const aItem: PLogItem);
    function GetName: string;
    function GetFileName: string;
    procedure SetFormat(const aFormat: ILogTextFormat);
    function GetMe: TObject;
    procedure Finalize;
  public
    property Stream: TFileStream read fStream;
    property FileName: string read GetFileName;
    property Format: ILogTextFormat read fFormat write SetFormat;
  public
    destructor Destroy; override;
  end;

  ETextFileLogWriter = class(ELogWriter)
  end;

implementation

{ TTextFileLogWriter }

constructor TTextFileLogWriter.Create(const aOwner: TComponent;
  const aFileName: string);
begin
  inherited Create(aOwner);
  Initialize(aFileName);
end;

procedure TTextFileLogWriter.Initialize(const aFileName: string);
begin
  fStream := TFileStream.Create(aFileName, fmCreate or fmOpenWrite);
end;

procedure TTextFileLogWriter.Write(const aThread: TJobThread;
  const aItem: PLogItem);
var
  s: string;
  sLength: integer;
  rLength: integer;
begin
  s := Format.Format(aItem) + LineEnding;
  sLength := length(s);
  rLength := Stream.Write(PChar(s)^, sLength);
  if (rLength < sLength) then
    raise ETextFileLogWriter.Create('Could not write; filename is "' + FileName + '"');
end;

function TTextFileLogWriter.GetName: string;
begin
  result := GetClassAndName;
end;

function TTextFileLogWriter.GetFileName: string;
begin
  result := Stream.FileName;
end;

procedure TTextFileLogWriter.SetFormat(const aFormat: ILogTextFormat);
begin
  fFormat := aFormat;
end;

function TTextFileLogWriter.GetMe: TObject;
begin
  result := self;
end;

procedure TTextFileLogWriter.Finalize;
begin
  Stream.Free;
end;

destructor TTextFileLogWriter.Destroy;
begin
  Finalize;
  inherited Destroy;
end;

end.

