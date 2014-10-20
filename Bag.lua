local addon, ns = ...
local O3 = O3

local Bag = O3.UI.Window:extend({
	name = 'O3Bag',
	titleText = 'O3Bag',
	frameStrata = 'HIGH',
	closeWithEscape = true,
	postInit = function (self)
		self.buttons[0]	= {}
		for i = 1, NUM_BAG_SLOTS do
			self.buttons[i] = {}
		end
	end,
	events = {
		MAIL_SHOW = true,
		ITEM_LOCKED = true,
		BAG_UPDATE_DELAYED = true,
		ITEM_UNLOCKED = true,
		BAG_UPDATE_COOLDOWN = true,
		ITEM_LOCK_CHANGED = true,		
	},
	containers = {},
	bagFrame = {},
	config = {
		columns = 12,
		buttonSize = 32,
		XOffset = -100,
		YOffset = 100,
		anchor = 'BOTTOMRIGHT',
		anchorTo = 'BOTTOMRIGHT',
		anchorParent = 'Screen',
	},
	settings = {
		maximizable = false,
		resizable = false,
		labelFont = O3.Media:font('Normal'),
		labelFontSize = 12,
		titleHeight = 25,
		panelHeight = 30,
	},	
	preInit = function (self)
		self.buttons = {}
	end,
	postInit = function (self)
		self.buttons[0]	= {}
		for i = 1, NUM_BAG_SLOTS do
			self.buttons[i] = {}
		end
	end,
	createButton = function (self, bag, slot)
		local bagFrame = self.bagFrame[bag] or self:createBagFrame(bag)
		local button = ns.BagButton:instance({
			parentFrame = bagFrame,
			bag = bag,
			slot = slot,
			width = self.config.buttonSize,
			height = self.config.buttonSize
		})
		button:show()
		self.buttons[bag][slot] = button
		return button
	end,
	createBagFrame = function (self, bag)
		local bagFrame = CreateFrame("Frame", 'O3Bag'..bag , self.frame)
		bagFrame:SetAllPoints()
		bagFrame:SetID(bag)
		self.bagFrame[bag] = bagFrame
		return bagFrame
	end,
	getButton = function (self, bag, slot)
		local button = self.buttons[bag][slot] or self:createButton( bag, slot)
		return button
	end,
	search = function (self, searchText)
		if searchText then
			local searchText = string.lower(searchText)
			for bag, buttons in pairs(self.buttons) do 
				for slot=1,GetContainerNumSlots(bag) do
					local button = self:getButton(bag, slot)
					local itemName = string.lower(button.itemName or "")
					if searchText == "" or string.find(itemName, searchText) then
						button.frame:SetAlpha(1)
					else
						button.frame:SetAlpha(0.3)
					end
				end
			end
		else
			for bag, buttons in pairs(self.buttons) do 
				for slot=1,GetContainerNumSlots(bag) do
					local button = self:getButton(bag, slot)
					button.frame:SetAlpha(1)
				end
			end
		end			
	end,
	createHeaderButtons = function (self)
		self.header:addButton(O3.UI.GlyphButton:instance({
			parentFrame = self.header.frame,
			width = 20,
			height = 20,
			text = '',
			onClick = function ()
				if self.activePanel == self.searchPanel then
					self.searchPanel:hide()
				else
					if (self.activePanel) then
						self.activePanel:hide()
					end
					self.searchPanel:show()
					self.activePanel = self.searchPanel
				end
			end,
		}))
		self.header:addButton(O3.UI.GlyphButton:instance({
			parentFrame = self.header.frame,
			width = 20,
			height = 20,
			text = '',
			onClick = function ()
				if self.activePanel == self.bagChangerPanel then
					self.bagChangerPanel:hide()
				else
					if (self.activePanel) then
						self.activePanel:hide()
					end
					self.bagChangerPanel:show()
					self.activePanel = self.bagChangerPanel
				end
			end,
		}))
		self.header:addButton(O3.UI.GlyphButton:instance({
			parentFrame = self.header.frame,
			width = 20,
			height = 20,
			text = '',
			onClick = function ()
				self:refresh()
			end,
		}))
	end,
	postCreate = function (self)
		self.searchPanel = ns.Search:instance({
			parentFrame = self.frame,
			bag = self,
		})
		self.searchPanel:hide()
		self.bagChangerPanel = ns.BagChanger:instance({
			parentFrame = self.frame,
			bag = self,
		})
		self.bagChangerPanel:hide()
		self:createHeaderButtons()
		self:createContainers()
		-- self:createSearchPanel()
		-- self:createContainerButtons()
		-- self:anchor()
	end,
	
	size = function (self, height)
		height = height or 500
		local width = self.config.columns*(self.config.buttonSize+1)+5
		self.frame:SetSize(width, self.header.frame:GetHeight()+height+self.footer.frame:GetHeight())
	end,
	addContainer = function (self, container)
		table.insert(self.containers, container)
		container.frame:SetParent(self.content.frame)
	end,
	place = function (self, button)
		for i = 1, #self.containers do
			local container = self.containers[i]
			if (container:takes(button)) then
				container:place(button)
				return
			end
		end
		if (self.containers[1]) then
			self.containers[1]:place(button)
		end
	end,
	shouldRefresh = function (self)
		return true
	end,
	refresh = function (self)
		if self:shouldRefresh() then
			for i = 1, #self.containers do
				local container = self.containers[i]
				container:reset(self.config.columns)
				container.frame:SetPoint('TOP', self.content.frame, 'TOP', 0, -4)
			end
			for bag, buttons in pairs(self.buttons) do 
				for slot=1,GetContainerNumSlots(bag) do
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
					container:hide()
				end
			end
			self:size(height)
		end
	end,
	createContainer = function (self, template)
		template.parentFrame = self.content.frame
		template.buttonSize = self.config.buttonSize
		local container = ns.Container:instance(template)
		self:addContainer(container)
		return container
	end,
	createInscriptionContainer = function (self)
		self:createContainer({
				titleText = 'Trade Goods Parts',
				takes = function (self, button)
					local itemSubType = button.itemSubType
					local itemType = button.itemType
					return (itemType == 'Trade Goods' and itemSubType == 'Parts')
				end,
			})	
	end,
	createContainers = function (self)
		self:createContainer({
			titleText = 'Trash',
			takes = function (self, button)
				local quality = button.itemLink and button.quality
				return quality == 0
			end,
		})
		self:createContainer({
			titleText = 'Armor',
			takes = function (self, button)
				local itemType = button.itemType
				return itemType == "Armor" or itemType == "Weapon"
			end,
		})
		local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
		if (prof1 == 5 or prof2 == 5) then
			self:createInscriptionContainer()
		end
		self:createContainer({
			titleText = 'Profession',
			takes = function (self, button)
				local itemSubType = button.itemSubType
				local itemType = button.itemType
				return itemType == 'Gem' or (itemType == 'Trade Goods' and itemSubType == 'Cooking') or (itemType == 'Trade Goods' and itemSubType == 'Herb')
			end,
		})
		self:createContainer({
			titleText = 'Trade Goods',
			takes = function (self, button)
				local itemType = button.itemType
				return itemType == "Trade Goods"
			end,
		})
		self:createContainer({
			titleText = 'Consumables',
			takes = function (self, button)
				local itemSubType = button.itemSubType
				local itemType = button.itemType
				return itemSubType == "Potion" or itemSubType == "Elixir" or itemSubType == "Flask" or itemType == "Consumable" or itemSubType == "Food & Drink"
			end,
		})
		self:createContainer({
			titleText = 'Misc',
			takes = function (self, button)
				local itemType = button.itemType
				return itemType == "Miscellaneous"
			end,
		})
		self:createContainer({
			titleText = 'Other',
			takes = function (self, button)
				local itemType = button.itemType
				return true
			end,
		})

	end,
	register = function (self, handler)
		self.handler = handler
		handler:addOption(self.name..'_1', {
			type = 'Title',
			label = self.name,
		})
		handler:addOption(self.name..'visible', {
			type = 'CheckBox',
			label = 'Visible',
			onMouseDown = function (option, toggle)
				if (option.parent.settings[self.name..'visible']) then
					self:show()
				else
					self:hide()
				end
			end,
		})
        handler:addOption(self.name..'anchor', {
            type = 'DropDown',
            label = 'Point',
            bag = self,
            setter = 'anchorSet',
            _values = O3.UI.anchorPoints
        })
        handler:addOption(self.name..'anchorParent', {
            type = 'DropDown',
            label = 'Anchor To',
            bag = self,
            setter = 'anchorSet',
            _values = handler.bagDropdown
        })         
        handler:addOption(self.name..'anchorTo', {
            type = 'DropDown',
            label = 'To Point',
            bag = self,
            setter = 'anchorSet',
            _values = O3.UI.anchorPoints
        })        
		handler:addOption(self.name..'XOffset', {
			type = 'Range',
			label = 'Horizontal',
			setter = 'anchorSet',
			bag = self,
			min = -500,
			max = 500,
			step = 5,
		})
		handler:addOption(self.name..'YOffset', {
			type = 'Range',
			label = 'Vertical',
			setter = 'anchorSet',
			bag = self,
			min = -500,
			max = 500,
			step = 5,
		})		
		for k, v in pairs(self.config) do
			handler.config[self.name..k] = v
		end
		for event, on in pairs(self.events) do
			handler:registerEvent(event, self)
		end
		self:hideBlizzardCrap()
	end,
	hideBlizzardCrap = function (self)
	end,
	onShow = function (self)
		for bag, buttons in pairs(self.buttons) do
			for slot = 1, #buttons do
				local button = buttons[slot]
				button:refresh()
			end
		end
		self.bagChangerPanel:update()
		self:refresh()
	end,
	BAG_UPDATE_DELAYED = function (self)
		if (self:visible()) then
			for bag, buttons in pairs(self.buttons) do
				for slot = 1, #buttons do
					local button = buttons[slot]
					button:refresh()
				end
			end
			self.bagChangerPanel:update()
		end
	end,
	ITEM_LOCKED = function (self, bag, slot)
		if (self[bag]) then
			local button = self:getButton(bag, slot)
			button:lock()
		end
	end,
	ITEM_UNLOCKED = function (self, bag, slot)
		if (self[bag]) then
			local button = self:getButton(bag, slot)
			button:unlock()
		end
	end,
	ITEM_LOCK_CHANGED = function (self, bag, slot)
		if (self[bag]) then
			local button = self:getButton(bag, slot)
			button:refresh()
		end
	end,
	BAG_UPDATE_COOLDOWN = function (self)
		self:BAG_UPDATE_DELAYED()
	end,
	BANKFRAME_OPENED = function (self)
		self:show()
	end,
	BANKFRAME_CLOSED = function (self)
		self:hide()
	end,	
})

ns.Bag = Bag