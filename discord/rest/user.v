module rest

import x.json2

[noinit]
pub struct User {
pub mut:
	id string
	// Todo: complete this
}

pub fn (mut u User) from_map(data map[string]json2.Any) {
	for key, val in data {
		match key {
			'id' {
				u.id = val.str()
			}
			else {
				dump('unimplemented ${key}')
			}
		}
	}
}

pub fn (mut u User) to_map() map[string]json2.Any {
	return {}
}
