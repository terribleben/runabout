local HiScore = {
   _bestTime = 0,
}

local BESTTIME_STORAGE_KEY = 'bestTime-TODOTEST'

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
   if self._bestTime == 0 or self._bestTime == nil or completedTime < self._bestTime then
      network.async(function()
            castle.storage.set(BESTTIME_STORAGE_KEY, completedTime)
            self._bestTime = completedTime
      end)
   end
end

function HiScore:formatTime(timeInSeconds)
   timeInSeconds = math.floor(timeInSeconds * 10) / 10
   
   local min, sec = 0, 0
   min = math.floor(timeInSeconds / 60)
   sec = timeInSeconds - (min * 60)

   local minStr, secStr = tostring(min), tostring(sec)
   if sec < 10 then
      secStr = '0' .. secStr
   end

   return minStr .. ':' .. secStr
end

return HiScore
