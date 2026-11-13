-- LocalScript в StarterPlayer -> StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
SoundService.DopplerScale = 0

local SCRIPT_NAME = "DLCNever"
local SCRIPT_VERSION = "v8.0"

local Connections = {}
local isUnloaded = false
local activeTab = "Standart"
local UIUpdaters = {}

-- Библиотека звуков попадания (6 вариантов)
local HitSoundOrder = {"Skeet", "Neverlose", "Bameware", "Bubble", "Laser", "Click"}
local HitSounds = {
	Skeet = "rbxassetid://4817809188",
	Neverlose = "rbxassetid://6607204501",
	Bameware = "rbxassetid://3124331820",
	Bubble = "rbxassetid://6534947588",
	Laser = "rbxassetid://5869422451",
	Click = "rbxassetid://4499400560"
}

-- Палитры тем оформления (ImGui Classic установлена по умолчанию)
local Themes = {
	ImGuiClassic = {
		Name = "ImGui Classic (Default)",
		MainBg = Color3.fromRGB(18, 20, 24),
		TitleBg = Color3.fromRGB(30, 56, 92),
		Accent = Color3.fromRGB(66, 150, 250),
		TabBg = Color3.fromRGB(24, 27, 33),
		Border = Color3.fromRGB(58, 64, 74),
		Corner = 0
	},
	MaterialLavender = {
		Name = "Material You (Lavender)",
		MainBg = Color3.fromRGB(24, 21, 32),
		TitleBg = Color3.fromRGB(58, 48, 86),
		Accent = Color3.fromRGB(168, 130, 255),
		TabBg = Color3.fromRGB(32, 28, 44),
		Border = Color3.fromRGB(85, 74, 118),
		Corner = 10
	},
	MaterialSage = {
		Name = "Material You (Sage)",
		MainBg = Color3.fromRGB(20, 26, 23),
		TitleBg = Color3.fromRGB(40, 66, 54),
		Accent = Color3.fromRGB(122, 214, 168),
		TabBg = Color3.fromRGB(27, 35, 31),
		Border = Color3.fromRGB(64, 96, 80),
		Corner = 10
	},
	CatppuccinMocha = {
		Name = "Catppuccin Mocha",
		MainBg = Color3.fromRGB(30, 30, 46),
		TitleBg = Color3.fromRGB(49, 50, 68),
		Accent = Color3.fromRGB(203, 166, 247),
		TabBg = Color3.fromRGB(36, 39, 58),
		Border = Color3.fromRGB(88, 91, 112),
		Corner = 8
	},
	CyberpunkNeon = {
		Name = "Cyberpunk Neon",
		MainBg = Color3.fromRGB(14, 15, 26),
		TitleBg = Color3.fromRGB(115, 22, 68),
		Accent = Color3.fromRGB(255, 48, 135),
		TabBg = Color3.fromRGB(22, 24, 40),
		Border = Color3.fromRGB(0, 210, 235),
		Corner = 2
	},
	NordicFrost = {
		Name = "Nordic Frost",
		MainBg = Color3.fromRGB(36, 41, 51),
		TitleBg = Color3.fromRGB(59, 66, 82),
		Accent = Color3.fromRGB(136, 192, 208),
		TabBg = Color3.fromRGB(46, 52, 64),
		Border = Color3.fromRGB(76, 86, 106),
		Corner = 6
	},
	ObsidianGold = {
		Name = "Obsidian & Gold",
		MainBg = Color3.fromRGB(15, 15, 17),
		TitleBg = Color3.fromRGB(68, 52, 20),
		Accent = Color3.fromRGB(235, 180, 55),
		TabBg = Color3.fromRGB(24, 24, 28),
		Border = Color3.fromRGB(125, 96, 38),
		Corner = 4
	},
	GameSenseGreen = {
		Name = "GameSense Green",
		MainBg = Color3.fromRGB(17, 21, 18),
		TitleBg = Color3.fromRGB(32, 74, 38),
		Accent = Color3.fromRGB(95, 195, 65),
		TabBg = Color3.fromRGB(24, 30, 25),
		Border = Color3.fromRGB(55, 85, 58),
		Corner = 0
	}
}

-- Конфигурация всех 13 вкладок
local Config = {
	-- === STANDART TAB ===
	MultSpeedEnabled = true,
	GlobalMultSpeed = 1.0,

	AutoSprint = false,
	AutoSprintSpeed = 24,
	NoJumpCooldown = false,

	BunnyHop = false,
	BhopBoost = 2.0,
	BhopMaxSpeed = 50,
	BhopKeepMomentum = 0.98,

	AirStrafe = false,
	StrafeAccel = 2.8,
	StrafeMaxSpeed = 55,
	StrafeAirControl = 1.0,

	CrouchJump = false,
	CrouchJumpBonus = 1.18,

	EdgeJump = false,
	EdgeJumpOffset = 0.4,
	EdgeJumpBoost = 1.05,

	EdgeBug = false,
	EdgeBugBounce = 4.0,
	EdgeBugMinFall = 18,
	EdgeBugSpeedMult = 1.08,

	JumpBug = false,
	JumpBugMult = 1.15,
	JumpBugMinFall = 15,
	JumpBugSpeedBonus = 2.0,

	SurfGlide = false,
	SurfAccel = 35,
	SurfMaxSpeed = 95,

	RampLaunch = false,
	RampLaunchMult = 1.25,

	LedgeVault = false,
	VaultUpPower = 38,
	VaultForwardPush = 24,

	QuickTurn180 = false,
	TurnMomentumKeep = 0.95,

	-- === ANTI-AIM TAB (РАСШИРЕННЫЙ + MANUAL AA НА 8 И 9) ===
	AntiAimEnabled = false,
	AA_AtTargets = false,
	AA_Freestanding = false,
	AA_ManualEnabled = true,     -- Manual AA: 8 = Направо (-90), 9 = Налево (+90)
	AA_ManualMode = "Static",    -- "Static", "Jitter", "Spin", "Sway"
	AA_InvertKeyEnabled = true,  -- Инверсия стороны по клавише F
	AA_BaseYaw = 180,
	AA_YawModifier = "Static",   -- "Static", "Spin", "Jitter", "3-Way", "Ping-Pong", "Random", "Sway"
	AA_SpinSpeed = 720,
	AA_JitterRange = 65,
	AA_JitterSpeed = 30,
	AA_DynamicJitterSpeed = false, -- Ускорение джиттера при движении
	AA_AirMode = "Same",         -- "Same", "Air Spin", "Air Jitter", "Air 180"
	AA_OnShotFlick = false,      -- Резкий отворот модели в момент выстрела
	AA_OnShotAngle = 140,
	AA_PitchMode = "None",       -- "None", "Down", "Up", "Zero", "Jitter", "SpinPitch", "Custom"
	AA_CustomPitch = -45,
	AA_BodyLean = "None",        -- "None", "Left", "Right", "Jitter"
	AA_RollAngle = 0,
	AA_LegMode = "Default",      -- "Default", "Slide", "JitterLegs", "Moonwalk"
	AA_SlowWalk = false,
	AA_SlowWalkSpeed = 7,
	AA_FakeDuck = false,
	AA_ShowArrows = true,        -- Показывать индикаторы Manual AA (< 9 | 8 >) и стрелку Yaw
	AA_FakeLagTicks = 0,

	ThirdPersonEnabled = false,
	ThirdPersonDistance = 12,
	ThirdPersonHeight = 1.5,
	ThirdPersonKey = Enum.KeyCode.C,

	-- === VISUALS TAB ===
	MissLogEnabled = true,
	HitLogEnabled = true,
	LogDuration = 4.5,
	LogMaxLines = 7,

	AspectRatioEnabled = false,
	AspectRatioValue = 0.75,

	WhiteDotCrosshair = true,
	DotSize = 4,
	DotOutlineThickness = 1,

	DynamicFOV = false,
	BaseFOV = 70,
	MaxBonusFOV = 28,

	LandingPredictor = false,
	VelocityVector3D = false,
	SpeedTrail = false,

	-- === WEAPONS TAB ===
	AimbotEnabled = false,
	AimbotRequireRMB = true,
	AimbotFOV = 180,
	AimbotMaxDistance = 800,
	AimbotSmoothness = 4.0,
	AimbotSmoothCurve = "Linear",
	AimbotTargetHead = true,
	AimbotWallCheck = true,
	AimbotAutoSwitch = true,
	AimbotPrediction = 0.12,
	ShowAimbotFOV = false,

	BaimEnabled = false,
	BaimCondition = "Always",
	BaimHPThreshold = 50,

	ResolverEnabled = false,
	ResolverMode = "Auto-Bruteforce",

	SilentAim = false,
	SilentAutoFire = false,
	SilentAutoFireDelay = 0.06,
	SilentAimFOV = 220,
	SilentHitChance = 100,
	SilentTargetHead = true,
	SilentMultiPoint = false,
	SilentWallCheck = false,
	SilentPrediction = 0.1,
	ShowSilentFOV = false,

	RapidFire = false,
	NoRecoil = true,
	NoSpread = true,
	Triggerbot = false,
	TriggerDelay = 0.05,
	MultiTapCount = 1,
	AlwaysHeadshot = false,
	Wallbang = false,
	BypassForceField = true,
	ChainLightning = false,
	ChainLightningRadius = 18,
	RicochetBounces = 0,
	FreezeTargetTime = 0,
	ExplosiveBullets = false,
	ExplosionRadius = 12,
	DamageMultiplier = 1.0,
	BulletSpeed = 480,
	BulletGravityDrop = 0,
	VampirismPercent = 0,
	KnockbackForce = 0,
	HitmarkerEnabled = true,

	HitSoundEnabled = true,
	HitSoundType = "Skeet",
	HitSoundVolume = 1.0,
	HitSoundPitch = 1.1,

	KnifeReach = 9,
	KnifeBackstabMult = 3.0,
	KnifeLungeForce = 35,

	-- === NM (NEVERMISS) TAB ===
	NM_Enabled = false,
	NM_BypassAllMisses = false,
	NM_HomingBullets = true,
	NM_HomingTurnStrength = 1.0,
	NM_BulletTeleport = false,
	NM_DeadTargetRedirect = true,
	NM_PingCompensation = true,
	NM_BulletTimeFreeze = false,
	NM_OrbitalStrikeKey = false,
	NM_AutoShoot = false,
	NM_AutoShootDelay = 0.08,
	NM_MultiTargetCount = 1,
	NM_TargetBone = "Head",
	NM_SmartBoneFallback = true,
	NM_InfiniteDamage = false,
	NM_IgnoreFOV = true,
	NM_IgnoreWalls = true,
	NM_TargetPriority = "Crosshair",
	NM_AimAssistMagnet = false,
	NM_MagnetStrength = 0.35,
	NM_KillAura = false,
	NM_KillAuraRange = 25,
	NM_TeleportBehindKey = false,
	NM_ShowTargetBeam = true,
	NM_HighlightTarget = true,

	-- === GS (GAMESENSE) TAB ===
	GS_DoubleTap = false,
	GS_HideShots = false,
	GS_PeekAssist = false,
	GS_HitboxExpander = false,
	GS_HitboxSize = 4.5,
	GS_HitboxTransparency = 0.65,
	GS_CrosshairIndicators = true,
	GS_NightMode = false,
	GS_NightBrightness = 0.35,

	-- === RAGE TAB ===
	Rage_OrbitTarget = false,
	Rage_OrbitRadius = 14,
	Rage_OrbitSpeed = 4.5,
	Rage_BlitzTeleport = false,
	Rage_BlitzDelay = 0.22,
	Rage_GravityVortex = false,
	Rage_VortexDistance = 16,
	Rage_AutoDodge = false,
	Rage_DodgePower = 45,
	Rage_ResolverLines = false,

	-- === RADAR TAB ===
	Radar_Enabled = false,
	Radar_Size = 150,
	Radar_Range = 220,
	Radar_ShowGrid = true,

	-- === PLAYER TAB ===
	Player_NoclipKey = false,
	Player_ClickTP = false,
	Player_RainbowSelf = false,
	Player_AutoRegen = false,

	-- === WORLD TAB ===
	World_CustomGravity = false,
	World_GravityValue = 196.2,
	World_Fullbright = false,
	World_NoFog = false,
	World_CustomTime = false,
	World_TimeOfDay = 14,
	World_AmbientPreset = "Default",

	-- === MISC TAB ===
	Misc_AntiAFK = true,
	Misc_NeonRingAura = false,
	Misc_RingRadius = 4.5,
	Misc_AutoJumpHeight = false,
	Misc_JumpHeightVal = 12,

	-- === ESP TAB ===
	ESPEnabled = false,
	ESPShowPlayers = true,
	ESPShowNPCs = true,
	ESPBox = true,
	ESPBoxFill = false,
	ESPCornerBox = false,
	ESPHealthBar = true,
	ESPHealthText = false,
	ESPName = true,
	ESPWeapon = true,
	ESPDistance = true,
	ESPSkeleton = false,
	ESPTracers = false,
	ESPChams = false,
	ESPHeadDot = false,
	ESPMaxDistance = 600,
	ESPChamsTransparency = 0.55,

	-- === MENU SETTINGS & WATERMARK TAB ===
	WatermarkEnabled = true,
	WatermarkClickToggle = true,
	WatermarkShowFPS = true,
	WatermarkShowPing = true,
	WatermarkShowVersion = true,

	MenuOpacity = 0.06,
	MenuCornerRadius = 0, -- ImGui Classic острые углы по умолчанию
	CloseWarningAccepted = false,

	MenuKey = Enum.KeyCode.RightShift
}

-- Состояние персонажа и таймеры
local character, humanoid, rootPart
local neckMotor, originalNeckC0
local waistMotor, originalWaistC0
local legMotors = {}
local origMinZoom = player.CameraMinZoomDistance
local origMaxZoom = player.CameraMaxZoomDistance
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origAmbient = Lighting.Ambient
local origFogEnd = Lighting.FogEnd
local origGravity = Workspace.Gravity

local wasGrounded = false
local lastEdgeBugTime = 0
local lastVaultTime = 0
local lastTriggerTime = 0
local lastSilentFireTime = 0
local lastNMAutoShootTime = 0
local lastKillAuraTime = 0
local lastBlitzTime = 0
local lastDodgeTime = 0
local blitzIndex = 1
local orbitAngle = 0
local peekSavedCFrame = nil
local noclipActive = false

local aaSpinAngle = 0
local aaPitchSpinAngle = 0
local aaJitterTimer = 0
local aaJitterStep = 0
local aaSwayPhase = 0
local aaFakeLagCounter = 0
local aaLastAppliedYaw = 0
local aaManualSide = nil -- nil, "Right" (клавиша 8), "Left" (клавиша 9)
local aaInverted = false
local aaOnShotFlickUntil = 0

local resolverBruteforceIndex = 0
local resolverTargetHistory = {}

local peakSpeed = 0
local currentAirTime = 0
local fpsCounter = 0
local fpsLastUpdate = os.clock()
local currentFPS = 60

local VisualObjects = {}
local GivenTools = {}
local ActiveProjectiles = {}
local ESPPool = {}
local KilledTargetsRegistry = {}
local ResolverLinesPool = {}
local ExpandedHitboxes = {}
local RadarDotsPool = {}
local LogEntries = {}
local hitmarkerAlpha = 0

local currentAccentColor = Themes.ImGuiClassic.Accent

local function getOrCreatePart(name, size, shape, color)
	if VisualObjects[name] and VisualObjects[name].Parent then
		return VisualObjects[name]
	end
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.Material = Enum.Material.Neon
	p.Size = size
	p.Shape = shape or Enum.PartType.Block
	p.Color = color or currentAccentColor
	p.Parent = Workspace
	VisualObjects[name] = p
	return p
end

local function destroyVisual(name)
	if VisualObjects[name] then
		VisualObjects[name]:Destroy()
		VisualObjects[name] = nil
	end
end

local function clearResolverLines()
	for _, line in pairs(ResolverLinesPool) do
		if line then line:Destroy() end
	end
	table.clear(ResolverLinesPool)
end

local function restoreAllHitboxes()
	for part, origData in pairs(ExpandedHitboxes) do
		if part and part.Parent then
			part.Size = origData.size
			part.Transparency = origData.transparency
			part.Material = origData.material
		end
	end
	table.clear(ExpandedHitboxes)
end

local function resetAntiAimJoints()
	if humanoid then
		humanoid.AutoRotate = true
		humanoid.HipHeight = (humanoid.RigType == Enum.HumanoidRigType.R15) and 2.0 or 0
	end
	if neckMotor and originalNeckC0 then
		neckMotor.C0 = originalNeckC0
	end
	if waistMotor and originalWaistC0 then
		waistMotor.C0 = originalWaistC0
	end
	for _, item in ipairs(legMotors) do
		if item.motor and item.motor.Parent then
			item.motor.C0 = item.origC0
		end
	end
end

local function setCharacterLocalTransparency(transp)
	if not character then return end
	for _, desc in ipairs(character:GetDescendants()) do
		if desc:IsA("BasePart") and desc ~= rootPart then
			desc.LocalTransparencyModifier = transp
		elseif desc:IsA("Decal") then
			desc.Transparency = transp
		end
	end
end

local function setupTrail(char)
	destroyVisual("TrailObj")
	destroyVisual("TrailAtt0")
	destroyVisual("TrailAtt1")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(0, 1.2, 0)
	a0.Parent = hrp

	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0, -1.2, 0)
	a1.Parent = hrp

	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.45
	trail.MinLength = 0.1
	trail.FaceCamera = true
	trail.Enabled = Config.SpeedTrail
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.25),
		NumberSequenceKeypoint.new(1, 1.0)
	})
	trail.Parent = hrp

	VisualObjects["TrailAtt0"] = a0
	VisualObjects["TrailAtt1"] = a1
	VisualObjects["TrailObj"] = trail
end

local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")

	neckMotor = nil
	originalNeckC0 = nil
	waistMotor = nil
	originalWaistC0 = nil
	table.clear(legMotors)

	for _, desc in ipairs(char:GetDescendants()) do
		if desc:IsA("Motor6D") then
			if desc.Name == "Neck" then
				neckMotor = desc
				originalNeckC0 = desc.C0
			elseif desc.Name == "Waist" or desc.Name == "RootJoint" then
				if not waistMotor or desc.Name == "Waist" then
					waistMotor = desc
					originalWaistC0 = desc.C0
				end
			elseif desc.Name == "Left Hip" or desc.Name == "Right Hip"
				or desc.Name == "LeftHip" or desc.Name == "RightHip" then
				table.insert(legMotors, {motor = desc, origC0 = desc.C0})
			end
		end
	end

	setupTrail(char)
end

if player.Character then
	setupCharacter(player.Character)
end
table.insert(Connections, player.CharacterAdded:Connect(setupCharacter))

table.insert(Connections, player.Idled:Connect(function()
	if Config.Misc_AntiAFK and not isUnloaded then
		local cam = Workspace.CurrentCamera
		if cam then
			cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(0.1), 0)
		end
	end
end))

local function getSpeedMult()
	return Config.MultSpeedEnabled and Config.GlobalMultSpeed or 1.0
end

local function getJumpVelocity()
	if not humanoid then return 50 end
	if humanoid.UseJumpPower then
		return humanoid.JumpPower
	else
		return math.sqrt(2 * Workspace.Gravity * humanoid.JumpHeight)
	end
end

local function getFloorDistance()
	if not humanoid or not rootPart then return 3.0 end
	return humanoid.HipHeight + (rootPart.Size.Y * 0.5)
end

local function getCurrentPingSeconds()
	local pingMs = 0
	pcall(function()
		pingMs = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	return math.clamp(pingMs / 1000, 0, 0.5)
end

----------------------------------------------------------------------
-- СИСТЕМА ВОСКРЕШЕНИЯ УБИТЫХ ЦЕЛЕЙ
----------------------------------------------------------------------
local function findGroundPositionForModel(model, referencePos)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {model}
	if character then
		table.insert(params.FilterDescendantsInstances, character)
	end

	local rayOrigin = Vector3.new(referencePos.X, referencePos.Y + 6, referencePos.Z)
	local result = Workspace:Raycast(rayOrigin, Vector3.new(0, -100, 0), params)
	if result then
		return result.Position
	end
	return referencePos
end

local function registerKilledTarget(model, hum)
	if not model or not hum then return end
	if not KilledTargetsRegistry[model] then
		local hrp = model:FindFirstChild("HumanoidRootPart")
		local rawPos = hrp and hrp.Position or model:GetPivot().Position
		local groundPos = findGroundPositionForModel(model, rawPos)
		local _, yaw, _ = (hrp and hrp.CFrame or model:GetPivot()):ToOrientation()

		KilledTargetsRegistry[model] = {
			model = model,
			humanoid = hum,
			groundPos = groundPos,
			yaw = yaw
		}
	end
end

local function reviveAllKilledTargets()
	local remote = ReplicatedStorage:FindFirstChild("WeaponDamageRemote")

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= character then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			if hum and (hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead) then
				registerKilledTarget(obj, hum)
			end
		end
	end

	local revivedCount = 0
	for model, data in pairs(KilledTargetsRegistry) do
		if model and model.Parent then
			local hum = data.humanoid or model:FindFirstChildOfClass("Humanoid")
			local hrp = model:FindFirstChild("HumanoidRootPart")

			if hum and hrp then
				revivedCount += 1
				hum.BreakJointsOnDeath = false
				hum.MaxHealth = 100
				hum.Health = 100
				hum.PlatformStand = false
				hum.Sit = false

				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = false
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end
				end

				local hipOffset = hum.HipHeight + (hrp.Size.Y * 0.5)
				local currentGround = findGroundPositionForModel(model, data.groundPos or hrp.Position)
				local uprightCFrame = CFrame.new(currentGround + Vector3.new(0, hipOffset, 0)) * CFrame.Angles(0, data.yaw or 0, 0)

				model:PivotTo(uprightCFrame)
				hrp.CFrame = uprightCFrame
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero

				hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				task.defer(function()
					if hum and hum.Parent then
						hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
						hum:ChangeState(Enum.HumanoidStateType.Running)
					end
				end)

				if remote and remote:IsA("RemoteEvent") then
					remote:FireServer("Revive", hum, 100)
				end
			end
		end
	end

	table.clear(KilledTargetsRegistry)
	return revivedCount
end

----------------------------------------------------------------------
-- ЖУРНАЛ ПРОМАХОВ И ПОПАДАНИЙ (КРУПНЫЙ + С АНИМАЦИЕЙ)
----------------------------------------------------------------------
local missLogContainer

local function pushCombatLog(prefixTag, mainText, accentColor)
	if not missLogContainer or isUnloaded then return end

	local slot = Instance.new("Frame")
	slot.Size = UDim2.new(1, 0, 0, 28)
	slot.BackgroundTransparency = 1
	slot.ClipsDescendants = true
	slot.Parent = missLogContainer

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 1, 0)
	card.Position = UDim2.new(1, 40, 0, 0)
	card.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
	card.BackgroundTransparency = 0.12
	card.BorderSizePixel = 0
	card.Parent = slot

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 4)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = accentColor
	cardStroke.Thickness = 1.2
	cardStroke.Transparency = 0.45
	cardStroke.Parent = card

	local sideBar = Instance.new("Frame")
	sideBar.Size = UDim2.new(0, 4, 1, 0)
	sideBar.BackgroundColor3 = accentColor
	sideBar.BorderSizePixel = 0
	sideBar.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Code
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(242, 245, 250)
	label.TextStrokeTransparency = 0.35
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = string.format("[%s] %s", prefixTag, mainText)
	label.Parent = card

	TweenService:Create(
		card,
		TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 0, 0, 0)}
	):Play()

	table.insert(LogEntries, {
		slot = slot,
		card = card,
		label = label,
		stroke = cardStroke,
		sideBar = sideBar,
		fading = false,
		expiresAt = os.clock() + Config.LogDuration
	})

	while #LogEntries > Config.LogMaxLines do
		local oldest = table.remove(LogEntries, 1)
		if oldest and oldest.slot then
			oldest.slot:Destroy()
		end
	end
