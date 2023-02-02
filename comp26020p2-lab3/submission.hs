-- initialise colors and data type
data Color = Black | White deriving (Eq, Show)

-- implement QuadTree (the order of quadrant is same as mathematical coordinate system, with top-right grid being the first quadrant)
data QuadTree = Cell Color | Grid QuadTree QuadTree QuadTree QuadTree deriving (Eq, Show)

-- 
allBlack :: Int -> QuadTree
allBlack _ = Cell Black

allWhite :: Int -> QuadTree
allWhite _ = Cell White

clockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
clockwise a b c d = Grid a b c d

anticlockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
anticlockwise a b c d = Grid d c b a
