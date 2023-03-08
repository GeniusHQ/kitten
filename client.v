module kitten

import os
import universe
import discord.rest as discord_rest
import discord.gateway as discord_gateway
import guilded.rest as guilded_rest

[heap]
pub struct Client { // Todo: receive messages from guilded
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
	discord_fn_on_ready   ?fn (mut client Client, event &discord_gateway.ReadyEvent) !
	discord_fn_on_message ?fn (mut client Client, event &discord_gateway.MessageCreateEvent) !
	universe_fn_on_message ?fn (mut client Client, message &universe.Message) !
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
	client.discord_gateway.fn_on_ready = client.discord_event_ready
	client.discord_gateway.fn_on_message = client.discord_event_message_create

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

fn (mut client Client) discord_event_ready(event discord_gateway.ReadyEvent) ! {
	if func := client.discord_fn_on_ready {
		func(mut client, event)!
	}
}

fn (mut client Client) discord_event_message_create(event discord_gateway.MessageCreateEvent) ! {
	if func := client.discord_fn_on_message {
		func(mut client, event)!
	}

	message_discord := client.discord_channel_message_fetch(
		event.channel,
		event.id)!

	message := universe.from_message(
		universe.Platform.discord,
		string(message_discord.id),
		string(message_discord.content),
		string(message_discord.channel))!

	if func := client.universe_fn_on_message {
		func(mut client, message)!
	}
}

pub fn (mut client Client) discord_on_ready(func fn (mut client Client, event &discord_gateway.ReadyEvent) !) {
	client.discord_fn_on_ready = func
}

pub fn (mut client Client) discord_on_message_create(func fn (mut client Client, event &discord_gateway.MessageCreateEvent) !) {
	client.discord_fn_on_message = func
}

pub fn (client &Client) discord_channel_fetch(channel_id string) !&discord_rest.Channel {
	return client.discord_rest.channel_fetch(channel_id)!
}

pub fn (client &Client) discord_channel_message_send(channel string, content string) !&discord_rest.Message {
	return client.discord_rest.channel_message_send(channel, content)!
}

pub fn (client &Client) discord_channel_message_fetch(channel_id string, message_id string) !&discord_rest.Message {
	return client.discord_rest.channel_message_fetch(channel_id, message_id)!
}

pub fn (client &Client) guilded_channel_fetch(channel_id string) !&guilded_rest.Channel {
	return client.guilded_rest.channel_fetch(channel_id)!
}

pub fn (client &Client) guilded_channel_message_send(channel_id string, content string) !&guilded_rest.Message {
	return client.guilded_rest.channel_message_send(channel_id, content)!
}

pub fn (mut client Client) universe_on_message_create(func fn (mut client Client, message &universe.Message) !) {
	client.universe_fn_on_message = func
}

pub fn (client &Client) universe_channel_message_send(platform universe.Platform, channel_id string, content string) !&universe.Message {
	match platform {
		.discord {
			message_platform := client.discord_channel_message_send(channel_id, content)!

			message := universe.from_message(
				universe.Platform.discord,
				string(message_platform.id),
				string(message_platform.content),
				string(message_platform.channel))!

			return message
		}
		.guilded {
			message_platform := client.guilded_channel_message_send(channel_id, content)!

			message := universe.from_message(
				universe.Platform.discord,
				string(message_platform.id),
				string(message_platform.content),
				string(message_platform.channel))!

			return message
		}
		else {
			dump('unimplemented ${platform}')
		}
	}

	return error('platform has not been implemented')
}