module gateway

import x.json2
import guilded.rest
import reflect

type UUID = string

[noinit]
pub struct ChatMessageCreatedEvent {
pub mut:
	server  UUID          [json: 'serverId']
	message &rest.Message [json: 'message'] = unsafe { nil }
}

pub fn (mut event ChatMessageCreatedEvent) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'serverId' {
				event.server = val.str()
			}
			'message' {
				message := reflect.from_map[rest.Message](val.as_map())
				event.message = &message
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (event &ChatMessageCreatedEvent) to_map() map[string]json2.Any {
	return {}
}

[noinit]
pub struct WelcomeEvent {
pub mut:
	heartbeat_interval int        [json: 'heartbeatIntervalMs']
	last_message       string     [json: 'lastMessageId']
	bot_id             UUID       [json: 'botId']
	user               &rest.User [json: 'user']
}

pub fn (mut event WelcomeEvent) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'heartbeatIntervalMs' {
				event.heartbeat_interval = val.int()
			}
			'lastMessageId' {
				event.last_message = val.str()
			}
			'botId' {
				event.bot_id = val.str()
			}
			'user' {
				user := reflect.from_map[rest.User](val.as_map())
				event.user = &user
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (event &WelcomeEvent) to_map() map[string]json2.Any {
	return {}
}

fn (mut g Gateway) handle_event(data json2.Any, key string) ! {
	match key {
		'ChatMessageCreated' {
			mut event := ChatMessageCreatedEvent{}

			event.from_map(data.as_map())

			if func := g.fn_on_message_create {
				func(event)!
			}
		}
		else {
			dump('unimplemented event ${key} ${data}')
		}
	}
}
