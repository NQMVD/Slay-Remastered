io.stdout:setvbuf("no")

local log = require'lib.log'
local lume = require'lib.lume'
local serpent = require'lib.serpent'
local utils = require'lib.utils'

local flux = require'lib.flux'

local style = require'style'
local shaders = require'shaders'

local sliders = require'editorsliders'
local getPreset = require'assets.gridpresets'

love.keyboard.setKeyRepeat(true)
love.graphics.setDefaultFilter('nearest', 'nearest')

--==================================================================--

local showSliderPanel = false

--==================================================================--

local drawGridWireFrame = false
local draggable = true


local waterShader = love.graphics.newShader(shaders.waterShader)

local assetNames = {
    'tree','house','house_flag','tower',
    'tier1','tier2','tier3','tier4',
}
local sprites = {}
local spriteSheet = love.graphics.newImage('assets/spritesheet.png')
local spriteWidth, spriteHeight = 128, 200
sprites.tree       = love.graphics.newQuad(0, 0, spriteWidth, spriteHeight, spriteSheet)
sprites.house      = love.graphics.newQuad(spriteWidth, 0, spriteWidth, spriteHeight, spriteSheet)
sprites.house_flag = love.graphics.newQuad(spriteWidth*2, 0, spriteWidth, spriteHeight, spriteSheet)
sprites.tower      = love.graphics.newQuad(spriteWidth*3, 0, spriteWidth, spriteHeight, spriteSheet)
sprites.tier1 = love.graphics.newQuad(0, spriteHeight, spriteWidth, spriteHeight, spriteSheet)
sprites.tier2 = love.graphics.newQuad(spriteWidth*1, spriteHeight, spriteWidth, spriteHeight, spriteSheet)
sprites.tier3 = love.graphics.newQuad(spriteWidth*2, spriteHeight, spriteWidth, spriteHeight, spriteSheet)
sprites.tier4 = love.graphics.newQuad(spriteWidth*3, spriteHeight, spriteWidth, spriteHeight, spriteSheet)

--==================================================================--

-- teams
-- team 1 is player

local teams = {}
local teamNumberCounter = 1
local createTeam = function(color)
    local team = {}
    team.number = teamNumberCounter
    teamNumberCounter = teamNumberCounter + 1
    team.color = color
    team.money = 0
    team.tiles = {}
    lume.push(teams, team)
end

local getTeamColor = function(teamNumber)
    for i=1,#teams do
        local team = teams[i]
        if team.number == teamNumber then
            return team.color
        end
    end
    error('Team '..teamNumber..' does not exist')
end

--==================================================================--

local gridPosX, gridPosY = 0, 0
local tileSize = 25
local tileGrid = {}

local updateTileSizes = lume.memoize(function(ts)
    local tileVertices = {
        math.cos((-math.pi/3)*2)*ts, math.sin((-math.pi/3)*2)*ts,
        math.cos(-math.pi/3)*ts,     math.sin(-math.pi/3)*ts,
        math.cos(0)*ts,              math.sin(0)*ts,
        math.cos(math.pi/3)*ts,      math.sin(math.pi/3)*ts,
        math.cos((math.pi/3)*2)*ts,  math.sin((math.pi/3)*2)*ts,
        math.cos(math.pi)*ts,        math.sin(math.pi)*ts,
    }
    local tileWidth = (math.cos(0) * ts)-(math.cos(math.pi) * ts)
    local tileHeight = ((math.sin(math.pi/3) * ts) - (math.sin((-math.pi/3)*2) * ts)) / 2

    return tileVertices, tileWidth, tileHeight
end)
local tileVertices, tileWidth, tileHeight = 0,0,0

local tileContentEnum = {
    water = 0,
    empty = 1,
    house = 2,
    tower = 3,
    tree  = 4,
    tier1 = 5,
    tier2 = 6,
    tier3 = 7,
    tier4 = 8,
}

