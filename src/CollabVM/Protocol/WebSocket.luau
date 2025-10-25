local HttpService = game:GetService("HttpService")

local Root = script.Parent.Parent
local Packages = Root.Packages

local Signal = require(Packages.signal)

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
    open: Signal.Signal<>,
    close: Signal.Signal<>,
    message: Signal.Signal<string>,
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

function WebSocket:send(Data: string)
    self.WebSocket:Send(Data)
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