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
	// Todo: add permission_overwrites
	name                optional.Optional[string]
	topic               optional.Optional[string]
	nsfw                optional.Optional[bool]
	last_message_id     optional.Optional[Snowflake]
	bitrate             optional.Optional[int]
	user_limit          optional.Optional[int]
	rate_limit_per_user int
	// Todo: add recipients
	icon        string
	owner       Snowflake
	application Snowflake
	managed     bool
	parent      Snowflake
	// Todo: add last_pin_timestamp
	rtc_region string
	// Todo: add video_quality_mode
	message_count int
	member_count  int
	// Todo: add thread_metadata
	// Todo: add member
	// Todo: add default_auto_archive_duration
	permissions        string
	flags              int
	total_message_sent int
	// Todo: add available_tags
	// Todo: add applied_tags
	// Todo: add default_reaction_emoji
	// Todo: add default_thread_rate_limit_per_user
	// Todo: add default_sort_order
	// Todo: add default_forum_layout
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
