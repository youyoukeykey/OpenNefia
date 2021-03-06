local Chara = require("api.Chara")
local Gui = require("api.Gui")
local Map = require("api.Map")

local Sidequest = {}

function Sidequest.progress(sidequest_id)
   data["elona_sys.sidequest"]:ensure(sidequest_id)
   local sq = save.elona_sys.sidequest[sidequest_id]
   if sq == nil then
      return 0
   end

   return sq.progress
end

function Sidequest.set_progress(sidequest_id, progress)
   local sidequest_data = data["elona_sys.sidequest"]:ensure(sidequest_id)
   progress = math.floor(progress or 0)
   assert(type(progress) == "number")
   assert(progress == 0 or sidequest_data.progress[progress],
          ("Invalid sidequest progress %d (%s)"):format(progress, sidequest_id))

   local sidequest = save.elona_sys.sidequest
   if sidequest[sidequest_id] == nil then
      sidequest[sidequest_id] = {}
   end
   sidequest[sidequest_id].progress = progress
end

function Sidequest.set_quest_targets(map)
   map = map or Map.current()

   for _, v in Chara.iter_others(map) do
      if Chara.is_alive(v, map) then
         v.is_quest_target = true
         v.faction = "base.enemy"
         v:mod_reaction_at(Chara.player(), -1000)
      end
   end
end

function Sidequest.no_targets_remaining(map)
   map = map or Map.current()

   for _, v in Chara.iter(map) do
      if Chara.is_alive(v, map) and v.is_quest_target then
         return false
      end
   end

   return true
end

function Sidequest.update_journal()
   Gui.play_sound("base.write1");
   Gui.mes_c("quest.journal_updated", "Green");
end

return Sidequest
