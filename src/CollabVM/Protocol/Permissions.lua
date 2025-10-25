local Permissions = {}
Permissions.__index = Permissions

export type Permissions = typeof(setmetatable({} :: {
    restore: boolean,
    reboot: boolean,
    ban: boolean,
    forcevote: boolean,
    mute: boolean,
    kick: boolean,
    bypassturn: boolean,
    rename: boolean,
    grabip: boolean,
    xss: boolean,
}, Permissions))

function Permissions.new(mask): Class
    local self = setmetatable({
        restore = false,
        reboot = false,
        ban = false,
        forcevote = false,
        mute = false,
        kick = false,
        bypassturn = false,
        rename = false,
        grabip = false,
        xss = false,
    }, Permissions) :: Class

    self:set(mask)

    return self
end

function Permissions:set(mask: number)
    self.restore = bit32.band(mask, 1) ~= 0
    self.reboot = bit32.band(mask, 2) ~= 0
    self.ban = bit32.band(mask, 4) ~= 0
    self.forcevote = bit32.band(mask, 8) ~= 0
    self.mute = bit32.band(mask, 16) ~= 0
    self.kick = bit32.band(mask, 32) ~= 0
    self.bypassturn = bit32.band(mask, 64) ~= 0
    self.rename = bit32.band(mask, 128) ~= 0
    self.grabip = bit32.band(mask, 256) ~= 0
    self.xss = bit32.band(mask, 512) ~= 0
end

local Rank = {
    Unregistered = 0,
    Registered = 1,
    Admin = 2,
    Moderator = 3,
}

local AdminOpcode = {
    Login = 2,
    MonitorCommand = 5,
    Restore = 8,
    Reboot = 10,
    BanUser = 12,
    ForceVote = 13,
    MuteUser = 14,
    KickUser = 15,
    EndTurn = 16,
    ClearTurns = 17,
    RenameUser = 18,
    GetIP = 19,
    BypassTurn = 20,
    ChatXSS = 21,
    ToggleTurns = 22,
    IndefiniteTurn = 23,
    HideScreen = 24,
}

return {
    Permissions = Permissions,
    Rank = Rank,
    AdminOpcode = AdminOpcode,
}