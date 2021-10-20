unit Horse.Elastic.Config;

interface

uses
  Horse.Elastic.Templates,
  System.SysUtils;

type
  TElasticPlatform = (epLocal, epAws);

  THorseElasticConfig = class
  private
    class var FInstance: THorseElasticConfig;

    FPlatform: TElasticPlatform;
    FDateFormat: String;
    FLogFormat: String;
    FBaseUrl: String;
    FResource: string;
    FContentType: String;
    FUserName: String;
    FPassword: string;
    FAWSRegion: string;

    constructor createPrivate;
  public
    constructor create;
    destructor Destroy; override;

    function BaseUrl(Value: String): THorseElasticConfig; overload;
    function BaseUrl: String; overload;

    function Resource(Value: String): THorseElasticConfig; overload;
    function Resource: String; overload;

    function ContentType(Value: String): THorseElasticConfig; overload;
    function ContentType: String; overload;

    function &Platform(Value: TElasticPlatform): THorseElasticConfig; overload;
    function &Platform: TElasticPlatform; overload;

    function LogFormat(Value: String): THorseElasticConfig; overload;
    function LogFormat: String; overload;

    function DateFormat(Value: String): THorseElasticConfig; overload;
    function DateFormat: String; overload;

    function UserName(Value: String): THorseElasticConfig; overload;
    function UserName: String; overload;

    function Password(Value: String): THorseElasticConfig; overload;
    function Password: String; overload;

    function AWSRegion(Value: String): THorseElasticConfig; overload;
    function AWSRegion: String; overload;

    class function GetInstance: THorseElasticConfig;
    class destructor UnInitialize;

  end;

implementation

{ THorseElasticConfig }

function THorseElasticConfig.UserName: String;
begin
  result := FUserName;
end;

function THorseElasticConfig.UserName(Value: String): THorseElasticConfig;
begin
  result := Self;
  FUserName := Value;
end;

function THorseElasticConfig.AWSRegion: String;
begin
  result := FAWSRegion;
end;

function THorseElasticConfig.AWSRegion(Value: String): THorseElasticConfig;
begin
  result := Self;
  FAWSRegion := Value;
end;

function THorseElasticConfig.Password: String;
begin
  Result := FPassword;
end;

function THorseElasticConfig.Password(Value: String): THorseElasticConfig;
begin
  result := Self;
  FPassword := Value;
end;

function THorseElasticConfig.BaseUrl(Value: String): THorseElasticConfig;
begin
  result := Self;
  FBaseUrl := Value;
end;

function THorseElasticConfig.BaseUrl: String;
begin
  result := FBaseUrl;
end;

function THorseElasticConfig.ContentType: String;
begin
  result := FContentType;
end;

function THorseElasticConfig.ContentType(Value: String): THorseElasticConfig;
begin
  result := Self;
  FContentType := Value;
end;

constructor THorseElasticConfig.create;
begin
  raise Exception.Create('Invoke the GetInstance Method.');
end;

constructor THorseElasticConfig.createPrivate;
begin
  FBaseUrl := 'http://localhost:9200';
  FResource := 'horse_elastic/doc';
  FDateFormat := 'yyyy-MM-dd''T''hh:mm:ss';
  FPlatform := epLocal;
  FAWSRegion := 'us-east-1';
  FContentType := 'application/json';
  FLogFormat := DEFAULT_LOG_FORMAT;
end;

function THorseElasticConfig.DateFormat: String;
begin
  result := FDateFormat;
end;

function THorseElasticConfig.DateFormat(Value: String): THorseElasticConfig;
begin
  result := Self;
  FDateFormat := Value;
end;

destructor THorseElasticConfig.Destroy;
begin
  inherited;
end;

class function THorseElasticConfig.GetInstance: THorseElasticConfig;
begin
  if not Assigned(FInstance) then
    FInstance := THorseElasticConfig.createPrivate;
  Result := FInstance;
end;

function THorseElasticConfig.LogFormat: String;
begin
  result := FLogFormat;
end;

function THorseElasticConfig.LogFormat(Value: String): THorseElasticConfig;
begin
  result := Self;
  FLogFormat := Value;
end;

function THorseElasticConfig.Platform: TElasticPlatform;
begin
  result := FPlatform;
end;

function THorseElasticConfig.Resource: String;
begin
  result := FResource;
end;

function THorseElasticConfig.Resource(Value: String): THorseElasticConfig;
begin
  result := Self;
  FResource := Value;
end;

function THorseElasticConfig.Platform(Value: TElasticPlatform): THorseElasticConfig;
begin
  result := Self;
  FPlatform := Value;
end;

class destructor THorseElasticConfig.UnInitialize;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

end.
