unit LogObjectEnhancer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LogItem, LogManager, LogEntity;

type

  { TLogObjectEnhancer }

  TLogObjectEnhancer = class helper for TObject
  protected
    function CreateLog(const aManager: TLogManager): ILog;
  end;

implementation

{ TLogObjectEnhancer }

function TLogObjectEnhancer.CreateLog(const aManager: TLogManager): ILog;
var
  logName: string;
begin
  logName := self.ClassName;
  if self is TComponent then
    logName += ' "' + TComponent(self).Name + '"';
  result := TLog.Create(aManager, logName);
end;

end.

