----------------------script start-------------------------------

--some functions--

function Notify(tt, tx)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = tt,
        Text = tx,
        Duration = 4
    })
end
function getcurrentgun(plr)
    local char = plr.Character
    if not char then return nil, nil end
    local invchar = game.ReplicatedStorage.Players:FindFirstChild(game.Players.LocalPlayer.Name).Inventory
    if not invchar then return nil, nil end

    local gun = nil
    local gunname = nil
    local guninv = nil

    for _, desc in ipairs(char:GetDescendants()) do
        if desc:IsA("Model") and desc:FindFirstChild("ItemRoot") and desc:FindFirstChild("Attachments") then
            gun = desc
            gunname = desc.Name
            guninv = invchar:FindFirstChild(gunname)
        end
    end

    return gunname, gun, guninv
end
function getcurrentammo(gun)
    if not gun then return nil end
    local loadedfold = gun:FindFirstChild("LoadedAmmo", true)
    if not loadedfold then return nil end
    local firstammo = loadedfold:FindFirstChild("1")
    if not firstammo then return nil end

    local ammoname = firstammo:GetAttribute("AmmoType")
    local ammo = game.ReplicatedStorage.AmmoTypes:FindFirstChild(ammoname)
    if not ammo then return nil end

    return ammo
end

--startup--

print("Loading start")

if _G.ardour then
    Notify("Ardour", "Script is already loaded")
    return
end

local exec = identifyexecutor()
if string.match(exec, "Synapse") == nil and string.match(exec, "Macsploit") == nil and string.match(exec, "Seliware") == nil and string.match(exec, "Nihon") == nil and string.match(exec, "AWP") == nil then

    local reqtest = pcall(function()
        require(game.ReplicatedStorage.Modules.FPS)
    end)
    local filetest = pcall(function()
        isfile("Ardour1runCheck.mp3")
    end)
    local connecttest = pcall(function()
        getconnections(game.ChildAdded)
    end)
    if reqtest == true and filetest == true and connecttest == true then else
        Notify("Ardour", "Sorry, your executor cant run this script")
        return
    end

    local libtest = pcall(function()
        local drawing1 = Drawing.new("Square")
        drawing1.Visible = false
        drawing1:Destroy()
    end)
    if libtest == false then
        Notify("Ardour", "Wait while we install drawing lib for you")
        local lib = game:HttpGet("https://drive.google.com/uc?export=download&id=1xDwhcJeZMMaGsOhRTM1oZw0TgklkDIwP")
        loadstring(lib)()
        Notify("Ardour", "Drawing lib installed!, Script is loading")
    else
        Notify("Ardour", "Loading. Using " .. exec .. " (Half supported)")
    end

    Notify("WARNING", "We do not guarantee that the script will work on your injector!")
else
    Notify("Ardour", "Loading. Using " .. exec .. " (Full supported)")
end

if game.Players.LocalPlayer.Character == nil or not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
    Notify("Ardour", "It looks like the game has not loaded yet, the script is waiting for the game to load")

    while game.Players.LocalPlayer.Character == nil or not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") do
        wait(0.2)
    end
end
wait(0.5)

print("loading variables ")

--variables--

local wcamera = workspace.CurrentCamera
local localplayer = game.Players.LocalPlayer
local runs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local tweens = game:GetService("TweenService")
local scriptloading = true
local ACBYPASS_SYNC = false
local keybindlist = false
local keylist_gui 
local keylist_items = {}
local a1table

local configname = nil
allvars = {}

allvars.aimbool = false
allvars.aimselftrack = false
local fakemodels = {}
allvars.aimbots = false
allvars.aimvischeck = false
allvars.aimdistcheck = false
allvars.aimbang = true
allvars.aimtrigger = false
local aiminfrange = false
local aimtarget = nil
local aimtargetpart = nil
allvars.showfov = false
allvars.aimfovcolor = Color3.fromRGB(255,255,255)
allvars.showname = false
allvars.shotsleft = false
allvars.aimdynamicfov = false
allvars.aimpart = "Head"
allvars.aimtype = "Instant Hit"
allvars.aimfov = 150
local aimsnapline = Drawing.new("Line") 
allvars.snaplinebool = false
allvars.snaplinethick = 1
allvars.snaplinecolor = Color3.fromRGB(255,255,255)
allvars.aimdistance = 800 -- meters
allvars.aimchance = 100
allvars.aimfakewait = false
local aimfovcircle = Drawing.new("Circle")
local aimtargetname = Drawing.new("Text")
local aimtargetshots = Drawing.new("Text")
local aimogfunc = require(game.ReplicatedStorage.Modules.FPS.Bullet).CreateBullet
local aimmodfunc -- will change later in script
local aimignoreparts = {}
for i,v in ipairs(workspace:GetDescendants()) do
    if v:GetAttribute("PassThrough") then
        table.insert(aimignoreparts, v)
    end
end

local selftrack_data = {}
local selftrack_update = 0

allvars.hitmarkbool = false
allvars.hitmarkcolor = Color3.fromRGB(255,255,255)
allvars.hitmarkfade = 2
allvars.hitsoundbool = false
allvars.hitsoundhead = "Ding"
allvars.hitsoundbody = "Blackout"
local hitsoundlib = {
    ["TF2"]       = "rbxassetid://8255306220",
    ["Gamesense"] = "rbxassetid://4817809188",
    ["Rust"]      = "rbxassetid://1255040462",
    ["Neverlose"] = "rbxassetid://8726881116",
    ["Bubble"]    = "rbxassetid://198598793",
    ["Quake"]     = "rbxassetid://1455817260",
    ["Among-Us"]  = "rbxassetid://7227567562",
    ["Ding"]      = "rbxassetid://2868331684",
    ["Minecraft"] = "rbxassetid://6361963422",
    ["Blackout"]  = "rbxassetid://3748776946",
    ["Osu!"]      = "rbxassetid://7151989073",
}
local hitsoundlibUI = {}
for i,v in hitsoundlib do
    hitsoundlibUI[v] = i
end

local skychangerbool = false
local skyboxtable = {
    ["Standard"] = {
        SkyboxBk = "rbxassetid://0",  
        SkyboxDn = "rbxassetid://0",
        SkyboxFt = "rbxassetid://0",
        SkyboxLf = "rbxassetid://0",
        SkyboxRt = "rbxassetid://0",
        SkyboxUp = "rbxassetid://0"
    },
    ["Among Us"] = {
        SkyboxBk = "rbxassetid://5752463190",
        SkyboxDn = "rbxassetid://5752463190",
        SkyboxFt = "rbxassetid://5752463190",
        SkyboxLf = "rbxassetid://5752463190",
        SkyboxRt = "rbxassetid://5752463190",
        SkyboxUp = "rbxassetid://5752463190"
    },
    ["Spongebob"] = {
        SkyboxBk = "rbxassetid://277099484",
        SkyboxDn = "rbxassetid://277099500",
        SkyboxFt = "rbxassetid://277099554",
        SkyboxLf = "rbxassetid://277099531",
        SkyboxRt = "rbxassetid://277099589",
        SkyboxUp = "rbxassetid://277101591"
    },
    ["Deep Space"] = {
        SkyboxBk = "rbxassetid://159248188",
        SkyboxDn = "rbxassetid://159248183",
        SkyboxFt = "rbxassetid://159248187",
        SkyboxLf = "rbxassetid://159248173",
        SkyboxRt = "rbxassetid://159248192",
        SkyboxUp = "rbxassetid://159248176"
    },
    ["Clouded Sky"] = {
        SkyboxBk = "rbxassetid://252760981",
        SkyboxDn = "rbxassetid://252763035",
        SkyboxFt = "rbxassetid://252761439",
        SkyboxLf = "rbxassetid://252760980",
        SkyboxRt = "rbxassetid://252760986",
        SkyboxUp = "rbxassetid://252762652"
    },
}

allvars.rapidfire = false
allvars.crapidfire = false
allvars.crapidfirenum = 0.001
allvars.unlockmodes = false
allvars.multitaps = 1
local instrelOGfunc = require(game.ReplicatedStorage.Modules.FPS).reload
local instrelMODfunc -- changed later
allvars.instaequip = false
allvars.instareload = false
allvars.noswaybool = false

allvars.aimFRIENDLIST = {}
allvars.friendlistmode = "Blacklist"
allvars.friendlistbots = false

allvars.esptextcolor = Color3.fromRGB(255,255,255)
local esptable = {}
--[[ esptable template
    drawingobj = {
        primary = instance
        type = string --(highlight, name, hp, hotbar, distance, skelet, box)
        otype = string --(plr, bot, dead, extract, loot)
    }      
]] 
allvars.espbool = false
allvars.espname = false
allvars.esphp = false
allvars.espdistance = false
allvars.espdistmode = "Meters"
allvars.espbots = false
allvars.esphigh = false
allvars.espdead = false
allvars.esphotbar = false
allvars.esploot = false
allvars.espexit = false
allvars.esptextline = false
allvars.esprenderdist = 1000 -- meters
allvars.espchamsfill = 0.5
allvars.espchamsline = 0
allvars.esptextsize = 14
allvars.espboxcolor = Color3.fromRGB(255,255,255)
allvars.espfillcolor = Color3.fromRGB(255,0,0)
allvars.esplinecolor = Color3.fromRGB(255,255,255)

allvars.invcheck = false
local invchecktext = Drawing.new("Text")

allvars.tracbool = false
allvars.tracwait = 2
allvars.traccolor = Color3.fromRGB(255,255,255)
allvars.tractexture = nil
local tractextures = {
    ["None"] = nil,
    ["Glow"] = "http://www.roblox.com/asset/?id=78260707920108",
    ["Lighting"] = "http://www.roblox.com/asset/?id=131326755401058",
}

allvars.crossbool = false
allvars.crosscolor = Color3.fromRGB(255,255,255)
local crosssizeog = UDim2.new(0.017, 0, 0.03, 0)
allvars.crosssizek = 2
allvars.crossrot = 0
allvars.crossimg = "rbxassetid://15574540229"
local crossgui = Instance.new("ScreenGui", localplayer.PlayerGui)
crossgui.ClipToDeviceSafeArea = false
crossgui.ResetOnSpawn = false
crossgui.ScreenInsets = 0
local crosshair = Instance.new("ImageLabel", crossgui)
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshair.Size = UDim2.new(crosssizeog.X.Scale * allvars.crosssizek, 0, crosssizeog.Y.Scale * allvars.crosssizek, 0)
crosshair.Image = allvars.crossimg
crosshair.ImageColor3 = allvars.crosscolor
crosshair.BackgroundTransparency = 1
crosshair.Visible = false

allvars.camthirdp = false
allvars.camthirdpX = 2
allvars.camthirdpY = 2
allvars.camthirdpZ = 5
allvars.editzoom = false
allvars.basefov = 120
allvars.zoomfov = 5
allvars.antimaskbool = false
allvars.antiflashbool = false
local camzoomfunctionOG = require(game.ReplicatedStorage.Modules.CameraSystem).SetZoomTarget
local camzoomfunction --changed later

local viewmod_materials = {
    ["Forcefield"] = Enum.Material.ForceField,
    ["Neon"] = Enum.Material.Neon,
    ["Plastic"] = Enum.Material.SmoothPlastic
}
allvars.viewmodbool = false
allvars.viewmodhandmat = Enum.Material.Plastic
allvars.viewmodgunmat = Enum.Material.Plastic
allvars.viewmodhandcolor = Color3.fromRGB(255,255,255)
allvars.viewmodguncolor = Color3.fromRGB(255,255,255)
allvars.viewmodoffset = false
allvars.viewmodX = -2
allvars.viewmodY = -2
allvars.viewmodZ = 0

local scbool = false
local scgui = nil --later
local scselected = nil

allvars.doublejump = false
local candbjump = false
local dbjumplast = 0
local dbjumpdelay = 0.2

local desynctable = {}
local desyncvis = nil
allvars.desyncbool = false
allvars.desyncPos = false
allvars.desynXp = 0
allvars.desynYp = 0
allvars.desynZp = 0
allvars.desyncOr = false
allvars.desynXo = 0
allvars.desynYo = 0
allvars.desynZo = 0

allvars.upanglebool = false
allvars.upanglenum = 0
allvars.speedbool = false
allvars.speedboost = 1.2
allvars.nojumpcd = false
allvars.nofall = false
allvars.instafall = false
allvars.instalean = false
allvars.changerbool = false
allvars.changergrav = 95
allvars.changerspeed = 20
allvars.changerheight = 2
allvars.changerjump = 3
local charsemifly = false
allvars.charsemiflydist = 6
allvars.charsemiflyspeed = 30
local semifly_bodyvel = nil
local semifly_pos = CFrame.new()
local semifly_posconnect = nil
local instantleanOGfunc --changed later
local instantleanMODfunc --changed later



allvars.worldleaves = false
allvars.worldgrass = false
allvars.worldcloud = false
local folcheck = workspace:FindFirstChild("SpawnerZones")
allvars.worldclock = 14
allvars.worldnomines = false
allvars.worldnoweather = false
local waterplatforms = Instance.new("Folder", workspace)
waterplatforms.Name = "ArdourWaterPlatforms"
allvars.worldjesus = false
allvars.worldambient = Color3.fromRGB(255,255,255)
allvars.worldoutdoor = Color3.fromRGB(255,255,255)
allvars.worldexpo = 0
allvars.colorcorrectbool = false
allvars.colorcorrectbright = 0
allvars.colorcorrectcontrast = 0
allvars.colorcorrectsatur = 0
allvars.colorcorrecttint = Color3.fromRGB(255,255,255)

allvars.instantrespawn = false
local espmapactive = false
local handleESPMAP = function() do end end
local espmapmarkers = {}
local detectedmods = {}
local mdetect = false
allvars.detectmods = false

local valcache = {
    ["6B45"] = 16,
    ["AS Val"] = 16,
    ["ATC Key"] = 6,
    ["Airfield Key"] = 6,
    ["Altyn"] = 16,
    ["Altyn Visor"] = 8,
    ["Maska Visor"] = 8,
    ["Attak-5 60L"] = 16,
    ["Bolts"] = 1,
    ["Crane Key"] = 6,
    ["DAGR"] = 12,
    ["Duct Tape"] = 1,
    ["Fast MT"] = 10,
    ["Flare Gun"] = 20,
    ["Fueling Station Key"] = 2,
    ["Garage Key"] = 4,
    ["Hammer"] = 1,
    ["JPC"] = 10,
    ["Lighthouse Key"] = 6,
    ["M4A1"] = 12,
    ["Nails"] = 1,
    ["Nuts"] = 1,
    ["Saiga 12"] = 8,
    ["Super Glue"] = 1,
    ["Village Key"] = 2,
    ["Wrench"] = 1,
    ["SPSh-44"] = 12,
    ["R700"] = 16,
    ["AKMN"] = 12,
    ["Mosin"] = 12,
    ["SVD"] = 12,
    ["7.62x39AP"] = 0.15,
    ["7.62x54AP"] = 0,15,
}
--drawing setup--

aimfovcircle.Visible = false
aimfovcircle.Radius = allvars.aimfov
aimfovcircle.Thickness = 2
aimfovcircle.Filled = false
aimfovcircle.Transparency = 1
aimfovcircle.Color = Color3.fromRGB(255, 255, 255)
aimfovcircle.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
aimtargetname.Text = "None"
aimtargetname.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov + 20) 
aimtargetname.Size = 24
aimtargetname.Color = Color3.fromRGB(255,255,255)
aimtargetname.Visible = false
aimtargetname.Center = true
aimtargetname.Outline = true
aimtargetname.OutlineColor = Color3.new(0, 0, 0)
aimtargetshots.Text = " "
aimtargetshots.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov + 30) 
aimtargetshots.Size = 20
aimtargetshots.Color = Color3.fromRGB(255,255,255)
aimtargetshots.Visible = false
aimtargetshots.Center = true
aimtargetshots.Outline = true
aimtargetshots.OutlineColor = Color3.new(0, 0, 0)
invchecktext.Text = " "
invchecktext.Position = Vector2.new(100, wcamera.ViewportSize.Y / 2)
invchecktext.Size = 18
invchecktext.Color = Color3.fromRGB(255,255,255)
invchecktext.Visible = true
invchecktext.Center = false
invchecktext.Outline = true
invchecktext.OutlineColor = Color3.new(0, 0, 0)
aimsnapline.From = Vector2.new(20, 20)
aimsnapline.To = Vector2.new(50, 50)
aimsnapline.Color = Color3.fromRGB(255,255,255)
aimsnapline.Thickness = 1
aimsnapline.Visible = false

--gui setup--

if _G.ardour then
    Notify("Ardour", "Script is already loaded")
    return
end

print('loading gui library')
--gui library load--
local library = nil
task.spawn(function()
    local newlib = loadstring(game:HttpGet("https://pastebin.com/raw/kzPjQQbs", true))()

    if library ~= nil then 
        newlib.GUI:Destroy()
        return 
    end
    library = newlib

    if game.CoreGui:FindFirstChild("PCR_1") then
        game.CoreGui.PCR_1.Enabled = false
    end
end)
task.wait(2)
while library == nil do
    task.spawn(function()
        local newlib = loadstring(game:HttpGet("https://pastebin.com/raw/kzPjQQbs", true))()

        if library ~= nil then 
            newlib.GUI:Destroy()
            return 
        end
        library = newlib
    
        if game.CoreGui:FindFirstChild("PCR_1") then
            game.CoreGui.PCR_1.Enabled = false
        end
    end)

    task.wait(2)
    if library == nil then
        continue
    end
end
if _G.ardour then
    return
end
_G.ardour = true
game.CoreGui.PCR_1.Enabled = false
do
    local bg = game.CoreGui.PCR_1:FindFirstChild("BG", true)
    if bg then 
        Instance.new("UICorner", bg.Parent).CornerRadius = UDim.new(0.02, 0)
    end
end
library.GUI.ScreenInsets = Enum.ScreenInsets.None
local librarymaingui = library.GUI.MAIN


