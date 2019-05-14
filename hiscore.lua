local HiScore = {
   _bestTime = 0,
}

local BESTTIME_STORAGE_KEY = 'bestTime'

function HiScore:load()
   network.async(function()
         local bestTime = castle.storage.get(BESTTIME_STORAGE_KEY)
         if not (bestTime == nil) then
            self._bestTime = bestTime
         end
   end)
end

function HiScore:get()
   return self._bestTime
end

function HiScore:maybeSave(completedTime)
   network.async(function()
         -- check against server again before saving
         local bestTime = castle.storage.get(BESTTIME_STORAGE_KEY)
         if not (bestTime == nil) then
            self._bestTime = bestTime
         end
         if self._bestTime == nil or self._bestTime == 0 or completedTime < self._bestTime then
            self._bestTime = completedTime
            castle.storage.set(BESTTIME_STORAGE_KEY, completedTime)
         end
   end)
end

function HiScore:formatTime(timeInSeconds)
   timeInSeconds = math.floor(timeInSeconds * 10) / 10
   
   local min, sec, dec = 0, 0, 0
   min = math.floor(timeInSeconds / 60)
   sec = timeInSeconds - (min * 60)
   dec = math.floor((sec - math.floor(sec)) * 10)
   sec = math.floor(sec)

   local minStr, secStr, decStr = tostring(min), tostring(sec), tostring(dec)
   if sec < 10 then
      secStr = '0' .. secStr
   end

   return minStr .. ':' .. secStr .. '.' .. decStr
end

return HiScore
