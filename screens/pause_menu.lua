local pause_menu = {}

local config = require("game.config")
local colors = require("utils.colors")

-- Menu options
local menuOptions = {
    {text = "Continue", action = "continue"},
    {text = "Main Menu", action = "menu"},
    {text = "Exit Game", action = "exit"}
}

local selectedOption = 1
local optionHeight = 60
local optionWidth = 300

function pause_menu.init()
    selectedOption = 1
end

function pause_menu.update(dt, mouseX, mouseY)
    -- Update selection based on mouse position
    local startY = config.window.height / 2 - (#menuOptions * optionHeight) / 2
    
    for i, option in ipairs(menuOptions) do
        local optionY = startY + (i - 1) * optionHeight + 20
        local optionX = config.window.width / 2 - optionWidth / 2
        
        if mouseX >= optionX and mouseX <= optionX + optionWidth and
           mouseY >= optionY and mouseY <= optionY + optionHeight - 20 then
            selectedOption = i
        end
    end
end

function pause_menu.draw()
    -- Draw semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, config.window.width, config.window.height)
    
    -- Draw "PAUSED" title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf("PAUSED", 0, config.window.height / 2 - 150, config.window.width, "center")
    
    -- Draw menu options
    love.graphics.setFont(love.graphics.newFont(32))
    local startY = config.window.height / 2 - (#menuOptions * optionHeight) / 2
    
    for i, option in ipairs(menuOptions) do
        local optionY = startY + (i - 1) * optionHeight + 20
        local optionX = config.window.width / 2 - optionWidth / 2
        
        -- Draw selection highlight
        if i == selectedOption then
            local color = colors.getColor(math.floor(love.timer.getTime() % 5) + 1)
            love.graphics.setColor(color[1], color[2], color[3], 0.3)
            love.graphics.rectangle("fill", optionX - 10, optionY - 10, optionWidth + 20, optionHeight - 10, 10, 10)
            
            -- Draw option text with highlight color
            love.graphics.setColor(color[1], color[2], color[3], 1)
        else
            -- Draw option text in white
            love.graphics.setColor(1, 1, 1, 0.8)
        end
        
        love.graphics.printf(option.text, optionX, optionY, optionWidth, "center")
    end
    
    -- Reset font
    love.graphics.setFont(love.graphics.newFont(12))
end

function pause_menu.mousepressed(x, y, button)
    if button == 1 then
        return menuOptions[selectedOption].action
    end
    return nil
end

function pause_menu.keypressed(key)
    if key == "up" then
        selectedOption = selectedOption - 1
        if selectedOption < 1 then
            selectedOption = #menuOptions
        end
    elseif key == "down" then
        selectedOption = selectedOption + 1
        if selectedOption > #menuOptions then
            selectedOption = 1
        end
    elseif key == "return" or key == "kpenter" then
        return menuOptions[selectedOption].action
    elseif key == "escape" then
        return "continue"
    end
    return nil
end

function pause_menu.getSelectedOption()
    return selectedOption
end

return pause_menu