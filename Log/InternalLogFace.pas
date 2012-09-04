unit InternalLogFace;

interface

uses
  NiceInterfaces;

type
  ILog = interface(IReleasable) ['{C5009D82-1543-4424-953D-7F59EB3D384D}']
    procedure Write(const aTag: string; const aMessage: string);
  end;

implementation

end.

