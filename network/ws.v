module network

import net.websocket
import logger

type FnOnMessage = fn (mut c WebsocketClient, msg &websocket.Message) !

[heap]
pub struct WebsocketClient {
pub mut:
	logger        &logger.Logger
	client        &websocket.Client
	fn_on_message ?FnOnMessage
}

pub fn new_websocket_client(addr string, mut l logger.Logger) !&WebsocketClient {
	mut ws_client := websocket.new_client(addr, logger: l)!

	mut client := &WebsocketClient{
		logger: l
		client: ws_client
	}

	ws_client.on_message(client.ws_on_message)
	ws_client.on_close(client.ws_on_close)

	return client
}

pub fn (mut c WebsocketClient) start() ! {
	c.client.connect()!

	spawn c.routine_listen()
}

pub fn (mut c WebsocketClient) on_message(func FnOnMessage) {
	c.fn_on_message = func
}

fn (mut c WebsocketClient) ws_on_message(mut client websocket.Client, msg &websocket.Message) ! {
	if func := c.fn_on_message {
		func(mut c, msg)!
	}
}

fn (mut c WebsocketClient) ws_on_close(mut client websocket.Client, code int, reason string) ! {
	c.logger.warn('websocket closed code=${code} reason=${reason}')
}

pub fn (mut c WebsocketClient) write_binary(v []byte) ! {
	c.client.write(v, .text_frame)!
}

pub fn (mut c WebsocketClient) write_string(v string) ! {
	c.client.write_string(v)!
}

fn (mut c WebsocketClient) routine_listen() {
	for {
		c.client.listen() or { c.logger.warn('failed at listening websocket ${err}') }
	}
}
