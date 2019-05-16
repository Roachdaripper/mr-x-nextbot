
AddCSLuaFile()
ENT.Type = "nextbot"
----------------------------------------------
ENT.Base     = "base_nextbot"
ENT.Spawnable= true
ENT.Category = "nZombies Unlimited"
ENT.Author = "Roach"


list.Set("NPC", "npc_roach_iv04_tyrant_mrx", {
	Name = "Mr. X",
	Class = "npc_roach_iv04_tyrant_mrx",
	Category = "RE2 Nextbots"
})
if CLIENT then	language.Add("npc_roach_iv04_tyrant_mrx","Mr. X")end

-- Essentials --
ENT.Model = "models/roach/re2/tyrant_v5.mdl"	-- Our model.
ENT.health = 500000								-- Our health.
ENT.Speed = 105									-- How fast we move.
ENT.WalkAnim = "0200"
ENT.AllyNPCTable = {
	"npc_zombie"
}

function ENT:rnd(a)
	return math.random(1,a)
end
function ENT:snd(a,b)
	timer.Simple(b,function()
		if !IsValid(self) then return end
		self:EmitSound(a)
		self:EmitSound("re2/em6200/foley_long"..self:rnd(2)..".mp3")
	end)
end

function ENT:Think()
end
function ENT:CustomInit()
	self.PissedOff = false
	self.CanAttack = false
	self.CanTaunt = false
	self.CanFlinch = false
	self.ShotOffHat = false
	self.HiddenHealth = 5000
	self.CanCommitDie = false
	self.IsShocked = false
	self.IsDead = false
	self.IsPlayingGesture = false
	self.CanOpenDoor = true
	
	self.Grab_IsGrabbing = false
	self.Grab_DidSucceed = false -- Did we succeed in grabbing a bitch?

	for i=3,117 do self:ManipulateBoneJiggle(i, 1) end
	
	self:SetCollisionBounds(Vector(-14,-20,0), Vector(15,20,93))
	if SERVER then self:SetSolidMask(MASK_NPCSOLID)self:SetName("nextbot_mrx"..self:EntIndex()) end
end
function ENT:OnSpawn()
	local tr = util.TraceLine({
		start=self:GetPos()+Vector(0,0,5),
		endpos=self:GetPos()+Vector(0,0,50000),
		filter=self
	})
	if !tr.HitSky then
		ParticleEffect("strider_wall_smash",tr.HitPos,Angle(0,0,0),nil)
		ParticleEffect("strider_small_spray",tr.HitPos,Angle(0,0,0),nil)
		ParticleEffect("strider_impale_ground",tr.HitPos,Angle(0,0,0),nil)
		ParticleEffect("strider_headbeating_01",tr.HitPos,Angle(0,0,0),nil)
		ParticleEffect("strider_goop_01e",tr.HitPos,Angle(0,0,0),nil)
		ParticleEffect("strider_brain_open_01b",tr.HitPos,Angle(0,0,0),nil)
		
		self:EmitSound("explode_4",511,100)
	end
	timer.Simple(31/30,function()if !IsValid(self) then return end self:EmitSound("re2/em6200/land.mp3",511,100)end)
	self:PlaySequenceAndWait("nzu_intro_fall")
	
	self:snd("re2/em6200/step"..self:rnd(5)..".mp3",18/30)
	self:snd("re2/em6200/step"..self:rnd(5)..".mp3",33/30)
	self:snd("re2/em6200/step"..self:rnd(5)..".mp3",40/30)
	self:PlaySequenceAndWait("nzu_intro_land")
	
	self.CanAttack = true
end

