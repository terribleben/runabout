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
            { index = 16.5 },
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
         segments = {
            2, 1, 1, 0, 1, 1, 1, 3, 3,
            7, 7, 7, 7, 7, 6, 7, 7, 5, 5,
            3, 2, 2, 2, 3, 3, 3, 3, 3,
            4, 4, 4, 4, 3, 3, 5,
         },
         ponds = {
            { index = 2, width = 2, height = 1, },
            { index = 13, width = 2, height = 1, },
            { index = 19, width = 4, height = 1, },
         },
         collectibles = {
            { index = 5, },
            { index = 12.5, },
            { index = 25, },
            { index = 29, },
            { index = 30.5, },
         },
         doors = {
            {
               x = 1350,
               y = 250,
               initial = true,
            },
            {
               x = 1350,
               y = 100,
               destination = 3,
            },
         },
      },

      -- level 3
      {
         id = 3,
         segments = {
            4, 4, 3, 3, 4, 4,
            4, 4, 4, 3, 3, 3, 3, 2, 1, 0, 0, 1, 0, 0, 0, 0,
            1, 1, 1, 1, 0, 1, 2, 2, 2, 1, 1, 1, 1, 1,
            2, 2, 3, 3, 3, 3, 3, 3, 2, 2, 3, 3, 4, 3, 3, 3,
            4, 4, 5,
         },
         ponds = {},
         collectibles = {
            { index = 17 },
            { index = 31.5 },
            { index = 50 },
         },
         doors = {
            {
               x = 700,
               y = 100,
               initial = true,
            },
            {
               x = -150,
               y = 100,
               destination = 5,
            },
            {
               x = 440,
               y = 260,
               isOpen = true,
               color = 1,
               destination = 4,
            },
         },
         ponds = {
            {
               index = 1,
               width = 3,
               height = 1,
            },
            {
               index = 25,
               width = 2,
               height = 1,
            },
         },
      },

      -- level 4
      {
         id = 4,
         segments = { 1, 1, 1, 2, 0, 0, 0, 0, 1, 1, 2, 1, 1, 1, 1 },
         ponds = {
            {
               index = 3,
               width = 7,
               height = 2,
            },
         },
         collectibles = {},
         doors = {
            { x = 425, y = 380, initial = true, },
            { x = 780, y = 425, destination = 3, isOpen = true },
         },
      },

      -- level 5
      {
         id = 5,
         windy = true,
         segments = {
            12, 11, 6,
            4, 4, 4, 3, 4, 4,
            8, 5, 3, 3, 3, 2,
            9, 6, 4, 9, 12, 8, 6, 5, 5, 5, 4, 4,
            6, 9, 5, 4, 4, 3, 2, 2, 1, 1,
            1, 0, 1, 1, 2, 6, 9, 9, 11,
         },
         ponds = {
            { index = 16, width = 2, height = 2 },
            { index = 24.5, width = 2, height = 1 },
         },
         collectibles = {
            { index = 9.5, hover = 16 },
            { index = 12, },
            { index = 16.5, hover = 100 },
            { index = 24, },
            { index = 30.5, },
            { index = 33.5, },
         },
         doors = {
            { x = 200, y = 200, initial = true },
            { x = -475, y = 425, destination = 1 },
         },
      },
   },
}

return LevelData
