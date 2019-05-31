local Draw = require("api.Draw")
local Ui = require("api.Ui")

local ICharaMakeSection = require("api.gui.menu.chara_make.ICharaMakeSection")
local UiList = require("api.gui.UiList")
local UiRaceInfo = require("api.gui.menu.chara_make.UiRaceInfo")
local UiWindow = require("api.gui.UiWindow")
local KeyHandler = require("api.gui.KeyHandler")
local IKeyInput = require("api.gui.IKeyInput")

local SelectClassMenu = class("SelectClassMenu", ICharaMakeSection)

SelectClassMenu:delegate("keys", IKeyInput)
SelectClassMenu:delegate("win", {"x", "y", "width", "height"})

local function random_cm_bg()
   return Draw.load_image(string.format("graphic/g%d.bmp", math.random(4)))
end

function SelectClassMenu:init(race)
   self.race = race or "race"

   local classes = table.of(function(i) return "class" .. i end, 100)

   self.x, self.y, self.width, self.height = Ui.params_centered(680, 500)
   self.y = self.y + 20

   self.win = UiWindow:new("select_class.title", self.x, self.y, self.width, self.height)
   self.pages = UiList:new_paged(self.x + 38, self.y + 66, classes, 16)
   self.bg = random_cm_bg()

   self.chip_male = Draw.load_image("graphic/temp/chara_male.bmp")
   self.chip_female = Draw.load_image("graphic/temp/chara_female.bmp")

   self.race_info = UiRaceInfo:new(self.x, self.y, classes[1])

   self.keys = KeyHandler:new()
   self.keys:forward_to(self.pages)
   self.keys:bind_actions {
      shift = function() self.canceled = true end
   }

   self.caption = "Choose a class."
end

SelectClassMenu.query = require("api.Input").query

function SelectClassMenu:get_result()
end

function SelectClassMenu:relayout()
   self.win:relayout()
   self.pages:relayout()
   self.win:set_pages(self.pages)
end

function SelectClassMenu:draw()
   self.win:draw()
   Draw.image(self.bg,
              self.x + self.width / 4,
              self.y + self.height / 2,
              self.width / 5 * 2,
              self.height - 80,
              {255, 255, 255, 80},
              true)

   Draw.set_color()
   Ui.draw_topic("race", self.x + 28, self.y + 30)
   Ui.draw_topic("detail", self.x + 188, self.y + 30)

   self.pages:draw()

   Draw.set_color()
   Draw.image(self.chip_male, self.x + 380, self.y - self.chip_male:getHeight() + 60)
   Draw.image(self.chip_female, self.x + 350, self.y - self.chip_female:getHeight() + 60)

   Draw.set_color(0, 0, 0)
   Draw.text("race" .. ": " .. self.race, self.x + 460, self.y + 38)

   self.race_info:draw()
end

function SelectClassMenu:update()
   self.keys:run_actions()

   if self.pages.chosen then
      return self.pages:selected_item()
   elseif self.pages.changed then
      local class = self.pages:selected_item()
      self.race_info:set_data(class)

      self.win:set_pages(self.pages)
   end

   self.win:update()
   self.pages:update()

   if self.canceled then
      return nil, "canceled"
   end
end

return SelectClassMenu