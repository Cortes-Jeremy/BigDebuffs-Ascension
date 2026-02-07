
-- CooldownTemplate
-- https://wow.gamepedia.com/UIOBJECT_Cooldown
-- My Discord: https://discord.gg/Fm9kgfk

--[[------------------------ API REFERENCE -----------------------------

DYNAMIC TEXTURE PATHS:
The library automatically detects the addon name and builds texture paths.
Default structure expected:
  YourAddon/
    CooldownTemplate/
      Cooldown/
        CircleCooldown.blp
        SquareCooldown.blp
        ClockLeg.blp

SHAPE CONFIGURATION:
self:SetCooldownShape(shape) -- "SQUARE" (default) or "CIRCLE"
self:GetCooldownShape()

RETAIL-COMPATIBLE API:
self:SetCooldown(start, duration, modRate)
self:GetCooldown()
self:GetCooldownDuration()
self:GetCooldownTimes()
self:Clear()

TEXTURE CUSTOMIZATION (RETAIL-COMPATIBLE):
self:SetSwipeTexture(file, r, g, b, a)
self:SetSwipeColor(r, g, b, a)

DISPLAY OPTIONS:
self:SetDrawEdge(boolean)
self:SetDrawBling(boolean)
self:SetDrawSwipe(boolean)
self:GetDrawEdge()
self:GetDrawBling()
self:GetDrawSwipe()

BLING CUSTOMIZATION:
self:SetBlingTexture(file, r, g, b, a)

TEXT OVERLAY:
self:SetHideCountdownNumbers(boolean)
self:UseColorText(boolean)

CONTROL:
self:Pause()
self:Resume()
self:IsPaused()
self:GetReverse()
self:SetReverse(boolean)

]]


local addonName, addonTable = ...

local ADDON_PATH = "Interface\\AddOns\\" .. addonName
local GetTime = GetTime


-- SHAPE CONFIGURATION

local COOLDOWN_SHAPE_CIRCLE = "CIRCLE"
local COOLDOWN_SHAPE_SQUARE = "SQUARE"
local DEFAULT_SHAPE = COOLDOWN_SHAPE_SQUARE

local ShapeAssets = {
    [COOLDOWN_SHAPE_CIRCLE] = {
        texture = ADDON_PATH .. "\\CooldownTemplate\\Cooldown\\CircleCooldown",
        atlasInfo = nil,
    },
    [COOLDOWN_SHAPE_SQUARE] = {
        texture = ADDON_PATH .. "\\CooldownTemplate\\Cooldown\\SquareCooldown",
        atlasInfo = nil,
    },
}


-- ATLAS GENERATION

local pixels = 1024
local magic = 1/pixels/2
local step = pixels/20

local function GenerateAtlasInfo()
    local atlasInfo = {}
    for i = 0, 399 do
        local row = i%20 + 1
        local column = math.floor(i / 20 ) + 1

        local top = (step*column - step)/pixels + magic
        local left = (step*row - step)/pixels + magic
        local bottom = step*column/pixels - magic
        local right = step*row/pixels - magic

        atlasInfo[i] = {left, right, top, bottom}
    end
    return atlasInfo
end

local AtlasInfo = GenerateAtlasInfo()

for _, shapeData in pairs(ShapeAssets) do
    shapeData.atlasInfo = AtlasInfo
end


-- UTILITY FUNCTIONS

local function SetFrameVisible(frame, visible)
    if visible then
        frame:Show()
    else
        frame:Hide()
    end
end

local function WrapTextInColorCode(text, colorHexString)
    return ("|cff%s%s|r"):format(colorHexString, text)
end

local function GetEdgeTexturePath()
    return ADDON_PATH .. "\\CooldownTemplate\\Cooldown\\ClockLeg"
end

local function GetBlingTexturePath()
    return "Interface\\Cooldown\\star4"
end

if not Mixin then
    function Mixin(object, ...)
        for i = 1, select("#", ...) do
            local mixin = select(i, ...)
            for k, v in pairs(mixin) do
                object[k] = v
            end
        end
        return object
    end
end

if not CreateFromMixins then
    function CreateFromMixins(...)
        return Mixin({}, ...)
    end
end


-- CONTROL FRAME HOOKS

