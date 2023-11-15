unit Horse.Elastic.Config;

interface

uses
  Horse,
  Horse.Elastic.Templates,
  System.JSON,
  System.SysUtils,
  System.Generics.Collections;

type
  TElasticAuth = (eaNone, eaBasic, eaAWS);

  THorseElasticConfig = class
  private
    class var FInstance: THorseElasticConfig;

    FAuthType: TElasticAuth;
    FHoursDiff: Integer;
    FDateFormat: string;
    FLogFormat: string;
    FBaseUrl: string;
    FResource: string;
    FContentType: string;
    FUserName: string;
    FPassword: string;
    FAWSRegion: string;
    FIgnoreRoutes: TList<string>;

    constructor CreatePrivate;
  public
    constructor Create;
    class function GetInstance: THorseElasticConfig;

    destructor Destroy; override;
    class destructor UnInitialize;

    function AddField(AName: string): THorseElasticConfig;

    function BaseUrl(AValue: string): THorseElasticConfig; overload;
    function BaseUrl: string; overload;

    function Resource(AValue: string): THorseElasticConfig; overload;
    function Resource: string; overload;

    function ContentType(AValue: string): THorseElasticConfig; overload;
    function ContentType: string; overload;

    function AuthType(AValue: TElasticAuth): THorseElasticConfig; overload;
    function AuthType: TElasticAuth; overload;

    function LogFormat(AValue: string): THorseElasticConfig; overload;
    function LogFormat: string; overload;

    function DateFormat(AValue: string): THorseElasticConfig; overload;
    function DateFormat: string; overload;

    function UserName(AValue: string): THorseElasticConfig; overload;
    function UserName: string; overload;

    function Password(AValue: string): THorseElasticConfig; overload;
    function Password: string; overload;

    function AWSRegion(AValue: string): THorseElasticConfig; overload;
    function AWSRegion: string; overload;

    function HoursDiff(AValue: Integer): THorseElasticConfig; overload;
    function HoursDiff: Integer; overload;

    function IgnoreRoute(AValue: string): THorseElasticConfig;
    function IgnoreRoutes: TArray<string>;
    function IsIgnoreRoute(AValue: string): Boolean;
  end;

implementation

{ THorseElasticConfig }

function THorseElasticConfig.UserName: string;
begin
  Result := FUserName;
end;

function THorseElasticConfig.UserName(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FUserName := AValue;
end;

function THorseElasticConfig.AddField(AName: string): THorseElasticConfig;
var
  LValue: TJSONValue;
  LTemplate: TJSONObject;
  LStructure: TArray<string>;
  I: Integer;
begin
  Result := Self;
  LValue := nil;
  LTemplate := TJSONObject.ParseJSONValue(FLogFormat) as TJSONObject;
  try
    LStructure := AName.Split(['.']);
    if Length(LStructure) = 1 then
    begin
      LValue := LTemplate.GetValue(LStructure[0]);
      if not Assigned(LValue) then
        LTemplate.AddPair(LStructure[0], Format('${%s}', [LStructure[0]]));
    end
    else
    begin
      for I := 0 to Pred(Length(LStructure)) do
      begin
        if I = Pred(Length(LStructure)) then
        begin
          if TJSONObject(LValue).GetValue(LStructure[I]) = nil then
            TJSONObject(LValue).AddPair(LStructure[I], Format('${%s}', [LStructure[I]]));
        end
        else
        begin
          LValue := LTemplate.GetValue(LStructure[I]);
          if LValue = nil then
          begin
            LValue := TJSONObject.Create;
            LTemplate.AddPair(LStructure[I], LValue);
          end;
        end;
      end;
    end;

    FLogFormat := LTemplate.ToString;
  finally
    LTemplate.Free;
  end;
end;

function THorseElasticConfig.AuthType: TElasticAuth;
begin
  Result := FAuthType;
end;

function THorseElasticConfig.AuthType(AValue: TElasticAuth): THorseElasticConfig;
begin
  Result := Self;
  FAuthType := AValue;
end;

function THorseElasticConfig.AWSRegion: string;
begin
  Result := FAWSRegion;
end;

function THorseElasticConfig.AWSRegion(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FAWSRegion := AValue;
end;

function THorseElasticConfig.Password: string;
begin
  Result := FPassword;
end;

function THorseElasticConfig.Password(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FPassword := AValue;
end;

function THorseElasticConfig.BaseUrl(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FBaseUrl := AValue;
end;

function THorseElasticConfig.BaseUrl: string;
begin
  Result := FBaseUrl;
end;

function THorseElasticConfig.ContentType: string;
begin
  Result := FContentType;
end;

function THorseElasticConfig.ContentType(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FContentType := AValue;
end;

constructor THorseElasticConfig.Create;
begin
  raise Exception.Create('Invoke the GetInstance Method.');
end;

constructor THorseElasticConfig.CreatePrivate;
begin
  FBaseUrl := 'http://localhost:9200';
  FResource := 'indice/_doc';
  FDateFormat := 'yyyy-MM-dd''T''hh:mm:ss';
  FAuthType := eaNone;
  FAWSRegion := 'us-east-1';
  FContentType := 'application/json';
  FLogFormat := DEFAULT_LOG_FORMAT;
  FIgnoreRoutes := TList<string>.Create;
  FHoursDiff := 0;
end;

function THorseElasticConfig.DateFormat: string;
begin
  Result := FDateFormat;
end;

function THorseElasticConfig.DateFormat(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FDateFormat := AValue;
end;

destructor THorseElasticConfig.Destroy;
begin
  FIgnoreRoutes.Free;
  inherited;
end;

class function THorseElasticConfig.GetInstance: THorseElasticConfig;
begin
  if not Assigned(FInstance) then
    FInstance := THorseElasticConfig.CreatePrivate;
  Result := FInstance;
end;

function THorseElasticConfig.HoursDiff: Integer;
begin
  Result := FHoursDiff;
end;

function THorseElasticConfig.HoursDiff(AValue: Integer): THorseElasticConfig;
begin
  Result := Self;
  FHoursDiff := AValue;
end;

function THorseElasticConfig.IgnoreRoute(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  if not AValue.StartsWith('/') then
    AValue := '/' + AValue;
  FIgnoreRoutes.Add(AValue.ToLower);
end;

function THorseElasticConfig.IgnoreRoutes: TArray<string>;
begin
  Result := FIgnoreRoutes.ToArray;
end;

function THorseElasticConfig.IsIgnoreRoute(AValue: string): Boolean;
var
  LIgnore: TArray<string>;
  I: Integer;
begin
  Result := False;
  LIgnore := FIgnoreRoutes.ToArray;
  if not AValue.StartsWith('/') then
    AValue := '/' + AValue;

  for I := 0 to Pred(Length(LIgnore)) do
  begin
    if LIgnore[i].ToLower = AValue.ToLower then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function THorseElasticConfig.LogFormat: string;
begin
  Result := FLogFormat;
end;

function THorseElasticConfig.LogFormat(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FLogFormat := AValue;
end;

function THorseElasticConfig.Resource: string;
begin
  Result := FResource;
end;

function THorseElasticConfig.Resource(AValue: string): THorseElasticConfig;
begin
  Result := Self;
  FResource := AValue;
end;

class destructor THorseElasticConfig.UnInitialize;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

end.
