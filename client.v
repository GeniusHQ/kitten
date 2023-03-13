module kitten

import os
import universe
import discord.rest as discord_rest
import discord.gateway as discord_gateway
import discord.intents as discord_intents
import guilded.rest as guilded_rest
import guilded.gateway as guilded_gateway

[heap]
pub struct Client { // Todo: receive messages from guilded
pub:
	stop            chan int
pub mut:
	platforms       map[universe.Platform]universe.PlatformState
	discord_token   string
	discord_intents int
	discord_rest    &discord_rest.Rest = unsafe { nil }
	discord_gateway &discord_gateway.Gateway = unsafe { nil }
	guilded_token   string
	guilded_rest    &guilded_rest.Rest = unsafe { nil }
	guilded_gateway &guilded_gateway.Gateway = unsafe { nil }
mut:
	discord_fn_on_ready          ?fn (mut client Client, event &discord_gateway.ReadyEvent) !
	discord_fn_on_message        ?fn (mut client Client, event &discord_gateway.MessageCreateEvent) !
	guilded_fn_on_welcome        ?fn (mut client Client, event &guilded_gateway.WelcomeEvent) !
	guilded_fn_on_message_create ?fn (mut client Client, event &guilded_gateway.ChatMessageCreatedEvent) !
	universe_fn_on_ready         ?fn (mut client Client) !
	universe_fn_on_message       ?fn (mut client Client, message &universe.Message) !
}

pub fn new_client() &Client {
	return &Client{
		stop: chan int{cap: 1}
		platforms: map[universe.Platform]universe.PlatformState{}
	}
}

pub fn (mut client Client) with_discord(token string, intents discord_intents.Intent) &Client {
	client.platforms[.discord] = .initializing

	client.discord_token = token
	client.discord_intents = intents
	
	client.discord_rest = discord_rest.new_rest(
		client.discord_token,
		client.discord_intents)

	client.discord_gateway = discord_gateway.new_gateway(
		client.discord_token,
		client.discord_intents)

	return client }

pub fn (mut client Client) with_guilded(token string) &Client {
	client.platforms[.guilded] = .initializing

	client.guilded_token = token

	client.guilded_rest = guilded_rest.new_rest(
		client.guilded_token)

	client.guilded_gateway = guilded_gateway.new_gateway(
		client.guilded_token)

	return client
}

pub fn (mut client Client) start() ! {
	for platform, state in client.platforms {
		if state != .initializing {
			continue
		}

		match platform {
			.discord {
				client.discord_gateway.fn_on_ready = client.discord_event_ready
				client.discord_gateway.fn_on_message = client.discord_event_message_create

				spawn fn[mut client]() {
					client.discord_gateway.start() or {
						panic('client discord gateway ${err}')
					}
				}()
			}
			.guilded {
				client.guilded_gateway.fn_on_welcome = client.guilded_event_welcome
				client.guilded_gateway.fn_on_message_create = client.guilded_event_message_create

				spawn fn[mut client]() {
					client.guilded_gateway.start() or {
						panic('client guilded gateway ${err}')
					}
				}()
			}
			else {
				dump('unimplemented platform ${platform}')
			}
		}
	}
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

	client.universe_ready_check(.discord)! // Todo: make this async?
}

fn (mut client Client) discord_event_message_create(event discord_gateway.MessageCreateEvent) ! {
	if func := client.discord_fn_on_message {
		func(mut client, event)!
	}

	message_platform := client.discord_channel_message_fetch(
		event.channel,
		event.id)!

	message := universe.from_message(
		.discord,
		string(message_platform.id),
		string(message_platform.content),
		string(message_platform.channel))!

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

pub fn (mut client Client) guilded_event_welcome(event guilded_gateway.WelcomeEvent) ! {
	if func := client.guilded_fn_on_welcome {
		func(mut client, event)!
	}

	client.universe_ready_check(.guilded)! // Todo: make this async?
}

pub fn (mut client Client) guilded_event_message_create(event guilded_gateway.ChatMessageCreatedEvent) ! {
	if func := client.guilded_fn_on_message_create {
		func(mut client, event)!
	}

	message_platform := event.message

	message := universe.from_message(
		.guilded,
		string(message_platform.id),
		string(message_platform.content),
		string(message_platform.channel))!

	if func := client.universe_fn_on_message {
		func(mut client, message)!
	}
}

pub fn (mut client Client) guilded_on_message_create(func fn (mut client Client, event &guilded_gateway.ChatMessageCreatedEvent) !) {
	client.guilded_fn_on_message_create = func
}

pub fn (client &Client) guilded_channel_fetch(channel_id string) !&guilded_rest.Channel {
	return client.guilded_rest.channel_fetch(channel_id)!
}

pub fn (client &Client) guilded_channel_message_send(channel_id string, content string) !&guilded_rest.Message {
	return client.guilded_rest.channel_message_send(channel_id, content)!
}

// This method will be called every time a client is ready, and call
// universe_on_ready when all initialized platforms are successfully
// connected.
pub fn (mut client Client) universe_ready_check(platform universe.Platform) ! {
	mut flag := true

	client.platforms[platform] = .ready

	println(client.platforms)

	for _, state in client.platforms {
		if state != .ready {
			flag = false
			break
		}
	}

	if flag {
		if func := client.universe_fn_on_ready {
			func(mut client)!
		}
	}
}

pub fn (mut client Client) universe_on_ready(func fn (mut client Client) !) {
	client.universe_fn_on_ready = func
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
