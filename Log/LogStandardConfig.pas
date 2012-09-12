unit LogStandardConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  LogManager, LogItem, ConsoleLogWriter, DefaultLogTextFormat;

type

  { TLogStandardConfig }

  TLogStandardConfig = class
  public
    class function CreateLogManager(const aOwner: TComponent): TLogManager;
    class procedure CreateIt(const aOwner: TComponent; out aManager: TLogManager);
    class procedure CreateIt(out aManager: TLogManager);
    class function CreateConsoleLogger(const aOwner: TComponent): TConsoleLogWriter;
    class procedure CreateIt(const aOwner: TComponent; out
      aWriter: TConsoleLogWriter);
  end;

implementation

{ TLogStandardConfig }

class function TLogStandardConfig.CreateLogManager(const aOwner: TComponent
  ): TLogManager;
begin
  result := TLogManager.Create(aOwner);
  result.StandardLogTagToString := TStandardLogTagToString.Create;
end;

class procedure TLogStandardConfig.CreateIt(const aOwner: TComponent; out aManager: TLogManager);
begin
  aManager := CreateLogManager(aOwner);
end;

class procedure TLogStandardConfig.CreateIt(out aManager: TLogManager);
begin
  aManager := CreateLogManager(nil);
end;

class function TLogStandardConfig.CreateConsoleLogger(const aOwner: TComponent
  ): TConsoleLogWriter;
begin
  result := TConsoleLogWriter.Create(aOwner);
  result.Format := TDefaultLogTextFormat.Create;
  result.Name := 'DefaultConsoleLogger';
end;

class procedure TLogStandardConfig.CreateIt(const aOwner: TComponent;
  out aWriter: TConsoleLogWriter);
begin
  aWriter := CreateConsoleLogger(aOwner);
end;

end.

