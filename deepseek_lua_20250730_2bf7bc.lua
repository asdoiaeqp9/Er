-- Futuristic Map System
-- Complete Implementation

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Constants
local MAP_SIZE = 10000 -- 10k x 10k studs
local GRID_SIZE = 1000 -- Studs between grid lines
local MIN_ZOOM = 0.5
local MAX_ZOOM = 3
local DEFAULT_ZOOM = 1
local PLAYER_MARKER_SIZE = 15
local LOCAL_PLAYER_MARKER_SIZE = 20
local PLAYER_NAME_OFFSET = 20

-- Main ScreenGui
local MapGUI = Instance.new("ScreenGui")
MapGUI.Name = "FuturisticMap"
MapGUI.ResetOnSpawn = false
MapGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MapGUI.DisplayOrder = 10
MapGUI.Parent = playerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.7, 0, 0.8, 0)
MainFrame.Position = UDim2.new(1, 0, 0.1, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = MapGUI

-- Corner and Shadow
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.03, 0)
Corner.Parent = MainFrame

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0.05, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0.25, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FUTURISTIC MAP SYSTEM"
Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.SciFi
Title.TextSize = 18
Title.Parent = TitleBar

-- Control Buttons (Minimize, Fullscreen, Close)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0.1, 0, 1, 0)
CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.SciFi
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local FullscreenButton = Instance.new("TextButton")
FullscreenButton.Name = "FullscreenButton"
FullscreenButton.Size = UDim2.new(0.1, 0, 1, 0)
FullscreenButton.Position = UDim2.new(0.8, 0, 0, 0)
FullscreenButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
FullscreenButton.BorderSizePixel = 0
FullscreenButton.Text = "[ ]"
FullscreenButton.TextColor3 = Color3.new(1, 1, 1)
FullscreenButton.Font = Enum.Font.SciFi
FullscreenButton.TextSize = 18
FullscreenButton.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0.1, 0, 1, 0)
MinimizeButton.Position = UDim2.new(0.7, 0, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.SciFi
MinimizeButton.TextSize = 18
MinimizeButton.Parent = TitleBar

-- Map Container
local MapContainer = Instance.new("Frame")
MapContainer.Name = "MapContainer"
MapContainer.Size = UDim2.new(0.8, 0, 0.9, 0)
MapContainer.Position = UDim2.new(0.1, 0, 0.1, 0)
MapContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MapContainer.BorderSizePixel = 0
MapContainer.ClipsDescendants = true
MapContainer.Parent = MainFrame

local MapCorner = Instance.new("UICorner")
MapCorner.CornerRadius = UDim.new(0.02, 0)
MapCorner.Parent = MapContainer

-- Actual Map
local Map = Instance.new("Frame")
Map.Name = "Map"
Map.Size = UDim2.new(1, 0, 1, 0)
Map.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Map.BorderSizePixel = 0
Map.Parent = MapContainer

-- Grid Lines
local function createGridLines()
    local lineThickness = 1
    
    for x = -MAP_SIZE/2, MAP_SIZE/2, GRID_SIZE do
        local line = Instance.new("Frame")
        line.Name = "GridLineX_" .. x
        line.Size = UDim2.new(0, lineThickness, 1, 0)
        line.Position = UDim2.new(0.5, x / MAP_SIZE * Map.AbsoluteSize.X, 0, 0)
        line.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        line.BorderSizePixel = 0
        line.ZIndex = 1
        line.Parent = Map
        
        if x == 0 then
            line.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
            line.Size = UDim2.new(0, lineThickness * 2, 1, 0)
        end
    end
    
    for y = -MAP_SIZE/2, MAP_SIZE/2, GRID_SIZE do
        local line = Instance.new("Frame")
        line.Name = "GridLineY_" .. y
        line.Size = UDim2.new(1, 0, 0, lineThickness)
        line.Position = UDim2.new(0, 0, 0.5, y / MAP_SIZE * Map.AbsoluteSize.Y)
        line.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        line.BorderSizePixel = 0
        line.ZIndex = 1
        line.Parent = Map
        
        if y == 0 then
            line.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
            line.Size = UDim2.new(1, 0, 0, lineThickness * 2)
        end
    end
end

createGridLines()

-- Crosshair for selection
local CrosshairV = Instance.new("Frame")
CrosshairV.Name = "CrosshairV"
CrosshairV.Size = UDim2.new(0, 2, 1, 0)
CrosshairV.Position = UDim2.new(0.5, -1, 0, 0)
CrosshairV.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
CrosshairV.BorderSizePixel = 0
CrosshairV.ZIndex = 10
CrosshairV.Parent = MapContainer

local CrosshairH = Instance.new("Frame")
CrosshairH.Name = "CrosshairH"
CrosshairH.Size = UDim2.new(1, 0, 0, 2)
CrosshairH.Position = UDim2.new(0, 0, 0.5, -1)
CrosshairH.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
CrosshairH.BorderSizePixel = 0
CrosshairH.ZIndex = 10
CrosshairH.Parent = MapContainer

-- Zoom Controls
local ZoomInButton = Instance.new("TextButton")
ZoomInButton.Name = "ZoomInButton"
ZoomInButton.Size = UDim2.new(0.05, 0, 0.05, 0)
ZoomInButton.Position = UDim2.new(0.925, 0, 0.2, 0)
ZoomInButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
ZoomInButton.BorderSizePixel = 0
ZoomInButton.Text = "+"
ZoomInButton.TextColor3 = Color3.new(1, 1, 1)
ZoomInButton.Font = Enum.Font.SciFi
ZoomInButton.TextSize = 24
ZoomInButton.ZIndex = 5
ZoomInButton.Parent = MainFrame

local ZoomOutButton = Instance.new("TextButton")
ZoomOutButton.Name = "ZoomOutButton"
ZoomOutButton.Size = UDim2.new(0.05, 0, 0.05, 0)
ZoomOutButton.Position = UDim2.new(0.925, 0, 0.3, 0)
ZoomOutButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
ZoomOutButton.BorderSizePixel = 0
ZoomOutButton.Text = "-"
ZoomOutButton.TextColor3 = Color3.new(1, 1, 1)
ZoomOutButton.Font = Enum.Font.SciFi
ZoomOutButton.TextSize = 24
ZoomOutButton.ZIndex = 5
ZoomOutButton.Parent = MainFrame

-- Coordinates Display
local CoordinatesLabel = Instance.new("TextLabel")
CoordinatesLabel.Name = "CoordinatesLabel"
CoordinatesLabel.Size = UDim2.new(0.2, 0, 0.05, 0)
CoordinatesLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
CoordinatesLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
CoordinatesLabel.BackgroundTransparency = 0.5
CoordinatesLabel.BorderSizePixel = 0
CoordinatesLabel.Text = "X: 0 | Y: 0 | Z: 0"
CoordinatesLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
CoordinatesLabel.Font = Enum.Font.SciFi
CoordinatesLabel.TextSize = 14
CoordinatesLabel.TextXAlignment = Enum.TextXAlignment.Left
CoordinatesLabel.Parent = MapContainer

-- Side Buttons Panel
local SideButtons = Instance.new("Frame")
SideButtons.Name = "SideButtons"
SideButtons.Size = UDim2.new(0.07, 0, 0.7, 0)
SideButtons.Position = UDim2.new(0.015, 0, 0.15, 0)
SideButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SideButtons.BackgroundTransparency = 0.3
SideButtons.BorderSizePixel = 0
SideButtons.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0.1, 0)
SideCorner.Parent = SideButtons

