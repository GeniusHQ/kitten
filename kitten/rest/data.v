module rest

type Snowflake = string

struct Role {
	// Todo: complete this
}

enum ChannelType {
	guild_text = 0
	dm = 1
	guild_voice = 2
	group_dm = 3
	guild_category = 4
	guild_announcement = 5
	announcement_thread = 10
	public_thread = 11
	private_thread = 12
	guild_stage_voice = 13
	guild_directory = 14
	guild_forum = 15
}

enum MessageType {
	default = 0
	recipient_add = 1
	recipient_remove = 2
	call = 3
	channel_name_change = 4
	channel_icon_change = 5
	channel_pinned_message = 6
	user_join = 7
	guild_boost = 8
	guild_boost_tier_1 = 9
	guild_boost_tier_2 = 10
	guild_boost_tier_3 = 11
	channel_follow_add = 12
	guild_discovery_disqualified = 14
	guild_discovery_requalified = 15
	guild_discovery_grace_period_initial_warning = 16
	guild_discovery_grace_period_final_warning = 17
	thread_created = 18
	reply = 19
	chat_input_command = 20
	thread_starter_message = 21
	guild_invite_reminder = 22
	context_menu_command = 23
	auto_moderation_action = 24
	role_subscription_purchase = 25
	interaction_premium_upsell = 26
	stage_start = 27
	stage_end = 28
	stage_speaker = 29
	stage_topic = 31
	guild_application_premium_subscription = 32
}

struct MessageReference {
	message Snowflake [json: 'message_id']
	// Fixme: Need to find a way to skip serializing empty fields like 'omitempty' in go. Until then, just message works
	// channel Snowflake [json: 'channel_id']
	// guild   Snowflake [json: 'guild_id']
	// fail_if_not_exists bool
}
