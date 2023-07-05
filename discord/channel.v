module discord

import hlib.json
import hlib.optional

[noinit]
pub struct Channel {
pub mut:
	id Snowflake [required]
	// @type    ChannelType [required]
	guild    Snowflake
	position optional.Optional[int]
}

pub fn (mut c Channel) from_json(v json.Value) ! {
	data := v.object().get()!

	c.id = data.at('id').get()!.string().get()!
	// Todo: type
	c.guild = data.at('guild_id').get()!.string().get()!
	c.position = data.at('position')
		.map(fn (v json.Value) int {
			return int(v.f64().get() or { 0 })
		})
}

pub fn (c &Channel) to_json() json.Value {
	return map[string]json.Value{}
}
