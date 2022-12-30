-- initialise colors and data type
data Color = Black | White deriving (Eq, Show)
data Quadtree = Cell Color | Grid Quadtree Quadtree Quadtree Quadtree deriving (Eq, Show)

-- 
allBlack :: Int -> Quadtree
allBlack _ = Cell Black

allWhite :: Int -> Quadtree
allWhite _ = Cell White