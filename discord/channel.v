module discord

import hlib.json

[noinit]
pub struct Channel {
	pub mut:
	id       Snowflake   [required]
	// @type    ChannelType [required]
	guild    Snowflake
	position int
	// Todo: add permission_overwrites
	name                string
	topic               string
	nsfw                bool
	last_message_id     Snowflake
	bitrate             int
	user_limit          int
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

	c.id = data.at("id").get()!
	// Todo: c.@type
}

pub fn (c &Channel) to_json() json.Value {
	return map[string]json.Value{}
}