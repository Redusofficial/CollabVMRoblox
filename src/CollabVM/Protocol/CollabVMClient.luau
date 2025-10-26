local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")

local Root = script.Parent.Parent
local Protocol = Root.Protocol
local Packages = Root.Packages

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
    self.socket.message:Connect(function(message: string) self:onMessage(message) end)
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

    self.publicEmitter:emit("message", msgArr)

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
            self.publicEmitter:emit("chat", {msgArr[i], msgArr[i + 1]})
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
                _user = User.new(msgArr[i + 1], tonumber(msgArr[i]) or 0)
                table.insert(self.users, _user)
            end
            self.publicEmitter:emit("adduser", _user)
        end
        return
    elseif MessageType == "remuser" then
        for i = 3, #msgArr do
            local username = msgArr[i]
            local userIndex = nil
            local userToRemove = nil
            for index, u in self.users do
                if u.username == username then
                    userIndex = index
                    userToRemove = u
                    break
                end
            end

            if userToRemove ~= nil then
                table.remove(self.users, userIndex)
                self.publicEmitter:emit('remuser', userToRemove)
            end
        end
        return
    elseif MessageType == "rename" then

    elseif MessageType == "turn" then
        for _, user in self.users do
            user.turn = -1
        end

        local queuedUsers = tonumber(msgArr[3]) or 0
        if queuedUsers == 0 then
            self.publicEmitter:emit('turn', {
                user = nil,
                queue = {},
                turnTime = nil,
                queueTime = nil
            })
            return
        end

        local currentTurn = nil
        for _, user in ipairs(self.users) do
            if user.username == msgArr[4] then
                currentTurn = user
                break
            end
        end
        if currentTurn then
            currentTurn.turn = 0
        end

        local queue = {}
        if queuedUsers > 1 then
            for i = 1, queuedUsers - 1 do
                local user = nil
                for _, u in ipairs(self.users) do
                    if u.username == msgArr[i + 4] then
                        user = u
                        break
                    end
                end
                if user then
                    table.insert(queue, user)
                    user.turn = i
                end
            end
        end

        local turnTime = nil
        if currentTurn and currentTurn.username == self.username then
            turnTime = tonumber(msgArr[2])
        end

        local queueTime = nil
        local inQueue = false
        for _, user in ipairs(queue) do
            if user.username == self.username then
                inQueue = true
                break
            end
        end

        if inQueue then
            queueTime = tonumber(msgArr[#msgArr])
        end

        self.publicEmitter:emit('turn', {
            user = currentTurn,
            queue = queue,
            turnTime = turnTime,
            queueTime = queueTime
        })

        return
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
        self.publicEmitter:emit("flag")
    end
    return
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
