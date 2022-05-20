cosmetics = class ({})
LinkLuaModifier("_modifier_cosmetics", "modifiers/_modifier_cosmetics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_status_effect", "modifiers/_modifier_status_effect", LUA_MODIFIER_MOTION_NONE)

function cosmetics:Spawn()
	self:UpgradeAbility(true)
	self.status_efx_flags = {
		[1] = "models/items/rikimaru/haze_atrocity_weapon/haze_atrocity_weapon.vmdl"
	}
	self.cosmetic = {}
	self:LoadCosmetics()
end

function cosmetics:LoadCosmetics()
	local caster = self:GetCaster()
	local hero_name = nil

	if caster:GetUnitName() == "npc_dota_hero_shadow_shaman" then hero_name = "dasdingo" end
	if caster:GetUnitName() == "npc_dota_hero_elder_titan" then hero_name = "ancient" end
	if caster:GetUnitName() == "npc_dota_hero_pudge" then hero_name = "bocuse" end
	if caster:GetUnitName() == "npc_dota_hero_shadow_demon" then hero_name = "bloodstained" end
	if caster:GetUnitName() == "npc_dota_hero_riki" then hero_name = "icebreaker" end
	if caster:GetUnitName() == "npc_dota_hero_furion" then hero_name = "druid" end
	if caster:GetUnitName() == "npc_dota_hero_queenofpain" then hero_name = "succubus" end
	if caster:GetUnitName() == "npc_dota_hero_phantom_assassin" then hero_name = "gladiator" end
	if caster:GetUnitName() == "npc_dota_hero_bloodseeker" then hero_name = "bloodmage" end
	if caster:GetUnitName() == "npc_dota_hero_rubick" then hero_name = "doctor" end
	if caster:GetUnitName() == "npc_dota_hero_drow_ranger" then hero_name = "genuine" end

	if hero_name ~= nil then
		local cosmetics_data = LoadKeyValues("scripts/vscripts/heroes/"..hero_name.."/"..hero_name.."-cosmetics.txt")
		if cosmetics_data ~= nil then self:ApplyCosmetics(cosmetics_data) end
	end
end

function cosmetics:ApplyCosmetics(cosmetics_data)
	local caster = self:GetCaster()
	local index = 0

	for cosmetic, ambients in pairs(cosmetics_data) do
		index = index + 1
		self.cosmetic[index] = CreateUnitByName("npc_dummy", caster:GetOrigin(), false, nil, nil, caster:GetTeamNumber())
		local modifier = self.cosmetic[index]:AddNewModifier(caster, self, "_modifier_cosmetics", {model = cosmetic})

		if ambients ~= "nil" then
			for ambient, attach in pairs(ambients) do
				if ambient == "material" then
					self.cosmetic[index]:SetMaterialGroup(tostring(attach))
				else
					modifier:PlayEfxAmbient(ambient, attach)
				end
			end
		end
	end
end

function cosmetics:SetStatusEffect(string, enable)
	local caster = self:GetCaster()

	for i = 1, #self.cosmetic, 1 do
		if self:CheckFlags(self.cosmetic[i]) then
			if enable == true then
				self.cosmetic[i]:AddNewModifier(caster, self, string, {})
			else
				self.cosmetic[i]:RemoveModifierByName(string)
			end
		end
	end
end

function cosmetics:CheckFlags(cosmetic)
	local mod = cosmetic:FindModifierByName("_modifier_cosmetics")
	if mod then
		for i = 1, #self.status_efx_flags, 1 do
			if mod.model == self.status_efx_flags[i] then
				return false
			end
		end
	end

	return true
end

function cosmetics:HideCosmetic(model, bApply)
	for i = 1, #self.cosmetic, 1 do
		if self.cosmetic[i]:GetModelName() == model then
			if bApply then
				self.cosmetic[i]:AddNoDraw()
			else
				self.cosmetic[i]:RemoveNoDraw()
			end
		end
	end
end

function cosmetics:ChangeTeam(team)
	for i = 1, #self.cosmetic, 1 do
		self.cosmetic[i]:SetTeam(team)
	end
end