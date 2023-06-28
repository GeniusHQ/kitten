module network

import net.http
import reflect

const useragent = 'Kitten (https://github.com/geniushq/kitten v0.0.0)'

pub struct HttpClient {
}

pub fn new_http_client() &HttpClient {
	client := &HttpClient{}

	return client
}

fn (h &HttpClient) headers_raw() map[string]string {
	return {
		'User-Agent': network.useragent
	}
}

fn (h &HttpClient) headers() !http.Header {
	return http.new_custom_header_from_map(h.headers_raw())!
}

pub fn (h &HttpClient) fetch(method string, url string, authorization string, content_type string, data string) !string {
	mut header := h.headers()!

	header.set_custom('Authorization', authorization)!
	header.set_custom('Content-Type', content_type)!

	res := http.fetch(
		method: http.method_from_str(method.to_upper())
		url: url
		header: header
		data: data
	)!

	return res.body
}

pub fn (h &HttpClient) fetch_json[T](method string, url string, authorization string, content_type string) !T {
	body := h.fetch(method, url, authorization, content_type, '')!

	return reflect.deserialize[T](body)!
}

pub fn (h &HttpClient) fetch_json_data[T](method string, url string, authorization string, content_type string, data string) !T {
	body := h.fetch(method, url, authorization, content_type, data)!

	return reflect.deserialize[T](body)!
}
