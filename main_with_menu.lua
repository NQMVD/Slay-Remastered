io.stdout:setvbuf("no")

local lume = require'lib.lume'
local serpent = require'lib.serpent'
local log = require'lib.log'
local utils = require'lib.utils'

local helium = require'helium'
local flux = require'lib.flux'

local menuScene = helium.scene.new(true)
local levelScene = helium.scene.new(true)
local gameScene = helium.scene.new(true)
local settingsScene = helium.scene.new(true)

--==================================================================--
--[                         MAIN FUNCTIONS                         ]--
--==================================================================--

hate.keyboard.setKeyRepeat(true)

local menu = require("main-menu.menu")({switch = function() end}, 0, 0)
menuScene:draw()
menuScene:activate()
menu:draw(0, 0, hate.graphics.getDimensions())



function hate.update(dt)
    flux.update(dt)
	menuScene:update(dt)
end

function hate.draw()
    menuScene:draw()
    menu:draw(0, 0, hate.graphics.getDimensions())
end

function hate.quit()

end

--==================================================================--
--[                         CALLBACKS                              ]--
--==================================================================--
function hate.keypressed(key, scancode, isrepeat)

end

function hate.keyreleased(key)

end

function hate.textinput(t)

end

-------------------------------------------------------------------------

function hate.mousepressed(x, y, button)

end

function hate.mousereleased(x, y, button)
end

function hate.wheelmoved(x, y)

end

function hate.mousemoved( x, y, dx, dy )
end

-------------------------------------------------------------------------

function hate.focus(f)

end

function hate.mousefocus(f)

end

function hate.resize(w, h)

end

-------------------------------------------------------------------------


