module universe

pub enum Platform as int {
	unknown = -1
	any
	discord
	guilded
}

pub enum PlatformState as int {
	unknown = -1
	initializing
	ready
	error
}