unit Horse.Elastic.Templates;

interface

const
  DEFAULT_LOG_FORMAT =
    '{'+
    '"execution_date": "${execution_date}",'+
    '"execution_time": ${execution_time},'+
    '"exception_message": "${exception_message}",'+
    '"request": {'+
    '"request_method": "${request_method}",'+
    '"request_version": "${request_version}",'+
    '"request_url": "${request_url}",'+
    '"request_query": "${request_query}",'+
    '"request_path_info": "${request_path_info}",'+
    '"request_path_translated": "${request_path_translated}",'+
    '"request_cookie": "${request_cookie}",'+
    '"request_accept": "${request_accept}",'+
    '"request_from": "${request_from}",'+
    '"request_host": "${request_host}",'+
    '"request_referer": "${request_referer}",'+
    '"request_user_agent": "${request_user_agent}",'+
    '"request_connection": "${request_connection}",'+
    '"request_derived_from": "${request_derived_from}",'+
    '"request_remote_addr": "${request_remote_addr}",'+
    '"request_remote_host": "${request_remote_host}",'+
    '"request_script_name": "${request_script_name}",'+
    '"request_server_port": "${request_server_port}",'+
    '"request_remote_ip": "${request_remote_ip}",'+
    '"request_internal_path_info": "${request_internal_path_info}",'+
    '"request_raw_path_info": "${request_raw_path_info}",'+
    '"request_cache_control": "${request_cache_control}",'+
    '"request_authorization": "${request_authorization}",'+
    '"request_content_encoding": "${request_content_encoding}",'+
    '"request_content_type": "${request_content_type}",'+
    '"request_content_length": "${request_content_length}",'+
    '"request_content_version": "${request_content_version}",'+
    '"request_content": "${request_content}"'+
    '},'+
    '"response": {'+
    '"response_version": "${response_version}",'+
    '"response_reason": "${response_reason}", '+
    '"response_server": "${response_server}",'+
    '"response_realm": "${response_realm}",'+
    '"response_allow": "${response_allow}",'+
    '"response_location": "${response_location}",'+
    '"response_log_message": "${response_log_message}",'+
    '"response_title": "${response_title}",'+
    '"response_content_encoding": "${response_content_encoding}",'+
    '"response_content_type": "${response_content_type}",'+
    '"response_content_length": "${response_content_length}",'+
    '"response_content_version": "${response_content_version}",'+
    '"response_status": "${response_status}",'+
    '"response_content": "${response_content}"'+
    '}'+
    '}';

implementation

end.
