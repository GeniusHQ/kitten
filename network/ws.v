module network

import net.websocket

[heap]
struct WebsocketClient {
pub:
	client &websocket.Client
}

pub fn new_websocket_client(addr string) !&WebsocketClient {
	client := &WebsocketClient{
		client: websocket.new_client(addr)!
	}

	return client
}
