module main

import kitten
import os

fn intents() int {
	mut r := 0

	r |= 1 << 9 // Guild Messages
	r |= 1 << 15 // Message Content

	return r
}

fn main() {
	mut client := kitten.new_client(os.getenv('DISCORD_TOKEN'), intents())

	client.start()!
	client.wait()!
}