--keybind list--
print('loading keybind list')
do
    local a, b
    a = Instance.new"Frame"
    a.Name = "Keybinds"
    a.Size = UDim2.new(0.099531, 0, 0.2842593, 0)
    a.BorderColor3 = Color3.fromRGB(0, 0, 0)
    a.Position = UDim2.new(0.0057322, 0, 0.0495185, 0)
    a.BorderSizePixel = 0
    a.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
    a.Visible = false
    b = Instance.new"UICorner"
    b.CornerRadius = UDim.new(0.05, 0)
    b.Parent = a
    b = Instance.new"UIStroke"
    b.ApplyStrokeMode = 1
    b.Thickness = 2.5999999
    b.Color = Color3.fromRGB(91, 133, 197)
    b.Parent = a
    b = Instance.new"Frame"
    b.Name = "Title"
    b.Size = UDim2.new(0.9994792, 0, 0.0781759, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.75
    b.Position = UDim2.new(0, 0, 0, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.Parent = a
    local titleLabel = Instance.new"TextLabel"
    titleLabel.Name = "Label"
    titleLabel.Size = UDim2.new(0.7853403, 0, 0.7083333, 0)
    titleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0.1046575, 0, 0.144544, 0)
    titleLabel.BorderSizePixel = 0
    titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.FontSize = 5
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextSize = 14
    titleLabel.RichText = true
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Text = "Keybinds"
    titleLabel.TextWrapped = true
    titleLabel.TextWrap = true
    titleLabel.Font = 100
    titleLabel.TextScaled = true
    titleLabel.Parent = b
    b = Instance.new"UICorner"
    b.CornerRadius = UDim.new(0.5, 0)
    b.Parent = titleLabel.Parent
    b = Instance.new"Frame"
    b.Name = "Items"
    b.Size = UDim2.new(0.9105204, 0, 0.8794788, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.75
    b.Position = UDim2.new(0.041863, 0, 0.0977199, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.Parent = a
    b = Instance.new"UICorner"
    b.CornerRadius = UDim.new(0.05, 0)
    b.Parent = a.Items
    b = Instance.new"UIStroke"
    b.ApplyStrokeMode = 1
    b.Thickness = 1.8
    b.Color = Color3.fromRGB(54, 54, 54)
    b.Parent = a.Items
    b = Instance.new"UIListLayout"
    b.SortOrder = 2
    b.Wraps = true
    b.HorizontalFlex = 2
    b.ItemLineAlignment = 2
    b.Padding = UDim.new(0.02, 0)
    b.Parent = a.Items
    b = Instance.new"Configuration"
    b.Name = "Templates"
    b.Parent = a
    b = Instance.new"TextLabel"
    b.Name = "Keytemplate"
    b.Size = UDim2.new(0.9080459, 0, 0.08, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0.091954, 0, 0, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.FontSize = 5
    b.TextStrokeTransparency = 0
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "[Insert] Toggle GUI"
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextXAlignment = 0
    b.TextScaled = true
    b.Parent = a.Templates
    a.Parent = library.GUI
    keylist_gui = a
end
local function keylist_removekey(funcname)
    local oldkey = keylist_items[funcname]
    if oldkey == nil then return end
    oldkey:Destroy()
end
local function keylist_addkey(funcname, keyname)
    local newkey = keylist_gui.Templates.Keytemplate:Clone()
    newkey.Name = funcname
    newkey.Text = '['..keyname..'] '..funcname
    newkey.Parent = keylist_gui.Items
    keylist_items[funcname] = newkey
end

print('setting up gui')

library:ChangeWeb("discord.gg/ardour")
library:ChangeGame("Project Delta")

local home = library:AddWindow('Home')
local combat = library:AddWindow('Combat')
local visual = library:AddWindow('Visuals')
local other = library:AddWindow('Other')

local editwatermark
editwatermark = library.GUI.ChildAdded:Connect(function(ch)
    if ch:IsA("Frame") then
        ch.AnchorPoint = Vector2.new(0.5, 0.5)
        ch.Position = UDim2.new(0.5, 0, 0.05, 0)
        Instance.new("UICorner", ch).CornerRadius = UDim.new(0.2, 0)
    end
    editwatermark:Disconnect()
end)
local watermark = library:AddWatermark('Lirp')
watermark.AnchorPoint = Vector2.new(0.5, 0.5)
watermark.Position = UDim2.new(0.5, 0, 0.05, 0)

local mainhome = home:AddSection('Info')
local configui = home:AddSection('Configs')
local aim = combat:AddSection('Aim')
local gunmods = combat:AddSection('Gun Mods')
local tarinfo = combat:AddSection('Target')
local friendman = combat:AddSection('Friend manager')
local wh = visual:AddSection('ESP')
local cross = visual:AddSection('Crosshair')
local tracers = visual:AddSection('Tracers')
local camer = visual:AddSection('Camera')
local viewmod = visual:AddSection('View Model')
local speedh = other:AddSection('Character')
local worldh = other:AddSection('World')
local vmisc = other:AddSection('Misc')

saveconfig = function(cfgname) end
saveconfig = function(cfgname)
    cfgname = tostring(cfgname)
    if cfgname ~= nil then
        allvariables = {"aimbool", "aimselftrack", "aimbots", "aimvischeck", "aimdistcheck", "aimbang", "aimtrigger", "showfov", "aimfovcolor", "aimdynamicfov", "aimpart", "aimtype", "aimfov", "showname", "shotsleft",
            "snaplinebool", "snaplinethick", "snaplinecolor", "aimdistance", "aimchance", "aimfakewait",
            "hitmarkbool", "hitmarkcolor", "hitmarkfade", "hitsoundbool", "hitsoundhead", "hitsoundbody",
            "rapidfire", "crapidfire", "crapidfirenum", "unlockmodes", "multitaps",
            "instaequip", "instareload", "noswaybool",
            "aimFRIENDLIST", "friendlistmode", "friendlistbots",
            "esptextcolor", "espbool", "espname", "esphp", "espdistance", "espdistmode", "espbots", "esphigh", "espdead", "esphotbar", "esploot", "espexit", "esptextline", "esprenderdist", "espchamsfill", "espchamsline", "esptextsize", "espboxcolor", "espfillcolor", "esplinecolor",
            "invcheck",
            "tracbool", "tracwait", "traccolor", "tractexture",
            "crossbool", "crosscolor", "crosssizek", "crossrot", "crossimg",
            "camthirdp", "camthirdpX", "camthirdpY", "camthirdpZ", "editzoom", "basefov", "zoomfov", "antimaskbool", "antiflashbool",
            "viewmodbool", "viewmodhandmat", "viewmodgunmat", "viewmodhandcolor", "viewmodguncolor", "viewmodoffset", "viewmodX", "viewmodY", "viewmodZ",
            "speedbool", "speedboost", "nojumpcd", "nofall", "instafall", "instalean", "changerbool", "changergrav", "changerspeed", "changerheight", "changerjump",
            "charsemiflydist", "charsemiflyspeed",
            "worldleaves", "worldgrass", "worldcloud", "worldclock", "worldnomines", "worldnoweather", "worldjesus", "worldambient", "worldoutdoor", "worldexpo", "colorcorrectbool", "colorcorrectbright", "colorcorrectcontrast", "colorcorrectsatur", "colorcorrecttint",
            "instantrespawn", "detectmods", "doublejump",
            "upanglebool", "upanglenum",
            "desyncbool", "desyncPos", "desynXp", "desynYp", "desynZp", "desyncOr", "desynXo", "desynYo", "desynZo"
        }
        local output = "local newvalues = {}\n"

        for _, varname in ipairs(allvariables) do
            value = allvars[varname]
            if value ~= nil then
                if typeof(value) == "string" then
                    output = output .. "newvalues."..varname .. " = \"" .. value .. "\"\n"
                elseif typeof(value) == "Color3" then
                    output = output .. "newvalues."..varname .. " = Color3.fromRGB(" .. math.floor(value.R * 255) .. ", " .. math.floor(value.G * 255) .. ", " .. math.floor(value.B * 255) .. ")\n"
                elseif typeof(value) == "EnumItem" then
                    output = output .. "newvalues."..varname .. " = " .. tostring(value) .. "\n"
                elseif typeof(value) == "table" then
                    local tablecontent = "{ "
                    for i, v in ipairs(value) do
                        tablecontent = tablecontent .. "\"" .. v .. "\""
                        if i < #value then
                            tablecontent = tablecontent .. ", "
                        end
                    end
                    tablecontent = tablecontent .. " }"
                    output = output .. "newvalues."..varname .. " = " .. tablecontent .. "\n"
                else
                    output = output .. "newvalues."..varname .. " = " .. tostring(value) .. "\n"
                end
            end
        end

        output = output .. "return newvalues"

        writefile(cfgname..'.txt', output)
        
        warn('saved config : ' .. cfgname)
        warn('saved config content:')
        print(output)

        Notify("Ardour", "Saved config "..cfgname)
    end
end
function loadconfig(cfgname)
    if isfile(cfgname .. ".txt") then
        local cfgtext = tostring(readfile(cfgname .. ".txt"))
        if not cfgtext then 
            Notify("Ardour", "Cant read config")
            return 
        end

        local values = loadstring(cfgtext)()
        for i,v in values do
            allvars[i] = v
        end

        library.UpdateGui(allvars)

        Notify("Ardour", "Loaded config "..cfgname)
    else
        Notify("Ardour", "Cant find this config")
    end
end
function setasdefault(cfgname)
    writefile("ardourdefault.txt", cfgname)
    Notify("Ardour", "Set as default")
end

mainhome:AddLabel('The script version is "Whiskey - 2" ')
mainhome:AddKeyBind('Toggle GUI', Enum.KeyCode.Insert, function() 
    if scriptloading then return end
    librarymaingui.Visible = not librarymaingui.Visible
    if scgui and scbool then
        scgui.Visible = librarymaingui.Visible
    end
end)
mainhome:AddToggle('Keybind list', true, nil, function(v)
    keybindlist = v
    keylist_gui.Visible = v
end)
mainhome:AddButton('Sigma suicide',function() 
    game.Players.LocalPlayer.Character.Health.Drowning:FireServer(115)
end)
configui:AddTextBox('Config name', nil, false, 5, function(text) 
    configname = text
end)
configui:AddButton('Load config',function() 
    loadconfig(configname)
end)
configui:AddButton('Save config',function() 
    saveconfig(configname)
end)
configui:AddButton('Set as default',function() 
    setasdefault(configname)
end)

aim:AddLabel('No Recoil/Spread enables with Silent Aim')
aim:AddToggle('Silent Aim', not allvars.aimbool, nil, function(v)
    allvars.aimbool = v
    if v == true then
        require(game.ReplicatedStorage.Modules.FPS.Bullet).CreateBullet = aimmodfunc
    else
        require(game.ReplicatedStorage.Modules.FPS.Bullet).CreateBullet = aimogfunc
    end
end)
aim:AddToggle('Target AI', not allvars.aimbots, nil, function(v)
    allvars.aimbots = v
end)
aim:AddToggle('Visibility check', not allvars.aimvischeck, nil, function(v)
    allvars.aimvischeck = v
end)
aim:AddToggle('Trigger Bot', not allvars.aimtrigger, Enum.KeyCode.KeypadOne, function(v)
    if v then keylist_addkey("Trigger Bot", Enum.KeyCode.KeypadOne.Name) else keylist_removekey("Trigger Bot") end
    allvars.aimtrigger = v
end)
aim:AddToggle('Ping check', not allvars.aimselftrack, nil, function(v)
    allvars.aimselftrack = v
end)
aim:AddToggle('Ammo distance check', not allvars.aimdistcheck, nil, function(v)
    allvars.aimdistcheck = v
end)
aim:AddToggle('Delay bullet', not allvars.aimfakewait, nil, function(v)
    allvars.aimfakewait = v
end)
aim:AddSlider('Aim FOV', 250, 0, allvars.aimfov, function(c) 
    allvars.aimfov = c
end)
aim:AddSlider('Aim Distance (Meters)', 950, 50, allvars.aimdistance, function(c) 
    allvars.aimdistance = c
end)
aim:AddSlider('Hit Chance', 100, 0, allvars.aimchance, function(c) 
    allvars.aimchance = c
end)
aim:AddDropdown('Aim Part', {'Head', 'HeadTop', "Face", 'Torso', 'Scripted', "Random"}, allvars.aimpart, function(a)
    allvars.aimpart = a
end)
aim:AddDropdown('Aim Type', {'Prediction', 'Instant Hit'}, allvars.aimtype, function(a)
    allvars.aimtype = a
end)
aim:AddSeparateBar()
aim:AddToggle('Show FOV', not allvars.showfov, nil, function(v)
    allvars.showfov = v
    aimfovcircle.Visible = v
end)
aim:AddToggle('Dynamic FOV', not allvars.aimdynamicfov, nil, function(v)
    allvars.aimdynamicfov = v
end)
aim:AddColorPallete('FOV Color', allvars.aimfovcolor,function(a)
    allvars.aimfovcolor = a
    aimfovcircle.Color = allvars.aimfovcolor
end)
aim:AddSeparateBar()
aim:AddToggle('Snapline', not allvars.snaplinebool, nil, function(v)
    allvars.snaplinebool = v
end)
aim:AddSlider('Snapline Thickness', 5, 0.01, allvars.snaplinethick, function(c)
    allvars.snaplinethick = c
    aimsnapline.Thickness = c
end)
aim:AddColorPallete('Snapline Color', allvars.snaplinecolor,function(a)
    allvars.snaplinecolor = a
    aimsnapline.Color = allvars.snaplinecolor
end)
aim:AddSeparateBar()
aim:AddToggle('HitSound', not allvars.hitsoundbool, nil, function(v)
    allvars.hitsoundbool = v
end)
aim:AddDropdown('Head Sound', hitsoundlibUI, allvars.hitsoundhead, function(a)
    allvars.hitsoundhead = a

    local preview = Instance.new("Sound", workspace)
    preview.SoundId = hitsoundlib[a]
    preview:Play()
    task.wait(1)
    preview:Destroy()
end)
aim:AddDropdown('Body Sound', hitsoundlibUI, allvars.hitsoundbody, function(a)
    allvars.hitsoundbody = a

    local preview = Instance.new("Sound", workspace)
    preview.SoundId = hitsoundlib[a]
    preview:Play()
    task.wait(1)
    preview:Destroy()
end)
aim:AddSeparateBar()
aim:AddToggle('Hitmarkers', not allvars.hitmarkbool, nil, function(v)
    allvars.hitmarkbool = v
end)
aim:AddColorPallete('Hitmark color', allvars.hitmarkcolor,function(a) 
    allvars.hitmarkcolor = a
end)
aim:AddSlider('Hitmark fade time', 10, 0, allvars.hitmarkfade, function(c) 
    allvars.hitmarkfade = c
end)

gunmods:AddToggle('Rapid Fire [IF HOLD GUN - REEQUIP IT]', not allvars.rapidfire, nil, function(v)
    allvars.rapidfire = v
    if v == false then
        local inv = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory
        for i,v in ipairs(inv:GetChildren()) do
            local sett = require(v.SettingsModule)
            local toset = 0.05
            toset = 60 / v.ItemProperties.Tool:GetAttribute("FireRate")
            sett.FireRate = toset
        end
    end
end)
gunmods:AddToggle('Custom rapidfire', not allvars.crapidfire, nil, function(v)
    allvars.crapidfire = v
end)
gunmods:AddToggle('Unlock firemodes [IF HOLD GUN - REEQUIP IT]', not allvars.unlockmodes, nil, function(v)
    allvars.unlockmodes = v
end)
gunmods:AddToggle('Instant Reload', allvars.instareload, nil, function(v)
    allvars.instareload = v
    if scriptloading then
        while scriptloading == true do wait(0.5) end
    end

    if v then 
        require(game.ReplicatedStorage.Modules.FPS).reload = instrelMODfunc
    else
        require(game.ReplicatedStorage.Modules.FPS).reload = instrelOGfunc
    end
end)
gunmods:AddToggle('Instant Equip', not allvars.instaequip, nil, function(v)
    allvars.instaequip = v
end)
gunmods:AddToggle('No sway', not allvars.noswaybool, nil, function(v)
    allvars.noswaybool = v
end)
gunmods:AddSlider('Multitaps', 5, 1, allvars.multitaps, function(c)
    allvars.multitaps = c
end)
gunmods:AddTextBox('Custom rapidfire delay', nil, false, 5, function(a)
    local num = tonumber(a)
    if num ~= nil then
        allvars.crapidfirenum = num
        Notify("Ardour", "Set custom allvars.rapidfire delay")
    end
end)


tarinfo:AddLabel('If it shows the name of target, then target is visible ')
tarinfo:AddToggle('Show Name', not allvars.showname, nil, function(v)
    allvars.showname = v
    aimtargetname.Visible = v
end)
tarinfo:AddToggle('Shots left', not allvars.shotsleft, nil, function(v)
    allvars.shotsleft = v
    aimtargetshots.Visible = v
end)


friendman:AddTextBox('Add player name', nil, false, 5, function(a) 
    local name = string.lower(a)
    local plrname = nil
    local matches = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        if string.find(string.lower(plr.Name), name, 1, true) then
            table.insert(matches, plr)
        end
    end
    if #matches == 1 then
        plrname = matches[1].Name
    end

    if game.Players:FindFirstChild(plrname) then 
        if table.find(allvars.aimFRIENDLIST, plrname) ~= nil then return end
        table.insert(allvars.aimFRIENDLIST, plrname)
        Notify("Ardour", "Added "..plrname.." to friendlist" )
    end
end)
friendman:AddTextBox('Add bot name', nil, false, 5, function(a) 
    if workspace.AiZones:FindFirstChild(plrname, true) then 
        if table.find(allvars.aimFRIENDLIST, plrname) ~= nil then return end
        table.insert(allvars.aimFRIENDLIST, plrname)
        Notify("Ardour", "Added "..plrname.." to friendlist" )
    end
end)
friendman:AddTextBox('Remove name', nil, false, 5, function(plrname)
    local iter = table.find(allvars.aimFRIENDLIST, plrname)
    if iter ~= nil then 
        table.remove(allvars.aimFRIENDLIST, iter)
        Notify("Ardour", "Removed "..plrname.." from friendlist" )
    end
end)
friendman:AddToggle('Include bots', not allvars.friendlistbots, nil, function(v)
    allvars.friendlistbots = v
end)
friendman:AddDropdown('Friendlist mode', {'Blacklist', 'Whitelist'}, allvars.friendlistmode, function(a)
    allvars.friendlistmode = a
end)
friendman:AddButton('Print friendlist (console)',function()
    if #allvars.aimFRIENDLIST == 0 then 
        print("No one in friendlist")
        return
    end
    print("Ardour friendlist:")
    for i,v in allvars.aimFRIENDLIST do
        print("["..i.."] "..v)
    end
    print("Ardour friendlist end")
end)
friendman:AddButton('Clear friendlist',function()
    table.clear(allvars.aimFRIENDLIST)
end)


wh:AddToggle('ESP', not allvars.espbool, nil, function(v)
    allvars.espbool = v
end)
wh:AddToggle('Name', not allvars.espname, nil, function(v)
    allvars.espname = v
end)
wh:AddToggle('HP', not allvars.esphp, nil, function(v)
    allvars.esphp = v
end)
wh:AddToggle('Distance', not allvars.espdistance, nil, function(v)
    allvars.espdistance = v
end)
wh:AddToggle('Chams', not allvars.esphigh, nil, function(v)
    allvars.esphigh = v
end)
wh:AddToggle('Active Gun', not allvars.esphotbar, nil, function(v)
    allvars.esphotbar = v
end)
wh:AddToggle('Dead', not allvars.espdead, nil, function(v)
    allvars.espdead = v
end)
wh:AddToggle('Bots', not allvars.espbots, nil, function(v)
    allvars.espbots = v
end)
wh:AddToggle('Loot', not allvars.esploot, nil, function(v)
    allvars.esploot = v
end)
wh:AddToggle('Extract', not allvars.espexit, nil, function(v)
    allvars.espexit = v
end)
wh:AddDropdown('Distance type', {'Meters', 'Studs'}, allvars.espdistmode, function(a)
    allvars.espdistmode = a
end)
wh:AddSlider('Render Distance (Meters)', 1200, 50, allvars.esprenderdist, function(c) 
    allvars.esprenderdist = c
end)
wh:AddSlider('Text Size', 35, 1, allvars.esptextsize, function(c) 
    allvars.esptextsize = c
end)
wh:AddToggle('Text outline', allvars.esptextline, nil, function(v)
    allvars.esptextline = v
end)
wh:AddSlider('Chams Outline Transparency', 1, 0, allvars.espchamsline, function(c) 
    allvars.espchamsline = c
end)
wh:AddSlider('Chams Fill Transparency', 1, 0, allvars.espchamsfill, function(c) 
    allvars.espchamsfill = c
end)
wh:AddColorPallete('Text Color', allvars.esptextcolor,function(a) 
    allvars.esptextcolor = a
end)
wh:AddColorPallete('Chams Outline Color', allvars.esplinecolor,function(a) 
    allvars.esplinecolor = a
end)
wh:AddColorPallete('Chams Fill Color', allvars.espfillcolor,function(a) 
    allvars.espfillcolor = a
end)


cross:AddToggle('Crosshair', not allvars.crossbool, nil, function(v)
    allvars.crossbool = v
end)
cross:AddLabel('Example: ArdourCross.png (put image from workspace)')
cross:AddTextBox('File Name', nil, false, 5, function(a) 
    if isfile(a) then
        if getcustomasset(a) ~= nil then
            allvars.crossimg = getcustomasset(a)
        else
            Notify("Ardour Error", "File is not a image")
            return
        end
    else
        Notify("Ardour Error", "Cant find the image")
        return
    end
end)
cross:AddLabel('or use default image id')
cross:AddTextBox('Image id', nil, false, 5, function(a) 
    allvars.crossimg = "rbxassetid://"..a
end)
cross:AddSlider('Size', 30, 0.5, allvars.crosssizek, function(c) 
    allvars.crosssizek = c
end)
cross:AddSlider('Rotation Speed', 10, -10, allvars.crossrot, function(c) 
    allvars.crossrot = c
end)
cross:AddColorPallete('Color', allvars.crosscolor,function(a) 
    allvars.crosscolor = a
end)


tracers:AddToggle('Tracers Enabled', not allvars.tracbool, nil, function(v)
    allvars.tracbool = v
end)
tracers:AddSlider('Remove time', 10, 0, allvars.tracwait, function(c) 
    allvars.tracwait = c
end)
tracers:AddColorPallete('Tracers Color', allvars.traccolor,function(a) 
    allvars.traccolor = a
end)
tracers:AddDropdown('Texture', {'None', 'Lighting', "Glow"}, 'None', function(a)
    allvars.tractexture = tractextures[a]
end)


camer:AddToggle('Third Person', not allvars.camthirdp, Enum.KeyCode.KeypadSix, function(v)
    if v then keylist_addkey("Third Person", Enum.KeyCode.KeypadSix.Name) else keylist_removekey("Third Person") end

    allvars.camthirdp = v
    if v and localplayer.Character then
        localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
        localplayer.CameraMaxZoomDistance = 5
        localplayer.CameraMinZoomDistance = 5
    else
        localplayer.Character.Humanoid.CameraOffset = Vector3.new(0,0,0)
        localplayer.CameraMaxZoomDistance = 0.5
        localplayer.CameraMinZoomDistance = 0.5
    end
end)
camer:AddSlider('Thirdp Offset X', 10, -10, allvars.camthirdpX, function(c) 
    allvars.camthirdpX = c
    if allvars.camthirdp and localplayer.Character then
        localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
    end
end)
camer:AddSlider('Thirdp Offset Y', 10, -10, allvars.camthirdpY, function(c) 
    allvars.camthirdpY = c
    if allvars.camthirdp and localplayer.Character then
        localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
    end
end)
camer:AddSlider('Thirdp Offset Z', 10, -10, allvars.camthirdpZ, function(c) 
    allvars.camthirdpZ = c
    if allvars.camthirdp and localplayer.Character then
        localplayer.Character.Humanoid.CameraOffset = Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
    end
end)
camer:AddSeparateBar()
camer:AddToggle('Anti mask', not allvars.antimaskbool, nil, function(v)
    allvars.antimaskbool = v
    if v == true then
        game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(0,0,1,0)
        game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(0,0,1,0)
        for i,v in ipairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
            v.Size = UDim2.new(0,0,1,0)
        end
    else
        game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(1,0,1,0)
        game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(1,0,1,0)
        for i,v in ipairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
            v.Size = UDim2.new(1,0,1,0)
        end
    end
end)
camer:AddToggle('Anti flash', not allvars.antiflashbool, nil, function(v)
    allvars.antiflashbool = v
    if v == true then
        game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Flashbang.Size = UDim2.new(0,0,1,0)
    else
        game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Flashbang.Size = UDim2.new(1,0,1,0)
    end
end)
camer:AddSeparateBar()
camer:AddToggle('Modify Zoom', allvars.editzoom, nil, function(v)
    if scriptloading then
        while scriptloading == true do wait(0.5) end
    end
    allvars.editzoom = v

    if v == true then
        require(game.ReplicatedStorage.Modules.CameraSystem).SetZoomTarget = camzoomfunction
    else
        require(game.ReplicatedStorage.Modules.CameraSystem).SetZoomTarget = camzoomfunctionOG
    end
end)
camer:AddSlider('Base FOV', 120, 10, allvars.basefov, function(c) 
    allvars.basefov = c
end)
camer:AddSlider('Zoom FOV', 50, 0, allvars.zoomfov, function(c) 
    allvars.zoomfov = c
end)

viewmod:AddToggle('SkinChanger menu', true, Enum.KeyCode.KeypadEight, function(v)
    if scriptloading then return end
    if librarymaingui.Visible == false then return end

    scbool = v

    if v then keylist_addkey("SkinChanger", Enum.KeyCode.KeypadEight.Name) else keylist_removekey("SkinChanger") end

    scgui.Visible = v
end)
viewmod:AddSeparateBar()
viewmod:AddToggle('Texture changer', not allvars.viewmodbool, nil, function(v)
    allvars.viewmodbool = v
end)
viewmod:AddDropdown('Hand Material', {'Neon', 'Forcefield', "Plastic"}, 'Plastic', function(a)
    if viewmod_materials[a] then
        allvars.viewmodhandmat = viewmod_materials[a]
    else
        warn('no material in mat table : ' .. a)
    end
end)
viewmod:AddDropdown('Gun Material', {'Neon', 'Forcefield', "Plastic"}, 'Plastic', function(a)
    if viewmod_materials[a] then
        allvars.viewmodgunmat = viewmod_materials[a]
    else
        warn('no material in mat table : ' .. a)
    end
end)
viewmod:AddColorPallete('Hand Color', allvars.viewmodhandcolor,function(a) 
    allvars.viewmodhandcolor = a
end)
viewmod:AddColorPallete('Gun Color', allvars.viewmodguncolor,function(a) 
    allvars.viewmodguncolor = a
end)
viewmod:AddSeparateBar()
viewmod:AddToggle('Offset changer', not allvars.viewmodoffset, nil, function(v)
    allvars.viewmodoffset = v
end)
viewmod:AddSlider('Offset X', 5, -5, allvars.viewmodX, function(c) 
    allvars.viewmodX = c
end)
viewmod:AddSlider('Offset Y', 5, -5, allvars.viewmodY, function(c) 
    allvars.viewmodY = c
end)
viewmod:AddSlider('Offset Z', 5, -5, allvars.viewmodZ, function(c) 
    allvars.viewmodZ = c
end)


speedh:AddToggle('Jesus', not allvars.worldjesus, nil, function(v)
    allvars.worldjesus = v
    if v then
        while allvars.worldjesus do
            wait(0.01)
            --original = https://devforum.roblox.com/t/how-do-i-make-water-walking-passive-like-this/1589924/10
            local hitPart = workspace:Raycast(localplayer.Character:FindFirstChild("HumanoidRootPart").Position, Vector3.new(0, -5, 0) + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5, RaycastParams.new())
            if hitPart and hitPart.Material == Enum.Material.Water then
                local clone = Instance.new("Part")
                clone.Parent = waterplatforms
                clone.Position = hitPart.Position
                clone.Anchored = true
                clone.CanCollide = true
                clone.Size = Vector3.new(10,0.2,10)
                clone.Transparency = 1
            end
        end
    else
        for i,v in ipairs(waterplatforms:GetChildren()) do
            v:Destroy()
        end
    end
end)
speedh:AddToggle('Desync', not allvars.desyncbool, Enum.KeyCode.KeypadThree, function(v)
    if v then keylist_addkey("Desync", Enum.KeyCode.KeypadThree.Name) else keylist_removekey("Desync") end
    allvars.desyncbool = v

    if v then
        desyncvis = Instance.new("Part", workspace)
        desyncvis.Name = "DesyncVisual"
        desyncvis.Anchored = true
        desyncvis.CanQuery = false
        desyncvis.CanCollide = false
        desyncvis.Size = Vector3.new(4,5,1)
        desyncvis.Color = Color3.fromRGB(255,0,0)
        desyncvis.Material = Enum.Material.Neon
        desyncvis.Transparency = 0.8
        desyncvis.TopSurface = Enum.SurfaceType.Hinge

        while allvars.desyncbool do
            task.wait(0.01)
        end

        localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.None, true)

        desyncvis:Destroy()
        desyncvis = nil
    end
end)
speedh:AddToggle('Edit Position', not allvars.desyncPos, nil, function(v)
    allvars.desyncPos = v
end)
speedh:AddSlider('Position X', 3, -3, allvars.desynXp, function(c) 
    allvars.desynXp = c
end)
speedh:AddSlider('Position Y', 2.5, -2.5, allvars.desynYp, function(c) 
    allvars.desynYp = c
end)
speedh:AddSlider('Position Z', 3, -3, allvars.desynZp, function(c) 
    allvars.desynZp = c
end)
speedh:AddToggle('Edit Orientation', not allvars.desyncOr, nil, function(v)
    allvars.desyncOr = v
end)
speedh:AddSlider('Orientation X', 180, -180, allvars.desynXo, function(c) 
    allvars.desynXo = c
end)
speedh:AddSlider('Orientation Y', 180, -180, allvars.desynYo, function(c) 
    allvars.desynYo = c
end)
speedh:AddSlider('Orientation Z', 180, -180, allvars.desynZo, function(c) 
    allvars.desynZo = c
end)
speedh:AddSeparateBar()
speedh:AddToggle('Edit upangle', not allvars.upanglebool, nil, function(v)
    allvars.upanglebool = v
end)
speedh:AddSlider('Upangle number', 0.75, -0.75, allvars.upanglenum, function(c) 
    allvars.upanglenum = c
end)
speedh:AddSeparateBar()
speedh:AddToggle('Auto Respawn', not allvars.instantrespawn, nil, function(v)
    allvars.instantrespawn = v
end)
speedh:AddSeparateBar()
speedh:AddToggle('TP Speed', not allvars.speedbool, nil, function(v)
    allvars.speedbool = v
    startspeedhack()
end)
speedh:AddSlider('TP Speed Boost', 1.5, 0, allvars.speedboost, function(c) 
    allvars.speedboost = c
end)
speedh:AddSeparateBar()
speedh:AddToggle('No Jump Cooldown', not allvars.nojumpcd, nil, function(v)
    allvars.nojumpcd = v
    startnojumpcd()
end)
speedh:AddToggle('NoFall', not allvars.nofall, nil, function(v)
    allvars.nofall = v
end)
speedh:AddToggle('InstaFall', not allvars.instafall, nil, function(v)
    allvars.instafall = v
end)
speedh:AddSeparateBar()
speedh:AddToggle('Double jump', not allvars.doublejump, nil, function(v)
    allvars.doublejump = v
end)
speedh:AddToggle('Instant Lean', not allvars.instalean, nil, function(v)
    if scriptloading then
        while scriptloading == true do wait(0.5) end
    end
    allvars.instalean = v
    if v then 
        require(game.ReplicatedStorage.Modules.FPS).changeLean = instantleanMODfunc
    else
        require(game.ReplicatedStorage.Modules.FPS).changeLean = instantleanOGfunc
    end
end)
speedh:AddSeparateBar()
speedh:AddToggle('Stop water effect update', true, nil, function(v)
    if scriptloading then return end

    localplayer.PlayerGui.MainGui.Scripts.HealthLocal.Disabled = v
    localplayer.PlayerGui.MainGui.Scripts.HealthLocal.Enabled = not v
end)
speedh:AddSeparateBar()
speedh:AddToggle('Humanoid changer', not allvars.changerbool, nil, function(v)
    allvars.changerbool = v
end)
speedh:AddSlider('Humanoid Speed', 21, 0, allvars.changerspeed, function(c) 
    allvars.changerspeed = c
end)
speedh:AddSlider('Humanoid Jumpheight', 8, 0, allvars.changerjump, function(c) 
    allvars.changerjump = c
end)
speedh:AddSlider('Humanoid Height', 6, 0, allvars.changerheight, function(c) 
    allvars.changerheight = c
end)
speedh:AddSlider('Gravity', 150, 0, allvars.changergrav, function(c) 
    allvars.changergrav = c
end)
speedh:AddSeparateBar()
speedh:AddToggle('Semi-Fly', true, Enum.KeyCode.KeypadFive, function(v) 
    if scriptloading then return end
    if v then keylist_addkey("Semi-Fly", Enum.KeyCode.KeypadFive.Name) else keylist_removekey("Semi-Fly") end

    if localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart") then
        if ACBYPASS_SYNC == false then
            Notify("Ardour", "Action in queue, wait for anticheat bypass update")

            while ACBYPASS_SYNC == false do
                wait(0.5)
            end
        end

        if v == false then
			semifly_bodyvel:Destroy()

            for i,v in ipairs(localplayer.Character.HumanoidRootPart:GetChildren()) do
                if v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end

            localplayer.Character.Humanoid.PlatformStand = false
		elseif v == true then
			semifly_bodyvel = Instance.new("BodyVelocity", localplayer.Character.HumanoidRootPart)
			semifly_bodyvel.Velocity = Vector3.new(0,0,0)
            localplayer.Character.Humanoid.PlatformStand = true
		end

        charsemifly = v
    else
        charsemifly = false
    end
end)
speedh:AddSlider('Semi-Fly Distance', 6, 0.1, allvars.charsemiflydist, function(c) 
    allvars.charsemiflydist = c
end)
speedh:AddSlider('Semi-Fly Speed', 50, 5, allvars.charsemiflyspeed, function(c) 
    allvars.charsemiflyspeed = c
end)


vmisc:AddToggle('Inventory Checker', not allvars.invcheck, nil, function(v)
    allvars.invcheck = v
end)
vmisc:AddToggle('Mod notify', not allvars.detectmods, nil, function(v)
    if scriptloading then return end

    allvars.detectmods = v
    if v == false then
        mdetect = false
        table.clear(detectedmods)
    end
end)
vmisc:AddToggle('Revive boss', true, nil, function(v)
    if scriptloading then return end
    if not workspace:FindFirstChild("Boss") then Notify("Ardour", "Use this only in lobby") end

    if v then
        local boss = workspace.Boss
        boss:SetAttribute("Hidden", false)
        for _,v in boss:GetDescendants() do
            if v:IsA("BasePart") and v:GetAttribute("OriginalTransparency") then
                v.Transparency = v:GetAttribute("OriginalTransparency")
            end
        end
    else
        local boss = workspace.Boss
        boss:SetAttribute("Hidden", true)
        for _,v in boss:GetDescendants() do
            if v:IsA("BasePart") and v:GetAttribute("OriginalTransparency") then
                v.Transparency = 1
            end
        end
    end
end)
vmisc:AddToggle('ESP Map', true, Enum.KeyCode.KeypadSeven, function(v)
    if scriptloading then return end
    if v then keylist_addkey("ESP Map", Enum.KeyCode.KeypadSeven.Name) else keylist_removekey("ESP Map") end

    espmapactive = v
    handleESPMAP(v)
end)


worldh:AddToggle('Disable Grass', not allvars.worldgrass, nil, function(v)
    allvars.worldgrass = v
    sethiddenproperty(workspace.Terrain, "Decoration", not v)
end)
worldh:AddToggle('Disable Leaves', not allvars.worldleaves, nil, function(v)
    allvars.worldleaves = v
end)
worldh:AddToggle('No clouds', not allvars.worldcloud, nil, function(v)
    allvars.worldcloud = v
    if workspace.Terrain:FindFirstChild("Clouds") then
        workspace.Terrain.Clouds.Enabled = not v
    end
end)
worldh:AddToggle('No weather', not allvars.worldnoweather, nil, function(v)
    allvars.worldnoweather = v
end)
worldh:AddToggle('No mines', not allvars.worldnomines, nil, function(v)
    allvars.worldnomines = v
end)
worldh:AddSeparateBar()
worldh:AddSlider('Exposure', 4, -4, allvars.worldexpo, function(c)
    allvars.worldexpo = c
    game.Lighting.ExposureCompensation = c
end)
worldh:AddSlider('Clock time', 24, 0, allvars.worldclock, function(c) 
    allvars.worldclock = c
    game.Lighting.ClockTime = c
end)
worldh:AddSeparateBar()
worldh:AddToggle('Edit Skybox', true, nil, function(v)
    skychangerbool = v
    if v == false then
        local Sky = game.Lighting:FindFirstChildOfClass("Sky")
        local selected = skyboxtable["Standard"]
        Sky.SkyboxBk = selected.SkyboxBk
        Sky.SkyboxDn = selected.SkyboxDn
        Sky.SkyboxFt = selected.SkyboxFt
        Sky.SkyboxLf = selected.SkyboxLf
        Sky.SkyboxRt = selected.SkyboxRt
        Sky.SkyboxUp = selected.SkyboxUp
    end
end)
worldh:AddDropdown('Select Skybox', {"Among Us", "Spongebob", "Deep Space", "Clouded Sky"}, false, function(skyboxName) --code by ds: _hai_hai
    local Sky = game.Lighting:FindFirstChildOfClass("Sky")
    local selected = skyboxtable[skyboxName]
    if selected and skychangerbool then
        Sky.SkyboxBk = selected.SkyboxBk
        Sky.SkyboxDn = selected.SkyboxDn
        Sky.SkyboxFt = selected.SkyboxFt
        Sky.SkyboxLf = selected.SkyboxLf
        Sky.SkyboxRt = selected.SkyboxRt
        Sky.SkyboxUp = selected.SkyboxUp
    else
        print("Invalid Skybox: " .. skyboxName)
    end
end)
worldh:AddSeparateBar()
worldh:AddToggle('Edit PostEffects', not allvars.colorcorrectbool, nil, function(v)
    allvars.colorcorrectbool = v
    game.Lighting.GeographicLatitude += 0.1
    game.Lighting.GeographicLatitude -= 0.1
end)
worldh:AddSlider('Brightness', 3, -3, allvars.colorcorrectbright, function(c) 
    allvars.colorcorrectbright = c
    game.Lighting.GeographicLatitude += 0.1
    game.Lighting.GeographicLatitude -= 0.1
end)
worldh:AddSlider('Saturation', 3, -3, allvars.colorcorrectsatur, function(c) 
    allvars.colorcorrectsatur = c
    game.Lighting.GeographicLatitude += 0.1
    game.Lighting.GeographicLatitude -= 0.1
end)
worldh:AddSlider('Contrast', 3, -3, allvars.colorcorrectcontrast, function(c) 
    allvars.colorcorrectcontrast = c
    game.Lighting.GeographicLatitude += 0.1
    game.Lighting.GeographicLatitude -= 0.1
end)
worldh:AddColorPallete('Tint color', allvars.colorcorrecttint,function(a) 
    allvars.colorcorrecttint = a
    game.Lighting.GeographicLatitude += 0.1
    game.Lighting.GeographicLatitude -= 0.1
end)
worldh:AddSeparateBar()
worldh:AddColorPallete('Ambient Color', allvars.worldambient,function(a) 
    allvars.worldambient = a
    game.Lighting.Ambient = allvars.worldambient
end)
worldh:AddColorPallete('Outdoor Ambient Color', allvars.worldoutdoor,function(a) 
    allvars.worldoutdoor = a
    game.Lighting.OutdoorAmbientAmbient = allvars.worldoutdoor
end)


--tracers--
print("loading tracers")
local function runtracer(start, endp)
    local beam = Instance.new("Beam")
    beam.Name = "LineBeam"
    beam.Parent = game.Workspace
    local startpart = Instance.new("Part")
    startpart.CanCollide = false
    startpart.CanQuery = false
    startpart.Transparency = 1
    startpart.Position = start
    startpart.Parent = workspace
    startpart.Anchored = true
    startpart.Size = Vector3.new(0.01, 0.01, 0.01)
    local endpart = Instance.new("Part")
    endpart.CanCollide = false
    endpart.CanQuery = false
    endpart.Transparency = 1
    endpart.Position = endp
    endpart.Parent = workspace
    endpart.Anchored = true
    endpart.Size = Vector3.new(0.01, 0.01, 0.01)
    beam.Attachment0 = Instance.new("Attachment", startpart)
    beam.Attachment1 = Instance.new("Attachment", endpart)
    beam.Color = ColorSequence.new(allvars.traccolor,  allvars.traccolor)
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.Transparency = NumberSequence.new(0)
    beam.LightEmission = 1

    if allvars.tractexture ~= nil then
        beam.Texture = allvars.tractexture
        if allvars.tractexture == "http://www.roblox.com/asset/?id=131326755401058" then
            beam.TextureSpeed = 3
            beam.TextureLength = (endp - start).Magnitude
            beam.Width0 = 0.3
            beam.Width1 = 0.3
        end
    end

    wait(allvars.tracwait)

    beam:Destroy()
    startpart:Destroy()
    endpart:Destroy()
end


--silent aim--
print("loading silent aim ")
function isonscreen(object)
    local _, bool = wcamera:WorldToScreenPoint(object.Position)
    return bool
end
v311 = require(game.ReplicatedStorage.Modules:WaitForChild("UniversalTables"))
globalist11 = v311.ReturnTable("GlobalIgnoreListProjectile")
function isvisible(char, object)
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    if allvars.aimvischeck == false then
        return true
    end

    local origin = localplayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
    if allvars.aimselftrack then
        local plrping = localplayer:GetNetworkPing() * 1000 + 5
        local key = math.floor(plrping / 10) * 10

        local onv
        for _, entry in ipairs(selftrack_data) do
            if entry.ms == key then
                onv = entry
            end
        end
        if onv ~= nil then
            origin = onv.vpos
        end
    end

    local pos = object.Position
    local dir = pos - origin
    local dist = dir.Magnitude + 5
    local penetrated = true
    dir = dir.Unit

    local params = RaycastParams.new()
    params.IgnoreWater = true
    params.CollisionGroup = "WeaponRay"
    params.FilterDescendantsInstances = {
        localplayer.Character:GetChildren(),
        wcamera:GetChildren(),
        globalist11,
        aimignoreparts,
    }

    local ray = workspace:Raycast(origin, dir * dist, params)
    if ray and ray.Instance:IsDescendantOf(char) then
        return true
    elseif ray and ray.Instance.Name ~= "Terrain" and not ray.Instance:GetAttribute("NoPen") then
        local armorpen4 = 10
        if globalammo then
            armorpen4 = globalammo:GetAttribute("ArmorPen")
        end

        local FunctionLibraryExtension = require(game.ReplicatedStorage.Modules.FunctionLibraryExtension)
        local armorpen1, newpos2 = FunctionLibraryExtension.Penetration(FunctionLibraryExtension, ray.Instance, ray.Position, dir, armorpen4)
        if armorpen1 == nil or newpos2 == nil then
            return false
        end

        local neworigin = ray.Position + dir * 0.01
        local newray = workspace:Raycast(neworigin, dir * (dist - (neworigin - origin).Magnitude), params)
        if newray and newray.Instance:IsDescendantOf(char) then
            return true
        end
    end

    return false
end
function predictpos(tpart, bulletspeed, bulletdrop)
    local velocity = tpart.Velocity
    local distance = (wcamera.CFrame.Position - tpart.CFrame.Position).Magnitude
    local tth = (distance / bulletspeed)
    local predict1 = tpart.CFrame.Position + (velocity * tth)
    local delta = (predict1 - tpart.CFrame.Position).Magnitude
    local finalspeed = bulletspeed - 0.013 * bulletspeed ^ 2 * tth ^ 2
    tth += (delta / finalspeed)
    local predictres1 = tpart.CFrame.Position + (velocity * tth)
    local predictres2 = bulletdrop * tth ^ 2
    if tostring(drop_timing):find("nan") then
        predictres2 = 0
    end
    return predictres1 -- + Vector3.new(0,predictres2,0)
end
function choosetarget()
    local cent = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
    local cdist = math.huge
    local ctar = nil
    local cpart = nil

    local ammodistance = 999999999
    if allvars.aimdistcheck and globalammo then
        ammodistance = globalammo:GetAttribute("MuzzleVelocity")
    end

    local bparts = {
        "Head",
        "HeadTopHitBox",
        "FaceHitBox",
        "UpperTorso",
        "LowerTorso",
        "LeftUpperArm",
        "RightUpperArm",
        "LeftLowerArm",
        "RightLowerArm",
        "LeftHand",
        "RightHand",
        "LeftUpperLeg",
        "RightUpperLeg",
        "LeftLowerLeg",
        "RightLowerLeg",
        "LeftFoot",
        "RightFoot"
    }

    local function chooseTpart(charact)
        if allvars.aimpart == "Head" then
            return charact:FindFirstChild("Head")
        elseif allvars.aimpart == "HeadTop" then
            return charact:FindFirstChild("HeadTopHitBox")
        elseif allvars.aimpart == "Face" then
            return charact:FindFirstChild("FaceHitBox")
        elseif allvars.aimpart == "Torso" then
            return charact:FindFirstChild("UpperTorso")
        elseif allvars.aimpart == "Scripted" then
            local head = charact:FindFirstChild("Head")
            local upperTorso = charact:FindFirstChild("UpperTorso")
            if not isvisible(charact, head) then
                return upperTorso
            else
                return head
            end
        elseif allvars.aimpart == "Random" then
            return charact:FindFirstChild(bparts[math.random(1, #bparts)])
        end
    end

    if allvars.aimbots then --priority 2 (bots)
        for _, botfold in ipairs(workspace.AiZones:GetChildren()) do
            for _, bot in ipairs(botfold:GetChildren()) do
                if bot:IsA("Model") and bot:FindFirstChild("Humanoid") and bot.Humanoid.Health > 0 then
                    if allvars.friendlistbots then
                        if allvars.friendlistmode == "Blacklist" then 
                            if table.find(allvars.aimFRIENDLIST, bot.Name) ~= nil then
                                continue
                            end
                        elseif allvars.friendlistmode == "Whitelist" then 
                            if table.find(allvars.aimFRIENDLIST, bot.Name) == nil then
                                continue
                            end
                        end
                    end

                    local potroot = chooseTpart(bot)
                    if potroot and localplayer.Character then
                        local spoint = wcamera:WorldToViewportPoint(potroot.Position)
                        local optpoint = Vector2.new(spoint.X, spoint.Y)
                        local dist = (optpoint - cent).Magnitude
                        
                        local betweendist = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude * 0.3336
                        local betweendistSTUDS = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude
                        if dist <= aimfovcircle.Radius and dist < cdist and betweendist < allvars.aimdistance and betweendistSTUDS < ammodistance then
                            local canvis = isvisible(bot, potroot)
                            if canvis and isonscreen(potroot) then
                                cdist = dist
                                ctar = bot
                                cpart = potroot
                            end
                        end
                    end
                end
            end
        end
    end

    for _, pottar in ipairs(game.Players:GetPlayers()) do --priority 1 (players)
        if pottar ~= localplayer and pottar.Character and localplayer.Character.PrimaryPart ~= nil then
            if allvars.friendlistmode == "Blacklist" then 
                if table.find(allvars.aimFRIENDLIST, pottar.Name) ~= nil then
                    continue
                end
            elseif allvars.friendlistmode == "Whitelist" then 
                if table.find(allvars.aimFRIENDLIST, pottar.Name) == nil then
                    continue
                end
            end

            local potroot = chooseTpart(pottar.Character)
            if potroot then
                local spoint = wcamera:WorldToViewportPoint(potroot.Position)
                local optpoint = Vector2.new(spoint.X, spoint.Y)
                local dist = (optpoint - cent).Magnitude
                
                local betweendist = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude * 0.3336
                local betweendistSTUDS = (localplayer.Character.PrimaryPart.Position - potroot.Position).Magnitude
                if dist <= aimfovcircle.Radius and dist < cdist and betweendist < allvars.aimdistance and betweendistSTUDS < ammodistance then
                    local canvis = isvisible(pottar.Character, potroot)
                    local onscr = isonscreen(potroot)
                    if canvis and onscr then
                        cdist = dist
                        ctar = pottar
                        cpart = potroot
                    end
                end
            end
        end
    end

    if ctar == nil then
        aimtarget = nil
        aimtargetpart = nil
    else
        aimtarget = ctar
        aimtargetpart = cpart
    end
end
function runhitmark(v140)
    if allvars.hitmarkbool then --some code by ds: meowya_1337
        local hitpart = Instance.new("Part", workspace)
        hitpart.Transparency = 1
        hitpart.CanCollide = false
        hitpart.CanQuery = false
        hitpart.Size = Vector3.new(0.01,0.01,0.01)
        hitpart.Anchored = true
        hitpart.Position = v140

        local hit = Instance.new("BillboardGui")
        hit.Name = "hit"
        hit.AlwaysOnTop = true
        hit.Parent = hitpart

        local hit_img = Instance.new("ImageLabel")
        hit_img.Name = "hit_img"
        hit_img.Image = "http://www.roblox.com/asset/?id=13298929624"
        hit_img.BackgroundTransparency = 1
        hit_img.Size = UDim2.new(0, 50, 0, 50)
        hit_img.Visible = true
        hit_img.ImageColor3 = allvars.hitmarkcolor
        hit_img.Rotation = 45
        hit_img.AnchorPoint = Vector2.new(0.5, 0.5)
        hit_img.Parent = hit

        task.spawn(function()
            local tweninfo = TweenInfo.new(allvars.hitmarkfade, Enum.EasingStyle.Sine)
            local tweninfo2 = TweenInfo.new(allvars.hitmarkfade, Enum.EasingStyle.Linear)
            tweens:Create(hit_img, tweninfo, {ImageTransparency = 1}):Play()
            tweens:Create(hit_img, tweninfo2, {Rotation = 180}):Play()
            task.wait(allvars.hitmarkfade)
            hit_img:Destroy()
            hit:Destroy()
        end)
    end
end
aimmodfunc = function(prikol, p49, p50, p_u_51, aimpart, _, p52, p53, p54)
    local v_u_6 = game.ReplicatedStorage.Remotes.VisualProjectile
    local v_u_108 = 1
    local v_u_106 = 0
    local v_u_7 = game.ReplicatedStorage.Remotes.FireProjectile
    local target = aimtarget
    local target_part
    local v_u_4 = require(game.ReplicatedStorage.Modules:WaitForChild("FunctionLibraryExtension"))
    local v_u_103
    local v_u_114
    local v_u_16 = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name)
    local v_u_64 = v_u_16.Status.GameplayVariables:GetAttribute("EquipId")
    local v_u_13 = game.ReplicatedStorage:WaitForChild("VFX")
    local v_u_2 = require(game.ReplicatedStorage.Modules:WaitForChild("VFX"))
    local v3 = require(game.ReplicatedStorage.Modules:WaitForChild("UniversalTables"))
    local v_u_5 = game.ReplicatedStorage.Remotes.ProjectileInflict
    local v_u_10 = game:GetService("ReplicatedStorage")
    local v_u_12 = v_u_10:WaitForChild("RangedWeapons")
    local v_u_17 = game.ReplicatedStorage.Temp
    local v_u_56 = localplayer.Character
    local v135 = 500000
    local v_u_18 = v3.ReturnTable("GlobalIgnoreListProjectile")
    local v_u_115 = localplayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
    if allvars.aimselftrack then
        local plrping = localplayer:GetNetworkPing() * 1000 + 5
        local key = math.floor(plrping / 10) * 10

        local onv
        for _, entry in ipairs(selftrack_data) do
            if entry.ms == key then
                onv = entry
            end
        end
        if onv ~= nil then
            v_u_115 = onv.vpos
        end
    end

    local v65 = v_u_10.AmmoTypes:FindFirstChild(p52)
    local v_u_74 = v65:GetAttribute("Pellets")
    local v60 = p50.ItemRoot
    local v61 = p49.ItemProperties
    local v62 = v_u_12:FindFirstChild(p49.Name)
    local v63 = v61:FindFirstChild("SpecialProperties")
    local v_u_66 = v63 and v63:GetAttribute("TracerColor") or v62:GetAttribute("ProjectileColor")
    local itemprop = require(v_u_16.Inventory:FindFirstChild(p49.Name).SettingsModule)
    local bulletspeed = v65:GetAttribute("MuzzleVelocity")
    local armorpen4 = v65:GetAttribute("ArmorPen")
    local tracerendpos = Vector3.zero
    local v79 = {
        ["x"] = {
            ["Value"] = 0
        },
        ["y"] = {
            ["Value"] = 0
        }
    }

    if v_u_56:FindFirstChild(p49.Name) then
        local v83 = 0.001 
        local v82 = 0.001
        local v81 = v61.Tool:GetAttribute("MuzzleDevice") or "Default"
        v_u_108 = math.random(-100000, 100000)
        
        if v61.Tool:GetAttribute("MuzzleDevice") or "Default" == "Suppressor" then
            if tick() - p53 < 0.8 then
                v_u_4:PlaySoundV2(v60.Sounds.FireSoundSupressed, v60.Sounds.FireSoundSupressed.TimeLength, v_u_17)
            else
                v_u_4:PlaySoundV2(v60.Sounds.FireSoundSupressed, v60.Sounds.FireSoundSupressed.TimeLength, v_u_17)
            end
        elseif tick() - p53 < 0.8 then
            v_u_4:PlaySoundV2(v60.Sounds.FireSound, v60.Sounds.FireSound.TimeLength, v_u_17)
        else
            v_u_4:PlaySoundV2(v60.Sounds.FireSound, v60.Sounds.FireSound.TimeLength, v_u_17)
        end
        local v_u_59
        if p_u_51.Item.Attachments:FindFirstChild("Front") then
            v_u_59 = p_u_51.Item.Attachments.Front:GetChildren()[1].Barrel
        else
            v_u_59 = p_u_51.Item.Barrel
        end

        if target ~= nil and aimtargetpart ~= nil then
            target_part = aimtargetpart
            if allvars.aimtype == "Prediction" then
                local buldrop = v65:GetAttribute("ProjectileDrop")
                local bulsp = v65:GetAttribute("MuzzleVelocity")
                target_part = predictpos(target_part, bulsp, buldrop)
                v_u_103 = CFrame.new(v_u_115, target_part).LookVector
            else
                v_u_103 = CFrame.new(v_u_115, target_part.Position).LookVector
            end
            v_u_114 = v_u_103
        else
            target_part = aimpart
            v_u_103 = CFrame.new(v_u_115, localplayer:GetMouse().Hit.Position).LookVector
            v_u_114 = v_u_103
        end

        function v185()
            local v_u_110 = RaycastParams.new()
            v_u_110.FilterType = Enum.RaycastFilterType.Exclude
            local v_u_111 = { v_u_56, p_u_51, v_u_18, aimignoreparts}
            v_u_110.FilterDescendantsInstances = v_u_111
            v_u_110.CollisionGroup = "WeaponRay"
            v_u_110.IgnoreWater = true

            v_u_106 += 1

            local usethisvec = v_u_114

            if v_u_106 == 1 then
                task.spawn(function()
                    for i=1, allvars.multitaps do
                        if allvars.aimtype == "Instant Hit" then
                            if not v_u_7:InvokeServer(usethisvec, v_u_108, tick()-15) then 
                                game.ReplicatedStorage.Modules.FPS.Binds.AdjustBullets:Fire(v_u_64, 1)
                            end
                        else
                            if not v_u_7:InvokeServer(usethisvec, v_u_108, tick()) then 
                                game.ReplicatedStorage.Modules.FPS.Binds.AdjustBullets:Fire(v_u_64, 1)
                            end
                        end
                    end
                end)
            elseif 1 < v_u_106 then
                for i=1, allvars.multitaps do
                    v_u_6:FireServer(usethisvec, v_u_108)
                end
            end

            local v_u_131 = nil
            local v_u_132 = 0
            local v_u_133 = 0

            if (allvars.aimtype == "Prediction" or allvars.aimfakewait) and target ~= nil then
                local tpart 
                if target:IsA("Model") then
                    tpart = target.HumanoidRootPart
                else
                    tpart = target.Character.HumanoidRootPart
                end
                local velocity = tpart.Velocity
                local distance = (wcamera.CFrame.Position - tpart.CFrame.Position).Magnitude
                local tth = (distance / bulletspeed)
                task.wait(tth + 0.01)
            end

            local penetrated = false

            function v184(p134)
                v_u_132 = v_u_132 + p134
                if true then
                    v_u_133 = v_u_133 + v_u_132
                    local v136 = workspace:Raycast(v_u_115, v_u_114 * v135, v_u_110)
                    local v137 = nil
                    local v138 = nil
                    local v139 = nil
                    local v140
                    if v136 then
                        v137 = v136.Instance
                        v140 = v136.Position
                        v138 = v136.Normal
                        v139 = v136.Material
                    else
                        v140 = v_u_115 + v_u_114 * v135
                    end

                    if v137 == nil then
                        v_u_131:Disconnect()
                        return
                    end

                    tracerendpos = v140

                    local v171 = v_u_4:FindDeepAncestor(v137, "Model")
                    if v171:FindFirstChild("Humanoid") then -- if hit target
                        local ran = math.random(1, 100)
                        local ranbool = ran <= allvars.aimchance
                        if ranbool then
                            local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140))

                            if target_part and penetrated == false then
                                v_u_5:FireServer(target_part, v175, v_u_108, tick())
                            else
                                v_u_5:FireServer(v137, v175, v_u_108, tick())
                            end
                        else
                            local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140))
                            v_u_5:FireServer(aimpart, v175, v_u_108, tick())
                        end

                        task.spawn(function()
                            runhitmark(v140)
                        end)
                    elseif v137.Name == "Terrain" then -- if hit terrain
                        local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140))
                        v_u_5:FireServer(v137, v175, v_u_108, tick())

                        v_u_2.Impact(v137, v140, v138, v139, v_u_114, "Ranged", true)

                        task.spawn(function()
                            runhitmark(v140)
                        end)
                    else -- if hit not target then try wallpen
                        v_u_2.Impact(v137, v140, v138, v139, v_u_114, "Ranged", true)

                        task.spawn(function()
                            runhitmark(v140)
                        end)

                        local arg1, arg2, arg3 = v_u_4.Penetration(v_u_4, v137, v140, v_u_114, armorpen4)
                        if arg1 == nil or arg2 == nil then
                            local v175 = v137.CFrame:ToObjectSpace(CFrame.new(v140))
                            v_u_5:FireServer(v137, v175, v_u_108, tick())
                            v_u_131:Disconnect()
                            return
                        end

                        armorpen4 = arg1
                        if armorpen4 > 0 then
                            v_u_115 = arg2
                            v_u_2.Impact(unpack(arg3))
                            penetrated = true
                            return
                        end

                        v_u_131:Disconnect()
                        return
                    end
                end

                v_u_131:Disconnect()
                return
            end
            v_u_131 = game:GetService("RunService").RenderStepped:Connect(v184)
            return
        end
        if v_u_74 == nil then
            task.spawn(v185)
        else
            for _ = 1, v_u_74 do
                task.spawn(v185)
            end
        end

        if allvars.tracbool then
            task.spawn(function()
                task.wait(0.05)
                if tracerendpos == Vector3.zero then return end
                runtracer(v60.Position, tracerendpos)
            end)
        end
        return v83, v82, v81, v79
    end
