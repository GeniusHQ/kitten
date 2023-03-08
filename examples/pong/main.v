module main

import os

import kitten
import kitten.universe
import kitten.discord.intents as discord_intents
import kitten.discord.gateway as discord_gateway

fn get_discord_intents() int {
	mut r := discord_intents.@none

	r |= discord_intents.guild_messages // Guild Messages
	r |= discord_intents.message_content // Message Content

	return r
}

fn handle_on_ready(mut client kitten.Client, event &discord_gateway.ReadyEvent) ! {
	println('Ready')
}

fn handle_universe_on_message_create(mut client kitten.Client, message &universe.Message) ! {
	if message.content.to_lower() == '!ping' {
		client.universe_channel_message_send(message.platform, message.channel, 'pong')!
	}
}

fn main() {
	mut client := kitten.new_client(
		os.getenv('DISCORD_TOKEN'), get_discord_intents(),
		os.getenv("GUILDED_TOKEN"))

	client.discord_on_ready(handle_on_ready)
	client.universe_on_message_create(handle_universe_on_message_create)

	client.start()!
	client.wait()!
}
