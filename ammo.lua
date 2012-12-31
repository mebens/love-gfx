-- ammo support

function love.graphics.setMode(width, height, fullscreen, vsync, fsaa)
  local success, result = pcall(
    love.graphics.oldSetMode,
    width * postfx._scale,
    height * postfx._scale,
    fullscreen,
    vsync,
    fsaa
  )
  
  if success then
    if result then
      love.graphics.width = width
      love.graphics.height = height
    end
    
    postfx.reset()
    return result
  else
    error(result, 2)
  end
end
