module gateway

import time
import net.websocket
import network
import reflect
import x.json2
import os
import log
import logger

[heap]
pub struct Gateway {
	token   string              [required]
	intents int                 [required]
	http    &network.HttpClient
mut:
	logger             &log.Logger
	client             &websocket.Client
	heartbeat_interval int
	sequence           ?int
}

pub fn new_gateway(token string, intents int) &Gateway {
	gateway := &Gateway{
		token: token
		intents: intents
		http: network.new_http_client()
		client: unsafe { nil }
		logger: logger.new_logger()
		heartbeat_interval: 0
		sequence: none
	}

	return gateway
}

struct GatewayBotResponse {
	url    string
	shards int
	// Todo: add session_start_limit
}

pub fn (mut g Gateway) start() ! {
	res := g.http.fetch_json[GatewayBotResponse]('GET', 'https://discord.com/api/v10/gateway/bot',
		'application/json')!
	url := '${res.url}?v=10&encoding=json'

	g.client = websocket.new_client(url, logger: g.logger)!

	g.client.on_message(g.on_message)
	g.client.on_close(g.on_close)

	g.client.connect()!

	spawn g.routine_listen()
}

fn (mut g Gateway) get_sequence() json2.Any {
	if v := g.sequence {
		return v
	}

	return json2.Null{}
}

fn (mut g Gateway) routine_listen() {
	for {
		g.client.listen() or { eprintln('failed at listening websocket ${err}') }
	}
}

fn (mut g Gateway) routine_heartbeat() {
	for {
		time.sleep(time.millisecond * g.heartbeat_interval)

		t := 5
		for i := 0; i < t; i++ {
			g.send_heartbeat() or {
				eprintln('failed at sending heartbeat attempt ${i}/${t}')
				time.sleep(time.second)
				continue
			}

			g.logger.info('heartbeat sent')
			break
		}
	}
}

fn (mut g Gateway) send(payload &GatewayPayload) ! {
	g.client.write_string(reflect.serialize[GatewayPayload](payload))!
}

fn (mut g Gateway) send_heartbeat() ! {
	mut payload := GatewayPayload{
		op: .heartbeat
		data: g.get_sequence()
	}

	g.send(payload)!
}

fn (mut g Gateway) send_identify() ! {
	mut data := map[string]json2.Any{}

	mut data_properties := map[string]json2.Any{}

	data_properties['os'] = os.uname().sysname.to_lower()
	data_properties['browser'] = 'kitten'
	data_properties['device'] = 'kitten'

	data['token'] = g.token
	data['intents'] = g.intents
	data['properties'] = data_properties

	mut payload := GatewayPayload{
		op: .identify
		data: data
	}

	g.send(payload)!
}

fn (mut g Gateway) on_message(mut c websocket.Client, msg &websocket.Message) ! {
	payload := reflect.deserialize[GatewayPayload](msg.payload.bytestr())!

	g.handle_payload(&payload)!
}

fn (mut g Gateway) on_close(mut c websocket.Client, code int, reason string) ! {
	g.logger.fatal('websocket closed code=${code} reason=${reason}')
}

fn (mut g Gateway) handle_payload(payload &GatewayPayload) ! {
	if s := g.sequence {
		if v := payload.seq {
			if v > s {
				g.sequence = v
			}
		}
	}

	match payload.op {
		.hello {
			g.handle_payload_hello(payload)!
		}
		.dispatch {
			g.handle_payload_dispatch(payload)!
		}
		.heartbeat_ack {
			g.handle_payload_heartbeat_ack(payload)!
		}
		else {
			dump('unimplemented payload ${payload.op}')
		}
	}
}

fn (mut g Gateway) handle_payload_hello(payload &GatewayPayload) ! {
	data := payload.data.as_map()

	g.heartbeat_interval = data['heartbeat_interval']!.int()

	spawn g.routine_heartbeat()

	g.send_identify()!
}

fn (mut g Gateway) handle_payload_dispatch(payload &GatewayPayload) ! {
	if event := payload.event {
		g.handle_event(payload.data, event)!
		return
	}

	return error('payload has no event field')
}

fn (mut g Gateway) handle_payload_heartbeat_ack(payload &GatewayPayload) ! {
	g.logger.info('heartbeat acknowledged ${reflect.serialize[GatewayPayload](payload)}')
}
