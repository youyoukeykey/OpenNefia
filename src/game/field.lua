local internal = require("internal")
local startup = require("game.startup")

local Draw = require("api.Draw")
local InputHandler = require("api.gui.InputHandler")
local GameKeyHandler = require("api.gui.GameKeyHandler")
local IUiLayer = require("api.gui.IUiLayer")
local LDateTime = require("api.LDateTime")
local IInput = require("api.gui.IInput")

local env = require("internal.env")
local map = require("internal.map")
local field_renderer = require("internal.field_renderer")

local field_layer = class("field_layer", IUiLayer)

field_layer:delegate("keys", IInput)

function field_layer:init()
   self.is_active = false

   self.hud = require("api.gui.hud.MainHud"):new()

   self.map = nil
   self.renderer = nil
   self.player = nil
   self.allies = {}
   self.repl = nil

   self.map_changed = false

   self:init_global_data()

   self.keys = InputHandler:new()
   self.keys:focus()

   self.layers = {
      "internal.layer.tile_layer",
      "internal.layer.item_layer",
      "internal.layer.chara_layer",
      "internal.layer.shadow_layer",
   }
end

local global_require = require

function field_layer:setup_repl()
   -- avoid circular requires that depend on internal.field, since
   -- this auto-requires the full public API.
   local Repl = require("api.gui.menu.Repl")

   local repl_env = env.generate_sandbox("repl")
   local apis = env.require_all_apis()
   repl_env = table.merge(repl_env, apis)

   -- WARNING: for development only.
   if _DEBUG then
      repl_env["require"] = global_require
   end

   local history = {}
   local file = io.open("repl_history.txt", "r")
   if file ~= nil then
      for line in file:lines() do
         history[#history + 1] = line
      end
   end

   self.repl = Repl:new(repl_env, history)
end

function field_layer:init_global_data()
   -- TEMP: temporary storage for save-global variables. needs to be
   -- moved a public store API.
   self.data = {}
   self.data.date = LDateTime:new(517, 8, 12, 16, 10, 0)
   self.data.play_turns = 0
   self.data.play_days = 0
end

function field_layer:set_map(map)
   self.map = map
   self.renderer = field_renderer:new(map.width, map.height, self.layers)
   self.map_changed = true
end

function field_layer:relayout(x, y, width, height)
   self.x = x
   self.y = y
   self.width = width
   self.height = height
   self.hud:relayout(x, y, width, height)
end

function field_layer:turn_cost()
   return self.map.turn_cost
end

function field_layer:exists(obj)
   return self.map and self.map:exists(obj)
end

function field_layer:get_object(_type, uid)
   return self.map and self.map:get_object(_type, uid)
end

function field_layer:update_screen()
   if not self.is_active or not self.renderer then return end

   assert(self.map ~= nil)

   local player = self.player
   if player then
      self.renderer:update_draw_pos(player.x, player.y)
      self.map:calc_screen_sight(player.x, player.y, player.fov or 15)
   end

   local dt = 0
   self.renderer:update(dt)

   self:update_hud()
end

function field_layer:update_hud()
   -- HACK there is a better way of doing this. It almost certainly
   -- has to do with the event system.
   self.hud.clock:set_data(self.data.date)

   if self.player ~= nil then
      self.hud.hp_bar:set_data(self.player.hp, self.player.max_hp)
      self.hud.mp_bar:set_data(self.player.mp, self.player.max_mp)
      self.hud.level:set_data(self.player.level, self.player.experience)
      self.hud.status_effects:set_data(self.player.status_effects)
   end

   self.hud:update()
end

function field_layer:update(dt, ran_action, result)
   self.renderer:update(dt)
end

function field_layer:add_async_draw_callback(cb)
   self.renderer:add_async_draw_callback(cb)
end

function field_layer:draw()
   if self.renderer then
      self.renderer:draw()
   end

   self.hud:draw()
end

function field_layer:query_repl()
   if self.repl == nil then
      self:setup_repl()
   end
   self.repl:query()
   self.repl:save_history()
end

function field_layer:register_draw_layer(require_path)
   self.layers[#self.layers+1] = require_path
end

return field_layer:new()
