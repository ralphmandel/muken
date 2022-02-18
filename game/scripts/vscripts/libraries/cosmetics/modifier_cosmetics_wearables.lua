--[[
Copyright (c) Elfansoer

RESTRICTED MODIFICATION:
Any changes outside Editable Section is prohibited.
- There is no Editable Section in this file.
]]
--------------------------------------------------------------------------------
modifier_cosmetics_wearables = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_cosmetics_wearables:IsHidden()
	return true
end

function modifier_cosmetics_wearables:IsPurgable()
	return false
end

function modifier_cosmetics_wearables:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_cosmetics_wearables:OnCreated( kv )
	-- get data
	self.parent = self:GetParent()
	self.owner = self:GetCaster()	
	-- self.owner = EntIndexToHScript( kv.owner )

	-- tags
	self.tag_invisible = false
	self.tag_illusion = false
	self.tag_hide = {}

	if not IsServer() then return end
	-- get data
	local item = Cosmetics.wearables[ kv.itemID ]
	self.itemID = kv.itemID
	self.style = kv.style or 0
	if self.style>=item.styles then
		self.styles = 0
	end

	-- list of modifiers
	self.effects = {}
	self.activity_modifiers = {}
	self.replaced_effects = {}
	self.replaced_icons = {}
	self.replaced_sounds = {}

	-- set model
	self.parent:SetModel( item.model )
	self.parent:SetOriginalModel( item.model ) -- if this is not set, the model reverts when modifier added

	-- set following parent
	self.parent:FollowEntity( self.owner, true )

	-- -- start gesture
	-- self.parent:StartGesture( ACT_DOTA_IDLE )
	self.animation = self.parent:AddNewModifier(
		self.owner, -- player source
		self:GetAbility(), -- ability source
		"modifier_cosmetics_animation", -- modifier name
		{} -- kv
	)

	-- get visual handle
	local visuals = item.visuals
	if not visuals then 
		-- Check special behaviors
		self:SpecialBehaviors()
		return
	end

	if visuals.styles then
		self:TraverseStyles( visuals.styles )
	end

	-- create ambient
	self:TraverseVisuals( visuals )

	-- Check special behaviors
	self:SpecialBehaviors()

	-- manage Color Gem
	self:RegisterColorGem()
end

function modifier_cosmetics_wearables:OnRefresh( kv )
end

function modifier_cosmetics_wearables:OnRemoved()
end

function modifier_cosmetics_wearables:OnDestroy()
	if not IsServer() then return end
	-- revert skin
	-- TODO: Check multiple skin change
	if self.model_skin_enabled then
		self.owner:SetSkin( 0 )
	end

	-- destroy activity modifier
	for _,modifier in pairs(self.activity_modifiers) do
		if modifier and (not modifier:IsNull()) then
			modifier:Destroy()
		end
	end

	-- destroy model modifier
	if self.model_modifier and (not self.model_modifier:IsNull()) then
		self.model_modifier:Destroy()
	end

	-- destroy animation
	if self.animation and (not self.animation:IsNull()) then
		self.animation:Destroy()
	end

	-- clear replaced effects
	for ori,rep in pairs(self.replaced_effects) do
		Cosmetics:RemoveParticleReplacement( self.owner, ori )
	end

	-- clear replaced effects
	for ori,rep in pairs(self.replaced_sounds) do
		Cosmetics:RemoveSoundReplacement( self.owner, ori )
	end

	-- clear replaced icons
	for key,_ in pairs(self.replaced_icons) do
		Cosmetics:RemoveIconReplacement( key )
	end

	self:UnregisterColorGem()

	-- self destroy
	UTIL_Remove( self.parent )
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_cosmetics_wearables:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_MODEL_CHANGED,
	}

	return funcs
end

function modifier_cosmetics_wearables:GetModifierInvisibilityLevel( params )
	if self.owner:IsInvisible() then
		return 1
	else
		return 0
	end
