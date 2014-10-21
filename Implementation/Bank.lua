local addon, ns = ...
local O3 = O3

local BankButton = ns.BagButton:extend({
	template = 'BankItemButtonGenericTemplate',
	-- hook = function (self)
	-- 	self.frame:SetScript('OnEnter', function (frame)
	-- 		self.icon:SetVertexColor(0.8,0.8,1,1)
	-- 		if (self.itemLink) then
	-- 			GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	-- 			GameTooltip:SetHyperlink(self.itemLink)
	-- 		else
	-- 			GameTooltip:Hide()
	-- 		end
	-- 	end)
	-- 	self.frame:SetScript('OnLeave', function (frame)
	-- 		self.icon:SetVertexColor(1,1,1,1)
	-- 		GameTooltip:Hide()
 --            ResetCursor()
	-- 	end)
	-- end,
})

local Bank = ns.Bag:extend({
	name = 'O3Bank',
	title = 'O3',
	subTitle = 'Bank',
	frameStrata = 'HIGH',
	containers = {},
	bagFrame = {},
	bankOpen = false,
	offset = {100, nil, nil, 100},
	events = {
		BANKFRAME_OPENED = true,
		BANKFRAME_CLOSED = true,
		ITEM_LOCKED = true,
		BAG_UPDATE_DELAYED = true,
		ITEM_UNLOCKED = true,
		BAG_UPDATE_COOLDOWN = true,
		ITEM_LOCK_CHANGED = true,		
		
	},	
	config = {
		columns = 12,
		buttonSize = 32,
		XOffset = 100,
		YOffset = 100,
		anchor = 'BOTTOMLEFT',
		anchorTo = 'BOTTOMLEFT',
		anchorParent = 'Screen',
	},	
	containerButtons = {},
	postInit = function (self)
		self.buttons[BANK_CONTAINER] = {}
		for i = NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS  do
			self.buttons[i] = {}
		end
	end,
	shouldRefresh = function (self)
		return self.bankOpen
	end,	
	postCreate = function (self)
		self.searchPanel = ns.Search:instance({
			parentFrame = self.frame,
			bag = self,
		})
		self.searchPanel:hide()
		self.bagChangerPanel = ns.BagChanger:instance({
			_start = NUM_BAG_SLOTS+1,
			_end = NUM_BAG_SLOTS+NUM_BANKBAGSLOTS,
			parentFrame = self.frame,
			bag = self,
		})
		self.bagChangerPanel:hide()
		self:createHeaderButtons()
		self:createContainers()
		-- self:createSearchPanel()
		-- self:createContainerButtons()
		-- self:anchor()

		if GetBankSlotCost() ~= 999999999 then
			self.header:addButton(O3.UI.GlyphButton:instance({
				parentFrame = self.header.frame,
				width = 20,
				height = 20,
				text = '',
				onClick = function (control)
					PurchaseSlot()
					if GetBankSlotCost() == 999999999 then
						control:Hide()
					end
				end,
			}))

		end


	end,
	createButton = function (self, bag, slot)
		local bagFrame = self.bagFrame[bag] or self:createBagFrame(bag)
		local button
		if bag == BANK_CONTAINER then
			button = BankButton:instance({
				parentFrame = bagFrame,
				bag = bag,
				slot = slot,
				width = self.config.buttonSize,
				height = self.config.buttonSize
			})
		else
			button = ns.BagButton:instance({
				parentFrame = bagFrame,
				bag = bag,
				slot = slot,
				width = self.config.buttonSize,
				height = self.config.buttonSize
			})
		end	
		button:show()		
		self.buttons[bag][slot] = button
		return button
	end,	
	hideBlizzardCrap = function (self)
		O3:destroy(BankFrame)
	end,
	BANKFRAME_OPENED = function (self)
		self.bankOpen = true
		self:show()
	end,
	onHide = function (self)
		if self.bankOpen then
			CloseBankFrame()
		end
	end,	
	BANKFRAME_CLOSED = function (self)
		self.bankOpen = false
		self:hide()
	end,
})

ns.Handler:addBag(Bank:new())
--inventory:show()