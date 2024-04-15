return {
  test = 6,  -- ** 修改【起始关卡编号】 ** --

  -- ** 搜索文本可以直接跳转到关卡 ** --
  -- ** 例如，搜索“谜题1” ** --

  ------ Vase 1: Fundamentals ------
  -- Game objective
  [1] = {    -- ** 谜题1 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {3, 8},
    objs = {
      {'pollen', 1, 3, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 7, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 0, dir = 1},
    },
  },
  -- Blossom
  [2] = {    -- ** 谜题2 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {3, 8},
    objs = {
      {'bloom', 1, 4},
      {'pollen', 1, 6, group = 1, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 7, group = 1, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 1, dir = 4},
    },
  },
  -- Fuzzy (i.e. non-orthogonal layout) turn,
  -- corner case (square), multiple pollen pairs
  [3] = {    -- ** 谜题3 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {4, 9},
    objs = {
      {'bloom', 0, 8},
      {'pollen', 2, 3, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 5, group = 2, image = '3.2', rotation = -1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 7, group = 2, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 2, 1, dir = 1},
    },
  },
  -- Mild difficulty, more fuzzy turn (backwards)
  [4] = {    -- ** 谜题4 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {4, 8},
    objs = {
      {'bloom', 3, 6},
      {'bloom', 0, 6},
      {'pollen', 1, 3, group = 1, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 4, group = 1, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 5, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 6, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 1, dir = 1},
    },
  },
  -- Mild difficulty (trickery!), obstacles
  [5] = {    -- ** 谜题5 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {5, 9},
    objs = {
      {'obstacle', 1, 2, image = '1.1'},
      {'obstacle', 1, 3, image = '1.2'},
      {'bloom', 3, 2},
      {'bloom', 1, 8},
      {'pollen', 1, 1, group = 1, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 5, group = 1, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 0, 1, dir = 2},
    },
  },
  -- Some difficulty
  [6] = {    -- ** 谜题6 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {3, 7},
    objs = {
      {'obstacle', 0, 5, image = '2'},
      {'obstacle', 0, 6, image = '1.2'},
      {'obstacle', 1, 1, image = '1.1'},
      {'bloom', 0, 3},
      {'bloom', 0, 0},
      {'bloom', 2, 5},
      {'pollen', 1, 4, group = 1, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 3, group = 1, image = '3.2', rotation = 2},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 3, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 6, dir = 2},
    },
  },

  ------ Vase 2: Flocks/locksteps, intricate moves ------
  -- 180-degree turn, carrying rules, backwards-fuzzy recap
  [7] = {    -- ** 谜题7 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {4, 9},
    objs = {
      {'bloom', 0, 4},
      {'bloom', 1, 0},
      {'bloom', 3, 2},
      {'pollen', 1, 3, group = 1, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 8, group = 1, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 6, group = 2, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 4, group = 2, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 2, dir = 1},
    },
  },
  -- Multiple butterflies
  [8] = {    -- ** 谜题8 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {3, 10},
    objs = {
      {'bloom', 0, 3},
      {'bloom', 1, 9},
      {'pollen', 1, 5, group = 1, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 8, group = 1, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 6, group = 2, image = '5.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 7, group = 2, image = '5.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 0, dir = 1},
      {'butterfly', 2, 0, dir = 1},
    },
  },
  -- Some difficulty (heads-wrapping)
  [9] = {    -- ** 谜题9 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 8},
    objs = {
      {'bloom', 2, 2},
      {'bloom', 2, 3},
      {'pollen', 2, 5, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 6, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 5, group = 2, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 6, group = 2, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 0, dir = 1},
      {'butterfly', 4, 4, dir = 4},
    },
  },
  -- Decent difficulty
  [10] = {    -- ** 谜题10 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 10},
    objs = {
      {'obstacle', 5, 4, image = '2'},
      {'bloom', 4, 3},
      {'bloom', 2, 6},
      {'bloom', 1, 7},
      {'pollen', 2, 5, group = 1, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 7, group = 1, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 3, group = 2, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 3, group = 2, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 1, group = 3, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 5, group = 3, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 0, dir = 1},
      {'butterfly', 2, 3, dir = 1},
    },
  },

  ------ Vase 3: Weeds ------
  -- Introduction to weeds and its nuances
  -- (pollen is carried over; revisiting does not spawn more butterflies)
  [11] = {    -- ** 谜题11 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {5, 7},
    objs = {
      {'bloom', 2, 0},
      {'weeds', 2, 4},
      {'pollen', 0, 1, group = 1, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 0, 3, group = 1, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 1, group = 2, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 3, group = 2, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 1, group = 3, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 3, group = 3, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 2, 2, dir = 1},
    },
  },
  -- Mild difficulty
  [12] = {    -- ** 谜题12 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {5, 7},
    objs = {
      {'bloom', 1, 4},
      {'bloom', 0, 5},
      {'bloom', 1, 5},
      {'weeds', 2, 3},
      {'pollen', 0, 3, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 3, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 1, group = 2, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 2, group = 2, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 3, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 5, group = 3, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 3, 3, dir = 2},
    },
  },
  -- Puzzles, in increasing order of difficulty
  [13] = {    -- ** 谜题13 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {4, 7},
    objs = {
      {'bloom', 2, 3},
      {'bloom', 1, 4},
      {'weeds', 1, 3},
      {'pollen', 1, 0, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 1, group = 3, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 5, group = 2, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 6, group = 3, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 5, group = 4, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 6, group = 4, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 0, 2, dir = 1},
    },
  },
  [14] = {    -- ** 谜题14 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {4, 7},
    objs = {
      {'obstacle', 3, 0, image = '1'},
      {'obstacle', 3, 1, image = '2.1'},
      {'bloom', 3, 3},
      {'bloom', 2, 4},
      {'bloom', 3, 4},
      {'weeds', 2, 3},
      {'pollen', 0, 3, group = 1, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 3, group = 1, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 0, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 1, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 5, group = 3, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 6, group = 3, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 5, group = 4, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 6, group = 4, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 2, dir = 1},
    },
  },
  [15] = {    -- ** 谜题15 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {4, 8},
    objs = {
      {'weeds', 1, 4},
      {'bloom', 1, 3},
      {'bloom', 0, 7},
      {'bloom', 2, 7},
      {'pollen', 1, 1, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 5, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 0, 1, group = 2, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 0, 5, group = 2, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 1, group = 3, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 5, group = 3, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 2, dir = 1},
    },
  },
  [16] = {    -- ** 谜题16 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {7, 8},
    objs = {
      {'weeds', 3, 2},
      {'weeds', 3, 5},
      {'bloom', 5, 3},
      {'bloom', 6, 4},
      {'bloom', 3, 3},
      {'pollen', 0, 3, group = 1, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 0, 4, group = 1, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 3, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 3, group = 3, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 4, group = 3, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 2, 0, dir = 1},
    },
  },

  ------ Vase 4: Rebounces ------
  -- Introduction to the rebouncing obstacle
  [17] = {    -- ** 谜题17 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {4, 6},
    objs = {
      {'reflect_obstacle', 0, 0, image = '1.3'},
      {'bloom', 2, 1},
      {'pollen', 2, 4, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 4, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 0, 4, dir = 3},
    },
  },
  -- Mild difficulty
  [18] = {    -- ** 谜题18 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {5, 5},
    objs = {
      {'reflect_obstacle', 4, 0, image = '1.2'},
      {'bloom', 2, 1},
      {'bloom', 1, 3},
      {'pollen', 0, 2, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 2, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 3, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 3, 4, dir = 3},
      {'butterfly', 4, 4, dir = 3},
    },
  },
  -- Rebounce and weeds, decent difficulty
  [19] = {    -- ** 谜题19 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {5, 9},
    objs = {
      {'reflect_obstacle', 1, 0, image = '1.3', rotation = -1},
      {'reflect_obstacle', 2, 0, image = '1.3', rotation = -1},
      {'reflect_obstacle', 1, 8, image = '1.1'},
      {'reflect_obstacle', 2, 8, image = '1.1'},
      {'weeds', 2, 3},
      {'bloom', 3, 7},
      {'bloom', 4, 7},
      {'pollen', 1, 1, group = 1, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 7, group = 1, image = '3.2', rotation = 2},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 1, group = 2, image = '4.1', rotation = 1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 7, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 5, group = 3, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 6, group = 3, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 4, dir = 1},
    },
  },
  [20] = {    -- ** 谜题20 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 9},
    objs = {
      {'reflect_obstacle', 4, 3, image = '1.1'},
      {'bloom', 4, 1},
      {'bloom', 4, 2},
      {'bloom', 4, 5},
      {'bloom', 4, 6},
      {'weeds', 3, 4},
      {'pollen', 0, 3, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 3, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 3, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 5, group = 3, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 5, group = 3, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 2, 6, dir = 3},
    },
  },

  ------ Vase 5: Chameleons ------
  -- Introduction to the chameleon
  [21] = {    -- ** 谜题21 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 8},
    objs = {
      {'obstacle', 0, 0, empty_background = true}, {'obstacle', 0, 1, empty_background = true}, {'obstacle', 0, 6, empty_background = true}, {'obstacle', 0, 7, empty_background = true},
      {'obstacle', 1, 0, empty_background = true}, {'obstacle', 1, 1, empty_background = true}, {'obstacle', 1, 6, empty_background = true}, {'obstacle', 1, 7, empty_background = true},
      {'obstacle', 2, 0, empty_background = true}, {'obstacle', 2, 1, empty_background = true}, {'obstacle', 2, 6, empty_background = true}, {'obstacle', 2, 7, empty_background = true},
      {'obstacle', 3, 0, empty_background = true}, {'obstacle', 3, 1, empty_background = true}, {'obstacle', 3, 6, empty_background = true}, {'obstacle', 3, 7, empty_background = true},
      {'obstacle', 4, 0, empty_background = true}, {'obstacle', 4, 1, empty_background = true}, {'obstacle', 4, 6, empty_background = true}, {'obstacle', 4, 7, empty_background = true},
      {'obstacle', 5, 0, empty_background = true}, {'obstacle', 5, 1, empty_background = true}, {'obstacle', 5, 6, empty_background = true}, {'obstacle', 5, 7, empty_background = true},
      {'bloom', 3, 5},
      {'bloom', 4, 5},
      {'pollen', 1, 3, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 3, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 2, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 4, group = 2, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'chameleon', 2, 5, range_x = -3},
      {'butterfly', 0, 3, dir = 2},
    },
  },
  -- Introduction to the nuances of multiple successive entries
  [22] = {    -- ** 谜题22 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 9},
    objs = {
      {'obstacle', 0, 0, empty_background = true}, {'obstacle', 0, 1, empty_background = true}, {'obstacle', 0, 2, empty_background = true}, {'obstacle', 0, 3, empty_background = true}, {'obstacle', 0, 4, empty_background = true}, {'obstacle', 0, 5, empty_background = true},
      {'obstacle', 4, 0, empty_background = true}, {'obstacle', 4, 1, empty_background = true}, {'obstacle', 4, 2, empty_background = true}, {'obstacle', 4, 3, empty_background = true}, {'obstacle', 4, 4, empty_background = true}, {'obstacle', 4, 5, empty_background = true},
      {'obstacle', 5, 0, empty_background = true}, {'obstacle', 5, 1, empty_background = true}, {'obstacle', 5, 2, empty_background = true}, {'obstacle', 5, 3, empty_background = true}, {'obstacle', 5, 4, empty_background = true}, {'obstacle', 5, 5, empty_background = true},
      {'weeds', 2, 2},
      {'bloom', 2, 5},
      {'pollen', 2, 7, group = 1, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 8, group = 1, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 5, group = 2, image = '5.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 6, group = 2, image = '5.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 5, group = 3, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 6, group = 3, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'chameleon', 3, 4, range_y = -2},
      {'butterfly', 2, 1, dir = 1},
    },
  },
  -- Mild difficulty
  [23] = {    -- ** 谜题23 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 10},
    objs = {
      {'obstacle', 3, 8, empty_background = true}, {'obstacle', 3, 9, empty_background = true},
      {'obstacle', 4, 8, empty_background = true}, {'obstacle', 4, 9, empty_background = true},
      {'obstacle', 5, 8, empty_background = true}, {'obstacle', 5, 9, empty_background = true},
      {'bloom', 2, 5},
      {'bloom', 5, 5},
      {'bloom', 4, 3},
      {'pollen', 5, 0, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 3, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 1, group = 2, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 2, group = 2, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'chameleon', 3, 7, range_x = -4},
      {'butterfly', 0, 2, dir = 1},
      {'butterfly', 1, 2, dir = 1},
    },
  },
  -- Decent difficulty, with rebouncing
  [24] = {    -- ** 谜题24 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {5, 10},
    objs = {
      {'obstacle', 2, 6, empty_background = true}, {'obstacle', 2, 7, empty_background = true}, {'obstacle', 2, 8, empty_background = true}, {'obstacle', 2, 9, empty_background = true},
      {'obstacle', 3, 6, empty_background = true}, {'obstacle', 3, 7, empty_background = true}, {'obstacle', 3, 8, empty_background = true}, {'obstacle', 3, 9, empty_background = true},
      {'obstacle', 4, 6, empty_background = true}, {'obstacle', 4, 7, empty_background = true}, {'obstacle', 4, 8, empty_background = true}, {'obstacle', 4, 9, empty_background = true},
      {'reflect_obstacle', 1, 9, image = '1.1'},
      {'bloom', 0, 3},
      {'bloom', 4, 3},
      {'bloom', 1, 6},
      {'bloom', 1, 7},
      {'pollen', 1, 2, group = 1, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 8, group = 1, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 2, group = 2, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 4, group = 2, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 5, group = 3, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 5, group = 3, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'chameleon', 2, 5, range_x = -3},
      {'butterfly', 2, 1, dir = 1},
    },
  },

  ------ Vase 6: Everything everywhere all at once ------
  -- TODO 5/6
  [25] = {    -- ** 谜题25 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {8, 10},
    objs = {
      {'obstacle', 0, 0, empty_background = true}, {'obstacle', 0, 1, empty_background = true}, {'obstacle', 0, 8, empty_background = true}, {'obstacle', 0, 9, empty_background = true},
      {'obstacle', 1, 0, empty_background = true}, {'obstacle', 1, 1, empty_background = true}, {'obstacle', 1, 8, empty_background = true}, {'obstacle', 1, 9, empty_background = true},
      {'obstacle', 2, 0, empty_background = true}, {'obstacle', 2, 1, empty_background = true}, {'obstacle', 2, 8, empty_background = true}, {'obstacle', 2, 9, empty_background = true},
      {'obstacle', 3, 0, empty_background = true}, {'obstacle', 3, 1, empty_background = true}, {'obstacle', 3, 8, empty_background = true}, {'obstacle', 3, 9, empty_background = true},
      {'obstacle', 4, 0, empty_background = true}, {'obstacle', 4, 1, empty_background = true}, {'obstacle', 4, 8, empty_background = true}, {'obstacle', 4, 9, empty_background = true},
      {'obstacle', 5, 0, empty_background = true}, {'obstacle', 5, 1, empty_background = true}, {'obstacle', 5, 8, empty_background = true}, {'obstacle', 5, 9, empty_background = true},
      {'obstacle', 6, 0, empty_background = true}, {'obstacle', 6, 1, empty_background = true}, {'obstacle', 6, 8, empty_background = true}, {'obstacle', 6, 9, empty_background = true},
      {'obstacle', 7, 0, empty_background = true}, {'obstacle', 7, 1, empty_background = true}, {'obstacle', 7, 8, empty_background = true}, {'obstacle', 7, 9, empty_background = true},
      {'chameleon', 4, 7, range_x = -4},
      {'weeds', 2, 4},
      {'bloom', 3, 6},
      {'bloom', 4, 5},
      {'bloom', 5, 5},
      {'pollen', 6, 2, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 7, 2, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 6, 4, group = 2, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 7, 4, group = 2, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 6, 6, group = 3, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 7, 6, group = 3, image = '3.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 0, 3, dir = 2},
    },
  },
  [26] = {    -- ** 谜题26 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {8, 8},
    objs = {
      {'obstacle', 0, 0, empty_background = true}, {'obstacle', 0, 1, empty_background = true},
      {'obstacle', 1, 0, empty_background = true}, {'obstacle', 1, 1, empty_background = true},
      {'obstacle', 2, 0, empty_background = true}, {'obstacle', 2, 1, empty_background = true},
      {'obstacle', 5, 5, image = '2.1'},
      {'obstacle', 6, 5, image = '1'}, {'obstacle', 6, 7, empty_background = true},
      {'obstacle', 7, 5, empty_background = true}, {'obstacle', 7, 6, empty_background = true}, {'obstacle', 7, 7, empty_background = true},
      {'reflect_obstacle', 7, 4, image = '1.2'},
      {'reflect_obstacle', 6, 6, image = '1.1', rotation = 0.5},
      {'weeds', 2, 5},
      {'bloom', 3, 3},
      {'bloom', 4, 4},
      {'bloom', 4, 2},
      {'chameleon', 2, 2, range_x = 2},
      {'chameleon', 4, 5, range_y = -1},
      {'pollen', 3, 1, group = 1, image = '2.2', rotation = 0.2},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 2, group = 1, image = '2.1', rotation = 2},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 1, group = 2, image = '3.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 2, group = 2, image = '3.1', rotation = -1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 1, 4, dir = 1},
    },
  },
  [27] = {    -- ** 谜题27 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 11},
    objs = {
      {'obstacle', 0, 0, empty_background = true}, {'obstacle', 0, 7, empty_background = true}, {'obstacle', 0, 8, empty_background = true}, {'obstacle', 0, 9, empty_background = true}, {'obstacle', 0, 10, empty_background = true},
      {'obstacle', 1, 0, empty_background = true}, {'obstacle', 1, 7, empty_background = true}, {'obstacle', 1, 8, empty_background = true}, {'obstacle', 1, 9, empty_background = true}, {'obstacle', 1, 10, empty_background = true},
      {'obstacle', 2, 0, empty_background = true}, {'obstacle', 2, 7, empty_background = true}, {'obstacle', 2, 8, empty_background = true}, {'obstacle', 2, 9, empty_background = true}, {'obstacle', 2, 10, empty_background = true},
      {'obstacle', 3, 0, empty_background = true}, {'obstacle', 3, 10, image = '2.1'},
      {'obstacle', 4, 0, empty_background = true},
      {'obstacle', 5, 0, empty_background = true}, {'obstacle', 5, 1, image = '1'},
      {'weeds', 2, 4},
      {'bloom', 2, 3},
      {'bloom', 3, 6},
      {'bloom', 5, 6},
      {'pollen', 3, 8, group = 1, image = '1.1', rotation = 1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 9, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 8, group = 2, image = '3.1', rotation = -1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 5, 9, group = 2, image = '3.2', rotation = -1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'chameleon', 3, 9, range_y = 2},
      {'butterfly', 0, 5, dir = 2},
    },
  },
  [28] = {    -- ** 谜题28 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 8},
    objs = {
      {'obstacle', 0, 0, empty_background = true},
      {'obstacle', 1, 0, empty_background = true},
      {'obstacle', 2, 0, empty_background = true},
      {'obstacle', 3, 0, empty_background = true}, {'obstacle', 3, 1, image = '2.2'},
      {'weeds', 3, 5},
      {'bloom', 1, 4},
      {'bloom', 2, 3},
      {'bloom', 4, 0},
      {'bloom', 4, 1},
      {'chameleon', 3, 2, range_x = 2},
      {'pollen', 3, 2, group = 1, image = '1.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 3, 4, group = 1, image = '1.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 1, 5, group = 2, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 5, group = 2, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 1, group = 3, image = '2.2', rotation = -1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 2, group = 3, image = '2.1', rotation = 1},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 4, 4, dir = 1},
    },
  },
  [29] = {    -- ** 谜题29 ** --
    tile = {1, 1},   -- ** 修改【背景瓷砖起始位置（行、列，左上角为 1）】 ** --
    size = {6, 10},
    objs = {
      {'obstacle', 0, 5, empty_background = true}, {'obstacle', 0, 6, empty_background = true}, {'obstacle', 0, 7, empty_background = true}, {'obstacle', 0, 8, empty_background = true}, {'obstacle', 0, 9, empty_background = true},
      {'obstacle', 1, 5, empty_background = true}, {'obstacle', 1, 6, empty_background = true}, {'obstacle', 1, 7, empty_background = true}, {'obstacle', 1, 8, empty_background = true}, {'obstacle', 1, 9, empty_background = true},
      {'weeds', 3, 4},
      {'bloom', 1, 1},
      {'bloom', 5, 1},
      {'bloom', 4, 8},
      {'chameleon', 2, 5, range_y = 3},
      {'pollen', 3, 6, group = 1, image = '4.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 2, 4, group = 1, image = '4.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 6, group = 2, image = '2.1'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'pollen', 4, 7, group = 2, image = '2.2'},  -- ** 修改 image【传粉花图片编号】 ** --
      {'butterfly', 3, 2, dir = 1},
    },
  },
}