end

function modifier_cosmetics_wearables:OnModelChanged( params )
	if not IsServer() then return end
	if params.attacker~=self.owner then return end
	

	if not self.owner.model_change_notify then
		if self.tag_hide.model_change then
			self.tag_hide.model_change = nil
		else
			self.tag_hide.model_change = true
		end
	end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_cosmetics_wearables:Delay( time, func )
	self.IntervalCallback = func or function() end
	self:StartIntervalThink( time )
end

function modifier_cosmetics_wearables:OnIntervalThink()
	self:StartIntervalThink( -1 )
	self.IntervalCallback()
	self.IntervalCallback = nil
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_cosmetics_wearables:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_UNSLOWABLE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
	}

	--nodraw effect
	if IsServer() then
		if self.owner:IsOutOfGame() then
			self.tag_hide.outofgame = true
		else
			self.tag_hide.outofgame = nil
		end

		-- check if tag_hide is not empty
		local hide = not (next(self.tag_hide)==nil)

		if hide then
			self.parent:AddNoDraw()
		else
			self.parent:RemoveNoDraw()
		end
	end

	return state
end

--------------------------------------------------------------------------------
-- Helper
function modifier_cosmetics_wearables:TraverseStyles( styles )
	local item = Cosmetics.wearables[ self.itemID ]

	local style_table = styles[ self.style ]

	if not style_table then
		-- check size
		local size = 0
		for k,v in pairs(styles) do
			size = size+1
		end

		if self.style>=size then
			self.style = size-1
			style_table = styles[ self.style ]
		end
	end

	-- set model
	if style_table.model_player then
		self.parent:SetModel( style_table.model_player )
		self.parent:SetOriginalModel( style_table.model_player ) -- if this is not set, the model reverts when modifier added
	end

	-- set skin
	if style_table.skin then
		self:Delay( FrameTime(), function()
			self.parent:SetSkin( tonumber(style_table.skin) )
		end)
	end
end

