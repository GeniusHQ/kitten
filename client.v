module kitten

import os
import rest
import gateway

[heap]
pub struct Client {
pub:
	token   string
	intents int
	stop    chan int
pub mut:
	rest    &rest.Rest
	gateway &gateway.Gateway
}

pub fn new_client(token string, intents int) &Client {
	return &Client{
		token: token
		intents: intents
		stop: chan int{cap: 1}
		rest: rest.new_rest(token, intents)
		gateway: gateway.new_gateway(token, intents)
	}
}

pub fn (mut client Client) start() ! {
	client.gateway.start()!
}

pub fn (client &Client) wait() ! {
	os.signal_opt(.int, fn [client] (_ os.Signal) {
		client.stop <- 42
	})!

	_ = <-client.stop

	print('\r')
	println('exiting')
}

pub fn (client &Client) channel_fetch(channel string) !&rest.Channel {
	return client.rest.channel_fetch(channel)!
}

pub fn (client &Client) channel_message_send(channel string, content string) !&rest.Message {
	return client.rest.channel_message_send(channel, content)!
}
