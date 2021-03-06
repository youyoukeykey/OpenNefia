local Action = require("api.Action")
local Chara = require("api.Chara")
local Event = require("api.Event")
local Gui = require("api.Gui")
local Input = require("api.Input")
local Item = require("api.Item")
local Map = require("api.Map")
local Pos = require("api.Pos")
local EquipmentMenu = require("api.gui.menu.EquipmentMenu")
local Save = require("api.Save")
local FieldMap = require("mod.elona.api.FieldMap")
local elona_Magic = require("mod.elona.api.Magic")
local QuickMenuPrompt = require("api.gui.QuickMenuPrompt")
local Log = require("api.Log")
local Area = require("api.Area")

--- Game logic intended for the player only.
local Command = {}

local function travel_to_map_hook(source, params, result)
   local cur = Map.current()

   local _, outer_map = assert(Map.load_parent_map(cur))
   local x, y = Map.position_in_parent_map(cur)
   if not x and y then
      Log.error("No position in parent map, defaulting to center.")
      x = outer_map:width() / 2
      y = outer_map:height() / 2
   end

   save.base.player_pos_on_map_leave = { x = Chara.player().x, y = Chara.player().y }

   assert(Map.travel_to(outer_map, { start_x = x, start_y = y }))

   return {true, "player_turn_query"}
end

local hook_travel_to_map = Event.define_hook("travel_to_map",
                                        "Hook when traveling to a new map.",
                                        { false, "Error running hook." },
                                        nil,
                                        travel_to_map_hook)

local hook_player_move = Event.define_hook("player_move",
                                      "Hook when the player moves.",
                                      nil,
                                      "pos")

Event.register("elona_sys.hook_player_move", "Player scroll speed",
               function(_, params, result)
                  local scroll = 10
                  local start_run_wait = 2
                  if Gui.key_held_frames() > start_run_wait then
                     scroll = 6
                  end

                  if Gui.player_is_running() then
                     scroll = 1
                  end

                  params.chara:mod("scroll", scroll, "set")

                  return result
               end)

function Command.move(player, x, y)
   if type(x) == "string" then
      x, y = Pos.add_direction(x, player.x, player.y)
   end

   player.direction = Pos.pack_direction(Pos.direction_in(player.x, player.y, x, y))

   -- Try to modify the final position.
   local next_pos = hook_player_move({chara=player}, {pos={x=x,y=y}})

   -- EVENT: before_player_move_check (player)
   -- dimmed
   -- drunk
   -- confusion
   -- mount
   -- overburdened

   -- At this point the next position is final.

   local on_cell = Chara.at(next_pos.x, next_pos.y)
   if on_cell then
      local result = player:emit("elona_sys.on_player_bumped_into_chara", {chara=on_cell}, "turn_end")

      return result
   end

   -- >>>>>>>> shade2/action.hsp:581 	if (gLevel=1)or(mType=mTypeField):if mType!mTypeW ..
   local map = player:current_map()
   local parent_area = Area.parent(map)
   local can_exit_from_edge = Area.floor_number(map) == 1 and not Map.is_world_map(map)

   if not Map.is_in_bounds(next_pos.x, next_pos.y, map)
      and (can_exit_from_edge or not map.is_indoor)
      and parent_area ~= nil
   then
      -- Player is trying to move out of the map.

      Event.trigger("elona_sys.before_player_map_leave", {player=player})

      if Input.yes_no() then
         Gui.play_sound("base.exitmap1")
         Gui.update_screen()

         local success, result = table.unpack(hook_travel_to_map())

         if not success then
            Gui.report_error(result)
            return "player_turn_query"
         end

         return result
      end

      return "player_turn_query"
   else
      for _, obj in Map.current():objects_at_pos(next_pos.x, next_pos.y) do
         if obj:calc("is_solid") then
            Input.halt_input()
            local result = obj:emit("elona_sys.on_bump_into", {chara=player}, nil)
            if result then
               return "turn_end"
            end
         end
      end

      -- Run the general-purpose movement command. This will also
      -- handle blocked tiles.

      Action.move(player, next_pos.x, next_pos.y)
      Gui.set_scroll()
   end

   -- proc confusion text

   return "turn_end"
   -- >>>>>>>> shade2/action.hsp:598 		} ..
end

function Command.get(player)
   -- TODO: plants
   -- traps
   -- buildings
   -- snow

   local items = Item.at(player.x, player.y):to_list()
   if #items == 0 then
      Gui.mes("action.get.air")
      return "turn_end"
   end

   if #items == 1 then
      local item = items[1]
      Item.activate_shortcut(item, "elona.inv_get", { chara = player })
      return "turn_end"
   end

   local result, canceled = Input.query_inventory(player, "elona.inv_get", nil, nil)
   if canceled then
      return nil, canceled
   end
   return result.result
end

function Command.drop(player)
   local result, canceled = Input.query_inventory(player, "elona.inv_drop", nil, "elona.main")
   if canceled then
      return nil, canceled
   end
   return result.result
end

function Command.wear(player)
   return EquipmentMenu:new(player):query()
end

