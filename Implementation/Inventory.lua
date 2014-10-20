local addon, ns = ...
local O3 = O3


local Inventory = ns.Bag:extend({
	name = 'O3Inventory',
	title = 'O3',
	subTitle = 'Inventory',
	frameStrata = 'HIGH',
	containers = {},
	bagFrame = {},
	offset = {nil, 100, nil, 100},
	events = {
		MAIL_SHOW = true,
		ITEM_LOCKED = true,
		BAG_UPDATE_DELAYED = true,
		ITEM_UNLOCKED = true,
		BAG_UPDATE_COOLDOWN = true,
		ITEM_LOCK_CHANGED = true,				
	},
	config = {
		columns = 12,
		buttonSize = 32,
		XOffset = -100,
		YOffset = 100,
		anchor = 'BOTTOMRIGHT',
		anchorTo = 'BOTTOMRIGHT',
		anchorParent = 'Screen',
	},	
	MAIL_SHOW = function (self)
		self:show()
	end,
	createRegions = function (self)
		self._parent.createRegions(self)
		self.moneyText = self.footer:createFontString({
			offset = {nil, 5, 0, 0},
			text = O3:formatMoney(GetMoney()),
			justifyH = 'RIGHT',
		})
		self.handler:registerEvent('PLAYER_MONEY', self)
		self:createContainers()
	end,
	PLAYER_MONEY = function (self)
		self.moneyText:SetText(O3:formatMoney(GetMoney()))
	end,
	hideBlizzardCrap = function (self)
		for i = 1, NUM_CONTAINER_FRAMES do
			local frame = _G["ContainerFrame"..i]
			O3:destroy(frame)
		end
		ToggleBackpack = function ()
			self:toggle()
		end
		ToggleBag = function ()
			self:toggle()
		end
		CloseBag = function ()
			self:hide()
		end
		OpenBag = function ()
			self:show()
		end		
	end,
})

ns.Handler:addBag(Inventory:new())
--inventory:show()