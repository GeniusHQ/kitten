module gateway

import x.json2
import rest
import reflect

[noinit]
pub struct MessageCreateEvent {
pub mut:
	content string     [json: 'content']
	channel string     [json: 'channel_id']
	author  &rest.User [json: 'author'] = unsafe { nil } // Todo: find a better way to do this
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
				user := reflect.from_map[rest.User](val.as_map())
				event.author = &user
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

[noinit]
pub struct ReadyEvent {
pub mut:
	session_id         string [json: 'session_id']
	resume_gateway_url string
}

pub fn (mut event ReadyEvent) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'session_id' {
				event.session_id = val.str()
			}
			'resume_gateway_url' {
				event.resume_gateway_url = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (event &ReadyEvent) to_map() map[string]json2.Any {
	return {}
}

fn (mut g Gateway) handle_event(data json2.Any, key string) ! {
	match key {
		'READY' {
			mut event := ReadyEvent{}

			event.from_map(data.as_map())

			g.session_id = event.session_id
			g.resume_url = event.resume_gateway_url

			if func := g.fn_on_ready {
				func(event)!
			}
		}
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
