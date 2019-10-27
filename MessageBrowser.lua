local ADDON_NAME = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local AceGUI = LibStub("AceGUI-3.0")

MessageClassifierBrowser = AceGUI:Create("Frame")
MessageClassifierBrowser.messages = {}
MessageClassifierBrowser.messageClass = {}
MessageClassifierBrowser.allMessages = 0
MessageClassifierBrowser.uniqueMessages = 0
MessageClassifierBrowser.duplicateMessages = 0

local function deepCompare(t1,t2,ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then return false end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1,v1 in pairs(t1) do
      local v2 = t2[k1]
      if v2 == nil or not deepcompare(v1,v2) then return false end
    end
    for k2,v2 in pairs(t2) do
      local v1 = t1[k2]
      if v1 == nil or not deepcompare(v1,v2) then return false end
    end
    return true
end

local function tableLen(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

local function split(str, d)
	local lst = { }
	local n = string.len(str)
	local start = 1
	while start <= n do
		local i = string.find(str, d, start)
		if i == nil then 
			table.insert(lst, string.sub(str, start, n))
			break 
		end
		table.insert(lst, string.sub(str, start, i-1))
		if i == n then
			table.insert(lst, "")
			break
		end
		start = i + 1
	end
	return lst
end

function MessageClassifierBrowser:addMessage(msg, authorWithServer, author, channelName, playerGUID, guid)
    if authorWithServer == author .. '-' .. GetRealmName() then
        -- Same as the player's realm, remove the suffix
        authorWithServer = author
    end
    self.allMessages = self.allMessages + 1
    if not self.messages[guid] then
        self.messages[guid] = {
            guid = guid,
            author = authorWithServer,
            msg = msg,
            channels = {
                [channelName] = true
            },
            updateTime = time(),
            count = 1,
        }
        self.uniqueMessages = self.uniqueMessages + 1
        self:updateMessageClass(guid)
    else
        self.messages[guid].updateTime = time()
        self.messages[guid].count = self.messages[guid].count + 1
        self.duplicateMessages = self.duplicateMessages + 1

        if not self.messages[guid].channels[channelName] then
            self.messages[guid].channels[channelName] = true
            self:updateMessageClass(guid)
        end
    end
    self:updateStatusBar()
end

function MessageClassifierBrowser:updateMessageClass(guid)
    if not self.messages[guid] then return end
    
    local msg = self.messages[guid]

    local newClass = self:getMessageClass(msg, MessageClassifierConfig.classificationRules)
    if deepCompare(msg.class, newClass) then
        return
    end
    self:removeMessageFromClass(msg, msg.class, self.messageClass)
    msg.class = newClass

    MessageClassifierBrowser:addMessageToClass(msg, msg.class, self.messageClass)
end

function MessageClassifierBrowser:addMessageToClass(msg, classTree, messageTree)
    local guid = msg.guid
    for key, class in pairs(classTree) do
        if type(class) == 'table' then
            if type(messageTree[key]) ~= 'table' then
                messageTree[key] = {}
            end
            self:addMessageToClass(msg, class, messageTree[key])
        else
            if type(messageTree[class]) ~= 'table' then
                messageTree[class] = {}
            end
            if not messageTree[class][guid] then
                messageTree[class][guid] = msg
            end
        end
    end
end

function MessageClassifierBrowser:removeMessageFromClass(msg, classTree, messageTree)
    if type(classTree) ~= 'table' then return end

    local guid = msg.guid
    for key, class in pairs(classTree) do
        if type(class) == 'table' then
            if type(messageTree[key]) == 'table' then
                self:removeMessageFromClass(msg, class, messageTree[key])
            end
        else
            if messageTree[class][guid] then
                messageTree[class][guid] = nil
            end
            if tableLen(messageTree[class]) == 0 then
                messageTree[class] = nil
            end
        end
    end
end

function MessageClassifierBrowser:getMessageClass(msg, ruleSet)
    local classTree = {}

    for _, rule in pairs(ruleSet) do
        local match = false
        for _, expression in pairs(rule.expressions) do
            if expression.operator == "unconditional" then
                match = true
            else
                local operator = expression.operator
                local field = msg[expression.field or ""] or ""
                local value = expression.value or ""

                if not expression.caseSensitive then
                    field = field:lower()
                    if operator ~= "match" and operator ~= "not match" then
                        value = value:lower()
                    end
                end

                if operator == "equal" then
                    match = field == value
                elseif operator == "not equal" then
                    match = field ~= value
                elseif operator == "contain" then
                    match = field:find(value) ~= nil
                elseif operator == "not contain" then
                    match = field:find(value) == nil
                elseif operator == "match" then
                    match = field:match(value)
                elseif operator == "not match" then
                    match = not field:match(value)
                end

                if not match then
                    break
                end
            end
        end

        if match then
            local class = rule.class

            if class:find('{author}') ~= nil then
                class = class:gsub('{author}', msg.author)
            end

            if class:find('{channel}') then
                for channel in pairs(msg.channels) do
                    local classWithChannel = class:gsub('{channel}', channel)
                    self:mergeClassTree(msg, classTree, split(classWithChannel, '/'))
                end
            else
                self:mergeClassTree(msg, classTree, split(class, '/'))
            end
        end
    end

    return classTree
end

function MessageClassifierBrowser:mergeClassTree(msg, classTree, class)
    if #class <= 0 then return end

    for i = 1, #class - 1 do
        node = class[i]
        if type(classTree[node]) ~= "table" then
            classTree[node] = {}
        end
        classTree = classTree[node]
    end

    classTree[class[#class]] = class[#class]
end

function MessageClassifierBrowser:updateAllMessageClass()
    self.messageClass = {}
    for guid in pairs(self.messages) do
        self:updateMessageClass(guid)
    end
end

function MessageClassifierBrowser:updateStatusBar()
    MessageClassifierBrowser:SetStatusText(L["BROWSER_STATUS_BAR"]:format(
        self.allMessages, self.uniqueMessages,
        self.duplicateMessages,
        (self.allMessages > 0) and (self.duplicateMessages / self.allMessages * 100) or 0
    ))
end

function MessageClassifierBrowser:addClassView(className)

end

MessageClassifierBrowser:SetTitle(L["BROWSER_TITLE"])
MessageClassifierBrowser:updateStatusBar()
MessageClassifierBrowser:SetLayout("Flow")

MessageClassifierBrowser.searchEdit = AceGUI:Create("EditBox")
MessageClassifierBrowser.searchEdit:SetRelativeWidth(1)
MessageClassifierBrowser:AddChild(MessageClassifierBrowser.searchEdit)

MessageClassifierBrowser.classList = AceGUI:Create("ScrollFrame")
MessageClassifierBrowser.classList:SetFullWidth(true)
MessageClassifierBrowser.classList:SetFullHeight(true)
MessageClassifierBrowser.classList:SetLayout("Fill")
MessageClassifierBrowser:AddChild(MessageClassifierBrowser.classList)

MessageClassifierBrowser:Hide()
