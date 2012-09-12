program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this },
  LogManager, LogEntity,
  LogWriter, ConsoleLogWriter, TextFileLogWriter,
  DefaultLogTextFormat, LogItem, SimpleLogTextFormat;

var
  manager: TLogManager;
  consoleLogger: TConsoleLogWriter;
  fileLogger: TTextFileLogWriter;
  log: TLog;

procedure EnumerateWriters;
  function ExamineWriter(const aWriter: ILogWriter): string;
  begin
    result := aWriter.Name;
    if aWriter.Me is TTextFileLogWriter then
      result += LineEnding + (aWriter.Me as TTextFileLogWriter).FileName;
  end;

  procedure ExamineWriters(const aWriters: TFPList);
  var
    p: pointer;
  begin
    for p in aWriters do
      log.Write(ExamineWriter(ILogWriter(p)));
  end;

begin
  log.Write('Deferred writers:');
  ExamineWriters(manager.DeferredWriters);
  log.Write('Immediate writers:');
  ExamineWriters(manager.ImmediateWriters);
end;

begin
  // initialization SECTION
  manager := TLogManager.Create(nil);
  manager.StandardLogTagToString := TStandardLogTagToString.Create;
  consoleLogger := TConsoleLogWriter.Create(manager);
  consoleLogger.Format := TSimpleTextLogFormat.Create(manager);
  consoleLogger.Name := 'PrimaryConsoleLogger';
  manager.ImmediateWriters.Add(consoleLogger as ILogWriter);
  fileLogger := TTextFileLogWriter.Create(manager, 'log.text');
  fileLogger.Format := consoleLogger.Format; // same format okay
  //manager.DeferredWriters.Add(fileLogger);
  manager.DeferredWriters.Add(fileLogger as ILogWriter);
  // sub initialization SECTION
  log := TLog.Create(manager, 'MAIN');
  // run SECTION
  log.Write(logTagStartup, 'Now starting application...');
  log.Write(logTagDebug, 'Now running application...');
  EnumerateWriters;
  log.Write(logTagEnd, 'Eng of log');
  // end SECTION
  log.Free;
  manager.Free;
end.

