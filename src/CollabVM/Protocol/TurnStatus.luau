local User = require(script.Parent.User)

export type TurnStatus = {
	user: User.User?,
	queue: {User.User},
	turnTime: number?,
	queueTime: number?
}

return {}