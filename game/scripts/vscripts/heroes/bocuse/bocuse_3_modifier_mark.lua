bocuse_3_modifier_mark = class ({})

function bocuse_3_modifier_mark:IsHidden()
    return false
end

function bocuse_3_modifier_mark:IsPurgable()
    return true
end

function bocuse_3_modifier_mark:IsDebuff()
    return true
end

-----------------------------------------------------------

function bocuse_3_modifier_mark:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    self.max = self.ability:GetSpecialValueFor("max")
    self.incoming_damage = self.ability:GetSpecialValueFor("incoming_damage")
    self.silenced = false
    self.truesight = false

	-- UP 3.3
	if self.ability:GetRank(3) then
        self.max = self.max + 1
	end

	-- UP 3.2
	if self.ability:GetRank(2) then
        self.incoming_damage =  self.incoming_damage + 2
	end

    if IsServer() then
        self:SetStackCount(1)
        self:RefreshDuration()
        self:CheckCounterEfx()
        self:PopupSauce(false)
        self:PlayEfxStart()
        self:PlaySoundEfx()
    end

	-- UP 3.1
	if self.ability:GetRank(1) then
        self.truesight = true
        self:StartIntervalThink(FrameTime())
	end
end

function bocuse_3_modifier_mark:OnRefresh(kv)
    if IsServer() then
        if self:GetStackCount() < self.max then
            self:IncrementStackCount()
            self:RefreshDuration()
            self:PopupSauce(false)
            self:PlaySoundEfx()
        end

        if self:GetStackCount() >= self.max and self.silenced == false then
            self.silenced = true

            -- UP 3.5
            if self.ability:GetRank(5) then
                self.parent:AddNewModifier(self.caster, self.ability, "_modifier_restrict", {duration = self:GetRemainingTime()})
            end

            self.parent:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
                duration = self:GetRemainingTime(),
                special = 2
            })
        end
    end
end

function bocuse_3_modifier_mark:OnRemoved()
    if self.pidx then ParticleManager:DestroyParticle(self.pidx, false) end
    self:CheckCounterEfx()
end

function bocuse_3_modifier_mark:RefreshDuration()
    local duration_init = self.ability:GetSpecialValueFor("duration_init")
    local duration_stack = self.ability:GetSpecialValueFor("duration_stack")

	-- UP 3.3
	if self.ability:GetRank(3) then
        duration_init = duration_init + 1.5
	end

    local duration = duration_init - (duration_stack * (self:GetStackCount() - 1))

    self:SetDuration(self.ability:CalcStatus(duration, self.caster, self.parent), true)
end

------------------------------------------------------------

function bocuse_3_modifier_mark:CheckState()
    local state = {}
    if self.truesight == true then
        state = {
            [MODIFIER_STATE_INVISIBLE] = false,
        }
    end

	return state
end

function bocuse_3_modifier_mark:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function bocuse_3_modifier_mark:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function bocuse_3_modifier_mark:GetModifierIncomingDamage_Percentage(keys)
    if keys.attacker ~= self.caster then return 0 end
    if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return 0 end
    if self.parent:IsIllusion() then return end

    -- UP 3.4
	if self.ability:GetRank(4) and keys.damage_flags ~= 40 then
        local heal = keys.original_damage * (1 + (self.incoming_damage * self:GetStackCount() * 0.01))
        heal = heal * 0.12
        if heal > 0 then
            self.caster:Heal(heal, nil)
            self:PlayEfxLifesteal()
        end
	end

    return self.incoming_damage * self:GetStackCount()
end

function bocuse_3_modifier_mark:OnIntervalThink()
    AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), 200, 0.1, true)
end

-----------------------------------------------------------

function bocuse_3_modifier_mark:PlayEfxStart()
	local particle_cast_1 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf"
	local effect_cast_1 = ParticleManager:CreateParticle( particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast_1, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
    self:AddParticle(effect_cast_1, false, false, -1, false, false)
end

function bocuse_3_modifier_mark:PlaySoundEfx()
    if IsServer() then self.parent:EmitSound("Hero_Bocuse.Sauce") end
end

function bocuse_3_modifier_mark:CheckCounterEfx()
	local mod = self.parent:FindModifierByName("icebreaker_0_modifier_slow")
	if mod then mod:PopupIce(true) end
end

function bocuse_3_modifier_mark:PopupSauce(immediate)
	if self.pidx ~= nil then ParticleManager:DestroyParticle(self.pidx, immediate) end

    local particle = "particles/bocuse/bocuse_3_counter.vpcf"
    if self.parent:HasModifier("icebreaker_0_modifier_slow") then particle = "particles/bocuse/bocuse_3_double_counter.vpcf" end
    self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.pidx, 2, Vector(self:GetStackCount(), 0, 0))
end

function bocuse_3_modifier_mark:PopupPure(target, damage)
	local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
    local digits = 0
	if damage < 10 then digits = 1 end
    if damage > 9 and damage < 100 then digits = 2 end
    if damage > 99 and damage < 1000 then digits = 3 end
    if damage > 999 then digits = 4 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 0))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, Vector(255, 225, 175))
end

function bocuse_3_modifier_mark:PlayEfxLifesteal()
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(effect_cast, 1, self.caster:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end