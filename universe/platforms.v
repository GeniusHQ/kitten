module universe

pub enum Platform {
	unknown = -1
	any
	discord
	guilded
}

pub enum PlatformState {
	unknown = -1
	initializing
	ready
	error
}