function CooldownControlFrame_OnLoad(controlFrame)
    local self = controlFrame:GetParent()
    Mixin(self, CooldownMixin)

    self.Edge.texture:SetTexture(GetEdgeTexturePath())
    self.Bling.texture:SetTexture(GetBlingTexturePath())

    self:SetDrawEdge(self:GetAttribute("drawEdge"))
    self:SetDrawBling(self:GetAttribute("drawBling"))
    self:SetDrawSwipe(self:GetAttribute("drawSwipe"))
    self.IsReverse = self:GetAttribute("reverse")

    self:SetCooldownShape(DEFAULT_SHAPE)
    self:SetSwipeColor(0,0,0,0.6)
end

function CooldownControlFrame_OnUpdate(controlFrame, ...)
    Cooldown_OnUpdate(controlFrame:GetParent(), ...)
end


-- CORE COOLDOWN LOGIC

function Cooldown_SetCooldown(self, start, duration, modRate)
    self.start = start
    self.duration = duration
    self.timeRemaining = (start + duration) - GetTime()
    self.fadeTime = 1.2
    self.Pause = false
    self:Show()

    if self.Bling.texture.Anim:IsPlaying() then
        self.Bling.texture.Anim:Stop()

        self.Cooldown:SetAlpha(1)
        self.TimerText:SetAlpha(1)
        self.Edge:SetAlpha(1)
    end
end


-- COOLDOWN MIXIN

CooldownMixin = {}
CooldownMixin.IsReverse = false
CooldownMixin.textFormatted = false
CooldownMixin.hideCountdownNumbers = false
CooldownMixin.currentShape = DEFAULT_SHAPE
CooldownMixin.customSwipeTexture = nil


-- SHAPE MANAGEMENT

function CooldownMixin:SetCooldownShape(shape)
    if not ShapeAssets[shape] then
        error("Invalid cooldown shape: " .. tostring(shape))
        return
    end

    self.currentShape = shape

    -- Apply shape texture if no custom texture is set
    if not self.customSwipeTexture then
        local shapeData = ShapeAssets[shape]
        self.Cooldown.texture:SetTexture(shapeData.texture)
    end
end

function CooldownMixin:GetCooldownShape()
    return self.currentShape
end


-- ATLAS/ANIMATION SYSTEM

function CooldownMixin:SetAtlas(atlasName)
    local shapeData = ShapeAssets[self.currentShape]
    if not shapeData or not shapeData.atlasInfo then
        return
    end

    local atlas = shapeData.atlasInfo[atlasName]
    local left, right, top, bottom

    if atlas then
        if self:GetReverse() then
            left, right, top, bottom = unpack(atlas)
            self.Cooldown.texture:SetTexCoord(right, left, bottom, top)
        else
            left, right, top, bottom = unpack(shapeData.atlasInfo[399 - atlasName])
            self.Cooldown.texture:SetTexCoord(left, right, bottom, top)
        end
    end
end

function CooldownMixin:GetReverse()
    return self.IsReverse
end

function CooldownMixin:SetReverse(boolean)
    self.IsReverse = boolean
end


-- COOLDOWN CONTROL

function CooldownMixin:Clear()
    self.start = nil
    self.duration = nil
    self.endTime = nil
    self.timeRemaining = nil
    self.Pause = false
    self.rotation = nil

    self:Hide()
end

function CooldownMixin:IsPaused()
    return self.Pause
end

function CooldownMixin:Pause()
    self.Pause = true
end

function CooldownMixin:Resume()
    self.Pause = false
end

function CooldownMixin:SetCooldown(start, duration, modRate)
    Cooldown_SetCooldown(self, start, duration, modRate)
end

function CooldownMixin:GetCooldown()
    return self.start, self.duration, not self:IsPaused()
end

function CooldownMixin:GetRotation()
    return self.rotation
end

function CooldownMixin:GetCooldownDuration()
    return self.timeRemaining
end

function CooldownMixin:GetCooldownTimes()
    return self.start, self.duration
end


-- TEXTURE CUSTOMIZATION

-- Force Circle Shape cause I think addon use this function to put circle mask usually
function CooldownMixin:SetSwipeTexture(file, r, g, b, a)
    if file then
        -- self.customSwipeTexture = file
        -- self.Cooldown.texture:SetTexture(file)
        self:SetCooldownShape(COOLDOWN_SHAPE_CIRCLE)
        self.Cooldown.texture:SetVertexColor(r or 0, g or 0, b or 0, a or 0.6)
    else
        self.customSwipeTexture = nil
        self:SetCooldownShape(DEFAULT_SHAPE)
    end
end