end

local function logMiss(targetName, reason)
	if not Config.MissLogEnabled then return end
	if reason == "occlusion" then return end
	local nameStr = targetName or "unknown"
	pushCombatLog("MISS", string.format("missed %s by %s", nameStr, reason), Color3.fromRGB(255, 85, 95))
end

local function logHit(targetName, partName, damage)
	if not Config.HitLogEnabled then return end
	local nameStr = targetName or "target"
	local hitGroup = partName or "body"
	pushCombatLog("HIT", string.format("hit %s in %s (%d dmg)", nameStr, hitGroup, math.floor(damage)), Color3.fromRGB(95, 235, 135))
end

----------------------------------------------------------------------
-- RESOLVER, BAIM, ПРИЦЕЛИВАНИЕ И ОРУЖИЕ
----------------------------------------------------------------------
local WeaponPresets = {
	AK47 = {
		Type = "Gun", Name = "AK-47 [Auto]", Damage = 28, FireRate = 10, Auto = true,
		Pellets = 1, Spread = 0.035, Recoil = 1.6, Range = 450,
		Color = Color3.fromRGB(160, 110, 60), Size = Vector3.new(0.35, 0.45, 2.8)
	},
	AWP = {
		Type = "Gun", Name = "AWP [Sniper]", Damage = 115, FireRate = 1.1, Auto = false,
		Pellets = 1, Spread = 0.002, Recoil = 4.5, Range = 900,
		Color = Color3.fromRGB(55, 95, 65), Size = Vector3.new(0.32, 0.45, 3.6)
	},
	SPAS12 = {
		Type = "Gun", Name = "SPAS-12 [Shotgun]", Damage = 18, FireRate = 1.8, Auto = false,
		Pellets = 8, Spread = 0.09, Recoil = 3.5, Range = 180,
		Color = Color3.fromRGB(55, 58, 64), Size = Vector3.new(0.4, 0.48, 2.5)
	},
	DEAGLE = {
		Type = "Gun", Name = "Deagle [Heavy]", Damage = 55, FireRate = 3.2, Auto = false,
		Pellets = 1, Spread = 0.02, Recoil = 2.8, Range = 350,
		Color = Color3.fromRGB(190, 195, 205), Size = Vector3.new(0.28, 0.4, 1.3)
	},
	MINIGUN = {
		Type = "Gun", Name = "Minigun [Gatling]", Damage = 22, FireRate = 24, Auto = true,
		Pellets = 3, Spread = 0.06, Recoil = 1.2, Range = 500,
		Color = Color3.fromRGB(70, 75, 85), Size = Vector3.new(0.55, 0.55, 3.4)
	},
	KNIFE = {
		Type = "Melee", Name = "Tactical Knife [Melee]", Damage = 45, FireRate = 2.4, Auto = false,
		Color = Color3.fromRGB(45, 48, 54), Size = Vector3.new(0.18, 0.24, 0.7)
	}
}

local hitSoundInstance = Instance.new("Sound")
hitSoundInstance.Name = "HitSoundChannel"
hitSoundInstance.Looped = false
hitSoundInstance.PlaybackSpeed = 1.0
hitSoundInstance.RollOffMaxDistance = 10000
hitSoundInstance.RollOffMinDistance = 10000
hitSoundInstance.Parent = SoundService

local pitchEffect = Instance.new("PitchShiftSoundEffect")
pitchEffect.Octave = Config.HitSoundPitch
pitchEffect.Parent = hitSoundInstance

local function playHitSound(isHeadshot)
	if not Config.HitSoundEnabled then return end
	local soundId = HitSounds[Config.HitSoundType] or HitSounds.Skeet

	hitSoundInstance.SoundId = soundId
	hitSoundInstance.Volume = Config.HitSoundVolume
	hitSoundInstance.PlaybackSpeed = 1.0
	pitchEffect.Octave = math.clamp(isHeadshot and (Config.HitSoundPitch * 1.18) or Config.HitSoundPitch, 0.5, 2.0)

	hitSoundInstance:Stop()
	hitSoundInstance.TimePosition = 0
	hitSoundInstance:Play()
end

local function triggerHitFeedback(isHeadshot)
	if Config.HitmarkerEnabled then
		hitmarkerAlpha = 1.0
	end
	playHitSound(isHeadshot)
end

local function shouldForceBaim(targetModel, targetHum)
	if not Config.BaimEnabled or not targetModel or not targetHum then
		return false
	end
	if Config.BaimCondition == "Always" then
		return true
	elseif Config.BaimCondition == "LowHP" then
		return targetHum.Health <= Config.BaimHPThreshold
	elseif Config.BaimCondition == "InAir" then
		return targetHum.FloorMaterial == Enum.Material.Air
	end
	return false
end

