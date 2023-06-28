module universe

pub struct Message {
pub:
	platform Platform [required]

	id      string [required]
	content string [required]
	channel string [required]
}

pub fn from_message(platform Platform, id string, content string, channel string) !&Message {
	mut message := Message{
		platform: platform
		id: id
		content: content
		channel: channel
	}

	return &message
}
