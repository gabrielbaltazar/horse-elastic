unit Horse.Elastic.Utils;

interface

uses
  Horse.Elastic.Config,
  System.DateUtils,
  System.SysUtils;

function GetValue(const AValue: Int64): string; overload;
function GetValue(const AValue: Integer): string; overload;
function GetValue(const AValue: string): string; overload;
function GetValue(const AValue: TDateTime): string; overload;
function GetValueContent(const AValue: string): string;

implementation

function GetValue(const AValue: Int64): string;
begin
  Result := AValue.ToString;
end;

function GetValue(const AValue: Integer): string;
begin
  Result := AValue.ToString;
end;

function GetValue(const AValue: string): string;
begin
  Result := AValue;
end;

function GetValue(const AValue: TDateTime): string;
var
  LData: TDateTime;
  LHoursDiff: Integer;
begin
  LData := AValue;
  LHoursDiff := THorseElasticConfig.GetInstance.HoursDiff;
  if LHoursDiff <> 0 then
    LData := IncHour(LData, LHoursDiff);
  Result := FormatDateTime(THorseElasticConfig.GetInstance.DateFormat, LData);
end;

function GetValueContent(const AValue: string): string;
begin
  Result := AValue
    .Replace(#9, EmptyStr)
    .Replace(#$A, EmptyStr)
    .Replace(#$D, EmptyStr)
    .Replace('"', '\"');
end;

end.
