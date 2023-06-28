module rest

import x.json2

[noinit]
pub struct User {
pub mut:
	id string [required]
	// @type string [required] // Todo: use an enum
	name string [required]
	// Todo: complete this
	created_at DateString [json: 'createdAt'; required]
}

pub fn (mut u User) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'id' {
				u.id = val.str()
			}
			'name' {
				u.name = val.str()
			}
			'createdAt' {
				u.created_at = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (u &User) to_map() map[string]json2.Any {
	return {}
}