end

--esp--
print("loading ESP functions/connections")
function setupesp(obj, dtype, otype1)
    if not obj then return end

    local dobj
    local tableinfo
    if dtype == "Name" then
        dobj = Drawing.new("Text")
        dobj.Visible = allvars.espbool
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "Name",
            otype = otype1
        }
    elseif dtype == "HP" then
        dobj = Drawing.new("Text")
        dobj.Visible = allvars.espbool
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "HP",
            otype = otype1
        }
    elseif dtype == "Distance" then
        dobj = Drawing.new("Text")
        dobj.Visible = allvars.espbool
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "Distance",
            otype = otype1
        }
    elseif dtype == "Hotbar" then
        dobj = Drawing.new("Text")
        dobj.Visible = allvars.espbool
        dobj.Center = true
        dobj.Outline = true
        dobj.Size = allvars.esptextsize
        dobj.Color = allvars.esptextcolor
        dobj.OutlineColor = Color3.new(0, 0, 0)
        tableinfo = {
            primary = obj,
            type = "Hotbar",
            otype = otype1
        }
    elseif dtype == "Highlight" then
        dobj = Instance.new("Highlight")
        dobj.Name = "ardour highlight solter dont delete PLS"
        dobj.FillColor = allvars.espfillcolor
        dobj.OutlineColor = allvars.esplinecolor
        dobj.FillTransparency = allvars.espchamsfill
        dobj.OutlineTransparency = allvars.espchamsline
        if obj.Parent:IsA("Model") then
            dobj.Parent = obj.Parent
        else
            dobj:Destroy()
            return
        end

        dobj.Enabled = allvars.esphigh
        tableinfo = {
            primary = obj,
            type = "Highlight",
            otype = otype1
        }
    end

    if dobj == nil or tableinfo == nil then return end

    local function selfdestruct() --destroy esp object
        if dtype == "Highlight" then
            dobj.Enabled = false
            dobj:Destroy()
        else
            dobj.Visible = false
            dobj:Remove()
        end
        if removing then
            removing:Disconnect()
            removing = nil
        end
        return
    end

    if esptable[dobj] ~= nil then --if in table then cancel
        selfdestruct()
        return
    else
        esptable[dobj] = tableinfo
    end

    removing = workspace.DescendantRemoving:Connect(function(what)
        if what == obj then
            esptable[dobj] = nil
            selfdestruct()
        end
    end)
