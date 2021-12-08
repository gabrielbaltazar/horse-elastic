unit Horse.Elastic;

interface

uses
  Horse,
  Horse.Elastic.Config,
  Horse.Elastic.Logger,
  Horse.Elastic.Utils,
  System.DateUtils,
  System.SysUtils,
  Web.HTTPApp;

const
  epLocal = Horse.Elastic.Config.epLocal;
  epAws = Horse.Elastic.Config.epAws;

type
  TElasticPlatform = Horse.Elastic.Config.TElasticPlatform;
  THorseElasticConfig = Horse.Elastic.Config.THorseElasticConfig;
  THorseElasticLogger = Horse.Elastic.Logger.THorseElasticLogger;

procedure HorseElastic(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

procedure HorseElastic(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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

end.