-- Add side buttons
local buttonNames = {"Teleport", "Mark", "Scan", "Settings", "Help"}
local buttonIcons = {"📡", "📍", "🔍", "⚙️", "❓"}

for i, name in ipairs(buttonNames) do
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(0.8, 0, 0.15, 0)
    button.Position = UDim2.new(0.1, 0, 0.05 + (i-1)*0.17, 0)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    button.BorderSizePixel = 0
    button.Text = buttonIcons[i] .. "\n" .. name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SciFi
    button.TextSize = 12
    button.TextWrapped = true
    button.Parent = SideButtons
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.2, 0)
    buttonCorner.Parent = button
end

-- Confirm/Select Button
local ConfirmButton = Instance.new("TextButton")
ConfirmButton.Name = "ConfirmButton"
ConfirmButton.Size = UDim2.new(0.15, 0, 0.07, 0)
ConfirmButton.Position = UDim2.new(0.425, 0, 0.9, 0)
ConfirmButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ConfirmButton.BorderSizePixel = 0
ConfirmButton.Text = "SELECT"
ConfirmButton.TextColor3 = Color3.new(1, 1, 1)
ConfirmButton.Font = Enum.Font.SciFi
ConfirmButton.TextSize = 18
ConfirmButton.Parent = MainFrame

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0.2, 0)
ConfirmCorner.Parent = ConfirmButton