local function resolveTargetPosition(model, aimPart, basePrediction)
	local hrp = model:FindFirstChild("HumanoidRootPart")
	local targetVel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
	local pingBonus = (Config.NM_Enabled and Config.NM_PingCompensation) and getCurrentPingSeconds() or 0
	local totalPred = (basePrediction or 0) + pingBonus

	local rawPos = aimPart.Position + (targetVel * totalPred)

	if not (Config.ResolverEnabled or (Config.NM_Enabled and Config.NM_BypassAllMisses)) or not hrp then
		return rawPos
	end

	local _, curYaw, _ = hrp.CFrame:ToOrientation()
	local prevYaw = resolverTargetHistory[model] or curYaw
	local yawDelta = math.abs(math.deg(curYaw - prevYaw))
	resolverTargetHistory[model] = curYaw

	if yawDelta > 25 or Config.ResolverMode == "Velocity-Align" then
		local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or hrp
		if aimPart.Name == "Head" and torso then
			local headHeightOffset = aimPart.Position.Y - torso.Position.Y
			rawPos = Vector3.new(torso.Position.X, torso.Position.Y + headHeightOffset, torso.Position.Z) + (targetVel * totalPred)
		end
	elseif Config.ResolverMode == "Auto-Bruteforce" then
		local angles = {0, 35, -35, 60, -60}
		local offsetDeg = angles[(resolverBruteforceIndex % #angles) + 1]
		local rotOffset = CFrame.Angles(0, math.rad(offsetDeg), 0) * Vector3.new(0, 0, -0.15)
		rawPos = rawPos + rotOffset
	elseif Config.ResolverMode == "Zero-Pitch" then
		local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or hrp
		if torso then
			rawPos = Vector3.new(torso.Position.X, aimPart.Position.Y, torso.Position.Z) + (targetVel * totalPred)
		end
	end

	return rawPos
end

local function isTargetVisible(camPos, targetPart, targetModel)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local result = Workspace:Raycast(camPos, targetPart.Position - camPos, params)
	if not result then return true end
	return result.Instance:IsDescendantOf(targetModel)
end

local function getIntendedTargetForMissLog(aimDir, rayOrigin)
	local bestModel = nil
	local bestHum = nil
	local bestAngle = 0.85

	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model ~= character then
			local hum = model:FindFirstChildOfClass("Humanoid")
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hum and hrp then
				local toTarget = (hrp.Position - rayOrigin)
				if toTarget.Magnitude > 0.5 then
					local dot = aimDir:Dot(toTarget.Unit)
					if dot > bestAngle then
						bestAngle = dot
						bestModel = model
						bestHum = hum
					end
				end
			end
		end
	end
	return bestModel, bestHum
end

local function findBestAimTarget(fovRadius, maxRange, preferHead, requireVisible, predictionFactor)
	local cam = Workspace.CurrentCamera
	if not cam then return nil, nil end

	local mousePos = UserInputService:GetMouseLocation()
	local bestPart = nil
	local bestPredictedPos = nil
	local bestDist = fovRadius

	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model ~= character then
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local useHead = preferHead and (not shouldForceBaim(model, hum))
				local aimPart = useHead
					and (model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart"))
					or (model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart"))

				if aimPart then
					local worldDist = (aimPart.Position - cam.CFrame.Position).Magnitude
					if worldDist <= maxRange then
						if not requireVisible or isTargetVisible(cam.CFrame.Position, aimPart, model) then
							local predictedPos = resolveTargetPosition(model, aimPart, predictionFactor)

							if Config.SilentMultiPoint and requireVisible and not isTargetVisible(cam.CFrame.Position, aimPart, model) then
								for _, offset in ipairs({Vector3.new(0.8, 0, 0), Vector3.new(-0.8, 0, 0), Vector3.new(0, 0.5, 0)}) do
									local testPos = predictedPos + offset
									local params = RaycastParams.new()
									params.FilterType = Enum.RaycastFilterType.Exclude
									params.FilterDescendantsInstances = {character}
									local res = Workspace:Raycast(cam.CFrame.Position, testPos - cam.CFrame.Position, params)
									if not res or res.Instance:IsDescendantOf(model) then
										predictedPos = testPos
										break
									end
								end
							end

							local screenPos, onScreen = cam:WorldToViewportPoint(predictedPos)
							if onScreen and screenPos.Z > 0 then
								local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
								if dist2D < bestDist then
									bestDist = dist2D
									bestPart = aimPart
									bestPredictedPos = predictedPos
								end
							end
						end
					end
				end
			end
		end
	end

	return bestPart, bestPredictedPos
end

local function findNeverMissTargets(maxCount)
	local cam = Workspace.CurrentCamera
	if not cam or not rootPart then return {} end

	local mousePos = UserInputService:GetMouseLocation()
	local candidates = {}

	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model ~= character then
			local hum = model:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local forceBody = shouldForceBaim(model, hum)
				local boneChoice = forceBody and "Torso" or Config.NM_TargetBone
				if boneChoice == "Random" then
					boneChoice = (math.random(1, 2) == 1) and "Head" or "Torso"
				end

				local aimPart
				if boneChoice == "Head" then
					aimPart = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
				else
					aimPart = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or model:FindFirstChild("HumanoidRootPart")
				end

				if aimPart and not Config.NM_IgnoreWalls and Config.NM_SmartBoneFallback then
					if not isTargetVisible(cam.CFrame.Position, aimPart, model) then
						for _, partName in ipairs({"UpperTorso", "Torso", "HumanoidRootPart", "LeftHand", "RightHand", "LeftFoot", "RightFoot"}) do
							local altPart = model:FindFirstChild(partName)
							if altPart and altPart:IsA("BasePart") and isTargetVisible(cam.CFrame.Position, altPart, model) then
								aimPart = altPart
								break
							end
						end
					end
				end

				if aimPart then
					local visibleOk = Config.NM_IgnoreWalls or isTargetVisible(cam.CFrame.Position, aimPart, model)
					if visibleOk then
						local screenPos, onScreen = cam:WorldToViewportPoint(aimPart.Position)
						local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
						local fovOk = Config.NM_IgnoreFOV or (onScreen and screenPos.Z > 0 and dist2D <= Config.SilentAimFOV)

						if fovOk then
							local score = math.huge
							if Config.NM_TargetPriority == "Crosshair" then
								score = (onScreen and screenPos.Z > 0) and dist2D or (dist2D + 5000)
							elseif Config.NM_TargetPriority == "Distance" then
								score = (aimPart.Position - rootPart.Position).Magnitude
							elseif Config.NM_TargetPriority == "LowestHP" then
								score = hum.Health
							end

							table.insert(candidates, {
								part = aimPart,
								hum = hum,
								model = model,
								score = score
							})
						end
					end
				end
			end
		end
	end

	table.sort(candidates, function(a, b)
		return a.score < b.score
	end)

	local result = {}
	local count = math.min(#candidates, maxCount or 1)
	for i = 1, count do
		result[i] = candidates[i]
	end
	return result
end

local function spawnLightningArc(posA, posB)
	local dist = (posB - posA).Magnitude
	if dist < 0.2 then return end
	local arc = Instance.new("Part")
	arc.Anchored = true
	arc.CanCollide = false
	arc.CanQuery = false
	arc.Material = Enum.Material.Neon
	arc.Color = Color3.fromRGB(110, 210, 255)
	arc.Size = Vector3.new(0.12, 0.12, dist)
	arc.CFrame = CFrame.lookAt(posA, posB) * CFrame.new(0, 0, -dist * 0.5)
	arc.Parent = Workspace
	task.delay(0.12, function()
		if arc then arc:Destroy() end
	end)
end

local function applyDamageToTarget(targetHum, amount, hitPart, impulseDir, skipChain)
	if not targetHum then return end
	local targetModel = targetHum.Parent
	local targetName = targetModel and targetModel.Name or "Target"

	if not humanoid or humanoid.Health <= 0 then
		if not (Config.NM_Enabled and Config.NM_BypassAllMisses) then
			logMiss(targetName, "death local")
		end
		return
	end

	if targetHum.Health <= 0 then
		if Config.NM_Enabled and (Config.NM_DeadTargetRedirect or Config.NM_BypassAllMisses) then
			local backupTargets = findNeverMissTargets(1)
			if #backupTargets > 0 then
				targetHum = backupTargets[1].hum
				hitPart = backupTargets[1].part
				targetModel = backupTargets[1].model
				targetName = targetModel.Name
			else
				return
			end
		else
			logMiss(targetName, "death target")
			return
		end
	end

	if targetModel then
		registerKilledTarget(targetModel, targetHum)
		if Config.BypassForceField then
			for _, child in ipairs(targetModel:GetChildren()) do
				if child:IsA("ForceField") then
					child:Destroy()
				end
			end
		end
	end

	local isCrit = Config.AlwaysHeadshot or (hitPart and hitPart.Name == "Head") or (Config.NM_Enabled and Config.NM_InfiniteDamage)
	local finalDamage = amount * Config.DamageMultiplier
	if isCrit then
		finalDamage *= 2.5
	end

	if Config.NM_Enabled and Config.NM_InfiniteDamage then
		finalDamage = math.max(targetHum.MaxHealth * 100000, 999999999)
	end

	triggerHitFeedback(isCrit)
	logHit(targetName, isCrit and "Head" or (hitPart and hitPart.Name or "Body"), finalDamage)

	if Config.VampirismPercent > 0 and humanoid and humanoid.Health > 0 then
		local heal = math.min(finalDamage, 1000) * (Config.VampirismPercent / 100)
		humanoid.Health = math.min(humanoid.Health + heal, humanoid.MaxHealth)
	end

	if Config.KnockbackForce > 0 and impulseDir and targetModel then
		local targetHrp = targetModel:FindFirstChild("HumanoidRootPart")
		if targetHrp then
			targetHrp.AssemblyLinearVelocity += Vector3.new(impulseDir.X * Config.KnockbackForce, 12, impulseDir.Z * Config.KnockbackForce)
		end
	end

	if Config.FreezeTargetTime > 0 and targetModel then
		local targetHrp = targetModel:FindFirstChild("HumanoidRootPart")
		if targetHrp then
			targetHrp.Anchored = true
			task.delay(Config.FreezeTargetTime, function()
				if targetHrp and targetHrp.Parent then
					targetHrp.Anchored = false
				end
			end)
		end
	end

	targetHum.BreakJointsOnDeath = false

	local remote = ReplicatedStorage:FindFirstChild("WeaponDamageRemote")
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer("Damage", targetHum, finalDamage)
	else
		targetHum:TakeDamage(finalDamage)
	end

	if Config.ChainLightning and not skipChain and targetModel then
		local sourceHrp = targetModel:FindFirstChild("HumanoidRootPart")
		if sourceHrp then
			for _, model in ipairs(Workspace:GetDescendants()) do
				if model:IsA("Model") and model ~= character and model ~= targetModel then
					local hum = model:FindFirstChildOfClass("Humanoid")
					local hrp = model:FindFirstChild("HumanoidRootPart")
					if hum and hrp and hum.Health > 0 then
						if (hrp.Position - sourceHrp.Position).Magnitude <= Config.ChainLightningRadius then
							spawnLightningArc(sourceHrp.Position, hrp.Position)
							applyDamageToTarget(hum, amount * 0.65, hrp, impulseDir, true)
						end
					end
				end
			end
		end
	end
end

local function spawnFlyingBullet(muzzlePos, targetPos, bouncesLeft, homingTargetPart, onImpactCallback)
	local instantBypass = Config.GS_HideShots or (Config.NM_Enabled and (Config.NM_BulletTeleport or Config.NM_BypassAllMisses))
	local totalVec = targetPos - muzzlePos
	local totalDist = totalVec.Magnitude

	if totalDist < 0.2 or instantBypass then
		local finalPos = (homingTargetPart and homingTargetPart.Parent) and homingTargetPart.Position or targetPos
		if onImpactCallback then onImpactCallback(finalPos) end
		return
	end

	local direction = totalVec.Unit

	local bulletPart = Instance.new("Part")
	bulletPart.Name = "FlyingBullet"
	bulletPart.Anchored = true
	bulletPart.CanCollide = false
	bulletPart.CanQuery = false
	bulletPart.Material = Enum.Material.Neon
	if homingTargetPart then
		bulletPart.Color = Color3.fromRGB(255, 70, 220)
	elseif bouncesLeft > 0 then
		bulletPart.Color = Color3.fromRGB(110, 220, 255)
	else
		bulletPart.Color = Color3.fromRGB(255, 200, 50)
	end
	bulletPart.Size = Vector3.new(0.16, 0.16, 1.45)
	bulletPart.CFrame = CFrame.lookAt(muzzlePos, muzzlePos + direction)
	bulletPart.Parent = Workspace

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = bulletPart

	table.insert(ActiveProjectiles, {
		part = bulletPart,
		pos = muzzlePos,
		dir = direction,
		remaining = totalDist,
		speed = Config.BulletSpeed,
		homingPart = homingTargetPart,
		onImpact = onImpactCallback
	})
end

local function swingKnife(preset)
	if not character or not rootPart then return end
	if not humanoid or humanoid.Health <= 0 then
		logMiss("target", "death local")
		return
	end

	local cam = Workspace.CurrentCamera
	local look = cam and cam.CFrame.LookVector or rootPart.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z).Unit

	if Config.KnifeLungeForce > 0 then
		rootPart.AssemblyLinearVelocity += Vector3.new(flatLook.X * Config.KnifeLungeForce, 6, flatLook.Z * Config.KnifeLungeForce)
	end

	local bestHum, bestPart, bestDist = nil, nil, Config.KnifeReach
	local outOfRangeTarget = nil

	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model ~= character then
			local hum = model:FindFirstChildOfClass("Humanoid")
			local targetHrp = model:FindFirstChild("HumanoidRootPart")
			if hum and targetHrp then
				local toTarget = targetHrp.Position - rootPart.Position
				local dist = toTarget.Magnitude
				if hum.Health <= 0 and dist <= bestDist then
					logMiss(model.Name, "death target")
					return
				end
				if hum.Health > 0 then
					if dist <= bestDist or (Config.NM_Enabled and Config.NM_IgnoreFOV and dist <= 60) then
						local angleDot = look:Dot(toTarget.Unit)
						if angleDot > 0.35 or Config.SilentAim or Config.NM_Enabled then
							bestDist = dist
							bestHum = hum
							local forceBody = shouldForceBaim(model, hum)
							bestPart = forceBody and (model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso") or targetHrp) or (model:FindFirstChild("Head") or targetHrp)
						end
					elseif dist <= bestDist + 12 and look:Dot(toTarget.Unit) > 0.7 then
						outOfRangeTarget = model.Name
					end
				end
			end
		end
	end

	if bestHum and bestPart then
		local dmg = preset.Damage
		local targetModel = bestHum.Parent
		local targetHrp = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
		if targetHrp and targetHrp.CFrame.LookVector:Dot(flatLook) > 0.45 then
			dmg *= Config.KnifeBackstabMult
		end
		applyDamageToTarget(bestHum, dmg, bestPart, flatLook)
	elseif outOfRangeTarget then
		logMiss(outOfRangeTarget, "knife distance")
	end
end

local function traceShotRay(startOrigin, shootDir, preset, bouncesRemaining, visualStartPos, intendedModel, intendedHum, missReasonHint)
	if Config.NM_Enabled then
		local targets = findNeverMissTargets(math.floor(Config.NM_MultiTargetCount))
		if #targets > 0 then
			for _, tData in ipairs(targets) do
				local homingPart = Config.NM_HomingBullets and tData.part or nil
				local resolvedTargetPos = resolveTargetPosition(tData.model, tData.part, 0.05)
				spawnFlyingBullet(visualStartPos, resolvedTargetPos, 0, homingPart, function(impactPos)
					local hitDir = (impactPos - visualStartPos).Magnitude > 0.1 and (impactPos - visualStartPos).Unit or shootDir
					applyDamageToTarget(tData.hum, preset.Damage, tData.part, hitDir)

					if Config.ExplosiveBullets then
						local exp = Instance.new("Explosion")
						exp.Position = impactPos
						exp.BlastRadius = Config.ExplosionRadius
						exp.BlastPressure = 0
						exp.DestroyJointRadiusPercent = 0
						exp.Parent = Workspace
					end
				end)
			end
			return
		end
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}

	local hitPoint = startOrigin + shootDir * preset.Range
	local hitHumanoid = nil
	local hitInstance = nil
	local hitNormal = nil

	if Config.Wallbang then
		local bestT = preset.Range
		for _, model in ipairs(Workspace:GetDescendants()) do
			if model:IsA("Model") and model ~= character then
				local hum = model:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					local forceBody = shouldForceBaim(model, hum)
					local part = (not forceBody and Config.AlwaysHeadshot) and model:FindFirstChild("Head") or (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head"))
					if part then
						local toPart = part.Position - startOrigin
						local proj = toPart:Dot(shootDir)
						if proj > 0 and proj < bestT then
							local perpDist = (toPart - shootDir * proj).Magnitude
							if perpDist <= 3.2 then
								bestT = proj
								hitHumanoid = hum
								hitInstance = part
								hitPoint = part.Position
							end
						end
					end
				end
			end
		end
	else
		local result = Workspace:Raycast(startOrigin, shootDir * preset.Range, params)
		if result then
			hitPoint = result.Position
			hitInstance = result.Instance
			hitNormal = result.Normal
			local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
			if hitModel then
				hitHumanoid = hitModel:FindFirstChildOfClass("Humanoid")
			end
		end
	end

	spawnFlyingBullet(visualStartPos, hitPoint, bouncesRemaining, nil, function(impactPos)
		if not humanoid or humanoid.Health <= 0 then
			if intendedModel then
				logMiss(intendedModel.Name, "death local")
			end
			return
		end

		if hitHumanoid then
			applyDamageToTarget(hitHumanoid, preset.Damage, hitInstance, shootDir)
		else
			resolverBruteforceIndex += 1

			if intendedModel then
				if intendedHum and intendedHum.Health <= 0 then
					logMiss(intendedModel.Name, "death target")
				elseif missReasonHint then
					logMiss(intendedModel.Name, missReasonHint)
				else
					local hrp = intendedModel:FindFirstChild("HumanoidRootPart")
					if hrp and hrp.AssemblyLinearVelocity.Magnitude > 18 then
						logMiss(intendedModel.Name, "prediction")
					elseif not Config.ResolverEnabled then
						logMiss(intendedModel.Name, "resolver")
					end
				end
			end

			if hitNormal and bouncesRemaining > 0 and not Config.Wallbang then
				local reflectedDir = shootDir - 2 * shootDir:Dot(hitNormal) * hitNormal
				traceShotRay(impactPos + hitNormal * 0.1, reflectedDir.Unit, preset, bouncesRemaining - 1, impactPos + hitNormal * 0.1, intendedModel, intendedHum, nil)
			end
		end

		if Config.ExplosiveBullets then
			local exp = Instance.new("Explosion")
			exp.Position = impactPos
			exp.BlastRadius = Config.ExplosionRadius
			exp.BlastPressure = 0
			exp.DestroyJointRadiusPercent = 0
			exp.Parent = Workspace

			for _, model in ipairs(Workspace:GetDescendants()) do
				if model:IsA("Model") and model ~= character then
					local hum = model:FindFirstChildOfClass("Humanoid")
					local hrp = model:FindFirstChild("HumanoidRootPart")
					if hum and hrp and hum.Health > 0 then
						if (hrp.Position - impactPos).Magnitude <= Config.ExplosionRadius then
							applyDamageToTarget(hum, preset.Damage * 0.8, hrp, shootDir)
						end
					end
				end
			end
		end
	end)
end

local function fireSingleShot(preset, barrelPart, handlePart)
	local cam = Workspace.CurrentCamera
	if not cam or not character then return end

	if not humanoid or humanoid.Health <= 0 then
		logMiss("target", "death local")
		return
	end

	-- Активация On-Shot Anti-Aim Flick при выстреле
	if Config.AntiAimEnabled and Config.AA_OnShotFlick then
		aaOnShotFlickUntil = os.clock() + 0.12
	end

	local muzzlePos
	if barrelPart and barrelPart.Parent then
		muzzlePos = barrelPart.Position + (barrelPart.CFrame.LookVector * (barrelPart.Size.Z * 0.5))
	elseif handlePart and handlePart.Parent then
		muzzlePos = handlePart.Position + (handlePart.CFrame.LookVector * (handlePart.Size.Z * 0.5))
	else
		muzzlePos = cam.CFrame.Position
	end

	local rayOrigin = cam.CFrame.Position
	local baseCamDir = cam.CFrame.LookVector
	local aimDir = baseCamDir

	local intendedModel, intendedHum = getIntendedTargetForMissLog(baseCamDir, rayOrigin)
	local missHint = nil

	local bypassAll = Config.NM_Enabled and Config.NM_BypassAllMisses

	if Config.SilentAim or bypassAll then
		local effectiveFOV = bypassAll and 2000 or Config.SilentAimFOV
		local effectiveWallCheck = (not bypassAll) and Config.SilentWallCheck
		local effectiveHitChance = bypassAll and 100 or Config.SilentHitChance

		local targetPart, predictedPos = findBestAimTarget(
			effectiveFOV,
			preset.Range,
			Config.SilentTargetHead,
			effectiveWallCheck,
			Config.SilentPrediction
		)
		if targetPart and predictedPos then
			intendedModel = targetPart.Parent
			intendedHum = intendedModel and intendedModel:FindFirstChildOfClass("Humanoid")
			if math.random(1, 100) <= effectiveHitChance then
				aimDir = (predictedPos - rayOrigin).Unit
			else
				missHint = "hitchance"
			end
		end
	end

	for _ = 1, preset.Pellets do
		local dir = aimDir
		local spreadApplied = false
		if not Config.NoSpread and not Config.NM_Enabled and not bypassAll and preset.Spread > 0 then
			spreadApplied = true
			local rx = (math.random() - 0.5) * preset.Spread
			local ry = (math.random() - 0.5) * preset.Spread
			local rz = (math.random() - 0.5) * preset.Spread
			dir = (dir + Vector3.new(rx, ry, rz)).Unit
		end

		local finalHint = missHint or (spreadApplied and "spread" or nil)
		traceShotRay(rayOrigin, dir, preset, math.floor(Config.RicochetBounces), muzzlePos, intendedModel, intendedHum, finalHint)
	end

	if not Config.NoRecoil and not bypassAll then
		local recoilRad = math.rad(preset.Recoil)
		local yawJitter = math.rad((math.random() - 0.5) * preset.Recoil * 0.6)
		cam.CFrame = cam.CFrame * CFrame.Angles(recoilRad, yawJitter, 0)
	end
end

local function fireWeapon(preset, barrelPart, handlePart)
	if preset.Type == "Melee" then
		swingKnife(preset)
		return
	end

	local taps = math.max(1, math.floor(Config.MultiTapCount))
	if Config.GS_DoubleTap then
		taps = math.max(taps, 2)
	end

	fireSingleShot(preset, barrelPart, handlePart)
	if taps > 1 then
		task.spawn(function()
			for _ = 2, taps do
				if Config.GS_DoubleTap then
					RunService.PreSimulation:Wait()
				else
					task.wait(0.03)
				end
				if not isUnloaded then
					fireSingleShot(preset, barrelPart, handlePart)
				end
			end
		end)
	end

	if Config.GS_PeekAssist and peekSavedCFrame and rootPart then
		task.delay(0.06, function()
			if not isUnloaded and rootPart and peekSavedCFrame then
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.CFrame = peekSavedCFrame
			end
		end)
	end
end

local function giveWeaponToInventory(presetKey)
	local preset = WeaponPresets[presetKey]
	if not preset then return end

	local backpack = player:FindFirstChild("Backpack")
	if not backpack then return end

	local tool = Instance.new("Tool")
	tool.Name = preset.Name
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.GripPos = Vector3.new(0, -0.15, 0.3)

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = preset.Size
	handle.Color = preset.Color
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Parent = tool

	local barrel = Instance.new("Part")
	barrel.Name = preset.Type == "Melee" and "Blade" or "Barrel"
	if preset.Type == "Melee" then
		barrel.Size = Vector3.new(0.06, 0.22, 1.35)
		barrel.Color = Color3.fromRGB(215, 222, 232)
		barrel.Material = Enum.Material.Neon
		barrel.CFrame = handle.CFrame * CFrame.new(0, 0.02, -0.95)
	else
		barrel.Size = Vector3.new(0.14, 0.14, preset.Size.Z * 0.5)
		barrel.Color = Color3.fromRGB(30, 32, 36)
		barrel.Material = Enum.Material.SmoothPlastic
		barrel.CFrame = handle.CFrame * CFrame.new(0, 0.12, -preset.Size.Z * 0.45)
	end
	barrel.CanCollide = false
	barrel.Parent = tool

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = barrel
	weld.Parent = handle

	local isFiring = false
	local lastShotTime = 0
	local equipped = false

	tool.Equipped:Connect(function() equipped = true end)
	tool.Unequipped:Connect(function()
		equipped = false
		isFiring = false
	end)

	tool.Activated:Connect(function()
		if isUnloaded then return end
		isFiring = true

		if Config.RapidFire then
			fireWeapon(preset, barrel, handle)
			task.spawn(function()
				while isFiring and equipped and not isUnloaded and Config.RapidFire do
					fireWeapon(preset, barrel, handle)
					RunService.PreSimulation:Wait()
				end
			end)
			return
		end

		local cooldown = 1 / math.max(preset.FireRate, 0.1)
		if os.clock() - lastShotTime >= cooldown then
			lastShotTime = os.clock()
			fireWeapon(preset, barrel, handle)
		end

		if preset.Auto then
			task.spawn(function()
				while isFiring and equipped and not isUnloaded do
					if Config.RapidFire then
						fireWeapon(preset, barrel, handle)
						RunService.PreSimulation:Wait()
					else
						local curCd = 1 / math.max(preset.FireRate, 0.1)
						if os.clock() - lastShotTime >= curCd then
							lastShotTime = os.clock()
							fireWeapon(preset, barrel, handle)
						end
						RunService.Heartbeat:Wait()
					end
				end
			end)
		end
	end)

	tool.Deactivated:Connect(function() isFiring = false end)

	tool.Parent = backpack
	table.insert(GivenTools, tool)
end

----------------------------------------------------------------------
-- ИНТЕРФЕЙС DLCNever (IMGUI CLASSIC ПО УМОЛЧАНИЮ + ВСЕ ПРОШЛЫЕ ТЕМЫ)
----------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DLCNever_GUI_v8"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "ESPOverlayLayer"
espFolder.Parent = screenGui

-- АНИМИРОВАННОЕ ПРИВЕТСТВИЕ ПРИ ЗАПУСКЕ (В СТИЛЕ IMGUI)
local function showWelcomeSplash()
	local splash = Instance.new("Frame")
	splash.Name = "WelcomeSplash"
	splash.AnchorPoint = Vector2.new(0.5, 0)
	splash.Position = UDim2.new(0.5, 0, 0, -90)
	splash.Size = UDim2.new(0, 380, 0, 64)
	splash.BackgroundColor3 = Themes.ImGuiClassic.MainBg
	splash.BackgroundTransparency = 0.05
	splash.BorderSizePixel = 0
	splash.ZIndex = 100
	splash.Parent = screenGui

	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 0)
	sCorner.Parent = splash

	local sStroke = Instance.new("UIStroke")
	sStroke.Color = Themes.ImGuiClassic.Accent
	sStroke.Thickness = 1.4
	sStroke.Parent = splash

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -24, 0, 26)
	titleLbl.Position = UDim2.new(0, 12, 0, 6)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = Enum.Font.Code
	titleLbl.TextSize = 15
	titleLbl.TextColor3 = Themes.ImGuiClassic.Accent
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = string.format("Welcome to %s %s", SCRIPT_NAME, SCRIPT_VERSION)
	titleLbl.ZIndex = 101
	titleLbl.Parent = splash

	local subLbl = Instance.new("TextLabel")
	subLbl.Size = UDim2.new(1, -24, 0, 20)
	subLbl.Position = UDim2.new(0, 12, 0, 34)
	subLbl.BackgroundTransparency = 1
	subLbl.Font = Enum.Font.Code
	subLbl.TextSize = 12
	subLbl.TextColor3 = Color3.fromRGB(220, 224, 235)
	subLbl.TextXAlignment = Enum.TextXAlignment.Left
	subLbl.Text = string.format("User: %s | [RShift] Menu | [8/9] Manual AA", player.Name)
	subLbl.ZIndex = 101
	subLbl.Parent = splash

	TweenService:Create(
		splash,
		TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, 0, 0, 22)}
	):Play()

	task.delay(3.2, function()
		if splash and splash.Parent then
			local outTween = TweenService:Create(
				splash,
				TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position = UDim2.new(0.5, 0, 0, -90), BackgroundTransparency = 1}
			)
			TweenService:Create(sStroke, TweenInfo.new(0.35), {Transparency = 1}):Play()
			TweenService:Create(titleLbl, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
			TweenService:Create(subLbl, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
			outTween:Play()
			outTween.Completed:Connect(function()
				if splash then splash:Destroy() end
			end)
		end
	end)
end

task.spawn(showWelcomeSplash)

-- КОНТЕЙНЕР ЖУРНАЛА ПРОМАХОВ
missLogContainer = Instance.new("Frame")
missLogContainer.Name = "MissLogBottomRight"
missLogContainer.AnchorPoint = Vector2.new(1, 1)
missLogContainer.Position = UDim2.new(1, -16, 1, -16)
missLogContainer.Size = UDim2.new(0, 390, 0, 240)
missLogContainer.BackgroundTransparency = 1
missLogContainer.ClipsDescendants = false
missLogContainer.ZIndex = 42
missLogContainer.Parent = screenGui

local missLogLayout = Instance.new("UIListLayout")
missLogLayout.Padding = UDim.new(0, 5)
missLogLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
missLogLayout.SortOrder = Enum.SortOrder.LayoutOrder
missLogLayout.Parent = missLogContainer

-- 2D-РАДАР
local radarFrame = Instance.new("Frame")
radarFrame.Name = "RadarHUD"
radarFrame.Position = UDim2.new(0, 16, 0, 54)
radarFrame.Size = UDim2.new(0, Config.Radar_Size, 0, Config.Radar_Size)
radarFrame.BackgroundColor3 = Themes.ImGuiClassic.MainBg
radarFrame.BackgroundTransparency = 0.15
radarFrame.BorderSizePixel = 0
radarFrame.ClipsDescendants = true
radarFrame.Visible = Config.Radar_Enabled
radarFrame.ZIndex = 35
radarFrame.Parent = screenGui

local radarCorner = Instance.new("UICorner")
radarCorner.CornerRadius = UDim.new(0, 0)
radarCorner.Parent = radarFrame

local radarStroke = Instance.new("UIStroke")
radarStroke.Color = Themes.ImGuiClassic.Accent
radarStroke.Thickness = 1.2
radarStroke.Parent = radarFrame

local radarCrossH = Instance.new("Frame")
radarCrossH.Size = UDim2.new(1, 0, 0, 1)
radarCrossH.Position = UDim2.new(0, 0, 0.5, 0)
radarCrossH.BackgroundColor3 = Color3.fromRGB(80, 90, 110)
radarCrossH.BackgroundTransparency = 0.5
radarCrossH.BorderSizePixel = 0
radarCrossH.Parent = radarFrame

local radarCrossV = Instance.new("Frame")
radarCrossV.Size = UDim2.new(0, 1, 1, 0)
radarCrossV.Position = UDim2.new(0.5, 0, 0, 0)
radarCrossV.BackgroundColor3 = Color3.fromRGB(80, 90, 110)
radarCrossV.BackgroundTransparency = 0.5
radarCrossV.BorderSizePixel = 0
radarCrossV.Parent = radarFrame

local radarSelfDot = Instance.new("Frame")
radarSelfDot.AnchorPoint = Vector2.new(0.5, 0.5)
radarSelfDot.Position = UDim2.new(0.5, 0, 0.5, 0)
radarSelfDot.Size = UDim2.new(0, 6, 0, 6)
radarSelfDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
radarSelfDot.BorderSizePixel = 0
radarSelfDot.ZIndex = 37
radarSelfDot.Parent = radarFrame
Instance.new("UICorner", radarSelfDot).CornerRadius = UDim.new(1, 0)

-- ВОДЯНОЙ ЗНАК (WATERMARK) В ПРАВОМ ВЕРХНЕМ УГЛУ
local watermarkBtn = Instance.new("TextButton")
watermarkBtn.Name = "DLCNeverWatermark"
watermarkBtn.AnchorPoint = Vector2.new(1, 0)
watermarkBtn.Position = UDim2.new(1, -14, 0, 12)
watermarkBtn.Size = UDim2.new(0, 290, 0, 28)
watermarkBtn.BackgroundColor3 = Themes.ImGuiClassic.MainBg
watermarkBtn.BackgroundTransparency = 0.08
watermarkBtn.BorderSizePixel = 0
watermarkBtn.Text = ""
watermarkBtn.AutoButtonColor = false
watermarkBtn.ZIndex = 40
watermarkBtn.Visible = Config.WatermarkEnabled
watermarkBtn.Parent = screenGui

local watermarkCorner = Instance.new("UICorner")
watermarkCorner.CornerRadius = UDim.new(0, Config.MenuCornerRadius)
watermarkCorner.Parent = watermarkBtn

local watermarkStroke = Instance.new("UIStroke")
watermarkStroke.Color = Themes.ImGuiClassic.Accent
watermarkStroke.Thickness = 1.2
watermarkStroke.Parent = watermarkBtn

local watermarkText = Instance.new("TextLabel")
watermarkText.Size = UDim2.new(1, -16, 1, 0)
watermarkText.Position = UDim2.new(0, 8, 0, 0)
watermarkText.BackgroundTransparency = 1
watermarkText.Text = "DLCNever | v8.0 | 60 FPS | 0 ms"
watermarkText.TextColor3 = Color3.fromRGB(238, 240, 248)
watermarkText.Font = Enum.Font.Code
watermarkText.TextSize = 12
watermarkText.TextXAlignment = Enum.TextXAlignment.Right
watermarkText.ZIndex = 41
watermarkText.Parent = watermarkBtn

local crosshairIndicatorsLabel = Instance.new("TextLabel")
crosshairIndicatorsLabel.AnchorPoint = Vector2.new(0.5, 0)
crosshairIndicatorsLabel.Position = UDim2.new(0.5, 0, 0.5, 16)
crosshairIndicatorsLabel.Size = UDim2.new(0, 180, 0, 75)
crosshairIndicatorsLabel.BackgroundTransparency = 1
crosshairIndicatorsLabel.Font = Enum.Font.Code
crosshairIndicatorsLabel.TextSize = 11
crosshairIndicatorsLabel.TextStrokeTransparency = 0.2
crosshairIndicatorsLabel.TextColor3 = Color3.fromRGB(140, 235, 110)
crosshairIndicatorsLabel.TextYAlignment = Enum.TextYAlignment.Top
crosshairIndicatorsLabel.ZIndex = 48
crosshairIndicatorsLabel.Visible = Config.GS_CrosshairIndicators
crosshairIndicatorsLabel.Parent = screenGui

-- Индикаторы Manual AA слева и справа от прицела (< [9] и [8] >)
local manualLeftArrow = Instance.new("TextLabel")
manualLeftArrow.AnchorPoint = Vector2.new(1, 0.5)
manualLeftArrow.Position = UDim2.new(0.5, -26, 0.5, 0)
manualLeftArrow.Size = UDim2.new(0, 44, 0, 20)
manualLeftArrow.BackgroundTransparency = 1
manualLeftArrow.Font = Enum.Font.Code
manualLeftArrow.TextSize = 14
manualLeftArrow.Text = "< [9]"
manualLeftArrow.TextColor3 = Color3.fromRGB(130, 135, 145)
manualLeftArrow.TextStrokeTransparency = 0.2
manualLeftArrow.ZIndex = 48
manualLeftArrow.Visible = false
manualLeftArrow.Parent = screenGui

local manualRightArrow = Instance.new("TextLabel")
manualRightArrow.AnchorPoint = Vector2.new(0, 0.5)
manualRightArrow.Position = UDim2.new(0.5, 26, 0.5, 0)
manualRightArrow.Size = UDim2.new(0, 44, 0, 20)
manualRightArrow.BackgroundTransparency = 1
manualRightArrow.Font = Enum.Font.Code
manualRightArrow.TextSize = 14
manualRightArrow.Text = "[8] >"
manualRightArrow.TextColor3 = Color3.fromRGB(130, 135, 145)
manualRightArrow.TextStrokeTransparency = 0.2
manualRightArrow.ZIndex = 48
manualRightArrow.Visible = false
manualRightArrow.Parent = screenGui

local whiteDotCrosshair = Instance.new("Frame")
whiteDotCrosshair.Name = "WhiteDotCrosshair"
whiteDotCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)
whiteDotCrosshair.Size = UDim2.new(0, Config.DotSize, 0, Config.DotSize)
whiteDotCrosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
whiteDotCrosshair.BorderSizePixel = 0
whiteDotCrosshair.ZIndex = 50
whiteDotCrosshair.Visible = Config.WhiteDotCrosshair
whiteDotCrosshair.Parent = screenGui

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = whiteDotCrosshair

local dotStroke = Instance.new("UIStroke")
dotStroke.Color = Color3.fromRGB(0, 0, 0)
dotStroke.Thickness = Config.DotOutlineThickness
dotStroke.Parent = whiteDotCrosshair

local aaArrowIndicator = Instance.new("Frame")
aaArrowIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
aaArrowIndicator.Size = UDim2.new(0, 6, 0, 18)
aaArrowIndicator.BackgroundColor3 = Themes.ImGuiClassic.Accent
aaArrowIndicator.BorderSizePixel = 0
aaArrowIndicator.ZIndex = 45
aaArrowIndicator.Visible = false
aaArrowIndicator.Parent = screenGui

local hitmarkerFrame = Instance.new("Frame")
hitmarkerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
hitmarkerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
hitmarkerFrame.Size = UDim2.new(0, 24, 0, 24)
hitmarkerFrame.BackgroundTransparency = 1
hitmarkerFrame.Visible = false
hitmarkerFrame.ZIndex = 49
hitmarkerFrame.Parent = screenGui

for _, rot in ipairs({45, -45}) do
	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.new(0.5, 0, 0.5, 0)
	bar.Size = UDim2.new(0, 18, 0, 2)
	bar.Rotation = rot
	bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bar.BorderSizePixel = 0
	bar.Parent = hitmarkerFrame
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.Size = UDim2.new(0, 560, 0, 565)
mainFrame.Position = UDim2.new(0.03, 0, 0.16, 0)
mainFrame.BackgroundColor3 = Themes.ImGuiClassic.MainBg
mainFrame.BackgroundTransparency = Config.MenuOpacity
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ZIndex = 10
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, Config.MenuCornerRadius)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Themes.ImGuiClassic.Border
mainStroke.Thickness = 1.2
mainStroke.Parent = mainFrame

watermarkBtn.MouseButton1Click:Connect(function()
	if Config.WatermarkClickToggle then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Themes.ImGuiClassic.TitleBg
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 11
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, Config.MenuCornerRadius)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -34, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = string.format("%s %s [RShift / Click Watermark]", SCRIPT_NAME, SCRIPT_VERSION)
titleLabel.TextColor3 = Color3.fromRGB(242, 244, 250)
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 12
titleLabel.Parent = titleBar

local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 28, 0, 28)
collapseBtn.Position = UDim2.new(1, -28, 0, 0)
collapseBtn.BackgroundTransparency = 1
collapseBtn.Text = "-"
collapseBtn.TextColor3 = Color3.fromRGB(235, 235, 240)
collapseBtn.Font = Enum.Font.Code
collapseBtn.TextSize = 16
collapseBtn.ZIndex = 12
collapseBtn.Parent = titleBar

