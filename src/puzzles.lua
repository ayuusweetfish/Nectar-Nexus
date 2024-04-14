return {
  [1] = {
    size = {3, 7},
    objs = {
      {'obstacle', 0, 5},
      {'obstacle', 0, 6},
      {'obstacle', 1, 1},
      {'bloom', 0, 3},
      {'bloom', 0, 0},
      {'bloom', 2, 5},
      {'pollen', 1, 4, group = 1},
      {'pollen', 1, 3, group = 1},
      {'pollen', 2, 3, group = 2},
      {'pollen', 2, 4, group = 2},
      {'butterfly', 1, 6, dir = 2},
    },
  },
  [2] = {
    size = {5, 5},
    objs = {
      {'reflect_obstacle', 4, 0},
      {'bloom', 2, 1},
      {'bloom', 1, 3},
      {'pollen', 0, 2, group = 1},
      {'pollen', 1, 2, group = 1},
      {'pollen', 2, 3, group = 2},
      {'pollen', 2, 4, group = 2},
      {'butterfly', 3, 4, dir = 3},
      {'butterfly', 4, 4, dir = 3},
    },
  },
  [3] = {
    size = {4, 7},
    objs = {
      {'bloom', 2, 3},
      {'bloom', 1, 4},
      {'weeds', 1, 3},
      {'pollen', 1, 0, group = 2},
      {'pollen', 1, 1, group = 3},
      {'pollen', 1, 5, group = 2},
      {'pollen', 1, 6, group = 3},
      {'pollen', 3, 5, group = 4},
      {'pollen', 3, 6, group = 4},
      {'butterfly', 0, 2, dir = 1},
    },
  },
  [4] = {
    size = {4, 7},
    objs = {
      {'obstacle', 3, 0},
      {'obstacle', 3, 1},
      {'bloom', 3, 3},
      {'bloom', 2, 4},
      {'bloom', 3, 4},
      {'weeds', 2, 3},
      {'pollen', 0, 3, group = 1},
      {'pollen', 1, 3, group = 1},
      {'pollen', 2, 0, group = 2},
      {'pollen', 2, 1, group = 2},
      {'pollen', 2, 5, group = 3},
      {'pollen', 2, 6, group = 3},
      {'pollen', 3, 5, group = 4},
      {'pollen', 3, 6, group = 4},
      {'butterfly', 1, 2, dir = 1},
    },
  },
  [5] = {
    size = {6, 8},
    objs = {
      {'obstacle', 0, 0}, {'obstacle', 0, 1}, {'obstacle', 0, 6}, {'obstacle', 0, 7},
      {'obstacle', 1, 0}, {'obstacle', 1, 1}, {'obstacle', 1, 6}, {'obstacle', 1, 7},
      {'obstacle', 2, 0}, {'obstacle', 2, 1}, {'obstacle', 2, 6}, {'obstacle', 2, 7},
      {'obstacle', 3, 0}, {'obstacle', 3, 1}, {'obstacle', 3, 6}, {'obstacle', 3, 7},
      {'obstacle', 4, 0}, {'obstacle', 4, 1}, {'obstacle', 4, 6}, {'obstacle', 4, 7},
      {'obstacle', 5, 0}, {'obstacle', 5, 1}, {'obstacle', 5, 6}, {'obstacle', 5, 7},
      {'bloom', 3, 5},
      {'bloom', 4, 5},
      {'pollen', 1, 3, group = 1},
      {'pollen', 2, 3, group = 1},
      {'pollen', 2, 4, group = 2},
      {'pollen', 3, 4, group = 2},
      {'chameleon', 2, 5, range_x = -3},
      {'butterfly', 0, 3, dir = 2},
    },
  },
  [6] = {
    size = {8, 10},
    objs = {
      {'obstacle', 0, 0}, {'obstacle', 0, 1}, {'obstacle', 0, 8}, {'obstacle', 0, 9},
      {'obstacle', 1, 0}, {'obstacle', 1, 1}, {'obstacle', 1, 8}, {'obstacle', 1, 9},
      {'obstacle', 2, 0}, {'obstacle', 2, 1}, {'obstacle', 2, 8}, {'obstacle', 2, 9},
      {'obstacle', 3, 0}, {'obstacle', 3, 1}, {'obstacle', 3, 8}, {'obstacle', 3, 9},
      {'obstacle', 4, 0}, {'obstacle', 4, 1}, {'obstacle', 4, 8}, {'obstacle', 4, 9},
      {'obstacle', 5, 0}, {'obstacle', 5, 1}, {'obstacle', 5, 8}, {'obstacle', 5, 9},
      {'obstacle', 6, 0}, {'obstacle', 6, 1}, {'obstacle', 6, 8}, {'obstacle', 6, 9},
      {'obstacle', 7, 0}, {'obstacle', 7, 1}, {'obstacle', 7, 8}, {'obstacle', 7, 9},
      {'chameleon', 4, 7, range_x = -4},
      {'weeds', 2, 4},
      {'bloom', 3, 6},
      {'bloom', 4, 5},
      {'bloom', 5, 5},
      {'pollen', 6, 2, group = 1},
      {'pollen', 7, 2, group = 1},
      {'pollen', 6, 4, group = 2},
      {'pollen', 7, 4, group = 2},
      {'pollen', 6, 6, group = 3},
      {'pollen', 7, 6, group = 3},
      {'butterfly', 0, 3, dir = 2},
    },
  },
  [7] = {
    size = {6, 11},
    objs = {
      {'obstacle', 0, 0}, {'obstacle', 0, 7}, {'obstacle', 0, 8}, {'obstacle', 0, 9}, {'obstacle', 0, 10},
      {'obstacle', 1, 0}, {'obstacle', 1, 7}, {'obstacle', 1, 8}, {'obstacle', 1, 9}, {'obstacle', 1, 10},
      {'obstacle', 2, 0}, {'obstacle', 2, 7}, {'obstacle', 2, 8}, {'obstacle', 2, 9}, {'obstacle', 2, 10},
      {'obstacle', 3, 0}, {'obstacle', 3, 10},
      {'obstacle', 4, 0},
      {'obstacle', 5, 0}, {'obstacle', 5, 1},
      {'weeds', 2, 4},
      {'bloom', 2, 3},
      {'bloom', 3, 6},
      {'bloom', 5, 6},
      {'pollen', 3, 8, group = 2},
      {'pollen', 3, 9, group = 2},
      {'pollen', 5, 8, group = 3},
      {'pollen', 5, 9, group = 3},
      {'chameleon', 3, 9, range_y = 2},
      {'butterfly', 0, 5, dir = 2},
    },
  },
}
