local Colors = {
   Palette = {
      START = 1,
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
      ['TERRAIN'] = { 188/ 255, 129/ 255, 73 / 255, 1 },
      ['BACKGROUND'] = { 194 / 255, 162 / 255, 97 / 255, 1 },
      ['SKYTOP'] = { 87 / 255, 136 / 255, 98 / 255, 1 },
      ['SKYBOTTOM'] = { 227 / 255, 207 / 255, 126 / 255, 1 },
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