function ENT:OnContact(ent)
	if self.CanAttack and (ent != self:GetTarget()) and (ent:IsPlayer() or ent:IsNPC()) then
		self.CanAttack = false
		local right = self:GetPos()+self:GetRight()*1
		local left = self:GetPos()-self:GetRight()*1
		local pos = ent:GetPos()
		if left:DistToSqr(pos) < right:DistToSqr(pos) then
			self:RestartGesture(140)
			timer.Simple(0.4,function()
				if !IsValid(self) then return end
				
				print("RIGHT")
				local dmg = DamageInfo()
				dmg:SetDamage(100000)
				dmg:SetDamageForce(self:GetRight()* -Vector(0,50000000,0))
				dmg:SetDamageType(DMG_CLUB)
				dmg:SetAttacker(self)
				dmg:SetReportedPosition(self:GetPos())
				
				ent:SetVelocity(self:GetRight()* -Vector(0,50000000,990))
				ent:TakeDamageInfo(dmg)
				
				self:EmitSound("re2/em6200/attack_hit"..self:rnd(5)..".mp3",511,100)
			end)
		else
			self:RestartGesture(self:GetSequenceActivity( self:LookupSequence("g_puntL2") ))
			timer.Simple(0.4,function()
				if !IsValid(self) then return end
				
				print("LEFT")
				local dmg = DamageInfo()
				dmg:SetDamage(100000)
				dmg:SetDamageForce(self:GetRight()*Vector(0,50000000,0))
				dmg:SetDamageType(DMG_CLUB)
				dmg:SetAttacker(self)
				dmg:SetReportedPosition(self:GetPos())
				
				ent:SetVelocity(self:GetRight()* Vector(0,50000000,990))
				ent:TakeDamageInfo(dmg)
				
				self:EmitSound("re2/em6200/attack_hit"..self:rnd(5)..".mp3",511,100)
			end)
		end
		timer.Simple(1.4,function()self.CanAttack = true end)
	end
end

function ENT:OnLeaveGround()
	if not self.CanOpenDoor then return end
	local seqid,dur = self:LookupSequence("1500")
	self:ResetSequence(seqid)
end
function ENT:OnLandOnGround()
	if not self.CanOpenDoor then return end
	if self:GetSequence() == self:LookupSequence("1500") then
		self.CanAttack = false
		self.loco:SetDesiredSpeed(0)
		self:EmitSound("re2/em6200/land.mp3",511,100)
		
		local seqid,dur = self:LookupSequence("1750")
		self:ResetSequence(seqid)
		
		timer.Simple(dur,function()
			if !IsValid(self) then return end
			self.loco:SetDesiredSpeed(self.Speed)
			self:ResetSequence(self.WalkAnim)
			self.CanAttack = true
		end)
	end
