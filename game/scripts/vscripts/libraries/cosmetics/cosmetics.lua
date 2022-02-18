--[[
Copyright (c) Elfansoer

RESTRICTED MODIFICATION:
Any changes outside Editable Section is prohibited.
- One Editable Section available.
- You may add/remove newlines within Editable Section.
]]

--------------------------------------------------------------------------------
-- Editable Section starts by next newline.

-- to update items reference, set UPDATE_MODE to true, fill the correct folder name of this addon, and put "items_game.txt to PATH folder".

-- Metadata:
local UPDATE_MODE = false
local PATH = "scripts/vscripts/libraries/cosmetics/"
local ADDON_FOLDER_NAME = "dota_cosmetics"

-- Requires
-- KV Parser:
if not KVParser then
	require( "scripts/vscripts/libraries/kvparser/kvparser" )
	-- wont work if no KVParser
	if not KVParser then return end
end

-- Editable Section ended by previous newline.
--------------------------------------------------------------------------------
local VERSION = "0.7.1"

--[[
=========================
=== COSMETICS LIBRARY ===
=========================
/////////////////////////////
This is a library for applying wearables to supported heroes.
1. Requirements:
	- KVParser library by Elfansoer
	- CustomNetTable with table name 'cosmetics' (optional, for hero/ability icon replacement)

2. Features:
	- Almost all wearables can be accessed and worn by default heroes
	- Wearables' ambient particles supported (mostly. see limitations)
	- Fairly easy to update
	- Lightweight (probably)
	- Javascript Queries: Enables Panorama to call this library's API to be executed on server and returned a response

3. Limitations:
	- Heroes must have "DisableWearables" "1" in their KV. This results in ugly portraits
	- Have not tested for all heroes; some may be inappropriate
	- Taunts and Pets are not supported.
	- Minimap icon replacements are not supported.
	- Hero alternate voices are not supported.
	- Ability particle & sound replacement are not supported yet.
	- Summon model replacements are not supported yet.

/////////////////////////////
How to update item reference:
- Extract "items_game.txt" from [pak_01.dir->scripts/items/]
- Copy to PATH folder
- Run in Tools Mode with UPDATE_MODE set to 'true'
- Update done when "items_game.lua" is updated. File "items_game.txt" can be deleted afterwards.
- Restart the game with UPDATE_MODE set to 'false'.

/////////////////////////////
Panorama Query
1. Send queries
Panorama can also query for API functions, which the response will be sent.
Use following JS:

	GameEvents.SendCustomGameEventToServer( "cosmetics_query", query_data );

with query_data is a table consisted of:
	int playerID: local player ID ( Players.GetLocalPlayer() )
	string query: API function name,
	array args: array of arguments. Handles such as hero units uses entindex instead.
	string ticket: [optional] Use this to differentiate between requests. Server response will include this value.

2. Server responses
To listen for responses, use this on Panorama:

	GameEvents.Subscribe( "cosmetics_query", MyFunc );

Server will response with a table containing:
	int status: returns 200 (OK) if valid, or 400 (Bad request)
	table response: the response table if status is OK
	string ticket: the ticket string given at query, if provided

/////////////////////////////
API:
STRING returnTypes:
- nil, null (JS) or '' (Default)
	- Item: itemIDs (index)
	- Slot: slot identifier
- 'simple'
	- Item: (index, name, slot, styles)
	- Slot: (name, text)
- 'full'
	- Item: (index, name, slot, styles, hero, model)
	- Slot: (name, text, index, visible)

--------------------------------------------------------------------------------
-- Finders. Find always returns array. Returns empty KV if passed params is invalid (not supported, etc.)

---[[ Cosmetics:FindSupportedHeroes  Returns an array of hero names supported by this library ])
-- @return array
function Cosmetics:FindSupportedHeroes()

---[[ Cosmetics:FindSlotsForHero  Returns an array of possible slots for a hero. ])
-- @return array
-- @param hHero handle
-- @param returnType string
function Cosmetics:FindSlotsForHero( hHero, returnType )

---[[ Cosmetics:FindWearablesByName  Returns an array of wearables with given name. hero and slot can be nil ])
-- @return array
-- @param name string
-- @param hHero handle
-- @param slot string
-- @param returnType string
function Cosmetics:FindWearablesByName( name, hHero, slot, returnType )

---[[ Cosmetics:FindWearablesByHero  Returns an array of possible itemIDs for a hero in slot (if slot is nil, returns all itemIDs for a hero) ])
-- @return array
-- @param hHero handle
-- @param slot string
-- @param returnType string
function Cosmetics:FindWearablesByHero( hHero, slot, returnType )

--------------------------------------------------------------------------------
-- Getters. Get always returns KV tables. Returns empty KV if passed params is invalid (not supported, etc.)

---[[ Cosmetics:GetSlotsForHero  Returns a KV {slot,slot_name} of slots available for hero.])
-- @return table
-- @param hHero handle
function Cosmetics:GetSlotsForHero( hHero ) end

---[[ Cosmetics:GetWearableData  Returns item information KV {itemID, (index, name, model, hero, slot, slot_name, styles, type) } ])
-- @return table
-- @param itemID int
function Cosmetics:GetWearableData( itemID )

---[[ Cosmetics:GetWearablesForHero  Returns a KV {slot,table}, with each table {itemID,returnType} contains wearables applicable for slot.
		If slot is filled, returns a KV {itemID,returnType} of all itemIDs for the hero's slot). ])
-- @return table
-- @param hHero handle
-- @param slot string
-- @param returnType string
function Cosmetics:GetWearablesForHero( hHero, slot, returnType )

--------------------------------------------------------------------------------
---[[ Cosmetics:IsHeroSupported   ])
-- @return bool
-- @param hHero handle
function Cosmetics:IsHeroSupported( hHero )

---[[ Cosmetics:IsHeroHasSlot   ])
-- @return bool
-- @param hHero handle
-- @param slot string
function Cosmetics:IsHeroHasSlot( hHero, slot )

---[[ Cosmetics:IsWearableValid   ])
-- @return bool
-- @param itemID int
function Cosmetics:IsWearableValid( itemID )

---[[ Cosmetics:IsWearableForHero   ])
-- @return bool
-- @param itemID int
-- @param hHero handle
function Cosmetics:IsWearableForHero( itemID, hHero )

--------------------------------------------------------------------------------
---[[ Cosmetics:SetDefaultWearable  Sets the hero's default wearables ])
-- @return bool
-- @param hHero handle
function Cosmetics:SetDefaultWearable( hHero )

---[[ Cosmetics:SetWearable  Style is 0-based ])
-- @return bool
-- @param hHero handle
-- @param itemID int
-- @param style int
function Cosmetics:SetWearable( hHero, itemID, style )

---[[ Cosmetics:RemoveWearable. Pass 'all' as slot to remove all wearables   ])
-- @return bool
-- @param hHero handle
-- @param slot string
function Cosmetics:RemoveWearable( hHero, slot )
--------------------------------------------------------------------------------
]]

--------------------------------------------------------------------------------
-- Class Definition
-- check if there is already another cosmetics library
if Cosmetics and Cosmetics.AUTHOR~="Elfansoer" then return end
Cosmetics = {}

Cosmetics.PATH = PATH
Cosmetics.VERSION = VERSION
Cosmetics.AUTHOR = "Elfansoer"

Cosmetics.initialized = false
Cosmetics.wearables = {}
Cosmetics.hero_wearables = {}
Cosmetics.default_wearables = {}

Cosmetics.particle_replacement = {}
Cosmetics.sound_replacement = {}
Cosmetics.icon_replacement = {}

--------------------------------------------------------------------------------
-- Function API / Queries

-- Return Types
function Cosmetics:GetReturnType( item, returnType )
	local data = {}

	-- set return type
	if returnType=='simple' then
		-- simple
		data.index = item.index
		data.name = item.name
		data.slot = item.slot
		data.styles = item.styles
	elseif returnType=='full' then
		-- full
		data.index = item.index
		data.name = item.name
		data.slot = item.slot
		data.styles = item.styles
		data.hero = item.hero
		data.model = item.model
	else
		-- default
		data = item.index
	end

	return data
end
function Cosmetics:GetSlotReturnType( slot, returnType )
	local data = {}

	-- set return type
	if returnType=='simple' then
		-- simple
		data.name = slot.name
		data.text = slot.text
	elseif returnType=='full' then
		-- full
		data.index = slot.index
		data.name = slot.name
		data.text = slot.text
		data.visible = slot.visible
	else
		-- default
		data = slot.name
	end

	return data
end

-- Finders (always return arrays)
function Cosmetics:FindSupportedHeroes()
	local ret = {}

	-- loop through names
	for name,herotable in pairs(self.hero_wearables) do
		table.insert( ret, name )
	end

	return ret
end

function Cosmetics:FindSlotsForHero( hHero, returnType )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	local hero = hHero:GetUnitName()
	local ret = {}

	if not self:IsHeroSupported( hHero ) then return ret end

	-- try get wearables for hero
	local herotable = self.slots[ hero ]

	-- loop through wearables
	for slot,slotvalue in pairs(herotable) do
		if slotvalue.visible==1 then
			table.insert( ret, self:GetSlotReturnType( slotvalue, returnType ) )
		end
	end

	-- sort by index
	local sort
	if returnType=='full' then
		sort = function(a,b)
			return a.index<b.index
		end
	elseif returnType=='simple' then
		sort = function(a,b)
			-- priority given to bundle
			if a.name=='bundle' then return true
			elseif b.name=='bundle' then return false
			else return a.name<b.name end
		end
	else
		sort = function(a,b)
			-- priority given to bundle
			if a=='bundle' then return true
			elseif b=='bundle' then return false
			else return a<b end
		end
	end
	table.sort( ret, sort )

	return ret
end

function Cosmetics:FindWearablesByName( name, hHero, slot, returnType )
	local ret = {}

	if hHero then
		if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
		if not self:IsHeroSupported( hHero ) then return ret end
		local hero = hHero:GetUnitName()

		for itemID,item_table in pairs(self.wearables) do
			-- check name
			if string.find( item_table.name, name ) then
				-- check slot
				if not (slot and item.slot~=slot) then
					local data = self:GetReturnType( item_table, returnType )
					table.insert( ret, data )
				end
			end
		end
	else
		for itemID,item_table in pairs(self.wearables) do
			-- chack name
			if string.find( item_table.name, name ) then
				local data = self:GetReturnType( item_table, returnType )
				table.insert( ret, data )
			end
		end
	end

	-- sort by index
	local sort = function(a,b)
		return a.index<b.index
	end
	if returnType=='simple' or returnType=='full' then
		table.sort( ret, sort )
	else
		table.sort( ret )
	end

	return ret
end

function Cosmetics:FindWearablesByHero( hHero, slot, returnType )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	local hero = hHero:GetUnitName()
	local ret = {}

	if not slot then
		if not self:IsHeroSupported( hHero ) then return ret end

		for slot,slot_table in pairs(self.hero_wearables[ hero ]) do
			for itemID,item_table in pairs(slot_table) do
				local data = self:GetReturnType( item_table, returnType )
				table.insert( ret, data )
			end
		end
	else
		if not self:IsHeroHasSlot( hHero, slot ) then return ret end

		for itemID,item_table in pairs(self.hero_wearables[ hero ][ slot ]) do
			local data = self:GetReturnType( item_table, returnType )
			table.insert( ret, data )
		end
	end

	-- sort by index
	local sort = function(a,b)
		return a.index<b.index
	end
	if returnType=='simple' or returnType=='full' then
		table.sort( ret, sort )
	else
		table.sort( ret )
	end

	return ret
end

-- Getters
function Cosmetics:GetSlotsForHero( hHero, returnType )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	local hero = hHero:GetUnitName()
	local ret = {}

	if not self:IsHeroSupported( hHero ) then return ret end

	-- try get wearables for hero
	local herotable = self.slots[ hero ]

	-- loop through wearables
	for slot,slotvalue in pairs(herotable) do
		if slotvalue.visible==1 then
			ret[ slot ] = self:GetSlotReturnType( slotvalue, returnType )
		end
	end

	return ret
end

function Cosmetics:GetWearableData( itemID )
	local ret = {}
	if not self:IsWearableValid( itemID ) then return ret end

	for k,v in pairs(self.wearables[ itemID ]) do
		ret[ k ] = v
	end

	-- remove visuals and other things
	ret.visuals = nil
	ret.type = nil

	return ret
end

function Cosmetics:GetWearablesForHero( hHero, slot, returnType )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	local hero = hHero:GetUnitName()
	local ret = {}

	if not slot then
		if not self:IsHeroSupported( hHero ) then return ret end

		for slot,slot_table in pairs(self.hero_wearables[ hero ]) do
			-- check if it should be visible
			if self.slots[ hero ][ slot ].visible==1 then
				local slot_data = {}
				for itemID,item_table in pairs(slot_table) do
					local data = self:GetReturnType( item_table, returnType )
					slot_data[ itemID ] = data
				end
				ret[ slot ] = slot_data
			end
		end
	else
		if not self:IsHeroHasSlot( hHero, slot ) then return ret end

		for itemID,item_table in pairs(self.hero_wearables[ hero ][ slot ]) do
			local data = self:GetReturnType( item_table, returnType )
			ret[ itemID ] = data
		end
	end

	return ret
end

function Cosmetics:GetEquippedWearables( hHero )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end

	local modifier = hHero:FindModifierByName( "modifier_cosmetics" )
	if not modifier then return {} end

	return modifier:GetEquippedWearables()
end

-- Boolean Status (returns boolean)
function Cosmetics:IsHeroHasEquippedWearables( hHero, itemID )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end

	local modifier = hHero:FindModifierByName( "modifier_cosmetics" )
	if not modifier then return false end

	if not itemID then
		return true
	end

	local items = modifier:GetEquippedWearables()
	for k,v in pairs(items) do
		if v==itemID then
			return true
		end
	end

	return false
end

function Cosmetics:IsHeroHasSlot( hHero, slot )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	local hero = hHero:GetUnitName()
	if not self:IsHeroSupported( hHero ) then return false end
	if not slot then return false end
	return self.hero_wearables[ hero ][ slot ]~=nil
end

function Cosmetics:IsHeroSupported( hHero )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	local hero = hHero:GetUnitName()
	return self.hero_wearables[ hero ] ~= nil
end

function Cosmetics:IsWearableValid( itemID )
	return self.wearables[ itemID ]~=nil
end

function Cosmetics:IsWearableForHero( itemID, hHero )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	local hero = hHero:GetUnitName()
	if not self:IsWearableValid( itemID ) then return false end
	if not self:IsHeroSupported( hHero ) then return end

	return self.wearables[ itemID ].hero == hero
end

-- Methods (boolean)
function Cosmetics:SetDefaultWearable( hHero )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	if not self:IsHeroSupported( hHero ) then return false end
	hHero:AddNewModifier(
		hHero, -- player source
		nil, -- ability source
		"modifier_cosmetics", -- modifier name
		{} -- kv
	)

	return true
end

function Cosmetics:SetWearable( hHero, itemID, style )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	if not self:IsWearableForHero( itemID, hHero ) then return false end
	local sstyle = style or 0
	hHero:AddNewModifier(
		hHero, -- player source
		nil, -- ability source
		"modifier_cosmetics", -- modifier name
		{
			query = "add",
			itemID = itemID,
			style = sstyle,
		} -- kv
	)
	return true
end

function Cosmetics:RemoveWearable( hHero, slot )
	if type(hHero)=='number' then hHero = EntIndexToHScript( hHero ) end
	if slot~="all" then
		if not self:IsHeroHasSlot( hHero, slot ) then return false end
	end
	hHero:AddNewModifier(
		hHero, -- player source
		nil, -- ability source
		"modifier_cosmetics", -- modifier name
		{
			query = "remove",
			slot = slot,
		} -- kv
	)

	return true
end

--------------------------------------------------------------------------------
-- Javascript Queries
Cosmetics.api = {
	["FindSupportedHeroes"] = true,
	["FindSlotsForHero"] = true,
	["FindWearablesByName"] = true,
	["FindWearablesByHero"] = true,
	["GetSlotsForHero"] = true,
	["GetWearableData"] = true,
	["GetWearablesForHero"] = true,
	["IsHeroSupported"] = true,
	["IsHeroHasSlot"] = true,
	["IsWearableValid"] = true,
	["IsWearableForHero"] = true,
	["SetDefaultWearable"] = true,
	["SetWearable"] = true,
	["RemoveWearable"] = true,
}
function Cosmetics.ClientQuery( playerID, data )
	-- apparently playerID is not accurately represent the local player ID
	local player = PlayerResource:GetPlayer( tonumber(data.playerID) )
	local ret = {}

	-- return ticket id if available
	ret.ticket = data.ticket

	-- check query
	if not data.query or not data.args then
		-- bad request
		print("Missing query or missing args")
		ret.status = 400
		ret.response = {}
	elseif not Cosmetics.api[ data.query ] then
		-- unavailable
		print("No such function")
		ret.status = 400
		ret.response = {}
	else
		-- get query function
		local f = Cosmetics[data.query]

		-- do query
		local status, err = pcall( function()
			ret.response = f( Cosmetics, Cosmetics.ConvertArgs( data.args ) )
			ret.status = 200
		end)
		if not status then
			-- wrong parameter
			print("Fail to call query function:",err)
			ret.status = 400
			ret.response = {}
		end
	end

	-- send response
	CustomGameEventManager:Send_ServerToPlayer( player, "cosmetics_query", ret )
end

function Cosmetics.ConvertArgs( data )
	-- create lua args from js args
	local args = {}

	-- js args starts from 0, and written as string
	local i = 0
	while true do
		local temp = data[ tostring(i) ]
		if not temp then break end

		-- if empty table, it is nil
		if type(temp)=='table' and next(temp) == nil then
			temp = nil
		end

		-- lua args is 1 based, as numbers if possible
		args[ i+1 ] = tonumber(temp) or temp
		i = i+1
	end

	-- because unpack does not allow nil in the middle, use unload
	local argsize = i
	local function unload( args, size, i )
		if not i then i = 1 end
		if i>=size then
			return args[i]
		else
			return args[i], unload( args, size, i+1 )
		end
	end
	return unload( args, argsize )
end

--------------------------------------------------------------------------------
-- Icon and particle replacements database
function Cosmetics:AddIconReplacement( hHero, asset, modifier )
	-- create kv
	local id = hHero:entindex()
	local key = tostring(id) .. ' ' .. asset
	local value = modifier

	-- update nettables
	CustomNetTables:SetTableValue( "cosmetics", key, { value = value } )

	return key
end

-- NOTE: May be called on client
function Cosmetics:GetIconReplacement( hHero, asset )
	-- create kv
	local id = hHero:entindex()
	local key = tostring(id) .. ' ' .. asset
	local value = modifier

	-- get nettables value
	local value = CustomNetTables:GetTableValue( "cosmetics", key )
	if not value then return asset end

	local ret = value.value
	if not ret then return asset end

	return ret
end

function Cosmetics:RemoveIconReplacement( key )
	-- update nettables
	CustomNetTables:SetTableValue( "cosmetics", key, {} )
end

function Cosmetics:AddParticleReplacement( hHero, asset, modifier )
	local data = self.particle_replacement[ hHero ]
	if not data then
		data = {}
		self.particle_replacement[ hHero ] = data
	end
	data[ asset ] = modifier
end

function Cosmetics:RemoveParticleReplacement( hHero, asset )
	local data = self.particle_replacement[ hHero ]
	if not data then return end
	data[ asset ] = nil

	-- delete if empty
	if not next(data) then
		self.particle_replacement[ hHero ] = nil
	end
end

function Cosmetics:GetParticleReplacement( hHero, name )
	local data = self.particle_replacement[ hHero ]
	if not data then
		return name
	end
	if not data[ name ] then
		return name
	end

	return data[ name ]
end

function Cosmetics:AddSoundReplacement( hHero, asset, modifier )
	local data = self.sound_replacement[ hHero ]
	if not data then
		data = {}
		self.sound_replacement[ hHero ] = data
	end
	data[ asset ] = modifier
end

function Cosmetics:RemoveSoundReplacement( hHero, asset )
	local data = self.sound_replacement[ hHero ]
	if not data then return end
	data[ asset ] = nil

	-- delete if empty
	if not next(data) then
		self.sound_replacement[ hHero ] = nil
	end
end

function Cosmetics:GetSoundReplacement( hHero, name )
	local data = self.sound_replacement[ hHero ]
	if not data then
		return name
	end
	if not data[ name ] then
		return name
	end

	return data[ name ]
end

-- Legacy
-- function Cosmetics:GetParticleReplacement( particle )
-- 	return self.particle_replacement[ particle ] or particle
-- end

-- function Cosmetics:GetIconReplacement( icon )
-- 	if not IsServer() then
-- 		local replace = CustomNetTables:GetTableValue( "cosmetics", icon )
-- 		if replace and replace.v then return replace.v end
-- 		return icon
-- 	end
-- 	return self.icon_replacement[ icon ] or icon
-- end

function Cosmetics:SetParticleReplacement( original, replacement )
	self.particle_replacement[ original ] = replacement
end

function Cosmetics:SetIconReplacement( original, replacement )
	self.icon_replacement[ original ] = replacement
	CustomNetTables:SetTableValue( "cosmetics", original, { v = replacement } )
end

function Cosmetics:ClearParticleReplacement( original )
	self.particle_replacement[ original ] = replacement
end

function Cosmetics:ClearIconReplacement( original )
	self.icon_replacement[ original ] = nil
	CustomNetTables:SetTableValue( "cosmetics", original, {} )
end

--------------------------------------------------------------------------------
-- Init Cosmetics
function Cosmetics:Init()
	-- load KV data
	local stored_data = KVParser:LoadKeyValueFromRequire( self.PATH .. "items_game" )
	if not stored_data then
		print('... failed. This might occur if "items_game.lua" is missing from the PATH folder.')
		print('Try run update mode first.')
		print('Aborting.')
		return false
	end

	-- create wearables, then index table based on hero and slot
	self.wearables = stored_data.wearables
	self.hero_wearables = self:CreateHeroIndex()

	-- build slots
	self.slots = stored_data.slots
	self:FixHeroSlots()

	self:CreateDefaultIndex()

	-- Link Lua modifier
	local path = string.gsub( self.PATH, "scripts/vscripts/", "" )
	LinkLuaModifier( "modifier_cosmetics", path .. "modifier_cosmetics", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_cosmetics_model", path .. "modifier_cosmetics_model", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_cosmetics_activity", path .. "modifier_cosmetics_activity", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_cosmetics_wearables", path .. "modifier_cosmetics_wearables", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier( "modifier_cosmetics_animation", path .. "modifier_cosmetics_animation", LUA_MODIFIER_MOTION_NONE )

	LinkLuaModifier( "modifier_cosmetics_color_gem", path .. "modifier_cosmetics_color_gem", LUA_MODIFIER_MOTION_NONE )

	-- Init color gem support
	self.color_gem_particles = require( self.PATH .. "color_gem_support" )

	if IsServer() then
		-- register query
		CustomGameEventManager:RegisterListener( "cosmetics_query", self.ClientQuery )
	end

	-- Initialized
	self.initialized = true

	return true
end

--------------------------------------------------------------------------------
-- Indexing
function Cosmetics:CreateHeroIndex()
	-- init table
	local heroes = {}

	for id,item in pairs( self.wearables ) do

		-- get hero index table
		if not heroes[ item.hero ] then
			heroes[ item.hero ] = {}
		end
		local data = heroes[ item.hero ]

		-- get slot
		if not data[ item.slot ] then
			data[ item.slot ] = {}
		end
		local slots = data[ item.slot ]

		-- register data
		slots[id] = item
	end

	return heroes
end

Cosmetics.slot_blacklist = {
	["shoulder_persona_1"] = true,
	["arms_persona_1"] = true,
	["head_persona_1"] = true,
	["back_persona_1"] = true,
	["summon_persona_1"] = true,
	["armor_persona_1"] = true,
	["taunt_persona_1"] = true,
}
function Cosmetics:FixHeroSlots()
	-- fix hero scales
	for id,item in pairs( self.wearables ) do
		if item.visuals then
			for asset,assettable in pairs(item.visuals) do
				if type(assettable)=='table' and assettable.type=='entity_scale' then

					-- get original entity scale
					local data = self.slots[ assettable.asset ]
					if data then
						-- recalculate the scale
						assettable.scale_size = tonumber(assettable.scale_size)/tonumber(data.model_scale)
					end

				end
			end
		end
	end

	-- move 'slots' to root
	for name,value in pairs(self.slots) do
		-- move 'slots' to root
		for k,v in pairs(value.slots) do
			value[k] = v
		end

		-- delete slots
		value.slots = nil

		-- delete model_scale
		value.model_scale = nil
	end

	-- fix hero slots for missing keys
	for hero,heroslots in pairs(self.slots) do
		-- check if each of them is available on hero_wearables
		for slot,slotvalue in pairs(heroslots) do
			-- check if it is available
			if not self.hero_wearables[ hero ][ slot ] then
				-- delete
				heroslots[ slot ] = nil
			end

			-- check if it is under blacklist
			if self.slot_blacklist[ slot ] then
				slotvalue.visible = 0
			end
		end

		-- check if hero_wearables has something that slots don't
		for slot,slotvalue in pairs(self.hero_wearables[hero]) do
			-- check if it is available
			if not heroslots[ slot ] then
				-- create new key, but with visible to 0
				local data = {}
				data.index = -1
				data.visible = 0
				data.name = slot
				data.text = "Unknown"

				-- if bundle, change it
				if slot=='bundle' then
					data.visible = 1
					data.text = "Bundle"
				end

				heroslots[ slot ] = data
			end
		end
	end
end

function Cosmetics:CreateDefaultIndex()
	local defaults = {}

	for id,item in pairs( self.wearables ) do
		if item.type=="default_item" then
			-- get index
			if not defaults[ item.hero ] then
				defaults[ item.hero ] = {}
			end

			local data = defaults[ item.hero ]

			data[ item.slot ] = id
		end
	end

	self.default_wearables = defaults
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------
-- Update Cosmetics
function Cosmetics:Update()
	local folder_path = "../../dota_addons/" .. ADDON_FOLDER_NAME .. "/" .. self.PATH

	-- open file
	print( 'Opening "items_game.txt" for read...' )
	local file,err = io.open( folder_path .. "items_game.txt", "r" )
	if not file then
		print('Error opening "items_game.txt": ' .. err )
		return false
	end

	-- load KV into table
	print( 'Loading "items_game.txt"...' )
	local items_game = KVParser:LoadKeyValueFromOpenFile( file, KVParser.MODE_UNIQUE )
	file:close()

	-- Create wearable list from original KV (which full of irrelevant stuff)
	print( "Indexing..." )
	local wearables = self:CreateWearablesTable( items_game )

	-- prepare printing to file
	local newtable = {}
	newtable["wearables"] = wearables
	newtable["slots"] = self:BuildSlots()

	-- open file to write
	print( 'Opening "items_game.lua" for write...' )
	file, err = io.open( folder_path .. "items_game.lua", "w" )
	if not file then
		print('Error opening "items_game.lua": ' .. err )
		return false
	end

	-- writing file
	print('writing to "items_game.lua"...')
	file:write( "-- Elfansoer's Cosmetics Library, Simplified Item References.\n" )
	file:write( "-- Generated on " .. GetSystemDate() .. ".\n" )
	file:write( "return [[\n" )
	KVParser:PrintToFile( newtable, file )
	file:write( "]]\n" )
	file:close()
end

-- reduce original items_game kv into compacted version
function Cosmetics:CreateWearablesTable( items_game )
	-- get only relevant KV (others such as Item price and stuff are not included)
	local items = items_game.items_game.items
	local attachments = items_game.items_game.attribute_controlled_attached_particles
	local attachIndex = self:BuildAttachmentsIndex( attachments )

	-- init table
	local wearables = {}
	local name_index = {}
	local bundles = {}

	for id,item in pairs(items) do
		-- only type wearable and default_item
		local filter1 = false
		if item.prefab=="wearable" or item.prefab=="default_item" then
			filter1 = true
		end

		-- only obtain those who have hero name
		local filter2 = false
		if type(item.used_by_heroes)=="table" then
			filter2 = true
		end

		if filter1 and filter2 then
			-- check hero
			local item_hero = nil
			local temp = item.used_by_heroes
			for k,v in pairs(temp) do
				item_hero = k
			end

			-- collect relevant data
			local data = {}
			data.index = id
			data.name = item.name or "#DOTA_Wearable_Sven_DefaultSword"
			data.hero = item_hero or "no_hero"
			data.type = item.prefab or "no_prefab"
			data.slot = item.item_slot or "weapon"
			data.model = item.model_player or ""
			data.visuals = item.visuals

			-- connect visuals and attachments
			self:ConnectVisualsAttachment( data, attachments, attachIndex )

			-- determine styles
			data.styles = self:CalculateStyles( data )

			-- register
			if tonumber( id ) then
				wearables[tonumber( id )] = data
			else
				wearables[ id ] = data
			end

			-- build name index
			name_index[ item.name ] = data

		elseif item.prefab=="bundle" and filter2 then
			-- check hero
			local item_hero = nil
			local temp = item.used_by_heroes
			for k,v in pairs(temp) do
				item_hero = k
			end

			-- collect relevant data
			local data = {}
			data.index = id
			data.name = item.name or "#DOTA_Wearable_Sven_DefaultSword"
			data.hero = item_hero or "no_hero"
			data.type = item.prefab or "no_prefab"
			data.slot = "bundle"
			data.bundle = item.bundle

			-- register
			if tonumber( id ) then
				wearables[tonumber( id )] = data
			else
				wearables[ id ] = data
			end

			-- build bundle index
			if tonumber( id ) then
				bundles[tonumber( id )] = data
			else
				bundles[ id ] = data
			end
		end
	end

	-- connect bundles index
	self:ConnectBundlesIndex( bundles, name_index )

	return wearables
end

function Cosmetics:BuildAttachmentsIndex( attachments )
	local ret = {}
	for id,valuetable in pairs(attachments) do
		local particle = valuetable.system
		if particle then
			ret[particle] = id
		end
	end

	return ret
end

function Cosmetics:ConnectVisualsAttachment( data, attachTable, attachIndex )
	if not data.visuals then return end

	-- traverse through visuals
	for asset,assetTable in pairs(data.visuals) do

		-- get asset type
		local asset_type
		if type(assetTable)=="table" then
			asset_type = assetTable.type
		end

		-- check if type particle/particle_create
		if asset_type=="particle" or asset_type=="particle_create" then
			-- get particle name
			local particle = assetTable.modifier
			-- check attachment
			local attachID = attachIndex[particle]
			if attachID then
				-- connect attachment to visual
				assetTable.attachments = attachTable[attachID]
				assetTable.attachments.system = nil
			end
		end
	end
end

function Cosmetics:CalculateStyles( data )
	local styles = 1

	if data.visuals and data.visuals.styles then
		styles = 0
		for k,v in pairs(data.visuals.styles) do
			styles = styles + 1
		end
	end

	return styles
end

function Cosmetics:ConnectBundlesIndex( bundles, name_index )
	for id,item in pairs(bundles) do
		local data = {}
		local styles = 1
		for name,_ in pairs(item.bundle) do
			local set_item = name_index[ name ]
			
			if set_item then
				-- get itemID
				data[ set_item.index ] = 1

				-- add data to wearable
				set_item.bundle = id

				if set_item.styles>styles then
					styles = set_item.styles
				end
			end
		end

		-- replace name with itemIDs
		item.bundle = data
		item.styles = styles
	end
end

function Cosmetics:BuildSlots()
	-- load 'npc_heroes.txt'
	local npc_heroes = LoadKeyValues( "scripts/npc/npc_heroes.txt" )

	local heroes_data = {}
	for name,valuetable in pairs(npc_heroes) do
		-- only those who has item slots
		if type(valuetable)=='table' and valuetable.ItemSlots then

			local data = {}

			-- get slots
			local slot_data = {}
			for _,slottable in pairs(valuetable.ItemSlots) do
				local temp = {}
				temp.index = tonumber(slottable.SlotIndex)
				temp.name = slottable.SlotName
				temp.text = slottable.SlotText
				temp.visible = tonumber(slottable.DisplayInLoadout) or 1

				-- register
				slot_data[ temp.name ] = temp
			end
			data.slots = slot_data

			-- get model scale
			data.model_scale = tonumber(valuetable.ModelScale) or 1

			-- store
			heroes_data[ name ] = data
		end
	end

	return heroes_data
end
--------------------------------------------------------------------------------
-- Instantiating Class
if UPDATE_MODE then
	if not IsInToolsMode() then
		print("UPDATE MODE: Can only update in Tools mode")
	elseif IsServer() then
		print("Updating Cosmetics...")
		if Cosmetics:Update() then
			print( "...update cosmetics done" )
		end
	end
end

local code = "server"
if IsClient() then code = "client" end

print( "Loading Cosmetics in " .. code .. " ..." )
if Cosmetics:Init() then
	print( "...done" )
end