function modifier_cosmetics_wearables:TraverseVisuals( visuals )
	local cps = {}

	-- traverse visuals
	for asset,asset_value in pairs( visuals ) do
		-- check for "skin" modifiers
		if asset=="skin" then
			self.parent:SetSkin( tonumber( asset_value ) )
		end

		-- check style
		local wrong_style = false
		if type(asset_value)=="table" and asset_value.style then
			if self.style~=tonumber( asset_value.style ) then
				wrong_style = true
			end
		end

		-- check for asset modifiers and appropriate style
		if type(asset_value)=="table" and (not wrong_style) then

			-- has activity modifier
			if asset_value.type=="activity" then
				local activity_modifier = self.owner:AddNewModifier(
					self.parent, -- player source
					self:GetAbility(), -- ability source
					"modifier_cosmetics_activity", -- modifier name
					{
						activity = asset_value.modifier,
					} -- kv
				)
				table.insert( self.activity_modifiers, activity_modifier )

			-- has hero model change
			elseif asset_value.type=="entity_model" then
				-- notify that this model change is internal
				self.owner.model_change_notify = true

				-- check if it is the hero's model
				if asset_value.asset==self.owner:GetUnitName() then
					-- add model change modifier
					self.model_modifier = self.owner:AddNewModifier(
						self.owner, -- player source
						self:GetAbility(), -- ability source
						"modifier_cosmetics_model", -- modifier name
						{
							model = asset_value.modifier,
						} -- kv
					)
				end

				-- internal model change tag ended
				self.owner.model_change_notify = false

			-- has ambient particle
			elseif asset_value.type=="particle_create" then
				-- if it has 'spawn_in_loadout_only' '1' then skip
				local filter1 = not (asset_value.spawn_in_loadout_only and asset_value.spawn_in_loadout_only==1)
				local filter2 = not (asset_value.spawn_in_alternate_loadout_only and asset_value.spawn_in_alternate_loadout_only==1)

				if filter1 and filter2 then
					-- create particle
					self:PlayAmbient( asset_value )
				end

			-- has hero model skin change
			elseif asset_value.type=="model_skin" then
				-- self:Delay( FrameTime(), function()
					-- set owner skin
					self.owner:SetSkin( tonumber(asset_value.skin) )
					self.model_skin_enabled = true
				-- end)

			-- has ability icon replacement
			elseif asset_value.type=="ability_icon" then
				-- Replace icons
				local key = Cosmetics:AddIconReplacement( self.owner, asset_value.asset, asset_value.modifier )
				self.replaced_icons[ key ] = true

			-- has topbar hero icon replacement
			elseif asset_value.type=="icon_replacement_hero" then
				-- Replace icons
				local key = Cosmetics:AddIconReplacement( self.owner, "hero", asset_value.modifier )
				self.replaced_icons[ key ] = true

			-- has particle replacement
			elseif asset_value.type=="particle" then
				-- replace effects
				self.replaced_effects[ asset_value.asset ] = asset_value.modifier
				Cosmetics:AddParticleReplacement( self.owner, asset_value.asset, asset_value.modifier )

			-- has sound replacement
			elseif asset_value.type=="sound" then
				-- replace sounds
				self.replaced_sounds[ asset_value.asset ] = asset_value.modifier
				Cosmetics:AddSoundReplacement( self.owner, asset_value.asset, asset_value.modifier )

			-- has control point reposition
			elseif asset_value.type=="particle_control_point" then
				-- store cp
				table.insert( cps, asset_value )
			end
		end
	end

	-- replace control points
	for _,asset_value in pairs(cps) do
		local effect_cast = self.effects[ asset_value.asset ]
		if effect_cast then
			-- get cp
			local cp = tonumber(asset_value.control_point_number)

			-- cet cp value
			local vec = {}
			for val in asset_value.cp_position:gmatch("%w+") do table.insert(vec, tonumber(val)) end

			-- set cp
			ParticleManager:SetParticleControl( effect_cast, cp, Vector( vec[1], vec[2], vec[3] ) )
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
modifier_cosmetics_wearables.attach_reference = {
	["absorigin"] = PATTACH_ABSORIGIN,
	["absorigin_follow"] = PATTACH_ABSORIGIN_FOLLOW,
	["customorigin"] = PATTACH_CUSTOMORIGIN,
	["customorigin_follow"] = PATTACH_CUSTOMORIGIN_FOLLOW,
	["EYES_FOLLOW"] = PATTACH_EYES_FOLLOW,
	["point_follow"] = PATTACH_POINT_FOLLOW,
	["renderorigin_follow"] = PATTACH_RENDERORIGIN_FOLLOW,
	["worldorigin"] = PATTACH_WORLDORIGIN,
	-- ["CENTER_FOLLOW"] = PATTACH_CENTER_FOLLOW,
	-- ["CUSTOM_GAME_STATE_1"] = PATTACH_CUSTOM_GAME_STATE_1,
	-- ["MAIN_VIEW"] = PATTACH_MAIN_VIEW,
	-- ["OVERHEAD_FOLLOW"] = PATTACH_OVERHEAD_FOLLOW,
	-- ["POINT"] = PATTACH_POINT,
	-- ["ROOTBONE_FOLLOW"] = PATTACH_ROOTBONE_FOLLOW,
	-- ["WATERWAKE"] = PATTACH_WATERWAKE,
}

