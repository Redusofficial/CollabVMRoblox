function decode(str: string): {string}
    local pos = 0
    local sections = {}

    while true do
        local len_end = string.find(str, '%.', pos + 1, true)

        if not len_end then
            break
        end

        local len_str = string.sub(str, pos + 1, len_end - 1)
        
        local section_len = tonumber(len_str)
        
        if not section_len or section_len < 0 then
            return {}
        end

        local end_pos = len_end + section_len

        if end_pos > #str then
            return {}
        end

        local section_data = string.sub(str, len_end + 1, end_pos)

        table.insert(sections, section_data)

        pos = end_pos
        local sep = string.sub(str, pos + 1, pos + 1)

        if sep == ',' then
            pos = pos + 1
            continue
        elseif sep == ';' then
            break
        else
            return {}
        end
    end

    return sections
end

function encode(stringArray: {string}): string
	local command: string = ""

	for i, current in ipairs(stringArray) do
		local currentString: string = current
		local length: number = #currentString
		command = command .. length .. "." .. currentString

		if i < #stringArray then
			command = command .. ","
		else
			command = command .. ";"
		end
	end

	return command
end

return {
    decode = decode,
    encode = encode
}