end
function ENT:CustomChaseTarget(target)
	self:Taunt()
	self:Flinch()
	self:CommitDie()
	self:DirectPoseParametersAt(target:GetPos(), "aim_pitch", "aim_yaw")
	
	if self.CanOpenDoor then
		local doorseq,doordur = self:LookupSequence("9200")
		for k, door in pairs(ents.FindInSphere(self:GetPos(),64)) do
		if IsValid(door) and door:GetClass() == "prop_door_rotating" then
			self.CanOpenDoor = false
			self.CanAttack = false
			self.CanTaunt = false
			self.CanFlinch = false
			self:SetNotSolid(true)
			door:SetNotSolid(true)
				-- find ourselves to know which side of the door we're on
				local fwd = door:GetPos()+door:GetForward()*5
				local bck = door:GetPos()-door:GetForward()*5
				local pos = self:GetPos()
				
				if fwd:DistToSqr(pos) < bck:DistToSqr(pos) then -- entered from forward
					self:SetNotSolid(true)
					door:SetNotSolid(true)
					self:SetPos(door:GetPos()+(door:GetForward()*80)+(door:GetRight()*-32))
					local ang = door:GetAngles()
					ang:RotateAroundAxis(Vector(0,0,1),180)
					self:SetAngles(ang)
				elseif bck:DistToSqr(pos) < fwd:DistToSqr(pos) then -- entered from backward
					self:SetNotSolid(true)
					door:SetNotSolid(true)
					self:SetPos(door:GetPos()+(door:GetForward()*-80)+(door:GetRight()*-12))
					local a = (door:GetAngles())
					a:Normalize()
					self:SetAngles(a)
				end
				-- find ourselves to know which side of the door we're on
				if (fwd:DistToSqr(pos) < bck:DistToSqr(pos)) or (bck:DistToSqr(pos) < fwd:DistToSqr(pos)) then
					local fuck_double_doors1 = door:GetKeyValues()
					local fuck_double_doors2 = nil
					if isstring(fuck_double_doors1.slavename) and fuck_double_doors1.slavename != "" then
						-- print("yes")
						fuck_double_doors2 = ents.FindByName(fuck_double_doors1.slavename)[1]
					-- else
						-- print("no")
					end
					
					self:SetNotSolid(true)
					door:SetNotSolid(true)
					fuck_double_doors2:SetNotSolid(true)
					
					door:Fire("setspeed",500)
					fuck_double_doors2:Fire("setspeed",500)
					timer.Simple(0.5,function()
						if !IsValid(self) then return end
						self:EmitSound("doors/vent_open3.wav",511,math.random(50,80))
						door:Fire("openawayfrom",self:GetName())
						fuck_double_doors2:Fire("openawayfrom",self:GetName())
					end)
					timer.Simple(doordur,function()
						if !IsValid(self) then return end
						door:Fire("setspeed",100)
						door:Fire("close")
						fuck_double_doors2:Fire("setspeed",100)
						fuck_double_doors2:Fire("close")
						timer.Simple(0.2,function()
							door:SetNotSolid(false)
							fuck_double_doors2:SetNotSolid(false)
							if !IsValid(self) then return end
							self.CanOpenDoor = true
							self.CanAttack = true
							self.CanFlinch = false
							self:SetNotSolid(false)
						end)
					end)
					self:snd("re2/em6200/step"..self:rnd(5)..".mp3",6/30)
					self:snd("re2/em6200/step"..self:rnd(5)..".mp3",13/30)
					self:snd("re2/em6200/step"..self:rnd(5)..".mp3",20/30)
					self:snd("re2/em6200/step"..self:rnd(5)..".mp3",53/30)
					self:snd("re2/em6200/step"..self:rnd(5)..".mp3",70/30)
					self:snd("re2/em6200/step"..self:rnd(5)..".mp3",83/30)
					self:PlaySequenceAndSetPos("9200")
				else
					timer.Simple(0.1,function()
						door:SetNotSolid(false)
						if !IsValid(self) then return end
						self.CanOpenDoor = true
						self.CanAttack = true
						self.CanFlinch = false
						self:SetNotSolid(false)
					end)
				end
		end
		end
	end
	
	local v = target
	
	if self.CanAttack and self:GetRangeTo(v:GetPos()) < 96 then
		if self.PissedOff then
			self:DoChangeWalk()
			self.PissedOff = false
		end
		
		-- function ENT:Helper_Attack(victim,delay,sequence,damage,damageradius,hitsound)
		local rm = math.random(1,5)
		if rm == 1 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.5)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.6)
			
			self:Helper_Attack(v,1,"3000",50,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
			if self:GetTarget():Health() <= 0 then self:SetTarget(nil)self:CustomIdle() end
		elseif rm == 2 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.5)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.8)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3.2)
				
			self:Helper_Attack(v,1,"3001",50,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
			if self:GetTarget():Health() <= 0 then self:SetTarget(nil)self:CustomIdle() end
		elseif rm == 3 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.4)
			
			self:Helper_Attack(v,0.6,"3002",30,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
			if self:GetTarget():Health() <= 0 then self:SetTarget(nil)self:CustomIdle() end
		elseif rm == 4 then
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0.1)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",2.6)
			
			self:Helper_Attack(v,0.6,"3003",30,96,"re2/em6200/attack_hit"..self:rnd(5)..".mp3")
			if self:GetTarget():Health() <= 0 then self:SetTarget(nil)self:CustomIdle() end
		elseif rm == 5 then -- grab
			self.Grab_IsGrabbing = true
			
			self:SetSequence("ragdoll_grabA")
				self:SetCycle(0)
				self:SetPlaybackRate(1)
				self:ResetSequenceInfo()
			self.loco:SetDesiredSpeed(0)
			
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",0)
			self:snd("re2/em6200/step"..self:rnd(5)..".mp3",13/30)
			self:snd("re2/em6200/attack_swing"..self:rnd(5)..".mp3",13/30)
			timer.Simple(15/30, function()
				if self:GetRangeTo(v:GetPos()) < 100 then
					self.Grab_DidSucceed = true
					
					self.attachment=ents.Create("obj_ragdoll_attachment_body_mrx")
					self.attachment.model = v:GetModel()
					self.attachment:SetPos(self:GetPos())
					self.attachment:SetParent(self)
					self.attachment:Spawn()
					self:DeleteOnRemove(self.attachment)
					
					if v:IsPlayer() then
						v:SetPos(self:GetPos() + (self:GetForward()*60) + Vector(0,0,60))
						v:KillSilent()
					else
						SafeRemoveEntity(v)
					end
				end
			end)
			coroutine.wait(17/30)
			if self.Grab_DidSucceed then
				self:snd("physics/body/body_medium_impact_soft"..math.random(5,7)..".wav",0)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",8/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",15/30)
				self:PlaySequenceAndWait("ragdoll_grabB")
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",8/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",13/30)
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",19/30)
				timer.Simple(27/30,function()
					self:EmitSound("physics/body/body_medium_break"..math.random(2,3)..".wav",511,100)
					ParticleEffectAttach("blood_advisor_puncture",PATTACH_POINT_FOLLOW,self,3)
					for i=1,math.random(5,10) do ParticleEffectAttach("blood_impact_red_01",PATTACH_POINT_FOLLOW,self,3) end
				end)
				timer.Simple(120/30,function()
					self.doll=ents.Create("prop_ragdoll")
					self.doll:SetModel(self.attachment.model)
					self.doll:SetPos(self.attachment.doll:GetPos())
					
					local ang = self:GetAngles()
					local fuckyou = ang:RotateAroundAxis(Vector(0,0,1),180)
					self.doll:SetAngles(ang)
					
					self.doll:Spawn()
					self.doll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
					self.doll:Fire("fadeandremove",1,10)
					
					SafeRemoveEntity(self.attachment)
				end)
				self:PlaySequenceAndWait("ragdoll_grabC")
				
				self.Grab_DidSucceed = false
				self.Grab_IsGrabbing = false
				self:CustomIdle()
			else
				self:snd("re2/em6200/step"..self:rnd(5)..".mp3",6/30)
				coroutine.wait(1)
				self.Grab_IsGrabbing = false
				self:ResetSequence(self.WalkAnim)
				self.loco:SetDesiredSpeed(self.Speed)
			end
		end
	end
