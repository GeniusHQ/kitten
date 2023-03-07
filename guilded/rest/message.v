module rest

import x.json2
import reflect

pub struct Message {
pub mut:
	id      string [required]
	@type   string [required] // Todo: maybe use an enum
	server  UUID   [json: 'serverId']
	channel UUID   [json: 'channelId'; required]
	content string
	// Todo: complete this
	created_by string [required]
}

pub fn (mut m Message) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'id' {
				m.id = val.str()
			}
			'type' {
				m.@type = val.str()
			}
			'serverId' {
				m.server = val.str()
			}
			'content' {
				m.content = val.str()
			}
			'channelId' {
				m.channel = val.str()
			}
			'createdBy' {
				m.created_by = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (mut m Message) to_map() map[string]json2.Any {
	return {}
}

[noinit]
pub struct ChannelMessageSendResponse {
pub mut:
	message Message [required]
}

pub fn (mut r ChannelMessageSendResponse) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'message' {
				r.message = reflect.from_map[Message](val.as_map())
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (r &ChannelMessageSendResponse) to_map() map[string]json2.Any {
	return {}
}