end
function startesp(v, otype) --start esp for model
    if not v then return end

    task.spawn(function()
        if otype == "Extract" then
            setupesp(v, "Name", otype)
            setupesp(v, "Distance", otype)
        elseif otype == "Loot" then
            local Amount
            local TotalPrice = 0
            local Value = 0

            if v.Parent and v.Parent:FindFirstChild("Inventory") then else
                return
            end

            for _, i in ipairs(v.Parent.Inventory:GetChildren()) do
                Amount = i.ItemProperties:GetAttribute("Amount") or 1
                TotalPrice += i.ItemProperties:GetAttribute("Price") or 0
                Value += (valcache[i.ItemProperties:GetAttribute("CallSign")] or 0) * Amount
            end --original = https://rbxscript.com/post/ProjectDeltaLootEsp-P7xaS

            if Value >= 4 then
                setupesp(v, "Name", otype)
                setupesp(v, "Hotbar", otype)
                setupesp(v, "Distance", otype)
            end
        elseif otype == "Dead333" then
            local hd = v:WaitForChild("Head",1)
            if hd == nil then return end
            setupesp(hd, "Name", otype)
            setupesp(hd, "Distance", otype)
        else
            local hd = v:WaitForChild("Head",1)
            if hd == nil then return end
            setupesp(hd, "Name", otype)
            setupesp(hd, "HP", otype)
            setupesp(hd, "Distance", otype)
            setupesp(hd, "Hotbar", otype)
            setupesp(hd, "Highlight", otype) 
        end
    end)