end
function ENT:CustomIdle()
	self:ResetSequence("0000")
end
function ENT:CustomRunBehaviour()end
function ENT:OnKilled(dmginfo)
	ErrorNoHalt("Tyrant [Index: "..self:EntIndex().."] just died! This shouldn't happen!")
	SafeRemoveEntity(self)
end
function ENT:OnInjured(dmginfo)
	if self:GetSequence() == self:LookupSequence("2201") then dmginfo:ScaleDamage(0) return end
	-- Don't react to damage at all if we're down.
	
		if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() then
			local hitgroup = dmginfo:GetAttacker():GetEyeTrace().HitGroup
			if hitgroup == HITGROUP_HEAD and not self.ShotOffHat then
				self:SetBodygroup(2,1)
				local hat = ents.Create("prop_physics")
				hat:SetModel("models/roach/re2/tyrant_hat.mdl")
				hat:SetPos(self:GetAttachment(2).Pos)
				hat:SetAngles(self:GetAngles())
				hat:Spawn()
				hat:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				self:DeleteOnRemove(hat)
				
				local phys = hat:GetPhysicsObject()
				phys:SetVelocity((self:GetForward()*-150) + (self:GetUp()*150))
				phys:AddAngleVelocity(Vector(0, 500, 0))
				
				self.ShotOffHat = true
			end
			if hitgroup == HITGROUP_RIGHTARM and dmginfo:GetDamage() > 100 then
				self.CanAttack = false
				self:RestartGesture(ACT_GESTURE_FLINCH_RIGHTARM)
				timer.Simple(65/30, function() self.CanAttack=true end)
			end
			if hitgroup == HITGROUP_LEFTARM and dmginfo:GetDamage() > 100 then
				self.CanAttack = false
				self:RestartGesture(ACT_GESTURE_FLINCH_LEFTARM)
				timer.Simple(65/30, function() self.CanAttack=true end)
			end
		end	
	self.HiddenHealth = self.HiddenHealth - dmginfo:GetDamage()
	dmginfo:ScaleDamage(0)
	if dmginfo:GetDamageType() == DMG_SHOCK then 
		self.CanCommitDie = true 
		self.IsShocked = true 
	else
		if self.HiddenHealth <= 0 then
			self.HiddenHealth = 5000
			if self.PissedOff then
				self:DoChangeWalk()
				self.PissedOff = false
			end
			self.CanCommitDie = true
		else
			if !self.PissedOff and self:GetSequence() == self:LookupSequence("0200") then
				self:DoChangeRun()
				self.PissedOff = true
			end
			
			if dmginfo:IsExplosionDamage() then self.CanFlinch = true end
		end
	end
