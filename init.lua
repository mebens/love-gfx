local path = ({...})[1]:gsub("%.init", "") 
require(path .. ".postfx")
require(path .. ".Spritemap")
require(path .. ".Tilemap")
require(path .. ".Grid")
if ammo then require(path .. ".ammo") end
