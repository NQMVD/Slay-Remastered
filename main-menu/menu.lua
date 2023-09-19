local helium = require'helium'

local buttonFac = require'main-menu.menu-button'

local buttonfont = love.graphics.newFont('main-menu/Roboto-Bold.ttf', 50, 'none')
local headerfont = love.graphics.newFont('main-menu/Roboto-Bold.ttf', 100)

local headerico = love.graphics.newImage'/main-menu/img/Main.png'
local playico = love.graphics.newImage'/main-menu/img/Play.png'
local loadico = love.graphics.newImage'/main-menu/img/Load.png'
local settingico = love.graphics.newImage'/main-menu/img/Settings.png'
local exitico = love.graphics.newImage'/main-menu/img/Exit.png'

local bwidth = 350
local bheight = 80

local playProps = {
	ico = playico,
	color = {0.415, 0.815, 0.6},
	text = 'Play',
}

local loadProps = {
	ico = loadico,
	color = {0.737, 0.517, 0.752},
	text = 'Load',
}

local settingProps = {
	ico = settingico,
	color = {0.815, 0.682, 0.333},
	text = 'Settings',
}

local exitProps = {
	ico = exitico,
	color = {0.933, 0.419, 0.419},
	text = 'Exit',
}

return helium(function(param, view)
	settingProps.onClick = param.switch
	exitProps.onClick = function() love.event.quit() end
	local playB = buttonFac(playProps, bwidth, bheight)
	local loadB = buttonFac(loadProps, bwidth, bheight)
	local settingB = buttonFac(settingProps, bwidth, bheight)
	local exitB = buttonFac(exitProps, bwidth, bheight)

	return function()
		local w,h = love.graphics.getDimensions()
		local leftOff = w - bwidth
		local topOff = h - ((bheight+20)*4)

		love.graphics.setColor(0.921, 0.921, 0.949, 1)
		love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(headerico, 55, 55)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setFont(headerfont)
		love.graphics.print('Main Menu', 155, 35)

		love.graphics.setFont(buttonfont)
		playB:draw(leftOff, topOff)
		loadB:draw(leftOff, topOff+bheight)
		settingB:draw(leftOff, topOff+(bheight*2))
		exitB:draw(leftOff, topOff+(bheight*3))
	end
end)