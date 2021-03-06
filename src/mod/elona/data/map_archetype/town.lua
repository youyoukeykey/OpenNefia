local Rand = require("api.Rand")
local Chara = require("api.Chara")
local I18N = require("api.I18N")
local Sidequest = require("mod.elona_sys.sidequest.api.Sidequest")
local Item = require("api.Item")
local Text = require("mod.elona.api.Text")
local IChara = require("api.chara.IChara")
local World = require("api.World")
local util = require("mod.elona.data.map_archetype.util")
local Elona122Map = require("mod.elona_sys.map_loader.Elona122Map")
local MapEntrance = require("mod.elona_sys.api.MapEntrance")

do
   local vernis = {
      _type = "base.map_archetype",
      _id = "vernis",
      elona_id = 5,

      starting_pos = MapEntrance.edge,

      properties = {
         music = "elona.town1",
         types = { "town" },
         tileset = "elona.town",
         turn_cost = 10000,
         is_indoor = false,
         is_temporary = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 40,
      },
   }

   vernis.chara_filter = util.chara_filter_town(
      function()
         if Rand.one_in(2) then
            return { id = "elona.miner" }
         end

         return nil
      end
   )

   function vernis.on_generate_map(area, floor)
      local map = Elona122Map.generate("vernis")
      map:set_archetype("elona.vernis", { set_properties = true })

      local chara = Chara.create("elona.whom_dwell_in_the_vanity", 39, 3, nil, map)

      chara = Chara.create("elona.loyter", 42, 23, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.miches", 24, 5, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.shena", 40, 24, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.dungeon_cleaner", 40, 25, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.rilian", 30, 5, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 42, 24, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.shopkeeper", 47, 9, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.fisher" }
      chara.shop_rank = 5
      chara.name = I18N.get("chara.job.fisher", chara.name)

      chara = Chara.create("elona.shopkeeper", 14, 12, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.blacksmith" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.blacksmith", chara.name)

      chara = Chara.create("elona.shopkeeper", 39, 27, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.trader", chara.name)

      chara = Chara.create("elona.shopkeeper", 10, 15, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.general_vendor" }
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.wizard", 7, 26, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
      chara.shop_rank = 11
      chara.name = I18N.get("chara.job.magic_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 14, 25, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
      chara.roles["elona.innkeeper"] = true
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.innkeeper", chara.name)

      chara = Chara.create("elona.shopkeeper", 22, 26, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.bakery" }
      chara.shop_rank = 9
      chara.image = "elona.chara_baker"
      chara.name = I18N.get("chara.job.baker", chara.name)

      chara = Chara.create("elona.wizard", 28, 16, nil, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.bartender", 38, 27, nil, map)
      chara.roles["elona.bartender"] = true

      chara = Chara.create("elona.healer", 6, 25, nil, map)
      chara.roles["elona.healer"] = true

      chara = Chara.create("elona.elder", 10, 7, nil, map)
      chara.roles["elona.elder"] = true
      chara.name = I18N.get("chara.job.of_vernis", chara.name)

      chara = Chara.create("elona.trainer", 27, 16, nil, map)
      chara.roles["elona.trainer"] = true
      chara.name = I18N.get("chara.job.trainer", chara.name)

      chara = Chara.create("elona.informer", 25, 16, nil, map)
      chara.roles["elona.informer"] = true

      for _=1,4 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _=1,4 do
         chara = Chara.create("elona.guard", nil, nil, nil, map)
         chara.roles["elona.guard"] = true
      end

      for _=1,25 do
         util.generate_chara(map)
      end

      -- TODO only if sidequest
      --local stair = Feat.at(28, 9, map):nth(1)
      --assert(stair)
      --stair.generator_params = { generator = "base.map_template", params = { id = "elona.the_mine" }}
      --stair.area_params = { outer_map_id = map._id }

      return map
   end

   function vernis.on_map_renew_geometry(map)
      util.reload_122_map_geometry(map, "vernis")
   end

   data:add(vernis)

   data:add {
      _type = "base.area_archetype",
      _id = "vernis",
      elona_id = 5,

      image = "elona.feat_area_city",
      floors = {
         [1] = "elona.vernis"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 26,
         y = 23,
         starting_floor = 1
      }
   }
end

do
   local yowyn = {
      _id = "yowyn",
      _type = "base.map_archetype",
      elona_id = 12,

      starting_pos = MapEntrance.edge,

      properties = {
         music = "elona.village1",
         types = { "town" },
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         quest_town_id = 2,
      }
   }

   yowyn.chara_filter = util.chara_filter_town(
      function()
         if Rand.one_in(2) then
            return { id = "elona.farmer" }
         end

         return nil
      end
   )

   function yowyn.on_generate_map(area, floor)
      local map = Elona122Map.generate("yowyn")
      map:set_archetype("elona.yowyn", { set_properties = true })

      -- TODO only if sidequest
      --local stair = Feat.at(23, 22, map):nth(1)
      --stair.generator_params = { generator = "base.map_template", params = { id = "elona.cat_mansion" }}
      --stair.area_params = { outer_map_id = map._id }

      local chara = Chara.create("elona.ainc", 3, 17, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.tam", 26, 11, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.gilbert_the_colonel", 14, 20, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.shopkeeper", 11, 5, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 25, 8, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
      chara.roles["elona.innkeeper"] = true
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.inkeeper", chara.name)

      chara = Chara.create("elona.shopkeeper", 7, 8, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.goods_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 14, 14, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.trader", chara.name)

      chara = Chara.create("elona.shopkeeper", 35, 18, nil, map)
      chara.roles["elona.horse_master"] = true
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.horse_master", chara.name)

      chara = Chara.create("elona.lame_horse", 33, 16, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.lame_horse", 37, 19, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.yowyn_horse", 34, 19, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.yowyn_horse", 38, 16, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.elder", 3, 4, nil, map)
      chara.roles["elona.elder"] = true
      chara.name = I18N.get("chara.job.of_yowyn", chara.name)

      chara = Chara.create("elona.trainer", 20, 14, nil, map)
      chara.roles["elona.trainer"] = true
      chara.name = I18N.get("chara.job.trainer", chara.name)

      chara = Chara.create("elona.wizard", 24, 16, nil, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.informer", 26, 16, nil, map)
      chara.roles["elona.informer"] = true

      chara = Chara.create("elona.gwen", 14, 12, nil, map)
      chara.roles["elona.special"] = true


      for _=1,2 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _=1,3 do
         chara = Chara.create("elona.guard", nil, nil, nil, map)
         chara.roles["elona.guard"] = true
      end

      for _=1,15 do
         util.generate_chara(map)
      end

      return map
   end

   function yowyn.on_map_renew_geometry(map)
      util.reload_122_map_geometry(map, "yowyn")
   end

   data:add(yowyn)

   data:add {
      _type = "base.area_archetype",
      _id = "yowyn",
      elona_id = 12,

      image = "elona.feat_area_village",
      floors = {
         [1] = "elona.yowyn"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 43,
         y = 32,
         starting_floor = 1
      }
   }
end

do
   local palmia = {
      _id = "palmia",
      _type = "base.map_archetype",
      elona_id = 15,

      properties = {
         music = "elona.town4",
         types = { "town" },
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         max_crowd_density = 45,
         quest_town_id = 3,
      },
   }

   function palmia.starting_pos(map, chara)
      local pos = MapEntrance.edge(map, chara)
      if save.base.player_pos_on_map_leave then
         return pos
      end
      local last_dir = Chara.player().direction
      if last_dir == "East" then
         pos.y = 22
      elseif last_dir == "North" then
         pos.x = 30
      end
      return pos
   end

   palmia.chara_filter = util.chara_filter_town(
      function()
         if Rand.one_in(3) then
            return { id = "elona.noble" }
         end

         return nil
      end
   )

   function palmia.on_generate_map()
      local map = Elona122Map.generate("palmia")
      map:set_archetype("elona.palmia", { set_properties = true })

      local chara = Chara.create("elona.bartender", 42, 27, nil, map)
      chara.roles["elona.bartender"] = true

      chara = Chara.create("elona.healer", 34, 3, nil, map)
      chara.roles["elona.healer"] = true

      chara = Chara.create("elona.arena_master", 22, 31, nil, map)
      chara.roles["elona.arena_master"] = true

      chara = Chara.create("elona.erystia", 5, 15, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.mia", 41, 11, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.conery", 5, 6, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.cleaner", 24, 6, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.cleaner", 15, 22, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 15, 22, nil, map)
      chara.roles["elona.special"] = true

      if Sidequest.progress("elona.mias_dream") == 1000 then
         local silver_cat = Chara.create("elona.silver_cat", 42, 11, {}, map, nil, map)
         silver_cat.roles["elona.special"] = true
      end

      chara = Chara.create("elona.shopkeeper", 48, 18, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 30, 17, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
      chara.roles["elona.innkeeper"] = true
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.inkeeper", chara.name)

      chara = Chara.create("elona.shopkeeper", 48, 3, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.goods_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 42, 17, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.blacksmith", chara.name)

      chara = Chara.create("elona.shopkeeper", 11, 14, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.bakery" }
      chara.shop_rank = 9
      chara.image = "elona.chara_baker"
      chara.name = I18N.get("chara.job.baker", chara.name)

      chara = Chara.create("elona.wizard", 41, 3, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
      chara.shop_rank = 11
      chara.name = I18N.get("chara.job.magic_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 41, 28, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.trader", chara.name)

      chara = Chara.create("elona.stersha", 7, 2, nil, map)
      chara.roles["elona.royal_family"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.xabi", 6, 2, nil, map)
      chara.roles["elona.royal_family"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.elder", 49, 11, nil, map)
      chara.roles["elona.elder"] = true
      chara.name = I18N.get("chara.job.of_palmia", chara.name)

      chara = Chara.create("elona.trainer", 30, 27, nil, map)
      chara.roles["elona.trainer"] = true
      chara.name = I18N.get("chara.job.trainer", chara.name)

      chara = Chara.create("elona.wizard", 32, 27, nil, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.informer", 29, 28, nil, map)
      chara.roles["elona.informer"] = true

      chara = Chara.create("elona.guard", 16, 5, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 16, 9, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 5, 3, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 8, 3, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 35, 14, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 38, 14, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 29, 2, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 19, 18, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      chara = Chara.create("elona.guard", 22, 18, nil, map)
      chara.roles["elona.guard"] = true
      chara.ai_calm = 3

      for _=1,5 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _=1,4 do
         chara = Chara.create("elona.guard", nil, nil, nil, map)
         chara.roles["elona.guard"] = true
      end

      for _=1,25 do
         util.generate_chara(map)
      end

      return map
   end

   function palmia.on_map_renew_geometry(map)
      util.reload_122_map_geometry(map, "palmia")
   end

   data:add(palmia)

   data:add {
      _type = "base.area_archetype",
      _id = "palmia",

      image = "elona.feat_area_palace",

      floors = {
         [1] = "elona.palmia"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 53,
         y = 24,
         starting_floor = 1
      }
   }
end

do
   local derphy = {
      _id = "derphy",
      _type = "base.map_archetype",
      elona_id = 14,

      starting_pos = MapEntrance.edge,

      properties = {
         music = "elona.town3",
         types = { "town" },
         player_start_pos = "base.edge",
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         quest_town_id = 4,
      }
   }

   derphy.chara_filter = util.chara_filter_town(
      function()
         if Rand.one_in(3) then
            return { id = "elona.rogue" }
         elseif Rand.one_in(2) then
            return { id = "elona.prostitute" }
         end
      end
   )

   function derphy.on_generate_map()
      local map = Elona122Map.generate("rogueden")
      map:set_archetype("elona.derphy", { set_properties = true })

      local chara = Chara.create("elona.marks", 23, 14, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.noel", 13, 18, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.abyss", 16, 17, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.shopkeeper", 10, 17, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.trader", chara.name)

      chara = Chara.create("elona.bartender", 15, 15, nil, map)
      chara.roles["elona.bartender"] = true

      chara = Chara.create("elona.shopkeeper", 13, 3, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 29, 23, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
      chara.roles["elona.innkeeper"] = true
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.inkeeper", chara.name)

      chara = Chara.create("elona.shopkeeper", 26, 7, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.goods_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 30, 4, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.blackmarket", chara.name)

      chara = Chara.create("elona.shopkeeper", 29, 4, nil, map)
      chara.roles["elona.slaver"] = true
      chara.name = I18N.get("chara.job.slave_master", chara.name)

      chara = Chara.create("elona.shopkeeper", 10, 6, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.blacksmith", chara.name)

      chara = Chara.create("elona.arena_master", 7, 15, nil, map)
      chara.roles["elona.arena_master"] = true

      chara = Chara.create("elona.elder", 9, 18, nil, map)
      chara.roles["elona.elder"] = true
      chara.name = I18N.get("chara.job.of_derphy", chara.name)

      chara = Chara.create("elona.trainer", 13, 18, nil, map)
      chara.roles["elona.trainer"] = true
      chara.name = I18N.get("chara.job.trainer", chara.name)

      chara = Chara.create("elona.wizard", 5, 26, nil, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.informer", 3, 28, nil, map)
      chara.roles["elona.informer"] = true

      for _=1,4 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _=1,20 do
         util.generate_chara(map)
      end

      return map
   end

   function derphy.on_map_renew_geometry(map)
      util.reload_122_map_geometry(map, "rogueden")
   end

   data:add(derphy)

   data:add {
      _type = "base.area_archetype",
      _id = "derphy",

      image = "elona.feat_area_village",

      floors = {
         [1] = "elona.derphy"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 14,
         y = 35,
         starting_floor = 1
      }
   }
end

do
   local port_kapul = {
      _id = "port_kapul",
      _type = "base.map_archetype",
      elona_id = 11,

      starting_pos = MapEntrance.edge,

      properties = {
         music = "elona.town2",
         types = { "town" },
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         quest_town_id = 5,
      }
   }

   port_kapul.chara_filter = util.chara_filter_town()

   function port_kapul.on_generate_map()
      local map = Elona122Map.generate("kapul")
      map:set_archetype("elona.port_kapul", { set_properties = true })

      local chara = Chara.create("elona.raphael", 15, 18, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.arnord", 36, 27, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.icolle", 5, 26, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.doria", 29, 3, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.cleaner", 24, 21, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.cleaner", 12, 26, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.cleaner", 8, 11, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 8, 14, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.shopkeeper", 16, 17, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.trader", chara.name)

      chara = Chara.create("elona.shopkeeper", 23, 7, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.blacksmith", chara.name)

      chara = Chara.create("elona.shopkeeper", 32, 14, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 22, 14, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.goods_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.goods_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 16, 25, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blackmarket"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.blackmarket", chara.name)

      chara = Chara.create("elona.shopkeeper", 17, 28, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.food_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.food_vendor", chara.name)

      chara = Chara.create("elona.wizard", 22, 22, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
      chara.shop_rank = 11
      chara.name = I18N.get("chara.job.magic_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 35, 3, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
      chara.roles["elona.innkeeper"] = true
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.innkeeper", chara.name)

      chara = Chara.create("elona.bartender", 15, 15, nil, map)
      chara.roles["elona.bartender"] = true

      chara = Chara.create("elona.arena_master", 26, 3, nil, map)
      chara.roles["elona.arena_master"] = true

      chara = Chara.create("elona.pet_arena_master", 25, 4, nil, map)
      chara.roles["elona.arena_master"] = true

      chara = Chara.create("elona.elder", 8, 12, nil, map)
      chara.roles["elona.elder"] = true
      chara.name = I18N.get("chara.job.of_port_kapul", chara.name)

      chara = Chara.create("elona.trainer", 16, 4, nil, map)
      chara.roles["elona.trainer"] = true
      chara.name = I18N.get("chara.job.trainer", chara.name)

      chara = Chara.create("elona.wizard", 14, 4, nil, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.informer", 17, 5, nil, map)
      chara.roles["elona.informer"] = true

      chara = Chara.create("elona.healer", 27, 11, nil, map)
      chara.roles["elona.healer"] = true

      for _=1,2 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _=1,4 do
         chara = Chara.create("elona.sailor", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _=1,5 do
         chara = Chara.create("elona.guard_port_kapul", nil, nil, nil, map)
         chara.roles["elona.guard"] = true
      end

      chara = Chara.create("elona.captain", 7, 6, nil, map)
      chara.roles["elona.citizen"] = true

      for _=1,20 do
         util.generate_chara(map)
      end

      return map
   end

   function port_kapul.on_map_renew_geometry(map)
      util.reload_122_map_geometry(map, "kapul")
   end

   data:add(port_kapul)

   data:add {
      _type = "base.area_archetype",
      _id = "port_kapul",

      image = "elona.feat_area_city",

      floors = {
         [1] = "elona.port_kapul"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 3,
         y = 15,
         starting_floor = 1
      }
   }
end

do
   local noyel = {
      _id = "noyel",
      _type = "base.map_archetype",
      elona_id = 33,

      properties = {
         music = "elona.town6",
         types = { "town" },
         tileset = "elona.town",
         level = 1,
         deepest_dungeon_level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         quest_town_id = 6,
         villagers_make_snowmen = true,
         max_crowd_density = 35,
      }
   }

   function noyel.starting_pos(map, chara)
      local pos = MapEntrance.edge(map, chara)
      if save.base.player_pos_on_map_leave then
         return pos
      end
      local last_dir = Chara.player().direction
      if last_dir == "East" then
         pos.y = 3
      elseif last_dir == "North" then
         pos.x = 28
      elseif last_dir == "South" then
         pos.x = 5
      end
      return pos
   end

   noyel.chara_filter = util.chara_filter_town(
      function()
         if Rand.one_in(3) then
            return { id = "elona.sister" }
         end
      end
   )

   function noyel.on_generate_map()
      local map = Elona122Map.generate("noyel")
      map:set_archetype("elona.noyel", { set_properties = true })

      local chara = Chara.create("elona.ebon", 46, 18, {}, map)
      chara.roles["elona.special"] = true
      save.elona.fire_giant_uid = chara.uid

      chara = Chara.create("elona.moyer_the_crooked", 47, 18, {}, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.moyer"}

      chara = Chara.create("elona.town_child", 47, 20, {}, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.town_child", 15, 19, {}, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.town_child", 49, 20, {}, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 28, 22, {}, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.pael", 19, 3, {}, map)
      chara.roles["elona.special"] = true

      -- TODO sidequest
      if true then
         chara = Chara.create("elona.lily", 19, 2, {}, map)
         chara.roles["elona.special"] = true
      end

      chara = Chara.create("elona.bartender", 40, 33, {}, map)
      chara.roles["elona.bartender"] = true

      chara = Chara.create("elona.healer", 44, 6, {}, map)
      chara.roles["elona.healer"] = true

      chara = Chara.create("elona.healer", 44, 3, {}, map)
      chara.roles["elona.nun"] = true

      chara = Chara.create("elona.shopkeeper", 19, 31, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.blacksmith", chara.name)

      chara = Chara.create("elona.shopkeeper", 11, 31, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 38, 34, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
      chara.roles["elona.innkeeper"] = true
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.inkeeper", chara.name)

      chara = Chara.create("elona.shopkeeper", 5, 27, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.bakery" }
      chara.shop_rank = 9
      chara.image = "elona.chara_baker"
      chara.name = I18N.get("chara.job.baker", chara.name)

      chara = Chara.create("elona.wizard", 56, 5, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
      chara.shop_rank = 11
      chara.name = I18N.get("chara.job.magic_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 39, 35, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.trader", chara.name)

      chara = Chara.create("elona.elder", 5, 18, nil, map)
      chara.roles["elona.elder"] = true
      chara.name = I18N.get("chara.job.of_noyel", chara.name)

      chara = Chara.create("elona.trainer", 18, 20, nil, map)
      chara.roles["elona.trainer"] = true
      chara.name = I18N.get("chara.job.trainer", chara.name)

      chara = Chara.create("elona.wizard", 4, 33, nil, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.informer", 6, 33, nil, map)
      chara.roles["elona.informer"] = true

      for _ = 1, 3 do
         chara = Chara.create("elona.citizen", Rand.rnd(32), Rand.rnd(map:height()), nil, map)
         chara.roles["elona.citizen"] = true

         chara = Chara.create("elona.citizen2", Rand.rnd(32), Rand.rnd(map:height()), nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _ = 1, 3 do
         chara = Chara.create("elona.guard", Rand.rnd(32), Rand.rnd(map:height()), nil, map)
         chara.roles["elona.guard"] = true
      end

      for _ = 1, 8 do
         chara = util.generate_chara(map, Rand.rnd(11) + 25, Rand.rnd(5) + 15, { id = "elona.town_child" })
         chara.roles["elona.special"] = true
      end

      for _ = 1, 20 do
         util.generate_chara(map, Rand.rnd(55), Rand.rnd(map:height()))
      end

      return map
   end

   local function reload_noyel_christmas(map)
      local item = Item.create("elona.pedestal", 29, 16, nil, map)
      item.own_state = "not_owned"

      item = Item.create("elona.statue_of_jure", 29, 16, nil, map)
      item.own_state = "not_owned"

      item = Item.create("elona.altar", 29, 17, nil, map)
      item.own_state = "not_owned"
      item.params = { god_id = "elona.jure" }

      item = Item.create("elona.mochi", 29, 17, nil, map)
      item.own_state = "unobtainable"

      local chara = Chara.create("elona.kaneda_bike", 48, 19, nil, map)
      chara.roles["elona.special"] = true
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.part_time_worker", 30, 17, nil, map)
      chara.roles["elona.special"] = true
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.punk", 38, 19, nil, map)
      chara.is_only_in_christmas = true
      chara.is_hung_on_sandbag = true
      chara.name = I18N.get("chara.job.fanatic")

      chara = Chara.create("elona.fanatic", 35, 19, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.fanatic", 37, 18, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.fanatic", 37, 21, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.fanatic", 39, 20, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.fanatic", 38, 21, nil, map)
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.bartender", 17, 8, nil, map)
      chara.ai_calm = 3
      chara.is_only_in_christmas = true
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.food_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.food_vendor", chara.name)

      chara = Chara.create("elona.hot_spring_maniac", 25, 8, nil, map)
      chara.ai_calm = 3
      chara.faction = "base.citizen"
      chara.is_only_in_christmas = true
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.souvenir_vendor"}
      chara.shop_rank = 30
      chara.name = I18N.get("chara.job.souvenir_vendor", Text.random_name())

      chara = Chara.create("elona.rogue", 24, 22, nil, map)
      chara.ai_calm = 3
      chara.faction = "base.citizen"
      chara.is_only_in_christmas = true
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.souvenir_vendor"}
      chara.shop_rank = 30
      chara.name = I18N.get("chara.job.souvenir_vendor", Text.random_name())

      chara = Chara.create("elona.shopkeeper", 38, 12, nil, map)
      chara.ai_calm = 3
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.blackmarket"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.blackmarket", Text.random_name())
      chara.is_only_in_christmas = true

      chara = Chara.create("elona.rogue", 28, 9, nil, map)
      chara.ai_calm = 3
      chara.faction = "base.citizen"
      chara.is_only_in_christmas = true
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.street_vendor"}
      chara.shop_rank = 30
      chara.name = I18N.get("chara.job.street_vendor", Text.random_name())

      chara = Chara.create("elona.rogue", 29, 24, nil, map)
      chara.ai_calm = 3
      chara.faction = "base.citizen"
      chara.is_only_in_christmas = true
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.street_vendor"}
      chara.shop_rank = 30
      chara.name = I18N.get("chara.job.street_vendor2", Text.random_name())

      for _ = 1, 20 do
         chara = Chara.create("elona.holy_beast", nil, nil, nil, map)
         chara.is_only_in_christmas = true

         chara = Chara.create("elona.festival_tourist", nil, nil, nil, map)
         chara.is_only_in_christmas = true
      end

      for _ = 1, 15 do
         chara = Chara.create("elona.bard", nil, nil, nil, map)
         chara.is_only_in_christmas = true
      end

      for _ = 1, 7 do
         chara = Chara.create("elona.prostitute", nil, nil, nil, map)
         chara.is_only_in_christmas = true

         chara = Chara.create("elona.tourist", nil, nil, nil, map)
         chara.is_only_in_christmas = true

         chara = Chara.create("elona.noble", nil, nil, nil, map)
         chara.is_only_in_christmas = true

         chara = Chara.create("elona.punk", nil, nil, nil, map)
         chara.is_only_in_christmas = true
      end

      for _ = 1, 3 do
         chara = Chara.create("elona.stray_cat", nil, nil, nil, map)
         chara.is_only_in_christmas = true

         chara = Chara.create("elona.tourist", nil, nil, nil, map)
         chara.is_only_in_christmas = true
      end
   end

   local function reload_noyel(map)
      Chara.iter_others(map)
      :filter(function(c) return c.is_only_in_christmas end)
         :each(IChara.vanquish)
   end

   function noyel.on_map_renew_geometry(map)
      for _, item in Item.iter_ground(map) do
         if item.id ~= "elona.shelter" and item.id ~= "elona.giants_shackle" then
            item:remove()
         end
      end

      if World.date().month == 12 then
         if not map.is_noyel_christmas_festival then
            map.is_noyel_christmas_festival = true
            reload_noyel_christmas(map)
         end
         util.reload_122_map_geometry(map, "noyel_fest")
      else
         if map.is_noyel_christmas_festival then
            map.is_noyel_christmas_festival = false
            reload_noyel(map)
         end
         util.reload_122_map_geometry(map, "noyel")
      end
   end

   data:add(noyel)

   data:add {
      _type = "base.area_archetype",
      _id = "noyel",

      image = "elona.feat_area_village_snow",

      floors = {
         [1] = "elona.noyel"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 89,
         y = 14,
         starting_floor = 1
      }
   }
end

do
   local lumiest = {
      _id = "lumiest",
      _type = "base.map_archetype",
      elona_id = 36,

      properties = {
         music = "elona.town2",
         types = { "town" },
         tileset = "elona.town",
         level = 1,
         is_indoor = false,
         has_anchored_npcs = true,
         default_ai_calm = 1,
         quest_town_id = 7,
      }
   }

   function lumiest.starting_pos(map, chara)
      local pos = MapEntrance.edge(map, chara)
      if save.base.player_pos_on_map_leave then
         return pos
      end
      local last_dir = Chara.player().direction
      if last_dir == "West" then
         pos.x = 58
         pos.y = 21
      elseif last_dir == "East" then
         pos.x = 25
         pos.y = 1
      elseif last_dir == "North" then
         pos.x = 58
         pos.y = 21
      elseif last_dir == "South" then
         pos.x = 25
         pos.y = 1
      end
      return pos
   end

   lumiest.chara_filter = util.chara_filter_town(
      function()
         if Rand.one_in(3) then
            return { id = "elona.artist" }
         end
      end
   )

   function lumiest.on_generate_map()
      local map = Elona122Map.generate("lumiest")
      map:set_archetype("elona.lumiest", { set_properties = true })

      -- TODO only if sidequest
      --local stair = Feat.at(18, 45, map):nth(1)
      --assert(stair)
      --stair.generator_params = { generator = "base.map_template", params = { id = "elona.the_sewer" }}
      --stair.area_params = { outer_map_id = map._id }

      local chara = Chara.create("elona.renton", 12, 24, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.balzak", 21, 3, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.lexus", 5, 20, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.cleaner", 28, 29, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 41, 19, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 32, 43, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 29, 28, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 16, 45, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bard", 13, 24, nil, map)
      chara.roles["elona.special"] = true

      chara = Chara.create("elona.bartender", 41, 42, nil, map)
      chara.roles["elona.bartender"] = true

      chara = Chara.create("elona.healer", 10, 16, nil, map)
      chara.roles["elona.healer"] = true

      chara = Chara.create("elona.shopkeeper", 47, 30, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id="elona.general_vendor"}
      chara.shop_rank = 10
      chara.name = I18N.get("chara.job.general_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 24, 47, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.innkeeper" }
      chara.roles["elona.innkeeper"] = true
      chara.shop_rank = 8
      chara.name = I18N.get("chara.job.inkeeper", chara.name)

      chara = Chara.create("elona.shopkeeper", 37, 30, nil, map)
      chara.roles["elona.shopkeeper"] = {inventory_id = "elona.blacksmith"}
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.blacksmith", chara.name)

      chara = Chara.create("elona.shopkeeper", 37, 12, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.bakery" }
      chara.shop_rank = 9
      chara.image = "elona.chara_baker"
      chara.name = I18N.get("chara.job.baker", chara.name)

      chara = Chara.create("elona.wizard", 6, 15, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.magic_vendor" }
      chara.shop_rank = 11
      chara.name = I18N.get("chara.job.magic_vendor", chara.name)

      chara = Chara.create("elona.shopkeeper", 33, 43, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.trader" }
      chara.shop_rank = 12
      chara.name = I18N.get("chara.job.trader", chara.name)

      chara = Chara.create("elona.shopkeeper", 47, 12, nil, map)
      chara.roles["elona.shopkeeper"] = { inventory_id = "elona.fisher" }
      chara.shop_rank = 5
      chara.name = I18N.get("chara.job.fisher", chara.name)

      chara = Chara.create("elona.elder", 3, 38, nil, map)
      chara.roles["elona.elder"] = true
      chara.name = I18N.get("chara.job.of_lumiest", chara.name)

      chara = Chara.create("elona.trainer", 21, 28, nil, map)
      chara.roles["elona.trainer"] = true
      chara.name = I18N.get("chara.job.trainer", chara.name)

      chara = Chara.create("elona.wizard", 21, 30, nil, map)
      chara.roles["elona.wizard"] = true

      chara = Chara.create("elona.informer", 23, 38, nil, map)
      chara.roles["elona.informer"] = true

      for _=1,6 do
         chara = Chara.create("elona.citizen", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true

         chara = Chara.create("elona.citizen2", nil, nil, nil, map)
         chara.roles["elona.citizen"] = true
      end

      for _=1,7 do
         chara = Chara.create("elona.guard", nil, nil, nil, map)
         chara.roles["elona.guard"] = true
      end

      for _=1,25 do
         util.generate_chara(map)
      end

      return map
   end

   function lumiest.on_map_renew_geometry(map)
      util.reload_122_map_geometry(map, "lumiest")
   end

   data:add(lumiest)

   data:add {
      _type = "base.area_archetype",
      _id = "lumiest",

      image = "elona.feat_area_city",

      floors = {
         [1] = "elona.lumiest"
      },

      parent_area = {
         _id = "elona.north_tyris",
         on_floor = 1,
         x = 61,
         y = 32,
         starting_floor = 1
      }
   }
end
