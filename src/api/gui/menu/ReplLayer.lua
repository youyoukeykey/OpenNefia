local Draw = require("api.Draw")
local Env = require("api.Env")
local Gui = require("api.Gui")
local Object = require("api.Object")
local Ui = require("api.Ui")
local circular_buffer = require("thirdparty.circular_buffer")

local IUiLayer = require("api.gui.IUiLayer")
local IInput = require("api.gui.IInput")
local InputHandler = require("api.gui.InputHandler")
local UiWindow = require("api.gui.UiWindow")
local LuaReplMode = require("api.gui.menu.LuaReplMode")
local UiList = require("api.gui.UiList")
local TextHandler = require("api.gui.TextHandler")
local ReplCompletion = require("api.gui.menu.ReplCompletion")

local ReplLayer = class.class("ReplLayer", IUiLayer)

ReplLayer:delegate("input", IInput)

function ReplLayer:init(env, history)
   self.text = ""
   self.env = env or {}
   self.result = ""
   self.size = 10000
   self.color = {17, 17, 65, 192}

   self.scrollback = circular_buffer:new(self.size)
   self.scrollback_index = 0

   self.history = history or {}
   self.history_index = 0

   -- quake pulldown
   self.pulldown = true
   self.pulldown_y = 0
   self.pulldown_speed = 8
   self.frames = 0

   -- line editing support
   self.cursor_pos = 0
   self.cursor_x = 0

   -- tab completion
   self.completion_candidates = nil
   self.selected_candidate = 1

   -- mode of operation. could implement Elona-style console if
   -- desired.
   self.mode = LuaReplMode:new(env)

   self.input = InputHandler:new(TextHandler:new())
   self.input:bind_keys {
      text_entered = function(t)
         self:insert_text(t)
      end,
      backspace = function()
         self:delete_char()
      end,
      text_submitted = function()
         self:submit()
         local res, err = pcall(Gui.update_screen)
         if not res then
            self:print("[DRAW ERROR] " .. err)
         end
         self.input:halt_input()
      end,
      text_canceled = function()
         self.finished = true
      end,
      up = function()
         self:history_next()
      end,
      down = function()
         self:history_prev()
      end,
      left = function()
         self:move_cursor(-1)
      end,
      right = function()
         self:move_cursor(1)
      end,
      pageup = function()
         self:scrollback_up()
      end,
      pagedown = function()
         self:scrollback_down()
      end,
      home = function()
         self:set_cursor_pos(0)
      end,
      ["end"] = function()
         self:set_cursor_pos(#self.text)
      end,
      tab = function()
         if not self.completion_candidates then
            local cp = ReplCompletion:new()
            self.completion_candidates = cp:complete(self.text, self.env)
            self.selected_candidate = 1
         else
            self.selected_candidate =
               (self.selected_candidate + 1) % #self.completion_candidates
         end
      end
   }
   self.input:halt_input()
end

function ReplLayer:on_query()
   self.completion_candidates = nil
   if self.scrollback:len() == 0 then
      self:print(string.format("Elona_next(仮 REPL\nVersion: %s  LÖVE version: %s  Lua version: %s  OS: %s",
                               Env.version(), Env.love_version(), Env.lua_version(), Env.os()))
   end
end

function ReplLayer:history_prev()
   self.scrollback_index = 0
   self.history_index = math.max(self.history_index - 1, 0)
   self:set_text(self.history[self.history_index])
end

function ReplLayer:history_next()
   self.scrollback_index = 0
   self.history_index = math.min(self.history_index + 1, #self.history)
   self:set_text(self.history[self.history_index])
end

function ReplLayer:set_text(text)
   self.text = text or ""

   self:set_cursor_pos(#self.text)
end

function ReplLayer:scrollback_up()
   self.scrollback_index = math.clamp(self.scrollback_index + math.floor(self.max_lines / 2),
                                      0,
                                      math.max(self.scrollback:len() - self.max_lines, 0))
end

function ReplLayer:scrollback_down()
   self.scrollback_index = math.clamp(self.scrollback_index - math.floor(self.max_lines / 2),
                                      0,
                                      math.max(self.scrollback:len() - self.max_lines, 0))
end

function ReplLayer:clear()
   self.scrollback = circular_buffer:new(self.size)
   self.scrollback_index = 0

   self:set_text("")
end

function ReplLayer:move_cursor(codepoints)
   local pos = utf8.find_next_pos(self.text, self.cursor_pos, codepoints)
   if codepoints > 0 and pos == 0 then
      pos = utf8.offset(self.text, 1)
   end
   if pos < 1 then
      self.cursor_pos = 0
      self.cursor_x = 0
      return
   end

   self:set_cursor_pos(pos)
end

function ReplLayer:insert_text(t)
   if self.cursor_pos == #self.text then
      self.text = self.text .. t
   elseif self.cursor_pos == 0 then
      self.text = t .. self.text
   else
      local a, b = string.split_at_pos(self.text, self.cursor_pos)
      self.text = a .. t .. b
   end

   self:move_cursor(utf8.len(t))
end

function ReplLayer:delete_char()
   if self.cursor_pos == 0 then
      return
   end

   if self.cursor_pos == #self.text then
      self.text = utf8.pop(self.text)
   elseif self.cursor_pos == 1 then
      self.text = utf8.sub(self.text, 2)
   else
      local a, b = string.split_at_pos(self.text, self.cursor_pos)
      a = utf8.sub(a, 1, utf8.len(a)-1)
      self.text = a .. b
   end

   self:move_cursor(-1)
end

function ReplLayer:set_cursor_pos(byte)
   self.cursor_pos = math.clamp(0, byte, #self.text)

   Draw.set_font(self.font_size)
   local rest = string.sub(self.text, 0, self.cursor_pos)
   self.cursor_x = Draw.text_width(rest)
   self.frames = 0
end

function ReplLayer:relayout(x, y, width, height)
   self.x = 0
   self.y = 0
   self.width = Draw.get_width()
   self.height = Draw.get_height() / 3
   self.font_size = 15
   Draw.set_font(self.font_size)
   self.max_lines = math.floor((self.height - 5) / Draw.text_height()) - 1

   if self.pulldown then
      self.pulldown = false
      self.pulldown_y = self.max_lines
   end
end

function ReplLayer:print(text)
   Draw.set_font(self.font_size)
   local success, err, wrapped = pcall(function() return Draw.wrap_text(text, self.width) end)
   if not success then
      self.scrollback:push("<error printing result: " .. err .. ">")
   else
      for _, line in ipairs(wrapped) do
         self.scrollback:push(line)
      end
   end
end

function ReplLayer:execute(code)
   self:set_text(code)
   self:submit()
end

function ReplLayer:submit()
   -- if self.completion_candidates then
   --    self:insert_text(self.completion_candidates[self.selected_candidate])
   --    self.completion_candidates = nil
   --    return
   -- end

   local text = self.text
   self.text = ""
   self.scrollback_index = 0
   self.history_index = 0
   self.cursor_pos = 0
   self.cursor_x = 0

   self:print(self.mode.caret .. text)
   if string.nonempty(text) then
      table.insert(self.history, 1, text)
   end

   local success, result = self.mode:submit(text)

   local result_text
   if type(result) == "table" then
      -- HACK: Don't print out unnecessary class fields. In the future
      -- `inspect` should be modified to account for this.
      if result._type then
         result_text = inspect(Object.make_prototype(result))
      elseif tostring(result) == "<generator>" then
         local max = 10
         local list = result:take(max + 1)
         if list:length() == max + 1 then
            result_text = "(iterator): " .. inspect(list:take(10):to_list())
            result_text = string.strip_suffix(result_text, " }")
            result_text = result_text .. ", <...> }"
         else
            result_text = "(iterator): " .. inspect(list:to_list())
         end
      else
         result_text = inspect(result)
      end
   else
      result_text = tostring(result)
   end

   if not success then
      print(result_text)
   end

   self:print(result_text)

   self:save_history()
end

function ReplLayer:save_history()
   -- HACK: this must go through the config API eventually.
   local file = io.open("repl_history.txt", "w")
   for i, v in ipairs(self.history) do
      file:write(v)
      file:write("\n")
   end
   file:close()
end

function ReplLayer:copy_last_input()
   local line = self.history[2]
   if line then
      Env.set_clipboard_text(line)
      return line
   end

   return nil
end

function ReplLayer:draw()
   Draw.set_font(self.font_size)

   -- background
   local top = self.height - self.pulldown_y * Draw.text_height()
   Draw.filled_rect(self.x, self.y, self.width, top, self.color)

   -- caret
   Draw.set_color(255, 255, 255)
   Draw.text(self.mode.caret, self.x + 5, self.y + top - Draw.text_height() - 5)
   Draw.text(self.text, self.x + 5 + Draw.text_width(self.mode.caret), self.y + top - Draw.text_height() - 5)

   -- blinking cursor
   if math.floor(self.frames * 2) % 2 == 0 then
      local x = self.x + 5 + Draw.text_width(self.mode.caret) + self.cursor_x + 1
      local y = self.y + top - Draw.text_height() - 5
      Draw.line(x, y, x, y + Draw.text_height() - 1)
   end

   -- scrollback counter
   if self.scrollback_index > 0 then
      local scrollback_count = string.format("%d/%d",self.scrollback_index + self.max_lines, self.scrollback:len())
      Draw.text(scrollback_count, self.width - Draw.text_width(scrollback_count) - 5, self.y + top - Draw.text_height() - 5)
   end

   -- scrollback display
   for i=1,self.max_lines do
      local t = self.scrollback[self.scrollback_index + i]
      if t == nil then
         break
      end
      Draw.text(t, self.x + 5, self.y + top - Draw.text_height() * (i+1) - 5)
   end
end

function ReplLayer:update(dt)
   self.frames = self.frames + dt

   if self.finished then
      -- delay closing until pullup finishes
      self.pulldown = true
      if self.pulldown_y > self.max_lines then
         self.finished = false
         self.pulldown = true
         return true
      end
   end

   if self.finished then
      self.pulldown_y = math.min(self.pulldown_y + self.pulldown_speed, self.max_lines + 1)
   else
      if self.pulldown_y > 0 then
         self.pulldown_y = math.max(self.pulldown_y - self.pulldown_speed, 0)
      end
   end
end

return ReplLayer