end
for i,v in ipairs(workspace:GetDescendants()) do
    if v and v:FindFirstChild("Humanoid") and v ~= localplayer.Character then
        if game.Players:FindFirstChild(v.Name) and not v:FindFirstAncestor("DroppedItems") then
            startesp(v, "Plr")
        elseif v:FindFirstAncestor("AiZones") then
            startesp(v, "Bot333")
        elseif v:FindFirstAncestor("DroppedItems") then
            startesp(v, "Dead333")
        end
    elseif v.Parent == workspace:FindFirstChild("NoCollision"):FindFirstChild("ExitLocations") then
        startesp(v, "Extract")
    elseif v:FindFirstAncestor("Containers") and v:IsA("MeshPart") then
        if v.Parent:IsA("Model") then
            startesp(v, "Loot")
        end
    end
end
workspace.DescendantAdded:Connect(function(v)
    if v and v.Parent and v:IsA("BasePart") and v.Name == "Head" then
        local hum = v.Parent:WaitForChild("Humanoid", 2)
        if hum and v.Parent ~= localplayer.Character then
            if game.Players:FindFirstChild(v.Parent.Name) and not v:FindFirstAncestor("DroppedItems") then
                startesp(v.Parent, "Plr")
            elseif v:FindFirstAncestor("AiZones") then
                startesp(v.Parent, "Bot333")
            elseif v:FindFirstAncestor("DroppedItems") then
                startesp(v.Parent, "Dead333")
            end
        end
    elseif v.Parent == workspace:FindFirstChild("NoCollision"):FindFirstChild("ExitLocations") then
        startesp(v, "Extract")
    elseif v:FindFirstAncestor("Containers") and v:IsA("MeshPart") then
        if v.Parent:IsA("Model") then
            startesp(v, "Loot")
        end
    end
end)

--speedhack--
print("loading speedhack function")
function startspeedhack() --paste2
    local chr = localplayer.Character
    local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
    while allvars.speedbool and chr and hum and hum.Parent do
        local delta = runs.Heartbeat:Wait()
        if hum.MoveDirection.Magnitude > 0 then
            chr:TranslateBy(hum.MoveDirection * tonumber(allvars.speedboost) * delta * 10)
        else
            chr:TranslateBy(hum.MoveDirection * delta * 10)
        end
    end
end

--no jump cd--
print("loading bunnyhop function")
function startnojumpcd() --btw this not paste i found it myself
    while allvars.nojumpcd do
        task.wait(0.01)
        if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:SetAttribute("JumpCooldown", tick())
        else
            wait(1)
        end
    end
end

