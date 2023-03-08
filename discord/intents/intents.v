module intents

pub type Intent = u16

pub const (
	@none = Intent(0)
	guilds = Intent(1 << 0)
	guild_members = Intent(1 << 1)
	guild_moderation = Intent(1 << 2)
	guild_emojis_and_stickers = Intent(1 << 3)
	guild_integrations = Intent(1 << 4)
	guild_webhooks = Intent(1 << 5)
	guild_invites = Intent(1 << 6)
	guild_voice_states = Intent(1 << 7)
	guild_presences = Intent(1 << 8)
	guild_messages = Intent(1 << 9)
	guild_message_reactions = Intent(1 << 10)
	guild_message_typing = Intent(1 << 11)
	direct_messages = Intent(1 << 12)
	direct_message_reactions = Intent(1 << 13)
	direct_message_typing = Intent(1 << 14)
	message_content = Intent(1 << 15)
	guild_scheduled_events = Intent(1 << 16)
	auto_moderation_configuration = Intent(1 << 20)
	auto_moderation_execution = Intent(1 << 21)
)
