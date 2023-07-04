module reflect

import hlib.json
import x.json2

pub interface Mappable {
	to_json() json.Value
mut:
	from_json(v json.Value)!
}

pub fn deserialize_json[T](src string) !T {
	$if T is Mappable {
		mut res := T{}

		res.from_json(json.decode(src)!)!

		return res
	}

	return json2.decode[T](src)!
}

pub fn serialize[T](obj T) string {
	$if T is Mappable {
		return json.encode(Mappable(obj).to_json())
	}

	return json2.encode[T](obj)
}
