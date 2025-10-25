local Root = script.Parent
local Rank = require(Root.Permissions).Rank

local User = {}
User.__index = User

export type User = typeof(setmetatable({} :: {
    username: string,
    rank: number,
    turn: number,
    countryCode: string?,
}, User))

function User.new(username: string, rank: number): User
    local self = setmetatable({}, User) :: User

    self.username = username
    self.rank = rank or Rank.Unregistered
    self.turn = -1

    self.countryCode = nil

    return self
end

return User