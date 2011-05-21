--
-- Conky Lua scripting example
--
-- Copyright (c) 2009 Brenden Matthews, all rights reserved.
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--

function components_to_colour(r, g, b)
	-- Take the RGB components r, g, b, and return an RGB integer
	return ((math.floor(r + 0.5) * 0x10000) + (math.floor(g + 0.5) * 0x100) + math.floor(b + 0.5)) % 0xffffff -- no bit shifting operator in Lua afaik
end

function colour_to_components(colour)
	-- Take the RGB components r, g, b, and return an RGB integer
	return (colour / 0x10000) % 0x100, (colour / 0x100) % 0x100, colour % 0x100
end

function conky_top_colour(value, default_colour, lower_thresh, upper_thresh)
	--[[
	This function returns a colour based on a threshold, by adding more of
	the red component and reducing the other components.  ``value'' is the
	value we're checking the thresholds against, ``default_colour'' is the
	original colour (before adjusting), and the ``lower_thresh'' and
	``upper_thresh'' parameters are the low and high values for which we
	start applying redness.
	]]
	local r, g, b = colour_to_components(default_colour)
	local colour = 0
	if value ~= nil and (value - lower_thresh) > 0 then
		if value > upper_thresh then value = upper_thresh end
		local perc = (value - lower_thresh) / (upper_thresh - lower_thresh)
		if perc > 1 then perc = 1 end
		-- add some redness, depending on where ``value'' lies within the
		-- threshhold range
		r = r + perc * (0xff - r)
		b = b - perc * b
		g = g - perc * g
	end
	colour = components_to_colour(r, g, b)

	return string.format("${color #%06x}", colour)
end

-- parses the output from top and calls the colour function
function conky_top_cpu_colour(arg)
	-- input is the top var number we want to use
	local str = conky_parse(string.format(' ${top name %i} ${top pid %i} ${top cpu %i} ${top mem %i}', tonumber(arg), tonumber(arg), tonumber(arg), tonumber(arg)))
	local cpu = tonumber(string.match(str, '(%d+%.%d+)'))
	-- tweak the last 3 parameters to your liking
	-- my machine has 4 CPUs, so an upper thresh of 25% is appropriate
	return conky_top_colour(cpu, 0xd3d3d3, 15, 25) .. str
end

function conky_top_mem_colour(arg)
	-- input is the top var number we want to use
    local str_cpu = math.floor(tonumber(conky_parse(string.format('${top_mem cpu %i}', tonumber(arg) )))+0.5)
    local str_mem = math.floor(tonumber(conky_parse(string.format('${top_mem mem %i}', tonumber(arg) )))+0.5)
	local str_namepid = conky_parse(string.format(' ${top_mem name %i} ${top_mem pid %i}', tonumber(arg), tonumber(arg) ))
    local mem1 = math.floor(conky_parse('${top_mem mem 1}'))
    print (str_namepid .. ' ' .. conky_pad(str_cpu) .. '% ' .. conky_pad(str_mem) .. '%')
	--local mem = tonumber(string.match(str, '%d+%.%d+%s+(%d+%.%d+)'))
	-- tweak the last 3 parameters to your liking
	-- my machine has ~8GiB of ram, so an upper thresh of 15% seemed appropriate
	return str_cpu
end
function conky_top_cpu_integer(arg)
	-- input is the top var number we want to use
    local str_cpu = math.floor(tonumber(conky_parse(string.format('${top cpu %i}', tonumber(arg) )))+0.5)
    local str_mem = math.floor(tonumber(conky_parse(string.format('${top mem %i}', tonumber(arg) )))+0.5)
    local str = conky_pad(str_cpu) .. '% ' .. conky_pad(str_mem) .. '%'
	return str
end

function conky_top_mem_integer(arg)
	-- input is the top var number we want to use
    local str_cpu = math.floor(tonumber(conky_parse(string.format('${top_mem cpu %i}', tonumber(arg) )))+0.5)
    local str_mem = math.floor(tonumber(conky_parse(string.format('${top_mem mem %i}', tonumber(arg) )))+0.5)
    local str = conky_pad(str_cpu) .. '% ' .. conky_pad(str_mem) .. '%'
	return str
end

function conky_pad( number )
    return string.format( '%3i' , conky_parse( number ) )
end
