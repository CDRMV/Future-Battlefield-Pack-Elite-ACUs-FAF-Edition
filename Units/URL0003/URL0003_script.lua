#****************************************************************************
#**
#**  File     :  /cdimage/units/URL0301/URL0301_script.lua
#**  Author(s):  David Tomandl, Jessica St. Croix
#**
#**  Summary  :  Cybran Sub Commander Script
#**
#**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local CCommandUnit = import('/lua/cybranunits.lua').CCommandUnit
local CWeapons = import('/lua/cybranweapons.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

local CAAMissileNaniteWeapon = CWeapons.CAAMissileNaniteWeapon
local CDFLaserDisintegratorWeapon = CWeapons.CDFLaserDisintegratorWeapon02
local SCUDeathWeapon = import('/lua/sim/defaultweapons.lua').SCUDeathWeapon

URL0003 = Class(CCommandUnit) {
    LeftFoot = 'Left_Foot01',
    RightFoot = 'Right_Foot01',

    Weapons = {
        DeathWeapon = Class(SCUDeathWeapon) {},
        RightDisintegrator = Class(CDFLaserDisintegratorWeapon) {
            OnCreate = function(self)
                CDFLaserDisintegratorWeapon.OnCreate(self)
                #Disable buff 
                self:DisableBuff('STUN')
            end,
        },
        NMissile = Class(CAAMissileNaniteWeapon) {},
    },

    # ********
    # Creation
    # ********
    OnCreate = function(self)
        CCommandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:SetWeaponEnabledByLabel('NMissile', false)
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
        self.IntelButtonSet = true
    end,

    OnPrepareArmToBuild = function(self)
        CCommandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self:SetWeaponEnabledByLabel('RightDisintegrator', false)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisintegrator'):GetHeadingPitch() )
    end,
    
    OnStopCapture = function(self, target)
        CCommandUnit.OnStopCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
        CCommandUnit.OnFailedCapture(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStopReclaim = function(self, target)
        CCommandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    # ********
    # Engineering effects
    # ********
    OnStartBuild = function(self, unitBeingBuilt, order)    
        CCommandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true   
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        CCommandUnit.OnStopBuild(self, unitBeingBuilt)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)   
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)    
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,    
    
    OnFailedToBuild = function(self)
        CCommandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self:SetWeaponEnabledByLabel('RightDisintegrator', true)
        self:GetWeaponManipulatorByLabel('RightDisintegrator'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.SpawnBuildBots( self, unitBeingBuilt, 3, self.BuildEffectsBag )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        CCommandUnit.OnStopBeingBuilt(self,builder,layer)
        self:BuildManipulatorSetEnabled(false)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
        self.LeftArmUpgrade = 'EngineeringArm'
        self.RightArmUpgrade = 'Disintegrator'
    end,

    SetupIntel = function(self, layer)
        CCommandUnit.SetupIntel(self)
        if layer == 'Seabed' or layer == 'Sub' then
            self:EnableIntel('WaterVision')
        else
            self:EnableIntel('Vision')
        end

        self:EnableIntel('Radar')
        self:EnableIntel('Sonar')
    end,



    OnScriptBitSet = function(self, bit)
        if bit == 8 then # cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')          
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 8 then # cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        end
    end,
           

    # ************
    # Enhancements
    # ************
    CreateEnhancement = function(self, enh)
        CCommandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'CloakingGenerator' then
            self.StealthEnh = false
			self.CloakEnh = true 
            self:EnableUnitIntel('Cloak')
            if not Buffs['CybranSCUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranSCUCloakBonus',
                    DisplayName = 'CybranSCUCloakBonus',
                    BuffType = 'SCUCLOAKBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'CybranSCUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCUCloakBonus' )
            end  
            Buff.ApplyBuff(self, 'CybranSCUCloakBonus')                		
        elseif enh == 'CloakingGeneratorRemove' then
            self:DisableUnitIntel('Cloak')
            self.StealthEnh = false
            self.CloakEnh = false 
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            if Buff.HasBuff( self, 'CybranSCUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranSCUCloakBonus' )
            end 
        elseif enh == 'StealthGenerator' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false        
            self.StealthEnh = true
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')          
        elseif enh == 'StealthGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')           
            self.StealthEnh = false
            self.CloakEnh = false 
        elseif enh == 'NaniteMissileSystem' then
            self:ShowBone('AA_Gun', true)
            self:SetWeaponEnabledByLabel('NMissile', true)
        elseif enh == 'NaniteMissileSystemRemove' then
            self:HideBone('AA_Gun', true)
            self:SetWeaponEnabledByLabel('NMissile', false)
        elseif enh == 'SelfRepairSystem' then
            local bpRegenRate = self:GetBlueprint().Enhancements.SelfRepairSystem.NewRegenRate 
            self:SetRegenRate(bpRegenRate or 0)
        elseif enh == 'SelfRepairSystemRemove' then
            self:RevertRegenRate()
        elseif enh =='ResourceAllocation' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'ResourceAllocationRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        elseif enh =='Switchback' then
            if not Buffs['CybranSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'CybranSCUBuildRate',
                    DisplayName = 'CybranSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'CybranSCUBuildRate')
        elseif enh == 'SwitchbackRemove' then
            if Buff.HasBuff( self, 'CybranSCUBuildRate' ) then
                Buff.RemoveBuff( self, 'CybranSCUBuildRate' )
            end
        elseif enh == 'FocusConvertor' then
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:AddDamageMod(self:GetBlueprint().Enhancements.FocusConvertor.NewDamageMod or 0)
        elseif enh == 'FocusConvertorRemove' then
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:AddDamageMod(0)
        elseif enh == 'EMPCharge' then
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:ReEnableBuff('STUN')        
        elseif enh == 'EMPChargeRemove' then
            local wep = self:GetWeaponByLabel('RightDisintegrator')
            wep:DisableBuff('STUN')        
        end             
    end,

    # *****
    # Death
    # *****
    OnKilled = function(self, instigator, type, overkillRatio)
        local bp
        for k, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                bp = v
            end
        end 
        #if we could find a blueprint with v.Add.OnDeath, then add the buff 
        if bp != nil then 
            #Apply Buff
			self:AddBuff(bp)
        end
        #otherwise, we should finish killing the unit
        CWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Head',
				    'Right_Elbow',
				    'Left_Elbow',
				    'Right_Arm01',
				    'Left_Shoulder',
				    'Torso',
				    'URL0301',
				    'Left_Thigh',
				    'Left_Knee',
				    'Left_Leg',
				    'Right_Thigh',
				    'Right_Knee',
				    'Right_Leg',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Head',
				    'Right_Elbow',
				    'Left_Elbow',
				    'Right_Arm01',
				    'Left_Shoulder',
				    'Torso',
				    'URL0301',
				    'Left_Thigh',
				    'Left_Knee',
				    'Left_Leg',
				    'Right_Thigh',
				    'Right_Knee',
				    'Right_Leg',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
    
    OnIntelEnabled = function(self)
        CCommandUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then 
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
			    self.IntelEffectsBag = {}
			    self.CreateTerrainTypeEffects( self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
			end            
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()  
            if not self.IntelEffectsBag then 
	            self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		    end                  
        end		
    end,

    OnIntelDisabled = function(self)
        CCommandUnit.OnIntelDisabled(self)
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then
            self:SetMaintenanceConsumptionInactive()
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
            self:SetMaintenanceConsumptionInactive()
        end          
    end,
    
    OnPaused = function(self)
        CCommandUnit.OnPaused(self)
        if self.BuildingUnit then
            CCommandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            CCommandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        CCommandUnit.OnUnpaused(self)
    end,        
}

TypeClass = URL0003
