module rest

import x.json2

[noinit]
struct User {
	// Todo: complete this
}

pub fn (mut u User) from_map(data map[string]json2.Any) {
}

pub fn (mut u User) to_map() map[string]json2.Any {
	return {}
}
