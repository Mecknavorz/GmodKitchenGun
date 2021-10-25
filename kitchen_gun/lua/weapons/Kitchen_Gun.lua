AddCSLuaFile()



--swep basic info
SWEP.PrintName	= "Kitchen Gun"
SWEP.Author	= "Mecknavorz the Dragoness"
SWEP.Contact = "bottest9@gmail.com"
SWEP.Purpose = "SAY GOODBYE TO DAILY STAINS AND DIRT SURFACES"
SWEP.Category = "Cleaning Supplies"


--menu options
SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
--icon stuff
resource.AddFile( "materials/vgui/entities/weapon_kitchengun" )

--who can spawn it
SWEP.Spawnable = true
SWEP.AdminOnly = false
--other spawn stuff
SWEP.Weight = 5 --Priority when the weapon your currently holding drops
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false


--view model options
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 80
SWEP.ViewModel			= "models/weapons/c_synergy_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_synergy_deagle.mdl"
SWEP.UseHands           = true
SWEP.HoldType = "Pistol" 


--attack properties
SWEP.Base = "weapon_base"

--primary fire information
local ShootSound = Sound("weapons/kitchen_fire.wav")
SWEP.Primary.Damage = 50 --The amount of damage will the weapon do
SWEP.Primary.TakeAmmo = 1 -- How much ammo will be taken per shot
SWEP.Primary.ClipSize = 9  -- How much bullets are in the mag
SWEP.Primary.Ammo = "357" --The ammo type will it use
SWEP.Primary.DefaultClip = 9 -- How much bullets preloaded when spawned
SWEP.Primary.Spread = 0.1 -- The spread when shot
SWEP.Primary.NumberofShots = 1 -- Number of bullets when shot
SWEP.Primary.Automatic = false -- Is it automatic
SWEP.Primary.Recoil = .5 -- The amount of recoil
SWEP.Primary.Delay = 2 -- Delay before the next shot
SWEP.Primary.Force = 10

--basically same as above but since we don't shoot anything we don't need to fill out as much stuff
SWEP.Secondary.NumShots = 1
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

--reload properties
SWEP.FiresUnderwater = true
SWEP.ReloadSound = "Weapon_Pistol.Reload"
SWEP.CSMuzzleFlashes = true


--swep functions and whatnot
function SWEP:Initialize()
	--load our sounds
	util.PrecacheSound(ShootSound) 
	util.PrecacheSound(self.ReloadSound)
	--play kitchen gun sound
	self:EmitSound("weapons/kitchen_equip.wav")
	--sets oour hold type
	self:SetWeaponHoldType( self.HoldType )
	--to give the sound enough time to play
	self:SetNextPrimaryFire(CurTime() + 4.3) 
end

--the normal bullet stuff
--put in a seprate function because I wanna fire 3 times
function SWEP:Bullet()
	local bullet = {} 
	bullet.Num = self.Primary.NumberofShots --line 83
	bullet.Src = self.Owner:GetShootPos() 
	bullet.Dir = self.Owner:GetAimVector() 
	bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
	bullet.Tracer = 4
	bullet.Force = self.Primary.Force 
	bullet.Damage = self.Primary.Damage 
	bullet.AmmoType = self.Primary.Ammo 
	--print(self)
	local rnda = self.Primary.Recoil * -1 
	local rndb = self.Primary.Recoil * math.random(-1, 1) 
	 
	self:ShootEffects()
	 
	self.Owner:FireBullets( bullet ) 
	self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
	self:TakePrimaryAmmo(self.Primary.TakeAmmo) 
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self:EmitSound(ShootSound)
	self:Bullet()
	--print("bang! " .. CurTime()) --for debugging
	timer.Simple( .4, function() self:Bullet() end )
	timer.Simple( .8, function() self:Bullet() end )
	self:SetNextPrimaryFire(CurTime()+self.Primary.Delay) 
end 

function SWEP:SecondaryAttack()
	-- there isn't a real secondary fire instead the gun will play a random Derick Bum line
	local line = math.random(6, 0) --generate a number 1-5 to decide which voiceline to play
	--print(line) --for debugging
	if line == 1 then
		self:EmitSound("weapons/kitchen_extra1.wav")
	elseif line == 2 then
		self:EmitSound("weapons/kitchen_extra2.wav")
	elseif line == 3 then
		self:EmitSound("weapons/kitchen_extra3.wav")
	elseif line == 4 then
		self:EmitSound("weapons/kitchen_extra4.wav")
	else
		self:EmitSound("weapons/kitchen_extra5.wav")
	end
	--a delay to prevent spam
	self:SetNextSecondaryFire( CurTime() + 3 )
end

function SWEP:Reload()
	if ( self:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		self.Weapon:DefaultReload( ACT_VM_RELOAD );
		self:EmitSound(Sound(self.ReloadSound))
	end
end

function SWEP:KillSounds()
	if ( self.BeatSound ) then self.BeatSound:Stop() self.BeatSound = nil end
	if ( self.LoopSound ) then self.LoopSound:Stop() self.LoopSound = nil end
end

function SWEP:Holster()
	self:KillSounds()
	return true
end

function SWEP:OnRemove()
	self:KillSounds()
end

function SWEP:OnDrop()
	self:KillSounds()
end