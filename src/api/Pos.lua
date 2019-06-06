-- Functions dealing with 2D tiled map positions.
-- @module Pos
local Pos = {}

local directions = {
   North     = {  0, -1 },
   South     = {  0,  1 },
   East      = { -1,  0 },
   West      = {  1,  0 },
   Northeast = { -1, -1 },
   Southeast = { -1,  1 },
   Northwest = {  1, -1 },
   Southwest = {  1,  1 },
}

function Pos.unpack_direction(dir)
   local dir = directions[dir]
   if dir then
      return dir[1], dir[2]
   else
      return 0, 0
   end
end

function Pos.add_direction(dir, x, y)
   local dir = directions[dir]
   if dir then
      return x + dir[1], y + dir[2]
   else
      return x, y
   end
end

function Pos.dist(x1, y1, x2, y2)
   local dx = x1 - x2
   local dy = y1 - y2
   return math.sqrt(dx * dx + dy * dy)
end

return Pos