--fullbright--
print("loading fullbright")
pcall(function() --paste1
    local lighting = game:GetService("Lighting");
    lighting.Ambient = allvars.worldambient
    lighting.OutdoorAmbient = allvars.worldoutdoor
    lighting.Brightness = 1;
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
	for i,v in pairs(lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
    for i, v in pairs(lighting:GetDescendants()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false;
        end;
    end;
    lighting.Changed:Connect(function()
        lighting.Ambient = allvars.worldambient
        lighting.Brightness = 1;
        lighting.FogEnd = 100000
        lighting.OutdoorAmbient = allvars.worldoutdoor
        lighting.ClockTime = allvars.worldclock
        lighting.ExposureCompensation = allvars.worldexpo

        if allvars.colorcorrectbool then
            lighting.PostEffects.Enabled = true
            lighting.PostEffects.Brightness = allvars.colorcorrectbright
            lighting.PostEffects.Saturation = allvars.colorcorrectsatur
            lighting.PostEffects.Contrast = allvars.colorcorrectcontrast
            lighting.PostEffects.TintColor = allvars.colorcorrecttint
        else
            lighting.PostEffects.Enabled = false
        end

        local atmo = lighting:FindFirstChildOfClass("Atmosphere")
        if atmo then
            atmo:Destroy()
        end
    end)
end)

--camera--
print("loading fov changer")
do --fov changer
    csys = require(game.ReplicatedStorage.Modules.CameraSystem)
    dop2 = require(game.ReplicatedStorage.Modules.spring).new(Vector3.new(), Vector3.new(), Vector3.new(), 15, 0.5)
    dop3 = game:GetService("TweenService")
    dop4 = workspace.Camera
    dop5 = false
    dop6 = 1
    dop7 = false
    dop8 = 1
    dop9 = 1
    dop10 = nil
    function FieldOfViewUpdate(p11, p12, p13) 
        local v14 = p12 or Enum.EasingStyle.Quad
        local v15 = p13 or Enum.EasingDirection.Out
        local targetfov
        if dop8 > 1 then
            targetfov = allvars.zoomfov
        else
            targetfov = allvars.basefov
        end
        local v16 = dop9 ~= 1 and dop9 or dop5 and dop6 or targetfov
        dop3:Create(dop4, TweenInfo.new(p11, v14, v15), {
            ["FieldOfView"] = v16 > 1 and dop7 and v16 or v16
        }):Play()
        if dop10 then
            local v_u_17 = dop10
            task.spawn(function() 
                local v_u_18 = v_u_17:FindFirstChild("Head") or v_u_17.PrimaryPart
                dop2.p = v_u_18.Position
                local v_u_19 = nil
                v_u_19 = game:GetService("RunService").RenderStepped:Connect(function(p20)
                    dop4.CFrame = CFrame.lookAt(dop4.CFrame.Position, dop2.p)
                    dop2.target = v_u_18.Position
                    dop2:update(p20)
                    if dop10 ~= v_u_17 then
                        v_u_19:Disconnect()
                    end
                end)
            end)
        end
    end
    camzoomfunction = function(_, p21, p22, p23, p24, p25)
        dop7 = p22
        dop8 = p21
        FieldOfViewUpdate(p23, p24, p25)
    end
end


--insta equip 
print("loading insta equip")
workspace.Camera.ChildAdded:Connect(function(ch)
    if allvars.instaequip and ch:IsA("Model") then
        task.wait(0.015)
        for i,v in ch.Humanoid.Animator:GetPlayingAnimationTracks() do
            if v.Animation.Name == "Equip" then
                --v:AdjustSpeed(15)
                v.TimePosition = v.Length - 0.01
            end
        end
    end
end)


-- third person --
print("changing thirdperson roblox script")
require(game.Players.LocalPlayer.PlayerScripts.PlayerModule.CameraModule.TransparencyController).Update = function(a1, a2) -- transparency = allvars.camthirdp and 1 or 0
    local v14_3_ = workspace
    local v14_2_ = v14_3_.CurrentCamera

    local setto = 0
    if allvars.camthirdp == false then
        setto = 1
    end

    if v14_2_ then
        v14_3_ = a1.enabled
        if v14_3_ then
            local v14_6_ = v14_2_.Focus
            local v14_5_ = v14_6_.p
            local v14_7_ = v14_2_.CoordinateFrame
            v14_6_ = v14_7_.p
            local v14_4_ = v14_5_ - v14_6_
            v14_3_ = v14_4_.magnitude
            v14_5_ = 2
            v14_4_ = 0
            v14_5_ = 0.500000
            if v14_4_ < v14_5_ then
                v14_4_ = 0
            end
            v14_5_ = a1.lastTransparency
            if v14_5_ then
                v14_5_ = 1
                if v14_4_ < v14_5_ then
                    v14_5_ = a1.lastTransparency
                    v14_6_ = 0.950000
                    if v14_5_ < v14_6_ then
                        v14_6_ = a1.lastTransparency
                        v14_5_ = v14_4_ - v14_6_
                        v14_7_ = 2.800000
                        v14_6_ = v14_7_ * a2
                        local v14_9_ = -v14_6_
                        local v14_8_ = v14_5_
                        local v14_10_ = v14_6_
                        local clamp = math.clamp
                        v14_7_ = clamp(v14_8_, v14_9_, v14_10_)
                        v14_5_ = v14_7_
                        v14_7_ = a1.lastTransparency
                        v14_4_ = v14_7_ + v14_5_
                    else
                        v14_5_ = true
                        a1.transparencyDirty = v14_5_
                    end
                else
                    v14_5_ = true
                    a1.transparencyDirty = v14_5_
                end
            else
                v14_5_ = true
                a1.transparencyDirty = v14_5_
            end
            v14_7_ = v0_2_
            v14_7_ = v14_4_
            local v14_8_ = 2
            v14_7_ = 0
            v14_8_ = 1
            v14_4_ = v14_5_
            v14_5_ = a1.transparencyDirty
            if not v14_5_ then
                v14_5_ = a1.lastTransparency
                if v14_5_ ~= v14_4_ then
                    v14_5_ = pairs
                    v14_6_ = a1.cachedParts
                    v14_5_, v14_6_, v14_7_ = v14_5_(v14_6_)
                    for v14_8_, v14_9_ in v14_5_, v14_6_, v14_7_ do
                        local v14_11_ = v0_0_
                        local v14_10_ = false
                        if v14_10_ then
                            v14_11_ = v0_0_
                            v14_10_ = v14_11_.AvatarGestures
                            if v14_10_ then
                                v14_10_ = {}
                                local Hat = Enum.AccessoryType.Hat
                                local v14_12_ = true
                                v14_10_[Hat] = v14_12_
                                local Hair = Enum.AccessoryType.Hair
                                v14_12_ = true
                                v14_10_[Hair] = v14_12_
                                local Face = Enum.AccessoryType.Face
                                v14_12_ = true
                                v14_10_[Face] = v14_12_
                                local Eyebrow = Enum.AccessoryType.Eyebrow
                                v14_12_ = true
                                v14_10_[Eyebrow] = v14_12_
                                local Eyelash = Enum.AccessoryType.Eyelash
                                v14_12_ = true
                                v14_10_[Eyelash] = v14_12_
                                v14_11_ = v14_8_.Parent
                                local v14_13_ = "Accessory"
                                v14_11_ = v14_11_:IsA(v14_13_)
                                if v14_11_ then
                                    v14_13_ = v14_8_.Parent
                                    v14_12_ = v14_13_.AccessoryType
                                    v14_11_ = v14_10_[v14_12_]
                                    if not v14_11_ then
                                        v14_11_ = v14_8_.Name
                                        if v14_11_ == "Head" then
                                            v14_8_.LocalTransparencyModifier = setto
                                        else
                                            v14_11_ = 0
                                            v14_8_.LocalTransparencyModifier = setto
                                            v14_8_.LocalTransparencyModifier = setto
                                        end
                                    end
                                end
                                v14_11_ = v14_8_.Name
                                if v14_11_ == "Head" then
                                    v14_8_.LocalTransparencyModifier = setto
                                else
                                    v14_11_ = 0
                                    v14_8_.LocalTransparencyModifier = setto
                                    v14_8_.LocalTransparencyModifier = setto
                                end
                            else
                                v14_8_.LocalTransparencyModifier = setto
                            end
                        else
                            v14_8_.LocalTransparencyModifier = setto
                        end
                    end
                    v14_5_ = false
                    a1.transparencyDirty = v14_5_
                    a1.lastTransparency = setto
                end
            end
            v14_5_ = pairs
            v14_6_ = a1.cachedParts
            v14_5_, v14_6_, v14_7_ = v14_5_(v14_6_)
            for v14_8_, v14_9_ in v14_5_, v14_6_, v14_7_ do
                local v14_11_ = v0_0_
                local v14_10_ = false
                if v14_10_ then
                    v14_11_ = v0_0_
                    v14_10_ = v14_11_.AvatarGestures
                    if v14_10_ then
                        v14_10_ = {}
                        local Hat = Enum.AccessoryType.Hat
                        local v14_12_ = true
                        v14_10_[Hat] = v14_12_
                        local Hair = Enum.AccessoryType.Hair
                        v14_12_ = true
                        v14_10_[Hair] = v14_12_
                        local Face = Enum.AccessoryType.Face
                        v14_12_ = true
                        v14_10_[Face] = v14_12_
                        local Eyebrow = Enum.AccessoryType.Eyebrow
                        v14_12_ = true
                        v14_10_[Eyebrow] = v14_12_
                        local Eyelash = Enum.AccessoryType.Eyelash
                        v14_12_ = true
                        v14_10_[Eyelash] = v14_12_
                        v14_11_ = v14_8_.Parent
                        local v14_13_ = "Accessory"
                        v14_11_ = v14_11_:IsA(v14_13_)
                        if v14_11_ then
                            v14_13_ = v14_8_.Parent
                            v14_12_ = v14_13_.AccessoryType
                            v14_11_ = v14_10_[v14_12_]
                            if not v14_11_ then
                                v14_11_ = v14_8_.Name
                                if v14_11_ == "Head" then
                                    v14_8_.LocalTransparencyModifier = setto
                                else
                                    v14_11_ = 0
                                    v14_8_.LocalTransparencyModifier = setto
                                    v14_8_.LocalTransparencyModifier = setto
                                end
                            end
                        end
                        v14_11_ = v14_8_.Name
                        if v14_11_ == "Head" then
                            v14_8_.LocalTransparencyModifier = setto
                        else
                            v14_11_ = 0
                            v14_8_.LocalTransparencyModifier = setto
                            v14_8_.LocalTransparencyModifier = setto
                        end
                    else
                        v14_8_.LocalTransparencyModifier = setto
                    end
                else
                    v14_8_.LocalTransparencyModifier = setto
                end
            end
            v14_5_ = false
            a1.transparencyDirty = v14_5_
            a1.lastTransparency = setto
        end
    end
end


--instant reload--
print("loading instant reload function")
instrelMODfunc = function(a1,a2)
    local function aaa(a1)
        local v27_2_ = a1.weapon
        local v27_1_ = v27_2_.Attachments
        local v27_3_ = "Magazine"
        v27_1_ = v27_1_:FindFirstChild(v27_3_)
        if v27_1_ then
            local v27_4_ = a1.weapon
            v27_3_ = v27_4_.Attachments
            v27_2_ = v27_3_.Magazine
            v27_2_ = v27_2_:GetChildren()
            v27_1_ = v27_2_[-1]
            if v27_1_ then
                v27_2_ = v27_1_.ItemProperties
                v27_4_ = "LoadedAmmo"
                v27_2_ = v27_2_:GetAttribute(v27_4_)
                a1.Bullets = v27_2_
                v27_2_ = {}
                a1.BulletsList = v27_2_
                v27_3_ = v27_1_.ItemProperties
                v27_2_ = v27_3_.LoadedAmmo
                v27_3_ = v27_2_:GetChildren()
                local v27_6_ = 1
                v27_4_ = #v27_3_
                local v27_5_ = 1
                for v27_6_ = v27_6_, v27_4_, v27_5_ do
                    local v27_7_ = a1.BulletsList
                    local v27_10_ = v27_3_[v27_6_]
                    local v27_9_ = v27_10_.Name
                    local v27_8_ = tonumber
                    v27_8_ = v27_8_(v27_9_)
                    v27_9_ = {}
                    v27_10_ = v27_3_[v27_6_]
                    local v27_12_ = "AmmoType"
                    v27_10_ = v27_10_:GetAttribute(v27_12_)
                    v27_9_.AmmoType = v27_10_
                    v27_10_ = v27_3_[v27_6_]
                    v27_12_ = "Amount"
                    v27_10_ = v27_10_:GetAttribute(v27_12_)
                    v27_9_.Amount = v27_10_
                    v27_7_[v27_8_] = v27_9_
                end
            end
            v27_2_ = 0
            a1.movementModifier = v27_2_
            v27_2_ = a1.weapon
            if v27_2_ then
                v27_2_ = a1.movementModifier
                local v27_6_ = a1.weapon
                local v27_5_ = v27_6_.ItemProperties
                v27_4_ = v27_5_.Tool
                v27_6_ = "MovementModifer"
                v27_4_ = v27_4_:GetAttribute(v27_6_)
                v27_3_ = v27_4_ or 0.000000
                v27_2_ += v27_3_
                a1.movementModifier = v27_2_
                v27_2_ = a1.weapon
                v27_4_ = "Attachments"
                v27_2_ = v27_2_:FindFirstChild(v27_4_)
                if v27_2_ then
                    v27_3_ = a1.weapon
                    v27_2_ = v27_3_.Attachments
                    v27_2_ = v27_2_:GetChildren()
                    v27_5_ = 1
                    v27_3_ = #v27_2_
                    v27_4_ = 1
                    for v27_5_ = v27_5_, v27_3_, v27_4_ do
                        v27_6_ = v27_2_[v27_5_]
                        local v27_8_ = "StringValue"
                        v27_6_ = v27_6_:FindFirstChildOfClass(v27_8_)
                        if v27_6_ then
                            local v27_7_ = v27_6_.ItemProperties
                            local v27_9_ = "Attachment"
                            v27_7_ = v27_7_:FindFirstChild(v27_9_)
                            if v27_7_ then
                                v27_7_ = a1.movementModifier
                                local v27_10_ = v27_6_.ItemProperties
                                v27_9_ = v27_10_.Attachment
                                local v27_11_ = "MovementModifer"
                                v27_9_ = v27_9_:GetAttribute(v27_11_)
                                v27_8_ = v27_9_ or 0.000000
                                v27_7_ += v27_8_
                                a1.movementModifier = v27_7_
                            end
                        end
                        return
                    end
                end
            end
        end
        v27_2_ = a1.weapon
        v27_1_ = v27_2_.ItemProperties
        v27_3_ = "LoadedAmmo"
        v27_1_ = v27_1_:GetAttribute(v27_3_)
        a1.Bullets = v27_1_
        v27_1_ = {}
        a1.BulletsList = v27_1_
        v27_3_ = a1.weapon
        v27_2_ = v27_3_.ItemProperties
        v27_1_ = v27_2_.LoadedAmmo
        v27_2_ = v27_1_:GetChildren()
        local v27_5_ = 1
        v27_3_ = #v27_2_
        local v27_4_ = 1
        for v27_5_ = v27_5_, v27_3_, v27_4_ do
            local v27_6_ = a1.BulletsList
            local v27_9_ = v27_2_[v27_5_]
            local v27_8_ = v27_9_.Name
            local v27_7_ = tonumber
            v27_7_ = v27_7_(v27_8_)
            v27_8_ = {}
            v27_9_ = v27_2_[v27_5_]
            local v27_11_ = "AmmoType"
            v27_9_ = v27_9_:GetAttribute(v27_11_)
            v27_8_.AmmoType = v27_9_
            v27_9_ = v27_2_[v27_5_]
            v27_11_ = "Amount"
            v27_9_ = v27_9_:GetAttribute(v27_11_)
            v27_8_.Amount = v27_9_
            v27_6_[v27_7_] = v27_8_
        end
    end
    local v103_2_ = a1.viewModel
    if v103_2_ then
        local v103_3_ = a1.viewModel
        v103_2_ = v103_3_.Item
        local v103_4_ = "AmmoTypes"
        v103_2_ = v103_2_:FindFirstChild(v103_4_)
        if v103_2_ then
            local v103_5_ = a1.weapon
            v103_4_ = v103_5_.ItemProperties
            v103_3_ = v103_4_.AmmoType
            v103_2_ = v103_3_.Value
            v103_5_ = a1.viewModel
            v103_4_ = v103_5_.Item
            v103_3_ = v103_4_.AmmoTypes
            v103_3_ = v103_3_:GetChildren()
            local v103_6_ = 1
            v103_4_ = #v103_3_
            v103_5_ = 1
            for v103_6_ = v103_6_, v103_4_, v103_5_ do
                local v103_7_ = v103_3_[v103_6_]
                local v103_8_ = 1
                v103_7_.Transparency = v103_8_
            end
            v103_6_ = a1.viewModel
            v103_5_ = v103_6_.Item
            v103_4_ = v103_5_.AmmoTypes
            v103_6_ = v103_2_
            v103_4_ = v103_4_:FindFirstChild(v103_6_)
            v103_5_ = 0
            v103_4_.Transparency = v103_5_
            v103_5_ = a1.viewModel
            v103_4_ = v103_5_.Item
            v103_6_ = "AmmoTypes2"
            v103_4_ = v103_4_:FindFirstChild(v103_6_)
            if v103_4_ then
                v103_6_ = a1.viewModel
                v103_5_ = v103_6_.Item
                v103_4_ = v103_5_.AmmoTypes2
                v103_4_ = v103_4_:GetChildren()
                local v103_7_ = 1
                v103_5_ = #v103_4_
                v103_6_ = 1
                for v103_7_ = v103_7_, v103_5_, v103_6_ do
                    local v103_8_ = v103_4_[v103_7_]
                    local v103_9_ = 1
                    v103_8_.Transparency = v103_9_
                end
                v103_7_ = a1.viewModel
                v103_6_ = v103_7_.Item
                v103_5_ = v103_6_.AmmoTypes2
                v103_7_ = v103_2_
                v103_5_ = v103_5_:FindFirstChild(v103_7_)
                v103_6_ = 0
                v103_5_.Transparency = v103_6_
            end
        end
        v103_2_ = a1.reloading
        if v103_2_ == false then
            v103_2_ = a1.cancellingReload
            if v103_2_ == false then
                v103_2_ = a1.MaxAmmo
                v103_3_ = 0
                if v103_3_ < v103_2_ then
                    v103_3_ = true
                    local v103_6_ = 1
                    local v103_7_ = a1.CancelTables
                    v103_4_ = #v103_7_
                    local v103_5_ = 1
                    for v103_6_ = v103_6_, v103_4_, v103_5_ do
                        local v103_9_ = a1.CancelTables
                        local v103_8_ = v103_9_[v103_6_]
                        v103_7_ = v103_8_.Visible
                        if v103_7_ == true then
                            v103_3_ = false
                        else
                        end
                    end
                    v103_2_ = v103_3_
                    if v103_2_ then
                        v103_3_ = a1.clientAnimationTracks
                        v103_2_ = v103_3_.Inspect
                        if v103_2_ then
                            v103_3_ = a1.clientAnimationTracks
                            v103_2_ = v103_3_.Inspect
                            v103_2_:Stop()
                            v103_3_ = a1.serverAnimationTracks
                            v103_2_ = v103_3_.Inspect
                            v103_2_:Stop()
                            v103_4_ = a1.WeldedTool
                            v103_3_ = v103_4_.ItemRoot
                            v103_2_ = v103_3_.Sounds.Inspect
                            v103_2_:Stop()
                        end
                        v103_3_ = a1.settings
                        v103_2_ = v103_3_.AimWhileActing
                        if not v103_2_ then
                            v103_2_ = a1.isAiming
                            if v103_2_ then
                                v103_4_ = false
                                a1:aim(v103_4_)
                            end
                        end
                        
                        if a1.reloadType == "loadByHand" then
                            local count = a1.Bullets
                            local maxcount = a1.MaxAmmo

                            for i=count, maxcount do 
                                game.ReplicatedStorage.Remotes.Reload:InvokeServer(nil, 0.001, nil)
                            end

                            aaa(a1)
                        else
                            game.ReplicatedStorage.Remotes.Reload:InvokeServer(nil, 0.001, nil)

                            require(game.ReplicatedStorage.Modules.FPS).equip(a1, a1.weapon, nil)

                            aaa(a1)
                        end      
                    end
                end
            end
        end
    end
end

--instant lean--
print("loading instant lean functions")
instantleanMODfunc = function(a1,a2,a3)
    --a1 = player table 
    if a2 == 0 then 
        if a1.lean == 0 then return end
    end
    carv_9X7Z = a1.rs_Vehicle.CurrentSeat.Value
    if carv_9X7Z then 
        if a1.lean == 0 then return end
    end
    if a1.humanoid:GetState() == Enum.HumanoidStateType.Swimming then 
        if a1.lean == 0 then return end
    end
    if a1.sprinting == true then 
        if a1.lean == 0 then return end
    end
    
    if a2 == a1.lean then 
        a1.lean = 0
    else 
        a1.lean = a2
    end
    
    springs_R2D2 = a1.springs
    lalpha_C3PO = springs_R2D2.leanAlpha
    springs_R2D2.leanAlpha.Speed = 15
    currentlean_BB8 = a1.lean
    vectorposidk_VADER = Vector3.new(-currentlean_BB8, 0,0)
    lalpha_C3PO.Target = vectorposidk_VADER
    valuetoserver_YODA = nil
    
    if lalpha_C3PO.Target.X == 1 then 
        valuetoserver_YODA = true
    elseif lalpha_C3PO.Target.X == -1 then
        valuetoserver_YODA = false
    end

    game.ReplicatedStorage.Remotes.UpdateLeaning:FireServer(valuetoserver_YODA)
end
instantleanOGfunc = function(a1,a2,a3)
    --a1 = player table 
    if a2 == 0 then 
        if a1.lean == 0 then return end
    end
    carv_9X7Z = a1.rs_Vehicle.CurrentSeat.Value
    if carv_9X7Z then 
        if a1.lean == 0 then return end
    end
    if a1.humanoid:GetState() == Enum.HumanoidStateType.Swimming then 
        if a1.lean == 0 then return end
    end
    if a1.sprinting == true then 
        if a1.lean == 0 then return end
    end
    
    if a2 == a1.lean then 
        a1.lean = 0
    else 
        a1.lean = a2
    end
    
    springs_R2D2 = a1.springs
    lalpha_C3PO = springs_R2D2.leanAlpha
    springs_R2D2.leanAlpha.Speed = 5
    currentlean_BB8 = a1.lean
    vectorposidk_VADER = Vector3.new(-currentlean_BB8, 0,0)
    lalpha_C3PO.Target = vectorposidk_VADER
    valuetoserver_YODA = nil
    
    if lalpha_C3PO.Target.X == 1 then 
        valuetoserver_YODA = true
    elseif lalpha_C3PO.Target.X == -1 then
        valuetoserver_YODA = false
    end

    game.ReplicatedStorage.Remotes.UpdateLeaning:FireServer(valuetoserver_YODA)
end


--hitsound-- hitsound method by ds: _hai_hai
print("loading hitsound")
localplayer.CharacterAdded:Connect(function(lchar)
    if localplayer.PlayerGui:WaitForChild("MainGui") then
        localplayer.PlayerGui.MainGui.ChildAdded:Connect(function(Sound)
            if Sound:IsA("Sound") and allvars.hitsoundbool then
                if Sound.SoundId == "rbxassetid://4585351098" or Sound.SoundId == "rbxassetid://4585382589" then --headshot
                    Sound.SoundId = hitsoundlib[allvars.hitsoundhead]
                elseif Sound.SoundId == "rbxassetid://4585382046" or Sound.SoundId == "rbxassetid://4585364605" then --bodyshot
                    Sound.SoundId = hitsoundlib[allvars.hitsoundbody]
                end
            end
        end)
    end
end)
localplayer.PlayerGui.MainGui.ChildAdded:Connect(function(Sound)
    if Sound:IsA("Sound") and allvars.hitsoundbool then
        if Sound.SoundId == "rbxassetid://4585351098" or Sound.SoundId == "rbxassetid://4585382589" then --headshot
            Sound.SoundId = hitsoundlib[allvars.hitsoundhead]
        elseif Sound.SoundId == "rbxassetid://4585382046" or Sound.SoundId == "rbxassetid://4585364605" then --bodyshot
            Sound.SoundId = hitsoundlib[allvars.hitsoundbody]
        end
    end
end)


--esp map--
print("loading espmap function")
handleESPMAP = function(bool)
    if bool then
        map = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.Maps.EstonianBorderMap
        mapFrame = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame
        mapFrame.Size = UDim2.fromScale(1, 1)
        mapFrame.Position = UDim2.new(0.5, 0, 0.49, 0)

        mapFrame.Parent.Visible = true
        game.UserInputService.MouseIconEnabled = true
        game.Players.LocalPlayer.PlayerGui.MainGui.ModalButton.Modal = true

        for _,v in ipairs(mapFrame.Markers:GetChildren()) do
            v:Destroy()
        end

        selfMarker = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.MarkerDotTemplate:Clone()
        selfMarker.Name = "SelfMarker"
        selfMarker.Visible = true
        selfMarker.Parent = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.Markers
        selfMarker.TextLabel.Visible = true
        espmapmarkers.Me = {
            playerRef = game.Players.LocalPlayer,
            markerRef = selfMarker,
        }

        for _,v in ipairs(game.Players:GetChildren()) do
            if v ~= localplayer then
                plrMarker = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.MarkerDotTemplate:Clone()
                plrMarker.ImageColor3 = Color3.fromRGB(227, 36, 36)
                plrMarker.Name = "TeamMarker"
                plrMarker.Visible = true
                plrMarker.TextLabel.Text = v.Name
                plrMarker.TextLabel.Visible = true
                plrMarker.TextLabel.Size = UDim2.fromScale(2, 0.5)
                plrMarker.TextLabel.Position = UDim2.fromScale(-0.5, 0)
                plrMarker.Parent = game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.MainFrame.Markers
                espmapmarkers[v.Name] = {
                    playerRef = v,
                    markerRef = plrMarker,
                }
            end
        end
        
        task.spawn(function()
            while task.wait(0.1) do
                if espmapactive == false then return end

                for ind, markerData in espmapmarkers do
                    if markerData.markerRef == nil then
                        table.remove(espmapmarkers, ind)
                    else
                        local playerRef = markerData.playerRef
                        if playerRef then
                            local character = playerRef.Character
                            if character then
                                local chpos = game.ReplicatedStorage.Players:FindFirstChild(playerRef.Name).Status.UAC:GetAttribute("LastVerifiedPos")
                                local xPos = (chpos.X - 208) / map:GetAttribute("SizeReal")
                                local zPos = (chpos.Z + 203) / map:GetAttribute("SizeReal")
                                markerData.markerRef.Position = UDim2.new(0.5 + xPos, 0, 0.5 + zPos, 0)
                                markerData.markerRef.Visible = true
                                if markerData.playerRef ~= localplayer then 
                                    if table.find(allvars.aimFRIENDLIST, markerData.playerRef.Name) ~= nil then
                                        markerData.markerRef.ImageColor3 = Color3.fromRGB(102, 245, 66)
                                    else
                                        markerData.markerRef.ImageColor3 = Color3.fromRGB(227, 36, 36)
                                    end
                                end
                            else
                                markerData.markerRef.Visible = false
                            end
                        end
                    end
                end
            end
        end)

        mapFrame.Markers.Visible = true
    else
        if game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.Visible == true then
            game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.MapFrame.Visible = false
            game.Players.LocalPlayer.PlayerGui.MainGui.ModalButton.Modal = false
            game.UserInputService.MouseIconEnabled = false
        end
    end
end


-- semi fly --
print("loading semifly functions")
function fly_move(dir)
    local hrp = localplayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

	local newPos = hrp.CFrame + (dir * 1)
	hrp.CFrame = newPos
end
function fly_getclosestpoint()
    local hrp = localplayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

	local dirs = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 1, 0),
        Vector3.new(0, -1, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
        Vector3.new(1, 1, 0),
        Vector3.new(1, -1, 0),
        Vector3.new(-1, 1, 0),
        Vector3.new(-1, -1, 0),
        Vector3.new(1, 0, 1),
        Vector3.new(1, 0, -1),
        Vector3.new(-1, 0, 1),
        Vector3.new(-1, 0, -1),
        Vector3.new(0, 1, 1),
        Vector3.new(0, 1, -1),
        Vector3.new(0, -1, 1),
        Vector3.new(0, -1, -1),
        Vector3.new(1, 1, 1),
        Vector3.new(1, 1, -1),
        Vector3.new(1, -1, 1),
        Vector3.new(1, -1, -1),
        Vector3.new(-1, 1, 1),
        Vector3.new(-1, 1, -1),
        Vector3.new(-1, -1, 1),
        Vector3.new(-1, -1, -1)
    }

	local fcp = nil
	local cd = math.huge

    local ignorl = {localplayer.Character, wcamera}

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character then
            table.insert(ignorl, player.Character)
        end
    end

	for _, dir in ipairs(dirs) do
		local ray = Ray.new(hrp.Position, dir * 200)
		local part, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignorl)
		if part and pos then
			local d = (hrp.Position - pos).Magnitude
			if d < cd then
				cd = d
				fcp = pos
			end
		end
	end

	return fcp
