module main

import os
import kitten
import intents

fn get_intents() int {
	mut r := intents.Intent.@none.int()

	r += intents.Intent.guild_messages.int() // Guild Messages
	r += intents.Intent.message_content.int() // Message Content

	return r
}

fn main() {
	mut client := kitten.new_client(os.getenv('DISCORD_TOKEN'), get_intents())

	// Todo: add on_message handler here

	client.start()!
	client.wait()!
}
