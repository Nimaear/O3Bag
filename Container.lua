local addon, ns = ...
local O3 = O3

local equipLookup = {
	INVTYPE_AMMO = '01',
	INVTYPE_HEAD = '02',
	INVTYPE_NECK = '03',
	INVTYPE_SHOULDER = '04',
	INVTYPE_BODY = '05',
	INVTYPE_CHEST = '06',
	INVTYPE_ROBE = '07',
	INVTYPE_WAIST = '08',
	INVTYPE_LEGS = '09',
	INVTYPE_FEET = '10',
	INVTYPE_WRIST = '11',
	INVTYPE_HAND = '12',
	INVTYPE_FINGER = '13',
	INVTYPE_TRINKET = '14',
	INVTYPE_CLOAK = '15',
	INVTYPE_WEAPON = '16',
	INVTYPE_SHIELD = '17',
	INVTYPE_2HWEAPON = '18',
	INVTYPE_WEAPONMAINHAND = '19',
	INVTYPE_WEAPONOFFHAND = '20',
	INVTYPE_HOLDABLE = '21',
	INVTYPE_RANGED = '22',
	INVTYPE_THROWN = '23',
	INVTYPE_RANGEDRIGHT = '24',
	INVTYPE_RELIC = '25',
	INVTYPE_TABARD = '26',
	INVTYPE_BAG = '27',
	INVTYPE_QUIVER = '28',
}
local itemTypeLookup = {
	Armor = '00',
	Consumable = '01',
	Container = '02',
	Gem = '03',
	Key = '04',
	Miscellaneous = '05',
	Money = '06',
	Reagent = '07',
	Recipe = '09',
	Projectile = '10',
	Quest = '11',
	Quiver = '12',
	['Trade Goods'] = '13',
	Weapon = '14',
}
local subItemTypeLookup = {
	Miscellaneous = '01',
	Cloth = '02',
	Leather = '03',
	Mail = '04',
	Plate = '05',
	Shields = '06',
	Librams = '07',
	Idols = '08',
	Totems = '09',
	Sigils = '10',
	['Food & Drink'] = '11',
	Potion = '12',
	Elixir = '13',
	Flask = '14',
	Bandage = '15',
	ItemEnhancement = '16',
	Scroll = '17',
	Other = '18',
	Consumable = '19',
	Bag = '20',
	EnchantingBag = '21',
	EngineeringBag = '22',
	GemBag = '23',
	HerbBag = '24',
	MiningBag = '25',
	SoulBag = '26',
	LeatherworkingBag = '27',
	Blue = '28',
	Green = '29',
	Orange = '30',
	Meta = '31',
	Prismatic = '32',
	Purple = '33',
	Red = '34',
	Simple = '35',
	Yellow = '36',
	Key = '37',
	Junk = '38',
	Reagent = '39',
	Pet = '40',
	Holiday = '41',
	Mount = '42',
	Other = '43',
	Alchemy = '44',
	Blacksmithing = '45',
	Book = '46',
	Cooking = '47',
	Enchanting = '48',
	Engineering = '49',
	FirstAid = '50',
	Leatherworking = '51',
	Tailoring = '52',
	rojectileArrow = '53',
	Bullet = '54',
	Quest = '55',
	AmmoPouch = '56',
	Quiver = '57',
	ArmorEnchantment = '58',
	Cloth = '59',
	Devices = '60',
	Elemental = '61',
	Enchanting = '62',
	Explosives = '63',
	Herb = '64',
	Jewelcrafting = '65',
	Leather = '66',
	Materials = '67',
	Meat = '68',
	['Metal & Stone'] = '69',
	Other = '70',
	Parts = '71',
	TradeGoods = '72',
	WeaponEnchantment = '73',
	Bows = '74',
	Crossbows = '75',
	Daggers = '76',
	Guns = '77',
	FishingPoles = '78',
	FistWeapons = '79',
	Miscellaneous = '80',
	['OneHanded Axes'] = '81',
	['OneHanded Maces'] = '82',
	['OneHanded Swords'] = '83',
	Polearms = '84',
	Staves = '85',
	Thrown = '86',
	['TwoHanded Axes'] = '87',
	['TwoHanded Maces'] = '88',
	['TwoHanded Swords'] = '89',
	Wands = '90',
	OneHand = '91',
	TwoHand = '92',
}

