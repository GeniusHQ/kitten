module network

import net.websocket
import logger

type FnOnMessage = fn (mut c WebsocketClient, msg &websocket.Message) !

type FnOnClose = fn (mut c WebsocketClient, code int, reason string) !

type FnOnOpen = fn (mut c WebsocketClient) !

[heap]
pub struct WebsocketClient {
pub mut:
	logger        &logger.Logger
	client        &websocket.Client
	fn_on_message ?FnOnMessage
	fn_on_close   ?FnOnClose
	fn_on_open    ?FnOnOpen
}

pub fn new_websocket_client(addr string, mut l logger.Logger) !&WebsocketClient {
	mut ws_client := websocket.new_client(addr, logger: l)!

	mut client := &WebsocketClient{
		logger: l
		client: ws_client
	}

	ws_client.on_message(client.ws_on_message)
	ws_client.on_close(client.ws_on_close)
	ws_client.on_open(client.ws_on_open)

	return client
}

pub fn (mut c WebsocketClient) start() ! {
	c.client.connect()!
}

pub fn (mut c WebsocketClient) listen() ! {
	c.client.listen()!
}

pub fn (mut c WebsocketClient) close() ! {
	c.free()
}

pub fn (mut c WebsocketClient) free() {
	c.client.free()
}

pub fn (mut c WebsocketClient) on_message(func FnOnMessage) {
	c.fn_on_message = func
}

pub fn (mut c WebsocketClient) on_close(func FnOnClose) {
	c.fn_on_close = func
}

pub fn (mut c WebsocketClient) on_open(func FnOnOpen) {
	c.fn_on_open = func
}

fn (mut c WebsocketClient) ws_on_message(mut client websocket.Client, msg &websocket.Message) ! {
	if func := c.fn_on_message {
		func(mut c, msg)!
	}
}

fn (mut c WebsocketClient) ws_on_close(mut client websocket.Client, code int, reason string) ! {
	if func := c.fn_on_close {
		func(mut c, code, reason)!
	}
}

fn (mut c WebsocketClient) ws_on_open(mut client websocket.Client) ! {
	if func := c.fn_on_open {
		func(mut c)!
	}
}

pub fn (mut c WebsocketClient) write_binary(v []byte) ! {
	c.client.write(v, .text_frame)!
}

pub fn (mut c WebsocketClient) write_string(v string) ! {
	c.client.write_string(v)!
}
