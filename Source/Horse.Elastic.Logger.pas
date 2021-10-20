unit Horse.Elastic.Logger;

interface

uses
  Horse,
  Horse.Elastic.Config,
  GBClient.Interfaces,
  GBClient.Core.Types,
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

    class function GetValue(Value: Int64): string; overload;
    class function GetValue(Value: Integer): string; overload;
    class function GetValue(Value: String): string; overload;
    class function GetValue(Value: TDateTime): string; overload;
    class function GetValueContent(Value: String): string;

    procedure SaveLogCache;
    function ExtractLogCache: TArray<string>;
    function NewLog(ALog: string): THorseElasticLogger;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Execute; override;

    class function Build: THorseCallback;
    class function GetInstance: THorseElasticLogger;
    class destructor UnInitialize;
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
  FCriticalSection.Free;;
end;

class function THorseElasticLogger.Build: THorseCallback;
begin
  Result :=
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LWebRequest: TWebRequest;
      LWebResponse: TWebResponse;
      LBeforeDateTime: TDateTime;
      LAfterDateTime: TDateTime;
      LMilliSecondsBetween: Integer;
      LExeption: string;
      LLog: string;
      LConfig: THorseElasticConfig;
    begin
      LBeforeDateTime := Now();
      try
        try
          Next();
        except
          on E: EHorseCallbackInterrupted do
          begin
            LExeption := E.Message;
            raise;
          end;
          on E: EHorseException do
          begin
            LExeption := E.Message;
            raise;
          end;
          on E: Exception do
          begin
            LExeption := E.Message;
            raise;
          end;
        end;
      finally
        LConfig := THorseElasticConfig.GetInstance;
        LAfterDateTime := Now();
        LMilliSecondsBetween := MilliSecondsBetween(LAfterDateTime, LBeforeDateTime);

        LWebRequest := Req.RawWebRequest;
        LWebResponse := Res.RawWebResponse;

        LLog := LConfig.LogFormat;

        LLog := LLog.Replace('${execution_date}', GetValue(LBeforeDateTime));
        LLog := LLog.Replace('${execution_time}', GetValue(LMilliSecondsBetween));
        LLog := LLog.Replace('${exception_message}', GetValue(LExeption));

        LLog := LLog.Replace('${request_method}', GetValue(LWebRequest.Method));
        LLog := LLog.Replace('${request_version}', GetValue(LWebRequest.ProtocolVersion));
        LLog := LLog.Replace('${request_url}', GetValue(LWebRequest.URL));
        LLog := LLog.Replace('${request_query}', GetValue(LWebRequest.Query));
        LLog := LLog.Replace('${request_path_info}', GetValue(LWebRequest.PathInfo));
        LLog := LLog.Replace('${request_path_translated}', GetValue(LWebRequest.PathTranslated));
        LLog := LLog.Replace('${request_cookie}', GetValue(LWebRequest.Cookie));
        LLog := LLog.Replace('${request_accept}', GetValue(LWebRequest.Accept));
        LLog := LLog.Replace('${request_from}', GetValue(LWebRequest.From));
        LLog := LLog.Replace('${request_host}', GetValue(LWebRequest.Host));
        LLog := LLog.Replace('${request_referer}', GetValue(LWebRequest.Referer));
        LLog := LLog.Replace('${request_user_agent}', GetValue(LWebRequest.UserAgent));
        LLog := LLog.Replace('${request_connection}', GetValue(LWebRequest.Connection));
        LLog := LLog.Replace('${request_derived_from}', GetValue(LWebRequest.DerivedFrom));
        LLog := LLog.Replace('${request_remote_addr}', GetValue(LWebRequest.RemoteAddr));
        LLog := LLog.Replace('${request_remote_host}', GetValue(LWebRequest.RemoteHost));
        LLog := LLog.Replace('${request_script_name}', GetValue(LWebRequest.ScriptName));
        LLog := LLog.Replace('${request_server_port}', GetValue(LWebRequest.ServerPort));
        LLog := LLog.Replace('${request_remote_ip}', GetValue(LWebRequest.RemoteIP));
        LLog := LLog.Replace('${request_internal_path_info}', GetValue(LWebRequest.InternalPathInfo));
        LLog := LLog.Replace('${request_raw_path_info}', GetValue(LWebRequest.RawPathInfo));
        LLog := LLog.Replace('${request_cache_control}', GetValue(LWebRequest.CacheControl));
        LLog := LLog.Replace('${request_script_name}', GetValue(LWebRequest.ScriptName));
        LLog := LLog.Replace('${request_authorization}', GetValue(LWebRequest.Authorization));
        LLog := LLog.Replace('${request_content_encoding}', GetValue(LWebRequest.ContentEncoding));
        LLog := LLog.Replace('${request_content_type}', GetValue(LWebRequest.ContentType));
        LLog := LLog.Replace('${request_content_length}', GetValue(LWebRequest.ContentLength));
        LLog := LLog.Replace('${request_content_version}', GetValue(LWebRequest.ContentVersion));
        LLog := LLog.Replace('${request_content}', GetValueContent(LWebRequest.Content));

        LLog := LLog.Replace('${response_version}', GetValue(LWebResponse.Version));
        LLog := LLog.Replace('${response_reason}', GetValue(LWebResponse.ReasonString));
        LLog := LLog.Replace('${response_server}', GetValue(LWebResponse.Server));
        LLog := LLog.Replace('${response_realm}', GetValue(LWebResponse.Realm));
        LLog := LLog.Replace('${response_allow}', GetValue(LWebResponse.Allow));
        LLog := LLog.Replace('${response_location}', GetValue(LWebResponse.Location));
        LLog := LLog.Replace('${response_log_message}', GetValue(LWebResponse.LogMessage));
        LLog := LLog.Replace('${response_title}', GetValue(LWebResponse.Title));
        LLog := LLog.Replace('${response_content_encoding}', GetValue(LWebResponse.ContentEncoding));
        LLog := LLog.Replace('${response_content_type}', GetValue(LWebResponse.ContentType));
        LLog := LLog.Replace('${response_content_length}', GetValue(LWebResponse.ContentLength));
        LLog := LLog.Replace('${response_content_version}', GetValue(LWebResponse.ContentVersion));
        LLog := LLog.Replace('${response_status}', GetValue(LWebResponse.StatusCode));
        LLog := LLog.Replace('${response_content}', GetValueContent(LWebResponse.Content));

        THorseElasticLogger.GetInstance.NewLog(LLog);
      end;
    end;
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
    FHorseElasticLogger := THorseElasticLogger.create(True);
    FHorseElasticLogger.FreeOnTerminate := True;
    FHorseElasticLogger.Start;
  end;

  result := FHorseElasticLogger;
