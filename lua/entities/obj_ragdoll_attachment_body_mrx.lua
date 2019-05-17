AddCSLuaFile()

ENT.Type   = "anim"

// Thanks to Parakeet for this entity, modified for NPC usage.

function ENT:Initialize()
	self:SetModel("models/props_junk/PopCan01a.mdl")
	if SERVER then
		self:Fire("setparentattachment","tag_ragdoll_attach", 0)
		self.CanDetach = false

		self.attachId = self:GetParent():LookupAttachment("tag_ragdoll_attach")
		local attachment = self:GetParent():GetAttachment(self.attachId)

		self.doll=ents.Create("prop_ragdoll")
		self.doll:SetModel(self.model)
		self.doll:SetPos(attachment.Pos+(self:GetParent():GetForward()*5))
		self.doll:Spawn()
		self.doll:SetCollisionGroup(COLLISION_GROUP_WORLD)
		
		local phy = self.doll:GetPhysicsObject()
		if IsValid(phy) then
			-- phy:SetMass(1)
			phy:EnableDrag(false)
		end
		
		self:DeleteOnRemove(self.doll)

		local boneId = self.doll:TranslateBoneToPhysBone(self.doll:LookupBone("ValveBiped.Bip01_Head1"))
		self.bone = self.doll:GetPhysicsObjectNum(boneId)
		self.bone:SetAngles(self.bone:RotateAroundAxis(Vector(0,0,1),180))
		self.bone:EnableMotion(false)
	end
end

function ENT:Think()
	if SERVER and IsValid(self.doll) then
		if self.CanDetach then 
			self.bone:EnableMotion(true)
			if self.doll:GetManipulateBoneScale(self.doll:LookupBone("ValveBiped.Bip01_Head1")) == Vector(1,1,1) then
				self.doll:ManipulateBoneScale(self.doll:LookupBone("ValveBiped.Bip01_Head1"), Vector(0,0,0))
			end
		return end
		
		local attachment = self:GetParent():GetAttachment(self.attachId)
		self.bone:SetPos(attachment.Pos+(self:GetParent():GetForward()*10))
		
		for bonelim = 1,128 do -- 128 = Bone Limit
			local childphys = self:GetPhysicsObjectNum(bonelim)
			if IsValid(childphys) then
				local childphys_bonepos, childphys_boneang = self:GetBonePosition(ent:TranslatePhysBoneToBone(bonelim))
				if (childphys_bonepos) then 
					-- childphys:SetDamping(1000,1000)
					childphys:SetAngleDragCoefficient(100000)
				end
			end
		end

		self:NextThink(CurTime())
		return true
	end
end

function ENT:Draw()

end