-- Player Markers
local PlayerMarkers = Instance.new("Folder")
PlayerMarkers.Name = "PlayerMarkers"
PlayerMarkers.Parent = Map

-- Player Info GUI (appears when clicking a player)
local PlayerInfoGUI = Instance.new("Frame")
PlayerInfoGUI.Name = "PlayerInfoGUI"
PlayerInfoGUI.Size = UDim2.new(0.3, 0, 0.4, 0)
PlayerInfoGUI.Position = UDim2.new(0.35, 0, 0.3, 0)
PlayerInfoGUI.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
PlayerInfoGUI.BackgroundTransparency = 0.1
PlayerInfoGUI.BorderSizePixel = 0
PlayerInfoGUI.Visible = false
PlayerInfoGUI.ZIndex = 20
PlayerInfoGUI.Parent = MapGUI

local PlayerInfoCorner = Instance.new("UICorner")
PlayerInfoCorner.CornerRadius = UDim.new(0.03, 0)
PlayerInfoCorner.Parent = PlayerInfoGUI

local PlayerAvatar = Instance.new("ImageLabel")
PlayerAvatar.Name = "PlayerAvatar"
PlayerAvatar.Size = UDim2.new(0.2, 0, 0.2, 0)
PlayerAvatar.Position = UDim2.new(0.05, 0, 0.05, 0)
PlayerAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
PlayerAvatar.BorderSizePixel = 0
PlayerAvatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
PlayerAvatar.Parent = PlayerInfoGUI

local PlayerName = Instance.new("TextLabel")
PlayerName.Name = "PlayerName"
PlayerName.Size = UDim2.new(0.7, 0, 0.1, 0)
PlayerName.Position = UDim2.new(0.3, 0, 0.05, 0)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = "PlayerName"
PlayerName.TextColor3 = Color3.fromRGB(200, 200, 255)
PlayerName.Font = Enum.Font.SciFi
PlayerName.TextSize = 18
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.Parent = PlayerInfoGUI

local PlayerDistance = Instance.new("TextLabel")
PlayerDistance.Name = "PlayerDistance"
PlayerDistance.Size = UDim2.new(0.7, 0, 0.1, 0)
PlayerDistance.Position = UDim2.new(0.3, 0, 0.15, 0)
PlayerDistance.BackgroundTransparency = 1
PlayerDistance.Text = "Distance: 0 studs"
PlayerDistance.TextColor3 = Color3.fromRGB(180, 180, 255)
PlayerDistance.Font = Enum.Font.SciFi
PlayerDistance.TextSize = 14
PlayerDistance.TextXAlignment = Enum.TextXAlignment.Left
PlayerDistance.Parent = PlayerInfoGUI

local ClosePlayerInfo = Instance.new("TextButton")
ClosePlayerInfo.Name = "ClosePlayerInfo"
ClosePlayerInfo.Size = UDim2.new(0.1, 0, 0.1, 0)
ClosePlayerInfo.Position = UDim2.new(0.9, 0, 0, 0)
ClosePlayerInfo.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClosePlayerInfo.BorderSizePixel = 0
ClosePlayerInfo.Text = "X"
ClosePlayerInfo.TextColor3 = Color3.new(1, 1, 1)
ClosePlayerInfo.Font = Enum.Font.SciFi
ClosePlayerInfo.TextSize = 18
ClosePlayerInfo.Parent = PlayerInfoGUI

