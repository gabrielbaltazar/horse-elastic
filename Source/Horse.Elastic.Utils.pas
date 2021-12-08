unit Horse.Elastic.Utils;

interface

uses
  Horse.Elastic.Config,
  System.SysUtils;

function GetValue(const Value: Int64): string; overload;
function GetValue(const Value: Integer): string; overload;
function GetValue(const Value: String): string; overload;
function GetValue(const Value: TDateTime): string; overload;
function GetValueContent(const Value: String): string;

implementation

function GetValue(const Value: Int64): string;
begin
  result := Value.ToString;
end;

function GetValue(const Value: Integer): string;
begin
  result := Value.ToString;
end;

function GetValue(const Value: String): string;
begin
  result := Value;
end;

function GetValue(const Value: TDateTime): string;
begin
  result := FormatDateTime(THorseElasticConfig.GetInstance.DateFormat, Value);
end;

function GetValueContent(const Value: String): string;
begin
  result := Value.Replace(#9, EmptyStr)
                 .Replace(#$A, EmptyStr)
                 .Replace(#$D, EmptyStr)
                 .Replace('"', '\"');
end;

end.
