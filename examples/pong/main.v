module main

import os
import kitten
import kitten.intents
import kitten.gateway

fn get_intents() int {
	mut r := intents.Intent.@none.int()

	r |= intents.Intent.guild_messages.int() // Guild Messages
	r |= intents.Intent.message_content.int() // Message Content

	return r
}

fn handle_on_ready(mut client kitten.Client, event &gateway.ReadyEvent) ! {
	println('Ready')
}

fn handle_on_message(mut client kitten.Client, event &gateway.MessageCreateEvent) ! {
	if event.content.to_lower().starts_with('!ping') {
		client.channel_message_send(event.channel, 'pong')!
	}
}

fn main() {
	mut client := kitten.new_client(os.getenv('DISCORD_TOKEN'), get_intents())

	client.on_message_create(handle_on_message)

	client.start()!
	client.wait()!
}
