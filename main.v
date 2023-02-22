module main

import kitten
import os

fn main() {
	mut client := kitten.new_client(os.getenv('DISCORD_TOKEN'))

	client.start()!
	client.wait()!
}
