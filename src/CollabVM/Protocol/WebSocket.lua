local HttpService = game:GetService("HttpService")

local Root = script.Parent.Parent
local Packages = Root.Packages
local Types = Root.Types

local Signal = require(Packages.signal)
local SignalTypes = require(Types.Signal)

local State = {
    CONNECTING = 0,
    OPEN = 1,
    CLOSING = 2,
    CLOSED = 3,
}

local WebSocket = {}
WebSocket.__index = WebSocket

export type Class = typeof(setmetatable({} :: {
    WebSocket: WebStreamClient,
    open: SignalTypes.Signal<>,
    close: SignalTypes.Signal<>,
    message: SignalTypes.Signal<buffer>,
    readyState: number
}, WebSocket))

function WebSocket.new(url: string): Class
    local self = setmetatable({}, WebSocket) :: Class

    self.WebSocket = HttpService:CreateWebStreamClient(
        Enum.WebStreamClientType.WebSocket,
        {
            ["Url"] = url,
            ["Headers"] = {
                ["sec-websocket-protocol"] = "guacamole",
			    ["Origin"] = "https://computernewb.com"
            }
        }
    )

    self.readyState = State.CONNECTING

    self.open = Signal.new()
    self.close = Signal.new()
    self.message = Signal.new()

    self.WebSocket.Closed:Connect(function()
        self.readyState = State.CLOSED
        self.close:Fire()
    end)

    self.WebSocket.Opened:Connect(function() 
        self.readyState = State.OPEN
        self.open:Fire()
    end)

    self.WebSocket.MessageReceived:Connect(function(Message: string)
        
        self.message:Fire(Message)
    end)

    return self
end

function WebSocket:Destroy()
    self:close()
    self.WebSocket:Destroy()

    self.open:Destroy()
    self.close:Destroy()
    self.message:Destroy()

    table.clear(self)
    setmetatable(self, nil)
end

function WebSocket:close()
    self.WebSocket:Close() 
end

WebSocket.WebSocketState = State

return WebSocket