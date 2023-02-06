-- Definition of the data type Cell, representing a cell in a quadrant with either "White" or "Black" value.
data Cell = White | Black
  deriving (Eq, Show)

-- Definition of the data type QuadTree, representing a Quadtree which can be a single Cell of a certain size or four quadrants.
data QuadTree = Leaf Cell Int | Node QuadTree QuadTree QuadTree QuadTree
  deriving (Eq, Show)


-- Functions which returns a Black or White cell of a specified size.
allBlack :: Int -> QuadTree
allBlack size = Leaf Black size

allWhite :: Int -> QuadTree
allWhite size = Leaf White size


-- Functions to build a Quadtree from four quadrants arranged in a clockwise or anticlockwise manner.
clockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
clockwise tl tr br bl = Node tl tr bl br

anticlockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
anticlockwise tl bl br tr = Node tl tr bl br





-- Function which returns the size of a side of a QuadTree.
-- Input: Quadtree
-- Output: Size of a side
getTreeSize :: QuadTree -> Double
getTreeSize (Leaf p size) = fromIntegral size
getTreeSize (Node tl tr bl br) = getTreeSize tl + getTreeSize tr

-- Main function which returns the final Quadtree after applying the recoloring algorithm.
-- Input: Initial Quadtree
-- Output: Final Quadtree
blur :: QuadTree -> QuadTree
blur fullTree = let treeSize = (getTreeSize fullTree) in 
 (blur_recursion fullTree (fullTree, treeSize) (treeSize / 2, treeSize / 2, treeSize))


-- Function which returns the final Quadtree after recursively applying the recoloring algorithm on each Leaf, changing its color if more than half of its neighbors have the opposite color.
-- Inputs: Current Quadtree -> (Initial Quadtree, It's size) -> (Current x coordinate, Current y coordinate, Current Quadtree's size)
-- Output: Solved QuadTree
blur_recursion :: QuadTree -> (QuadTree, Double) -> (Double, Double, Double) -> QuadTree
-- Base case: change the color of a Leaf if more than half of its direct neighbors have the opposite color.
blur_recursion (Leaf p leaf_size) (full_tree, tree_size) (current_x, current_y, _) 
  | p == White && (neighbors_score < 0) = Leaf Black leaf_size
  | p == Black && (neighbors_score > 0) = Leaf White leaf_size
  | otherwise = Leaf p leaf_size
  where neighbors_score = (calculateNeighborsScore (full_tree, tree_size) (current_x, current_y, fromIntegral leaf_size))
-- Step case: recursively builds the final Quadtree by applying blur_recursion on each Quadrant in a clockwise manner.
blur_recursion (Node tl tr bl br) (full_tree, tree_size) (current_x, current_y, current_size) =
  clockwise
    (blur_recursion tl (full_tree, tree_size) (current_x - offset, current_y - offset, current_size / 2))
    (blur_recursion tr (full_tree, tree_size) (current_x + offset, current_y - offset, current_size / 2))
    (blur_recursion br (full_tree, tree_size) (current_x + offset, current_y + offset, current_size / 2))
    (blur_recursion bl (full_tree, tree_size) (current_x - offset, current_y + offset, current_size / 2))
  where offset = current_size / 4


-- Function which calculates the sum of all cells on an inside-border of a Quadtree, based on their color. White cells are worth +1 and black cells are worth -1.
-- Input: a Quadtree (or Nothing) -> a String specifying one of the four inside-borders
-- Output: total sum of the color values of the cells on the specified inside-border
side :: Maybe QuadTree -> String -> Int
side Nothing _ = 0
side (Just (Leaf p _)) _ 
 | p == White = 1
 | p == Black = -1
side (Just (Node tl tr bl br)) direction
 | direction == "bottom" = (side (Just bl) "bottom") + (side (Just br) "bottom")
 | direction == "left" = (side (Just bl) "left") + (side (Just tl) "left")
 | direction == "top" = (side (Just tl) "top") + (side (Just tr) "top")
 | direction == "right" = (side (Just br) "right") + (side (Just tr) "right")