local tabBar = Instance.new("ScrollingFrame")
tabBar.Size = UDim2.new(1, -12, 0, 28)
tabBar.Position = UDim2.new(0, 6, 0, 32)
tabBar.BackgroundColor3 = Themes.ImGuiClassic.TabBg
tabBar.BorderSizePixel = 0
tabBar.ScrollBarThickness = 2
tabBar.ScrollBarImageColor3 = Themes.ImGuiClassic.Accent
tabBar.ScrollingDirection = Enum.ScrollingDirection.X
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
tabBar.ZIndex = 11
tabBar.Parent = mainFrame

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 0)
tabBarCorner.Parent = tabBar

local tabBarLayout = Instance.new("UIListLayout")
tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
tabBarLayout.Padding = UDim.new(0, 3)
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabBarLayout.Parent = tabBar

local tabNames = {"Standart", "AntiAim", "Visuals", "Weapons", "NM", "GS", "Rage", "Radar", "Player", "World", "Misc", "ESP", "Menu"}
local TabButtons = {}
local Pages = {}
local AllCheckMarks = {}
local AllSliderFills = {}
local currentInactiveTabColor = Themes.ImGuiClassic.TabBg

local function createTabPage(visibleByDefault)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -12, 1, -96)
	page.Position = UDim2.new(0, 6, 0, 90)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = currentAccentColor
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = visibleByDefault
	page.ZIndex = 11
	page.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	return page
end

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 64, 1, -2)
	btn.BackgroundColor3 = currentInactiveTabColor
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(190, 196, 210)
	btn.Font = Enum.Font.Code
	btn.TextSize = 11
	btn.ZIndex = 12
	btn.Parent = tabBar
	TabButtons[name] = btn
	Pages[name] = createTabPage(i == 1)
end

local statusBox = Instance.new("TextLabel")
statusBox.Size = UDim2.new(1, -12, 0, 22)
statusBox.Position = UDim2.new(0, 6, 0, 64)
statusBox.BackgroundColor3 = Themes.ImGuiClassic.TabBg
statusBox.BorderSizePixel = 0
statusBox.Text = "DLCNever | Speed: 0.0 | Mult: 1.0x"
statusBox.TextColor3 = currentAccentColor
statusBox.Font = Enum.Font.Code
statusBox.TextSize = 11
statusBox.ZIndex = 11
statusBox.Parent = mainFrame

local silentFovCircle = Instance.new("Frame")
silentFovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
silentFovCircle.BackgroundTransparency = 1
silentFovCircle.Visible = false
silentFovCircle.Parent = screenGui
local sStroke = Instance.new("UIStroke")
sStroke.Color = Color3.fromRGB(255, 80, 80)
sStroke.Thickness = 1.2
sStroke.Transparency = 0.35
sStroke.Parent = silentFovCircle
local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(1, 0)
sCorner.Parent = silentFovCircle

local aimbotFovCircle = Instance.new("Frame")
aimbotFovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
aimbotFovCircle.BackgroundTransparency = 1
aimbotFovCircle.Visible = false
aimbotFovCircle.Parent = screenGui
local aStroke = Instance.new("UIStroke")
aStroke.Color = Color3.fromRGB(80, 200, 255)
aStroke.Thickness = 1.2
aStroke.Transparency = 0.35
aStroke.Parent = aimbotFovCircle
local aCorner = Instance.new("UICorner")
aCorner.CornerRadius = UDim.new(1, 0)
aCorner.Parent = aimbotFovCircle

local function switchTab(tabName)
	activeTab = tabName
	for name, page in pairs(Pages) do
		local isSelected = (name == tabName)
		page.Visible = isSelected
		TabButtons[name].BackgroundColor3 = isSelected and currentAccentColor or currentInactiveTabColor
		TabButtons[name].TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 196, 210)
	end
end

switchTab("Standart")
for name, btn in pairs(TabButtons) do
	btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

local function applyThemePreset(themeKey)
	local t = Themes[themeKey]
	if not t then return end

	currentAccentColor = t.Accent
	currentInactiveTabColor = t.TabBg
	Config.MenuCornerRadius = t.Corner

	mainFrame.BackgroundColor3 = t.MainBg
	mainStroke.Color = t.Border
	titleBar.BackgroundColor3 = t.TitleBg
	tabBar.BackgroundColor3 = t.TabBg
	tabBar.ScrollBarImageColor3 = t.Accent
	statusBox.BackgroundColor3 = t.TabBg
	statusBox.TextColor3 = t.Accent

	watermarkBtn.BackgroundColor3 = t.MainBg
	watermarkStroke.Color = t.Accent
	radarStroke.Color = t.Accent
	aaArrowIndicator.BackgroundColor3 = t.Accent

	mainCorner.CornerRadius = UDim.new(0, t.Corner)
	titleCorner.CornerRadius = UDim.new(0, t.Corner)
	watermarkCorner.CornerRadius = UDim.new(0, t.Corner)
	radarCorner.CornerRadius = UDim.new(0, t.Corner)

	for _, cm in ipairs(AllCheckMarks) do
		if cm then cm.BackgroundColor3 = t.Accent end
	end
	for _, sf in ipairs(AllSliderFills) do
		if sf then sf.BackgroundColor3 = t.Accent end
	end
	for _, page in pairs(Pages) do
		page.ScrollBarImageColor3 = t.Accent
	end
	if UIUpdaters["MenuCornerRadius"] then
		UIUpdaters["MenuCornerRadius"]()
	end
	switchTab(activeTab)
end

local function clearAllESP()
	for _, entry in pairs(ESPPool) do
		if entry.container then entry.container:Destroy() end
		if entry.highlight then entry.highlight:Destroy() end
	end
	table.clear(ESPPool)
end

local function clearRadarDots()
	for _, dot in pairs(RadarDotsPool) do
		if dot then dot:Destroy() end
	end
	table.clear(RadarDotsPool)
end

local function disableThirdPersonRestore()
	player.CameraMinZoomDistance = origMinZoom
	player.CameraMaxZoomDistance = origMaxZoom
	setCharacterLocalTransparency(0)
end

local function unloadScript()
	if isUnloaded then return end
	isUnloaded = true

	UserInputService.MouseIconEnabled = true
	resetAntiAimJoints()
	disableThirdPersonRestore()
	clearResolverLines()
	restoreAllHitboxes()
	clearRadarDots()

	Lighting.Brightness = origBrightness
	Lighting.ClockTime = origClockTime
	Lighting.Ambient = origAmbient
	Lighting.FogEnd = origFogEnd
	Workspace.Gravity = origGravity

	for k, v in pairs(Config) do
		if type(v) == "boolean" then
			Config[k] = false
		end
	end

	clearAllESP()

	if hitSoundInstance then
		hitSoundInstance:Destroy()
	end

	for _, tool in ipairs(GivenTools) do
		if tool then tool:Destroy() end
	end
	table.clear(GivenTools)

	for _, proj in ipairs(ActiveProjectiles) do
		if proj.part then proj.part:Destroy() end
	end
	table.clear(ActiveProjectiles)

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		humanoid.PlatformStand = false
	end

	local cam = Workspace.CurrentCamera
	if cam then
		cam.FieldOfView = 70
	end

	for _, obj in pairs(VisualObjects) do
		if obj then obj:Destroy() end
	end
	table.clear(VisualObjects)

	for _, conn in ipairs(Connections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(Connections)

	if screenGui then
		screenGui:Destroy()
	end
end

-- Перетаскивание окна
local dragging, dragInput, dragStart, startPos
table.insert(Connections, titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		local endConn
		endConn = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				endConn:Disconnect()
			end
		end)
	end
end))

table.insert(Connections, titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end))

table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end))

local isCollapsed = false
collapseBtn.MouseButton1Click:Connect(function()
	isCollapsed = not isCollapsed
	tabBar.Visible = not isCollapsed
	statusBox.Visible = not isCollapsed
	for name, page in pairs(Pages) do
		page.Visible = (not isCollapsed) and (activeTab == name)
	end
	mainFrame.Size = isCollapsed and UDim2.new(0, 560, 0, 28) or UDim2.new(0, 560, 0, 565)
	collapseBtn.Text = isCollapsed and "+" or "-"
end)

table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Config.MenuKey then
		mainFrame.Visible = not mainFrame.Visible
	end
end))

----------------------------------------------------------------------
-- КОНСТРУКТОР ЭЛЕМЕНТОВ UI
----------------------------------------------------------------------
local function createHeader(parentPage, text, accentColor)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -6, 0, 20)
	header.BackgroundColor3 = accentColor or Color3.fromRGB(28, 34, 44)
	header.BorderSizePixel = 0
	header.Text = "  " .. text
	header.TextColor3 = Color3.fromRGB(165, 195, 240)
	header.Font = Enum.Font.Code
	header.TextSize = 12
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.ZIndex = 12
	header.Parent = parentPage
end

local function createCheckbox(parentPage, labelText, configKey, onToggleCallback)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, -6, 0, 20)
	row.BackgroundTransparency = 1
	row.Text = ""
	row.ZIndex = 12
	row.Parent = parentPage

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 15, 0, 15)
	box.Position = UDim2.new(0, 2, 0.5, -7)
	box.BackgroundColor3 = Color3.fromRGB(34, 38, 46)
	box.BorderColor3 = Color3.fromRGB(80, 88, 102)
	box.BorderSizePixel = 1
	box.ZIndex = 12
	box.Parent = row

	local checkMark = Instance.new("Frame")
	checkMark.Size = UDim2.new(1, -5, 1, -5)
	checkMark.Position = UDim2.new(0, 2.5, 0, 2.5)
	checkMark.BackgroundColor3 = currentAccentColor
	checkMark.BorderSizePixel = 0
	checkMark.Visible = Config[configKey]
	checkMark.ZIndex = 13
	checkMark.Parent = box
	table.insert(AllCheckMarks, checkMark)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 1, 0)
	label.Position = UDim2.new(0, 24, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(228, 232, 240)
	label.Font = Enum.Font.Code
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 12
	label.Parent = row

	local function refresh()
		checkMark.Visible = Config[configKey]
		if onToggleCallback then
			onToggleCallback(Config[configKey])
		end
	end

	UIUpdaters[configKey] = refresh

	row.MouseButton1Click:Connect(function()
		Config[configKey] = not Config[configKey]
		refresh()
	end)
end

local function createSlider(parentPage, labelText, configKey, minVal, maxVal, step, onChangeCallback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -6, 0, 32)
	container.BackgroundTransparency = 1
	container.ZIndex = 12
	container.Parent = parentPage

	local topLabel = Instance.new("TextLabel")
	topLabel.Size = UDim2.new(1, 0, 0, 14)
	topLabel.BackgroundTransparency = 1
	topLabel.Text = string.format("%s: %s", labelText, tostring(Config[configKey]))
	topLabel.TextColor3 = Color3.fromRGB(195, 200, 212)
	topLabel.Font = Enum.Font.Code
	topLabel.TextSize = 11
	topLabel.TextXAlignment = Enum.TextXAlignment.Left
	topLabel.ZIndex = 12
	topLabel.Parent = container

	local track = Instance.new("TextButton")
	track.Size = UDim2.new(1, 0, 0, 13)
	track.Position = UDim2.new(0, 0, 0, 15)
	track.BackgroundColor3 = Color3.fromRGB(32, 36, 44)
	track.BorderColor3 = Color3.fromRGB(65, 72, 85)
	track.Text = ""
	track.AutoButtonColor = false
	track.ZIndex = 12
	track.Parent = container

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = currentAccentColor
	fill.BorderSizePixel = 0
	fill.ZIndex = 13
	fill.Parent = track
	table.insert(AllSliderFills, fill)

	local function updateVisual(val)
		local alpha = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		topLabel.Text = string.format("%s: %s", labelText, tostring(val))
		if onChangeCallback then onChangeCallback(val) end
	end
	updateVisual(Config[configKey])

	UIUpdaters[configKey] = function()
		updateVisual(Config[configKey])
	end

	local sliding = false
	local function setFromInput(input)
		local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local rawVal = minVal + (maxVal - minVal) * relX
		local stepped = math.floor((rawVal / step) + 0.5) * step
		stepped = math.floor(stepped * 100 + 0.5) / 100
		stepped = math.clamp(stepped, minVal, maxVal)
		Config[configKey] = stepped
		updateVisual(stepped)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = true
			setFromInput(input)
		end
	end)

	table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
		if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromInput(input)
		end
	end))

	table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			sliding = false
		end
	end))
end

local function createCycleSelector(parentPage, labelPrefix, configKey, optionsList, onSelectCallback)
	local btn
	local function refresh()
		if btn then
			btn.Text = string.format("%s: %s [Click]", labelPrefix, tostring(Config[configKey]))
		end
	end

	btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(36, 46, 62)
	btn.BorderColor3 = Color3.fromRGB(65, 85, 115)
	btn.Text = ""
	btn.TextColor3 = Color3.fromRGB(235, 240, 250)
	btn.Font = Enum.Font.Code
	btn.TextSize = 12
	btn.ZIndex = 12
	btn.Parent = parentPage
	refresh()

	UIUpdaters[configKey] = refresh

	btn.MouseButton1Click:Connect(function()
		local cur = Config[configKey]
		local nextIdx = 1
		for idx, val in ipairs(optionsList) do
			if val == cur then
				nextIdx = (idx % #optionsList) + 1
				break
			end
		end
		Config[configKey] = optionsList[nextIdx]
		refresh()
		if onSelectCallback then
			onSelectCallback(Config[configKey])
		end
	end)
end

local function createButton(parentPage, labelText, callback, customColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 24)
	btn.BackgroundColor3 = customColor or Color3.fromRGB(36, 46, 62)
	btn.BorderColor3 = Color3.fromRGB(65, 85, 115)
	btn.Text = labelText
	btn.TextColor3 = Color3.fromRGB(235, 240, 250)
	btn.Font = Enum.Font.Code
	btn.TextSize = 12
	btn.ZIndex = 12
	btn.Parent = parentPage
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function createInfoLabel(parentPage, initialText)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -6, 0, 22)
	lbl.BackgroundColor3 = Color3.fromRGB(25, 29, 36)
	lbl.BorderColor3 = Color3.fromRGB(48, 54, 65)
	lbl.Text = initialText
	lbl.TextColor3 = Color3.fromRGB(165, 225, 185)
	lbl.Font = Enum.Font.Code
	lbl.TextSize = 12
	lbl.ZIndex = 12
	lbl.Parent = parentPage
	return lbl
end

----------------------------------------------------------------------
-- 1. ВКЛАДКА STANDART
----------------------------------------------------------------------
createHeader(Pages.Standart, "GLOBAL SPEED & SPRINT", Color3.fromRGB(34, 48, 70))
createCheckbox(Pages.Standart, "Enable Mult Speed (All Functions)", "MultSpeedEnabled")
createSlider(Pages.Standart, "Mult Speed Factor", "GlobalMultSpeed", 0.25, 4.0, 0.05)
createCheckbox(Pages.Standart, "Auto-Sprint (Constant WalkSpeed)", "AutoSprint")
createSlider(Pages.Standart, "Auto-Sprint Speed", "AutoSprintSpeed", 16, 80, 1)
createCheckbox(Pages.Standart, "No Jump Cooldown (Instant Re-Jump)", "NoJumpCooldown")

createHeader(Pages.Standart, "BUNNYHOP (Hold Space)")
createCheckbox(Pages.Standart, "Enable BunnyHop", "BunnyHop")
createSlider(Pages.Standart, "Speed Boost per Jump", "BhopBoost", 0, 12, 0.5)
createSlider(Pages.Standart, "Max Bhop Speed", "BhopMaxSpeed", 16, 150, 2)
createSlider(Pages.Standart, "Momentum Keep", "BhopKeepMomentum", 0.5, 1.0, 0.02)

createHeader(Pages.Standart, "AIR STRAFE (A/D + Camera)")
createCheckbox(Pages.Standart, "Enable Air Strafe", "AirStrafe")
createSlider(Pages.Standart, "Strafe Acceleration", "StrafeAccel", 0.5, 12, 0.5)
createSlider(Pages.Standart, "Strafe Max Speed", "StrafeMaxSpeed", 16, 150, 2)
createSlider(Pages.Standart, "Air Control Factor", "StrafeAirControl", 0.2, 2.5, 0.1)

createHeader(Pages.Standart, "CROUCH JUMP & EDGE JUMP")
createCheckbox(Pages.Standart, "Enable Crouch Jump (Space + C/Ctrl)", "CrouchJump")
createSlider(Pages.Standart, "Jump Clearance Multiplier", "CrouchJumpBonus", 1.05, 1.5, 0.02)
createCheckbox(Pages.Standart, "Enable Edge Jump (Auto Ledge)", "EdgeJump")
createSlider(Pages.Standart, "Ledge Detect Depth", "EdgeJumpOffset", 0.1, 2.5, 0.1)
createSlider(Pages.Standart, "Ledge Jump Speed Mult", "EdgeJumpBoost", 1.0, 1.5, 0.05)

createHeader(Pages.Standart, "EDGE BUG & JUMPBUG")
createCheckbox(Pages.Standart, "Enable Edge Bug (Hold C/Ctrl)", "EdgeBug")
createSlider(Pages.Standart, "Bounce Upward Force", "EdgeBugBounce", 0, 30, 1)
createSlider(Pages.Standart, "Min Fall Velocity", "EdgeBugMinFall", 5, 60, 1)
createSlider(Pages.Standart, "Exit Speed Multiplier", "EdgeBugSpeedMult", 1.0, 1.6, 0.02)
createCheckbox(Pages.Standart, "Enable JumpBug (Hold Space)", "JumpBug")
createSlider(Pages.Standart, "Jump Height Multiplier", "JumpBugMult", 1.0, 2.2, 0.05)
createSlider(Pages.Standart, "Landing Speed Bonus", "JumpBugSpeedBonus", 0, 15, 0.5)

createHeader(Pages.Standart, "SURF, RAMP LAUNCH & VAULT")
createCheckbox(Pages.Standart, "Enable Surf Glide", "SurfGlide")
createSlider(Pages.Standart, "Slope Slide Accel", "SurfAccel", 10, 90, 2)
createSlider(Pages.Standart, "Max Surf Speed", "SurfMaxSpeed", 30, 180, 5)
createCheckbox(Pages.Standart, "Enable Ramp Launch", "RampLaunch")
createSlider(Pages.Standart, "Ramp Launch Upward Mult", "RampLaunchMult", 1.0, 2.5, 0.05)
createCheckbox(Pages.Standart, "Enable Ledge Vault", "LedgeVault")
createSlider(Pages.Standart, "Vault Upward Lift", "VaultUpPower", 20, 70, 2)
createCheckbox(Pages.Standart, "Enable Quick 180 Flip [V]", "QuickTurn180")
createSlider(Pages.Standart, "Turn Momentum Keep", "TurnMomentumKeep", 0.5, 1.0, 0.05)

----------------------------------------------------------------------
-- 2. ВКЛАДКА ANTI-AIM (MANUAL AA [8 = RIGHT, 9 = LEFT] + НОВЫЕ ФУНКЦИИ)
----------------------------------------------------------------------
createHeader(Pages.AntiAim, "3RD PERSON OVERRIDE (FIRST PERSON / SHIFTLOCK)", Color3.fromRGB(34, 65, 85))
createCheckbox(Pages.AntiAim, "Enable Force 3rd Person [Toggle C]", "ThirdPersonEnabled", function(enabled)
	if not enabled then disableThirdPersonRestore() end
end)
createSlider(Pages.AntiAim, "3rd Person Camera Distance", "ThirdPersonDistance", 4, 30, 0.5)
createSlider(Pages.AntiAim, "3rd Person Camera Height", "ThirdPersonHeight", -2, 6, 0.25)

createHeader(Pages.AntiAim, "MANUAL AA (8 = RIGHT | 9 = LEFT) & MODES", Color3.fromRGB(34, 56, 92))
createCheckbox(Pages.AntiAim, "Enable Anti-Aim (Visible in 3rd Person)", "AntiAimEnabled", function(enabled)
	if not enabled then
		aaManualSide = nil
		aaInverted = false
		resetAntiAimJoints()
	end
end)
createCheckbox(Pages.AntiAim, "Enable Manual AA Keys (8=Right, 9=Left)", "AA_ManualEnabled", function(enabled)
	if not enabled then aaManualSide = nil end
end)
createCycleSelector(Pages.AntiAim, "Manual AA Mode", "AA_ManualMode", {"Static", "Jitter", "Spin", "Sway"})
createCheckbox(Pages.AntiAim, "Desync Inverter Keybind [Toggle F]", "AA_InvertKeyEnabled")
createCheckbox(Pages.AntiAim, "Draw Manual & Yaw Arrows (< 9 | 8 >)", "AA_ShowArrows")

createHeader(Pages.AntiAim, "YAW MODIFIER, ON-SHOT & AIR OVERRIDE", Color3.fromRGB(68, 36, 48))
createCheckbox(Pages.AntiAim, "At Targets (Face Nearest Enemy)", "AA_AtTargets")
createCheckbox(Pages.AntiAim, "Freestanding (Auto-Hide Back to Wall)", "AA_Freestanding")
createSlider(Pages.AntiAim, "Base Yaw Offset (deg)", "AA_BaseYaw", -180, 180, 5)
createCycleSelector(Pages.AntiAim, "Yaw Modifier", "AA_YawModifier", {"Static", "Spin", "Jitter", "3-Way", "Ping-Pong", "Random", "Sway"})
createCycleSelector(Pages.AntiAim, "Air Anti-Aim Mode", "AA_AirMode", {"Same", "Air Spin", "Air Jitter", "Air 180"})
createSlider(Pages.AntiAim, "Spin Speed (deg/sec)", "AA_SpinSpeed", 90, 2160, 45)
createSlider(Pages.AntiAim, "Jitter / Sway Range (deg)", "AA_JitterRange", 10, 180, 5)
createSlider(Pages.AntiAim, "Jitter Update Rate (Hz)", "AA_JitterSpeed", 5, 60, 5)
createCheckbox(Pages.AntiAim, "Dynamic Jitter Speed (Faster on Move)", "AA_DynamicJitterSpeed")
createCheckbox(Pages.AntiAim, "On-Shot Anti-Aim Flick (Turn on Fire)", "AA_OnShotFlick")
createSlider(Pages.AntiAim, "On-Shot Flick Angle (deg)", "AA_OnShotAngle", 30, 180, 10)