end
function fly_getoffset(dir)
	local offset = Vector3.new(0.1, 0.1, 0.1)
	if dir.X > 0 then
		offset = Vector3.new(0.1, 0, 0)
	elseif dir.X < 0 then
		offset = Vector3.new(-0.1, 0, 0)
	elseif dir.Y > 0 then
		offset = Vector3.new(0, 0.1, 0)
	elseif dir.Y < 0 then
		offset = Vector3.new(0, -0.1, 0)
	elseif dir.Z > 0 then
		offset = Vector3.new(0, 0, 0.1)
	elseif dir.Z < 0 then
		offset = Vector3.new(0, 0, -0.1)
	end
	return offset
end

--anticheat bypass--
print("loading client anticheat bypass")  --method by discord.gg/exothium
function handleClientAntiCheatBypass()
    if ACBYPASS_SYNC == true then return end

    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        if Method == "FireServer" and self.Name == "ProjectileInflict" then
            if Args[1] == game.Players.LocalPlayer.Character.PrimaryPart then
                return coroutine.yield()
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)

    ACBYPASS_SYNC = true
end
handleClientAntiCheatBypass()


--selftrack(ping check)
print("loading ping check")
for i = 10, 1000, 10 do
    --selftrack_data[i] = localplayer.Character.Head.Position
    table.insert(selftrack_data, {ms = i, vpos = localplayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)})
end
local function updateselfpos()
    for i = #selftrack_data, 1, -1 do
        selftrack_data[i].ms = selftrack_data[i].ms + 10
    end
    if selftrack_data[#selftrack_data].ms > 1000 then
        table.remove(selftrack_data, #selftrack_data)
    end
    table.insert(selftrack_data, 1, {ms = 10, vpos = localplayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)})
end


--thirdperson fix + desync camera fix--
local function ThirdPersonFix()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(self, index, value)
        if tostring(self) == "Humanoid" and index == "CameraOffset" then
            local offset = Vector3.zero

            if allvars.desyncbool then
                if allvars.desyncPos then
                    offset += Vector3.new(-allvars.desynXp, -allvars.desynYp, -allvars.desynZp)
                end
                if allvars.desyncOr then
                    -- to make
                end
            end

            if allvars.camthirdp then
                offset += Vector3.new(allvars.camthirdpX, allvars.camthirdpY, allvars.camthirdpZ)
            end

            return oldIndex(self, index, offset)
        end
        return oldIndex(self, index, value)
    end)
    setreadonly(mt, true)
end
ThirdPersonFix()


--double jump--
uis.JumpRequest:Connect(function()
    if not allvars.doublejump then return end
    
    local ctime = tick()
    if ctime - dbjumplast < dbjumpdelay then return end
    
    local state = localplayer.Character.Humanoid:GetState()
    if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
        if candbjump then
            localplayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            candbjump = false
            dbjumplast = ctime
        end
    end
end)
localplayer.Character.Humanoid.StateChanged:Connect(function(_, state)
    if not allvars.doublejump then return end
    
    if state == Enum.HumanoidStateType.Jumping then
        candbjump = true
        dbjumplast = tick()
    elseif state == Enum.HumanoidStateType.Landed then
        candbjump = false
    end
end)
localplayer.CharacterAdded:Connect(function()
    task.wait(1.5)

    localplayer.Character.Humanoid.StateChanged:Connect(function(_, state)
        if not allvars.doublejump then return end
        
        if state == Enum.HumanoidStateType.Jumping then
            candbjump = true
            dbjumplast = tick()
        elseif state == Enum.HumanoidStateType.Landed then
            candbjump = false
        end
    end)
end)


