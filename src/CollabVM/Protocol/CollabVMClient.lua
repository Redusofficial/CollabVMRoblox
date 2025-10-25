local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")

local Root = script.Parent.Parent
local Protocol = Root.Protocol
local Packages = Root.Packages
local Types = Root.Types

local Signal = require(Packages.signal)
local msgpack = require(Packages["msgpack-luau"])
local CanvasDraw = require(Packages.CanvasDraw)

local WebSocket = require(Protocol.WebSocket)

local CollabVMClient = {}
CollabVMClient.__index = CollabVMClient

export type Class = typeof(setmetatable({} :: {
    url: string,
    internalEmitter: Signal.Signal<string>,
    publicEmitter: Signal.Signal<any>,
    socket: WebSocket.Class
}, CollabVMClient))

function CollabVMClient.new(url: string): Class
    local self = setmetatable({}, CollabVMClient) :: Class

    self.url = url

    self.internalEmitter = Signal.new()
    self.publicEmitter = Signal.new()

    --self.editableImage = AssetService:Crea

    self.onOpen = Signal.new()
    self.onClose = Signal.new()
    self.onError = Signal.new()
    self.onMessage = Signal.new()
    self.onFrame = Signal.new()

    self.socket = WebSocket.new(url)

    self.socket.open:Connect(function() self:onOpen() end)

    self.socket.message:Connect(function(self, message: string) self:onMessage(message) end)

    self.socket.close:Connect(function() self.publicEmitter:Fire("close") end)

    return self
end

function CollabVMClient:onOpen()
    self.internalEmitter:Fire()
end

function CollabVMClient:onMessage(message: string)
    local data = HttpService:JSONDecode(message)
    self.publicEmitter:Fire(data)
end

function CollabVMClient:send(tbl)
    if not self.ws then error("WebSocket not connected") end
    local str = HttpService:JSONEncode(tbl)
    self.ws:send(str)
end

function CollabVMClient:close()
    if self.ws then
        self.ws:close()
        self.ws = nil
    end
end

return CollabVMClient
