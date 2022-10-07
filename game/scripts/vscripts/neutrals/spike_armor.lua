spike_armor = class({})
LinkLuaModifier( "spike_armor_modifier", "neutrals/spike_armor_modifier", LUA_MODIFIER_MOTION_NONE )

function spike_armor:CalcStatus(duration, caster, target)
    if caster == nil or target == nil then return duration end
    if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
    local base_stats = caster:FindAbilityByName("base_stats")

    if caster:GetTeamNumber() == target:GetTeamNumber() then
        if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
    else
        if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
        duration = duration * (1 - target:GetStatusResistance())
    end
    
    return duration
end

function spike_armor:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "spike_armor_modifier", {duration = duration})

	if IsServer() then caster:EmitSound("DOTA_Item.BladeMail.Activate") end
end