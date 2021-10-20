program HorseElastic;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  Horse.Elastic,
  System.JSON,
  System.SysUtils;

begin
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;

  THorse
    .Use(THorseElasticLogger.Build) // It has to be before the Jhonson middleware
    .Use(Jhonson);

  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      json: TJsonObject;
    begin
      json := TJSONObject.Create;
      json.AddPair('ping', 'pong');

      Res.Send<TJSONObject>(json);
    end);

  THorse.Listen(9000,
    procedure(Horse: THorse)
    begin
      Readln;
    end);
end.