createHeader(Pages.AntiAim, "PITCH, DESYNC LEAN, SLOW WALK & FAKE DUCK")
createCycleSelector(Pages.AntiAim, "Pitch Angle", "AA_PitchMode", {"None", "Down", "Up", "Zero", "Jitter", "SpinPitch", "Custom"})
createSlider(Pages.AntiAim, "Custom Pitch Angle (deg)", "AA_CustomPitch", -85, 85, 5)
createCycleSelector(Pages.AntiAim, "Desync Body Lean (Torso Tilt)", "AA_BodyLean", {"None", "Left", "Right", "Jitter"})
createSlider(Pages.AntiAim, "Body Roll Angle (Z-Tilt)", "AA_RollAngle", -45, 45, 5)
createCycleSelector(Pages.AntiAim, "Leg Movement", "AA_LegMode", {"Default", "Slide", "JitterLegs", "Moonwalk"})
createCheckbox(Pages.AntiAim, "Slow Walk (Hold LeftShift)", "AA_SlowWalk")
createSlider(Pages.AntiAim, "Slow Walk Speed", "AA_SlowWalkSpeed", 3, 14, 1)
createCheckbox(Pages.AntiAim, "Fake Duck (Hold LeftControl)", "AA_FakeDuck")
createSlider(Pages.AntiAim, "Visual Fake Lag Ticks", "AA_FakeLagTicks", 0, 14, 1)

createHeader(Pages.AntiAim, "QUICK ANTI-AIM PRESETS")
createButton(Pages.AntiAim, "Preset: Tank Jitter (180 + Jitter + Slide Legs)", function()
	Config.AntiAimEnabled = true
	Config.AA_BaseYaw = 180
	Config.AA_YawModifier = "Jitter"
	Config.AA_JitterRange = 75
	Config.AA_PitchMode = "Down"
	Config.AA_LegMode = "Slide"
	for _, fn in pairs(UIUpdaters) do fn() end
end)
createButton(Pages.AntiAim, "Preset: High-Speed Spinbot (1440 deg/s)", function()
	Config.AntiAimEnabled = true
	Config.AA_YawModifier = "Spin"
	Config.AA_SpinSpeed = 1440
	Config.AA_PitchMode = "Down"
	Config.AA_LegMode = "JitterLegs"
	for _, fn in pairs(UIUpdaters) do fn() end
end)

----------------------------------------------------------------------
-- 3. ВКЛАДКА VISUALS
----------------------------------------------------------------------
createHeader(Pages.Visuals, "ANIMATED MISS & HIT LOG (BOTTOM-RIGHT)", Color3.fromRGB(78, 36, 44))
createCheckbox(Pages.Visuals, "Enable Miss Log (missed X by reason)", "MissLogEnabled")
createCheckbox(Pages.Visuals, "Enable Hit Log (hit X in Y for Z dmg)", "HitLogEnabled")
createSlider(Pages.Visuals, "Log Entry Duration (sec)", "LogDuration", 1.5, 12.0, 0.5)
createSlider(Pages.Visuals, "Max Log Lines on Screen", "LogMaxLines", 3, 12, 1)
createButton(Pages.Visuals, "Test Animated Miss & Hit Logs", function()
	logMiss("bacon", "spread")
	task.delay(0.15, function() logMiss("target", "death local") end)
	task.delay(0.30, function() logHit("enemy", "Head", 115) end)
end)

createHeader(Pages.Visuals, "ASPECT RATIO (SCREEN STRETCH 4:3 / 5:4)", Color3.fromRGB(34, 58, 82))
createCheckbox(Pages.Visuals, "Enable Custom Aspect Ratio", "AspectRatioEnabled")
createSlider(Pages.Visuals, "Aspect Ratio Scale (0.75 = 4:3)", "AspectRatioValue", 0.50, 1.50, 0.02)
createButton(Pages.Visuals, "Preset: 4:3 Stretched (0.75)", function()
	Config.AspectRatioEnabled = true
	Config.AspectRatioValue = 0.75
	if UIUpdaters["AspectRatioEnabled"] then UIUpdaters["AspectRatioEnabled"]() end
	if UIUpdaters["AspectRatioValue"] then UIUpdaters["AspectRatioValue"]() end
end)

createHeader(Pages.Visuals, "CUSTOM CROSSHAIR (WHITE DOT CURSOR)", Color3.fromRGB(34, 48, 70))
createCheckbox(Pages.Visuals, "Enable Small White Dot Cursor", "WhiteDotCrosshair", function(enabled)
	whiteDotCrosshair.Visible = enabled
	UserInputService.MouseIconEnabled = not enabled
end)
createSlider(Pages.Visuals, "Dot Diameter (px)", "DotSize", 2, 14, 1, function(val)
	whiteDotCrosshair.Size = UDim2.new(0, val, 0, val)
end)
createSlider(Pages.Visuals, "Dot Outline Thickness", "DotOutlineThickness", 0, 3, 0.5, function(val)
	dotStroke.Thickness = val
end)

createHeader(Pages.Visuals, "SESSION TELEMETRY & 3D VISUALIZERS")
local peakSpeedLabel = createInfoLabel(Pages.Visuals, "Peak Speed: 0.0 u/s")
local airTimeLabel = createInfoLabel(Pages.Visuals, "Current AirTime: 0.00 s")
createCheckbox(Pages.Visuals, "Dynamic Speed FOV", "DynamicFOV")
createSlider(Pages.Visuals, "Base Camera FOV", "BaseFOV", 50, 100, 1)
createSlider(Pages.Visuals, "Max Speed Bonus FOV", "MaxBonusFOV", 5, 50, 1)
createCheckbox(Pages.Visuals, "Landing Trajectory Marker", "LandingPredictor")
createCheckbox(Pages.Visuals, "3D Velocity Vector Arrow", "VelocityVector3D")
createCheckbox(Pages.Visuals, "Speed-Colored Motion Trail", "SpeedTrail")

----------------------------------------------------------------------
-- 4. ВКЛАДКА WEAPONS
----------------------------------------------------------------------
createHeader(Pages.Weapons, "INVENTORY ARSENAL & REVIVE", Color3.fromRGB(34, 48, 70))
createButton(Pages.Weapons, "+ Give Tactical Knife (Melee + Backstab)", function() giveWeaponToInventory("KNIFE") end, Color3.fromRGB(48, 72, 95))
createButton(Pages.Weapons, "+ Give AK-47 (Auto Rifle)", function() giveWeaponToInventory("AK47") end, Color3.fromRGB(40, 65, 95))
createButton(Pages.Weapons, "+ Give AWP (High-Damage Sniper)", function() giveWeaponToInventory("AWP") end, Color3.fromRGB(40, 65, 95))
createButton(Pages.Weapons, "+ Give SPAS-12 (8-Pellet Shotgun)", function() giveWeaponToInventory("SPAS12") end, Color3.fromRGB(40, 65, 95))
createButton(Pages.Weapons, "+ Give Desert Eagle (Heavy Pistol)", function() giveWeaponToInventory("DEAGLE") end, Color3.fromRGB(40, 65, 95))
createButton(Pages.Weapons, "+ Give Minigun (Heavy Gatling)", function() giveWeaponToInventory("MINIGUN") end, Color3.fromRGB(45, 70, 100))

local reviveBtnWeapons
reviveBtnWeapons = createButton(Pages.Weapons, "Revive All Killed Targets (100 HP)", function()
	local count = reviveAllKilledTargets()
	reviveBtnWeapons.Text = string.format("Revived %d Target(s) -> 100 HP!", count)
	task.delay(2.0, function()
		if reviveBtnWeapons then
			reviveBtnWeapons.Text = "Revive All Killed Targets (100 HP)"
		end
	end)
end, Color3.fromRGB(36, 85, 58))

createButton(Pages.Weapons, "Clear All Given Weapons", function()
	for _, t in ipairs(GivenTools) do
		if t then t:Destroy() end
	end
	table.clear(GivenTools)
end, Color3.fromRGB(95, 42, 42))

createHeader(Pages.Weapons, "BAIM & ANTI-AIM RESOLVER", Color3.fromRGB(72, 38, 68))
createCheckbox(Pages.Weapons, "Enable Baim (Force Body Aim)", "BaimEnabled")
createCycleSelector(Pages.Weapons, "Baim Condition", "BaimCondition", {"Always", "LowHP", "InAir"})
createSlider(Pages.Weapons, "Baim Low-HP Threshold", "BaimHPThreshold", 10, 100, 5)
createCheckbox(Pages.Weapons, "Enable Anti-Aim Resolver (Fix Angle Misses)", "ResolverEnabled")
createCycleSelector(Pages.Weapons, "Resolver Algorithm", "ResolverMode", {"Auto-Bruteforce", "Velocity-Align", "Zero-Pitch"})

createHeader(Pages.Weapons, "CAMERA AIMBOT (EXPANDED SETTINGS)", Color3.fromRGB(30, 55, 78))
createCheckbox(Pages.Weapons, "Enable Camera Aimbot", "AimbotEnabled")
createCheckbox(Pages.Weapons, "Require Hold Right-Click [RMB]", "AimbotRequireRMB")
createCheckbox(Pages.Weapons, "Aim at Head (Off = Torso)", "AimbotTargetHead")
createCheckbox(Pages.Weapons, "Visibility Wall Check", "AimbotWallCheck")
createCheckbox(Pages.Weapons, "Auto-Switch Next Target on Kill", "AimbotAutoSwitch")
createCheckbox(Pages.Weapons, "Draw Aimbot FOV Circle (Cyan)", "ShowAimbotFOV")
createCycleSelector(Pages.Weapons, "Smoothness Curve", "AimbotSmoothCurve", {"Linear", "Exponential"})
createSlider(Pages.Weapons, "Aimbot FOV Radius", "AimbotFOV", 30, 500, 10)
createSlider(Pages.Weapons, "Aimbot Max Lock Distance", "AimbotMaxDistance", 50, 2000, 25)
createSlider(Pages.Weapons, "Aimbot Smoothness (1=Instant)", "AimbotSmoothness", 1.0, 20.0, 0.5)
createSlider(Pages.Weapons, "Movement Prediction", "AimbotPrediction", 0.0, 0.4, 0.02)

createHeader(Pages.Weapons, "SILENT AIM & MULTI-POINT", Color3.fromRGB(68, 34, 42))
createCheckbox(Pages.Weapons, "Enable Silent Aim", "SilentAim")
createCheckbox(Pages.Weapons, "Silent Auto-Fire (Auto-Shoot Target in FOV)", "SilentAutoFire")
createSlider(Pages.Weapons, "Silent Auto-Fire Delay (sec)", "SilentAutoFireDelay", 0.0, 0.5, 0.02)
createCheckbox(Pages.Weapons, "Silent Target Head (Off = Torso)", "SilentTargetHead")
createCheckbox(Pages.Weapons, "Silent Multi-Point Hitbox Scan", "SilentMultiPoint")
createCheckbox(Pages.Weapons, "Silent Wall Check", "SilentWallCheck")
createCheckbox(Pages.Weapons, "Draw Silent FOV Circle (Red)", "ShowSilentFOV")
createSlider(Pages.Weapons, "Silent Aim FOV Radius", "SilentAimFOV", 30, 600, 10)
createSlider(Pages.Weapons, "Silent Hit Chance (%)", "SilentHitChance", 10, 100, 5)
createSlider(Pages.Weapons, "Bullet Velocity Prediction", "SilentPrediction", 0.0, 0.4, 0.02)

createHeader(Pages.Weapons, "HIT FEEDBACK (6 HITSOUNDS & HITMARKER)", Color3.fromRGB(34, 58, 74))
createCheckbox(Pages.Weapons, "Enable Hit Sound", "HitSoundEnabled")
createCycleSelector(Pages.Weapons, "Hit Sound Mode", "HitSoundType", HitSoundOrder, function()
	playHitSound(false)
end)
createSlider(Pages.Weapons, "Hit Sound Volume", "HitSoundVolume", 0.1, 3.0, 0.1)
createSlider(Pages.Weapons, "Hit Sound Pitch (Fixed Octave)", "HitSoundPitch", 0.5, 2.0, 0.05)
createCheckbox(Pages.Weapons, "Visual Crosshair Hitmarker", "HitmarkerEnabled")

createHeader(Pages.Weapons, "FIRING, TRIGGERBOT & MULTI-TAP")
createCheckbox(Pages.Weapons, "Rapid Fire (Zero Delay Between Shots)", "RapidFire")
createCheckbox(Pages.Weapons, "No Recoil (Zero Camera Kick)", "NoRecoil")
createCheckbox(Pages.Weapons, "No Spread (100% Pinpoint)", "NoSpread")
createCheckbox(Pages.Weapons, "Triggerbot (Auto-Fire on Crosshair)", "Triggerbot")
createSlider(Pages.Weapons, "Triggerbot Delay (sec)", "TriggerDelay", 0.0, 0.5, 0.02)
createSlider(Pages.Weapons, "Multi-Tap Bullets per Click", "MultiTapCount", 1, 5, 1)

createHeader(Pages.Weapons, "BALLISTICS, CHAIN LIGHTNING & DAMAGE MODS")
createCheckbox(Pages.Weapons, "Always Headshot (2.5x Crit)", "AlwaysHeadshot")
createCheckbox(Pages.Weapons, "Wallbang (Shoot Through Walls)", "Wallbang")
createCheckbox(Pages.Weapons, "Bypass ForceField (Ignore Shields)", "BypassForceField")
createCheckbox(Pages.Weapons, "Chain Lightning (Shock Nearby Enemies)", "ChainLightning")
createSlider(Pages.Weapons, "Lightning Chain Radius (Studs)", "ChainLightningRadius", 6, 50, 2)
createSlider(Pages.Weapons, "Ricochet Wall Bounces", "RicochetBounces", 0, 3, 1)
createSlider(Pages.Weapons, "Freeze Target on Hit (sec)", "FreezeTargetTime", 0.0, 3.0, 0.25)
createSlider(Pages.Weapons, "3D Bullet Flight Speed", "BulletSpeed", 100, 1200, 20)
createSlider(Pages.Weapons, "Bullet Gravity Drop", "BulletGravityDrop", 0, 150, 5)
createSlider(Pages.Weapons, "Damage Multiplier", "DamageMultiplier", 0.5, 10.0, 0.25)
createSlider(Pages.Weapons, "Vampirism (Life Steal %)", "VampirismPercent", 0, 100, 5)
createSlider(Pages.Weapons, "Bullet Knockback Impulse", "KnockbackForce", 0, 120, 5)
createCheckbox(Pages.Weapons, "Explosive Bullets (AoE Blast)", "ExplosiveBullets")
createSlider(Pages.Weapons, "Explosion Radius (Studs)", "ExplosionRadius", 4, 35, 1)

createHeader(Pages.Weapons, "TACTICAL KNIFE SETTINGS")
createSlider(Pages.Weapons, "Knife Slash Reach (Studs)", "KnifeReach", 4, 25, 1)
createSlider(Pages.Weapons, "Backstab Damage Multiplier", "KnifeBackstabMult", 1.0, 6.0, 0.5)
createSlider(Pages.Weapons, "Knife Lunge Forward Boost", "KnifeLungeForce", 0, 80, 5)

----------------------------------------------------------------------
-- 5. ВКЛАДКА NM (NEVERMISS)
----------------------------------------------------------------------
createHeader(Pages.NM, "NM — ZERO-MISS BYPASS SUITE (NO MISSES)", Color3.fromRGB(95, 32, 68))
createCheckbox(Pages.NM, "Enable NeverMiss (Never Miss Any Shot)", "NM_Enabled", function(enabled)
	if not enabled then
		destroyVisual("NMTargetBeam")
		destroyVisual("NMTargetHighlight")
	end
end)
createCheckbox(Pages.NM, "Bypass All Miss Reasons (Spread/Ping/Hitchance/Death)", "NM_BypassAllMisses", function(enabled)
	if enabled then
		Config.NoSpread = true
		Config.NoRecoil = true
		Config.ResolverEnabled = true
		Config.SilentHitChance = 100
		if UIUpdaters["NoSpread"] then UIUpdaters["NoSpread"]() end
		if UIUpdaters["NoRecoil"] then UIUpdaters["NoRecoil"]() end
		if UIUpdaters["ResolverEnabled"] then UIUpdaters["ResolverEnabled"]() end
		if UIUpdaters["SilentHitChance"] then UIUpdaters["SilentHitChance"]() end
	end
end)
createCheckbox(Pages.NM, "Dynamic Ping Prediction Compensation", "NM_PingCompensation")
createCheckbox(Pages.NM, "Dead Target Auto-Redirect (Skip Dead)", "NM_DeadTargetRedirect")

createHeader(Pages.NM, "HOMING & INSTANT TELEPORT PROJECTILES", Color3.fromRGB(85, 32, 78))
createCheckbox(Pages.NM, "Homing Bullets (Bullets Track Moving Target)", "NM_HomingBullets")
createSlider(Pages.NM, "Homing Tracking Strength", "NM_HomingTurnStrength", 0.1, 1.0, 0.05)
createCheckbox(Pages.NM, "Bullet Teleport (0ms Instant Hit)", "NM_BulletTeleport")
createCheckbox(Pages.NM, "Bullet Time-Stop Freeze [Toggle M]", "NM_BulletTimeFreeze")
createCheckbox(Pages.NM, "Orbital Bullet Rain Strike [Press N]", "NM_OrbitalStrikeKey")
createCheckbox(Pages.NM, "NM Auto-Shoot (Auto Fire at Locked Target)", "NM_AutoShoot")
createSlider(Pages.NM, "NM Auto-Shoot Delay (sec)", "NM_AutoShootDelay", 0.0, 0.5, 0.02)

createHeader(Pages.NM, "DAMAGE, CHAIN & AURA OVERRIDES", Color3.fromRGB(95, 32, 42))
createCheckbox(Pages.NM, "Infinite Damage (Instant One-Shot Kill)", "NM_InfiniteDamage")
createSlider(Pages.NM, "Multi-Target Chain Count (Targets/Shot)", "NM_MultiTargetCount", 1, 5, 1)
createCheckbox(Pages.NM, "Auto Kill Aura (Damage Enemies in Range)", "NM_KillAura")
createSlider(Pages.NM, "Kill Aura Radius (Studs)", "NM_KillAuraRange", 5, 150, 5)

createHeader(Pages.NM, "TARGETING, SMART BONE & TELEPORT")
createCheckbox(Pages.NM, "360° Global Target Lock (Ignore FOV)", "NM_IgnoreFOV")
createCheckbox(Pages.NM, "Ignore Walls & Obstacles", "NM_IgnoreWalls")
createCheckbox(Pages.NM, "Smart Bone Fallback (Hit Visible Limb)", "NM_SmartBoneFallback")
createCycleSelector(Pages.NM, "Target Priority", "NM_TargetPriority", {"Crosshair", "Distance", "LowestHP"})
createCycleSelector(Pages.NM, "Target Hitbox Bone", "NM_TargetBone", {"Head", "Torso", "Random"})
createCheckbox(Pages.NM, "Teleport Behind Target Keybind [T]", "NM_TeleportBehindKey")
createCheckbox(Pages.NM, "Magnetic Aim Assist (Smooth Pull)", "NM_AimAssistMagnet")
createSlider(Pages.NM, "Magnet Pull Strength", "NM_MagnetStrength", 0.05, 1.0, 0.05)
createCheckbox(Pages.NM, "Draw 3D Target Lock Beam", "NM_ShowTargetBeam", function(enabled)
	if not enabled then destroyVisual("NMTargetBeam") end
end)
createCheckbox(Pages.NM, "Highlight Locked Target (3D Glow)", "NM_HighlightTarget", function(enabled)
	if not enabled then destroyVisual("NMTargetHighlight") end
end)

----------------------------------------------------------------------
-- 6. ВКЛАДКА GS (GAMESENSE)
----------------------------------------------------------------------
createHeader(Pages.GS, "GS — GAMESENSE TICK & EXPLOIT MODULE", Color3.fromRGB(36, 78, 42))
createCheckbox(Pages.GS, "Double Tap (DT — Instant 2-Shot Burst)", "GS_DoubleTap")
createCheckbox(Pages.GS, "Hide Shots (Suppress Projectile Visuals)", "GS_HideShots")
createCheckbox(Pages.GS, "Peek Assist (Auto-Return on Fire [Hold Alt])", "GS_PeekAssist")
createCheckbox(Pages.GS, "Crosshair Status Indicators (DT / NM / AA)", "GS_CrosshairIndicators", function(enabled)
	crosshairIndicatorsLabel.Visible = enabled
end)

createHeader(Pages.GS, "HITBOX EXPANDER (ENLARGE ENEMY HITBOX)", Color3.fromRGB(45, 68, 38))
createCheckbox(Pages.GS, "Enable Hitbox Expander", "GS_HitboxExpander", function(enabled)
	if not enabled then restoreAllHitboxes() end
end)
createSlider(Pages.GS, "Expanded Hitbox Size (Studs)", "GS_HitboxSize", 2.0, 14.0, 0.5)
createSlider(Pages.GS, "Hitbox Visual Transparency", "GS_HitboxTransparency", 0.1, 1.0, 0.05)

createHeader(Pages.GS, "WORLD & NIGHT MODE (SKEET STYLE)")
createCheckbox(Pages.GS, "Enable Night Mode World", "GS_NightMode", function(enabled)
	if not enabled then
		Lighting.Brightness = origBrightness
		Lighting.ClockTime = origClockTime
	end
end)
createSlider(Pages.GS, "Night Ambient Brightness", "GS_NightBrightness", 0.05, 1.5, 0.05)

----------------------------------------------------------------------
-- 7. ВКЛАДКА RAGE
----------------------------------------------------------------------
createHeader(Pages.Rage, "TARGET ORBIT STRAFE (CIRCLE AROUND ENEMY)", Color3.fromRGB(88, 34, 48))
createCheckbox(Pages.Rage, "Enable Orbit Strafe Around Locked Target", "Rage_OrbitTarget")
createSlider(Pages.Rage, "Orbit Radius (Studs)", "Rage_OrbitRadius", 5, 35, 1)
createSlider(Pages.Rage, "Orbit Rotation Speed", "Rage_OrbitSpeed", 1.0, 12.0, 0.5)

createHeader(Pages.Rage, "BLITZ TELEPORT & GRAVITY VORTEX", Color3.fromRGB(75, 34, 85))
createCheckbox(Pages.Rage, "Enable Blitz Teleport (Chain Backstab All)", "Rage_BlitzTeleport")
createSlider(Pages.Rage, "Blitz Teleport Interval (sec)", "Rage_BlitzDelay", 0.08, 1.5, 0.04)
createCheckbox(Pages.Rage, "Enable Gravity Vortex (Pull Enemies Together)", "Rage_GravityVortex")
createSlider(Pages.Rage, "Vortex Pull Distance in Front", "Rage_VortexDistance", 6, 40, 2)

createHeader(Pages.Rage, "EVASION & RESOLVER VISUALS")
createCheckbox(Pages.Rage, "Auto-Dodge Close Enemies (Lateral Dash)", "Rage_AutoDodge")
createSlider(Pages.Rage, "Auto-Dodge Impulse Force", "Rage_DodgePower", 20, 100, 5)
createCheckbox(Pages.Rage, "Enemy Look-Direction Resolver Lasers", "Rage_ResolverLines", function(enabled)
	if not enabled then clearResolverLines() end
end)

