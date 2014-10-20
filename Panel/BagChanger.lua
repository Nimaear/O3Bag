local addon, ns = ...
local O3 = O3

ns.BagChanger = O3.UI.Panel:extend({
	offset = {0, 0, -34, nil},
	height = 32,
	bag = nil,
	buttons = {},
	layer = 'BACKGROUND',
	_start = 1,
	_end = NUM_BAG_SLOTS,
	createButton = function (self, id)
		local button = O3.UI.IconButton:instance({
			parentFrame = self.frame,
			width = 30,
			height = 30,
			offset = {1 + (id-self._start)*31, nil, nil, nil},
			id = ContainerIDToInventoryID(id),
			hook = function (button)
				button.frame:RegisterForDrag("LeftButton", "RightButton")
				button.frame:SetScript('OnDragStart', function (buttonFrame)
					PickupBagFromSlot(button.id)
				end)
				button.frame:SetScript('OnReceiveDrag', function (buttonFrame)
					PutItemInBag(button.id)
				end)
			end,
			update = function (button)
				local equippedBagId = GetInventoryItemID("player", button.id)
				if equippedBagId then
					local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(equippedBagId)
					button.icon:SetTexture(texture)
				else
					button.icon:SetTexture(nil)
				end	
			end,
		})
		button:createShadow()
		button:update()
		return button
	end,
	update = function (self)
		for i = 1, #self.buttons do
			self.buttons[i]:update()
		end
	end,
	createRegions = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -8,
			color = {0, 0, 0, 0.95},
			-- offset = {0, 0, 0, nil},
			-- height = 1,
		})	
		self:createTexture({
			layer = 'BACKGROUND',
			subLayer = -7,
			file = O3.Media:texture('Background'),
			tile = true,
			color = {147/255, 153/255, 159/255, 0.95},
			offset = {1,1,1,1},
		})
		self:createOutline({
			layer = 'BORDER',
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.03 },
			colorEnd = {1, 1, 1, 0.05 },
			offset = {1, 1, 1, 1},
			-- width = 2,
			-- height = 2,
		})


		local lastButton = nil
		for i = self._start, self._end do
			table.insert(self.buttons, self:createButton(i))
		end

	end,
})