local uid_tracker = require("internal.uid_tracker")
local ILocation = require("api.ILocation")

-- Low-level storage for map objects of the same types. Pretty much
-- anything that needs to store map objects uses this internally.
local pool = class.class("pool", ILocation, { no_inspect = false })

-- serialization ID for binser
pool.__id = "pool"

function pool:init(type_id, tracker, width, height)
   tracker = tracker or uid_tracker:new()
   width = width or 1
   height = height or 1

   class.assert_is_an(uid_tracker, tracker)

   self.type_id = type_id
   self.content = setmetatable({}, { __inspect = tostring })
   self.uids = {}
   self.uid_tracker = tracker
   self.width = width
   self.height = height

   self.positional = table.of(function() return {} end, self.width * self.height)
end

function pool:get_object(uid)
   if self.content[uid] == nil then
      return nil
   end

   local d = self.content[uid].data

   return d
end

function pool:take_object(obj, x, y)
   if self:has_object(obj) then
      return nil
   end

   x = math.floor(x or 0)
   y = math.floor(y or 0)
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   -- obj:remove_ownership()
   if obj.location then
      if not obj.location:remove_object(obj) then
         return nil
      end
      obj.location = nil
   end

   obj.x = x
   obj.y = y
   obj.location = self

   local entry = { data = obj, array_index = #self.uids + 1 }

   table.insert(self.uids, obj.uid)
   self.content[obj.uid] = entry
   table.insert(self.positional[y*self.width+x+1], obj)

   return self:get_object(obj.uid)
end

function pool:move_object(obj, x, y)
   assert(self:has_object(obj))
   assert(x >= 0 and x < self.width)
   assert(y >= 0 and y < self.height)

   table.iremove_value(self.positional[obj.y*self.width+obj.x+1], obj)
   table.insert(self.positional[y*self.width+x+1], obj)

   obj.x = x
   obj.y = y

   return obj
end

function pool:remove_object(obj)
   local uid
   if type(obj) == "table" then
      uid = obj.uid
   elseif type(obj) == "number" then
      uid = obj
   else
      error(string.format("remove_object takes an object or UID (got: %s)", obj))
   end

   local entry = self.content[uid]

   if entry == nil then
      error("UID not found " .. uid)
      return
   end

   -- HACK terribly inefficient for over 100 elements.
   local ind = entry.array_index
   table.remove(self.uids, ind)
   for _, v in pairs(self.content) do
      if v.array_index >= ind then
         v.array_index = v.array_index - 1
      end
   end

   local obj_ = self.content[uid].data

   self.content[obj_.uid] = nil

   table.iremove_value(self.positional[obj_.y*self.width+obj_.x+1], obj_)

   obj_.location = nil

   return obj_
end

-- HACK: This should really be extracted into its own class.
-- TODO: rename to iter_objects_at_pos
function pool:objects_at_pos(x, y)
   if not self:is_in_bounds(x, y) then
      return fun.iter({})
   end
   return fun.iter(self.positional[y*self.width+x+1])
end

function pool:is_in_bounds(x, y)
   return x >= 0 and y >= 0 and x < self.width and y < self.height
end

function pool:has_object(obj)
   return obj ~= nil and self.content[obj.uid] ~= nil
end

local function iter(state, index)
   if index > #state.uids then
      return nil
   end

   -- We have to be careful of stale iterators, since state.uids is a deepcopy
   -- from the parent. If this iterator is created as a standalone object and
   -- any objects referred to inside state.uids are removed from the pool
   -- afterwards, they should be skipped over.
   local content
   while content == nil and index <= #state.uids do
      content = state.content[state.uids[index]]
      index = index + 1
   end

   if content == nil then
      return nil
   end

   local data = content.data
   return index, data
end

function pool:iter(ordering)
   return fun.wrap(iter, {uids=ordering or table.deepcopy(self.uids), content=self.content}, 1)
end

function pool:object_count()
   return #self.uids
end

function pool:is_positional()
   return true
end

function pool:can_take_object(obj)
   return true
end

return pool