-- Function which takes all direct neighbors (same-size or bigger) of a Quadrant and calculate the sum of their color, on their neighbor-most side.
-- Input: (Initial Quadtree, It's size) -> (Neighbor Leaf's X coordinate, Leaf's Y coordinate, Leaf's size)
-- Output: Total sum of all neighbors colors
calculateNeighborsScore :: (QuadTree, Double) -> (Double, Double, Double) -> Int
calculateNeighborsScore (full_tree, tree_size) (leaf_x, leaf_y, leaf_size) = 
 side (getNeighbor "top" (full_tree, tree_size) (leaf_x, leaf_y, leaf_size)) "bottom" +
 side (getNeighbor "bottom" (full_tree, tree_size) (leaf_x, leaf_y, leaf_size)) "top" +
 side (getNeighbor "left" (full_tree, tree_size) (leaf_x, leaf_y, leaf_size)) "right" +
 side (getNeighbor "right" (full_tree, tree_size) (leaf_x, leaf_y, leaf_size)) "left"


-- Function that takes the position of a Leaf, and returns the Quadtree representing one of his four direct neighbors (top, bottom, left, right).
-- Input: String representing the direction of the desired neighbor -> (Initial Quadtree, It's size) -> (Leaf's X coordinate, Y coordinate, size)
-- Output: the Neighbors Quadtree in desired direction (or Nothing if outside Quadtree's border)
getNeighbor :: String -> (QuadTree, Double) -> (Double, Double, Double) -> Maybe QuadTree
getNeighbor direction (full_tree, tree_size) (leaf_x, leaf_y, leaf_size)
 | direction == "top" = getNode full_tree tree_size (tree_center, tree_center, tree_size) (leaf_x, leaf_y - leaf_size, leaf_size) -- top
 | direction == "bottom" = getNode full_tree tree_size (tree_center, tree_center, tree_size) (leaf_x, leaf_y + leaf_size, leaf_size) -- bottom
 | direction == "left" = getNode full_tree tree_size (tree_center, tree_center, tree_size) (leaf_x - leaf_size, leaf_y, leaf_size) -- left
 | direction == "right" = getNode full_tree tree_size (tree_center, tree_center, tree_size) (leaf_x + leaf_size, leaf_y, leaf_size) -- right
  where tree_center = tree_size / 2


-- Function used by getNeighbor(). This function returns the Node at inputed coordinates and of inputed size.
-- Intputs: a Quadtree -> It's size -> (current X coordinate, Y coordinate, size) -> (objective's X coordinate, Y coordinate, size)
-- Output: the Quadtree at the desired coordinates (or Nothing if outside Quadtree's border)
getNode :: QuadTree -> Double -> (Double, Double, Double) -> (Double, Double, Double) -> Maybe QuadTree
getNode (Leaf p leaf_size) _ _ _ = Just (Leaf p leaf_size)
getNode (Node tl tr bl br) full_tree_size (current_x, current_y, current_size) (node_x, node_y, node_size) 
 | node_x < 0.0 || node_x > (full_tree_size - 0.5) || node_y < 0.0 || node_y > (full_tree_size - 0.5) = Nothing
 | current_size == node_size = (Just (Node tl tr bl br))

 | current_x > node_x && current_y > node_y = getNode tl full_tree_size (current_x - offset, current_y - offset, current_size / 2) (node_x, node_y, node_size) 
 | current_x < node_x && current_y > node_y = getNode tr full_tree_size (current_x + offset, current_y - offset, current_size / 2) (node_x, node_y, node_size) 
 | current_x > node_x && current_y < node_y = getNode bl full_tree_size (current_x - offset, current_y + offset, current_size / 2) (node_x, node_y, node_size) 
 | current_x < node_x && current_y < node_y = getNode br full_tree_size (current_x + offset, current_y + offset, current_size / 2) (node_x, node_y, node_size) 
 where offset = current_size / 4


-- main = print(clockwise (allBlack 1) (allBlack 1) (allWhite 1) (allWhite 1) /= anticlockwise (allBlack 1) (allBlack 1) (allWhite 1) (allBlack 1))