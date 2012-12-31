local path = ({...})[1]:gsub("%.init", "") 
require(path .. ".postfx")
if ammo then require(path .. ".ammo") end
