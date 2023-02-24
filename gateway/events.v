module gateway

import x.json2

[noinit]
pub struct MessageCreateEvent {
pub mut:
	content string [json: 'content']
	channel string [json: 'channel_id']
	author  string [json: 'author']
}

pub fn (mut event MessageCreateEvent) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'content' {
				event.content = val.str()
			}
			'channel_id' {
				event.channel = val.str()
			}
			'author' {
				event.author = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (event &MessageCreateEvent) to_map() map[string]json2.Any {
	return {}
}

fn (mut g Gateway) handle_event(data json2.Any, key string) ! {
	match key {
		'MESSAGE_CREATE' {
			mut event := MessageCreateEvent{}

			event.from_map(data.as_map())

			if func := g.fn_on_message {
				func(event)!
			}
		}
		else {
			dump('unimplemented event ${key} ${data}')
		}
	}
}
