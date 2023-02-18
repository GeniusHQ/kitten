module main

import net.http
import json

struct Rest {
	token string [required]
}

fn (rest &Rest) token_raw() string {
	return rest.token
}

fn (rest &Rest) token_bot() string {
	return 'Bot ' + rest.token_raw()
}

fn (rest &Rest) api_endpoint() string {
	return 'https://discord.com/api/v10'
}

fn (rest &Rest) user_agent() string {
	return 'Kitten (https://github.com/geniushq/kitten v0.0.0)'
}

fn (rest &Rest) headers_raw() map[string]string {
	return {
		'Authorization': rest.token_bot()
		'User-Agent':    rest.user_agent()
	}
}

fn (rest &Rest) headers() !http.Header {
	return http.new_custom_header_from_map(rest.headers_raw())!
}

fn (rest &Rest) fetch(method string, url string, content_type string, data string) !string {
	mut header := rest.headers()!

	header.set_custom('Content-Type', content_type)!

	res := http.fetch(
		method: http.method_from_str(method.to_upper())
		url: url
		header: header
		data: data
	)!

	return res.body
}

fn (rest &Rest) fetch_json[T](method string, url string, content_type string) !T {
	body := rest.fetch(method, url, content_type, '')!

	return json.decode(T, body)!
}

fn (rest &Rest) fetch_json_data[T](method string, url string, content_type string, data string) !T {
	body := rest.fetch(method, url, content_type, data)!

	return json.decode(T, body)!
}