local genTile = function(tmp)
    local tile = {}
    tile.team = math.random(#teams)
    tile.color = getTeamColor(tile.team)
    tile.content = tmp==1 and tileContentEnum.empty or tileContentEnum.water
    return tile
end

local genTileGrid = function(preset)
    local tileGrid = {}

    for x = 1,#preset do
        tileGrid[x] = {}
        for y = 1,#preset[1] do
            local tile = genTile(preset[x][y])
            table.insert(tileGrid[x], tile)
        end
    end

    return tileGrid
end

local drawContent = function(tile)
    love.graphics.draw(spriteSheet, sprites[assetNames[tile.content]], 0, 0)
end

local drawGrid = function()
    love.graphics.push('all')
        for xindex=1,#tileGrid do
            love.graphics.translate(tileWidth*0.75, tileHeight * (xindex%2==0 and 1 or -1))
            love.graphics.push()
            for yindex=1, #tileGrid[xindex] do
                love.graphics.translate(0, tileHeight*2)
                local tile = tileGrid[xindex][yindex]
                if tile.content ~= tileContentEnum.water then
                    love.graphics.setColor(tile.color)
                    love.graphics.polygon('fill', tileVertices)

                    if tile.content ~= tileContentEnum.empty and not drawGridWireFrame then
                        love.graphics.setColor(1,1,1)
                        love.graphics.push()
                            love.graphics.translate(-tileWidth*sliders.getSliderValue('Sprite X Offset'), -tileHeight*sliders.getSliderValue('Sprite Y Offset'))
                            love.graphics.scale(0.2 * (tileSize/25))
                            drawContent(tile)
                        love.graphics.pop()
                    end
                    if drawGridWireFrame then
                        love.graphics.setColor(1,1,1)
                        love.graphics.printf((xindex..','..yindex), -tileWidth, -tileHeight/2, 100, "center")
                    end

                    love.graphics.setColor(0.1, 0.1, 0.1)
                    love.graphics.polygon('line', tileVertices)
                elseif drawGridWireFrame then
                    love.graphics.setColor(1,1,1)
                    love.graphics.polygon('line', tileVertices)
                end
            end
            love.graphics.pop()
        end
    love.graphics.pop()
end

local drawGridShadow = function()
    love.graphics.push('all')
    love.graphics.translate(tileWidth*0.1, tileHeight*0.35)
        for xindex=1,#tileGrid do
            love.graphics.translate(tileWidth*0.75, tileHeight * (xindex%2==0 and 1 or -1))
            love.graphics.push()
            for yindex=1, #tileGrid[xindex] do
                love.graphics.translate(0, tileHeight*2)
                if tileGrid[xindex][yindex].content ~= tileContentEnum.water then
                    love.graphics.setColor(0, 0, 0, 0.9)
                    love.graphics.polygon('fill', tileVertices)
                end
            end
            love.graphics.pop()
        end
    love.graphics.pop()
end

--[[

    -----X-XX---------      |       -----------------XXX-------    
    -----XXXX---------      |       ---------------XXXX--------    
    ------XXX---------      |       ---------------XXXXX-------    
    ----XXXX----------      |       -----XX--------XXXXX-------    
    ----XXXX----------      |       ---XXXX----X-X-XX-X--------    
    ---XXXX-----------      |       XX-XXXX---XXXXXX-----X--XOX 
    ---XXXX-----------      |       -XXXXXXX-X-XXXXXX---XX---XX
    ------X-----------      |       XXXXX---X-XXXXXXXX-XXX---X-
    -------X----------      |       XXX-------X-XXXXXXXXXXXX-X-
    ------X-------XXX-      |       -------------XXXXXXXXXXXX--  ^
    -----X-XX-----XXXX      |       -------------XXXXX--XXXXX--  y, grid[][]
    ----XXXX------XXX-      |       ------------X-XXXXXXXX-----  v
    -----XXXX--X--XXXX      |       --------------XX--X-X------
    ----XXXXXXX---XXX-      |       --------------XX----XX-----
    -----XXXXXXXXXXXXX      |       ---------XXXXXXXX---X------
    -XXXXXXXXXXXXXXX--      |       ---------XXXXXXXX----------
    -XXXX-XXXXXX--XX--      |       ---------XXXXXX------------
    XXXX---XXXXX------      |       ----------X-X-X------------
    XXXXX---XX-XX-----
    X-XX---XXX-X------                    < x, grid[] >
    ------XXXXXXXXX---
    -----XXXXXXX-X----   ^
    --------XXX-------   x, grid[]
    --------XXX-------   v
    -----X---XX-------      
    -----OXXX---------   < y, grid[][] >
    -----XX-----------


]]
local getNeighbourTiles = function(x, y)
    local directions = {
        'top', 'topright', 'bottomright', 'bottom', 'bottomleft', 'topleft'
    }
    local neighbours = {}

    neighbours.top         = tileGrid[x][y-1]
    neighbours.topright    = tileGrid[x-1][y]
    neighbours.bottomright = tileGrid[x-1][y+1]
    neighbours.bottom      = tileGrid[x][y+1]
    neighbours.bottomleft  = tileGrid[x-1][y]
    neighbours.topleft     = tileGrid[x-1][y-1]

    return neighbours
end

local processGrid = function()
    for y=1, #tileGrid[1] do
        for x=1, #tileGrid do
            -- io.write(tileGrid[x][y].content == tileContentEnum.empty and 'X' or '-')
        end
        -- print()
    end
end

--==================================================================--
--[                         MAIN FUNCTIONS                         ]--
--==================================================================--

function love.load(args, unfiltered)
    if lume.find(args, '--debuglog') then
        log.level = 'debug'
    end

    love.graphics.setBackgroundColor(style.gui.background)
    love.graphics.setLineWidth(1)
    love.graphics.setLineStyle('smooth')
    love.graphics.setPointSize(1)
    love.graphics.setBlendMode('alpha')
    love.graphics.setFont(love.graphics.newFont(12))

    setup()
end

function setup()
    log.debug'Original Table Layout'
    for index, row in ipairs(tileGrid) do
        for jndex, tile in ipairs(row) do
            io.write(tile.content == tileContentEnum.empty and 'X' or '-')
        end
        print()
    end
    log.debug()
    log.debug()
    log.debug'Actual Layout'
    for y=1, #tileGrid[1] do
        for x=1, #tileGrid do
            io.write(tileGrid[x][y].content == tileContentEnum.empty and 'X' or '-')
        end
        print()
    end

    sliders.createSlider('Sprite X Offset', -2, 2, 0.25)
    sliders.createSlider('Sprite Y Offset', -2, 2, 1)

    createTeam(style.vibrant.orange)
    createTeam(style.vibrant.purple)

    tileVertices, tileWidth, tileHeight = updateTileSizes(tileSize)
    tileGrid = genTileGrid(getPreset(1))
end

function love.update(dt)
    waterShader:send("time", love.timer.getTime())
    -- flux.update(dt)
    draggable = not sliders.updateSliders(showSliderPanel)
end

function love.draw()
    love.graphics.setShader(waterShader)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
    love.graphics.setShader()

    love.graphics.push('all')
        love.graphics.translate(gridPosX, gridPosY)
        drawGridShadow()
        drawGrid()
    love.graphics.pop()

    love.graphics.push('all')
        sliders.drawSliders(showSliderPanel)
    love.graphics.pop()
end

function love.quit()
    if showSliderPanel then
        sliders.dumpSliderValues()
    end
end

--==================================================================--
--[                         CALLBACKS                              ]--
--==================================================================--
function love.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'tab' then
        showSliderPanel = not showSliderPanel
    end
    if key == 'space' then
        drawGridWireFrame = not drawGridWireFrame
    end
end

function love.keyreleased(key)

end

function love.textinput(t)

end

-------------------------------------------------------------------------

function love.mousepressed(x, y, button)

end

function love.mousereleased(x, y, button)

end

function love.wheelmoved(x, y)
    tileSize = lume.clamp(tileSize + y*2, 10, 100)
    if tileSize > 10 and tileSize < 100 then
        tileVertices, tileWidth, tileHeight = updateTileSizes(tileSize)
        gridPosX = gridPosX - (tileSize*0.8*y)
        gridPosY = gridPosY - (tileSize*0.8*y)
    end
end

function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(1) and draggable then
        gridPosX = gridPosX + dx
        gridPosY = gridPosY + dy
    end
end

-------------------------------------------------------------------------

function love.focus(f)

end

function love.mousefocus(f)

end

function love.resize(w, h)

end

-------------------------------------------------------------------------


