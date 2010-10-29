%%%-------------------------------------------------------------------
%%% @author Fernando Benavides <fernando.benavides@inakanetworks.com>
%%% @copyright (C) 2010 Fernando Benavides <fernando.benavides@inakanetworks.com>
%%% @doc Apple Push Notification Server for Erlang
%%% @end
%%%-------------------------------------------------------------------
-module(apns).
-vsn('0.1').

-include("apns.hrl").

-export([start/0, stop/0]).
-export([connect/0, connect/1, connect/2, disconnect/1]).
-export([send_badge/3, send_message/2, send_message/3, send_message/4, send_message/5]).

%%% @doc Starts the application
%%% @spec start() -> ok | {error, {already_started, apns}}.
-spec start() -> ok | {error, {already_started, apns}}.
start() ->
  application:start(public_key),
  application:start(ssl),
  application:start(apns).

%%% @doc Stops the application
%%% @spec stop() -> ok.
-spec stop() -> ok.
stop() ->
  application:stop(apns).

%% @doc Opens an unnamed connection using the default parameters
%% @spec connect() -> {ok, pid()} | {error, Reason::term()}.
-spec connect() -> {ok, pid()} | {error, Reason::term()}.
connect() ->
  connect(#apns_connection{}).

%% @doc Opens an unnamed connection using the given certificate file
%%      or using the given #apns_connection{} parameters
%%      or the name and default configuration if a name is given
%% @spec connect(atom() | string() | #apns_connection{}) -> {ok, pid()} | {error, {already_started, pid()}} | {error, Reason::term()}.
-spec connect(atom() | string() | #apns_connection{}) -> {ok, pid()} | {error, {already_started, pid()}} | {error, Reason::term()}.
connect(Name) when is_atom(Name) ->
  connect(Name, #apns_connection{});
connect(Connection) when is_record(Connection, apns_connection) ->
  apns_sup:start_connection(Connection);
connect(CertFile) ->
  connect(#apns_connection{cert_file = CertFile}).

%% @doc Opens an connection named after the atom()
%%      using the given certificate file
%%      or using the given #apns_connection{} parameters
%% @spec connect(atom(), string() | #apns_connection{}) -> {ok, pid()} | {error, {already_started, pid()}} | {error, Reason::term()}.
-spec connect(atom(), string() | #apns_connection{}) -> {ok, pid()} | {error, {already_started, pid()}} | {error, Reason::term()}.
connect(Name, Connection) when is_record(Connection, apns_connection) ->
  apns_sup:start_connection(Name, Connection);
connect(Name, CertFile) ->
  connect(Name, #apns_connection{cert_file = CertFile}).

-spec disconnect(conn_id()) -> ok.
disconnect(ConnId) ->
  apns_connection:stop(ConnId).

%% @doc Sends a message to Apple
%% @spec send_message(conn_id(), #apns_msg{}) -> ok.
-spec send_message(conn_id(), #apns_msg{}) -> ok.
send_message(ConnId, Msg) ->
  apns_connection:send_message(ConnId, Msg).

%% @doc Sends a message to Apple with just a badge
%% @spec send_badge(conn_id(), Token::string(), Badge::integer()) -> ok.
-spec send_badge(conn_id(), string(), integer()) -> ok.
send_badge(ConnId, DeviceToken, Badge) -> 
  send_message(ConnId, #apns_msg{device_token = DeviceToken,
                                 badge = Badge}).

%% @doc Sends a message to Apple with just an alert
%% @spec send_message(conn_id(), Token::string(), Alert::string()) -> ok.
-spec send_message(conn_id(), string(), string()) -> ok.
send_message(ConnId, DeviceToken, Alert) -> 
  send_message(ConnId, #apns_msg{device_token = DeviceToken,
                                 alert = Alert}).

%% @doc Sends a message to Apple with an alert and a badge
%% @spec send_message(conn_id(), Token::string(), Alert::string(), Badge::integer()) -> ok.
-spec send_message(conn_id(), Token::string(), Alert::string(), Badge::integer()) -> ok.
send_message(ConnId, DeviceToken, Alert, Badge) -> 
  send_message(ConnId, #apns_msg{device_token = DeviceToken,
                                 badge = Badge,
                                 alert = Alert}).

%% @doc Sends a full message to Apple
%% @spec send_message(conn_id(), Token::string(), Alert::string(), Badge::integer(), Sound::string()) -> ok.
-spec send_message(conn_id(), Token::string(), Alert::string(), Badge::integer(), Sound::string()) -> ok.
send_message(ConnId, DeviceToken, Alert, Badge, Sound) -> 
  send_message(ConnId, #apns_msg{alert = Alert,
                                 badge = Badge,
                                 sound = Sound,
                                 device_token = DeviceToken}).