module gateway

import x.json2

fn (mut g Gateway) handle_event(data json2.Any, event string) ! {
	match event {
		'MESSAGE_CREATED' {
			g.logger.info('new message: ${data}')
		}
		else {
			dump('unimplemented event ${event} ${data}')
		}
	}
}
