local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local Chara = require("api.Chara")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")
local util = require("mod.elona.data.map_archetype.util")

local show_house = {
   _type = "base.map_archetype",
   _id = "show_house",
   elona_id = 35,

   on_generate_map = util.generate_122("dungeon1"),
   image = "elona.feat_area_border_tent",

   starting_pos = MapEntrance.south,

   properties = {
      types = { "temporary" },
      level = 1,
      is_indoor = true,
      default_ai_calm = 1,
      tileset = "elona.home",
      reveals_fog = true,
      prevents_monster_ball = true
   }
}
data:add(show_house)

data:add {
   _type = "base.area_archetype",
   _id = "show_house",

   image = "elona.feat_area_border_tent",

   parent_area = {
      _id = "elona.north_tyris",
      on_floor = 1,
      x = 35,
      y = 27,
      starting_floor = 1
   }
}


local arena = {
   _type = "base.map_archetype",
   _id = "arena",
   elona_id = 6,

   starting_pos = MapEntrance.center,

   properties = {
      music = "elona.arena",
      types = { "temporary" },
      tileset = "elona.tower_1",
      level = 1,
      is_indoor = true,
      default_ai_calm = 0,
      max_crowd_density = 0,
      reveals_fog = true,
      prevents_domination = true,
      prevents_monster_ball = true
   }
}
function arena.on_generate(area, floor)
   local map = Elona122Map.generate("arena_1")
   map:set_archetype("elona.arena", { set_properties = true })

   -- TODO
   Chara.create("elona.putit", nil, nil, nil, map)

   return map
end

data:add(arena)


local pet_arena = {
   _type = "base.map_archetype",
   _id = "pet_arena",
   elona_id = 40,

   starting_pos = MapEntrance.stairs_up,

   properties = {
      music = "elona.arena",
      types = { "temporary" },
      tileset = "elona.tower_1",
      level = 1,
      is_indoor = true,
      default_ai_calm = 0,
      max_crowd_density = 0,
      reveals_fog = true,
      prevents_teleport = true,
      prevents_domination = true,
      prevents_monster_ball = true
   }
}
function pet_arena.on_generate(area, floor)
   local map = Elona122Map.generate("arena_2")
   map:set_archetype("elona.pet_arena", { set_properties = true })

   -- TODO
   Chara.create("elona.putit", nil, nil, nil, map)

   return map
end

data:add(pet_arena)

local quest = {
   _type = "base.map_archetype",
   _id = "quest",
   elona_id = 13,

   starting_pos = MapEntrance.center,

   properties = {
      types = { "temporary" },
      tileset = "elona.tower_1",
      level = 1,
      is_indoor = false,
      max_crowd_density = 0,
      default_ai_calm = 0,
      shows_floor_count_in_name = true,
      prevents_building_shelter = true
   }
}
data:add(quest)