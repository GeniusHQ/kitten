module pong

import os
import kitten

fn intents() int {
	mut r := 0

	r |= 1 << 9 // Guild Messages
	r |= 1 << 15 // Message Content

	return r
}

fn main() {
	mut client := kitten.new_client(os.getenv('DISCORD_TOKEN'), intents())

	// Todo: add on_message handler here

	client.start()!
	client.wait()!
}
