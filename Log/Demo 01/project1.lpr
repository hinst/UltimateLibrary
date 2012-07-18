program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes
  { you can add units after this },
  LogManager, LogEntity, ConsoleLogWriter, LogWriter,
  DefaultLogTextFormat, LogItem, SimpleLogTextFormat;

var
  manager: TLogManager;
  consoleLogger: TConsoleLogWriter;
  log: TLog;

begin
  // initialization SECTION
  manager := TLogManager.Create(nil);
  manager.StandardLogTagToString := TStandardLogTagToString.Create;
  consoleLogger := TConsoleLogWriter.Create(manager);
  consoleLogger.Format := TSimpleTextLogFormat.Create(manager);
  consoleLogger.Name := 'ConsoleLogger';
  manager.ImmediateWriters.Add(consoleLogger as ILogWriter);
  // sub initialization SECTION
  log := TLog.Create(manager, 'MAIN');
  // run SECTION
  log.Write(logTagStartup, '');
  log.Write(logTagDebug, 'Now running application...');
  log.Write(logTagEnd, '');
  // end SECTION
  log.Free;
  manager.Free;
end.

