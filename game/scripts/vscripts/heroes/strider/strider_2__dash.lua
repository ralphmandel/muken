strider_2__dash = class({})
LinkLuaModifier( "strider_2_modifier_dash", "heroes/strider/strider_2_modifier_dash", LUA_MODIFIER_MOTION_NONE )

function strider_2__dash:CalcStatus(duration, caster, target)
    local time = duration
    if caster == nil then return time end
    local caster_int = caster:FindModifierByName("_1_INT_modifier")
    local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

    if target == nil then
        if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
    else
        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            local target_res = target:FindModifierByName("_2_RES_modifier")
            if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
            if target_res then time = time * (1 - target_res:GetStatus()) end
        end
    end

    if time < 0 then time = 0 end
    return time
end

function strider_2__dash:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

function strider_2__dash:Spawn()
	self:SetCurrentAbilityCharges(0)
end

function strider_2__dash:OnUpgrade()
    local caster = self:GetCaster()
    if caster:IsIllusion() then return end
    if caster:GetUnitName() ~= "npc_dota_hero_void_spirit" then return end

    local att = caster:FindAbilityByName("strider__attributes")
    if att then
        if att:IsTrained() then
            att.talents[2][0] = true
        end
    end
    
    if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
    if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
    if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
    if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
    if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
    if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

    local charges = 1
	self:SetCurrentAbilityCharges(charges)
end

function strider_2__dash:GetRank(upgrade)
    local caster = self:GetCaster()
    if caster:IsIllusion() then return end
    local att = caster:FindAbilityByName("strider__attributes")
    if not att then return end
    if not att:IsTrained() then return end
    if caster:GetUnitName() ~= "npc_dota_hero_void_spirit" then return end

    return att.talents[2][upgrade]
end

function strider_2__dash:OnSpellStart()
	local caster = self:GetCaster()
end