module discord

[heap]
pub struct Gateway {
	token   string [required]
	intents int    [required]
}