--upangle editor--
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if Method == "FireServer" and self.Name == "UpdateTilt" then
        if allvars.upanglebool then
            Args[1] = allvars.upanglenum
            return oldNamecall(self, table.unpack(Args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)


--fps table editor--
print("loading fps table editor")
do
    local mod = require(game.ReplicatedStorage.Modules.FPS)
    local ogfunc = mod.updateClient

    mod.updateClient = function(a1,a2,a3)
        arg1, arg2, arg3 = ogfunc(a1,a2,a3)
        
        a1table = a1
        
        if allvars.noswaybool then
            a1.springs.sway.Position = Vector3.new(0,0,0)
            a1.springs.walkCycle.Position = Vector3.new(0,0,0)
            a1.springs.sprintCycle.Position = Vector3.new(0,0,0)
            a1.springs.strafeTilt.Position = Vector3.new(0,0,0)
            a1.springs.jumpTilt.Position = Vector3.new(0,0,0)
            a1.springs.sway.Speed = 0
            a1.springs.walkCycle.Speed = 0
            a1.springs.sprintCycle.Speed = 0
            a1.springs.strafeTilt.Speed = 0
            a1.springs.jumpTilt.Speed = 0
        else
            a1.springs.sway.Speed = 4
            a1.springs.walkCycle.Speed = 4
            a1.springs.sprintCycle.Speed = 4
            a1.springs.strafeTilt.Speed = 4
            a1.springs.jumpTilt.Speed = 4
        end
        if allvars.viewmodoffset then
            a1.sprintIdleOffset = CFrame.new(Vector3.new(allvars.viewmodX, allvars.viewmodY, allvars.viewmodZ))
            a1.weaponOffset = CFrame.new(Vector3.new(allvars.viewmodX, allvars.viewmodY, allvars.viewmodZ))
            a1.AimInSpeed = 9e9
        else
            a1.AimInSpeed = 0.4
        end

        return arg1, arg2, arg3
    end
end


--skin changer--
print("loading skinchanger")
function createskinchangergui()
    local a, b
    a = Instance.new"Frame"
    a.Name = "SkinMain"
    a.Size = UDim2.new(0.193, 0, 0.478, 0)
    a.BorderColor3 = Color3.fromRGB(0, 0, 0)
    a.Position = UDim2.new(0.709, 0, 0.499, 0)
    a.BorderSizePixel = 0
    a.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    a.AnchorPoint = Vector2.new(0, 0.5)
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.03, 0)
    b.Parent = a
    b = Instance.new"Frame"
    b.Name = "Title"
    b.Size = UDim2.new(0.9995077, 0, 0.0345098, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.8
    b.Position = UDim2.new(3e-07, 0, 0, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.Parent = a
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.5, 0)
    b.Parent = a.Title
    b = Instance.new"TextLabel"
    b.Name = "Label"
    b.Size = UDim2.new(1, 0, 0.8636364, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0, 0, 0.0950089, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.FontSize = 5
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "Skin Changer v0.1"
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextScaled = true
    b.Parent = a.Title
    b = Instance.new"Frame"
    b.Name = "Guns"
    b.Size = UDim2.new(0.9502814, 0, 0.4, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.85
    b.Position = UDim2.new(0.0235427, 0, 0.0972549, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.Parent = a
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.03, 0)
    b.Parent = a.Guns
    b = Instance.new"ScrollingFrame"
    b.Name = "Bar"
    b.Size = UDim2.new(0.9414414, 0, 0.9058824, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0.0292793, 0, 0.0509804, 0)
    b.Active = true
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.ScrollingDirection = 2
    b.CanvasSize = UDim2.new(0, 0, 1, 0)
    b.ScrollBarThickness = 4
    b.Parent = a.Guns
    b = Instance.new"UIListLayout"
    b.SortOrder = 2
    b.Wraps = true
    b.HorizontalFlex = 1
    b.VerticalFlex = 1
    b.Padding = UDim.new(0.005, 0)
    b.Parent = a.Guns.Bar
    b = Instance.new"TextLabel"
    b.Name = "GunsLabel"
    b.Size = UDim2.new(0.8946342, 0, 0.0407843, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0.0513673, 0, 0.0454902, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.FontSize = 5
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "Your guns : "
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextScaled = true
    b.Parent = a
    b = Instance.new"Frame"
    b.Name = "Skins"
    b.Size = UDim2.new(0.9502814, 0, 0.4188235, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 0.85
    b.Position = UDim2.new(0.0235427, 0, 0.5631372, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.Parent = a
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.03, 0)
    b.Parent = a.Skins
    b = Instance.new"ScrollingFrame"
    b.Name = "Bar"
    b.Size = UDim2.new(0.9414414, 0, 0.9058824, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0.0292793, 0, 0.0509804, 0)
    b.Active = true
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.ScrollingDirection = 2
    b.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    b.ScrollBarThickness = 4
    b.Parent = a.Skins
    b = Instance.new"UIListLayout"
    b.SortOrder = 2
    b.Wraps = true
    b.HorizontalFlex = 1
    b.VerticalFlex = 1
    b.Padding = UDim.new(0.005, 0)
    b.Parent = a.Skins.Bar
    b = Instance.new"TextLabel"
    b.Name = "SkinsLabel"
    b.Size = UDim2.new(0.8946342, 0, 0.0407843, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0.0513673, 0, 0.5129412, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.FontSize = 5
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "Available skins (For None) : "
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextScaled = true
    b.Parent = a
    b = Instance.new"UIStroke"
    b.ApplyStrokeMode = 1
    b.Thickness = 3.5999999
    b.Color = Color3.fromRGB(75, 118, 197)
    b.Parent = a
    b = Instance.new"Configuration"
    b.Name = "Templates"
    b.Parent = a
    b = Instance.new"Frame"
    b.Name = "SkinTemplate"
    b.Size = UDim2.new(0, 411, 0, 55)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
    b.Parent = a.Templates
    b = Instance.new"TextLabel"
    b.Name = "SkinName"
    b.Size = UDim2.new(0.5425791, 0, 0.6363636, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0.0358852, 0, 0.1794467, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.FontSize = 5
    b.TextStrokeTransparency = 0
    b.TextSize = 14
    b.RichText = true
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "White Death"
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextXAlignment = 0
    b.TextScaled = true
    b.Parent = a.Templates.SkinTemplate
    b = Instance.new"TextButton"
    b.Name = "Set"
    b.Size = UDim2.new(0.377129, 0, 0.6363636, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.Position = UDim2.new(0.5926771, 0, 0.1794467, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(135, 255, 92)
    b.FontSize = 5
    b.TextStrokeTransparency = 0
    b.TextSize = 14
    b.RichText = true
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "Set"
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextScaled = true
    b.Parent = a.Templates.SkinTemplate
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.2, 0)
    b.Parent = a.Templates.SkinTemplate.Set
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.1, 0)
    b.Parent = a.Templates.SkinTemplate
    b = Instance.new"UIAspectRatioConstraint"
    b.AspectRatio = 7.3200002
    b.DominantAxis = 1
    b.Parent = a.Templates.SkinTemplate
    b = Instance.new"Frame"
    b.Name = "GunTemplate"
    b.Size = UDim2.new(0, 411, 0, 55)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
    b.Parent = a.Templates
    b = Instance.new"TextLabel"
    b.Name = "GunName"
    b.Size = UDim2.new(0.5425791, 0, 0.6363636, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0.0358852, 0, 0.1794467, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    b.FontSize = 5
    b.TextStrokeTransparency = 0
    b.TextSize = 14
    b.RichText = true
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "TFZ98"
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextXAlignment = 0
    b.TextScaled = true
    b.Parent = a.Templates.GunTemplate
    b = Instance.new"TextButton"
    b.Name = "Select"
    b.Size = UDim2.new(0.377129, 0, 0.6363636, 0)
    b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.Position = UDim2.new(0.5926771, 0, 0.1794467, 0)
    b.BorderSizePixel = 0
    b.BackgroundColor3 = Color3.fromRGB(135, 255, 92)
    b.FontSize = 5
    b.TextStrokeTransparency = 0
    b.TextSize = 14
    b.RichText = true
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Text = "Select"
    b.TextWrapped = true
    b.TextWrap = true
    b.Font = 100
    b.TextScaled = true
    b.Parent = a.Templates.GunTemplate
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.2, 0)
    b.Parent = a.Templates.GunTemplate.Select
    b = Instance.new"UICorner"
    b.Archivable = false
    b.CornerRadius = UDim.new(0.1, 0)
    b.Parent = a.Templates.GunTemplate
    b = Instance.new"UIAspectRatioConstraint"
    b.AspectRatio = 7.3200002
    b.DominantAxis = 1
    b.Parent = a.Templates.GunTemplate
    return a
end
function sc_setskin(skin)
    local gun = scselected
    gun.ItemProperties:SetAttribute("Skin", skin.Name)

    for _,att in ipairs(gun.Attachments:GetDescendants()) do
        if att:IsA("StringValue") and att:FindFirstChild("ItemProperties") then
            att.ItemProperties:SetAttribute("Skin", skin.Name)
        end
    end
end
function sc_additem(gui, obj, itemtype)
    if itemtype == "Skin" then
        local temp = gui.Templates.SkinTemplate:Clone()
        temp.Name = obj.Name
        temp.SkinName.Text = obj.name
        temp.Parent = gui.Skins.Bar
        temp.Set.Activated:Connect(function()
            sc_setskin(obj)
            Notify("Skin Changer", "Set " .. scselected.Name .. " skin to " .. obj.Name)
        end)
    else
        local temp = gui.Templates.GunTemplate:Clone()
        temp.Name = obj.Name
        temp.GunName.Text = obj.name
        temp.Parent = gui.Guns.Bar
        temp.Select.Activated:Connect(function()
            scselected = obj
            sc_loadskins(gui, obj)
        end)
    end
end
function sc_removeitem(gui, gunname)
    if scselected ~= nil and scselected.Name == gunname then
        scselected = nil
        sc_clearskins(gui)
    end
    local gunitem = gui.Guns.Bar:FindFirstChild(gunname)
    if gunitem then
        gunitem:Destroy()
    end
end
function sc_clearskins(gui)
    for _,delet in ipairs(gui.Skins.Bar:GetChildren()) do
        if delet:IsA("Frame") then  
            delet:Destroy()
        end
    end
end
function sc_loadskins(gui, gun)
    sc_clearskins(gui)

    local skinsfold = game.ReplicatedStorage.Skins:FindFirstChild(gun.Name)
    if skinsfold then
        for _, skin in ipairs(skinsfold:GetChildren()) do
            sc_additem(gui, skin, "Skin")
        end
    end
end
function skinchangerhandler()
    local skingui = createskinchangergui()
    skingui.Visible = false
    skingui.Parent = library.GUI
    scgui = skingui

    for _,gun in ipairs(game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory:GetChildren()) do
        sc_additem(skingui, gun, "Gun")
    end

    game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory.ChildAdded:Connect(function(child)
        sc_additem(skingui, child, "Gun")
    end)
    game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory.ChildRemoved:Connect(function(child)
        sc_removeitem(skingui, child.Name)
    end)
end
skinchangerhandler()


--global cycle--
print("loading global cycles")

task.spawn(function() -- very slow
    while wait(10.5) do
        table.clear(aimignoreparts)
        for i,v in ipairs(workspace:GetDescendants()) do
            if v:GetAttribute("PassThrough") then
                table.insert(aimignoreparts, v)
            elseif allvars.worldnomines and v.Name == "PMN2" and v:IsA("Model") then
                v:Destroy()
            end
        end
    end
end)

task.spawn(function() -- slow
    while wait(1) do
        invchecktext.Position = Vector2.new(30, (wcamera.ViewportSize.Y / 2) - 230) --on screen stuff

        if scselected ~= nil and scgui ~= nil then
            scgui.SkinsLabel.Text = "Available skins (For ".. scselected.Name.." ) : "
        else
            scgui.SkinsLabel.Text = "Available skins (For None) : "
        end

        local function handleModDetect()
            if allvars.detectmods then
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if detectedmods[player.Name] ~= nil then continue end

                    local pinfo = game.ReplicatedStorage.Players:FindFirstChild(player.Name)
                    if not pinfo then continue end
                    local status = pinfo:FindFirstChild("Status")
                    if not status then continue end

                    local function detectmod(plrname, reason)
                        detectedmods[plrname] = true
                        if mdetect == true then return end
                        mdetect = true

                        Notify("Mod Detected", reason.." ( ".. plrname .." ) ")
                        local notsound = Instance.new("Sound")
                        notsound.SoundId = "rbxassetid://1841354443"
                        notsound.Parent = workspace
                        notsound:Play()
                        
                        allvars.espexit = true
                        Notify("Extract ESP Enabled", "due to moderator")
                    end

                    if status.UAC:GetAttribute("Enabled") == true then
                        detectmod(player.Name, "uac enabled")
                        continue
                    elseif status.GameplayVariables:GetAttribute("Godmode") == true then
                        detectmod(player.Name, "godmode enabled")
                        continue
                    elseif status.GameplayVariables:GetAttribute("PremiumLevel") >= 4 then
                        detectmod(player.Name, "premium level >= 4")
                        continue
                    elseif status.UAC:GetAttribute("A1Detected") == true then
                        detectmod(player.Name, "A1Detected")
                        continue
                    elseif status.UAC:GetAttribute("A2Detected") == true then
                        detectmod(player.Name, "A2Detected")
                        continue
                    elseif status.UAC:GetAttribute("A3Detected") == true then
                        detectmod(player.Name, "A3Detected")
                        continue
                    end
                end
            end
        end

        local function handleAntiMask()
            if allvars.antimaskbool == true then
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(0,0,1,0)
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(0,0,1,0)
                for i,v in ipairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
                    v.Size = UDim2.new(0,0,1,0)
                end
            else
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.HelmetMask.TitanShield.Size = UDim2.new(1,0,1,0)
                game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Mask.GP5.Size = UDim2.new(1,0,1,0)
                for i,v in ipairs(game.Players.LocalPlayer.PlayerGui.MainGui.MainFrame.ScreenEffects.Visor:GetChildren()) do
                    v.Size = UDim2.new(1,0,1,0)
                end
            end
        end

        local function handleRespawn()
            if localplayer.Character and localplayer.Character:FindFirstChild("Humanoid") and localplayer.Character.Humanoid.Health <= 0 and allvars.instantrespawn == true then
                localplayer.PlayerGui.RespawnMenu.Enabled = false
                game.ReplicatedStorage.Remotes.SpawnCharacter:InvokeServer()
            elseif allvars.instantrespawn == false then
                localplayer.PlayerGui.RespawnMenu.Enabled = true
            else
                localplayer.PlayerGui.RespawnMenu.Enabled = false
                game.ReplicatedStorage.Remotes.SpawnCharacter:InvokeServer()
            end
        end

        local function handleFoliage()
            if not folcheck then return end 
            for _, v in pairs(folcheck.Foliage:GetDescendants()) do
                if v:FindFirstChildOfClass("SurfaceAppearance") then
                    v.Transparency = allvars.worldleaves and 1 or 0
                end
            end
        end

        local function handleInventory()
            local offset = CFrame.new(Vector3.new(allvars.viewmodX, allvars.viewmodY, allvars.viewmodZ))
            if not offset then return end

            local inv = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Inventory
            local eq = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Equipment
            local cloth = game.ReplicatedStorage.Players:FindFirstChild(localplayer.Name).Clothing
            if not inv then return end
            if not eq then return end
            if not cloth then return end

            for _, v in pairs(inv:GetChildren()) do
                if not v:FindFirstChild("SettingsModule") then return end
                local sett = require(v.SettingsModule)
                if allvars.viewmodoffset then
                    sett.weaponOffSet = offset
                end
                if allvars.rapidfire then
                    sett.FireRate = allvars.crapidfire and allvars.crapidfirenum or 0.001
                end
                if allvars.unlockmodes then
                    sett.FireModes = {"Auto", "Semi"}
                end
            end

            for _, v in pairs(eq:GetChildren()) do
                if not v:FindFirstChild("SettingsModule") then return end
                local sett = require(v.SettingsModule)
                if allvars.viewmodoffset then
                    sett.weaponOffSet = offset
                end
            end
        end

        local function handleViewModel()
            if allvars.viewmodbool and wcamera:FindFirstChild("ViewModel") then
                for _, obj in pairs(wcamera.ViewModel:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        if not obj:FindFirstAncestor("Item") then
                            local mb = obj:FindFirstChildOfClass("SurfaceAppearance")
                            if mb then
                                mb:Destroy()
                            end

                            obj.Color = allvars.viewmodhandcolor
                            obj.Material = allvars.viewmodhandmat
                        else
                            local mb = obj:FindFirstChildOfClass("SurfaceAppearance")
                            if mb then
                                mb:Destroy()
                            end

                            obj.Color = allvars.viewmodguncolor
                            obj.Material = allvars.viewmodgunmat
                        end
                    elseif obj:IsA("Model") and obj:FindFirstChild("LL") then
                        obj:Destroy()
                    end
                end
            end
        end

        handleRespawn()
        handleFoliage()
        handleInventory()
        handleViewModel()
        handleAntiMask()
        pcall(handleModDetect)
    end
end)

local fpsrequired = require(game.ReplicatedStorage.Modules.FPS)
runs.Heartbeat:Connect(function(delta) --silent aim + trigger bot fast cycle
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") or not localplayer.Character:FindFirstChild("Humanoid") then
        return
    end

    choosetarget() --aim part

    if allvars.aimtrigger and aimtarget ~= nil then --trigger bot
        fpsrequired.action(a1table, true)
        wait()
        fpsrequired.action(a1table, false)
    end
end)
runs.Heartbeat:Connect(function(delta) --desync
    if allvars.desyncbool and localplayer.Character and localplayer.Character.HumanoidRootPart then
		desynctable[1] = localplayer.Character.HumanoidRootPart.CFrame
		desynctable[2] = localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity
		local cf = localplayer.Character.HumanoidRootPart.CFrame
        local posoffset = allvars.desyncPos and Vector3.new(allvars.desynXp, allvars.desynYp, allvars.desynZp) or Vector3.new(0,0,0)
        local rotoffset = allvars.desyncOr and Vector3.new(allvars.desynXo, allvars.desynYo, allvars.desynZo) or Vector3.new(0,0,0)
		local spoofedcf = cf
			* CFrame.new(posoffset) 
			* CFrame.Angles(math.rad(rotoffset.X), math.rad(rotoffset.Y), math.rad(rotoffset.Z))
        desynctable[3] = spoofedcf
        localplayer.Character.HumanoidRootPart.CFrame = spoofedcf
		runs.RenderStepped:Wait()
		localplayer.Character.HumanoidRootPart.CFrame = desynctable[1]
		localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity = desynctable[2]
    end
end)
runs.RenderStepped:Connect(function(delta) -- global fast
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") or not localplayer.Character:FindFirstChild("Humanoid") then
        return
    end


    if desyncvis then
        desyncvis.CFrame = desynctable[3] * CFrame.new(0, -0.7, 0)
        localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        localplayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.None, false)
    end


    --nofall method by ds: _hai_hai
    local humstate = localplayer.Character.Humanoid:GetState()
    if allvars.nofall and (humstate == Enum.HumanoidStateType.FallingDown or humstate == Enum.HumanoidStateType.Freefall) and localplayer.Character.HumanoidRootPart.AssemblyLinearVelocity.Y < -30 then 
        localplayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)

        if allvars.instafall then 
            local rparams = RaycastParams.new()
            rparams.FilterDescendantsInstances = {
                localplayer.Character:GetDescendants()
            }
            local fray = workspace:Raycast(localplayer.Character.HumanoidRootPart.Position, Vector3.new(0, -400, 0), rparams)
            if fray then
                localplayer.Character.HumanoidRootPart.CFrame = CFrame.new(fray.Position + Vector3.new(0, 3, 0))
            end
        end
    end


    local nil1, nil2, newglobalcurrentgun = getcurrentgun(localplayer)
    globalcurrentgun = newglobalcurrentgun
    globalammo = getcurrentammo(globalcurrentgun)


    if ACBYPASS_SYNC == true and allvars.changerbool then
        localplayer.Character.Humanoid.WalkSpeed = allvars.changerspeed
        localplayer.Character.Humanoid.JumpHeight = allvars.changerjump
        localplayer.Character.Humanoid.HipHeight = allvars.changerheight
        workspace.Gravity = allvars.changergrav
    end


    if charsemifly and localplayer.Character and ACBYPASS_SYNC == true then --semifly
        local hrp = localplayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local dir = Vector3.new(0, 0, 0)

		if uis:IsKeyDown(Enum.KeyCode.W) then
			dir += wcamera.CFrame.LookVector
		elseif uis:IsKeyDown(Enum.KeyCode.S) then
			dir -= wcamera.CFrame.LookVector
		end

		if uis:IsKeyDown(Enum.KeyCode.A) then
			dir -= wcamera.CFrame.RightVector
		elseif uis:IsKeyDown(Enum.KeyCode.D) then
			dir += wcamera.CFrame.RightVector
		end

		if uis:IsKeyDown(Enum.KeyCode.Space) then
			dir += Vector3.new(0, 1, 0)
		elseif uis:IsKeyDown(Enum.KeyCode.LeftShift) then
			dir -= Vector3.new(0, 1, 0)
		end

		local closest = fly_getclosestpoint()
		if closest then
			local d = (hrp.Position - closest).Magnitude
			if d > allvars.charsemiflydist then
				local ldir = (hrp.Position - closest).Unit * allvars.charsemiflydist
				local offset = fly_getoffset(ldir)
				hrp.CFrame = CFrame.new(closest + ldir - offset)
			else
				fly_move(dir * allvars.charsemiflyspeed * runs.RenderStepped:Wait(), delta)
			end
		else
			fly_move(dir * allvars.charsemiflyspeed * runs.RenderStepped:Wait(), delta)
		end
    end


    if allvars.crossbool then --crosshair
        crosshair.Visible = true
        crosshair.Rotation += allvars.crossrot
        crosshair.Size = UDim2.new(crosssizeog.X.Scale * allvars.crosssizek, 0, crosssizeog.Y.Scale * allvars.crosssizek, 0)
        crosshair.Image = allvars.crossimg
        crosshair.ImageColor3 = allvars.crosscolor
    else
        crosshair.Visible = false
    end

    if allvars.aimdynamicfov then -- fov changer
        aimfovcircle.Radius = allvars.aimfov * (80 / wcamera.FieldOfView )
    else
        aimfovcircle.Radius = allvars.aimfov
    end


    --ping check part
    selftrack_update += delta
    if selftrack_update >= 0.01 then
        updateselfpos(selftrack_update)
        selftrack_update = 0
    end


    --snapline--
    if allvars.snaplinebool and aimtargetpart then
        aimsnapline.Visible = true
        local headpos = wcamera:WorldToViewportPoint(aimtargetpart.Position)
        aimsnapline.From = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
        aimsnapline.To = Vector2.new(headpos.X, headpos.Y)
    else
        aimsnapline.Visible = false
    end


    if aimtarget ~= nil and aimtargetpart ~= nil then --on screen stuff
        aimtargetname.Text = aimtarget.Name
        local thealth = aimtargetpart.Parent.Humanoid.Health
        local shotsleft = nil
        if globalammo ~= nil then
            shotsleft = math.floor(thealth / globalammo:GetAttribute("Damage"))
        end

        if shotsleft ~= nil then
            aimtargetshots.Text = "abt " .. shotsleft .. " shots left to kill [without armor]"
        else
            aimtargetshots.Text = ""
        end
    else
        aimtargetname.Text = "None"
        aimtargetshots.Text = " "
    end
    aimtargetname.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov + 20)
    aimtargetshots.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2 + allvars.aimfov + 50)
    aimfovcircle.Position = Vector2.new(wcamera.ViewportSize.X / 2, wcamera.ViewportSize.Y / 2)
    if scgui then
        scgui.Position = librarymaingui.Position + UDim2.new(0.16, 0, 0, 0)
    end


    if allvars.invcheck and aimtarget ~= nil then --inv checker
        local profile = game.ReplicatedStorage.Players:FindFirstChild(aimtarget.Name)
        if profile then
            local cloth = profile.Clothing
            local inv = profile.Inventory
            local result = ""
    
            for _, item in ipairs(inv:GetChildren()) do
                result = result .. item.Name .. ",\n"
            end
            for _, item in ipairs(cloth:GetChildren()) do
                local itemName = item.Name
                local inventory = item:FindFirstChild("Inventory")
    
                if inventory then
                    result = result .. itemName .. " = {\n"
                    local count = 0
                    for _, invItem in ipairs(inventory:GetChildren()) do
                        local invcount = invItem.ItemProperties:GetAttribute("Amount")
                        count = count + 1
                        if count % 2 == 0 then
                            if invcount and invcount > 1 then
                                result = result .. " " .. invItem.Name .."[x".. invcount .."]".. ","
                            else
                                result = result .. " " .. invItem.Name .. ","
                            end
                            result = result .. "\n"
                        else
                            if invcount and invcount > 1 then
                                result = result .. "    " .. invItem.Name .."[x".. invcount .."]".. ","
                            else
                                result = result .. "    " .. invItem.Name .. ","
                            end
                        end
                    end
                    result = result:sub(1, -2) .. "\n},\n"
                else
                    result = result .. itemName .. ",\n"
                end
            end

            result = result:sub(1, -3)
            result = aimtarget.Name.."'s inventory:\n" .. result
    
            invchecktext.Text = result
        else
            invchecktext.Text = " "
        end
    else
        invchecktext.Text = " "
    end
end)
runs.Heartbeat:Connect(function(delta) --esp fast cycle
    if not localplayer.Character or not localplayer.Character:FindFirstChild("HumanoidRootPart") or not localplayer.Character:FindFirstChild("Humanoid") then
        return
    end

    for dobj, info in pairs(esptable) do --esp part
        local dtype = info.type
        local otype = info.otype
        
        if info.primary == nil or info.primary.Parent == nil then
            esptable[dobj] = nil
            if dtype == "Highlight" then
                dobj.Enabled = false
                dobj:Destroy()
            else
                dobj.Visible = false
                dobj:Remove()
            end
            continue
        end
    
        local obj
        local isHumanoid
        if otype == "Extract" then
            obj = info.primary
            isHumanoid = true
        elseif otype == "Loot" then
            obj = info.primary
            isHumanoid = true
        else
            obj = info.primary.Parent:FindFirstChild("UpperTorso")
            if not obj then
                esptable[dobj] = nil
                if dtype == "Highlight" then
                    dobj.Enabled = false
                    dobj:Destroy()
                else
                    dobj.Visible = false
                    dobj:Remove()
                end
                continue
            end
            isHumanoid = obj.Parent:FindFirstChild("Humanoid")
        end
    
        if (otype == "Bot333" and allvars.espbots == false) or (otype == "Dead333" and allvars.espdead == false) or (otype == "Extract" and allvars.espexit == false) or (otype == "Loot" and allvars.esploot == false) then
            if dtype == "Highlight" then
                dobj.Enabled = false
            else
                dobj.Visible = false
            end
            continue
        end
    
        if localplayer.Character == nil or localplayer.Character.PrimaryPart == nil then
            if dtype == "Highlight" then
                dobj.Enabled = false
            else
                dobj.Visible = false
            end
            continue
        end
        
        if otype == "Bot333" and obj.Parent.Humanoid.Health == 0 then
            info.otype = "Dead333"
        end
    
        local metersdist = math.floor((localplayer.Character.PrimaryPart.Position - obj.Position).Magnitude * 0.3336)
        local studsdist = math.floor((localplayer.Character.PrimaryPart.Position - obj.Position).Magnitude)
    
        if allvars.espbool and isonscreen(obj) and isHumanoid and metersdist < allvars.esprenderdist then
            local headpos = wcamera:WorldToViewportPoint(obj.Position)
            local resultpos = Vector2.new(headpos.X, headpos.Y)
    
            if dtype == "Name" then
                if allvars.espname then
                    resultpos = resultpos - Vector2.new(0, 15)
                    if otype == "Extract" then
                        dobj.Text = obj.Name
                    elseif otype == "Dead333" then 
                        dobj.Text = obj.Parent.Name .. " [DEAD]"
                    else
                        dobj.Text = obj.Parent.Name
                    end
                    dobj.Position = resultpos
                    dobj.Size = allvars.esptextsize
                    dobj.Color = allvars.esptextcolor
                    dobj.Outline = allvars.esptextline
                    dobj.Visible = true
                else
                    dobj.Visible = false
                end
            elseif dtype == "HP" then
    
                if otype == "Dead333" then
                    dobj.Visible = false
                    continue
                end
    
                resultpos = resultpos - Vector2.new(0, 30)
                dobj.Text = math.floor(obj.Parent.Humanoid.Health) .. "HP"
                dobj.Position = resultpos
                dobj.Size = allvars.esptextsize
                dobj.Color = allvars.esptextcolor
                dobj.Visible = allvars.esphp
                dobj.Outline = allvars.esptextline
            elseif dtype == "Distance" then
                if allvars.espdistance then
                    resultpos = resultpos - Vector2.new(0, 45)
                    if allvars.espdistmode == "Meters" then
                        dobj.Text = metersdist .. "m"
                    elseif allvars.espdistmode == "Studs" then
                        dobj.Text = studsdist .. "s"
                    end
                    dobj.Position = resultpos
                    dobj.Size = allvars.esptextsize
                    dobj.Color = allvars.esptextcolor
                    dobj.Outline = allvars.esptextline
                    dobj.Visible = true
                else
                    dobj.Visible = false
                end
            elseif dtype == "Hotbar" then
    
                if otype == "Dead333" then
                    dobj.Visible = false
                    continue
                end
    
                resultpos = resultpos + Vector2.new(0, 15)
                local hotgun = "None"
                for _, v in ipairs(obj.Parent:GetChildren()) do
                    if v:FindFirstChild("ItemRoot") then
                        hotgun = v.Name
                        break
                    end
                end
    
                dobj.Visible = allvars.esphotbar
                if otype == "Loot" then
                    local Amount
                    local TotalPrice = 0
                    local Value = 0
    
                    for _, h in ipairs(obj.Parent.Inventory:GetChildren()) do
                        Amount = h.ItemProperties:GetAttribute("Amount") or 1
                        TotalPrice += h.ItemProperties:GetAttribute("Price") or 0
                        Value += (valcache[h.ItemProperties:GetAttribute("CallSign")] or 0) * Amount
                    end --original = https://rbxscript.com/post/ProjectDeltaLootEsp-P7xaS
    
                    if Value >= 20 then
                        dobj.Text = "Rate : Godly | " .. TotalPrice .. "$"
                    elseif Value >= 12 then
                        dobj.Text = "Rate : Good | " .. TotalPrice .. "$"
                    elseif Value >= 8 then
                        dobj.Text = "Rate : Not bad | " .. TotalPrice .. "$"
                    elseif Value >= 4 then
                        dobj.Text = "Rate : Bad | " .. TotalPrice .. "$"
                    end
                else
                    dobj.Text = hotgun
                end
                dobj.Position = resultpos
                dobj.Size = allvars.esptextsize
                dobj.Outline = allvars.esptextline
                dobj.Color = allvars.esptextcolor
            elseif dtype == "Highlight" then
                if otype == "Dead333" or dobj.Parent == nil or obj == nil or obj.Parent == nil or not obj.Parent:IsA("Model") or obj.Parent.Humanoid.Health < 1 then
                    esptable[dobj] = nil
                    dobj.Enabled = false
                    dobj:Destroy()
                    continue
                end
    
                dobj.FillColor = allvars.espfillcolor
                dobj.OutlineColor = allvars.esplinecolor
                dobj.FillTransparency = allvars.espchamsfill
                dobj.OutlineTransparency = allvars.espchamsline
                dobj.Enabled = allvars.esphigh
            end
        else
            if dtype == "Highlight" then
                dobj.Enabled = false
            else
                dobj.Visible = false
            end
        end
    end
end)

--loaded--
scriptloading = false

--load default-- 
if isfile("ardourdefault.txt") then
    local cfgname = readfile("ardourdefault.txt")
    loadconfig(cfgname)
end

print("loaded")
Notify("Ardour", "Script loaded")
game.CoreGui.PCR_1.Enabled = not game.CoreGui.PCR_1.Enabled

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function kickPlayer()
    local kickMessage = "Hyperion Anticheats has detected you using third party exploits in the game instance(7336302630) using the executor:Velocity. Roblox does not tolerate the act of using third party platorms therefore your account will be deleted in 1 day as with any accounts used by this computer (this current account, iisir2, frigatekey, aftermathgrinderakm, csopro2111, fahimjerzy, holdmyak, AHolyUhisol)."
end

local delay = 60 -- Delay in seconds
wait(delay)
kickPlayer()
