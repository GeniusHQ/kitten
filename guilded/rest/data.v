module rest

import x.json2
import reflect

type UUID = string
type DateString = string

[noinit]
pub struct Channel {
pub mut:
	id    UUID   [required]
	@type string [required] // Todo: maybe use an enum
	// Todo: add topic
	created_at string [json: 'createdAt'; required]
	created_by UUID   [json: 'createdBy'; required]
	// Todo: add updatedAt
	server UUID [json: 'serverId'; required]
	// Todo: add parentId
	// Todo: add categoryId
	group UUID [json: 'groupId'; required]
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
