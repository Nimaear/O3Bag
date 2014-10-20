local addon, ns = ...
local O3 = O3

ns.Search = O3.UI.Panel:extend({
	offset = {0, 0, -34, nil},
	height = 32,
	bag = nil,
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

		O3.UI.EditBox:instance({
			parentFrame = self.frame,
			offset = {4, 4, 4, 4},
			onEnterPressed = function (editBox)
				self.bag:search(editBox.frame:GetText())
			end,
			onEscapePressed = function (editBox)
				self.bag:search(nil)
			end,
		})
	end,
})