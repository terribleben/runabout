local LevelData = {
   numLevels = 1,
   levels = {
      -- level 1
      {
         id = 1,
         segments = { 0, 0, 1, 1, 0, 0, 0, 1, 2, 2, 1, 1, 1, 2, 3, 3, 3, 3, 3, 3, 2, 3, 3, 4 },
         ponds = {
            {
               index = 9,
               width = 4,
               height = 1,
            },
            {
               index = 19,
               width = 2,
               height = 1,
            },
         },
         collectibles = {
            {
               index = 16.5,
            },
         },
         doors = {
            {
               x = 175,
               y = 150,
               initial = true,
            },
            {
               x = 825,
               y = 175,
               destination = 2,
            },
         },
      },

      -- level 2
      {
         id = 2,
         segments = { 3, 4, 3, 3, 3, 2, 3, 2, 3, 4, 4, 4, 4 },
      }
   },
}

return LevelData
