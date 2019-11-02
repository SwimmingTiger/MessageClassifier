local ADDON_NAME = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

MessageClassifierConfig = {}

local defaultConfig = {
    ["enabled"] = true,
    ["minDupInterval"] = 0,
    ["classificationRules"] = {},
    ["enabledDefaultRules"] = {},
}

MessageClassifierConfigFrame = CreateFrame("Frame", "MessageClassifierConfigFrame", UIParent)

MessageClassifierDefaultRules = {
    --[[
    -- Fields and values:
    {
        logic = "and"
                "or"
                Default: "or"
        expressions = {
            field: "author",
                   "channel"
                   "content"

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
        
        enabled: true
                 false
                 Default: true
    }]]
    {
        id = 1,
        expressions = {
            { operator = "unconditional" },
        },
        class = L["BROWSER_CLASSIFIED_BY_AUTHOR"]:format("{author}")
    },
    {
        id = 2,
        expressions = {
            { operator = "unconditional" },
        },
        class = L["BROWSER_CLASSIFIED_BY_CHANNEL"]:format("{channel}")
    },
    {
        id = 3,
        expressions = {
            { operator = "unconditional" },
        },
        class = L["BROWSER_CLASSIFIED_ALL_MESSAGES"]
    },
    {
        id = 4,
        expressions = {
            {
                operator = "contain",
                field = "content",
                value = "AA",
            },
        },
        class = "AA/{author}"
    },
    {
        id = 5,
        expressions = {
            {
                operator = "contain",
                field = "content",
                value = "丝绸",
            },
            {
                operator = "contain",
                field = "content",
                value = "魔纹",
            },
        },
        class = "收布/{author}"
    },
    {
        id = 7,
        expressions = {
            {
                operator = "contain",
                field = "content",
                value = "厚皮",
            },
        },
        class = "收皮/{author}"
    },
    {
        id = 8,
        expressions = {
            {
                operator = "contain",
                field = "content",
                value = "黑上",
            },
        },
        class = "副本/黑石塔上层/{author}"
    },
    {
        id = 9,
        logic = "and",
        expressions = {
            {
                operator = "contain",
                field = "content",
                value = "黑石塔",
            },
            {
                operator = "contain",
                field = "content",
                value = "上层",
            },
        },
        class = "副本/黑石塔上层/{author}"
    },
}

local classPathLocales = {
    ["{author}"] = string.format("{%s}", L["author"]),
    ["{channel}"] = string.format("{%s}", L["channel"]),
}

local function localizeClassPath(class)
    for k,v in pairs(classPathLocales) do
        class = class:gsub(k, v)
    end
    return class
end

local function localizeClassPathWithColor(class)
    class = class:gsub('/', '|cffdb800a/|r')
    for k,v in pairs(classPathLocales) do
        class = class:gsub(k, string.format("|cffc586c0%s|r", v))
    end
    return class
end

local function delocalizeClassPath(class)
    for k,v in pairs(classPathLocales) do
        class = class:gsub(v, k)
    end
    return class
end

local function ruleToText(ruleSet)
    local text = string.format("%s: %s", L["OPTION_CLASS"], localizeClassPathWithColor(ruleSet.class))
    if #ruleSet.expressions > 1 then
        local logicOr = ruleSet.logic ~= "and"
        text = text..string.format("\n%s (|cffc586c0%s|r):", L["OPTION_ACHIEVE_CONDITIONS"], logicOr and L["OPTION_RULE_LOGIC_OR"] or L["OPTION_RULE_LOGIC_AND"])
    else
        text = text..string.format("\n%s:", L["OPTION_ACHIEVE_CONDITIONS"])
    end
    for _, rule in ipairs(ruleSet.expressions) do
        if rule.operator == "unconditional" then
            text = text..string.format("\n|cff569cd6%s|r", L["unconditional"])
            break
        end
        text = text..string.format("\n|cffdcdcaa%s|r |cff569cd6%s|r |cffce9178%s|r", L[rule.field], L[rule.operator], rule.value)
    end
    return text
end

function MessageClassifierConfigFrame:loadConfig()
    if not MessageClassifierConfig then MessageClassifierConfig = {} end

    for key, val in pairs(defaultConfig) do
        if MessageClassifierConfig[key] == nil then
            MessageClassifierConfig[key] = val
        end
    end

    self.configTable = {
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
            openBrowser = {
                order = 4,
                type = "execute",
                name = L["OPTION_OPEN_MESSAGE_BROWSER"],
                func = function(info)
                    MessageClassifierBrowser:Show()
                end
            },
            ruleSetsTitle = {
                order = 5,
                type = "header",
                name = L["OPTION_RULE_SETS_TITLE"],
            },
            ruleSets = {
                order = 10,
                type = "group",
                inline = true,
                name = L["OPTION_RULE_SETS"],
                args = {
                    addRule = {
                        order = 0,
                        type = "execute",
                        name = L["OPTION_ADD_RULE_SET"],
                        func = function(info)
                        end
                    },
                },
            },
            defaultRuleSets = {
                order = 20,
                type = "group",
                inline = true,
                name = L["OPTION_DEFAULT_RULE_SETS"],
                args = {},
            }
        }
    }

    self.ruleSetsIndex = 0

    for k,v in pairs(MessageClassifierConfig.classificationRules) do
        self:addRuleSet(self.configTable.args.ruleSets, k, v)
    end

    for k,v in pairs(MessageClassifierDefaultRules) do
        self:addDefaultRuleSet(self.configTable.args.defaultRuleSets, k, v)
    end


    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(ADDON_NAME, self.configTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME, L["CONFIG_PAGE_TITLE"])
