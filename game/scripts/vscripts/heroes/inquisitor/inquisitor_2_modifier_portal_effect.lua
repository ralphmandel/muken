inquisitor_2_modifier_portal_effect = class({})

function inquisitor_2_modifier_portal_effect:IsHidden()
	return false
end

function inquisitor_2_modifier_portal_effect:IsPurgable()
    return true
end

function inquisitor_2_modifier_portal_effect:IsDebuff()
	return self.debuff
end

function inquisitor_2_modifier_portal_effect:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.init_heal = self.ability:GetSpecialValueFor("init_heal")
    self.init_damage = self.ability:GetSpecialValueFor("init_damage")
    self.max_tick = self.ability:GetSpecialValueFor("max_tick")
    self.intervals = self.ability:GetSpecialValueFor("intervals")
    self.reduction = self.ability:GetSpecialValueFor("reduction") * 0.01
    self.root = false
    self.particle_root = nil
    self.debuff = false
    self:PlayEfxStart()

    -- UP 2.5
    if self.ability:GetRank(5) then
        self.reduction = 0.8
        self.max_tick = 7
        self.intervals = 0.5
    end

    self.tick = self.max_tick
    
    if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
        -- UP 2.6
        if self.ability:GetRank(6) then
            self.ms = 20
            self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = self.ms})
        end

        self.value = self.init_heal
        self:ExecuteHeal()
    else
        self.value = self.init_damage
        self.damageTable = {
            victim = self.parent,
            attacker = self.caster,
            damage = self.value,
            damage_type = DAMAGE_TYPE_MAGICAL,
            --damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
            ability = self.ability,
        }

        -- UP 2.6
        if self.ability:GetRank(6) then
            self.root = true
            self:PlayEfxRoot()
        end

        self:ExecuteDamage()
        self.debuff = true
    end

    self:StartIntervalThink(self.intervals)
end

function inquisitor_2_modifier_portal_effect:OnRefresh( kv )
    self:PlayEfxStart()
    self.tick = self.max_tick

    if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
        -- UP 2.6
        if self.ability:GetRank(6) then
            self.ms = 20

            local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
            for _,modifier in pairs(mod) do
                if modifier:GetAbility() == self.ability then modifier:Destroy() end
            end

            self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = self.ms})
        end
        self.value = self.value + self.init_heal
    else
        self.value = self.value + self.init_damage
    end
end

function inquisitor_2_modifier_portal_effect:OnRemoved()
    if self.particle_root ~= nil then ParticleManager:DestroyParticle(self.particle_root, false) end

    local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
    for _,modifier in pairs(mod) do
        if modifier:GetAbility() == self.ability then modifier:Destroy() end
    end
end

---------------------------------------------------------------------------------

function inquisitor_2_modifier_portal_effect:CheckState()
	local state = {
	    [MODIFIER_STATE_ROOTED] = self.root
	}

	return state
end

----------------------------------------------------------------------------------

function inquisitor_2_modifier_portal_effect:OnIntervalThink()
    self.value = self.value * self.reduction

    if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
        self:ExecuteHeal()
    else
        self:ExecuteDamage()
    end

    self.tick = self.tick - 1
    if self.tick <= 0 then
        self:StartIntervalThink(-1)
        self:Destroy()
    end
end

function inquisitor_2_modifier_portal_effect:ExecuteHeal()
    local value = self.value
    local mnd = self.caster:FindModifierByName("_2_MND_modifier")
	if mnd then value = value * mnd:GetHealPower() end
    if value > 0 then self.parent:Heal(value, self.ability) end

    -- UP 2.4
    if self.ability:GetRank(4) then
        self.parent:Purge(false, true, false, true, false)
    end

    -- UP 2.6
    if self.ability:GetRank(6) and self.tick > 1 then
        self.ms = self.ms * self.reduction

        local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self.ability then modifier:Destroy() end
        end

        self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = self.ms})
    end
end

function inquisitor_2_modifier_portal_effect:ExecuteDamage()
    self.damageTable.damage = self.value
    ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------

function inquisitor_2_modifier_portal_effect:GetEffectName()
	return "particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_heal.vpcf"
end

function inquisitor_2_modifier_portal_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function inquisitor_2_modifier_portal_effect:PlayEfxStart()
    if IsServer() then
        if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
            self.parent:EmitSound("Hero_Inquisitor.Portal.Buff")
        else
            EmitSoundOn("Hero_Abaddon.DeathCoil.Target", self.parent)
        end
    end
end

function inquisitor_2_modifier_portal_effect:PlayEfxRoot()
    self.particle_root = ParticleManager:CreateParticle( "particles/units/heroes/hero_treant/treant_bramble_root.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( self.particle_root, 0, self.parent:GetOrigin() )
end