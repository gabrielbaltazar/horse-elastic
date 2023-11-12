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
  BAD_REQUEST = 400;

  epLocal = Horse.Elastic.Config.epLocal;
  epAws = Horse.Elastic.Config.epAws;

type
  TElasticPlatform = Horse.Elastic.Config.TElasticPlatform;
  THorseElasticConfig = Horse.Elastic.Config.THorseElasticConfig;
  THorseElasticLogger = Horse.Elastic.Logger.THorseElasticLogger;
  THorseElasticOnFormatTag = function(ATag: string; AReq: THorseRequest; ARes: THorseResponse): string;

var
  HorseOnFormatTag: THorseElasticOnFormatTag;

procedure HorseElastic(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);

implementation

function ReplaceTag(ALog, ATag: string; AReq: THorseRequest; ARes: THorseResponse): string;
begin
  if Assigned(HorseOnFormatTag) then
    Result := ALog.Replace(ATag, HorseOnFormatTag(ATag, AReq, ARes))
  else
    Result := ALog.Replace(ATag, EmptyStr);
end;

function FormatCustomValues(ALog: string; AReq: THorseRequest; ARes: THorseResponse): string;
var
  LTag: string;
  LStrStart: string;
  LPosTag: Integer;
  I: Integer;
begin
  Result := ALog;
  LPosTag := Pos('${', Result);
  while LPosTag > 0 do
  begin
    LStrStart := Copy(Result, LPosTag, Result.Length);
    LTag := EmptyStr;
    for I := 1 to LStrStart.Length do
    begin
      LTag := LTag + LStrStart[I];
      if LStrStart[I] = '}' then
        break;
    end;
    LTag := LTag.Replace(#0, EmptyStr);
    Result := ReplaceTag(Result, LTag, AReq, ARes);
    LPosTag := Pos('${', Result);
  end;
end;

procedure HorseElastic(AReq: THorseRequest; ARes: THorseResponse; ANext: TProc);
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
      ANext();
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
    LWebRequest := AReq.RawWebRequest;
    LWebResponse := ARes.RawWebResponse;
    LConfig := THorseElasticConfig.GetInstance;
    if not LConfig.IsIgnoreRoute(LWebRequest.PathInfo) then
    begin
      LAfterDateTime := Now();
      LMilliSecondsBetween := MilliSecondsBetween(LAfterDateTime, LBeforeDateTime);

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

      if LWebResponse.StatusCode >= BAD_REQUEST then
        LLog := LLog.Replace('${response_content}', GetValueContent(LWebResponse.Content))
      else
        LLog := LLog.Replace('${response_content}', EmptyStr);

      LLog := FormatCustomValues(LLog, AReq, ARes);
      THorseElasticLogger.GetInstance.NewLog(LLog);
    end;
  end;
end;

end.
