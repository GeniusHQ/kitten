module gateway

import x.json2
import kitten.reflect

pub enum InteractionType {
	invalid = -1
	ping = 1
	application_command
	message_component
	application_command_component
	modal_submit
}

pub enum InteractionCallbackType {
	invalid = -1
	pong = 1
	channel_message_with_source = 4
	deferred_channel_message_with_source = 5
	deferred_update_message = 6
	update_message = 7
	application_command_autocomplete_result = 8
	modal = 9
}

pub fn interaction_type(v int) InteractionType {
	match v {
		1 {
			return .ping
		}
		2 {
			return .application_command
		}
		3 {
			return .message_component
		}
		4 {
			return .application_command_component
		}
		5 {
			return .modal_submit
		}
		else {
			return .invalid
		}
	}
}

pub struct Interaction {
pub mut:
	id Snowflake [required; json: 'id']
	application Snowflake [required; json: 'application_id']
	@type InteractionType [required; json: 'type']
	data InteractionData [required; json: 'data'] // Todo: this can be optional in the future
	token string [required; json: 'token']
	// Todo: complete this
}

pub fn (mut i Interaction) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'id' {
				i.id = val.str()
			}
			'application' {
				i.application = val.str()
			}
			'type' {
				i.@type = interaction_type(val.int())
			}
			'data' {
				i.data = reflect.from_map[InteractionData](val.as_map())
			}
			'token' {
				i.token = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (i &Interaction) to_map() map[string]json2.Any {
	return {}
}

pub struct InteractionData {
pub mut:
	id Snowflake [required; json: 'id']
	name string [required; json: 'name']
	@type InteractionType [required; json: 'type']
	// Todo: complete this
}

pub fn (mut i InteractionData) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'id' {
				i.id = val.str()
			}
			'name' {
				i.name = val.str()
			}
			'type' {
				i.@type = interaction_type(val.int())
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}