end
function ENT:DoChangeWalk()
	self.WalkAnim = "0200"
	self.Speed = 105
end
function ENT:DoChangeRun()
	self.WalkAnim = "0500"
	self.Speed = 155
end
function ENT:Taunt()
	if not self.CanTaunt then return end
	
	self.CanAttack = false
	self.CanTaunt = false
	
	local mtaunt = math.random(1,3)
	if mtaunt == 1 then -- neck crack
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",0)
		self:snd("re2/em6200/foley_adjust_hat"..self:rnd(2)..".mp3",0.7)
		self:snd("re2/em6200/foley_adjust_hat"..self:rnd(2)..".mp3",1)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",1.2)
		
		self:RestartGesture(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
		timer.Simple(83/30,function()
			self.CanAttack = true
		end)
	elseif mtaunt == 2 then -- fist bump
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",0)
		self:snd("re2/em6200/foley_taunt"..self:rnd(2)..".mp3",0.4)
		self:snd("re2/em6200/land.mp3",0.7)
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",1.2)
		
		self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
		timer.Simple(54/30,function()
			self.CanAttack = true
		end)
	elseif mtaunt == 3 then -- chin crack? idk
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",0)
		self:snd("re2/em6200/foley_adjust_hat"..self:rnd(2)..".mp3",0.7)
		self:snd("re2/em6200/foley_adjust_hat"..self:rnd(2)..".mp3",1)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",1.2)
		
		self:RestartGesture(ACT_GMOD_GESTURE_RANGE_ZOMBIE_SPECIAL)
		timer.Simple(67/30,function()
			self.CanAttack = true
		end)
	end
end
function ENT:Flinch()
	if not self.CanFlinch then return end
	
	self.CanAttack = false
	self.CanFlinch = false
	
	local flinch = math.random(1,3)
	if flinch == 1 then
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",0)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",0.35)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",0.55)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",2)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",2.5)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3.4)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3.8)
		
		self:PlaySequenceAndWait("9050")
		self:ResetSequence(self.WalkAnim)
		self.loco:SetDesiredSpeed(self.Speed)
		self.CanAttack = true
	elseif flinch == 2 then
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",0)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",0.35)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",0.55)
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",1)
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",1.5)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3.2)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3.7)
		
		self:PlaySequenceAndWait("9060")
		self:ResetSequence(self.WalkAnim)
		self.loco:SetDesiredSpeed(self.Speed)
		self.CanAttack = true
	elseif flinch == 3 then
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",0)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",0.5)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",0.8)
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",1)
		self:snd("re2/em6200/foley"..self:rnd(3)..".mp3",1.5)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3)
		self:snd("re2/em6200/step"..self:rnd(5)..".mp3",3.5)
		
		self:PlaySequenceAndWait("9061")
		self:ResetSequence(self.WalkAnim)
		self.loco:SetDesiredSpeed(self.Speed)
		self.CanAttack = true
	end