function CooldownMixin:SetSwipeColor(r, g, b, a)
    self.Cooldown.texture:SetVertexColor(r or 0, g or 0, b or 0, a or 0.6) -- 0.6 default 3.3.5 Cooldown Alpha
end

function CooldownMixin:SetBlingTexture(file, r, g, b, a)
    self.Bling.texture:SetTexture(file)
    self.Bling.texture:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
end


-- DISPLAY OPTIONS

function CooldownMixin:SetDrawEdge(enable)
    SetFrameVisible(self.Edge, enable)
end

function CooldownMixin:SetDrawBling(enable)
    SetFrameVisible(self.Bling, enable)
end

function CooldownMixin:SetDrawSwipe(enable)
    SetFrameVisible(self.Cooldown, enable)
end

function CooldownMixin:GetDrawEdge()
    return self.Edge:IsVisible()
end

function CooldownMixin:GetDrawBling()
    return self.Bling:IsVisible()
end

function CooldownMixin:GetDrawSwipe()
    return self.Cooldown:IsVisible()
end

function CooldownMixin:GetEdgeScale()
    return self.Edge:GetScale()
end


-- TEXT OVERLAY

function CooldownMixin:SetHideCountdownNumbers(value)
    self.hideCountdownNumbers = value

    if value then
        self.TimerText:Hide()
    else
        self.TimerText:Show()
    end
end

function CooldownMixin:UseColorText(value)
    self.textFormatted = value
end

function CooldownMixin:SetText(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(seconds / 60 - (hours * 60))
    local sec = seconds - hours * 3600 - minutes * 60
    local colorHexString = "ffffff"
    local text

    if ( seconds  > 3600 ) then
        text = WrapTextInColorCode(string.format("%.fh", hours),  self.textFormatted and "b2b2b2" or colorHexString)
        self:SetFormattedText("%s", text)
    elseif ( seconds > 60 ) then
        text = WrapTextInColorCode(string.format("%.fm", minutes), self.textFormatted and "ffffff" or colorHexString)
        self:SetFormattedText("%s", text)
    elseif ( seconds > 5 ) then
        text = WrapTextInColorCode(string.format("%.f", sec), self.textFormatted and "ffff00" or colorHexString)
        self:SetFormattedText("%s", text)
    elseif (seconds > 2 ) then
        text = WrapTextInColorCode(string.format("%.f", sec), self.textFormatted and "ff0000" or colorHexString)
        self:SetFormattedText("%s", text)
    else
        text = WrapTextInColorCode(string.format("%.1f", sec), self.textFormatted and"ff0000" or colorHexString)
        self:SetFormattedText("%s", text)
    end
end

function CooldownMixin:SetFormattedText(format, text)
    self.TimerText.text:SetFormattedText(format, text)
end


-- LEGACY/HELPER FUNCTIONS

function Cooldown_Set(self, start, duration, enable, forceShowDrawEdge, modRate)
    if enable and enable ~= 0 and start > 0 and duration > 0 then
        self:SetDrawEdge(forceShowDrawEdge)
        self:SetCooldown(start, duration, modRate)
    else
        Cooldown_Clear(self)
    end
end

function Cooldown_Clear(self)
    self:Hide()
end

function Cooldown_SetDisplayAsPercentage(self, percentage)
    local seconds = 100;
    self:SetCooldown(GetTime() - seconds * percentage, seconds)
end


-- UPDATE LOOP

function Cooldown_OnUpdate(self, elapsed)
    local start, duration, enable = self:GetCooldown()
    if not enable then
        return
    end

    self.timeRemaining = self.timeRemaining - elapsed
    local percent = math.floor(( self.timeRemaining / duration) * 400)

    if ( percent > 0 ) then

        self.rotation = math.rad(3.6 * percent/4)

        if self:GetDrawSwipe() then
            self:SetAtlas(400 - percent)
        end

        if self.TimerText:IsShown() then
            self:SetText(self.timeRemaining)
        end

        if self:GetDrawEdge() then
            self.Edge.texture:SetRotation(self.rotation)
        end

    elseif ( self:GetDrawBling() and self.fadeTime ) then

        self.fadeTime = self.fadeTime - elapsed

        if ( self.fadeTime < 0 ) then
            self.fadeTime = nil
            self:Hide()
        else
            self.Cooldown:SetAlpha(0)
            self.TimerText:SetAlpha(0)
            self.Edge:SetAlpha(0)

            self.Bling.texture.Anim:Play()
        end
    else
        self:Hide()
    end
end
