local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Map = require("api.Map")
local Input = require("api.Input")
local Anim = require("mod.elona_sys.api.Anim")
local Rand = require("api.Rand")
local Mef = require("api.Mef")
local Effect = require("mod.elona.api.Effect")
local Calc = require("mod.elona.api.Calc")
local Enum = require("api.Enum")
local Charagen = require("mod.tools.api.Charagen")
local DeferredEvents = {}

function DeferredEvents.ragnarok(chara)
   -- >>>>>>>> shade2/action.hsp:1413 	if enc=encRagnarok{ ..
   chara = chara or Chara.player()

   local tx, ty, tdx, tdy = Gui.visible_tile_bounds()

   local map = chara:current_map()
   if Map.is_world_map(map) then
      return
   end

   -- TODO weather
   Gui.mes("event.ragnarok")
   Gui.update_screen()
   Input.query_more()

   local cb = Anim.ragnarok()
   Gui.start_draw_callback(cb)

   for i = 1, 200 do
      for _ = 1, 2 do
         local x = Rand.rnd(map:width())
         local y = Rand.rnd(map:height())
         map:set_tile(x, y, "elona.destroyed")
      end

      local x = Rand.between(tx, tdx)
      local y = Rand.between(ty, tdy)
      if x < 0 or y < 0 or x >= map:width() or y >= map:height() or Rand.one_in(5) then
         x = Rand.rnd(map:width())
         y = Rand.rnd(map:height())
      end

      Mef.create("elona.fire", x, y, { duration = Rand.rnd(15) + 20, power = 50, origin = chara }, map)
      Effect.damage_map_fire(x, y)

      if (i - 1) % 4 == 0 then
         local level = 100
         local quality = Calc.calc_object_quality(Enum.Quality.Good)
         local tag_filters
         if Rand.one_in(4) then
            tag_filters = { "giant" }
         else
            tag_filters = { "dragon" }
         end

         local spawned = Charagen.create(x, y, { level = level, quality = quality, tag_filters = tag_filters })
         if spawned then
            spawned.is_summoned = true
         end
      end

      if (i - 1) % 7 == 0 then
         if Rand.one_in(7) then
            Gui.play_sound("base.crush1", x, y)
         else
            Gui.play_sound("base.fire1", x, y)
         end
         Gui.wait(25)
      end
   end
   -- <<<<<<<< shade2/action.hsp:1416 		} ..
end

return DeferredEvents
