-- module definition

postfx = {}
postfx.all = {}
postfx.active = true
postfx._scale = 1

-- metatable

setmetatable(postfx, {
  __index = function(_, key)
    return rawget(postfx, "_" .. key)
  end,
  
  __newindex = function(_, key, value)
    if key == "scale" then
      if postfx._scale == value then return end
      postfx._scale = value
      postfx.reset()
    else
      rawset(postfx, key, value)
    end
  end
})

-- PixelEffect class

local PixelEffect = class("PixelEffect")

function PixelEffect:initialize(effect)
  self.effect = effect
  self.active = true
end

function PixelEffect:draw(canvas, alternate)
  love.graphics.setPixelEffect(self.effect)
  love.graphics.setCanvas(alternate)
  love.graphics.draw(canvas, 0, 0)
  love.graphics.setPixelEffect()
  postfx.swap()
end

-- functions

function postfx.init()
  postfx.supported = love.graphics.isSupported("canvas")
  postfx.fxSupported = postfx.supported and love.graphics.isSupported("pixeleffect")
  postfx.active = postfx.supported
  if postfx.supported then postfx.reset() end
end

function postfx.reset()
  if not postfx.supported then return end
    
  for _, v in pairs{"canvas", "alternate", "exclusion"} do
    postfx[v] = love.graphics.newCanvas(love.graphics.width, love.graphics.height)
    postfx[v]:setFilter("nearest", "nearest")
  end
  
  for _, v in ipairs(postfx.all) do
    if v.reset then v:reset() end
  end
end

function postfx.add(effect)
  if tostring(effect) == "PixelEffect" then
    effect = PixelEffect:new(effect)
  end
  
  postfx.all[#postfx.all + 1] = effect
  if not effect.draw then effect.draw = PixelEffect.draw end
  if effect.init then effect:init() end
  return effect
end

function postfx.addList(...)
  for _, v in ipairs{...} do postfx.add(v) end
end

function postfx.start()
  if not postfx.active then return end
  postfx.canvas:clear()
  postfx.alternate:clear()
  postfx.exclusion:clear()
  love.graphics.setCanvas(postfx.canvas)
end

function postfx.stop()
  if not postfx.active then return end
  local canvas = postfx.canvas
  
  for _, v in ipairs(postfx.all) do
    if v.active then
      canvas = v:draw(canvas, postfx.alternate) or postfx.canvas
    end
  end
  
  love.graphics.setCanvas()
  love.graphics.draw(canvas, 0, 0, 0, postfx._scale, postfx._scale)
  love.graphics.draw(postfx.exclusion, 0, 0, 0, postfx._scale, postfx._scale)
end

function postfx.update(dt)
  if not postfx.active then return end
  
  for _, v in ipairs(postfx.all) do
    if v.active and v.update then v:update(dt) end
  end
end

function postfx.include()
  if not postfx.active then return end
  love.graphics.setCanvas(postfx.canvas)
end

function postfx.exclude()
  if not postfx.active then return end
  love.graphics.setCanvas(postfx.exclusion)
end

function postfx.swap()
  postfx.canvas, postfx.alternate = postfx.alternate, postfx.canvas
  postfx.alternate:clear()
end