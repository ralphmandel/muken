cosmetics = class ({})
LinkLuaModifier("cosmetics_mod", "_basics/cosmetics_mod", LUA_MODIFIER_MOTION_NONE)

function cosmetics:Spawn()
	self:UpgradeAbility(true)
end

-- ADD COSMETICS

	function cosmetics:LoadHeroNames()
		local heroes_name_data = LoadKeyValues("scripts/npc/heroes_name.kv")
		if heroes_name_data == nil then return end
		for name, id_name in pairs(heroes_name_data) do
			if self:GetCaster():GetUnitName() == id_name then
				return name
			end
		end
	end

	function cosmetics:LoadCosmetics()
		self.cosmetic = {}
		self.status_efx_flags = {
			[1] = "models/items/rikimaru/haze_atrocity_weapon/haze_atrocity_weapon.vmdl"
		}

		local cosmetics_data = LoadKeyValues("scripts/vscripts/heroes/"..self:LoadHeroNames().."/"..self:LoadHeroNames().."-cosmetics.txt")
		if cosmetics_data ~= nil then self:ApplyCosmetics(cosmetics_data) end
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
		if modifier == nil or ambients == nil or unit == nil then return end

		for ambient, attach in pairs(ambients) do
			if ambient == "material" then
				unit:SetMaterialGroup(tostring(attach))
			else
				modifier:PlayEfxAmbient(ambient, attach)
			end
		end
	end

	function cosmetics:ChangeTeam(team)
		if self.cosmetic == nil then return end
	
		for i = 1, #self.cosmetic, 1 do
			self.cosmetic[i]:SetTeam(team)
		end
	end

-- STATUS EFX / BAN

	function cosmetics:SetStatusEffect(caster, ability, string, enable)
		if self.cosmetic == nil then return end

		local inflictor = self
		if ability then inflictor = ability end

		for i = 1, #self.cosmetic, 1 do
			if self:CheckFlags(self.cosmetic[i]) then
				if enable == true then
					self.cosmetic[i]:AddNewModifier(caster, inflictor, string, {})
				else
					if ability then
						local mod = self.cosmetic[i]:FindAllModifiersByName(string)
						for _,modifier in pairs(mod) do
							if modifier:GetAbility() == ability then modifier:Destroy() end
						end
					else
						self.cosmetic[i]:RemoveModifierByNameAndCaster(string, caster)
					end
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
			if self.cosmetic[i]:GetModelName() == model 
			or model == nil then
				if bApply then
					self.cosmetic[i]:FindModifierByName("cosmetics_mod"):ChangeHidden(1)
				else
					self.cosmetic[i]:FindModifierByName("cosmetics_mod"):ChangeHidden(-1)
				end
			end
		end
	end

-- ACTIVITY / GESTURE

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

-- FIND / MODIFY: COSMETIC / AMBIENT

	function cosmetics:FindModifierByModel(model)
		local cosmetic = self:FindCosmeticByModel(model)
		if cosmetic then return cosmetic:FindModifierByName("cosmetics_mod") end
	end

	function cosmetics:FindCosmeticByModel(model)
		if self.cosmetic == nil then return end
		if model == nil then return end
	
		for i = 1, #self.cosmetic, 1 do
			if self.cosmetic[i]:GetModelName() == model then
				return self.cosmetic[i]
			end
		end
	end

	function cosmetics:GetAmbient(ambient)
		if self.cosmetic == nil then return end

		for i = 1, #self.cosmetic, 1 do
			local mod_cosmetic = self.cosmetic[i]:FindModifierByName("cosmetics_mod")
			if mod_cosmetic then
				if mod_cosmetic.index ~= nil then
					for i = 1, mod_cosmetic.index, 1 do
						if mod_cosmetic.ambient[i] == ambient then
							return mod_cosmetic.particle[i]
						end
					end
				end
			end
		end
	end

	function cosmetics:DestroyAmbient(model, ambient, bDestroyImmediately)
		if self.cosmetic == nil then return end

		if model then
			local mod_cosmetic = self:FindModifierByModel(model)
			if mod_cosmetic then mod_cosmetic:StopAmbientEfx(ambient, bDestroyImmediately) end
		else
			for i = 1, #self.cosmetic, 1 do
				local mod_cosmetic = self.cosmetic[i]:FindModifierByName("cosmetics_mod")
				if mod_cosmetic then mod_cosmetic:StopAmbientEfx(ambient, bDestroyImmediately) end
			end
		end
	end

	function cosmetics:ReloadAmbients(unit, models, bDestroyImmediately)
		self:DestroyAmbient(nil, nil, false)
		for model, ambients in pairs(models) do
			self:ApplyAmbient(ambients, unit, self:FindModifierByModel(model))
		end
	end