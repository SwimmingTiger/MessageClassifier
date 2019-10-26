local L = LibStub("AceLocale-3.0"):GetLocale(...)

MessageClassifierConfig = {}

local defaultConfig = {
    ["enabled"] = true,
    ["passPlayerSelf"] = true,
    ["minDupInterval"] = 0,
}


local function textFactory(parent, value, size)
    local text = parent:CreateFontString(nil, "ARTWORK")
    -- Different languages require different fonts, and 
    -- using inappropriate fonts will result in text not displaying correctly.
    -- So the choice of font needs to be localized.
    text:SetFont(STANDARD_TEXT_FONT, size)
    text:SetJustifyV("CENTER")
    text:SetJustifyH("CENTER")
    text:SetText(value)
    return text
end

local function buttonFactory(width, parent, name, description, onClick)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetHeight(25)
    button:SetWidth(width)
    button:SetText(name)
    button.tooltipText = description
    button:SetScript("OnClick", function(self)
        onClick(self)
    end)
    return button
end

local function checkboxFactory(parent, name, description, onClick)
    local checkbox = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    getglobal(checkbox:GetName() .. "Text"):SetText(name)
    checkbox.tooltip = description
    checkbox:SetScript("OnClick", function(self)
        onClick(self)
    end)
    checkbox:SetScale(1.1)
    return checkbox
end

local function editBoxFactory(parent, name, width, height, onEnter)
    local editBox = CreateFrame("EditBox", nil, parent)
    editBox.title_text = textFactory(editBox, name, 12)
    editBox.title_text:SetPoint("TOP", 0, 12)
    editBox:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 26,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    editBox:SetBackdropColor(0,0,0,1)
    editBox:SetSize(width, height)
    editBox:SetMultiLine(false)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(6)
    editBox:SetJustifyH("CENTER")
	editBox:SetJustifyV("CENTER")
    editBox:SetFontObject(GameFontNormal)
    editBox:SetScript("OnEnterPressed", function(self)
        onEnter(self)
        self:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    return editBox
end

local function sliderFactory(parent, name, title, minVal, maxVal, valStep, func, sliderWidth)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    local editBox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(valStep)
    slider.text = _G[name .. "Text"]
    slider.text:SetText(title)
    slider.textLow = _G[name .. "Low"]
    slider.textHigh = _G[name .. "High"]
    slider.textLow:SetText(floor(minVal))
    slider.textHigh:SetText(floor(maxVal))
    slider.textLow:SetTextColor(0.8,0.8,0.8)
    slider.textHigh:SetTextColor(0.8,0.8,0.8)
    if sliderWidth ~= nil then
        slider:SetWidth(sliderWidth)
    end
    slider:SetObeyStepOnDrag(true)
    editBox:SetSize(45,30)
    editBox:ClearAllPoints()
    editBox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    editBox:SetText(slider:GetValue())
    editBox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self)
        editBox:SetText(tostring(self:GetValue()))
        func(self)
    end)
    editBox:SetScript("OnTextChanged", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
        end
    end)
    editBox:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
            self:ClearFocus()
        end
    end)
    slider.editBox = editBox
    return slider
end

local function colorPickerFactory(parent, name, r, g, b, text, onClick)
    local colorPicker = CreateFrame("Button", name, parent)
    colorPicker:SetSize(15, 15)
    colorPicker.normal = colorPicker:CreateTexture(nil, "BACKGROUND")
    colorPicker.normal:SetColorTexture(1, 1, 1, 1)
    colorPicker.normal:SetPoint("TOPLEFT", -1, 1)
    colorPicker.normal:SetPoint("BOTTOMRIGHT", 1, -1)
    colorPicker.r = r
    colorPicker.g = g
    colorPicker.b = b
    colorPicker.foreground = colorPicker:CreateTexture(nil, "OVERLAY")
    colorPicker.foreground:SetColorTexture(colorPicker.r, colorPicker.g, colorPicker.b, 1)
    colorPicker.foreground:SetAllPoints()
    colorPicker:SetNormalTexture(colorPicker.normal)
    colorPicker:SetScript("OnClick", onClick)
    colorPicker.text = textFactory(colorPicker, text, 12)
    colorPicker.text:SetPoint("LEFT", 20, 0)
    
    return colorPicker
end

local function loadConfig()
    if not MessageClassifierConfig then MessageClassifierConfig = {} end

    for key, val in pairs(defaultConfig) do
        if MessageClassifierConfig[key] == nil then
            MessageClassifierConfig[key] = val
        end
    end
end

