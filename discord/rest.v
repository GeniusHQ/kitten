module discord

import network

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