ns.Container = O3.UI.Panel:extend({
	spacing = 1,
	columns = 8,
	buttonSize = 32,
	font = O3.Media:font('Normal'),
	fontSize = 12,
	fontFlags = '',
	offset = {0, 0, 0, nil},
	titleText = 'Default Container',
	empty = function (self)
		return self.buttonCount == 0
	end,
	reset = function (self, columns)
		self.buttonCount = 0
		self.columns = columns
	end,
	takes = function (self, button)
		return true
	end,
	createRegions = function (self)
		self.titleText = self:createFontString({
			offset = {1, 1, 1, nil},
			text = self.titleText,
			justifyH = 'LEFT',
		})
	end,
	-- style = function (self)
	-- 	self.outline = self:createOutline({
	-- 		layer = 'ARTWORK',
	-- 		subLayer = 3,
	-- 		gradient = 'VERTICAL',
	-- 		color = {1, 1, 1, 0.1 },
	-- 		colorEnd = {1, 1, 1, 0.2 },
	-- 		offset = {1, 1, 1, 1},
	-- 	})
	-- end,
	sorter = function (self, a, b)
		local aScore, bScore = a and string.format("%05d",a.bagType or 0) or '00000', b and string.format("%05d",b.bagType or 0) or '00000'
		if (a and a.itemLink) then
			local aIL, aIEL, aIT, aIST, aQ, aC, aN = string.format("%04d",a.itemLevel or 0), equipLookup[a.itemEquipLoc] or '00', itemTypeLookup[a.itemType] or '00', itemTypeLookup[a.itemSubType] or '00', a.quality or '0', string.format("%04d",a.itemCount or 0), string.format("%07d",a.itemId or 0)
			aScore = aScore..aIL..aIT..aIST..aIEL..aQ..aN..aC
		end
		if (b and b.itemLink) then
			local bIL, bIEL, bIT, bIST, bQ, bC, bN = string.format("%04d",b.itemLevel or 0), equipLookup[b.itemEquipLoc] or '00', itemTypeLookup[b.itemType] or '00', itemTypeLookup[b.itemSubType] or '00', b.quality or '0', string.format("%04d",b.itemCount or 0), string.format("%07d",b.itemId or 0)
			bScore = bScore..bIL..bIT..bIST..bIEL..bQ..bN..bC
		end
		return aScore > bScore
	end,
	sort = function (self)
		if (self.buttonCount < #self.buttons) then
			for i = self.buttonCount+1, #self.buttons do
				self.buttons[i] = nil
			end
		end
		table.sort(self.buttons, function (a, b)
			return self:sorter(a, b)
		end)
		for i = 1, self.buttonCount do 
			local button = self.buttons[i]
			if (i == 1 ) then
				button:point('TOPLEFT', self.frame, 'TOPLEFT', 2+self.spacing, -(self.spacing+14))
			elseif i % self.columns == 1 then
				button:point('TOPLEFT', self.buttons[i-self.columns].frame, 'BOTTOMLEFT', 0, -self.spacing)
			else
				button:point('TOPLEFT', self.buttons[i-1].frame, 'TOPRIGHT', self.spacing, 0)
			end
			-- button.frame:SetParent(UIParent)
		end
		self.frame:SetHeight(math.ceil(self.buttonCount/self.columns)*(self.buttonSize+self.spacing)+self.spacing+14)
	end,
	place = function (self, button)
		self.buttonCount = self.buttonCount + 1
		self.buttons[self.buttonCount] = button
	end,
	preInit = function (self)
		self.buttonCount = 0
		self.buttons = {}
	end,
	hook = function (self)
		-- titleFrame:SetScript('OnMousedown', function (frame)
		-- 	for i = 1, self.buttonCount do
		-- 		local button = self.buttons[i]
		-- 		UseContainerItem(button.bag, button.slot)
		-- 	end
		-- end)

	end,
})