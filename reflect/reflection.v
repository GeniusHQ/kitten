module reflect

import x.json2

pub interface Mappable {
mut:
	from_map(v map[string]json2.Any)
	to_map() map[string]json2.Any
}

pub fn deserialize[T](src string) !T {
	mut res := T{}

	$if res is Mappable {
		data := json2.raw_decode(src)!
		res.from_map(data.as_map())
		return res
	}

	return json2.decode[T](src)!
}
