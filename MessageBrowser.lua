local ADDON_NAME = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local AceGUI = LibStub("AceGUI-3.0")

MessageClassifierBrowser = AceGUI:Create("Frame")
MessageClassifierBrowser.messages = {}
MessageClassifierBrowser.messageTree = {}
MessageClassifierBrowser.messageTreeIndex = {}
MessageClassifierBrowser.messageViewIndex = {}
MessageClassifierBrowser.allMessages = 0
MessageClassifierBrowser.uniqueMessages = 0
MessageClassifierBrowser.duplicateMessages = 0
MessageClassifierBrowser.sortViewQueue = {}
MessageClassifierBrowser.msgViewContent = {}
MessageClassifierBrowser.baseTime = time() - GetTime()
MessageClassifierBrowser.updateInterval = 1
MessageClassifierBrowser.pauseUpdate = false

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

local function urlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    s = string.gsub(s, " ", "+")
    return s
end

local function urlDecode(s)
   s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
   return s
end

local function dirname(str)
	if str:match("/") then
		local name = string.gsub(str, "^(.*)/([^/]*)$", "%1")
		return name
	else
		return ''
	end
end

local function formatMsg(msg)
    return string.format("%s [%s] %s", date("%H:%M:%S", msg.updateTime), msg.author, msg.msg)
end

local function msgComp(a, b)
    return a.updateTime > b.updateTime
end

local lastSortTime = GetTime()
local function sortAndRefreshViews()
    local now = GetTime()
    if now - lastSortTime < MessageClassifierBrowser.updateInterval then return end
    lastSortTime = now

    -- Prevent stuttering when the user clicks on a node of the tree
    if MessageClassifierBrowser.pauseUpdate then
        MessageClassifierBrowser.pauseUpdate = false
    end

    if tableLen(MessageClassifierBrowser.sortViewQueue) > 0 then
        for _,v in pairs(MessageClassifierBrowser.sortViewQueue) do
            table.sort(v, msgComp)
            if v == MessageClassifierBrowser.msgViewContent.children then
                MessageClassifierBrowser:updateMsgView()
            end
        end
        MessageClassifierBrowser.sortViewQueue = {}
        MessageClassifierBrowser.msgTreeView:RefreshTree()
    end
    MessageClassifierBrowser:updateStatusBar()
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

function MessageClassifierBrowser:addMessage(msg, authorWithServer, author, channelName, authorGUID, guid)
    if authorWithServer == author .. '-' .. GetRealmName() then
        -- Same as the player's realm, remove the suffix
        authorWithServer = author
    end
    self.allMessages = self.allMessages + 1
    if not self.messages[guid] then
        self.messages[guid] = {
            guid = guid,
            author = authorWithServer,
            authorGUID = authorGUID,
            msg = msg,
            channel = channelName,
            updateTime = GetTime() + self.baseTime,
            count = 1,
        }
        self.uniqueMessages = self.uniqueMessages + 1
        self:updateMessageTree(guid)
    else
        self.messages[guid].updateTime = GetTime() + self.baseTime
        self.messages[guid].count = self.messages[guid].count + 1
        self.duplicateMessages = self.duplicateMessages + 1

        for _, v in pairs(self.messageViewIndex[guid]) do
            v.updateTime = self.messages[guid].updateTime
            self:sortMessageView(v)
        end
    end
end

function MessageClassifierBrowser:updateMessageTree(guid)
    if not self.messages[guid] then return end
    
    local msg = self.messages[guid]
    msg.class = self:getMessageClass(msg, MessageClassifierConfig.classificationRules)
    self:addMessageToTree(msg, msg.class, self.messageTree)
    self.msgTreeView:SetTree(self.messageTree)
end

