module reflect

import x.json2

pub interface Mappable {
	to_map() map[string]json2.Any
mut:
	from_map(v map[string]json2.Any)
}

pub fn deserialize[T](src string) !T {
	mut res := T{}

	$if T is Mappable {
		data := json2.raw_decode(src)!
		res.from_map(data.as_map())
		return res
	}

	return json2.decode[T](src)!
}

pub fn serialize[T](obj T) string {
	$if T is Mappable {
		return json2.encode[map[string]json2.Any](Mappable(obj).to_map())
	}

	return json2.encode[T](obj)
}

pub fn from_map[T](data map[string]json2.Any) T {
	mut res := T{}

	res.from_map(data)

	return res
}

pub fn to_map[T](obj T) map[string]json2.Any {
	return obj.to_map()
}