----------------------------------------------------------------------
-- 8. ВКЛАДКА RADAR
----------------------------------------------------------------------
createHeader(Pages.Radar, "2D TOP-DOWN MINI-RADAR HUD", Color3.fromRGB(38, 62, 85))
createCheckbox(Pages.Radar, "Enable 2D Mini-Radar (Top-Left)", "Radar_Enabled", function(enabled)
	radarFrame.Visible = enabled
	if not enabled then clearRadarDots() end
end)
createCheckbox(Pages.Radar, "Show Radar Crosshair Grid", "Radar_ShowGrid", function(enabled)
	radarCrossH.Visible = enabled
	radarCrossV.Visible = enabled
end)
createSlider(Pages.Radar, "Radar Window Size (px)", "Radar_Size", 100, 280, 10, function(val)
	radarFrame.Size = UDim2.new(0, val, 0, val)
end)
createSlider(Pages.Radar, "Radar Scan Range (Studs)", "Radar_Range", 80, 800, 20)

----------------------------------------------------------------------
-- 9. ВКЛАДКА PLAYER
----------------------------------------------------------------------
createHeader(Pages.Player, "MOVEMENT & TELEPORT UTILITIES", Color3.fromRGB(45, 58, 88))
createCheckbox(Pages.Player, "Enable Noclip Keybind [Toggle K]", "Player_NoclipKey", function(enabled)
	if not enabled then noclipActive = false end
end)
createCheckbox(Pages.Player, "Click-Teleport [Hold Ctrl + LeftClick]", "Player_ClickTP")
createCheckbox(Pages.Player, "Auto-Regenerate Health (Local)", "Player_AutoRegen")
createCheckbox(Pages.Player, "Rainbow Self-Chams Highlight", "Player_RainbowSelf", function(enabled)
	if not enabled then destroyVisual("PlayerRainbowHL") end
end)

----------------------------------------------------------------------
-- 10. ВКЛАДКА WORLD
----------------------------------------------------------------------
createHeader(Pages.World, "PHYSICS & GRAVITY OVERRIDE", Color3.fromRGB(34, 62, 82))
createCheckbox(Pages.World, "Enable Custom World Gravity", "World_CustomGravity", function(enabled)
	if not enabled then Workspace.Gravity = origGravity end
end)
createSlider(Pages.World, "Gravity Value (Default 196.2)", "World_GravityValue", 10, 450, 5)

createHeader(Pages.World, "LIGHTING, ATMOSPHERE & TIME", Color3.fromRGB(48, 52, 84))
createCheckbox(Pages.World, "Fullbright (Remove Dark Shadows)", "World_Fullbright", function(enabled)
	if not enabled then Lighting.Ambient = origAmbient end
end)
createCheckbox(Pages.World, "No Fog (Clear Long Distance)", "World_NoFog", function(enabled)
	if not enabled then Lighting.FogEnd = origFogEnd end
end)
createCheckbox(Pages.World, "Override Time of Day", "World_CustomTime", function(enabled)
	if not enabled then Lighting.ClockTime = origClockTime end
end)
createSlider(Pages.World, "Time of Day (Hours)", "World_TimeOfDay", 0, 24, 0.5)
createCycleSelector(Pages.World, "World Ambient Tint", "World_AmbientPreset", {"Default", "Purple", "Crimson", "Cyan"}, function(val)
	if val == "Default" then
		Lighting.Ambient = origAmbient
	elseif val == "Purple" then
		Lighting.Ambient = Color3.fromRGB(130, 80, 180)
	elseif val == "Crimson" then
		Lighting.Ambient = Color3.fromRGB(180, 65, 75)
	elseif val == "Cyan" then
		Lighting.Ambient = Color3.fromRGB(70, 165, 195)
	end
end)

----------------------------------------------------------------------
-- 11. ВКЛАДКА MISC
----------------------------------------------------------------------
createHeader(Pages.Misc, "GENERAL UTILITIES & PROTECTION", Color3.fromRGB(36, 65, 58))
createCheckbox(Pages.Misc, "Anti-AFK (Prevent Idle Disconnect)", "Misc_AntiAFK")
createCheckbox(Pages.Misc, "Override Jump Height", "Misc_AutoJumpHeight", function(enabled)
	if not enabled and humanoid then humanoid.JumpHeight = 7.2 end
end)
createSlider(Pages.Misc, "Custom Jump Height (Studs)", "Misc_JumpHeightVal", 4, 45, 1)

createHeader(Pages.Misc, "VISUAL AURA & EFFECTS")
createCheckbox(Pages.Misc, "3D Neon Ring Aura Under Feet", "Misc_NeonRingAura", function(enabled)
	if not enabled then destroyVisual("MiscNeonRing") end
end)
createSlider(Pages.Misc, "Neon Ring Radius", "Misc_RingRadius", 2, 14, 0.5)

----------------------------------------------------------------------
-- 12. ВКЛАДКА ESP
----------------------------------------------------------------------
createHeader(Pages.ESP, "MASTER ESP & TARGET FILTERS", Color3.fromRGB(34, 48, 70))
createCheckbox(Pages.ESP, "Enable ESP Overlay", "ESPEnabled", function(state)
	if not state then clearAllESP() end
end)
createCheckbox(Pages.ESP, "Show Players", "ESPShowPlayers")
createCheckbox(Pages.ESP, "Show Bots / NPCs", "ESPShowNPCs")
createSlider(Pages.ESP, "Max Render Distance (Studs)", "ESPMaxDistance", 50, 2000, 25)

createHeader(Pages.ESP, "BOX & HEALTH INDICATORS")
createCheckbox(Pages.ESP, "2D Bounding Box", "ESPBox")
createCheckbox(Pages.ESP, "2D Box Translucent Fill", "ESPBoxFill")
createCheckbox(Pages.ESP, "Corner Box Style (Instead of Full)", "ESPCornerBox")
createCheckbox(Pages.ESP, "Health Bar (Dynamic Color)", "ESPHealthBar")
createCheckbox(Pages.ESP, "Health Numeric Text (HP)", "ESPHealthText")

createHeader(Pages.ESP, "SKELETON, WEAPON, INFO & CHAMS")
createCheckbox(Pages.ESP, "Skeleton Bones (R6 & R15)", "ESPSkeleton")
createCheckbox(Pages.ESP, "Target Name Tag", "ESPName")
createCheckbox(Pages.ESP, "Equipped Weapon Tag", "ESPWeapon")
createCheckbox(Pages.ESP, "Distance Tag (Studs)", "ESPDistance")
createCheckbox(Pages.ESP, "Head Dot Marker", "ESPHeadDot")
createCheckbox(Pages.ESP, "Snapline Tracers (Bottom Screen)", "ESPTracers")
createCheckbox(Pages.ESP, "Wallhack Chams (Highlight)", "ESPChams")
createSlider(Pages.ESP, "Chams Fill Transparency", "ESPChamsTransparency", 0.1, 0.9, 0.05)

----------------------------------------------------------------------
-- 13. ВКЛАДКА MENU SETTINGS (IMGUI CLASSIC + ВСЕ ПРОШЛЫЕ ТЕМЫ + WATERMARK)
----------------------------------------------------------------------
createHeader(Pages.Menu, "UI THEMES (IMGUI CLASSIC & MATERIAL YOU)", Color3.fromRGB(30, 56, 92))
createButton(Pages.Menu, "Theme: ImGui Classic Blue (Default)", function() applyThemePreset("ImGuiClassic") end, Themes.ImGuiClassic.TitleBg)
createButton(Pages.Menu, "Theme: Material You (Lavender Monet)", function() applyThemePreset("MaterialLavender") end, Themes.MaterialLavender.TitleBg)
createButton(Pages.Menu, "Theme: Material You (Sage Green)", function() applyThemePreset("MaterialSage") end, Themes.MaterialSage.TitleBg)
createButton(Pages.Menu, "Theme: Catppuccin Mocha", function() applyThemePreset("CatppuccinMocha") end, Themes.CatppuccinMocha.TitleBg)
createButton(Pages.Menu, "Theme: Cyberpunk Neon", function() applyThemePreset("CyberpunkNeon") end, Themes.CyberpunkNeon.TitleBg)
createButton(Pages.Menu, "Theme: Nordic Frost", function() applyThemePreset("NordicFrost") end, Themes.NordicFrost.TitleBg)
createButton(Pages.Menu, "Theme: Obsidian & Gold", function() applyThemePreset("ObsidianGold") end, Themes.ObsidianGold.TitleBg)
createButton(Pages.Menu, "Theme: GameSense Green", function() applyThemePreset("GameSenseGreen") end, Themes.GameSenseGreen.TitleBg)

createHeader(Pages.Menu, "WINDOW APPEARANCE & ROUNDING")
createSlider(Pages.Menu, "UI Corner Radius (0=ImGui, 12=Material)", "MenuCornerRadius", 0, 14, 1, function(val)
	mainCorner.CornerRadius = UDim.new(0, val)
	titleCorner.CornerRadius = UDim.new(0, val)
	watermarkCorner.CornerRadius = UDim.new(0, val)
	radarCorner.CornerRadius = UDim.new(0, val)
end)
createSlider(Pages.Menu, "Window Background Transparency", "MenuOpacity", 0.0, 0.7, 0.02, function(val)
	mainFrame.BackgroundTransparency = val
end)
createButton(Pages.Menu, "Center Menu Window on Screen", function()
	mainFrame.Position = UDim2.new(0.5, -280, 0.5, -282)
end)

createHeader(Pages.Menu, "WATERMARK SETTINGS (TOP-RIGHT HUD)", Color3.fromRGB(34, 58, 88))
createCheckbox(Pages.Menu, "Show DLCNever Watermark", "WatermarkEnabled", function(enabled)
	watermarkBtn.Visible = enabled
end)
createCheckbox(Pages.Menu, "Toggle Menu by Clicking Watermark", "WatermarkClickToggle")
createCheckbox(Pages.Menu, "Show FPS Counter on Watermark", "WatermarkShowFPS")
createCheckbox(Pages.Menu, "Show Ping (ms) on Watermark", "WatermarkShowPing")
createCheckbox(Pages.Menu, "Show Version on Watermark", "WatermarkShowVersion")

createHeader(Pages.Menu, "SCRIPT UNLOAD & CLOSE (SAFETY LOCK)", Color3.fromRGB(85, 34, 34))

local warningBox = Instance.new("TextLabel")
warningBox.Size = UDim2.new(1, -6, 0, 54)
warningBox.BackgroundColor3 = Color3.fromRGB(42, 24, 24)
warningBox.BorderColor3 = Color3.fromRGB(140, 55, 55)
warningBox.Text = "WARNING: Closing DLCNever will disable all active movement mods, remove given weapons, clear ESP and destroy this GUI!"
warningBox.TextColor3 = Color3.fromRGB(255, 195, 195)
warningBox.Font = Enum.Font.Code
warningBox.TextSize = 11
warningBox.TextWrapped = true
warningBox.ZIndex = 12
warningBox.Parent = Pages.Menu

local confirmWarnBtn
local finalCloseBtn

confirmWarnBtn = createButton(Pages.Menu, "[1] Accept Warning to Unlock Close", function()
	Config.CloseWarningAccepted = true
	confirmWarnBtn.Text = "[1] Warning Accepted (Unlocked)"
	confirmWarnBtn.BackgroundColor3 = Color3.fromRGB(45, 95, 55)
	finalCloseBtn.Text = "[2] UNLOAD & CLOSE DLCNEVER NOW"
	finalCloseBtn.BackgroundColor3 = Color3.fromRGB(185, 42, 42)
	finalCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end, Color3.fromRGB(75, 55, 30))

finalCloseBtn = createButton(Pages.Menu, "[2] Close Script [LOCKED - Accept Above]", function()
	if Config.CloseWarningAccepted then
		unloadScript()
	end
end, Color3.fromRGB(45, 45, 50))
finalCloseBtn.TextColor3 = Color3.fromRGB(130, 130, 135)

createButton(Pages.Menu, "Re-Lock Close Button", function()
	Config.CloseWarningAccepted = false
	confirmWarnBtn.Text = "[1] Accept Warning to Unlock Close"
	confirmWarnBtn.BackgroundColor3 = Color3.fromRGB(75, 55, 30)
	finalCloseBtn.Text = "[2] Close Script [LOCKED - Accept Above]"
	finalCloseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	finalCloseBtn.TextColor3 = Color3.fromRGB(130, 130, 135)
end, Color3.fromRGB(36, 44, 56))

----------------------------------------------------------------------
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ФИЗИКИ И ВВОДА
----------------------------------------------------------------------
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function castRay(origin, direction)
	if not character then return nil end
	rayParams.FilterDescendantsInstances = {character}
	for _, obj in pairs(VisualObjects) do
		if obj:IsA("BasePart") then
			table.insert(rayParams.FilterDescendantsInstances, obj)
		end
	end
	for _, line in pairs(ResolverLinesPool) do
		table.insert(rayParams.FilterDescendantsInstances, line)
	end
	return Workspace:Raycast(origin, direction, rayParams)
end

local function predictLandingPosition(startPos, vel)
	local g = Workspace.Gravity
	local simPos = startPos
	local simVel = vel
	local stepDt = 0.06

	for _ = 1, 45 do
		local nextVel = simVel + Vector3.new(0, -g * stepDt, 0)
		local nextPos = simPos + (simVel + nextVel) * 0.5 * stepDt
		local hit = castRay(simPos, nextPos - simPos)
		if hit then
			return hit.Position
		end
		simPos = nextPos
		simVel = nextVel
	end
	return nil
end

local function getNearestEnemyPosition()
	if not rootPart then return nil end
	local bestPos = nil
	local bestDist = math.huge
	for _, model in ipairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model ~= character then
			local hum = model:FindFirstChildOfClass("Humanoid")
			local hrp = model:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				local d = (hrp.Position - rootPart.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestPos = hrp.Position
				end
			end
		end
	end
	return bestPos
end

----------------------------------------------------------------------
-- ОБНОВЛЕНИЕ 2D-РАДАРА
----------------------------------------------------------------------
local function updateRadarHUD()
	if not Config.Radar_Enabled then return end
	local cam = Workspace.CurrentCamera
	if not cam or not rootPart then return end

	local activeModels = {}
	local look = cam.CFrame.LookVector
	local camYaw = math.atan2(-look.X, -look.Z)
	local cosY = math.cos(-camYaw)
	local sinY = math.sin(-camYaw)
	local range = math.max(Config.Radar_Range, 10)

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= character then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local hrp = obj:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				local rel = hrp.Position - rootPart.Position
				local horizDist = Vector2.new(rel.X, rel.Z).Magnitude
				if horizDist <= range then
					activeModels[obj] = true
					local dot = RadarDotsPool[obj]
					if not dot then
						dot = Instance.new("Frame")
						dot.AnchorPoint = Vector2.new(0.5, 0.5)
						dot.Size = UDim2.new(0, 6, 0, 6)
						dot.BorderSizePixel = 0
						dot.ZIndex = 36
						dot.Parent = radarFrame
						Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
						RadarDotsPool[obj] = dot
					end

					local isPlayer = (Players:GetPlayerFromCharacter(obj) ~= nil)
					dot.BackgroundColor3 = isPlayer and Color3.fromRGB(255, 85, 95) or Color3.fromRGB(80, 210, 255)

					local rotX = rel.X * cosY - rel.Z * sinY
					local rotZ = rel.X * sinY + rel.Z * cosY
					local normX = math.clamp(rotX / range, -1, 1) * 0.45 + 0.5
					local normY = math.clamp(rotZ / range, -1, 1) * 0.45 + 0.5
					dot.Position = UDim2.new(normX, 0, normY, 0)
				end
			end
		end
	end

	for m, dot in pairs(RadarDotsPool) do
		if not activeModels[m] then
			if dot then dot:Destroy() end
			RadarDotsPool[m] = nil
		end
	end
end

----------------------------------------------------------------------
-- ЛОГИКА ANTI-AIM (MANUAL AA [8 / 9] + MODES), 3RD PERSON И ASPECT RATIO
----------------------------------------------------------------------
local function updateAntiAimAndThirdPerson(dt)
	local cam = Workspace.CurrentCamera
	if not cam or not character or not humanoid or not rootPart or humanoid.Health <= 0 then
		manualLeftArrow.Visible = false
		manualRightArrow.Visible = false
		aaArrowIndicator.Visible = false
		return
	end

	if Config.ThirdPersonEnabled then
		player.CameraMinZoomDistance = Config.ThirdPersonDistance
		player.CameraMaxZoomDistance = math.max(origMaxZoom, Config.ThirdPersonDistance)
		setCharacterLocalTransparency(0)

		local head = character:FindFirstChild("Head")
		local focusOrigin = (head and head.Position or rootPart.Position) + Vector3.new(0, Config.ThirdPersonHeight - 1.5, 0)
		local camLook = cam.CFrame.LookVector
		local desiredCamPos = focusOrigin - (camLook * Config.ThirdPersonDistance)

		local wallHit = castRay(focusOrigin, desiredCamPos - focusOrigin)
		local finalCamPos = wallHit and (wallHit.Position + camLook * 0.6) or desiredCamPos
		cam.CFrame = CFrame.lookAt(finalCamPos, focusOrigin + camLook * 10)
	end

	if Config.AspectRatioEnabled then
		local vScale = Config.AspectRatioValue
		cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, vScale, 0, 0, 0, 1)
	end

	if Config.AntiAimEnabled then
		humanoid.AutoRotate = false

		-- Динамическое ускорение джиттера при движении
		local speedBoostHz = 0
		if Config.AA_DynamicJitterSpeed then
			speedBoostHz = rootPart.AssemblyLinearVelocity.Magnitude * 0.8
		end

		aaJitterTimer += dt
		local jitterInterval = 1 / math.max(Config.AA_JitterSpeed + speedBoostHz, 1)
		if aaJitterTimer >= jitterInterval then
			aaJitterTimer = 0
			aaJitterStep = (aaJitterStep + 1) % 3
		end

		local refLook = cam.CFrame.LookVector
		if Config.AA_AtTargets then
			local enemyPos = getNearestEnemyPosition()
			if enemyPos then
				local toEnemy = enemyPos - rootPart.Position
				if toEnemy.Magnitude > 0.5 then
					refLook = toEnemy.Unit
				end
			end
		end
		local baseCamYaw = math.atan2(-refLook.X, -refLook.Z)

		local baseYawDeg = aaInverted and -Config.AA_BaseYaw or Config.AA_BaseYaw

		if Config.AA_Freestanding then
			local rightVec = Vector3.new(-refLook.Z, 0, refLook.X).Unit
			local hitRight = castRay(rootPart.Position, rightVec * 8)
			local hitLeft = castRay(rootPart.Position, -rightVec * 8)
			if hitRight and not hitLeft then
				baseYawDeg = -90
			elseif hitLeft and not hitRight then
				baseYawDeg = 90
			end
		end

		local isAir = (humanoid.FloorMaterial == Enum.Material.Air)
		local activeModifier = Config.AA_YawModifier
		if isAir and Config.AA_AirMode ~= "Same" then
			if Config.AA_AirMode == "Air Spin" then
				activeModifier = "Spin"
			elseif Config.AA_AirMode == "Air Jitter" then
				activeModifier = "Jitter"
			elseif Config.AA_AirMode == "Air 180" then
				baseYawDeg = 180
				activeModifier = "Static"
			end
		end

		-- MANUAL AA OVERRIDE (8 = Right [-90], 9 = Left [+90]) + выбор режима Manual AA
		if Config.AA_ManualEnabled and aaManualSide ~= nil then
			if aaManualSide == "Right" then
				baseYawDeg = -90
			elseif aaManualSide == "Left" then
				baseYawDeg = 90
			end
			activeModifier = Config.AA_ManualMode
		end

		-- Вычисление модификатора Yaw
		local modOffsetDeg = 0
		if activeModifier == "Spin" then
			aaSpinAngle = (aaSpinAngle + Config.AA_SpinSpeed * dt) % 360
			modOffsetDeg = aaSpinAngle
		elseif activeModifier == "Jitter" then
			modOffsetDeg = (aaJitterStep % 2 == 0) and (Config.AA_JitterRange * 0.5) or (-Config.AA_JitterRange * 0.5)
		elseif activeModifier == "3-Way" then
			if aaJitterStep == 0 then
				modOffsetDeg = -Config.AA_JitterRange
			elseif aaJitterStep == 1 then
				modOffsetDeg = 0
			else
				modOffsetDeg = Config.AA_JitterRange
			end
		elseif activeModifier == "Ping-Pong" then
			aaSwayPhase += dt * (Config.AA_SpinSpeed / 180)
			local triangle = math.abs((aaSwayPhase % 2) - 1) * 2 - 1
			modOffsetDeg = triangle * (Config.AA_JitterRange * 0.5)
		elseif activeModifier == "Random" then
			modOffsetDeg = math.random(-Config.AA_JitterRange, Config.AA_JitterRange)
		elseif activeModifier == "Sway" then
			aaSwayPhase += dt * 6
			modOffsetDeg = math.sin(aaSwayPhase) * (Config.AA_JitterRange * 0.5)
		end

		-- On-Shot Flick при выстреле
		if os.clock() < aaOnShotFlickUntil then
			modOffsetDeg += Config.AA_OnShotAngle
		end

		local totalYawRad = baseCamYaw + math.rad(baseYawDeg + modOffsetDeg)

		if Config.AA_FakeLagTicks > 0 then
			aaFakeLagCounter += 1
			if aaFakeLagCounter >= Config.AA_FakeLagTicks then
				aaFakeLagCounter = 0
				aaLastAppliedYaw = totalYawRad
			end
			totalYawRad = aaLastAppliedYaw
		else
			aaLastAppliedYaw = totalYawRad
		end

		local pos = rootPart.Position
		local rollRad = math.rad(Config.AA_RollAngle)
		rootPart.CFrame = CFrame.new(pos) * CFrame.Angles(0, totalYawRad, rollRad)

		-- Отрисовка индикаторов Manual AA (< [9] | [8] >) и стрелки направления
		if Config.AA_ShowArrows then
			local relYaw = totalYawRad - baseCamYaw
			local screenCenter = cam.ViewportSize * 0.5
			local radius = 52
			local arrowX = screenCenter.X - math.sin(relYaw) * radius
			local arrowY = screenCenter.Y - math.cos(relYaw) * radius
			aaArrowIndicator.Position = UDim2.new(0, arrowX, 0, arrowY)
			aaArrowIndicator.Rotation = math.deg(-relYaw)
			aaArrowIndicator.Visible = true

			manualLeftArrow.Visible = Config.AA_ManualEnabled
			manualRightArrow.Visible = Config.AA_ManualEnabled
			manualLeftArrow.TextColor3 = (aaManualSide == "Left") and currentAccentColor or Color3.fromRGB(120, 125, 135)
			manualRightArrow.TextColor3 = (aaManualSide == "Right") and currentAccentColor or Color3.fromRGB(120, 125, 135)
		else
			aaArrowIndicator.Visible = false
			manualLeftArrow.Visible = false
			manualRightArrow.Visible = false
		end

		if Config.AA_FakeDuck and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			humanoid.HipHeight = (humanoid.RigType == Enum.HumanoidRigType.R15) and 0.6 or -1.2
		else
			humanoid.HipHeight = (humanoid.RigType == Enum.HumanoidRigType.R15) and 2.0 or 0
		end

		if neckMotor and originalNeckC0 then
			local pitchAngle = 0
			if Config.AA_PitchMode == "Down" then
				pitchAngle = math.rad(-45)
			elseif Config.AA_PitchMode == "Up" then
				pitchAngle = math.rad(45)
			elseif Config.AA_PitchMode == "Zero" then
				pitchAngle = 0
			elseif Config.AA_PitchMode == "Jitter" then
				pitchAngle = (aaJitterStep % 2 == 0) and math.rad(-42) or math.rad(42)
			elseif Config.AA_PitchMode == "SpinPitch" then
				aaPitchSpinAngle = (aaPitchSpinAngle + dt * 12)
				pitchAngle = math.sin(aaPitchSpinAngle) * math.rad(50)
			elseif Config.AA_PitchMode == "Custom" then
				pitchAngle = math.rad(Config.AA_CustomPitch)
			end
			neckMotor.C0 = originalNeckC0 * CFrame.Angles(pitchAngle, 0, 0)
		end

		if waistMotor and originalWaistC0 then
			local leanAngle = 0
			local leanMode = Config.AA_BodyLean
			if aaInverted then
				if leanMode == "Left" then leanMode = "Right"
				elseif leanMode == "Right" then leanMode = "Left" end
			end

			if leanMode == "Left" then
				leanAngle = math.rad(22)
			elseif leanMode == "Right" then
				leanAngle = math.rad(-22)
			elseif leanMode == "Jitter" then
				leanAngle = (aaJitterStep % 2 == 0) and math.rad(24) or math.rad(-24)
			end
			waistMotor.C0 = originalWaistC0 * CFrame.Angles(0, 0, leanAngle)
		end

		if #legMotors > 0 then
			for idx, item in ipairs(legMotors) do
				if item.motor and item.motor.Parent then
					if Config.AA_LegMode == "Slide" then
						local spread = (idx % 2 == 0) and math.rad(18) or math.rad(-18)
						item.motor.C0 = item.origC0 * CFrame.Angles(spread, 0, 0)
					elseif Config.AA_LegMode == "JitterLegs" then
						local swing = (aaJitterStep % 2 == 0) and math.rad(35) or math.rad(-35)
						if idx % 2 == 0 then swing = -swing end
						item.motor.C0 = item.origC0 * CFrame.Angles(swing, 0, 0)
					elseif Config.AA_LegMode == "Moonwalk" then
						local wave = math.sin(os.clock() * 14) * math.rad(32)
						if idx % 2 == 0 then wave = -wave end
						item.motor.C0 = item.origC0 * CFrame.Angles(-wave, 0, 0)
					else
						item.motor.C0 = item.origC0
					end
				end
			end
		end
	else
		aaArrowIndicator.Visible = false
		manualLeftArrow.Visible = false
		manualRightArrow.Visible = false
	end
