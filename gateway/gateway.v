module gateway

import time
import net.websocket
import network
import reflect
import logger
import x.json2
import os

[heap]
pub struct Gateway {
	token   string              [required]
	intents int                 [required]
	http    &network.HttpClient
mut:
	logger             &logger.Logger
	client             &network.WebsocketClient
	connected          bool
	heartbeat_interval int
	sequence           ?int
	resume_url         string
	session_id         string
pub mut:
	fn_on_message ?fn (event MessageCreateEvent) !
}

pub fn new_gateway(token string, intents int) &Gateway {
	gateway := &Gateway{
		token: token
		intents: intents
		http: network.new_http_client()
		client: unsafe { nil }
		connected: false
		logger: logger.new_logger()
		heartbeat_interval: 0
		sequence: none
	}

	return gateway
}

pub fn (mut g Gateway) start() ! {
	g.connect()!
}

pub fn (mut g Gateway) connect() ! {
	g.connected = false
	g.logger.info('connecting to gateway')
	
	res := g.http.fetch_json[GatewayBotResponse]('GET', 'https://discord.com/api/v10/gateway/bot',
		'application/json')!
	url := '${res.url}?v=10&encoding=json'

	g.client = network.new_websocket_client(url, mut g.logger)!

	g.client.on_message(g.on_message)
	g.client.on_close(g.on_close)

	g.client.start()!
	g.connected = true
	g.client.listen()!

	for {
		g.reconnect()!
		time.sleep(time.second)
	}
}

pub fn (mut g Gateway) reconnect() ! {
	g.connected = false
	g.logger.info('reconnecting to gateway')

	g.client = network.new_websocket_client(g.resume_url, mut g.logger)!

	g.client.on_message(g.on_message)
	g.client.on_close(g.on_close)

	g.client.start()!
	g.connected = true
	g.logger.info('successfully reconnected to gateway')
	g.client.listen()!
}

fn (mut g Gateway) close()! {
	g.client.close()!
}

fn (mut g Gateway) get_sequence() json2.Any {
	if v := g.sequence {
		return v
	}

	return json2.Null{}
}

fn (mut g Gateway) routine_heartbeat() {
	for {
		time.sleep(time.millisecond * g.heartbeat_interval)

		if !g.connected {
			continue
		}

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

		// Todo: check if we receive heartbeat_ack
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

fn (mut g Gateway) send_resume() ! {
	mut seq := 0
	if v := g.sequence {
		seq = v
	}

	mut data := map[string]json2.Any{}

	data["token"] = g.token
	data["session_id"] = g.session_id
	data["seq"] = seq

	mut payload := GatewayPayload{
		op: .resume,
		data: data,
	}

	g.send(payload)!
}

fn (mut g Gateway) on_message(mut c network.WebsocketClient, msg &websocket.Message) ! {
	payload := reflect.deserialize[GatewayPayload](msg.payload.bytestr())!

	g.handle_payload(&payload)!
}

fn (mut g Gateway) on_close(mut c network.WebsocketClient, code int, reason string) ! {
	g.logger.info('websocket connection closed ${code} ${reason}')

	g.connected = false
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