end

function MessageClassifierConfigFrame:resetRules()
    MessageClassifierConfig.classificationRules = {}

    self.configTable.args.ruleSets.args = {}
    for k,v in pairs(MessageClassifierConfig.classificationRules) do
        self:addRuleSet(self.configTable.args.ruleSets, k, v)
    end

    self.configTable.args.defaultRuleSets.args = {}
    for k,v in pairs(MessageClassifierDefaultRules) do
        self:addDefaultRuleSet(self.configTable.args.defaultRuleSets, k, v)
    end
end

function MessageClassifierConfigFrame:addRuleSet(group, order, ruleSet)
    self.ruleSetsIndex = self.ruleSetsIndex + 1
    local option = {
        type = "group",
        inline = true,
        order = order,
        name = "",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = L["OPTION_ENABLE"],
                width = 0.5,
                get = function(info)
                    return ruleSet.enabled ~= false
                end,
                set = function(info, val)
                    ruleSet.enabled = val
                    MessageClassifierBrowser:updateAllMessages()
                end,
            },
            hideFromChatWindow = {
                order = 2,
                type = "toggle",
                name = L["OPTION_HIDE_FROM_CHAT_WINDOW"],
                get = function(info)
                    return ruleSet.hideFromChatWindow == true
                end,
                set = function(info, val)
                    ruleSet.hideFromChatWindow = val
                    MessageClassifierBrowser:updateAllMessages()
                end,
            },
            editRuleSet = {
                order = 3,
                type = "execute",
                name = L["OPTION_EDIT_RULE_SET"],
                width = 0.5,
                func = function(info)
                end
            },
            removeRuleSet = {
                order = 4,
                type = "execute",
                name = L["OPTION_REMOVE_RULE_SET"],
                width = 0.5,
                func = function(info)
                end
            },
            conditions = {
                order = 11,
                type = "description",
                name = ruleToText(ruleSet),
            },
        }
    }
    group.args[tostring(self.ruleSetsIndex)] = option
end

function MessageClassifierConfigFrame:addDefaultRuleSet(group, order, ruleSet)
    self.ruleSetsIndex = self.ruleSetsIndex + 1
    local option = {
        type = "group",
        inline = true,
        order = order,
        name = "",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = L["OPTION_ENABLE"],
                width = 0.5,
                get = function(info)
                    return MessageClassifierConfig.enabledDefaultRules[ruleSet.id] ~= false
                end,
                set = function(info, val)
                    MessageClassifierConfig.enabledDefaultRules[ruleSet.id] = val
                    MessageClassifierBrowser:updateAllMessages()
                end,
            },
            hideFromChatWindow = {
                order = 2,
                type = "toggle",
                name = L["OPTION_HIDE_FROM_CHAT_WINDOW"],
                get = function(info)
                    return ruleSet.hideFromChatWindow == true
                end,
                set = function(info, val)
                    ruleSet.hideFromChatWindow = val
                    MessageClassifierBrowser:updateAllMessages()
                end,
            },
            conditions = {
                order = 11,
                type = "description",
                name = ruleToText(ruleSet),
            },
        }
    }
    group.args[tostring(self.ruleSetsIndex)] = option
end

MessageClassifierConfigFrame:RegisterEvent("ADDON_LOADED")
MessageClassifierConfigFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        self:loadConfig()
    end
    self:UnregisterEvent("ADDON_LOADED")
end)
