module gateway

import time
import net.websocket
import network
import reflect
import logger
import x.json2
import os

const guilded_gateway_endpoint = 'wss://www.guilded.gg/websocket/v1'

[heap]
pub struct Gateway {
	token string [required]
	http &network.HttpClient
mut:
	logger &logger.Logger
	client &network.WebsocketClient
	connected bool
	heartbeat_interval int
	sequence ?int
pub mut:
	fn_on_welcome        ?fn (event WelcomeEvent) !
	fn_on_message_create ?fn (event ChatMessageCreatedEvent)!
}

pub fn new_gateway(token string) &Gateway {
	gateway := &Gateway{
		token: token
		http: network.new_http_client()
		client: unsafe { nil }
		connected: false
		logger: logger.new_logger()
		heartbeat_interval: 0
		sequence: none
	}

	return gateway
}

fn (g &Gateway) token_raw() string {
	return g.token
}

fn (g &Gateway) token() string {
	return 'Bearer ${g.token_raw()}'
}

pub fn (mut g Gateway) start() ! {
	g.connect()!
}

pub fn (mut g Gateway) connect() ! {
	g.connected = false
	g.logger.info('connecting to guilded gateway')

	g.client = network.new_websocket_client(guilded_gateway_endpoint, mut g.logger)!
	g.client.client.header.add_custom('Authorization', g.token())!

	g.client.on_message(g.on_message)
	g.client.on_close(g.on_close)

	g.client.start()!
	g.connected = true
	g.client.listen()!

	g.logger.fatal('failed at listening to guilded gateway')

	// Todo: implement reconnecting
}

fn (mut g Gateway) on_message(mut c network.WebsocketClient, msg &websocket.Message) ! {
	match msg.opcode {
		.text_frame {
			payload := reflect.deserialize[GatewayPayload](msg.payload.bytestr())!

			g.handle_payload(payload)!
		}
		else {
			dump('unhandled guilded gateway websocket message type ${msg.opcode}')
		}
	}
}

fn (mut g Gateway) on_close(mut c network.WebsocketClient, code int, reason string) ! {
	g.logger.info('guilded gateway connection closed ${code} ${reason}')

	g.connected = false
}

fn (mut g Gateway) handle_payload(payload &GatewayPayload) ! {
	if v := payload.seq {
		if s := g.sequence {
			if v > s {
				g.sequence = v
			}
		} else {
			g.sequence = v
		}
	}

	match payload.op {
		.welcome {
			g.handle_payload_welcome(payload)!
		}
		.missable {
			g.handle_payload_missable(payload)!
		}
		else {
			dump('unimplemented payload ${payload.op}')
		}
	}
}

fn (mut g Gateway) handle_payload_welcome(payload &GatewayPayload) ! {
	event := reflect.from_map[WelcomeEvent](payload.data.as_map())

	if func := g.fn_on_welcome {
		func(event)!
	}
}

fn (mut g Gateway) handle_payload_missable(payload &GatewayPayload) ! {
	if event := payload.event {
		g.handle_event(payload.data, event)!
		return
	}

	return error('payload has no event field')
}
