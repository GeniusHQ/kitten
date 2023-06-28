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
	missable = 0
	welcome = 1
	resumed = 2
	invalid_cursor = 8
	internal_error = 9
}

fn gateway_payload_type(v int) GatewayPayloadType {
	match v {
		0 { return .missable }
		1 { return .welcome }
		2 { return .resumed }
		8 { return .invalid_cursor }
		9 { return .internal_error }
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
