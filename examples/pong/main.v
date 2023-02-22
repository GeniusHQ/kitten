module main

import os
import kitten
import kitten.intents
import kitten.gateway

fn get_intents() int {
	mut r := intents.Intent.@none.int()

	r += intents.Intent.guild_messages.int() // Guild Messages
	r += intents.Intent.message_content.int() // Message Content

	return r
}

fn main() {
	mut client := kitten.new_client(os.getenv('DISCORD_TOKEN'), get_intents())

	client.on_message_create(fn (mut client kitten.Client, event &gateway.MessageCreateEvent) ! {
		if event.content.to_lower().starts_with('!ping') {
			client.channel_message_send(
				event.channel,
				'pong')!
		}
	})

	client.start()!
	client.wait()!
}