-- Player Action Buttons
local actionButtons = {
    {"Teleport", Color3.fromRGB(0, 150, 255)},
    {"Message", Color3.fromRGB(100, 200, 100)},
    {"Spectate", Color3.fromRGB(200, 150, 0)},
    {"Report", Color3.fromRGB(200, 50, 50)}
}

for i, buttonData in ipairs(actionButtons) do
    local buttonName, buttonColor = buttonData[1], buttonData[2]
    local button = Instance.new("TextButton")
    button.Name = buttonName .. "Button"
    button.Size = UDim2.new(0.9, 0, 0.15, 0)
    button.Position = UDim2.new(0.05, 0, 0.3 + (i-1)*0.18, 0)
    button.BackgroundColor3 = buttonColor
    button.BorderSizePixel = 0
    button.Text = buttonName
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SciFi
    button.TextSize = 16
    button.Parent = PlayerInfoGUI
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0.1, 0)
    buttonCorner.Parent = button
end

-- Map State Variables
local mapState = {
    zoomLevel = DEFAULT_ZOOM,
    offset = Vector2.new(0, 0),
    isDragging = false,
    dragStart = Vector2.new(0, 0),
    dragOffset = Vector2.new(0, 0),
    selectedPlayer = nil,
    minimized = false,
    fullscreen = false,
    originalSize = UDim2.new(0.7, 0, 0.8, 0),
    originalPosition = UDim2.new(0.15, 0, 0.1, 0)
}

-- Helper Functions
local function tweenGui(gui, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(gui, tweenInfo, properties)
    tween:Play()
    return tween
end

local function getWorldToMapPosition(worldPosition)
    local x = (worldPosition.X / MAP_SIZE) * Map.AbsoluteSize.X * mapState.zoomLevel + mapState.offset.X
    local z = (worldPosition.Z / MAP_SIZE) * Map.AbsoluteSize.Y * mapState.zoomLevel + mapState.offset.Y
    return Vector2.new(x, z)
end

local function updateCoordinatesDisplay(position)
    local x = math.floor(position.X)
    local y = math.floor(position.Y)
    local z = math.floor(position.Z)
    CoordinatesLabel.Text = string.format("X: %d | Y: %d | Z: %d", x, y, z)
end

local function updateMapTransform()
    Map.Size = UDim2.new(mapState.zoomLevel, 0, mapState.zoomLevel, 0)
    Map.Position = UDim2.new(
        0.5 - mapState.zoomLevel/2 + mapState.offset.X/Map.AbsoluteSize.X,
        0,
        0.5 - mapState.zoomLevel/2 + mapState.offset.Y/Map.AbsoluteSize.Y,
        0
    )
end

local function zoomToPoint(zoomPoint, newZoom)
    local relativePoint = (zoomPoint - Map.AbsolutePosition) / Map.AbsoluteSize
    local mapCenter = Vector2.new(Map.AbsoluteSize.X/2, Map.AbsoluteSize.Y/2)
    local offsetFromCenter = relativePoint * Map.AbsoluteSize - mapCenter
    
    mapState.zoomLevel = math.clamp(newZoom, MIN_ZOOM, MAX_ZOOM)
    
    -- Adjust offset to keep the zoom point under the cursor
    mapState.offset = mapState.offset - offsetFromCenter * (mapState.zoomLevel / newZoom - 1)
    
    updateMapTransform()
end

local function createPlayerMarker(player, isLocalPlayer)
    local marker = Instance.new("Frame")
    marker.Name = player.Name
    marker.Size = UDim2.new(0, isLocalPlayer and LOCAL_PLAYER_MARKER_SIZE or PLAYER_MARKER_SIZE, 0, isLocalPlayer and LOCAL_PLAYER_MARKER_SIZE or PLAYER_MARKER_SIZE)
    marker.AnchorPoint = Vector2.new(0.5, 0.5)
    marker.BackgroundColor3 = isLocalPlayer and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 100, 100)
    marker.BorderSizePixel = 0
    marker.ZIndex = 5
    
    -- Different shape for local player (triangle) vs others (circle)
    if isLocalPlayer then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = marker
    else
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = marker
    end
    
    -- Player name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(3, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0.5, 0, -0.5, -PLAYER_NAME_OFFSET)
    nameLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SciFi
    nameLabel.TextSize = 12
    nameLabel.ZIndex = 5
    nameLabel.Parent = marker
    
    marker.Parent = PlayerMarkers
    
    return marker
