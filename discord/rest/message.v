module rest

import x.json2

[noinit]
pub struct Message {
pub mut:
	id      Snowflake [required]
	channel Snowflake [json: 'channel_id'; required]
	author  &User     [required]
	content string    [required]
	// Todo: add timestamp
	// Todo: add edited_timestamp
	tts              bool   [required]
	mention_everyone bool   [required]
	mentions         []User [required]
	mention_roles    []Role [required]
	// Todo: add mention_channels
	// Todo: add attachments
	// Todo: add embeds
	// Todo: add reactions
	nonce      string
	pinned     bool        [required]
	webhook_id Snowflake
	@type      MessageType [required]
	// Todo: add activity
	// Todo: add application
	// Todo: add application_id
	// Todo: add message_reference
	flags int
	// Todo: add referenced_message
	// Todo: add interaction
	thread &Channel
	// Todo: add components
	// Todo: add sticker_items
	position int
	// Todo: add role_subscription_data
}

pub fn (mut m Message) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'id' {
				m.id = val.str()
			}
			'channel_id' {
				m.channel = val.str()
			}
			'author' {
				mut user := User{}
				user.from_map(val.as_map())
				m.author = &user
			}
			'content' {
				m.content = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (m &Message) to_map() map[string]json2.Any {
	return {}
}