end;

class function THorseElasticLogger.GetValue(Value: Integer): string;
begin
  result := Value.ToString;
end;

class function THorseElasticLogger.GetValue(Value: String): string;
begin
  result := Value;
end;

class function THorseElasticLogger.GetValue(Value: TDateTime): string;
begin
  result := FormatDateTime(THorseElasticConfig.GetInstance.DateFormat, Value);
end;

class function THorseElasticLogger.GetValueContent(Value: String): string;
begin
  result := Value.Replace(#9, EmptyStr)
                 .Replace(#$A, EmptyStr)
                 .Replace(#$D, EmptyStr)
                 .Replace('"', '\"');
end;

class function THorseElasticLogger.GetValue(Value: Int64): string;
begin
  result := Value.ToString;
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
  I: Integer;
  request: IGBClientRequest;
begin
  FCriticalSection.Enter;
  try
    try
      LLogCacheArray := ExtractLogCache;
      request := NewClientRequest;
      for I := Low(LLogCacheArray) to High(LLogCacheArray) do
      begin
        request
          .POST
          .BaseURL(THorseElasticConfig.GetInstance.BaseUrl)
          .Resource(THorseElasticConfig.GetInstance.Resource)
          .ContentType(THorseElasticConfig.GetInstance.ContentType)
          .Params
            .BodyAddOrSet(LLogCacheArray[I])
          .&End;

        if THorseElasticConfig.GetInstance.&Platform = epAws then
        begin
          request
            .Authorization.AWSv4
              .AccessKey(THorseElasticConfig.GetInstance.UserName)
              .SecretKey(THorseElasticConfig.GetInstance.Password)
              .Region(THorseElasticConfig.GetInstance.AWSRegion);
        end;

        request.Send;
      end;
    except
      FCriticalSection.Leave;
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
