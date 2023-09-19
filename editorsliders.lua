local lume = require 'lib.lume'
local sliders = {}
local sliderWidth, sliderHeight = 200, 30

local sliderList = {}
sliders.createSlider = function(name, min, max, default)
    local slider = {}
    slider.name = name
    slider.min = min
    slider.max = max
    slider.default = default
    slider.value = default
    lume.push(sliderList, slider)
end

sliders.getSliderValue = function(name)
    for i=1,#sliderList do
        local slider = sliderList[i]
        if slider.name == name then
            return slider.value
        end
    end
    error('Slider '..name..' does not exist')
end

-- returns true if mouse is over slider panel
sliders.updateSliders = function(active)
    if not active then return false end
    local mx,my = love.mouse.getPosition()
    if mx < sliderWidth*1.2 and my < sliderHeight*#sliderList+sliderHeight*2 then
        for i=1,#sliderList do
            local slider = sliderList[i]
            if my > sliderHeight*i+sliderHeight*0.5 and my < sliderHeight*(i+1)+sliderHeight*0.5 then
                if love.mouse.isDown(1) then
                    slider.value = lume.clamp(lume.mapvalue(mx, 10, 10+sliderWidth, slider.min, slider.max), slider.min, slider.max)
                elseif love.mouse.isDown(2) then
                    slider.value = slider.default
                end
            end
        end
        return true
    end
    return false
end

sliders.drawSliders = function(active)
    if not active then return end
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle('fill', 0, 0, sliderWidth*1.2, sliderHeight*#sliderList+sliderHeight*1.5)
    for i=1,#sliderList do
        local slider = sliderList[i]
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(slider.name, 10, sliderHeight*i)
        love.graphics.printf((slider.value), 10+sliderWidth/2, sliderHeight*i, 100, 'right')
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle('fill', 10, sliderHeight*i+sliderHeight*0.5, sliderWidth, sliderHeight*0.5, 5)
        if lume.mapvalue(slider.value, slider.min, slider.max, 0, sliderWidth) > 1 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle('fill', 10, sliderHeight*i+sliderHeight*0.5, lume.mapvalue(slider.value, slider.min, slider.max, 1, sliderWidth), sliderHeight*0.5, 5)
        end
    end
end

sliders.dumpSliderValues = function()
    print'Dumping slider values:'
    for i=1,#sliderList do
        local slider = sliderList[i]
        print(slider.name..': '..slider.value)
    end
end

return sliders