function modifier_cosmetics_wearables:PlayAmbient( asset_table )
	-- check simple visual table
	if not asset_table.attachments then
		self:PlayAmbientBasic( asset_table )
		return
	end

	local attachments = asset_table.attachments

	-- Get Resources
	local particle_cast = asset_table.modifier or ""
	local particle_attach = self.attach_reference[ attachments.attach_type ] or PATTACH_ABSORIGIN_FOLLOW
	local particle_parent
	if attachments.attach_entity=="self" then
		particle_parent = self.parent
	elseif attachments.attach_entity=="parent" then
		particle_parent = self.owner
	else
		particle_parent = self.parent
	end

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, particle_attach, particle_parent )

	-- Control Points
	if attachments.control_points then
		for number,cp_data in pairs(attachments.control_points) do
			-- get cp
			local index = tonumber(cp_data.control_point_index) or tonumber( number )

			-- get data
			local attach_type = self.attach_reference[ cp_data.attach_type ]
			local attach_name = cp_data.attachment

			-- set CP
			ParticleManager:SetParticleControlEnt(
				effect_cast,
				index,
				particle_parent,
				attach_type,
				attach_name,
				Vector(0,0,0), -- unknown
				true -- unknown, true
			)
		end
	end

	-- default color (So far only TB arcana uses this)
	if attachments.default_color then
		local color = attachments.default_color
		ParticleManager:SetParticleControl( effect_cast, 15, Vector( tonumber( color.r ), tonumber( color.g ), tonumber( color.b ) ) )
		ParticleManager:SetParticleControl( effect_cast, 16, Vector( 1,0,0 ) )
	end

	-- add to buff
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- register effect
	self.effects[ particle_cast ] = effect_cast
end

