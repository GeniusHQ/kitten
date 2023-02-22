module logger

import log

[heap; noinit]
pub struct Logger {
mut:
	level log.Level
}

pub fn new_logger() &Logger {
	logger := Logger{}

	return &logger
}

pub fn (mut l Logger) fatal(s string) {
	eprintln(s)
	exit(0)
}

pub fn (mut l Logger) error(s string) {
	eprintln(s)
}

pub fn (mut l Logger) warn(s string) {
	println(s)
}

pub fn (mut l Logger) info(s string) {
	println(s)
}

pub fn (mut l Logger) debug(s string) {
	// println(s)
}

pub fn (mut l Logger) set_level(level log.Level) {
	l.level = level
}
