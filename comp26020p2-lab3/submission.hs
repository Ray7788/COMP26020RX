-- initialise colors and data type
data Color = Black | White deriving (Eq, Show)

-- implement QuadTree (the order of quadrant follows mathematical coordinate system)
data QuadTree = Cell Color Int | Grid QuadTree QuadTree QuadTree QuadTree deriving (Eq, Show)

-- returns a Black or White cell of a specified size (size could be ignored in Exercise1)
allBlack :: Int -> QuadTree
allBlack size = Cell Black size

allWhite :: Int -> QuadTree
allWhite size = Cell White size

-- Exercise 1 ----------------------------------------------------------
clockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
clockwise a b c d = Grid a b c d

anticlockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
anticlockwise a b c d = Grid a d c b

-- Exercise 2 ----------------------------------------------------------
-- output the size of a QuadTree by calculating the length of one side (eg. top)
getTreeSize :: QuadTree -> Double
getTreeSize (Cell ce size) = fromIntegral size
getTreeSize (Grid a b c d) = getTreeSize a + getTreeSize b

-- detect one specified side of a certain Gird/Cell and sum its all cells values according to colors
-- a Quadtree (or Nothing) -> one of the four inside-borders ->
side :: Maybe QuadTree -> String -> Int
-- invalid
side Nothing _ = 0
-- calculate the weight of the Cell
side (Just (Cell ce _)) _
  | ce == White = 1 -- White cells are worth +1
  | ce == Black = -1 -- black cells are worth -1
--  continue to implement recursion for Grid if cell is not arrived
side (Just (Grid a b c d)) direction
  | direction == "top" = side (Just a) "top" + (side (Just b) "top")
  | direction == "bottom" = side (Just c) "bottom" + (side (Just d) "bottom")
  | direction == "left" = side (Just b) "left" + (side (Just c) "left")
  | direction == "right" = side (Just a) "right" + (side (Just d) "right")

-- helper function for getNeigbor: returns the Node at inputed coordinates and of inputed size.
-- Quadtree -> its size -> (current X coordinate, Y coordinate, size) -> (target's X coordinate, Y coordinate, size) ->
getGrid :: QuadTree -> Double -> (Double, Double, Double) -> (Double, Double, Double) -> Maybe QuadTree
getGrid (Cell ce cellSize) _ _ _ = Just (Cell ce cellSize)
getGrid (Grid a b c d) treeSize (x_now, y_now, sizeNow) (grid_x, grid_y, grid_size)
  -- detect boundary
  | grid_x < 0.0 || grid_x > (treeSize - 0.5) || grid_y < 0.0 || grid_y > (treeSize - 0.5) = Nothing
  | sizeNow == grid_size = Just (Grid a b c d)
  | x_now > grid_x && y_now > grid_y = getGrid b treeSize (x_now - offset, y_now - offset, sizeNow / 2) (grid_x, grid_y, grid_size)
  | x_now < grid_x && y_now > grid_y = getGrid a treeSize (x_now + offset, y_now - offset, sizeNow / 2) (grid_x, grid_y, grid_size)
  | x_now > grid_x && y_now < grid_y = getGrid c treeSize (x_now - offset, y_now + offset, sizeNow / 2) (grid_x, grid_y, grid_size)
  | x_now < grid_x && y_now < grid_y = getGrid d treeSize (x_now + offset, y_now + offset, sizeNow / 2) (grid_x, grid_y, grid_size)
  where
    offset = sizeNow / 4

--  returns the Quadtree representing one of his four direct neighbors (top, bottom, left, right)
-- direction -> (initial QuadTree, initial QuadTree size) -> (Cell's X coordinate, Cell's Y coordinate, Cell's size)
getNeighbor :: String -> (QuadTree, Double) -> (Double, Double, Double) -> Maybe QuadTree
getNeighbor direction (fullTree, treeSize) (x_cell, y_cell, cellSize)
  | direction == "top" = getGrid fullTree treeSize (tree_center, tree_center, treeSize) (x_cell, y_cell - cellSize, cellSize) -- top
  | direction == "bottom" = getGrid fullTree treeSize (tree_center, tree_center, treeSize) (x_cell, y_cell + cellSize, cellSize) -- bottom
  | direction == "left" = getGrid fullTree treeSize (tree_center, tree_center, treeSize) (x_cell - cellSize, y_cell, cellSize) -- left
  | direction == "right" = getGrid fullTree treeSize (tree_center, tree_center, treeSize) (x_cell + cellSize, y_cell, cellSize) -- right
  where
    tree_center = treeSize / 2

-- get neighbors weight and sum the total weight of a cell's all neighbors
-- (initial QuadTree, initial QuadTree size) -> (Neighbor Cell's X coordinate, Cell's Y coordinate, Cell's size)
getNeighborWeight :: (QuadTree, Double) -> (Double, Double, Double) -> Int
getNeighborWeight (fullTree, treeSize) (x_cell, y_cell, cellSize) =
  side (getNeighbor "top" (fullTree, treeSize) (x_cell, y_cell, cellSize)) "bottom"
    + side (getNeighbor "bottom" (fullTree, treeSize) (x_cell, y_cell, cellSize)) "top"
    + side (getNeighbor "left" (fullTree, treeSize) (x_cell, y_cell, cellSize)) "right"
    + side (getNeighbor "right" (fullTree, treeSize) (x_cell, y_cell, cellSize)) "left"

-- True engine for the programme
-- Current QuadTree -> (initial QuadTree, initial QuadTree size) -> (Current x, y, Current QuadTree size) -> output
blurMini :: QuadTree -> (QuadTree, Double) -> (Double, Double, Double) -> QuadTree
-- for Cell
blurMini (Cell c cellSize) (fullTree, treeSize) (x_now, y_now, _)
  | c == White && (neighborWeight < 0) = Cell Black cellSize
  | c == Black && (neighborWeight > 0) = Cell White cellSize
  | otherwise = Cell c cellSize
  where
    neighborWeight = getNeighborWeight (fullTree, treeSize) (x_now, y_now, fromIntegral cellSize)
-- for Grid
blurMini (Grid a b c d) (fullTree, treeSize) (x_now, y_now, fullSize) =
  clockwise
    (blurMini a (fullTree, treeSize) (x_now + offset, y_now - offset, fullSize / 2))
    (blurMini b (fullTree, treeSize) (x_now - offset, y_now - offset, fullSize / 2))
    (blurMini c (fullTree, treeSize) (x_now - offset, y_now + offset, fullSize / 2))
    (blurMini d (fullTree, treeSize) (x_now + offset, y_now + offset, fullSize / 2))
  where
    offset = fullSize / 4

-- Original Engine of whole programme
-- use blurMini to implement the tree
blur :: QuadTree -> QuadTree
blur fullTree = let fullSize = (getTreeSize fullTree)
  in (blurMini fullTree (fullTree, fullSize) (fullSize / 2, fullSize / 2, fullSize))
--   where treeSize = getTreeSize fullTree

main = print (clockwise (allBlack 1) (allBlack 1) (allWhite 1) (allWhite 1) /= anticlockwise (allBlack 1) (allBlack 1) (allWhite 1) (allBlack 1))