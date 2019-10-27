local ADDON_NAME = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local AceGUI = LibStub("AceGUI-3.0")

MessageClassifierBrowser = AceGUI:Create("Frame")
MessageClassifierBrowser.messages = {}
MessageClassifierBrowser.messageClass = {}
MessageClassifierBrowser.messageTreeIndex = {}
MessageClassifierBrowser.messageViewIndex = {}
MessageClassifierBrowser.allMessages = 0
MessageClassifierBrowser.uniqueMessages = 0
MessageClassifierBrowser.duplicateMessages = 0
MessageClassifierBrowser.sortViewQueue = {}

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

local function msgComp(a, b)
    return  a.updateTime > b.updateTime
end

local lastSortTime = GetTime()
local function sortAndRefreshViews()
    local now = GetTime()
    if now - lastSortTime < 5 then return end

    if tableLen(MessageClassifierBrowser.sortViewQueue) > 0 then
        for _,v in pairs(MessageClassifierBrowser.sortViewQueue) do
            table.sort(v, msgComp)
        end
        MessageClassifierBrowser.sortViewQueue = {}
        MessageClassifierBrowser.classTree:RefreshTree()
    end
    MessageClassifierBrowser:updateStatusBar()

    lastSortTime = now
end
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", sortAndRefreshViews)

function MessageClassifierBrowser:sortMessageView(view)
    if view and view.parent then
        view.parent.updateTime = view.updateTime
        if view.parent.children then
            self.sortViewQueue[view.parent.children] = view.parent.children
            self:sortMessageView(view.parent)
        end
    end
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
            channel = channelName,
            updateTime = time(),
            count = 1,
        }
        self.uniqueMessages = self.uniqueMessages + 1
        self:updateMessageClass(guid)
    else
        self.messages[guid].updateTime = time()
        self.messages[guid].count = self.messages[guid].count + 1
        self.duplicateMessages = self.duplicateMessages + 1

        for _, v in pairs(self.messageViewIndex[guid]) do
            v.updateTime = self.messages[guid].updateTime
            self:sortMessageView(v)
        end
    end
end

function MessageClassifierBrowser:updateMessageClass(guid)
    if not self.messages[guid] then return end
    
    local msg = self.messages[guid]
    msg.class = self:getMessageClass(msg, MessageClassifierConfig.classificationRules)
    self:addMessageToClass(msg, msg.class, self.messageClass)
    self.classTree:SetTree(self.messageClass)
end

function MessageClassifierBrowser:addMessageToClass(msg, classPath, messageTree)
    for k in pairs(classPath) do
        local parts = split(k, '/')
        local path = nil
        local parentNode = messageTree
        local parent = parentNode
        for _, v in pairs(parts) do
            path = path and path..'/'..v or v
            if not self.messageTreeIndex[path] then
                local index = #parent + 1
                parent[index] = {
                    text = v,
                    value = v,
                    children = {},
                    parent = parentNode,
                    updateTime = msg.updateTime,
                }
                self.messageTreeIndex[path] = parent[index]
            end
            parentNode = self.messageTreeIndex[path]
            parent = parentNode.children
        end
    end
    
    for k in pairs(classPath) do
        if self.messageTreeIndex[k].children then
            local parentNode = self.messageTreeIndex[k]
            local parent = parentNode.children
            local index = #(parent) + 1
            parent[index] = {
                text = msg.msg,
                value = msg.guid,
                parent = parentNode,
                msg = msg,
                updateTime = msg.updateTime,
            }
            if not self.messageViewIndex[msg.guid] then
                self.messageViewIndex[msg.guid] = {}
            end
            self.messageViewIndex[msg.guid][#self.messageViewIndex[msg.guid]] = parent[index]
            self:sortMessageView(parent[index])
        end
    end
end

function MessageClassifierBrowser:getMessageClass(msg, ruleSet)
    local classPath = {}

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
                class = class:gsub('{channel}', msg.channel)
            end

            classPath[class] = true
        end
    end

    return classPath
end

function MessageClassifierBrowser:updateAllMessageClass()
    self.messageClass = {}
    self.messageTreeIndex = {}
    self.messageViewIndex = {}
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

MessageClassifierBrowser:SetTitle(L["BROWSER_TITLE"])
MessageClassifierBrowser:updateStatusBar()
MessageClassifierBrowser:SetLayout("Flow")

MessageClassifierBrowser.searchEdit = AceGUI:Create("EditBox")
MessageClassifierBrowser.searchEdit:SetRelativeWidth(1)
MessageClassifierBrowser:AddChild(MessageClassifierBrowser.searchEdit)

MessageClassifierBrowser.classTree = AceGUI:Create("TreeGroup")
MessageClassifierBrowser.classTree:SetFullWidth(true)
MessageClassifierBrowser.classTree:SetFullHeight(true)
MessageClassifierBrowser.classTree:SetTree(MessageClassifierBrowser.messageClass)
--MessageClassifierBrowser.classTree.treeframe:SetWidth(600)
MessageClassifierBrowser.classTree:SetCallback("OnGroupSelected", function(self, event, group)
    self:SelectByPath(group)
end)
MessageClassifierBrowser.classTree:SetLayout("Fill")
MessageClassifierBrowser:AddChild(MessageClassifierBrowser.classTree)

MessageClassifierBrowser.messageScrollView = AceGUI:Create("ScrollFrame")
MessageClassifierBrowser.messageScrollView:SetLayout("List")
MessageClassifierBrowser.classTree:AddChild(MessageClassifierBrowser.messageScrollView)

MessageClassifierBrowser:Hide()