end

local function updatePlayerMarker(player, marker, character)
    if character and character:FindFirstChild("HumanoidRootPart") then
        local rootPart = character.HumanoidRootPart
        local mapPosition = getWorldToMapPosition(rootPart.Position)
        
        marker.Position = UDim2.new(
            0,
            mapPosition.X,
            0,
            mapPosition.Y
        )
        
        -- Update distance for selected player
        if mapState.selectedPlayer and mapState.selectedPlayer == player then
            local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            PlayerDistance.Text = string.format("Distance: %d studs", math.floor(distance))
        end
    end
end

local function showPlayerInfo(player)
    if not player then return end
    
    mapState.selectedPlayer = player
    PlayerName.Text = player.Name
    PlayerDistance.Text = "Distance: Calculating..."
    
    -- Load player avatar (async to prevent freezing)
    spawn(function()
        local userId = tostring(player.UserId)
        local thumbType = Enum.ThumbnailType.HeadShot
        local thumbSize = Enum.ThumbnailSize.Size420x420
        
        local content, isReady = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)
        PlayerAvatar.Image = content
    end)
    
    -- Animation
    PlayerInfoGUI.Visible = true
    PlayerInfoGUI.Size = UDim2.new(0, 0, 0, 0)
    PlayerInfoGUI.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    tweenGui(PlayerInfoGUI, {
        Size = UDim2.new(0.3, 0, 0.4, 0),
        Position = UDim2.new(0.35, 0, 0.3, 0)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function hidePlayerInfo()
    tweenGui(PlayerInfoGUI, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.2):Play()
    
    delay(0.2, function()
        PlayerInfoGUI.Visible = false
        mapState.selectedPlayer = nil
    end)
end

-- Initialize player markers
local function initPlayerMarkers()
    -- Create marker for local player
    if player.Character then
        createPlayerMarker(player, true)
    end
    
    player.CharacterAdded:Connect(function(character)
        createPlayerMarker(player, true)
    end)
    
    -- Create markers for other players
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            if otherPlayer.Character then
                createPlayerMarker(otherPlayer, false)
            end
            
            otherPlayer.CharacterAdded:Connect(function(character)
                createPlayerMarker(otherPlayer, false)
            end)
        end
    end
    
    -- Handle new players joining
    Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function(character)
            createPlayerMarker(newPlayer, false)
        end)
    end)
    
    -- Handle players leaving
    Players.PlayerRemoving:Connect(function(leavingPlayer)
        local marker = PlayerMarkers:FindFirstChild(leavingPlayer.Name)
        if marker then
            marker:Destroy()
        end
    end)
end

-- Update player positions
local function updatePlayerPositions()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        local marker = PlayerMarkers:FindFirstChild(otherPlayer.Name)
        if marker and otherPlayer.Character then
            updatePlayerMarker(otherPlayer, marker, otherPlayer.Character)
        end
    end
end

