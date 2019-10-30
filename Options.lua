local ADDON_NAME = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

MessageClassifierConfig = {}

local defaultConfig = {
    ["enabled"] = true,
    ["minDupInterval"] = 0,
    ["classificationRules"] = {
        --[[
        -- Fields and values:
        {
            expressions = {
                field: "author",
                       "channel"
                       "msg"

                operator: "equal"
                          "not equal"
                          "contain"
                          "not contain"
                          "match"
                          "not match"
                          "unconditional"

                value: <string>
                       <regular expression>
                       Example: "molten"
                                " AA "
                                "15g"
                                "%bAA%b"
                                "%d+g%b"
                
                caseSensitive: true
                               false
                               Default: false
            }

            class: <string>,
                    Available variables: {author}
                                         {channel},
                    Example: "RAID"
                             "Sell"
                             "Quest"
                             "The Molten Core"
                             "By Author/{author}"
                             "By Channel/{channel}"
            
            hideFromChatWindow: true
                                false
                                Default: false
        }]]
        {
            expressions = {
                { operator = "unconditional" },
            },
            class = L["BROWSER_CLASSIFIED_BY_AUTHOR"]:format("{author}")
        },
        {
            expressions = {
                { operator = "unconditional" },
            },
            class = L["BROWSER_CLASSIFIED_BY_CHANNEL"]:format("{channel}")
        },
        {
            expressions = {
                { operator = "unconditional" },
            },
            class = L["BROWSER_CLASSIFIED_ALL_MESSAGES"]
        },
        {
            expressions = {
                {
                    operator = "contain",
                    field = "msg",
                    value = "AA",
                },
            },
            class = "AA/{author}"
        },
        {
            expressions = {
                {
                    operator = "contain",
                    field = "msg",
                    value = "丝绸",
                },
            },
            class = "收布/{author}"
        },
        {
            expressions = {
                {
                    operator = "contain",
                    field = "msg",
                    value = "魔纹",
                },
            },
            class = "收布/{author}"
        },
        {
            expressions = {
                {
                    operator = "contain",
                    field = "msg",
                    value = "厚皮",
                },
            },
            class = "收皮/{author}"
        },
        {
            expressions = {
                {
                    operator = "contain",
                    field = "msg",
                    value = "黑上",
                },
            },
            class = "副本/黑上/{author}"
        },
    }
}

MessageClassifierConfigFrame = CreateFrame("Frame", "MessageClassifierConfigFrame", UIParent)
MessageClassifierConfigFrame:RegisterEvent("ADDON_LOADED")

function MessageClassifierConfigFrame:loadConfig()
    if not MessageClassifierConfig then MessageClassifierConfig = {} end

    for key, val in pairs(defaultConfig) do
        if MessageClassifierConfig[key] == nil then
            MessageClassifierConfig[key] = val
        end
    end

    MessageClassifierConfig.classificationRules = defaultConfig.classificationRules
end

MessageClassifierConfigFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        self:loadConfig()
    end
    self:UnregisterEvent("ADDON_LOADED")
end)

MessageClassifierConfigFrame.configTable = {
    type = "group",
    name = L["CONFIG_PAGE_TITLE"],
    args = {
        enabled = {
            order = 1,
            type = "toggle",
            width = "full",
            name = L["OPTION_ENABLED"], 
            desc = L["OPTION_ENABLED_TOOLTIP"],
            get = function(info)
                return MessageClassifierConfig.enabled
            end,
            set = function(info, val)
                MessageClassifier.Toggle(val)
            end
        },
        minDupInterval = {
            order = 2,
            type = "range",
            width = 3,
            name = L["OPTION_MIN_DUP_INTERVAL"],
            min = 0,
            max = 86400,
            softMin = 0,
            softMax = 3600,
            bigStep = 10,
            get = function(info)
                return MessageClassifierConfig.minDupInterval
            end,
            set = function(info, val)
                MessageClassifierConfig.minDupInterval = val
            end
        },
        reset = {
            order = 3,
            type = "execute",
            name = L["OPTION_RESET"],
            desc = L["OPTION_RESET_TOOLTIP"],
            func = function(info)
                MessageClassifier.Reset()
            end
        },
    }
}
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDON_NAME, MessageClassifierConfigFrame.configTable)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, L["CONFIG_PAGE_TITLE"])
