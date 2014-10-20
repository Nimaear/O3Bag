local addon, ns = ...

local O3 = O3
local tableInsert = table.insert
local stringGsub = string.gsub
local GetTime = GetTime




local handler = O3:module({
	name = 'Inventory',
	readable = 'Inventory',
	bags = {},
	bagDict = {},
	events = {
		PLAYER_ENTERING_WORLD = true,
	},
	config = {
		enabled = true,
	},
	settings = {

	},
	bagDropdown = {
		{ label = 'Screen', value = 'Screen'},
	},
	anchorLookup = {
		Screen = UIParent
	},	
	addOptions = function (self)
		self:addOption('_1', {
			type = 'Title',
			label = 'General',
		})
	end,
	anchorSet = function (self, token, value, option)
		O3:safe(function ()
			option.bag:show()
			option.bag:anchor()
		end)
	end,	
	addBag = function (self, bag)
		bag.handler = self
		tableInsert(self.bags, bag)
		self.anchorLookup[bag.name] = bag.frame
		table.insert(self.bagDropdown, { label = bag.name, value = bag.name})
		if (bag.id) then
			self.bagDict[bag.id] = bag
		end
	end,
	PLAYER_ENTERING_WORLD = function (self)
		for i = 1, #self.bags do
			local bag = self.bags[i]
			bag:register(self)
		end
		self:unregisterEvent('PLAYER_ENTERING_WORLD')
	end,	

	setup = function (self)
		self.panel = self.O3.UI.Panel:instance({
			name = self.name
		})	
		self.frame = self.panel.frame
		self:initEventHandler()
		
	end,
})
--handler:addBar(test)


ns.Handler = handler