-- Event Handlers
local function onZoomIn()
    local mousePos = UserInputService:GetMouseLocation()
    local newZoom = mapState.zoomLevel * 1.2
    zoomToPoint(mousePos, newZoom)
    
    -- Animation
    tweenGui(ZoomInButton, {Size = UDim2.new(0.055, 0, 0.055, 0)}, 0.1)
    tweenGui(ZoomInButton, {Size = UDim2.new(0.05, 0, 0.05, 0)}, 0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
end

local function onZoomOut()
    local mousePos = UserInputService:GetMouseLocation()
    local newZoom = mapState.zoomLevel / 1.2
    zoomToPoint(mousePos, newZoom)
    
    -- Animation
    tweenGui(ZoomOutButton, {Size = UDim2.new(0.055, 0, 0.055, 0)}, 0.1)
    tweenGui(ZoomOutButton, {Size = UDim2.new(0.05, 0, 0.05, 0)}, 0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
end

local function onDragStart(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mapState.isDragging = true
        mapState.dragStart = Vector2.new(input.Position.X, input.Position.Y)
        mapState.dragOffset = mapState.offset
    end
end

local function onDrag(input)
    if mapState.isDragging then
        local delta = Vector2.new(
            input.Position.X - mapState.dragStart.X,
            input.Position.Y - mapState.dragStart.Y
        )
        mapState.offset = mapState.dragOffset + delta
        updateMapTransform()
    end
end

local function onDragEnd()
    mapState.isDragging = false
end

local function onPlayerClick(marker)
    local playerName = marker.Name
    local clickedPlayer = Players:FindFirstChild(playerName)
    
    if clickedPlayer then
        showPlayerInfo(clickedPlayer)
        
        -- Animation
        tweenGui(marker, {Size = UDim2.new(0, PLAYER_MARKER_SIZE * 1.5, 0, PLAYER_MARKER_SIZE * 1.5)}, 0.1)
        tweenGui(marker, {Size = UDim2.new(0, PLAYER_MARKER_SIZE, 0, PLAYER_MARKER_SIZE)}, 0.1, Enum.EasingStyle.Bounce)
    end
end

local function onConfirm()
    if mapState.selectedPlayer then
        print("Selected player:", mapState.selectedPlayer.Name)
    else
        -- Get position at crosshair
        local mapCenter = Vector2.new(
            MapContainer.AbsolutePosition.X + MapContainer.AbsoluteSize.X/2,
            MapContainer.AbsolutePosition.Y + MapContainer.AbsoluteSize.Y/2
        )
        
        -- Convert to world position
        local relativeX = (mapCenter.X - Map.AbsolutePosition.X - mapState.offset.X) / (Map.AbsoluteSize.X * mapState.zoomLevel)
        local relativeZ = (mapCenter.Y - Map.AbsolutePosition.Y - mapState.offset.Y) / (Map.AbsoluteSize.Y * mapState.zoomLevel)
        
        local worldX = relativeX * MAP_SIZE - MAP_SIZE/2
        local worldZ = relativeZ * MAP_SIZE - MAP_SIZE/2
        
        print(string.format("Selected position: X: %d, Z: %d", worldX, worldZ))
        
        -- Animation
        tweenGui(ConfirmButton, {Size = UDim2.new(0.16, 0, 0.08, 0)}, 0.1)
        tweenGui(ConfirmButton, {Size = UDim2.new(0.15, 0, 0.07, 0)}, 0.1, Enum.EasingStyle.Bounce)
    end
end

local function onMinimize()
    if mapState.minimized then
        -- Restore
        tweenGui(MainFrame, {
            Size = mapState.originalSize,
            Position = mapState.originalPosition
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        mapState.minimized = false
        MinimizeButton.Text = "_"
    else
        -- Minimize
        mapState.originalSize = MainFrame.Size
        mapState.originalPosition = MainFrame.Position
        tweenGui(MainFrame, {
            Size = UDim2.new(0.2, 0, 0.05, 0),
            Position = UDim2.new(0.9, 0, 0.05, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        mapState.minimized = true
        MinimizeButton.Text = "🗖"
    end
end

local function onFullscreen()
    if mapState.fullscreen then
        -- Restore
        tweenGui(MainFrame, {
            Size = mapState.originalSize,
            Position = mapState.originalPosition
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        mapState.fullscreen = false
        FullscreenButton.Text = "[ ]"
    else
        -- Fullscreen
        mapState.originalSize = MainFrame.Size
        mapState.originalPosition = MainFrame.Position
        tweenGui(MainFrame, {
            Size = UDim2.new(0.95, 0, 0.95, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        mapState.fullscreen = true
        FullscreenButton.Text = "🗗"
    end
end

local function onClose()
    tweenGui(MainFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    delay(0.3, function()
        MapGUI:Destroy()
    end)
end

-- Connect Events
ZoomInButton.MouseButton1Click:Connect(onZoomIn)
ZoomOutButton.MouseButton1Click:Connect(onZoomOut)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        local mapAbsPos = MapContainer.AbsolutePosition
        local mapAbsSize = MapContainer.AbsoluteSize
        
        -- Check if click is inside map container
        if mousePos.X >= mapAbsPos.X and mousePos.X <= mapAbsPos.X + mapAbsSize.X and
           mousePos.Y >= mapAbsPos.Y and mousePos.Y <= mapAbsPos.Y + mapAbsSize.Y then
            onDragStart(input)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        onDrag(input)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        onDragEnd()
        
        -- Check for player marker click
        if not mapState.isDragging then
            local mousePos = input.Position
            for _, marker in ipairs(PlayerMarkers:GetChildren()) do
                if marker:IsA("Frame") then
                    local markerAbsPos = marker.AbsolutePosition - Vector2.new(marker.AbsoluteSize.X/2, marker.AbsoluteSize.Y/2)
                    local markerAbsSize = marker.AbsoluteSize
                    
                    if mousePos.X >= markerAbsPos.X and mousePos.X <= markerAbsPos.X + markerAbsSize.X and
                       mousePos.Y >= markerAbsPos.Y and mousePos.Y <= markerAbsPos.Y + markerAbsSize.Y then
                        onPlayerClick(marker)
                        break
                    end
                end
            end
        end
    end
end)

ConfirmButton.MouseButton1Click:Connect(onConfirm)
MinimizeButton.MouseButton1Click:Connect(onMinimize)
FullscreenButton.MouseButton1Click:Connect(onFullscreen)
CloseButton.MouseButton1Click:Connect(onClose)
ClosePlayerInfo.MouseButton1Click:Connect(hidePlayerInfo)

-- Connect side buttons (just print for now)
for _, name in ipairs(buttonNames) do
    local button = SideButtons:FindFirstChild(name .. "Button")
    if button then
        button.MouseButton1Click:Connect(function()
            print(name .. " button clicked")
            
            -- Animation
            tweenGui(button, {Size = UDim2.new(0.85, 0, 0.14, 0)}, 0.1)
            tweenGui(button, {Size = UDim2.new(0.8, 0, 0.15, 0)}, 0.1, Enum.EasingStyle.Bounce)
        end)
    end
end

-- Connect player action buttons
for _, buttonData in ipairs(actionButtons) do
    local buttonName = buttonData[1]
    local button = PlayerInfoGUI:FindFirstChild(buttonName .. "Button")
    if button then
        button.MouseButton1Click:Connect(function()
            if mapState.selectedPlayer then
                print(buttonName .. " clicked for player:", mapState.selectedPlayer.Name)
                
                -- Animation
                tweenGui(button, {Size = UDim2.new(0.85, 0, 0.14, 0)}, 0.1)
                tweenGui(button, {Size = UDim2.new(0.9, 0, 0.15, 0)}, 0.1, Enum.EasingStyle.Bounce)
            end
        end)
    end
end

-- Initialize
updateMapTransform()
initPlayerMarkers()

-- Main update loop
RunService.Heartbeat:Connect(function()
    -- Update player positions
    updatePlayerPositions()
    
    -- Update coordinates display for crosshair position
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        updateCoordinatesDisplay(player.Character.HumanoidRootPart.Position)
    end
end)

-- Initial animation
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
tweenGui(MainFrame, {
    Size = mapState.originalSize,
    Position = mapState.originalPosition
}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Return the GUI for external control
return MapGUI
