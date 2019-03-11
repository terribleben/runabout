Geom = {}

function Geom.distance2(pos1, pos2)
   return Geom.distance(pos1.x, pos1.y, pos2.x, pos2.y)
end

function Geom.distance(x1, y1, x2, y2)
   local dx, dy = x2 - x1, y2 - y1
   return math.sqrt(dx * dx + dy * dy)
end

function Geom.magnitude(vector)
   return math.sqrt(vector.x * vector.x + vector.y * vector.y)
end

function Geom.clampVector(vector, magnitude)
   local vMagnitude = Geom.magnitude(vector)
   if vMagnitude > magnitude then
      local direction = math.atan2(vector.y, vector.x)
      vector.x = magnitude * math.cos(direction)
      vector.y = magnitude * math.sin(direction)
   end
end

function Geom.slope(P, Q)
   if P.x == Q.x then
      return math.huge
   else
      return (P.y - Q.y) / (P.x - Q.x);
   end
end

function Geom.intersect(P1, Q1, P2, Q2)
   local m1, m2 = Geom.slope(P1, Q1), Geom.slope(P2, Q2)
   if m1 ~= m2 then
        local intX, intY
        if m1 == math.huge then
           intX = P1.x
           intY = m2 * (intX - P2.x) + P2.y;
        elseif m2 == math.huge then
           intX = P2.x;
           intY = m1 * (intX - P1.x) + P1.y;
        else
           intX = (-P1.y + (m1 * P1.x) + P2.y - (m2 * P2.x)) / (m1 - m2);
           intY = m1 * (intX - P1.x) + P1.y;
        end
        return true, intX, intY
   end
   return false, 0, 0
end

local function between(n, a, b)
   if a < b then
      return (n >= a and n <= b)
   else
      return (n >= b and n <= a)
   end
end

function Geom.intersectSegment(P1, Q1, P2, Q2)
   intersected, intX, intY = Geom.intersect(P1, Q1, P2, Q2)
   if intersected then
      if 
         between(intX, P1.x, Q1.x)
         and between(intX, P2.x, Q2.x)
         and between(intY, P1.y, Q1.y)
         and between(intY, P2.y, Q2.y)
      then
         return true, intX, intY
      end
   end
   return false
end

function Geom.nearestPointOnLine(P, Q, A)
   local result = {}
   if P.x == Q.x then
      result.x = P.x
      result.y = A.y
   elseif P.y == Q.y then
      result.x = A.x
      result.y = P.y
   else
      local m = Geom.slope(P, Q)
      local invM = 1.0 / m
      result.x = (m * P.x - P.y + A.y + invM * A.x) / (m + invM)
      result.y = m * (result.x - P.x) + P.y
   end
   return result
end

function Geom.nearestPointOnLineBoundedToSegment(P, Q, A)
   local point = Geom.nearestPointOnLine(P, Q, A)
   if
      between(point.x, P.x, Q.x)
      and between(point.y, P.y, Q.y)
   then
      return true, point
   end
   return false, point
end

return Geom
