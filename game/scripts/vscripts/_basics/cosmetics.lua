cosmetics = class ({})
LinkLuaModifier("cosmetics_mod", "_basics/cosmetics_mod", LUA_MODIFIER_MOTION_NONE)

function cosmetics:Spawn()
	self:UpgradeAbility(true)
end

function cosmetics:LoadCosmetics()
	self.status_efx_flags = {
		[1] = "models/items/rikimaru/haze_atrocity_weapon/haze_atrocity_weapon.vmdl"
	}
	self.cosmetic = {}

	local caster = self:GetCaster()
	local hero_name = nil

	if caster:GetUnitName() == "npc_dota_hero_shadow_shaman" then hero_name = "dasdingo" end
	if caster:GetUnitName() == "npc_dota_hero_elder_titan" then hero_name = "ancient" end
	if caster:GetUnitName() == "npc_dota_hero_pudge" then hero_name = "bocuse" end
	if caster:GetUnitName() == "npc_dota_hero_shadow_demon" then hero_name = "bloodstained" end
	if caster:GetUnitName() == "npc_dota_hero_riki" then hero_name = "icebreaker" end
	if caster:GetUnitName() == "npc_dota_hero_furion" then hero_name = "druid" end
	if caster:GetUnitName() == "npc_dota_hero_drow_ranger" then hero_name = "genuine" end
	if caster:GetUnitName() == "npc_dota_hero_spectre" then hero_name = "shadow" end

	if hero_name ~= nil then
		local cosmetics_data = LoadKeyValues("scripts/vscripts/heroes/"..hero_name.."/"..hero_name.."-cosmetics.txt")
		if cosmetics_data ~= nil then self:ApplyCosmetics(cosmetics_data) end
	end
end

function cosmetics:ApplyCosmetics(cosmetics_data)
	local caster = self:GetCaster()
	local index = 0

	for cosmetic, ambients in pairs(cosmetics_data) do
		local unit = caster
		local modifier = caster:FindModifierByName(cosmetic)

		if modifier == nil then
			index = index + 1
			self.cosmetic[index] = CreateUnitByName("npc_dummy", caster:GetOrigin(), false, nil, nil, caster:GetTeamNumber())
			modifier = self.cosmetic[index]:AddNewModifier(caster, self, "cosmetics_mod", {model = cosmetic})
			unit = self.cosmetic[index]
		end

		if ambients ~= "nil" then
			self:ApplyAmbient(ambients, unit, modifier)
		end
	end
end

function cosmetics:ApplyAmbient(ambients, unit, modifier)
	for ambient, attach in pairs(ambients) do
		if ambient == "material" then
			unit:SetMaterialGroup(tostring(attach))
		else
			modifier:PlayEfxAmbient(ambient, attach)
		end
	end
end

function cosmetics:SetStatusEffect(string, enable)
	local caster = self:GetCaster()
	if self.cosmetic == nil then return end

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
	if cosmetic == nil then return end
	if IsValidEntity(cosmetic) == false then return end
	local mod = cosmetic:FindModifierByName("cosmetics_mod")
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
	if self.cosmetic == nil then return end

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

function cosmetics:FindCosmeticByModel(model)
	if self.cosmetic == nil then return end

	for i = 1, #self.cosmetic, 1 do
		if self.cosmetic[i]:GetModelName() == model then
			return self.cosmetic[i]
		end
	end
end

function cosmetics:ChangeCosmeticsActivity(bClear)
	if self.cosmetic == nil then return end
	local base_hero_mod = self:GetCaster():FindModifierByName("base_hero_mod")
	if base_hero_mod == nil then return end

	for i = 1, #self.cosmetic, 1 do
		if bClear then self.cosmetic[i]:ClearActivityModifiers() end
		self.cosmetic[i]:AddActivityModifier(base_hero_mod.activity)
	end
end

function cosmetics:StartCosmeticGesture(model, gesture)
	if self.cosmetic == nil then return end

	for i = 1, #self.cosmetic, 1 do
		if self.cosmetic[i]:GetModelName() == model then
			self.cosmetic[i]:StartGesture(gesture)
		end
	end
end

function cosmetics:FadeCosmeticsGesture(model, gesture)
	if self.cosmetic == nil then return end

	for i = 1, #self.cosmetic, 1 do
		if self.cosmetic[i]:GetModelName() == model then
			self.cosmetic[i]:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_3)
		end
	end
end

function cosmetics:ChangeTeam(team)
	if self.cosmetic == nil then return end

	for i = 1, #self.cosmetic, 1 do
		self.cosmetic[i]:SetTeam(team)
	end
end