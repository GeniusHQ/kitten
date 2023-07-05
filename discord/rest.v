module discord

import network

import hlib.json

[heap]
pub struct Rest {
	token   string [required]
	intents int    [required]
	http    &network.HttpClient
}

pub fn Rest.new(token string, intents int) &Rest {
	rest := &Rest{
		token:   token,
		intents: intents,
		http:    network.new_http_client(),
	}

	return rest
}

fn (rest &Rest) token_raw() string {
	return rest.token
}

fn (rest &Rest) token_bot() string {
	return 'Bot ${rest.token_raw()}'
}

fn (rest &Rest) api_root() string {
	return 'https://discord.com/api/v10'
}

pub fn (rest &Rest) channel_fetch(channel_id string) !&Channel {
	channel := rest.http.fetch_json[Channel](
		'GET',
		'${rest.api_root()}/channels/${channel_id}',
		rest.token_bot(),
		'application/json')!

	return &channel
}

pub fn (rest &Rest) channel_message_send(channel_id string, content string) !&Message {
	mut data := map[string]json.Value{}

	data['content'] = content

	message := rest.http.fetch_json_data[Message](
		'POST',
		'${rest.api_root()}/channels/${channel_id}/messages',
		rest.token_bot(),
		'application/json',
		json.encode(data))!

	return &message
}