local function updateConfigPanel(configPanel)
    configPanel.enabledCheckbox:SetChecked(MessageClassifierConfig.enabled)
    configPanel.passPlayerSelfCheckbox:SetChecked(MessageClassifierConfig.passPlayerSelf)
    configPanel.minDupIntervalSlider:SetValue(MessageClassifierConfig.minDupInterval)
    configPanel.minDupIntervalSlider.editBox:SetCursorPosition(0)
end

local function createConfigPanel(parent)
    local config = CreateFrame("Frame", nil, parent)

    -- Title
    config.titleText = textFactory(config, L["CONFIG_PAGE_TITLE"], 20)
    config.titleText:SetPoint("TOPLEFT", 0, 0)
    config.titleText:SetTextColor(1, 0.9, 0, 1)
    
    -- enabled
    config.enabledCheckbox = checkboxFactory(config, L["OPTION_ENABLED"], L["OPTION_ENABLED_TOOLTIP"], function(self)
        MessageClassifier.Toggle(self:GetChecked())
    end)
    config.enabledCheckbox:SetPoint("TOPLEFT", 10, -35)

    --pass player self
    config.passPlayerSelfCheckbox = checkboxFactory(config, L["OPTION_PASS_PLAYER_SELF"], L["OPTION_PASS_PLAYER_SELF_TOOLTIP"], function(self)
        MessageClassifierConfig.passPlayerSelf = self:GetChecked()
    end)
    config.passPlayerSelfCheckbox:SetPoint("TOPLEFT", 10, -70)

    -- min dup interval
    config.minDupIntervalSlider = sliderFactory(config, "minDupInterval", L["OPTION_MIN_DUP_INTERVAL"], 0, 3600, 1, function(self)
        MessageClassifierConfig.minDupInterval = tonumber(self:GetValue())
    end, 424)
    config.minDupIntervalSlider:SetPoint("TOPLEFT", 10, -135)

    config.resetButton = buttonFactory(250, config, L["OPTION_RESET"], L["OPTION_RESET_TOOLTIP"], function(self)
        MessageClassifier.Reset()
    end)
    config.resetButton:SetPoint("TOPLEFT", 10, -180)
    
    return config
end

MessageClassifierConfigFrame = CreateFrame("Frame", "MessageClassifierConfigFrame", UIParent)
MessageClassifierConfigFrame:RegisterEvent("ADDON_LOADED")
MessageClassifierConfigFrame.name = L["CONFIG_PAGE_TITLE"]
MessageClassifierConfigFrame.default = defaultConfig
InterfaceOptions_AddCategory(MessageClassifierConfigFrame)

local scrollFrame = CreateFrame("ScrollFrame", nil, MessageClassifierConfigFrame)
scrollFrame:SetPoint('TOPLEFT', 5, -5)
scrollFrame:SetPoint('BOTTOMRIGHT', -5, 5)
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript('OnMouseWheel', function(self, direction)
    if direction == 1 then
        scrollValue = math.max(self:GetVerticalScroll() - 50, 1)
        self:SetVerticalScroll(scrollValue)
        self:GetParent().scrollBar:SetValue(scrollValue) 
    elseif direction == -1 then
        scrollValue = math.min(self:GetVerticalScroll() + 50, 250)
        self:SetVerticalScroll(scrollValue)
        self:GetParent().scrollBar:SetValue(scrollValue)
    end
end)
MessageClassifierConfigFrame.scrollFrame = scrollFrame

local scrollBar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
scrollBar:SetPoint("TOPLEFT", MessageClassifierConfigFrame, "TOPRIGHT", -20, -20) 
scrollBar:SetPoint("BOTTOMLEFT", MessageClassifierConfigFrame, "BOTTOMRIGHT", -20, 20) 
scrollBar:SetMinMaxValues(1, 250) 
scrollBar:SetValueStep(1) 
scrollBar.scrollStep = 1 
scrollBar:SetValue(0) 
scrollBar:SetWidth(16) 
scrollBar:SetScript("OnValueChanged", function (self, value)
    self:GetParent():SetVerticalScroll(value) 
end)

local scrollBackground = scrollBar:CreateTexture(nil, "BACKGROUND") 
scrollBackground:SetAllPoints(scrollBar) 
scrollBackground:SetColorTexture(0, 0, 0, 0.6) 
MessageClassifierConfigFrame.scrollBar = scrollBar

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(1, 1)
scrollFrame.content = content
scrollFrame:SetScrollChild(content)

function MessageClassifierConfigFrame:update()
    updateConfigPanel(content.panel)
end

MessageClassifierConfigFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "MessageClassifier" then
        loadConfig()

        -- Add main panel
        content.panel = createConfigPanel(content)
        content.panel:SetPoint("TOPLEFT", 10, -10)
        content.panel:SetSize(1, 1)
        
        self:update()
    end
end)
