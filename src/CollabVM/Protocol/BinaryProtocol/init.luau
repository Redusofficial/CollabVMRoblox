local CollabVMProtocolMessage = require(script.CollabVMProtocolMessage)
local CollabVMRectMessage = require(script.CollabVMRectMessage)
local CollabVMCapabilities = require(script.CollabVMCapabilities)

export type CollabVMProtocolMessage = CollabVMProtocolMessage.CollabVMProtocolMessage
export type CollabVMRectMessage = CollabVMRectMessage.CollabVMRectMessage

return {
    CollabVMProtocolMessage = CollabVMProtocolMessage,
    CollabVMRectMessage = CollabVMRectMessage,
    CollabVMCapabilities = CollabVMCapabilities
}