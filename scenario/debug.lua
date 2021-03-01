--Time for the debug code.  If any (not global.) globals are written to at this point, an error will be thrown.
--eg, x = 2 will throw an error because it's not global.x or local x
setmetatable(_G, {
	__newindex = function(_, n, v)
		log("Desync warning: attempt to write to undeclared var " .. n)
		-- game.print("Attempt to write to undeclared var " .. n)
		global[n] = v;
	end,
	__index = function(_, n)
		return global[n];
	end
})