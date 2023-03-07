module rest

import x.json2
import network

[heap]
pub struct Rest {
	token string              [required]
	http  &network.HttpClient
}

pub fn new_rest(token string) &Rest {
	rest := &Rest{
		token: token
		http: network.new_http_client()
	}

	return rest
}

fn (rest &Rest) token_raw() string {
	return rest.token
}

fn (rest &Rest) token_bot() string {
	return 'Bearer ' + rest.token_raw()
}

fn (rest &Rest) api_root() string {
	return 'https://www.guilded.gg/api/v1'
}

pub fn (rest &Rest) channel_fetch(channel_id string) !&Channel {
	response := rest.http.fetch_json[ChannelResponse](
		'GET',
		'${rest.api_root()}/channels/${channel_id}',
		rest.token_bot(),
		'application/json')!

	channel := response.channel

	return &channel
}

pub fn (rest &Rest) channel_message_send(channel_id string, content string) !&Message {
	mut data := map[string]json2.Any{}

	data['content'] = content

	response := rest.http.fetch_json_data[ChannelMessageSendResponse](
		'POST',
		'${rest.api_root()}/channels/${channel_id}/messages',
		rest.token_bot(),
		'application/json',
		json2.encode[map[string]json2.Any](data))!

	message := response.message

	return &message
}