end

----------------------------------------------------------------------
-- ОТРИСОВКА ESP
----------------------------------------------------------------------
local R15_BONES = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local R6_BONES = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Torso", "Right Arm"},
	{"Torso", "Left Leg"},
	{"Torso", "Right Leg"}
}

local function draw2DLine(lineFrame, p1, p2, color, thickness)
	local diff = p2 - p1
	local len = diff.Magnitude
	if len < 1 then
		lineFrame.Visible = false
		return
	end
	local mid = (p1 + p2) * 0.5
	lineFrame.Size = UDim2.new(0, len, 0, thickness or 1.5)
	lineFrame.Position = UDim2.new(0, mid.X, 0, mid.Y)
	lineFrame.Rotation = math.deg(math.atan2(diff.Y, diff.X))
	lineFrame.BackgroundColor3 = color
	lineFrame.Visible = true
end

local function getOrCreateESPEntry(model)
	if ESPPool[model] then
		return ESPPool[model]
	end

	local container = Instance.new("Folder")
	container.Name = "ESP_" .. model.Name
	container.Parent = espFolder

	local fullBox = Instance.new("Frame")
	fullBox.BackgroundTransparency = 1
	fullBox.BorderSizePixel = 0
	fullBox.Visible = false
	fullBox.Parent = container
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = 1.4
	boxStroke.Parent = fullBox

	local corners = {}
	for i = 1, 8 do
		local c = Instance.new("Frame")
		c.BorderSizePixel = 0
		c.Visible = false
		c.Parent = container
		corners[i] = c
	end

	local hpBg = Instance.new("Frame")
	hpBg.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	hpBg.BorderSizePixel = 0
	hpBg.Visible = false
	hpBg.Parent = container

	local hpFill = Instance.new("Frame")
	hpFill.BorderSizePixel = 0
	hpFill.Parent = hpBg

	local topText = Instance.new("TextLabel")
	topText.BackgroundTransparency = 1
	topText.Font = Enum.Font.Code
	topText.TextSize = 12
	topText.TextStrokeTransparency = 0.2
	topText.TextColor3 = Color3.fromRGB(245, 245, 250)
	topText.Visible = false
	topText.Parent = container

	local bottomText = Instance.new("TextLabel")
	bottomText.BackgroundTransparency = 1
	bottomText.Font = Enum.Font.Code
	bottomText.TextSize = 11
	bottomText.TextStrokeTransparency = 0.2
	bottomText.TextColor3 = Color3.fromRGB(185, 220, 255)
	bottomText.Visible = false
	bottomText.Parent = container

	local headDot = Instance.new("Frame")
	headDot.AnchorPoint = Vector2.new(0.5, 0.5)
	headDot.Size = UDim2.new(0, 6, 0, 6)
	headDot.BorderSizePixel = 0
	headDot.Visible = false
	headDot.Parent = container
	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = headDot

	local tracer = Instance.new("Frame")
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.Parent = container

	local bones = {}
	for i = 1, 14 do
		local b = Instance.new("Frame")
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.BorderSizePixel = 0
		b.Visible = false
		b.Parent = container
		bones[i] = b
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPChams"
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false
	highlight.Parent = container

	local entry = {
		container = container,
		fullBox = fullBox,
		boxStroke = boxStroke,
		corners = corners,
		hpBg = hpBg,
		hpFill = hpFill,
		topText = topText,
		bottomText = bottomText,
		headDot = headDot,
		tracer = tracer,
		bones = bones,
		highlight = highlight
	}
	ESPPool[model] = entry
	return entry
end

local function hideESPEntry(entry)
	entry.fullBox.Visible = false
	for _, c in ipairs(entry.corners) do c.Visible = false end
	entry.hpBg.Visible = false
	entry.topText.Visible = false
	entry.bottomText.Visible = false
	entry.headDot.Visible = false
	entry.tracer.Visible = false
	for _, b in ipairs(entry.bones) do b.Visible = false end
	entry.highlight.Enabled = false
end

local function getModelScreenBounds(cam, model, hrp)
	local _, size = model:GetBoundingBox()
	local halfX = math.min(size.X * 0.5, 2.2)
	local halfY = math.min(size.Y * 0.5, 3.2)
	local halfZ = math.min(size.Z * 0.5, 2.2)
	local center = hrp.Position

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local anyVisible = false

	for _, sx in ipairs({-1, 1}) do
		for _, sy in ipairs({-1, 1}) do
			for _, sz in ipairs({-1, 1}) do
				local worldCorner = center + Vector3.new(sx * halfX, sy * halfY, sz * halfZ)
				local screenPt, onScreen = cam:WorldToViewportPoint(worldCorner)
				if screenPt.Z > 0 then
					if onScreen then anyVisible = true end
					if screenPt.X < minX then minX = screenPt.X end
					if screenPt.Y < minY then minY = screenPt.Y end
					if screenPt.X > maxX then maxX = screenPt.X end
					if screenPt.Y > maxY then maxY = screenPt.Y end
				end
			end
		end
	end

	if not anyVisible or minX == math.huge then
		return nil
	end

	return minX, minY, math.max(maxX - minX, 8), math.max(maxY - minY, 12)
end

local function updateESP()
	if not Config.ESPEnabled then return end

	local cam = Workspace.CurrentCamera
	if not cam then return end

	local activeModels = {}
	local screenSize = cam.ViewportSize

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= character then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local hrp = obj:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 then
				local targetPlayer = Players:GetPlayerFromCharacter(obj)
				local isPlayer = (targetPlayer ~= nil)

				if (isPlayer and Config.ESPShowPlayers) or (not isPlayer and Config.ESPShowNPCs) then
					local dist = (hrp.Position - cam.CFrame.Position).Magnitude
					if dist <= Config.ESPMaxDistance then
						activeModels[obj] = true
						local entry = getOrCreateESPEntry(obj)
						local espColor = isPlayer and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(80, 200, 255)

						entry.highlight.Enabled = Config.ESPChams
						if Config.ESPChams then
							entry.highlight.FillColor = espColor
							entry.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
							entry.highlight.FillTransparency = Config.ESPChamsTransparency
						end

						local leftX, topY, width, height = getModelScreenBounds(cam, obj, hrp)
						if leftX then
							local centerX = leftX + width * 0.5
							local head = obj:FindFirstChild("Head")

							if Config.ESPBox then
								if Config.ESPCornerBox then
									entry.fullBox.Visible = false
									local cl = math.max(width * 0.28, 4)
									local t = 1.6
									local cData = {
										{leftX, topY, cl, t}, {leftX, topY, t, cl},
										{leftX + width - cl, topY, cl, t}, {leftX + width - t, topY, t, cl},
										{leftX, topY + height - t, cl, t}, {leftX, topY + height - cl, t, cl},
										{leftX + width - cl, topY + height - t, cl, t}, {leftX + width - t, topY + height - cl, t, cl}
									}
									for idx, d in ipairs(cData) do
										local f = entry.corners[idx]
										f.Position = UDim2.new(0, d[1], 0, d[2])
										f.Size = UDim2.new(0, d[3], 0, d[4])
										f.BackgroundColor3 = espColor
										f.Visible = true
									end
								else
									for _, c in ipairs(entry.corners) do c.Visible = false end
									entry.fullBox.Position = UDim2.new(0, leftX, 0, topY)
									entry.fullBox.Size = UDim2.new(0, width, 0, height)
									entry.boxStroke.Color = espColor
									entry.fullBox.BackgroundColor3 = espColor
									entry.fullBox.BackgroundTransparency = Config.ESPBoxFill and 0.85 or 1.0
									entry.fullBox.Visible = true
								end
							else
								entry.fullBox.Visible = false
								for _, c in ipairs(entry.corners) do c.Visible = false end
							end

							if Config.ESPHealthBar then
								local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
								entry.hpBg.Position = UDim2.new(0, leftX - 6, 0, topY)
								entry.hpBg.Size = UDim2.new(0, 3, 0, height)
								entry.hpBg.Visible = true

								entry.hpFill.Position = UDim2.new(0, 0, 1 - hpRatio, 0)
								entry.hpFill.Size = UDim2.new(1, 0, hpRatio, 0)
								entry.hpFill.BackgroundColor3 = Color3.fromRGB(235, 55, 55):Lerp(Color3.fromRGB(65, 235, 95), hpRatio)
							else
								entry.hpBg.Visible = false
							end

							if Config.ESPName or Config.ESPHealthText then
								local labelParts = {}
								if Config.ESPName then
									table.insert(labelParts, isPlayer and targetPlayer.Name or (obj.Name .. " [NPC]"))
								end
								if Config.ESPHealthText then
									table.insert(labelParts, string.format("[%d HP]", math.floor(hum.Health)))
								end
								entry.topText.Text = table.concat(labelParts, " ")
								entry.topText.Position = UDim2.new(0, centerX - 80, 0, topY - 16)
								entry.topText.Size = UDim2.new(0, 160, 0, 14)
								entry.topText.Visible = true
							else
								entry.topText.Visible = false
							end

							if Config.ESPDistance or Config.ESPWeapon then
								local botParts = {}
								if Config.ESPDistance then
									table.insert(botParts, string.format("%dm", math.floor(dist)))
								end
								if Config.ESPWeapon then
									local tool = obj:FindFirstChildOfClass("Tool")
									if tool then
										table.insert(botParts, "[" .. tool.Name .. "]")
									end
								end
								entry.bottomText.Text = table.concat(botParts, " ")
								entry.bottomText.Position = UDim2.new(0, centerX - 80, 0, topY + height + 2)
								entry.bottomText.Size = UDim2.new(0, 160, 0, 14)
								entry.bottomText.Visible = #botParts > 0
							else
								entry.bottomText.Visible = false
							end

							if Config.ESPHeadDot and head then
								local hPos, hVis = cam:WorldToViewportPoint(head.Position)
								entry.headDot.Visible = hVis
								if hVis then
									entry.headDot.Position = UDim2.new(0, hPos.X, 0, hPos.Y)
									entry.headDot.BackgroundColor3 = Color3.fromRGB(255, 230, 70)
								end
							else
								entry.headDot.Visible = false
							end

							if Config.ESPTracers then
								local startPt = Vector2.new(screenSize.X * 0.5, screenSize.Y)
								local endPt = Vector2.new(centerX, topY + height)
								draw2DLine(entry.tracer, startPt, endPt, espColor, 1.2)
							else
								entry.tracer.Visible = false
							end

							if Config.ESPSkeleton then
								local boneList = (hum.RigType == Enum.HumanoidRigType.R15) and R15_BONES or R6_BONES
								for idx = 1, #entry.bones do
									local pair = boneList[idx]
									local lineFrame = entry.bones[idx]
									if pair then
										local pA = obj:FindFirstChild(pair[1])
										local pB = obj:FindFirstChild(pair[2])
										if pA and pB then
											local sA, vA = cam:WorldToViewportPoint(pA.Position)
											local sB, vB = cam:WorldToViewportPoint(pB.Position)
											if vA and vB then
												draw2DLine(lineFrame, Vector2.new(sA.X, sA.Y), Vector2.new(sB.X, sB.Y), Color3.fromRGB(255, 255, 255), 1.3)
											else
												lineFrame.Visible = false
											end
										else
											lineFrame.Visible = false
										end
									else
										lineFrame.Visible = false
									end
								end
							else
								for _, b in ipairs(entry.bones) do b.Visible = false end
							end
						else
							hideESPEntry(entry)
							entry.highlight.Enabled = Config.ESPChams
						end
					end
				end
			end
		end
	end

	for model, entry in pairs(ESPPool) do
		if not activeModels[model] then
			if entry.container then entry.container:Destroy() end
			if entry.highlight then entry.highlight:Destroy() end
			ESPPool[model] = nil
		end
	end
end

----------------------------------------------------------------------
-- ОБРАБОТКА ВВОДА КЛАВИШ И МЫШИ (MANUAL AA: 8 = RIGHT, 9 = LEFT)
----------------------------------------------------------------------
table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if isUnloaded or gameProcessed or not character or not humanoid or not rootPart or humanoid.Health <= 0 then
		return
	end

	-- MANUAL AA: 8 = Направо (-90), 9 = Налево (+90)
	if Config.AntiAimEnabled and Config.AA_ManualEnabled then
		if input.KeyCode == Enum.KeyCode.Eight or input.KeyCode == Enum.KeyCode.KeypadEight then
			aaManualSide = (aaManualSide == "Right") and nil or "Right"
		elseif input.KeyCode == Enum.KeyCode.Nine or input.KeyCode == Enum.KeyCode.KeypadNine then
			aaManualSide = (aaManualSide == "Left") and nil or "Left"
		end
	end

	-- Desync Inverter [F]
	if Config.AntiAimEnabled and Config.AA_InvertKeyEnabled and input.KeyCode == Enum.KeyCode.F then
		aaInverted = not aaInverted
	end

	-- Player: Noclip Toggle [K]
	if Config.Player_NoclipKey and input.KeyCode == Enum.KeyCode.K then
		noclipActive = not noclipActive
	end

	-- Player: Click-TP [LeftCtrl + LeftClick]
	if Config.Player_ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 then
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			local cam = Workspace.CurrentCamera
			if cam then
				local mousePos = UserInputService:GetMouseLocation()
				local unitRay = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
				local hit = castRay(unitRay.Origin, unitRay.Direction * 1000)
				if hit then
					rootPart.AssemblyLinearVelocity = Vector3.zero
					rootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3.2, 0))
				end
			end
		end
	end

	if input.KeyCode == Config.ThirdPersonKey and not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		Config.ThirdPersonEnabled = not Config.ThirdPersonEnabled
		if not Config.ThirdPersonEnabled then
			disableThirdPersonRestore()
		end
		if UIUpdaters["ThirdPersonEnabled"] then
			UIUpdaters["ThirdPersonEnabled"]()
		end
	end

	if Config.NM_Enabled and input.KeyCode == Enum.KeyCode.M then
		Config.NM_BulletTimeFreeze = not Config.NM_BulletTimeFreeze
		if UIUpdaters["NM_BulletTimeFreeze"] then
			UIUpdaters["NM_BulletTimeFreeze"]()
		end
	end

	if Config.NM_Enabled and Config.NM_OrbitalStrikeKey and input.KeyCode == Enum.KeyCode.N then
		local targets = findNeverMissTargets(5)
		for _, tData in ipairs(targets) do
			local skyOrigin = tData.part.Position + Vector3.new(math.random(-6, 6), 55, math.random(-6, 6))
			spawnFlyingBullet(skyOrigin, tData.part.Position, 0, tData.part, function()
				applyDamageToTarget(tData.hum, 65, tData.part, Vector3.new(0, -1, 0))
			end)
		end
	end

	if Config.NM_Enabled and Config.NM_TeleportBehindKey and input.KeyCode == Enum.KeyCode.T then
		local targets = findNeverMissTargets(1)
		if #targets > 0 then
			local targetModel = targets[1].model
			local targetHrp = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
			if targetHrp then
				local behindCF = targetHrp.CFrame * CFrame.new(0, 0, 4.5)
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.CFrame = behindCF
			end
		end
	end

	if Config.GS_PeekAssist and input.KeyCode == Enum.KeyCode.LeftAlt then
		peekSavedCFrame = rootPart.CFrame
	end

	if Config.QuickTurn180 and input.KeyCode == Enum.KeyCode.V then
		local mult = getSpeedMult()
		local cam = Workspace.CurrentCamera
		if cam then
			local look = cam.CFrame.LookVector
			local horizLook = Vector3.new(look.X, 0, look.Z).Unit
			local flippedLook = -horizLook
			cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + Vector3.new(flippedLook.X, look.Y, flippedLook.Z))
		end
		rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.pi, 0)
		local vel = rootPart.AssemblyLinearVelocity
		local keep = Config.TurnMomentumKeep * mult
		rootPart.AssemblyLinearVelocity = Vector3.new(-vel.X * keep, vel.Y, -vel.Z * keep)
	end
end))

