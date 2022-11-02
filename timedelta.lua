---@alias delta_args {weeks: number?, days: number?, hours: number?, minutes: number?, seconds?: number, milliseconds?: number, microseconds?: number}
---@class timedelta
---@field public days integer
---@field public seconds integer
---@field public microseconds integer
---@operator add(timedelta): timedelta
---@operator sub(timedelta): timedelta
---@operator mul(number): timedelta
---@operator mod(number): timedelta
---@operator div(number): timedelta
---@operator idiv(integer): timedelta
---@operator call(delta_args):timedelta
local timedelta = {}

local modf = math.modf
local floor = math.floor
local abs = math.abs
local format = string.format
local insert = table.insert
local concat = table.concat

---@param x integer
---@param y integer
---@return integer
---@return integer
local function divmod(x, y)
    local quotient = floor(x / y)
    local remainder = x - y * quotient
    return quotient, remainder
end

---round-half-even
---@param x number
---@return integer
local function roundhev(x)
    local a, b = math.modf(x)
    if b == 0 then return a end
    if a % 2 == 0 then
        return a
    elseif a < 0 then
        return a - 1
    else
        return a + 1
    end
end

setmetatable(timedelta, {
    ---comment
    ---@param self any
    ---@param delta any
    ---@return timedelta
    __call = function(self, delta) return timedelta:new(delta) end
})

---@param delta delta_args 
---@return timedelta
function timedelta:new(delta)

    -- allow user to pass just a seconds arg
    if type(delta) == "number" then delta = {seconds = delta} end

    -- set defaults
    local weeks = delta.weeks or 0
    local days = delta.days or 0
    local hours = delta.hours or 0
    local minutes = delta.hours or 0
    local seconds = delta.seconds or 0
    local milliseconds = delta.milliseconds or 0
    local microseconds = delta.microseconds or 0

    local rem = 0

    -- convert to base units
    -- propagate floating point to smaller units
    days, rem = modf(days + weeks * 7)
    seconds, rem = modf(seconds + hours * 3600 + minutes * 60 + rem * 86400)
    microseconds = roundhev(milliseconds * 1000 + microseconds + rem * 1e6)

    -- normalize
    local offset = 0
    offset, microseconds = divmod(microseconds, 1000000)
    seconds = seconds + offset
    offset, seconds = divmod(seconds, 86400)
    days = days + offset

    assert(abs(days) <= 999999999,
           format("timedelta # of days too large: %s", days))

    -- create class
    local td = {days = days, seconds = seconds, microseconds = microseconds}
    setmetatable(td, self)
    self.__index = self
    return td
end

---@return timedelta
function timedelta:__unm()
    return timedelta:new{seconds = -1 * self:total_seconds()}
end

---@param other timedelta
---@return timedelta
function timedelta:__add(other)
    return timedelta:new{
        days = self.days + other.days,
        seconds = self.seconds + other.seconds,
        microseconds = self.microseconds + other.microseconds
    }
end

---@param other timedelta
---@return timedelta
function timedelta:__sub(other)
    return timedelta:new{
        days = self.days + other.days,
        seconds = self.seconds + other.seconds,
        microseconds = self.microseconds + other.microseconds
    }
end

---@param i number
---@return timedelta
function timedelta:__mul(i)
    return timedelta:new{
        days = self.days * i,
        seconds = self.seconds * i,
        microseconds = self.microseconds * i
    }
end

---@param i number
---@return timedelta
function timedelta:__div(i)
    return timedelta:new{
        days = self.days / i,
        seconds = self.seconds / i,
        microseconds = self.microseconds / i
    }
end

---@param other timedelta
---@return number
function timedelta:ratio(other)
    return self:total_seconds() / other:total_seconds()
end

---@param i integer
---@return timedelta
function timedelta:__idiv(i)
    return timedelta:new{
        days = self.days // i,
        seconds = self.seconds // i,
        microseconds = self.microseconds // i
    }
end

---@param other timedelta
function timedelta:__mod(other)
    return timedelta:new{
        seconds = (self:total_seconds() % (other:total_seconds()))
    }
end

---@param other timedelta
---@return boolean
function timedelta:__eq(other)
    return self.days == other.days and self.seconds == other.seconds and
               self.microseconds == other.microseconds
end

---@param other timedelta
---@return boolean
function timedelta:__lt(other)
    return self:total_seconds() < other:total_seconds()
end

---@param other timedelta
---@return boolean
function timedelta:__le(other)
    return self:total_seconds() <= other:total_seconds()
end

---@return string
function timedelta:__tostring()

    local output = {}

    if self.days < 0 then insert(output, "-") end
    if abs(self.days) > 1 then
        insert(output, format("%d days, ", self.days))
    elseif abs(self.days) == 1 then
        insert(output, format("%d day, ", self.days))
    end
    local hours, minutes
    local seconds = self.seconds
    hours, seconds = divmod(seconds, 3600)
    minutes, seconds = divmod(seconds, 60)

    insert(output, string.format("%d:%02d:%02d", hours, minutes, seconds))

    if self.microseconds > 0 then
        insert(output, string.format(".%06d", self.microseconds))
    end

    return concat(output)
end

function timedelta:abs()
    if self.days < 0 then
        return self * -1
    else
        return self
    end
end

---@return number
function timedelta:total_seconds()
    return self.days * 86400 + self.seconds + self.microseconds / 1e6
end

timedelta.min = timedelta:new{days = -999999999}
timedelta.max = timedelta:new{days = 999999999}
timedelta.resolution = timedelta:new{microseconds = 1}
return timedelta