end
function ENT:CommitDie()
	if not self.CanCommitDie then return end
	
	self.CanAttack = false
	self.CanCommitDie = false
	self.IsDead = true
	
	if self.IsShocked then
		self.IsShocked = false
		
		local fx = EffectData()
		fx:SetEntity(self)
		fx:SetOrigin(self:LocalToWorld(Vector(0,0,50)))
		fx:SetStart(self:LocalToWorld(Vector(0,0,50)))
		fx:SetScale(1)
		fx:SetMagnitude(10)
		for i=1,math.Round(162/30,1)*10 do
			timer.Simple(0.1*i,function()
				if !IsValid(self) then return end
				self:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav")
				util.Effect("teslahitboxes",fx)
			end)
		end
		self:snd("re2/em6200/step"..self:rnd(6)..".mp3",6/30)
		self:snd("re2/em6200/step"..self:rnd(6)..".mp3",14/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",43/30)
		self:snd("darksouls/npc/fsb.frpg_c2300/s230012302.wav.mp3",5.4)		
		self:PlaySequenceAndWait("2251")
		
		ParticleEffect("hunter_projectile_explosion_1",self:LocalToWorld(Vector(0,0,50)),Angle(0,0,0),nil)
		self:snd("re2/em6200/step"..self:rnd(6)..".mp3",44/30)
		self:snd("re2/em6200/land.mp3",72/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",72/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",72/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",72/30)
		self:PlaySequenceAndWait("2252")
	else
		self:snd("re2/em6200/step"..self:rnd(6)..".mp3",18/30)
		self:snd("re2/em6200/land.mp3",43/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",43/30)
		self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",43/30)
		self:PlaySequenceAndWait("2200")
		
		self:ResetSequence("2201")	
		coroutine.wait(30)
	end
	
	self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",0)
	self:snd("re2/em6200/foley_adjust_hat"..self:rnd(2)..".mp3",40/30)
	self:snd("re2/em6200/step"..self:rnd(6)..".mp3",83/30)
	self:snd("re2/em6200/foley_adjust_hat"..self:rnd(2)..".mp3",83/30)
	self:snd("re2/em6200/step"..self:rnd(6)..".mp3",121/30)
	self:snd("re2/em6200/foley_long"..self:rnd(2)..".mp3",121/30)
	self:PlaySequenceAndWait("2202")
	
	self.CanAttack = true
	self:ResetSequence(self.WalkAnim)
	self.loco:SetDesiredSpeed(self.Speed)
end
--[[-------------------------------------------------------]]--
function ENT:Initialize()
	self:CustomInit()
	self:SetHealth(self.health)
	self:SetModel(self.Model)
	self.LoseTargetDist	= 250000000 
	self.SearchRadius 	= 999000000 
	if SERVER then 
		-- self:SetLagCompensated(true)
		self.loco:SetStepHeight(35)
		self.loco:SetAcceleration(900)
		self.loco:SetDeceleration(900)
	end 
end

function ENT:BodyUpdate()
	if self:GetSequence() == self:LookupSequence("0200") or self:GetSequence() == self:LookupSequence("0500") then
		self:BodyMoveXY()
	else
		self:FrameAdvance()
	end
end
-----------------------------------------------------------------------------------------
local function validtarget(ent)
	return IsValid(ent) and (ent:IsPlayer() or ent:IsNPC())
end
function ENT:CalculateNextRetarget(target, dist)
	return math.Clamp(dist/200, 3, 15) -- 1 second for every 100 units to the closet player
end
-- Lets your determine what target to go for next upon retargeting
function ENT:SelectTarget()
	local mindist = math.huge
	local target
	for k,v in pairs(player.GetAll()) do
		local d = self:GetRangeTo(v)
		if d < mindist and self:AcceptTarget(v) then
			target = v
			mindist = d
		end
	end

	return target, mindist
end

function ENT:AcceptTarget(t)return IsValid(t) and (t:IsPlayer() or t:IsNPC())end
function ENT:GetTarget()return self.Target end
function ENT:SetTarget(ent)if self:AcceptTarget(ent) then self.Target = ent	return true else return false end end

AccessorFunc(ENT, "m_bTargetLocked", "TargetLocked", FORCE_BOOL) 
-- Stops the Zombie from retargetting and keeps this target while it is valid and targetable
function ENT:SetNextRetarget(time) self.NextRetarget = CurTime() + time end -- Sets the next time the Zombie will repath to its target
function ENT:ForceRepath() self.NextRepath = 0 end

function ENT:HaveTarget()
	if (self:GetTarget() and IsValid(self:GetTarget())) then 
		if (self:GetRangeTo(self:GetTarget():GetPos()) > self.LoseTargetDist or 700) then 
			return self:FindTarget()
		end 
		return true 
	else 
		return self:FindTarget()
	end 
end
function ENT:FindTarget()
	local _ents = ents.FindInSphere(self:GetPos(), self.SearchRadius or 700)
		for k,v in pairs(_ents) do 
			if (v:IsPlayer() and v:Alive()) and self:AcceptTarget(v) then 
				self:SetTarget(v)
				return true 
			end 
		end 
	self:SetTarget(nil)self:CustomIdle()
	return false 
end
-----------------------------------------------------------------------------------------
function ENT:SpawnIn()
	if !SERVER then return end
	local nav = navmesh.GetNearestNavArea(self:GetPos())
	if !self:IsInWorld() or !IsValid(nav) or nav:GetClosestPointOnArea(self:GetPos()):DistToSqr(self:GetPos()) >= 10000 then 
		for k,v in pairs(player.GetAll()) do
			if (string.find(v:GetUserGroup(),"admin")) then
				v:PrintMessage(HUD_PRINTTALK,"Nextbot ["..self:GetClass().."]["..self:EntIndex().."] spawned too far away from a navmesh!")
			end
		end
		SafeRemoveEntity(self)
	end 
	self:OnSpawn()
end
function ENT:RunBehaviour()
	self:SpawnIn()
	while (true) do
		self:CustomRunBehaviour()
		if (self:HaveTarget()) then 
			self.loco:SetDesiredSpeed(self.Speed)
			self:ResetSequence(self.WalkAnim)
			self:ChaseTarget()
		else 
			self:CustomIdle()
			self:FindTarget()
		end
		coroutine.wait(2)
	end
end

function ENT:ChaseTarget(options)
	local options = options or {}
	local path = Path("Follow")
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	if IsValid(self:GetTarget()) then
		path:Compute(self, self:GetTarget():GetPos())
	else
		print("Something removed the Target prematurely so this overly-long message is being printed to your console so that you can be safe in the knowledge the problem was not caused by you and was in-fact caused by the idiotic developer it was probably Roach he's dumb like that LOL XD\n\n")
		SafeRemoveEntity(self)
	end
	if (!path:IsValid()) then return "failed" end
	while (path:IsValid() and self:HaveTarget()) do

		if (path:GetAge() > 0.1) then	
			if IsValid(self:GetTarget()) then
				path:Compute(self, self:GetTarget():GetPos())
			else
				print("Something removed the Target prematurely so this overly-long message is being printed to your console so that you can be safe in the knowledge the problem was not caused by you and was in-fact caused by the idiotic developer it was probably Roach he's dumb like that LOL XD\n\n")
				SafeRemoveEntity(self)
			end
		end
		path:Update(self)	
		if (options.draw) then path:Draw() end
		if (self.loco:IsStuck()) then
			self:HandleStuck()
			return "stuck"
		end	
		
		self:CustomChaseTarget(self:GetTarget())
		
		coroutine.yield()
	end
	return "ok"
end

-- Helper funcs
function ENT:Helper_Attack(victim,delay,sequence,damage,damageradius,hitsound)
	local v = victim

	if (IsValid(v) and (v:IsPlayer() && v:Alive())) then
		if not (v:IsValid() && v:Health() > 0) then return end
		timer.Simple(delay,function()
			if !IsValid(self) then return end
			if !IsValid(v) then return end
			for k,ent in pairs(ents.FindInSphere(self:LocalToWorld(Vector(damageradius,0,0)),damageradius)) do
				if table.HasValue(self.AllyNPCTable,ent:GetClass()) then
					ent:TakeDamage(10000,self)
					if IsValid(self) then
						self:EmitSound(hitsound)
						self.CanTaunt = true
					end
				end
			end
			if self:GetRangeTo(v:GetPos()) > damageradius then return end
			self:EmitSound(hitsound)
			v:TakeDamage(damage,self)
			v:ViewPunch(Angle(-300,0,0))
			if math.random(1,5) <= 3 then
				self.CanTaunt = true
			end
			
			-- unstuck code in-case the player is gay
				if self:GetRangeTo(v:GetPos()) < 70 then
					self:SetNotSolid(true)
						self:CollisionBounce(70,256)
					timer.Simple(0.5,function()self:SetNotSolid(false)end)
				end
			--
		end)
		if sequence != "" then
			self:PlaySequenceAndWait(sequence)
			self:ResetSequence(self.WalkAnim)
		end
	end
end

function ENT:CollisionBounce(radius,force) -- Internal use only, for moving players out of the way.
   for k, target in pairs(ents.FindInSphere(self:GetPos(),radius)) do
      if IsValid(target) then
         local tpos = target:LocalToWorld(target:OBBCenter())
         local dir = (tpos - self:GetPos()):GetNormal()
         local phys = target:GetPhysicsObject()

         if target:IsPlayer() then
            local push = dir * force
            local vel = target:GetVelocity() + push
			vel.z = 1
            target:SetVelocity(vel)
         end
      end
   end
end
function ENT:PlaySequenceAndSetPos(anim)
	self.loco:SetDesiredSpeed(0)
	self:SetSequence(anim)
	self:SetCycle(0)
	self:SetPlaybackRate(1)
	self:ResetSequenceInfo()
		local seq,dur = self:LookupSequence(anim)
		local ga,gb,gc = self:GetSequenceMovement(seq,0,1)
		if not ga then print("ga failed") return end -- The animation has no locomotion or it's invalid or we failed in some other way.
				
		local pos = self:GetPos()
		local gd_prev = 0
		local cbmin_prev = Vector(-14,-20,0)
		local cbmax_prev = Vector(15,20,93)
		
		self:SetCollisionBounds(Vector(-1,-1,0), Vector(1,1,1))
		
		for i=1,dur*100 do 
			timer.Simple(0.01*i,function()
				if !IsValid(self) then return end
				local gd_cur = self:GetCycle()
				local ga2,gb2,gc2 = self:GetSequenceMovement(seq,gd_prev,gd_cur)
				gd_prev = gd_cur

				if (not ga2) or (gb2 == Vector(0,0,0)) or (gd_cur==0) or (!util.IsInWorld(self:LocalToWorld(gb2))) then return end
				
				local tr=util.TraceLine({
				    start=self:LocalToWorld(gb2)+Vector(0,0,10),
				    endpos=self:LocalToWorld(gb2),
				    filter=self
				})
				
				self:SetPos(tr.HitPos)
				-- self:SetAngles(self:LocalToWorldAngles(gc2))
			end)
		end
	coroutine.wait(dur)
	self:SetCollisionBounds(cbmin_prev, cbmax_prev)
	self:ResetSequence(self.WalkAnim)
	self.loco:SetDesiredSpeed(self.Speed)
end
function ENT:DirectPoseParametersAt(pos, pitch, yaw, center)
	if isentity(pos) then
		return self:DirectPoseParametersAt(pos:WorldSpaceCenter(), pitch, yaw)
	elseif isvector(pos) then
		center = center or self:WorldSpaceCenter()
		local angle = (pos - center):Angle()
		self:SetPoseParameter(pitch, math.AngleDifference(angle.p, self:GetAngles().p))
		self:SetPoseParameter(yaw, math.AngleDifference(angle.y, self:GetAngles().y))
	else
		self:SetPoseParameter(pitch, 0)
		self:SetPoseParameter(yaw, 0)
	end
end