module rest

import network
import x.json2

[heap]
pub struct Rest {
	token   string              [required]
	intents int                 [required]
	http    &network.HttpClient
}

pub fn new_rest(token string, intents int) &Rest {
	rest := &Rest{
		token: token
		intents: intents
		http: network.new_http_client()
	}

	return rest
}

fn (rest &Rest) token_raw() string {
	return rest.token
}

fn (rest &Rest) token_bot() string {
	return 'Bot ' + rest.token_raw()
}

pub fn (rest &Rest) channel_fetch(channel_id string) !&Channel {
	channel := rest.http.fetch_json[Channel]('GET', 'https://discord.com/api/v10/channels/${channel_id}',
		'application/json')!

	return &channel
}

pub fn (rest &Rest) channel_message_send(channel_id string, content string) !&Message {
	mut data := map[string]json2.Any{}
	data['content'] = content

	message := rest.http.fetch_json_data[Message]('POST', 'https://discord.com/api/v10/channels/${channel_id}/messages',
		'application/json', json2.encode[map[string]json2.Any](data))!

	return &message
}
