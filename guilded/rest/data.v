module rest

import x.json2
import reflect

type UUID = string

[noinit]
pub struct Channel {
pub mut:
	id UUID [required]
	@type string [required] // Todo: maybe use an enum
	// Todo: add topic
	created_at string [required; json: 'createdAt']
	created_by UUID   [required; json: 'createdBy']
	// Todo: add updatedAt
	server UUID [required; json: 'serverId']
	// Todo: add parentId
	// Todo: add categoryId
	group UUID [required; json: 'groupId']
	// Todo: add isPublic
	// Todo: add archivedBy
	// Todo: add archivedAt
}

pub fn (mut c Channel) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'id' {
				c.id = val.str()
			}
			'type' {
				c.@type = val.str()
			}
			'createdAt' {
				c.created_at = val.str()
			}
			'createdBy' {
				c.created_by = val.str()
			}
			'serverId' {
				c.server = val.str()
			}
			'groupId' {
				c.group = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (mut c Channel) to_map() map[string]json2.Any {
	return {}
}

[noinit]
pub struct ChannelResponse {
pub mut:
	channel Channel [required]
}

pub fn (mut c ChannelResponse) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'channel' {
				c.channel = reflect.from_map[Channel](val.as_map())
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (c &ChannelResponse) to_map() map[string]json2.Any {
	return {}
}
