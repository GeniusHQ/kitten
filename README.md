<div align="center">
  <img style="width: 128px; height: 128px" src="https://media.githubusercontent.com/media/GeniusHQ/kitten/main/kitten.png" alt="icon">
  <h1 style="margin: auto">Kitten</h1>

  <p>An experimental API for making chat bots in V</p>

  [![vlang](https://img.shields.io/badge/Made%20with-V-536b8a)](https://vlang.io)
  [![discord](https://discord.com/api/guilds/1066528514179874816/embed.png)](https://discord.gg/AXPHVgTTCR)
</div>

## Project State

As presented in the title, this project is still in its initial stages. This document will describe the project closer to its design than its available content. Kitten is not production safe. Currently, the bot tends to crash by itself after a few hours. The official documentation will be more accurate for real use in your project. In order to keep Kitten's development going, the Genius team has decided to use this as the main library for the Genius bot. Anything Genius does in regards of the APIs will be feasible with Kitten, and... contributions are always welcome!

## Features

### Multi-platform Support

Kitten allows developers to simultaneously listen to multiple chat applications. Deploying to Discord+Guilded for example is as easy as just to Discord.

### Rich Abstractions

Unlike libraries such as discordgo, Kitten is provided with a variety of abstractions to empower the users' productivity without sacrificing control. We believe that chatbots can be very complex projects and therefore it's often a good idea to present more than one way of getting something done.

### API Compliance

Kitten makes its best efforts to respect API requirements and ratelimits. Developers should never get ratelimited thanks to the client-side caching mechanisms.

### Safe and Efficient

Kitten has been written in the V programming langauge. So we can expect performance that is on par with C/C++; all while enjoying safe and modern language features that come with a simple (Go-like) syntax. V binaries are compact and generally don't require the language toolchain to be installed on the host. The average bot instance will use no more than a few megabytes of memory, making this ideal for running on micro computers such as Raspberry Pi's.

## Installation

To use Kitten in your V project, simply install it with

```sh
v install "https://github.com/geniushq/kitten"
```


## Example

```v
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

```

More examples can be found [here](https://github.com/geniushq/kitten/tree/main/examples)
