local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")

local Root = script.Parent.Parent
local Protocol = Root.Protocol
local Packages = Root.Packages
local Types = Root.Types

local Signal = require(Packages.signal)
local msgpack = require(Packages["msgpack-luau"])
local CanvasDraw = require(Packages.CanvasDraw)
local Emittery = require(Packages.emittery)

local Guacutils = require(Protocol.Guacutils)
local WebSocket = require(Protocol.WebSocket)
local User = require(Protocol.User)
local Permissions = require(Protocol.Permissions)
local BinaryProtocol = require(Protocol.BinaryProtocol)

local Rank = Permissions.Rank
local CollabVMProtocolMessage = BinaryProtocol.CollabVMProtocolMessage.CollabVMProtocolMessageType

local CollabVMClient = {}
CollabVMClient.__index = CollabVMClient

export type Class = typeof(setmetatable({} :: {
    url: string,
    connectedToVM: boolean,
    users: {User.User},
    username: string?,
    rank: number,
    perms: Permissions.Permissions,
    internalEmitter: Emittery.Emittery,
    publicEmitter: Emittery.Emittery,
    socket: WebSocket.Class,
    unsubscribeCallbacks: {Emittery.Emittery_UnsubscribeFn},
}, CollabVMClient))

function CollabVMClient.new(url: string): Class
    local self = setmetatable({}, CollabVMClient) :: Class

    self.url = url

    self.connectedToVM = false
    self.users = {}

    self.rank = Rank.Unregistered
    self.perms = Permissions.Permissions.new(0)

    self.internalEmitter = Emittery.default.new()
    self.publicEmitter = Emittery.default.new()

    --self.editableImage = AssetService:Crea

    self.socket = WebSocket.new(url)

    self.unsubscribeCallbacks = {}

    self.socket.open:Connect(function() self:onOpen() end)
    self.socket.message:Connect(function(self, message: string) self:onMessage(message) end)
    self.socket.close:Connect(function() self.publicEmitter:emit("close") end)

    return self
end

function CollabVMClient:onOpen()
    self.internalEmitter:emit("open")
end

function CollabVMClient:onBinaryMessage(data: string)
    local success, msg: BinaryProtocol.CollabVMProtocolMessage = pcall(function()
        return msgpack.decode(data)
    end)

    if not success then
        warn("Server sent invalid binary message")
        return
    end

    if msg.type == nil then return end

    if msg.type == CollabVMProtocolMessage.rect then
        if not msg.rect or msg.rect.x == nil or msg.rect.y == nil or msg.rect.data == nil then return end
    end
end

function CollabVMClient:onMessage(message: string)
    local BinaryMessageSignature = "\xDE\x00\x02\xA4"

    if message:sub(1, 4) == BinaryMessageSignature then
        self:onBinaryMessage(message)
        return 
    end
    local success, msgArr = pcall(function()
        return Guacutils.decode(message)
    end)

    if not success then
        warn(`Server sent invalid message ({message})`)
        return
    end

    self.publicEmitter:emit("message", unpack(msgArr))

    local MessageType = msgArr[1]

    if MessageType == "nop" then
        self:send("nop")
    elseif MessageType == "list" then
        self.internalEmitter:emit("list", table.pack(table.unpack(msgpack, 1)))
        return
    elseif MessageType == "connect" then
        self.connectedToVM = msgArr[2] == "1"
        self.internalEmitter:emit("connect", self.connectedToVM)
        return
    elseif MessageType == "size" then
        return
    elseif MessageType == "chat" then
        for i = 2, #msgArr, 2 do
            self.publicEmitter:emit('chat', msgArr[i], msgArr[i + 1])
        end
        return
    elseif MessageType == "adduser" then
        for i = 2, #msgArr - 1, 2 do
            local userFound
            for _, u in ipairs(self.users) do
                if u.username == msgArr[i] then
                    userFound = u
                    break
                end
            end

            local _user
            if userFound then
                _user = userFound
                _user.rank = tonumber(msgArr[i + 1])
            else
                _user = User.new(msgArr[i], tonumber(msgArr[i + 1]) or 0)
                table.insert(self.users, _user)
            end
            self.publicEmitter:emit('adduser', _user)
        end
    elseif MessageType == "remuser" then

    elseif MessageType == "rename" then

    elseif MessageType == "turn" then

    elseif MessageType == "vote" then

    elseif MessageType == "auth" then

    elseif MessageType == "login" then

    elseif MessageType == "admin" then

    elseif MessageType == "flag" then
        for i = 1, #msgArr - 1, 2 do
            local username = msgArr[i]
            local countryCode = msgArr[i + 1]
            local user = nil
            for _, u in ipairs(self.users) do
                if u.username == username then
                    user = u
                    break
                end
            end
            
            if user then
                user.countryCode = countryCode
            end
        end
        self.publicEmitter:emit('flag')
    end
end

function CollabVMClient:send(...: string)
    local args = {...}
    local guacElements = {}
    
    for i, el in args do
        if type(el) == "string" then
            guacElements[i] = el
        else
            guacElements[i] = tostring(el)
        end
    end
    
    self.socket:send(Guacutils.encode(table.unpack(guacElements)))
end

function CollabVMClient:close()
    if self.ws then
        self.ws:close()
        self.ws = nil
    end
end

function CollabVMClient:on(eventName: string, callback: (any) -> ()): Emittery.Emittery_UnsubscribeFn
    local unsub = self.publicEmitter:on(eventName, callback)
    table.insert(self.unsubscribeCallbacks, unsub)
    return unsub
end

return CollabVMClient
