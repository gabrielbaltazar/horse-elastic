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

  THorseElasticConfig.GetInstance
    .HoursDiff(3)
    .BaseUrl('https://localhost:9200')
    .Resource('passaporte/_doc')
    .AuthType(eaBasic)
    .UserName('elastic')
    .Password('G_xquEr9_nEoHU*J-y2j');

  THorse
    .Use(Horse.Elastic.HorseElastic) // It has to be before the Jhonson middleware
    .Use(Jhonson);

  THorse.Get('ping',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      LJson: TJsonObject;
    begin
      LJson := TJSONObject.Create;
      LJson.AddPair('ping', 'pong');

      ARes.Send<TJSONObject>(LJson);
    end);

  THorse.Post('ping',
    procedure(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc)
    var
      LJson: TJsonObject;
    begin
      LJson := TJSONObject.Create;
      LJson.AddPair('ping', 'pong');

      ARes.Send<TJSONObject>(LJson);
    end);

  THorse.Listen(9000,
    procedure(AHorse: THorse)
    begin
      Readln;
    end);
end.
