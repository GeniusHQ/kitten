module kitten

import os
import discord.rest
import discord.gateway

[heap]
pub struct Client {
pub:
	token   string
	intents int
	stop    chan int
pub mut:
	rest    &rest.Rest
	gateway &gateway.Gateway
mut:
	fn_on_ready   ?fn (mut client Client, event &gateway.ReadyEvent) !
	fn_on_message ?fn (mut client Client, event &gateway.MessageCreateEvent) !
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
	client.gateway.fn_on_ready = client.event_ready
	client.gateway.fn_on_message = client.event_message_create

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

fn (mut client Client) event_ready(event gateway.ReadyEvent) ! {
	if func := client.fn_on_ready {
		func(mut client, event)!
	}
}

fn (mut client Client) event_message_create(event gateway.MessageCreateEvent) ! {
	if func := client.fn_on_message {
		func(mut client, event)!
	}
}

pub fn (mut client Client) on_ready(func fn (mut client Client, event &gateway.ReadyEvent) !) {
	client.fn_on_ready = func
}

pub fn (mut client Client) on_message_create(func fn (mut client Client, event &gateway.MessageCreateEvent) !) {
	client.fn_on_message = func
}

pub fn (client &Client) channel_fetch(channel string) !&rest.Channel {
	return client.rest.channel_fetch(channel)!
}

pub fn (client &Client) channel_message_send(channel string, content string) !&rest.Message {
	return client.rest.channel_message_send(channel, content)!
}
