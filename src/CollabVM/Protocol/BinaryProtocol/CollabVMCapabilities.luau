type CollabVMCapabilities = {
    bin: boolean,
}

local CollabVMCapabilities = {}

function CollabVMCapabilities.new(): CollabVMCapabilities
    return {
        bin = false
    } :: CollabVMCapabilities
end

return CollabVMCapabilities