function modifier_cosmetics_wearables:PlayAmbientBasic( asset_table )
	-- Get Resources
	local particle_cast = asset_table.modifier

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

	-- add to buff
	self:AddParticle(
		effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	-- register effect
	self.effects[ particle_cast ] = effect_cast
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function modifier_cosmetics_wearables:RegisterColorGem()
	-- check color gem support
	if Cosmetics.color_gem_particles[ self.itemID ]==nil then return end

	-- get color gem modifier
	local modifier = self.owner:FindModifierByName( "modifier_cosmetics_color_gem" )
	if not modifier then return end

	-- register to modifier
	modifier:RegisterEffects( self, true )

	self.color_gem_modifier = modifier
	-- local color = modifier:GetColorAsTable()
	-- ParticleManager:SetParticleControl( effect_cast, 15, Vector( color.r, color.g, color.b ) )
	-- ParticleManager:SetParticleControl( effect_cast, 16, Vector( 1,0,0 ) )
end

function modifier_cosmetics_wearables:UnregisterColorGem()
	local modifier = self.color_gem_modifier
	if modifier and not modifier:IsNull() then
		modifier:UnregisterEffects( self )
	end
end

--------------------------------------------------------------------------------
-- Special Behaviors
function modifier_cosmetics_wearables:SpecialBehaviors()
	-- hero specials
	local f = self.SpecialBehaviorList[ self.owner:GetUnitName() ]
	if f then f( self ) end

	-- item specials
	f = self.SpecialBehaviorList[ self.itemID ]
	if f then f( self ) end
end

modifier_cosmetics_wearables.SpecialBehaviorList = {

-- Hero behaviors
["npc_dota_hero_grimstroke"] = function( self )
	local item = Cosmetics.wearables[ self.itemID ]
	
	--fix weapon particles
	local effect_cast = self.effects[ "particles/units/heroes/hero_grimstroke/grimstroke_brush_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_brush_tip',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Arcana Specials
-- Manifold Paradox
[7247] = function( self )
	--fix weapon particles
	local item = Cosmetics.wearables[ self.itemID ]
	local cp = item.visuals

	local particle_cast = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_blade_ambient_a.vpcf"
	local effect_cast = self.effects[ particle_cast ]
	if effect_cast then
		-- set CP based on style

	end
end,

-- Bladeform Legacy
[9059] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_v2_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_head',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
	effect_cast = self.effects[ "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_head',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Benevolent Companion
[9235] = function( self )
	local item = Cosmetics.wearables[ self.itemID ]

	-- self.parent:FollowEntity( self.owner, false )

	-- -- set model back to invisible box
	-- local model = "models/development/invisiblebox.vmdl"
	-- self.parent:SetModel( model )
	-- self.parent:SetOriginalModel( model )

	-- -- set parent's model to item's model
	-- self.model_modifier = self.owner:AddNewModifier(
	-- 	self.owner, -- player source
	-- 	self:GetAbility(), -- ability source
	-- 	"modifier_cosmetics_model", -- modifier name
	-- 	{
	-- 		model = item.model,
	-- 	} -- kv
	-- )
end,

-- Wearable behaviors

-- Alluvion Prophecy
[9232] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/oracle/oracle_fortune_ti7/oracle_fortune_ti7_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			2,
			self.owner,
			PATTACH_POINT_FOLLOW,
			'attach_attack1',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Maw of Eztzhok
[9241] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_ambient.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_head',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
	effect_cast = self.effects[ "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_thirst_stacks_ti7_loadout.vpcf" ]
	if effect_cast and self.style then
		ParticleManager:SetParticleControl( effect_cast, 2, Vector( 150,0,0 ) )
	end
end,

-- Shatterblast Core
[9462] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/ancient_apparition/ancient_apparation_ti8/ancient_ti8_ambient.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_shoulder',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Oathbound Defiant Off-Hand Blade
[9727] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/antimage/antimage_weapon_anchorite/antimage_blade_anchorite_off_hand.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.owner,
			PATTACH_POINT_FOLLOW,
			'attach_attack2',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Oathbound Defiant Blades
[9728] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/antimage/antimage_weapon_anchorite/antimage_blade_anchorite.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.owner,
			PATTACH_POINT_FOLLOW,
			'attach_attack1',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Savage Mettle
[9744] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_ambient_ti8.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.owner,
			PATTACH_POINT_FOLLOW,
			'attach_attack1',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Flame of the Penitent Scholar
[9779] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/skywrath_mage/ti8_set/skywrath_ti8_weapon_ambient.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_candle',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
	effect_cast = self.effects[ "particles/econ/items/skywrath_mage/ti8_set/skywrath_ti8_weapon_alternative_ambient.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_candle',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end

end,

-- Weapon of the Crystal Path
[12600] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/units/heroes/hero_oracle/oracle_ambient_weapon.vpcf" ]
	if effect_cast then
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			2,
			self.owner,
			PATTACH_POINT_FOLLOW,
			'attach_attack1',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Mask of the Vow Eternal
[12623] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/medusa/medusa_plus_2018/medusa_plus_2018_ambient_head.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_crown',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Turban of Mortal Deception
[13021] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/enigma/ti9_cache_enigma_lord_head/ti9_cache_enigma_lord_head_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_gem',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Armor of Mortal Deception
[13023] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/enigma/ti9_cache_enigma_lord_armor/ti9_cache_enigma_lord_armor_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_ball',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Dress of the Faeshade Flower
[13088] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/dark_willow/ti9_cache_willow_allure_armor/ti9_cache_willow_allure_armor_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_tail',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Bow of the Kha-Ren Faithful
[13338] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/drow/drow_runic/drow_runic_weapon.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'bow_bot',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Crucible of Rile
[12954] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_immortal_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_eye_l',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Golden Crucible of Rile
[13543] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_immortal_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_eye_l',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Mask of the Demon Trickster
[13544] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_head_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_eye_l',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Pauldron of the Demon Trickster
[13545] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_shoulders_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			'attach_wrist_l_1',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,

-- Pauldron of the Demon Trickster
[13546] = function( self )
	--fix weapon particles
	local effect_cast = self.effects[ "particles/econ/items/monkey_king/mk_ti9_immortal/mk_ti9_immortal_weapon_ambient.vpcf" ]
	if effect_cast then
		-- set CP
		ParticleManager:SetParticleControlEnt(
			effect_cast,
			2,
			self.owner,
			PATTACH_POINT_FOLLOW,
			'attach_attack1',
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end
end,


}