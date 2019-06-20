local field = require("game.field")
local data = require("internal.data")
local InstancedMap = require("api.InstancedMap")
local Rand = require("api.Rand")

-- Concerns anything that has to do with map querying/manipulation.
-- @module Map
local Map = {}

function Map.is_world_map(map)
   return table.contains((map or field.map).types, "base.world_map")
end

function Map.current()
   return field.map
end

function Map.width(map)
   return (map or field.map).width
end

function Map.height(map)
   return (map or field.map).height
end

function Map.is_in_bounds(x, y, map)
   return (map or field.map):is_in_bounds(x, y)
end

function Map.has_los(x1, y1, x2, y2, map)
   return (map or field.map):is_in_fov(x1, y1, x2, y2)
end

function Map.is_in_fov(x, y, map)
   return (map or field.map):is_in_fov(x, y)
end

function Map.is_floor(x, y, map)
   return (map or field.map):can_access(x, y)
end

function Map.can_access(x, y, map)
   local Chara = require("api.Chara")
   return Map.is_in_bounds(x, y, map)
      and Map.is_floor(x, y, map)
      and Chara.at(x, y, map) == nil
end

function Map.tile(x, y, map)
   return (map or field.map):tile(x, y)
end

function Map.set_tile(x, y, id, map)
   local tile = data["base.map_tile"][id]
   if tile == nil then return end

   return (map or field.map):set_tile(x, y, tile)
end

function Map.iter_charas(map)
   return (map or field.map):iter_charas()
end

function Map.iter_items(map)
   return (map or field.map):iter_items()
end

--- Creates a new blank map.
function Map.create(width, height)
   return InstancedMap:new(width, height)
end

function Map.generate(generator_id, params)
   params = params or {}
   local generator = data["base.map_generator"]:ensure(generator_id)
   local map = generator:generate(params)
   assert_is_an(InstancedMap, map)
   return map
end

function Map.force_clear_pos(x, y, map)
   local Chara = require("api.Chara")

   if not Map.is_floor(x, y, map) then
      map:set_tile(x, y, "base.floor")
   end

   local on_cell = Chara.at(x, y, map)
   if on_cell ~= nil then
      map:remove_object(on_cell)
   end

   -- TODO: on_force_clear_pos
end

local function can_place_chara_at(chara, x, y, map)
   return Map.can_access(x, y, map)
end

local function chara_get_place_pos(chara, x, y, map)
   local Chara = require("api.Chara")

   local tries = 0
   local cx, cy

   repeat
      cx = x + Rand.rnd(tries + 1) - Rand.rnd(tries + 1)
      cy = y + Rand.rnd(tries + 1) - Rand.rnd(tries + 1)
      if can_place_chara_at(chara, cx, cy, map) then
         return cx, cy
      end
      tries = tries + 1
   until tries == 100

   if not Chara.is_in_party(chara) then
      return nil
   end

   for x=0,map.width-1 do
      for y=0,map.height-1 do
         if can_place_chara_at(chara, x, y, map) then
            return x, y
         end
      end
   end

   if not Chara.is_player(chara) then
      return nil
   end

   cx = Rand.rnd(map.width)
   cy = Rand.rnd(map.height)

   Map.force_clear_pos(cx, cy, map)

   assert(can_place_chara_at(chara, cx, cy, map))

   return cx, cy
end

local function try_place(chara, x, y, current, map)
   local real_x, real_y = chara_get_place_pos(chara, x, y, map)

   if real_x ~= nil then
      return current:transfer_to(map, chara._type, chara.uid, real_x, real_y)
   end

   return nil
end

function Map.travel_to(map)
   local current = field.map
   local x, y = 0, 0

   if type(map.player_start_pos) == "table" then
      x = map.player_start_pos.x or x
      y = map.player_start_pos.y or y
   elseif type(map.player_start_pos) == "function" then
      x, y = map.player_start_pos(field.player)
   end

   -- take the player, allies and any items they carry.
   --
   -- TODO: map objects should be transferrable (moves maps with the
   -- player) and persistable (remains in the map even after it is
   -- deleted and the map is exited).
   local player = field.player
   local allies = field.allies
   -- TODO: items

   -- Transfer each to the new map.

   field.player = try_place(field.player, x, y, current, map)
   assert(field.player ~= nil)

   for _, uid in ipairs(allies) do
      -- TODO: try to find a place to put the ally. If they can't fit,
      -- then delay adding them to the map until the player moves. If
      -- the player moves back before the allies have a chance to
      -- spawn, be sure they are still preserved.
      local ally = current:get_object("base.chara", uid)
      assert(ally ~= nil)

      local new_ally = try_place(ally, x, y, current, map)
      assert(new_ally ~= nil)
   end

   field:set_map(map)
   field:update_screen()

   return "turn_begin"
end

-- TODO: way of accessing map variables without exposing internals

return Map
