local LevelData = {
   numLevels = 1,
   levels = {
      {
         segments = { 0, 0, 1, 1, 0, 0, 0, 1, 2, 2, 2, 3, 3, 3, 3, 3, 3, 2, 3, 3, 4 },
         ponds = {
            {
               index = 16,
               width = 2,
               height = 1,
            },
         },
         collectibles = {
            {
               index = 13.5,
            },
         },
         doors = {
            {
               x = 175,
               y = 150,
               initial = true,
            },
            {
               x = 575,
               y = 175,
            },
         },
      },
   },
}

return LevelData