----------------------------------------------------------------------
-- ЦИКЛ RENDER STEPPED
----------------------------------------------------------------------
table.insert(Connections, RunService.RenderStepped:Connect(function(dt)
	if isUnloaded then return end

	local now = os.clock()
	for i = #LogEntries, 1, -1 do
		local entry = LogEntries[i]
		local timeLeft = entry.expiresAt - now
		if timeLeft <= 0 then
			if entry.slot then entry.slot:Destroy() end
			table.remove(LogEntries, i)
		elseif timeLeft < 0.55 and not entry.fading then
			entry.fading = true
			TweenService:Create(
				entry.card,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1}
			):Play()
			TweenService:Create(entry.label, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
			TweenService:Create(entry.stroke, TweenInfo.new(0.45), {Transparency = 1}):Play()
			TweenService:Create(entry.sideBar, TweenInfo.new(0.45), {BackgroundTransparency = 1}):Play()
		end
	end

	fpsCounter += 1
	if now - fpsLastUpdate >= 0.4 then
		currentFPS = math.floor(fpsCounter / (now - fpsLastUpdate) + 0.5)
		fpsCounter = 0
		fpsLastUpdate = now

		if Config.WatermarkEnabled then
			local parts = {SCRIPT_NAME}
			if Config.WatermarkShowVersion then
				table.insert(parts, SCRIPT_VERSION)
			end
			if Config.WatermarkShowFPS then
				table.insert(parts, string.format("%d FPS", currentFPS))
			end
			if Config.WatermarkShowPing then
				local pingMs = math.floor(getCurrentPingSeconds() * 1000)
				table.insert(parts, string.format("%d ms", pingMs))
			end
			watermarkText.Text = table.concat(parts, " | ")
			watermarkBtn.Size = UDim2.new(0, math.max(120, #watermarkText.Text * 7.6 + 18), 0, 28)
		end
	end

	if Config.GS_CrosshairIndicators then
		local activeFlags = {}
		if Config.GS_DoubleTap then table.insert(activeFlags, "DT") end
		if Config.NM_Enabled then table.insert(activeFlags, "NM") end
		if Config.BaimEnabled then table.insert(activeFlags, "BAIM") end
		if Config.ResolverEnabled then table.insert(activeFlags, "RES") end
		if Config.AntiAimEnabled then
			local aaStr = aaManualSide and ("AA:" .. string.upper(aaManualSide)) or "AA"
			table.insert(activeFlags, aaStr)
		end
		if noclipActive then table.insert(activeFlags, "NOCLIP") end
		if Config.GS_PeekAssist and peekSavedCFrame then table.insert(activeFlags, "PEEK") end
		crosshairIndicatorsLabel.Text = table.concat(activeFlags, "\n")
	end

	if Config.GS_NightMode then
		Lighting.ClockTime = 0
		Lighting.Brightness = Config.GS_NightBrightness
	elseif Config.World_CustomTime then
		Lighting.ClockTime = Config.World_TimeOfDay
	end

	if Config.World_Fullbright then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.Brightness = 2.5
	end

	if Config.World_NoFog then
		Lighting.FogEnd = 100000
	end

	if Config.Player_RainbowSelf and character then
		local hl = VisualObjects["PlayerRainbowHL"]
		if not hl or not hl.Parent then
			hl = Instance.new("Highlight")
			hl.Name = "PlayerRainbowHL"
			hl.FillTransparency = 0.5
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = character
			VisualObjects["PlayerRainbowHL"] = hl
		end
		hl.Adornee = character
		local hue = (now * 0.25) % 1
		local rgb = Color3.fromHSV(hue, 0.85, 1)
		hl.FillColor = rgb
		hl.OutlineColor = rgb
	end

	local cam = Workspace.CurrentCamera
	local mousePos = UserInputService:GetMouseLocation()

	if Config.WhiteDotCrosshair then
		UserInputService.MouseIconEnabled = false
		whiteDotCrosshair.Visible = true
		whiteDotCrosshair.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
	else
		whiteDotCrosshair.Visible = false
		UserInputService.MouseIconEnabled = true
	end

	silentFovCircle.Visible = Config.SilentAim and Config.ShowSilentFOV
	if silentFovCircle.Visible then
		silentFovCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
		silentFovCircle.Size = UDim2.new(0, Config.SilentAimFOV * 2, 0, Config.SilentAimFOV * 2)
	end

	aimbotFovCircle.Visible = Config.AimbotEnabled and Config.ShowAimbotFOV
	if aimbotFovCircle.Visible then
		aimbotFovCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
		aimbotFovCircle.Size = UDim2.new(0, Config.AimbotFOV * 2, 0, Config.AimbotFOV * 2)
	end

	if Config.AimbotEnabled and cam and character and humanoid and humanoid.Health > 0 then
		local rmbHeld = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		if (not Config.AimbotRequireRMB) or rmbHeld then
			local _, predictedPos = findBestAimTarget(
				Config.AimbotFOV,
				Config.AimbotMaxDistance,
				Config.AimbotTargetHead,
				Config.AimbotWallCheck,
				Config.AimbotPrediction
			)
			if predictedPos then
				local targetCFrame = CFrame.lookAt(cam.CFrame.Position, predictedPos)
				local smooth = math.max(Config.AimbotSmoothness, 1.0)
				if smooth <= 1.05 then
					cam.CFrame = targetCFrame
				else
					local alpha = math.clamp(dt * (60 / smooth) * 0.45, 0.02, 1.0)
					if Config.AimbotSmoothCurve == "Exponential" then
						alpha = alpha * alpha
					end
					cam.CFrame = cam.CFrame:Lerp(targetCFrame, math.max(alpha, 0.015))
				end
			end
		end
	end

	if Config.NM_Enabled and cam and character and rootPart and humanoid and humanoid.Health > 0 then
		local targets = findNeverMissTargets(1)
		local primary = targets[1]
		if primary then
			if Config.NM_AimAssistMagnet then
				local targetCF = CFrame.lookAt(cam.CFrame.Position, primary.part.Position)
				cam.CFrame = cam.CFrame:Lerp(targetCF, math.clamp(dt * 12 * Config.NM_MagnetStrength, 0.01, 0.8))
			end

			if Config.NM_ShowTargetBeam then
				local dist = (primary.part.Position - rootPart.Position).Magnitude
				local beam = getOrCreatePart("NMTargetBeam", Vector3.new(0.08, 0.08, dist), nil, currentAccentColor)
				beam.Size = Vector3.new(0.08, 0.08, dist)
				beam.CFrame = CFrame.lookAt(rootPart.Position, primary.part.Position) * CFrame.new(0, 0, -dist * 0.5)
			else
				destroyVisual("NMTargetBeam")
			end

			if Config.NM_HighlightTarget then
				local hl = VisualObjects["NMTargetHighlight"]
				if not hl or not hl.Parent then
					hl = Instance.new("Highlight")
					hl.Name = "NMTargetHighlight"
					hl.FillColor = currentAccentColor
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.FillTransparency = 0.45
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Parent = Workspace
					VisualObjects["NMTargetHighlight"] = hl
				end
				hl.Adornee = primary.model
				hl.Enabled = true
			else
				destroyVisual("NMTargetHighlight")
			end
		else
			destroyVisual("NMTargetBeam")
			destroyVisual("NMTargetHighlight")
		end
	else
		destroyVisual("NMTargetBeam")
		destroyVisual("NMTargetHighlight")
	end

	if Config.Rage_ResolverLines then
		local activeModels = {}
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj ~= character then
				local hum = obj:FindFirstChildOfClass("Humanoid")
				local head = obj:FindFirstChild("Head")
				if hum and head and hum.Health > 0 then
					activeModels[obj] = true
					local line = ResolverLinesPool[obj]
					if not line or not line.Parent then
						line = Instance.new("Part")
						line.Anchored = true
						line.CanCollide = false
						line.CanQuery = false
						line.Material = Enum.Material.Neon
						line.Color = Color3.fromRGB(255, 140, 40)
						line.Parent = Workspace
						ResolverLinesPool[obj] = line
					end
					local len = 14
					line.Size = Vector3.new(0.08, 0.08, len)
					line.CFrame = head.CFrame * CFrame.new(0, 0, -len * 0.5)
				end
			end
		end
		for m, line in pairs(ResolverLinesPool) do
			if not activeModels[m] then
				if line then line:Destroy() end
				ResolverLinesPool[m] = nil
			end
		end
	end

	updateAntiAimAndThirdPerson(dt)
	updateRadarHUD()
	updateESP()

	if hitmarkerAlpha > 0 then
		hitmarkerAlpha = math.max(hitmarkerAlpha - dt * 4.5, 0)
		hitmarkerFrame.Visible = hitmarkerAlpha > 0
		for _, child in ipairs(hitmarkerFrame:GetChildren()) do
			if child:IsA("Frame") then
				child.BackgroundTransparency = 1 - hitmarkerAlpha
			end
		end
	else
		hitmarkerFrame.Visible = false
	end
end))

----------------------------------------------------------------------
-- ОСНОВНОЙ ФИЗИЧЕСКИЙ ЦИКЛ (PRE-SIMULATION)
----------------------------------------------------------------------
table.insert(Connections, RunService.PreSimulation:Connect(function(dt)
	if isUnloaded then return end

	if Config.World_CustomGravity then
		Workspace.Gravity = Config.World_GravityValue
	end

	if Config.GS_HitboxExpander then
		local sz = Config.GS_HitboxSize
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj ~= character then
				local hum = obj:FindFirstChildOfClass("Humanoid")
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				if hum and hrp and hum.Health > 0 then
					if not ExpandedHitboxes[hrp] then
						ExpandedHitboxes[hrp] = {
							size = hrp.Size,
							transparency = hrp.Transparency,
							material = hrp.Material
						}
					end
					hrp.Size = Vector3.new(sz, sz, sz)
					hrp.Transparency = Config.GS_HitboxTransparency
					hrp.Material = Enum.Material.Neon
					hrp.CanCollide = false
				end
			end
		end
	end

	if not Config.NM_BulletTimeFreeze then
		for i = #ActiveProjectiles, 1, -1 do
			local proj = ActiveProjectiles[i]
			local stepDist = proj.speed * dt

			if proj.homingPart and proj.homingPart.Parent then
				local targetPos = proj.homingPart.Position
				local toTarget = targetPos - proj.pos
				local distToTarget = toTarget.Magnitude

				if distToTarget <= stepDist or distToTarget < 1.2 then
					if proj.part then proj.part:Destroy() end
					table.remove(ActiveProjectiles, i)
					if proj.onImpact then
						proj.onImpact(targetPos)
					end
				else
					local desiredDir = toTarget.Unit
					proj.dir = proj.dir:Lerp(desiredDir, math.clamp(Config.NM_HomingTurnStrength, 0.1, 1.0)).Unit
					proj.pos += proj.dir * stepDist
					if proj.part and proj.part.Parent then
						proj.part.CFrame = CFrame.lookAt(proj.pos, proj.pos + proj.dir)
					end
				end
			else
				if Config.BulletGravityDrop > 0 then
					proj.dir = (proj.dir + Vector3.new(0, -(Config.BulletGravityDrop / 1000) * dt * 15, 0)).Unit
				end

				if stepDist >= proj.remaining then
					local impactPos = proj.pos + proj.dir * proj.remaining
					if proj.part then proj.part:Destroy() end
					table.remove(ActiveProjectiles, i)
					if proj.onImpact then
						proj.onImpact(impactPos)
					end
				else
					proj.pos += proj.dir * stepDist
					proj.remaining -= stepDist
					if proj.part and proj.part.Parent then
						proj.part.CFrame = CFrame.lookAt(proj.pos, proj.pos + proj.dir)
					end
				end
			end
		end
	end

	if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
		return
	end

	if noclipActive then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	if Config.Player_AutoRegen and humanoid.Health < humanoid.MaxHealth then
		humanoid.Health = math.min(humanoid.Health + 25 * dt, humanoid.MaxHealth)
	end

	local mult = getSpeedMult()

	if Config.Misc_NeonRingAura then
		local r = Config.Misc_RingRadius
		local ring = getOrCreatePart("MiscNeonRing", Vector3.new(0.15, r * 2, r * 2), Enum.PartType.Cylinder, currentAccentColor)
		ring.Size = Vector3.new(0.12, r * 2, r * 2)
		ring.Transparency = 0.45
		ring.CFrame = CFrame.new(rootPart.Position - Vector3.new(0, getFloorDistance() - 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
	else
		destroyVisual("MiscNeonRing")
	end

	if Config.Misc_AutoJumpHeight then
		humanoid.UseJumpPower = false
		humanoid.JumpHeight = Config.Misc_JumpHeightVal
	end

	if Config.AutoSprint then
		humanoid.WalkSpeed = Config.AutoSprintSpeed * mult
	end

	if Config.AntiAimEnabled and Config.AA_SlowWalk and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		humanoid.WalkSpeed = Config.AA_SlowWalkSpeed
	end

	-- RAGE MECHANICS
	if Config.Rage_OrbitTarget then
		local targets = findNeverMissTargets(1)
		if #targets > 0 then
			local targetHrp = targets[1].model:FindFirstChild("HumanoidRootPart")
			if targetHrp then
				orbitAngle += dt * Config.Rage_OrbitSpeed
				local offset = Vector3.new(
					math.cos(orbitAngle) * Config.Rage_OrbitRadius,
					0,
					math.sin(orbitAngle) * Config.Rage_OrbitRadius
				)
				local desiredPos = targetHrp.Position + offset
				rootPart.CFrame = CFrame.lookAt(desiredPos, targetHrp.Position)
				rootPart.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end

	if Config.Rage_BlitzTeleport and (os.clock() - lastBlitzTime >= Config.Rage_BlitzDelay) then
		local allTargets = findNeverMissTargets(20)
		if #allTargets > 0 then
			lastBlitzTime = os.clock()
			blitzIndex = (blitzIndex % #allTargets) + 1
			local targetModel = allTargets[blitzIndex].model
			local targetHrp = targetModel and targetModel:FindFirstChild("HumanoidRootPart")
			if targetHrp then
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3.8)
			end
		end
	end

	if Config.Rage_GravityVortex then
		local vortexPoint = rootPart.Position + rootPart.CFrame.LookVector * Config.Rage_VortexDistance
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj ~= character then
				local hum = obj:FindFirstChildOfClass("Humanoid")
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				if hum and hrp and hum.Health > 0 then
					local toVortex = vortexPoint - hrp.Position
					if toVortex.Magnitude > 2 then
						hrp.AssemblyLinearVelocity = toVortex.Unit * 55
					else
						hrp.AssemblyLinearVelocity = Vector3.zero
					end
				end
			end
		end
	end

	if Config.Rage_AutoDodge and (os.clock() - lastDodgeTime >= 0.45) then
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and obj ~= character then
				local hum = obj:FindFirstChildOfClass("Humanoid")
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				if hum and hrp and hum.Health > 0 then
					local dist = (hrp.Position - rootPart.Position).Magnitude
					if dist < 11 then
						lastDodgeTime = os.clock()
						local side = (math.random(1, 2) == 1) and rootPart.CFrame.RightVector or -rootPart.CFrame.RightVector
						rootPart.AssemblyLinearVelocity = Vector3.new(side.X * Config.Rage_DodgePower, 18, side.Z * Config.Rage_DodgePower)
						break
					end
				end
			end
		end
	end

	-- NEVERMISS & WEAPON TRIGGERS
	if Config.NM_Enabled and Config.NM_AutoShoot and (os.clock() - lastNMAutoShootTime >= Config.NM_AutoShootDelay) then
		local equippedTool = character:FindFirstChildOfClass("Tool")
		if equippedTool then
			local targets = findNeverMissTargets(1)
			if #targets > 0 then
				lastNMAutoShootTime = os.clock()
				equippedTool:Activate()
				task.defer(function()
					if equippedTool then equippedTool:Deactivate() end
				end)
			end
		end
	end

	if Config.NM_Enabled and Config.NM_KillAura and (os.clock() - lastKillAuraTime >= 0.12) then
		lastKillAuraTime = os.clock()
		for _, model in ipairs(Workspace:GetDescendants()) do
			if model:IsA("Model") and model ~= character then
				local hum = model:FindFirstChildOfClass("Humanoid")
				local hrp = model:FindFirstChild("HumanoidRootPart")
				if hum and hrp and hum.Health > 0 then
					local toEnemy = hrp.Position - rootPart.Position
					if toEnemy.Magnitude <= Config.NM_KillAuraRange then
						local forceBody = shouldForceBaim(model, hum)
						local hitPart = forceBody and hrp or (model:FindFirstChild("Head") or hrp)
						applyDamageToTarget(hum, 40, hitPart, toEnemy.Unit)
					end
				end
			end
		end
	end

	if Config.SilentAim and Config.SilentAutoFire and (os.clock() - lastSilentFireTime >= Config.SilentAutoFireDelay) then
		local equippedTool = character:FindFirstChildOfClass("Tool")
		if equippedTool then
			local targetPart = findBestAimTarget(
				Config.SilentAimFOV,
				800,
				Config.SilentTargetHead,
				Config.SilentWallCheck,
				Config.SilentPrediction
			)
			if targetPart then
				lastSilentFireTime = os.clock()
				equippedTool:Activate()
				task.defer(function()
					if equippedTool then equippedTool:Deactivate() end
				end)
			end
		end
	end

	if Config.Triggerbot and (os.clock() - lastTriggerTime >= Config.TriggerDelay) then
		local equippedTool = character:FindFirstChildOfClass("Tool")
		if equippedTool then
			local cam = Workspace.CurrentCamera
			if cam then
				local hit = castRay(cam.CFrame.Position, cam.CFrame.LookVector * 600)
				if hit and hit.Instance then
					local targetModel = hit.Instance:FindFirstAncestorOfClass("Model")
					local targetHum = targetModel and targetModel:FindFirstChildOfClass("Humanoid")
					if targetHum and targetHum.Health > 0 then
						lastTriggerTime = os.clock()
						equippedTool:Activate()
						task.defer(function()
							if equippedTool then equippedTool:Deactivate() end
						end)
					end
				end
			end
		end
	end

	local vel = rootPart.AssemblyLinearVelocity
	local flatVel = Vector3.new(vel.X, 0, vel.Z)
	local speed = flatVel.Magnitude

	local floorDist = getFloorDistance()
	local groundRay = castRay(rootPart.Position, Vector3.new(0, -(floorDist + 0.35), 0))
	local isGrounded = (humanoid.FloorMaterial ~= Enum.Material.Air) or (groundRay ~= nil and vel.Y <= 1)

	if isGrounded then
		currentAirTime = 0
	else
		currentAirTime += dt
	end

	if speed > peakSpeed then
		peakSpeed = speed
		peakSpeedLabel.Text = string.format("Peak Speed: %.1f u/s", peakSpeed)
	end
	airTimeLabel.Text = string.format("Current AirTime: %.2f s", currentAirTime)

	local nmTag = Config.NM_Enabled and " | NM:ON" or ""
	local aaTag = Config.AntiAimEnabled and (" | AA:" .. (aaManualSide or Config.AA_YawModifier)) or ""
	statusBox.Text = string.format("%s | Speed: %.1f | %.2fx%s%s", SCRIPT_NAME, speed, mult, aaTag, nmTag)

	local spaceHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)
	local crouchHeld = UserInputService:IsKeyDown(Enum.KeyCode.C) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
	local wHeld = UserInputService:IsKeyDown(Enum.KeyCode.W)
	local moveDir = humanoid.MoveDirection

	if Config.NoJumpCooldown and spaceHeld and isGrounded then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	-- STANDART MECHANICS
	if (Config.BunnyHop or Config.CrouchJump) and spaceHeld and isGrounded then
		local jumpVel = getJumpVelocity()
		if Config.CrouchJump and crouchHeld then
			jumpVel *= Config.CrouchJumpBonus
		end

		if Config.BunnyHop then
			local targetDir = moveDir.Magnitude > 0 and moveDir.Unit or (speed > 1 and flatVel.Unit or rootPart.CFrame.LookVector)
			local preserved = speed * Config.BhopKeepMomentum
			local maxBhop = Config.BhopMaxSpeed * mult
			local boost = Config.BhopBoost * mult
			local newSpeed = math.min(math.max(preserved, humanoid.WalkSpeed * mult) + boost, maxBhop)

			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			rootPart.AssemblyLinearVelocity = Vector3.new(targetDir.X * newSpeed, jumpVel, targetDir.Z * newSpeed)
			isGrounded = false
		elseif Config.CrouchJump and crouchHeld then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, jumpVel, vel.Z)
			isGrounded = false
		end
	end

	if Config.AirStrafe and not isGrounded and moveDir.Magnitude > 0 then
		local wishDir = moveDir.Unit
		local maxStrafe = Config.StrafeMaxSpeed * mult
		local currentProj = flatVel:Dot(wishDir)
		local addSpeed = maxStrafe - currentProj

		if addSpeed > 0 then
			local accel = math.min(Config.StrafeAccel * Config.StrafeAirControl * mult * dt * 60, addSpeed)
			local newFlat = flatVel + (wishDir * accel)
			if newFlat.Magnitude > maxStrafe then
				newFlat = newFlat.Unit * maxStrafe
			end
			rootPart.AssemblyLinearVelocity = Vector3.new(newFlat.X, vel.Y, newFlat.Z)
			flatVel = newFlat
			speed = flatVel.Magnitude
		end
	end

	if Config.EdgeJump and wasGrounded and not isGrounded and vel.Y <= 0 and not spaceHeld then
		local deepCheck = castRay(rootPart.Position, Vector3.new(0, -(floorDist + Config.EdgeJumpOffset + 1.5), 0))
		if not deepCheck then
			local jumpVel = getJumpVelocity()
			local boostedFlat = flatVel * (Config.EdgeJumpBoost * mult)
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			rootPart.AssemblyLinearVelocity = Vector3.new(boostedFlat.X, jumpVel, boostedFlat.Z)
		end
	end

	if Config.EdgeBug and crouchHeld and not isGrounded and vel.Y < -Config.EdgeBugMinFall and (os.clock() - lastEdgeBugTime > 0.25) then
		local nearFloor = castRay(rootPart.Position, Vector3.new(0, -(floorDist + 1.2), 0))
		if nearFloor then
			local forward = speed > 1 and flatVel.Unit or rootPart.CFrame.LookVector
			local beyondEdge = castRay(rootPart.Position + forward * 1.3, Vector3.new(0, -(floorDist + 2.0), 0))
			if not beyondEdge then
				lastEdgeBugTime = os.clock()
				local keepSpeed = math.max(speed, 20) * Config.EdgeBugSpeedMult * mult
				rootPart.AssemblyLinearVelocity = Vector3.new(forward.X * keepSpeed, Config.EdgeBugBounce, forward.Z * keepSpeed)
			end
		end
	end

	if Config.JumpBug and spaceHeld and not isGrounded and vel.Y < -Config.JumpBugMinFall then
		local imminentFloor = castRay(rootPart.Position, Vector3.new(0, -(floorDist + 0.9), 0))
		if imminentFloor then
			local jumpVel = getJumpVelocity() * Config.JumpBugMult
			local dir = moveDir.Magnitude > 0 and moveDir.Unit or (speed > 1 and flatVel.Unit or rootPart.CFrame.LookVector)
			local preservedSpeed = (math.max(speed, humanoid.WalkSpeed) + Config.JumpBugSpeedBonus) * mult

			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			rootPart.AssemblyLinearVelocity = Vector3.new(dir.X * preservedSpeed, jumpVel, dir.Z * preservedSpeed)
		end
	end

	if groundRay and groundRay.Normal.Y < 0.95 and groundRay.Normal.Y > 0.25 then
		local slopeNormal = groundRay.Normal
		if Config.SurfGlide then
			local slopeDown = Vector3.new(slopeNormal.X, 0, slopeNormal.Z).Unit
			local surfAccelVec = slopeDown * (Config.SurfAccel * mult * dt)
			local newFlat = flatVel + surfAccelVec
			local maxSurf = Config.SurfMaxSpeed * mult
			if newFlat.Magnitude > maxSurf then
				newFlat = newFlat.Unit * maxSurf
			end
			rootPart.AssemblyLinearVelocity = Vector3.new(newFlat.X, vel.Y, newFlat.Z)
		end

		if Config.RampLaunch and speed > 22 and vel.Y > 2 then
			local launchY = vel.Y * Config.RampLaunchMult
			rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, math.min(launchY, 90), vel.Z)
		end
	end

	if Config.LedgeVault and not isGrounded and wHeld and (os.clock() - lastVaultTime > 0.4) then
		local look = rootPart.CFrame.LookVector
		local chestRay = castRay(rootPart.Position + Vector3.new(0, 0.5, 0), look * 2.2)
		local headRay = castRay(rootPart.Position + Vector3.new(0, 2.6, 0), look * 2.4)
		if chestRay and not headRay then
			lastVaultTime = os.clock()
			rootPart.AssemblyLinearVelocity = Vector3.new(
				look.X * (Config.VaultForwardPush * mult),
				Config.VaultUpPower,
				look.Z * (Config.VaultForwardPush * mult)
			)
		end
	end

	-- VISUALS & TELEMETRY
	local cam = Workspace.CurrentCamera
	if cam then
		if Config.DynamicFOV then
			local speedRatio = math.clamp((speed - 16) / 80, 0, 1)
			local targetFOV = Config.BaseFOV + (Config.MaxBonusFOV * speedRatio)
			cam.FieldOfView += (targetFOV - cam.FieldOfView) * math.min(dt * 10, 1)
		else
			cam.FieldOfView = Config.BaseFOV
		end
	end

	local trailObj = VisualObjects["TrailObj"]
	if trailObj then
		trailObj.Enabled = Config.SpeedTrail
		if Config.SpeedTrail then
			local alpha = math.clamp((speed - 16) / 70, 0, 1)
			local trailColor = Color3.fromRGB(60, 160, 255):Lerp(Color3.fromRGB(255, 200, 50), alpha)
			trailObj.Color = ColorSequence.new(trailColor)
		end
	end

	if Config.VelocityVector3D and vel.Magnitude > 1.5 then
		local len = math.clamp(vel.Magnitude * 0.16, 1.5, 14)
		local arrow = getOrCreatePart("VelArrow", Vector3.new(0.14, 0.14, len), nil, currentAccentColor)
		local startPos = rootPart.Position
		local endPos = startPos + vel.Unit * len
		arrow.Size = Vector3.new(0.14, 0.14, len)
		arrow.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -len * 0.5)
	else
		destroyVisual("VelArrow")
	end

	if Config.LandingPredictor and not isGrounded then
		local hitPos = predictLandingPosition(rootPart.Position, vel)
		if hitPos then
			local marker = getOrCreatePart("LandMarker", Vector3.new(0.3, 3.2, 3.2), Enum.PartType.Cylinder, Color3.fromRGB(255, 95, 95))
			marker.CFrame = CFrame.new(hitPos + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90))
		else
			destroyVisual("LandMarker")
		end
	else
		destroyVisual("LandMarker")
	end

	wasGrounded = isGrounded
end))
