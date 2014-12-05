local addon, ns = ...
local O3 = O3

ns.BagButton = O3.UI.Button:extend({
	bag = nil,
	slot = nil,
	width = 28,
	height = 28,
	template = 'ContainerFrameItemButtonTemplate',
	preInit = function (self)
		self.name = "O3ItemButton" .. self.bag .. 'S' .. self.slot
	end,
	style = function (self)
		self.bg = self:createTexture({
			layer = 'BACKGROUND',
			subLayer = 0,
			color = {0, 0, 0, 1},
			offset = {0, 0, 0, 0},
			-- height = 1,
		})
		self.outline = self:createOutline({
			layer = 'ARTWORK',
			subLayer = 3,
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.1 },
			colorEnd = {1, 1, 1, 0.2 },
			offset = {1, 1, 1, 1},
		})
		self.highlight = self:createTexture({
			layer = 'ARTWORK',
			gradient = 'VERTICAL',
			color = {0,1,1,0.15},
			colorEnd = {0,1,1,0.20},
			offset = {1,1,1,1},
		})
		self.highlight:Hide()
	end,	
	postInit = function (self)
		local name = self.name
		local oldCount			= _G[name.."Count"]
		local icon				= _G[name.."IconTexture"]
		local button = self.frame
		button:ClearAllPoints()

		local highlightTexture	= _G[name.."HihglightTexture"]
		local iconQuestTexture	= _G[name.."IconQuestTexture"]
		
		local junkIcon = button.JunkIcon
		local border = button.IconBorder
		local battlePay = button.BattlepayItemTexture		

		local newItemTexture	= button.NewItemTexture
		-- local flash	= button.flash

		--icon:SetDrawLayer("HIGHLIGHT")
		local cooldown = _G[name.."Cooldown"]
		self.cooldown = cooldown
		self.icon = icon

		button.bag = self.bag
		button.slot = self.slot

		button:SetNormalTexture("")
		button:SetPushedTexture("")

		if oldCount then
			O3:destroy(oldCount)
			button.count = nil
		end

		if highlightTexture then
			highlightTexture:ClearAllPoints()
			O3:destroy(highlightTexture)
		end

		if iconQuestTexture then
			iconQuestTexture:SetAlpha(0)
		end

		if junkIcon then
			junkIcon:ClearAllPoints()
			O3:destroy(junkIcon)	
		end		

		if battlePay then
			battlePay:ClearAllPoints()
			O3:destroy(battlePay)	
		end

		border:SetAlpha(0)

		if newItemTexture then
			newItemTexture:ClearAllPoints()
			O3:destroy(newItemTexture)			
		end

		if flash then
			flash:ClearAllPoints()
			O3:destroy(flash)			
		end

		if iconQuestTexture then
			iconQuestTexture:ClearAllPoints()
			O3:destroy(iconQuestTexture)			
		end

		self.frame:SetID(self.slot)
		icon:SetTexCoord(.08, .92, .08, .92)
		self:style(button)

		local free, type = GetContainerNumFreeSlots(self.bag)
		button.bagType = type
		-- button.bagColor = self.bagTypes[type]

		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", -1, 1)
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
		cooldown:Hide()
		--icon:SetParent(button)
		--icon:SetDrawLayer("BORDER")
		button:ClearAllPoints()
		self:refresh()
	end,
	createRegions = function (self)
		self.countText = self:createFontString({
			offset = {2, nil, 2, nil},
			fontFlags = 'OUTLINE',
			-- shadowOffset = {1, -1},
			fontSize = 12,
		})
	end, 	
	refresh = function (self)
		local itemInfoTexture, itemCount, locked, _, _, _, itemLink = GetContainerItemInfo(self.bag, self.slot)
		if itemLink then
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =  GetItemInfo(itemLink)
			-- print(itemLink, itemType, itemSubType)
			self.quality = itemRarity
			self.itemCount = itemCount
			self.itemEquipLoc = itemEquipLoc
			self.itemType = itemType
			self.itemSubType = itemSubType
			self.itemLevel = itemLevel
			self.itemLink = itemLink
			self.itemName = itemName
			self.locked = locked
			itemTexture = itemTexture or itemInfoTexture
			
			local itemId = itemLink:match("item:(%d+):")

			if (itemId) then
				local startTime, duration, enable = GetItemCooldown(itemId)
				self.cooldown:SetCooldown(startTime, duration)
			end

			self.icon:SetTexture(itemTexture)
			--SetItemButtonTexture(self.frame, itemTexture)
			local r, g, b, hex = GetItemQualityColor(itemRarity or 0)
			self.bg:SetVertexColor(r, g, b, 1)
			self.bg:SetTexture(r, g, b, 1)
			if (itemCount > 1) then
				self.countText:SetText(itemCount)
			else
				self.countText:SetText(nil)
			end
			self.itemId = itemId
			if (locked) then
				self.icon:SetDesaturated(true)
			else
				self.icon:SetDesaturated(false)
			end
		else
			-- self.frame:SetBackdropColor(unpack(self.bgColor))
			self.bg:SetVertexColor(0, 0, 0, 0.65)
			self.bg:SetTexture(0, 0, 0, 0.65)
			self.countText:SetText(nil)
			self.icon:SetTexture(0, 0, 0, 0.95)
			self.quality = nil
			self.itemCount = nil
			self.itemEquipLoc = nil
			self.itemType = nil
			self.itemSubType = nil
			self.itemLevel = nil
			self.itemLink = nil
			self.itemName = nil
			self.itemId = nil
			self.locked = nil
			self.cooldown:Hide()
		end	
		self.frame.UpdateTooltip = function (frame)
			self:onEnter(frame)
		end

	end,
	lock = function (self)
		self.icon:SetDesaturated(true)
	end,
	unlock = function (self)
		self.icon:SetDesaturated(false)
	end,
		-- 	self.frame:SetScript('OnEnter', function (frame)
		-- 	self.icon:SetVertexColor(0.8,0.8,1,1)
		-- 	if (self.itemLink) then
		-- 		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
		-- 		GameTooltip:SetHyperlink(self.itemLink)
		-- 	else
		-- 		GameTooltip:Hide()
		-- 	end
		-- end)
		-- self.frame:SetScript('OnLeave', function (frame)
		-- 	self.icon:SetVertexColor(1,1,1,1)
		-- 	GameTooltip:Hide()
  --           ResetCursor()
		-- end)

	onEnter = function (self, frame)
		local x = frame:GetRight()
		if ( x >= ( GetScreenWidth() / 2 ) ) then
			GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
		else
			GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
		end

		local showSell = nil;
		local hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetBagItem(self.bag, self.slot)
		if(speciesID and speciesID > 0) then
			BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)
			return
		else
			if (BattlePetTooltip) then
				BattlePetTooltip:Hide()
			end
		end

		if ( InRepairMode() and (repairCost and repairCost > 0) ) then
			GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
			SetTooltipMoney(GameTooltip, repairCost);
			GameTooltip:Show()
		elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
			showSell = 1
		end


		if (O3.Merchant and O3.Merchant.open) then
			SetCursor('BUY_CURSOR')
		end


		if ( IsModifiedClick("DRESSUP") and frame.hasItem ) then
			ShowInspectCursor()
		elseif ( showSell ) then
			ShowContainerSellCursor(self.bag, self.slot)
		elseif ( self.readable ) then
			ShowInspectCursor()
		else
			ResetCursor()
		end

		frame.UpdateTooltip  = function ()
		end


		-- GameTooltip:SetHyperlink(self.itemLink)
		--CursorUpdate(frame)
		GameTooltip:Show()

		--ContainerFrameItemButton_OnEnter(frame)
	end,
	onLeave = function (self)
		GameTooltip:Hide()
        ResetCursor()	
	end,
	hook = function (self)
	end,	
})