local function feats_surrounding(player, field)
   local Feat = require("api.Feat")
   return Pos.iter_surrounding(player.x, player.y):flatmap(Feat.at):filter(function(f) return f:calc(field) end)
end

local function feats_under(player, field)
   local Feat = require("api.Feat")
   return Feat.at(player.x, player.y):filter(function(f) return f:calc(field) end)
end

function Command.close(player)
   local f = feats_surrounding(player, "can_close"):nth(1)
   if f then
      if Chara.at(f.x, f.y) then
         Gui.mes("action.close.blocked")
      else
         f:emit("elona_sys.on_feat_close", {chara=player})
      end
   end
end

function Command.search(player)
   local Feat = require("api.Feat")

   for j = 0, 10 do
      local y = player.y + j - 5
      if not (y < 0 or y >= player:current_map():height()) then
         for i = 0, 10 do
            local x = player.x + i - 5
            if not (x < 0 or x >= player:current_map():width()) then
               for _, f in Feat.at(x, y) do
                  f:emit("elona_sys.on_feat_search", {chara=player})
               end
            end
         end
      end
   end

   player:emit("elona_sys.on_search")
end

function Command.open(player)
   for _, f in feats_surrounding(player, "can_open") do
      Gui.mes(player.name .. " opens the " .. f.uid .. " ")
      f:emit("elona_sys.on_feat_open", {chara=player})
   end
end

local function activate(player, feat)
   Gui.mes(player.name .. " activates the " .. feat.uid .. " ")
   feat:emit("elona_sys.on_feat_activate", {chara=player})
end

function Command.enter_action(player)
   -- TODO iter objects on square, emit get_enter_action
   local f = feats_under(player, "can_activate"):nth(1)
   if f then
      activate(player, f)
      return "player_turn_query" -- TODO could differ per feat
   end

   local is_world_map = Map.current():has_type("world_map")

   if is_world_map then
      local stood_tile = Map.tile(player.x, player.y)
      local map = FieldMap.generate(stood_tile, 34, 22, Map.current())

      Gui.play_sound("base.exitmap1")
      assert(Map.travel_to(map))

      return "turn_begin"
   end

   return "player_turn_query"
end

function Command.help()
   local HelpMenuView = require("api.gui.menu.HelpMenuView")
   local SidebarMenu = require("api.gui.menu.SidebarMenu")

   local view = HelpMenuView:new()
   SidebarMenu:new(view:get_sections(), view):query()

   return "player_turn_query"
end

function Command.save_game()
   Save.save_game()
   return "player_turn_query"
end

function Command.load_game()
   Save.load_game()
   return "turn_begin"
end

function Command.quit_game()
   Gui.mes_newline()
   Gui.mes("Do you want to save the game and exit? ")
   if Input.yes_no() then
      return "quit"
   end
   return "player_turn_query"
end

local CharacterInfoWrapper = require("api.gui.menu.CharacterInfoWrapper")

function Command.chara_info()
   CharacterInfoWrapper:new():query()
   return "player_turn_query"
end

local SpellsWrapper = require("api.gui.menu.SpellsWrapper")

local function handle_spells_result(result, chara)
   local command_type = result.type
   local skill_id = result._id

   if command_type == "spell" then
      local did_something = elona_Magic.cast_spell(skill_id, chara, false)
      if did_something then
         return "turn_end"
      end
      return "player_turn_query"
   elseif command_type == "skill" then
      local did_something = elona_Magic.do_action(skill_id, chara)
      if did_something then
         return "turn_end"
      end
      return "player_turn_query"
   end

   error("unknown spell result")
end

function Command.cast(player)
   local result, canceled = SpellsWrapper:new(1):query()
   if canceled then
      return "player_turn_query"
   end
   return handle_spells_result(result, player)
end

function Command.skill(player)
   local result, canceled = SpellsWrapper:new(2):query()
   if canceled then
      return "player_turn_query"
   end
   return handle_spells_result(result, player)
end

function Command.target(player)
   local x, y, can_see = Input.query_position()

   if x then
      if not can_see or not Map.is_floor(x, y) then
         Gui.mes("action.which_direction.cannot_see_location")
      else
         Gui.play_sound("base.ok1")
         local chara = Chara.at(x, y)
         if chara and not chara:is_player() then
            player:set_target(chara)
            Gui.mes("action.look.target", chara)
         else
            player.target_location = { x = x, y = y }
            Gui.mes("action.look.target_ground")
         end
      end
   end

   return "player_turn_query"
end

function Command.look(player)
   if Map.is_world_map() then
      Input.query_position()
   else
      local target, canceled = Input.query_target()
      if target then
         player:set_target(target)
         Gui.play_sound("base.ok1")
         Gui.mes("action.look.target", target)
      end
   end

   return "player_turn_query"
end

function Command.quick_menu(player)
   local action, canceled = QuickMenuPrompt:new():query()
   if canceled then
      return "player_turn_query"
   end

   local did_something, result = Gui.run_keybind_action(action, player)
   if did_something then
      return result
   end

   Log.warn("No keybind action found for '%s'", action)

   return "player_turn_query"
end


return Command
