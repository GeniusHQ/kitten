module kitten

import os
import discord.rest as discord_rest
import discord.gateway as discord_gateway
import guilded.rest as guilded_rest

[heap]
pub struct Client {
pub:
	stop            chan int
	discord_token   string
	discord_intents int
	guilded_token   string
pub mut:
	discord_rest    &discord_rest.Rest
	discord_gateway &discord_gateway.Gateway
	guilded_rest    &guilded_rest.Rest
mut:
	fn_on_ready   ?fn (mut client Client, event &discord_gateway.ReadyEvent) !
	fn_on_message ?fn (mut client Client, event &discord_gateway.MessageCreateEvent) !
}

pub fn new_client(discord_token string, discord_intents int, guilded_token string) &Client {
	return &Client{
		stop: chan int{cap: 1}
		discord_token: discord_token
		discord_intents: discord_intents
		discord_rest: discord_rest.new_rest(discord_token, discord_intents)
		discord_gateway: discord_gateway.new_gateway(discord_token, discord_intents)
		guilded_token: guilded_token,
		guilded_rest: guilded_rest.new_rest(guilded_token),
	}
}

pub fn (mut client Client) start() ! {
	client.discord_gateway.fn_on_ready = client.event_ready
	client.discord_gateway.fn_on_message = client.event_message_create

	client.discord_gateway.start()!
}

pub fn (client &Client) wait() ! {
	os.signal_opt(.int, fn [client] (_ os.Signal) {
		client.stop <- 42
	})!

	_ = <-client.stop

	print('\r')
	println('exiting')
}

fn (mut client Client) event_ready(event discord_gateway.ReadyEvent) ! {
	if func := client.fn_on_ready {
		func(mut client, event)!
	}
}

fn (mut client Client) event_message_create(event discord_gateway.MessageCreateEvent) ! {
	if func := client.fn_on_message {
		func(mut client, event)!
	}
}

pub fn (mut client Client) discord_on_ready(func fn (mut client Client, event &discord_gateway.ReadyEvent) !) {
	client.fn_on_ready = func
}

pub fn (mut client Client) discord_on_message_create(func fn (mut client Client, event &discord_gateway.MessageCreateEvent) !) {
	client.fn_on_message = func
}

pub fn (client &Client) discord_channel_fetch(channel_id string) !&discord_rest.Channel {
	return client.discord_rest.channel_fetch(channel_id)!
}

pub fn (client &Client) discord_channel_message_send(channel string, content string) !&discord_rest.Message {
	return client.discord_rest.channel_message_send(channel, content)!
}

pub fn (client &Client) guilded_channel_fetch(channel_id string) !&guilded_rest.Channel {
	return client.guilded_rest.channel_fetch(channel_id)!
}