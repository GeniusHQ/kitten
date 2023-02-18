module main

import json

struct Client {
	rest &Rest [required]
}

fn new_client(token string) &Client {
	return &Client{
		rest: &Rest{
			token: token
		}
	}
}

fn (client &Client) channel_fetch(channel string) !Channel {
	return client.rest.fetch_json[Channel]('get', '${client.rest.api_endpoint()}/channels/${channel}',
		'application/json')!
}

fn (client &Client) channel_message_send(channel string, content string) !Message {
	data := {
		'content': content
	}

	return client.rest.fetch_json_data[Message]('post', client.rest.api_endpoint() +
		'/channels/${channel}/messages', 'application/json', json.encode(data))!
}
