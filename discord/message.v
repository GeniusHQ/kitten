module discord

import hlib.json

[noinit]
pub struct Message {
pub mut:
	id      Snowflake [required]
	channel Snowflake [json: 'channel_id'; required]
	content string    [required]
}

pub fn (mut m Message) from_json(v json.Value) ! {
	data := v.object().get()!

	m.id      = data.at('id').get()!.string().get()!
    m.channel = data.at('channel_id').get()!.string().get()!
    m.content = data.at('content').get()!.string().get()!
}

pub fn (m &Message) to_json() json.Value {
	return map[string]json.Value{}
}