function MessageClassifierBrowser:addMessageToTree(msg, classPath, messageTree)
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
                text = formatMsg(msg),
                value = msg.guid,
                parent = parentNode,
                msg = msg,
                updateTime = msg.updateTime,
            }
            if not self.messageViewIndex[msg.guid] then
                self.messageViewIndex[msg.guid] = {}
            end
            self.messageViewIndex[msg.guid][#self.messageViewIndex[msg.guid] + 1] = parent[index]
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

function MessageClassifierBrowser:updateAllMessages()
    self.messageTree = {}
    self.messageTreeIndex = {}
    self.messageViewIndex = {}
    for guid in pairs(self.messages) do
        self:updateMessageTree(guid)
    end
end

function MessageClassifierBrowser:updateStatusBar()
    MessageClassifierBrowser:SetStatusText(L["BROWSER_STATUS_BAR"]:format(
        self.allMessages, self.uniqueMessages,
        self.duplicateMessages,
        (self.allMessages > 0) and (self.duplicateMessages / self.allMessages * 100) or 0
    ))
end

function MessageClassifierBrowser:updateMsgView()
    local function getAllMessages(tree, result)
        for i=1, #tree do
            local item = tree[i]
            if item.msg then
                result[#result + 1] = item
            end
            if item.children then
                getAllMessages(item.children, result)
            end
        end
    end
    local allMessages = {}
    getAllMessages(self.msgViewContent.children, allMessages)
    table.sort(allMessages, msgComp)

    self.msgView:Clear()
    self.msgView.msgSize = #allMessages
    self.msgView:SetMaxLines(self.msgView.msgSize)
    for i=self.msgView.msgSize, 1, -1 do
        local msg = allMessages[i].msg
        self.msgView:AddMessage(formatMsg(msg))
    end
    self.msgView.msgSizeLineSpacing = self.msgView:CalculateLineSpacing()
    self.msgScroll:updateScroll()
end

function MessageClassifierBrowser:CreateView()
    self:SetTitle(L["BROWSER_TITLE"])
    self:updateStatusBar()
    self:SetLayout("Flow")

    self.searchEdit = AceGUI:Create("EditBox")
    self.searchEdit:SetRelativeWidth(1)
    self:AddChild(self.searchEdit)

    self.msgTreeView = AceGUI:Create("TreeGroup")
    self.msgTreeView:SetFullWidth(true)
    self.msgTreeView:SetFullHeight(true)
    self.msgTreeView:SetTree(self.messageTree)
    self.msgTreeView.parent = self
    self.msgTreeView:SetCallback("OnGroupSelected", function(self, event, group)
        local parent = self.parent
        -- Prevent stuttering when the user clicks on a node of the tree
        parent.pauseUpdate = true

        local path = group:gsub(string.char(1), '/')
        while path ~= '' and not parent.messageTreeIndex[path] do
            path = dirname(path)
        end
        if parent.messageTreeIndex[path] then
            parent.msgViewContent = parent.messageTreeIndex[path]
        end
        parent:updateMsgView()
    end)
    self.msgTreeView:SetLayout("Fill")
    self:AddChild(self.msgTreeView)

    self.msgView = CreateFrame("ScrollingMessageFrame", "$parentMessages", self.msgTreeView.content)
    self.msgView:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP)
    self.msgView:SetFading(false)
    self.msgView:SetIndentedWordWrap(true)
    self.msgView:SetFontObject(ChatFontNormal)
    self.msgView:SetPoint("TOPLEFT", 0, 0)
    self.msgView:SetPoint("BOTTOMRIGHT", -20, 0)
    self.msgView:SetJustifyH("LEFT")
    self.msgScroll = CreateFrame("ScrollFrame", "$parentScroll", self.msgTreeView.content, "FauxScrollFrameTemplate")
    self.msgScroll:SetPoint("TOPLEFT", 0, 0)
    self.msgScroll:SetPoint("BOTTOMRIGHT", -20, 0)

    self.msgView.msgSize = 0
    self.msgView.msgSizeLineSpacing = 14
    self.msgView:SetMaxLines(self.msgView.msgSize)

    self.msgScroll.msgView = self.msgView
    self.msgView.msgScroll = self.msgScroll
    function self.msgScroll:updateScroll()
        local lines = self.msgView.msgSize
        if lines == 0 then
            lines = 1
        end
        local offset = FauxScrollFrame_GetOffset(self)
        self.msgView:SetScrollOffset(offset)
        FauxScrollFrame_Update(self, lines, 1, self.msgView.msgSizeLineSpacing)
    end
    self.msgScroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, self.msgView.msgSizeLineSpacing, self.updateScroll)
    end)
    self:Hide()

    SLASH_MSGCF1 = "/msgcf"
    SlashCmdList["MSGCF"] = function(...)
        MessageClassifierBrowser:Show()
    end
end

MessageClassifierBrowser:CreateView()
