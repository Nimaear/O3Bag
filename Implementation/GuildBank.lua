local addon, ns = ...
local O3 = O3


local GuildBankButton = ns.Button:extend({
	template = 'GuildBankItemButtonTemplate',
	getItemInfo = function (self, bag, slot)
		local texture, count, locked = GetGuildBankItemInfo(bag, slot)
		local itemLink = GetGuildBankItemLink(bag, slot)
		return texture, count, locked, _, _, _, itemLink
	end,

	hook = function (self)
		self.frame:SetScript('OnEnter', function (frame)
			self.icon:SetVertexColor(0.8,0.8,1,1)
			if (self.itemLink) then
				GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(self.itemLink)
			else
				GameTooltip_Hide()
			end
		end)
		self.frame:SetScript('OnLeave', function (frame)
			self.icon:SetVertexColor(1,1,1,1)
			GameTooltip_Hide()
            ResetCursor()
		end)
		self.frame:SetScript('OnDragStart', function (frame)
			if (GetCurrentGuildBankTab() ~= self.bag) then
				SetCurrentGuildBankTab(self.bag)
				PickupGuildBankItem(self.bag, self.slot)
			end
		end)
		self.frame:SetScript('OnReceiveDrag', function (frame)
			if (GetCurrentGuildBankTab() ~= self.bag) then
				SetCurrentGuildBankTab(self.bag)
				PickupGuildBankItem(self.bag, self.slot)
			end
		end)
	end,
})

local GuildBank = ns.Bag:extend({
	name = 'O3GuildBank',
	titleText = 'O3GuildBank',
	frameStrata = 'HIGH',
	containers = {},
	bagFrame = {},
	bankOpen = false,
	events = {
		GUILDBANKFRAME_OPENED = true,
		GUILDBANKFRAME_CLOSED = true,
		GUILDBANKBAGSLOTS_CHANGED = true,
		GUILDBANK_ITEM_LOCK_CHANGED = true,
	},	
	buttons = {
	},
	config = {
		columns = 20,
		buttonSize = 32,
		anchor = 'BOTTOMLEFT',
		xOffset = 100,
		yOffset = 100,
	},
	tabInfo = {},
	containerButtons = {},
	postInit = function (self)
		for i = 1, 4 do
			self.buttons[i] = {}
		end
	end,
	shouldRefresh = function (self)
		return self.bankOpen
	end,	
	createContainerButtons = function (self)
		local containersPanel = self:createContainersPanel()
		local lastButton = nil
		for i = 1, 4 do
			local button = self:createContainerButton(containersPanel, i)
			if lastButton then
				button:SetPoint('LEFT', lastButton, 'RIGHT', 4, 0)
			else
				button:SetPoint('LEFT', containersPanel, 'LEFT', 4, 0)
			end
			lastButton = button
			table.insert(self.containerButtons, button)
		end
	end,
	refresh = function (self)
		if self:shouldRefresh() then
			for i = 1, #self.containers do
				local container = self.containers[i]
				container:reset(self.config.columns)
				container.frame:SetPoint('TOP', self.content, 'TOP', 0, -4)
			end
			for bag, buttons in pairs(self.buttons) do 
				for slot=1,MAX_GUILDBANK_SLOTS_PER_TAB do
					local button = self:getButton(bag, slot)
					self:place(button)
				end
			end
			local lastContainer = self.frame
			local height = 24
			for i = 1, #self.containers do
				local container = self.containers[i]
				if (not container:empty()) then
					container:sort()
					if (lastContainer ~= self.frame) then
						container.frame:SetPoint('TOP', lastContainer, 'BOTTOM', 0, -4)
					end
					height = height + container.frame:GetHeight() + 4
					lastContainer = container.frame
				else
					container.frame:Hide()
				end
			end
			self:size(height)
		end
	end,
	createContainers = function (self)
		self:createContainer({
			titleText = 'Tab 1 ',
			takes = function (self, button)
				return button.bag == 1
			end,
		})
		self:createContainer({
			titleText = 'Tab 2 ',
			takes = function (self, button)
				return button.bag == 2
			end,
		})
		self:createContainer({
			titleText = 'Tab 3 ',
			takes = function (self, button)
				return button.bag == 3
			end,
		})
		self:createContainer({
			titleText = 'Tab 4 ',
			takes = function (self, button)
				return button.bag == 4
			end,
		})
	end,	
	createButton = function (self, bag, slot)
		local bagFrame = self.bagFrame[bag] or self:createBagFrame(bag)
		local button
		button = GuildBankButton:instance({
			bagFrame = bagFrame,
			bag = bag,
			slot = slot,
			size = self.config.buttonSize
		})
		self.buttons[bag][slot] = button
		return button
	end,	
	hideBlizzardCrap = function (self)
		-- O3:destroy(GuildBankFrame)
	end,
	GUILDBANK_ITEM_LOCK_CHANGED = function (self)
		self:GUILDBANKBAGSLOTS_CHANGED('LOCK')
	end,
	requestTabInfo = function (self, tab)
		if (not self.tabInfo[tab] or self.tabInfo[tab] < GetTime()-2) then
			QueryGuildBankTab(tab)
			self.tabInfo[tab] = GetTime()
		end
	end,
	GUILDBANKBAGSLOTS_CHANGED = function (self, ...)

		if (self:visible()) then
			for bag, buttons in pairs(self.buttons) do
				self:requestTabInfo(bag)	
				for slot = 1, #buttons do
					local button = buttons[slot]
					button:refresh()
				end
			end
		end
	end,

	GUILDBANKFRAME_OPENED = function (self)
		self.bankOpen = true
		self:show()
	end,
	onHide = function (self)
		-- if self.bankOpen then
		-- 	CloseGuildBankFrame()
		-- end
	end,	
	GUILDBANKFRAME_CLOSED = function (self)
		self.bankOpen = false
		self:hide()
	end,
})

ns.Handler:addBag(GuildBank:new())

