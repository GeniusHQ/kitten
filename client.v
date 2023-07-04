module kitten

import os
import universe
import discord

[heap]
pub struct Client {
pub:
	stop            chan int
pub mut:
	platforms       map[universe.Platform]universe.PlatformState
}

pub fn new_client() &Client {
	return &Client{
		stop: chan int{cap: 1}
		platforms: map[universe.Platform]universe.PlatformState{}
	}
}

pub fn (mut client Client) start() ! {
	for platform, state in client.platforms {
		if state != .initializing {
			continue
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
