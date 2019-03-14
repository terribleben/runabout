local Colors = {
   Palette = {
      START = 1,
      VENICE = 2,
      MESA = 3,
   },
   Value = {
      TERRAIN = 'TERRAIN',
      BACKGROUND = 'BACKGROUND',
      SKYTOP = 'SKYTOP',
      SKYBOTTOM = 'SKYBOTTOM',
   },
}

local values = {
   {
      -- ['TERRAIN'] = { 188 / 255, 129 / 255, 73 / 255, 1 },
      ['TERRAIN'] = { 201 / 255, 148 / 255, 77 / 255, 1 },
      ['BACKGROUND'] = { 194 / 255, 162 / 255, 97 / 255, 0.8 },
      ['SKYTOP'] = { 87 / 255, 136 / 255, 98 / 255, 1 },
      ['SKYBOTTOM'] = { 227 / 255, 207 / 255, 126 / 255, 1 },
   },
   {
      --['TERRAIN'] = { 195 / 255, 117 / 255, 96 / 255, 1 },
      ['TERRAIN'] = { 199 / 255, 129 / 255, 139 / 255, 1 },
      --['BACKGROUND2'] = { 227 / 255, 193 / 255, 204 / 255, 1 },
      ['BACKGROUND'] = { 218 / 255, 162 / 255, 199 / 255, 1 },
      ['SKYTOP'] = { 255 / 255, 115 / 255, 200 / 255, 1 },
      ['SKYBOTTOM'] = { 255 / 255, 234 / 255, 234 / 255, 1 },
   },
   {
      ['TERRAIN'] = { 119 / 255, 60 / 255, 75 / 255, 1 },
      ['BACKGROUND'] = { 210 / 255, 93 / 255, 101 / 255, 0.8 },
      -- ['BACKGROUND'] = { 56 / 255, 38 / 255, 55 / 255, 1 },
      ['SKYTOP'] = { 105 / 255, 85 / 255, 86 / 255, 1 },
      -- ['SKYBOTTOM'] = { 223 / 255, 109 / 255, 102 / 255, 1 },
      ['SKYBOTTOM'] = { 237 / 255, 151 / 255, 99 / 255, 1 },
   },
}

function Colors.getColor(palette, color)
   local chosenPalette = values[palette]
   return chosenPalette[color]
end

function Colors.useColor(palette, color)
   local rgba = Colors.getColor(palette, color)
   love.graphics.setColor(rgba[1], rgba[2], rgba[3], rgba[4])
end

function Colors.interpColor(palette, color1, color2, interp)
   local rgba1 = Colors.getColor(palette, color1)
   local rgba2 = Colors.getColor(palette, color2)
   local remain = 1.0 - interp
   local rgba = {
      (rgba2[1] * interp) + (rgba1[1] * remain),
      (rgba2[2] * interp) + (rgba1[2] * remain),
      (rgba2[3] * interp) + (rgba1[3] * remain),
      (rgba2[4] * interp) + (rgba1[4] * remain),
   }
   love.graphics.setColor(rgba[1], rgba[2], rgba[3], rgba[4])
end

return Colors
