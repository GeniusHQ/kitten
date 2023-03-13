module main

import os

import kitten
import kitten.universe
import kitten.discord.intents

fn handle_ready(mut client kitten.Client) ! {
    println('Ready')
}

// This will reply to Discord and Guilded "!ping" messages
fn handle_message(mut client kitten.Client, message &universe.Message) ! {
	if message.content.to_lower() == "!ping" {
		client.universe_channel_message_send(message.platform, message.channel, "pong")!
	}
}

fn main() {
	mut client := kitten.new_client()

	client.with_discord(
	    os.getenv("DISCORD_TOKEN"),
	    intents.guild_messages | intents.message_content)

	client.with_guilded(
	    os.getenv("GUILDED_TOKEN"))

    client.universe_on_ready(handle_ready)
	client.universe_on_message_create(handle_message)

	client.start()!
	client.wait()!
}