local CollabVMRectMessage = require(script.Parent.CollabVMRectMessage)

local CollabVMProtocolMessageType = {
    rect = 0
}

export type CollabVMProtocolMessage = {
    type: number,
    rect: CollabVMRectMessage.CollabVMRectMessage?
}

return {
    CollabVMProtocolMessageType = CollabVMProtocolMessageType
}