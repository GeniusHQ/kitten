module network

import net.websocket
import kitten.logger

type FnOnMessage = fn (mut c WebsocketClient, msg &websocket.Message) !

[heap]
pub struct WebsocketClient {
pub:
	client &websocket.Client
pub mut:
	logger        &logger.Logger
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
