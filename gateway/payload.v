module gateway

import x.json2

struct GatewayPayload {
pub mut:
	op    GatewayPayloadType
	data  json2.Any          [json: 'd']
	seq   ?int               [json: 's']
	event ?string            [json: 't']
}

enum GatewayPayloadType {
	invalid = -1
	dispatch
	heartbeat
	identify
	presence_update
	voice_state_update
	five_undocumented
	resume
	reconnect
	request_guild_members
	invalid_session
	hello
	heartbeat_ack
}

fn gateway_payload_type(v int) GatewayPayloadType {
	match v {
		0 { return .dispatch }
		1 { return .heartbeat }
		2 { return .identify }
		3 { return .presence_update }
		4 { return .voice_state_update }
		5 { return .five_undocumented }
		6 { return .resume }
		7 { return .reconnect }
		8 { return .request_guild_members }
		9 { return .invalid_session }
		10 { return .hello }
		11 { return .heartbeat_ack }
		else { return .invalid }
	}
}

pub fn (mut g GatewayPayload) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'op' {
				g.op = gateway_payload_type(val.int())
			}
			's' {
				g.seq = val.int()
			}
			't' {
				g.event = val.str()
			}
			'd' {
				g.data = val
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (g &GatewayPayload) to_map() map[string]json2.Any {
	mut r := map[string]json2.Any{}

	r['op'] = int(g.op)
	r['d'] = g.data

	if v := g.seq {
		r['s'] = v
	}

	if v := g.event {
		r['t'] = v
	}

	return r
}
