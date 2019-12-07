local data = require("internal.data")
local paths = require("internal.paths")
local Event = require("api.Event")

data:add_multi(
   "base.event",
   {
      { _id = "before_handle_self_event" },
      { _id = "before_ai_decide_action" },
      { _id = "after_chara_damaged", },
      { _id = "on_calc_damage" },
      { _id = "after_damage_hp", },
      { _id = "on_damage_chara", },
      { _id = "on_kill_chara", },
      { _id = "before_chara_moved" },
      { _id = "on_chara_moved" },
      { _id = "on_chara_hostile_action", },
      { _id = "on_chara_killed", },
      { _id = "on_calc_kill_exp" },
      { _id = "on_chara_turn_end" },
      { _id = "before_chara_turn_start" },
      { _id = "on_chara_pass_turn" },
      { _id = "on_game_initialize" },
      { _id = "on_map_generated" },
      { _id = "on_map_loaded" },
      { _id = "on_proc_status_effect" },
      { _id = "on_object_instantiated" },
      { _id = "on_chara_instantiated" },
      { _id = "on_item_instantiated" },
      { _id = "on_feat_instantiated" },
      { _id = "on_chara_revived", },
      { _id = "on_talk", },
      { _id = "on_calc_chara_equipment_stats", },
      { _id = "on_game_startup", },
      { _id = "on_data_add" },
      { _id = "on_build_chara" },
      { _id = "on_build_item" },
      { _id = "on_build_feat" },
      { _id = "on_pre_build" },
      { _id = "on_normal_build" },
      { _id = "calc_status_indicators" },
      { _id = "on_refresh" },
      { _id = "on_second_passed" },
      { _id = "on_minute_passed" },
      { _id = "on_hour_passed" },
      { _id = "on_day_passed" },
      { _id = "on_month_passed" },
      { _id = "on_year_passed" },
      { _id = "on_init_save" },
      { _id = "on_build_map" },
      { _id = "on_activity_start" },
      { _id = "on_activity_pass_turns" },
      { _id = "on_activity_finish" },
      { _id = "on_activity_interrupt" },
      { _id = "on_activity_cleanup" },
      { _id = "on_generate" },
      { _id = "on_hotload_prototype" },
      { _id = "on_chara_generated" },
      { _id = "on_object_cloned" },
      { _id = "on_map_enter" },
      { _id = "on_map_leave" },
      { _id = "on_chara_place_failure" },
      { _id = "before_map_refresh" },
      { _id = "on_chara_refresh_in_map" },
      { _id = "on_refresh_weight" },
      { _id = "on_calc_speed" },
      { _id = "on_regenerate_map" },
      { _id = "on_regenerate" },
      { _id = "on_item_regenerate" },
      { _id = "on_chara_regenerate" },
      { _id = "on_hotload_object" },
      { _id = "on_chara_vanquished" },
      { _id = "on_turn_begin" },
      { _id = "on_new_game" },
      { _id = "generate_chara_name" },
      { _id = "generate_title" },
      { _id = "on_regenerate" },
      { _id = "on_hotload_begin" },
      { _id = "on_hotload_end" },
   }
)

-- The following adds support for cleaning up missing events
-- automatically if a chunk is hotloaded. It assumes only one chunk is
-- being loaded at a time, and does not handle hotloading dependencies
-- recursively.

local function on_hotload_begin(_, params)
   -- strip trailing "init" to make the path unique
   local path = paths.convert_to_require_path(params.path_or_class)
   Event.global():_begin_register(path)
end

local function on_hotload_end()
   Event.global():_end_register()
end

Event.register("base.on_hotload_begin", "Clean up events missing in chunk on hotload", on_hotload_begin)
Event.register("base.on_hotload_end", "Clean up events missing in chunk on hotload", on_hotload_end)