local style = {}

style.gui = {
    background = {0.14, 0.14, 0.14},
}

style.pastel = {
    green  = {0.756863, 0.941176, 0.698039},
    purple = {0.839216, 0.698039, 0.941176},
    pink   = {1.000000, 0.788235, 0.870588},
    orange = {0.992157, 0.850980, 0.486275},
    yellow = {0.984314, 0.992157, 0.666667},
    blue   = {0.698039, 0.894118, 0.941176},
}

style.vibrant = {
    blue = {0.474510, 0.670588, 1.000000},
    green = {0.474510, 1.000000, 0.670588},
    purple = {0.670588, 0.474510, 1.000000},
    orange = {0.996078, 0.666667, 0.474510},
    yellow = {0.666667, 0.996078, 0.474510},
    pink = {0.996078, 0.470588, 0.670588},
}

style.random = function(type)
    local arr = {}
    for k,v in pairs(style[type]) do
        table.insert(arr, v)
    end
    return arr[math.random(1, #arr)]
end

return style