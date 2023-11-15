unit Horse.Elastic.Logger;

interface

uses
  Horse,
  Horse.Elastic.Config,
  GBClient.Interfaces,
  GBClient.Core.Types,
  System.JSON,
  System.SysUtils,
  System.Classes,
  System.DateUtils,
  System.SyncObjs,
  System.Generics.Collections,
  Web.HTTPApp;

type
  THorseElasticLogger = class(TThread)
  private
    class var FHorseElasticLogger: THorseElasticLogger;
    FCriticalSection: TCriticalSection;
    FEvent: TEvent;
    FLogCache: TList<string>;

    procedure SaveLogCache;
    function ExtractLogCache: TArray<string>;
  public
    class function GetInstance: THorseElasticLogger;
    class destructor UnInitialize;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Execute; override;

    function NewLog(ALog: string): THorseElasticLogger;
  end;

implementation

{ THorseElasticLogger }

procedure THorseElasticLogger.AfterConstruction;
begin
  inherited;
  FLogCache := TList<string>.Create;
  FEvent := TEvent.Create;
  FCriticalSection := TCriticalSection.Create;
end;

procedure THorseElasticLogger.BeforeDestruction;
begin
  inherited;
  FLogCache.Free;
  FEvent.Free;
  FCriticalSection.Free;
end;

procedure THorseElasticLogger.Execute;
var
  LWait: TWaitResult;
begin
  inherited;
  while not(Self.Terminated) do
  begin
    LWait := FEvent.WaitFor(INFINITE);
    FEvent.ResetEvent;
    case LWait of
      wrSignaled:
        begin
          SaveLogCache;
        end
    else
      Continue;
    end;
  end;
end;

function THorseElasticLogger.ExtractLogCache: TArray<string>;
var
  LLogCacheArray: TArray<string>;
begin
  FCriticalSection.Enter;
  try
    LLogCacheArray := FLogCache.ToArray;
    FLogCache.Clear;
    FLogCache.TrimExcess;
  finally
    FCriticalSection.Leave;
  end;
  Result := LLogCacheArray;
end;

class function THorseElasticLogger.GetInstance: THorseElasticLogger;
begin
  if not Assigned(FHorseElasticLogger) then
  begin
    FHorseElasticLogger := THorseElasticLogger.Create(True);
    FHorseElasticLogger.FreeOnTerminate := True;
    FHorseElasticLogger.Start;
  end;

  Result := FHorseElasticLogger;
end;

function THorseElasticLogger.NewLog(ALog: string): THorseElasticLogger;
begin
  Result := Self;
  FCriticalSection.Enter;
  try
    FLogCache.Add(ALog);
  finally
    FCriticalSection.Leave;
    FEvent.SetEvent;
  end;
end;

procedure THorseElasticLogger.SaveLogCache;
var
  LLogCacheArray: TArray<string>;
  LJsonValue: TJSONObject;
  I: Integer;
  LRequest: IGBClientRequest;
begin
  FCriticalSection.Enter;
  try
    try
      LLogCacheArray := ExtractLogCache;
      LRequest := NewClientRequest;
      for I := Low(LLogCacheArray) to High(LLogCacheArray) do
      begin
        LJsonValue := TJSONObject.ParseJSONValue(LLogCacheArray[I]) as TJSONObject;
        try
          LRequest
            .POST
            .BaseURL(THorseElasticConfig.GetInstance.BaseUrl)
            .Resource(THorseElasticConfig.GetInstance.Resource)
            .ContentType(THorseElasticConfig.GetInstance.ContentType)
            .Params
              .BodyAddOrSet(LJsonValue.ToJSON)
            .&End;
        finally
          LJsonValue.Free;
        end;

        if THorseElasticConfig.GetInstance.AuthType = eaAWS then
        begin
          LRequest.Authorization.AWSv4
            .AccessKey(THorseElasticConfig.GetInstance.UserName)
            .SecretKey(THorseElasticConfig.GetInstance.Password)
            .Region(THorseElasticConfig.GetInstance.AWSRegion);
        end
        else
        if THorseElasticConfig.GetInstance.AuthType = eaBasic then
        begin
          LRequest.Authorization.Basic
            .Username(THorseElasticConfig.GetInstance.UserName)
            .Password(THorseElasticConfig.GetInstance.Password);
        end;

        LRequest.Send;
      end;
    except
      on E: Exception do
        System.Writeln(E.Message);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

class destructor THorseElasticLogger.UnInitialize;
begin
  if Assigned(FHorseElasticLogger) then
  begin
    FHorseElasticLogger.Terminate;
    FHorseElasticLogger.FEvent.SetEvent;
  end;
end;

end.
