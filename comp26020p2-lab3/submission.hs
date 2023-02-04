-- initialise colors and data type
data Color = Black | White deriving (Eq, Show)

-- implement QuadTree (the order of quadrant is same as mathematical coordinate system, with top-right grid being the first quadrant)
data QuadTree = Cell Color | Grid QuadTree QuadTree QuadTree QuadTree deriving (Eq, Show)

-- Exercise 1
allBlack :: Int -> QuadTree
allBlack _ = Cell Black

allWhite :: Int -> QuadTree
allWhite _ = Cell White

clockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
clockwise a b c d = Grid a b c d

anticlockwise :: QuadTree -> QuadTree -> QuadTree -> QuadTree -> QuadTree
anticlockwise a b c d = Grid a d c b

-- CAUTION: a is top-right. b is top-left, c is bottom-left. d is bottom-right --

-- Exercise 2
data QuadTreeWN = CellN Color [Color] | GridN QuadTreeWN QuadTreeWN QuadTreeWN QuadTreeWN deriving (Eq, Show)

-- stores surrounding QuadTrees of a QuadTree
data Surrounding = Empty | SubQuadTree QuadTree deriving (Eq, Show)
data Surroundings = Surroundings {
    top :: Surrounding, bottom :: Surrounding,
    left :: Surrounding, right :: Surrounding,
    topLeft :: Surrounding, topRight :: Surrounding,     -- corner cases
    bottomLeft :: Surrounding,  bottomRight :: Surrounding      -- corner cases
} deriving (Eq, Show)

-- define helper functions to get the specific sub-QuadTree of a QuadTree
getGridA :: Surrounding -> Surrounding
getGridA Empty = Empty
getGridA (SubQuadTree (Cell ce)) = SubQuadTree (Cell ce)
getGridA (SubQuadTree (Grid a b c d)) = SubQuadTree a

getGridB :: Surrounding -> Surrounding
getGridB Empty = Empty
getGridB (SubQuadTree (Cell ce)) = SubQuadTree (Cell ce)
getGridB (SubQuadTree (Grid a b c d)) = SubQuadTree b

getGridC :: Surrounding -> Surrounding
getGridC Empty = Empty
getGridC (SubQuadTree (Cell ce)) = SubQuadTree (Cell ce)
getGridC (SubQuadTree (Grid a b c d)) = SubQuadTree c

getGridD :: Surrounding -> Surrounding
getGridD Empty = Empty
getGridD (SubQuadTree (Cell ce)) = SubQuadTree (Cell ce)
getGridD (SubQuadTree (Grid a b c d)) = SubQuadTree d

-- define helper functions to get cells of a QuadTree in a given direction, e.g. `getTopCells` gives cells that compose the top edge of a QuadTree
getTopCells :: Surrounding -> [Color]
getTopCells Empty = []
getTopCells (SubQuadTree (Cell ce)) = [ce]
getTopCells (SubQuadTree (Grid a b c d)) = getTopCells (SubQuadTree b) ++ getTopCells (SubQuadTree a)

getBottomCells :: Surrounding -> [Color]
getBottomCells Empty = []
getBottomCells (SubQuadTree (Cell ce)) = [ce]
getBottomCells (SubQuadTree (Grid a b c d)) = getBottomCells (SubQuadTree c) ++ getBottomCells (SubQuadTree d)

getLeftCells :: Surrounding -> [Color]
getLeftCells Empty = []
getLeftCells (SubQuadTree (Cell ce)) = [ce]
getLeftCells (SubQuadTree (Grid a b c d)) = getLeftCells (SubQuadTree b) ++ getLeftCells (SubQuadTree c)

getRightCells :: Surrounding -> [Color]
getRightCells Empty = []
getRightCells (SubQuadTree (Cell ce)) = [ce]
getRightCells (SubQuadTree (Grid a b c d)) = getRightCells (SubQuadTree a) ++ getRightCells (SubQuadTree d)

getTopLeftCell :: Surrounding -> [Color]
getTopLeftCell Empty = []
getTopLeftCell (SubQuadTree (Cell ce)) = [ce]
getTopLeftCell (SubQuadTree (Grid a b c d)) = getTopLeftCell (SubQuadTree b)

getTopRightCell :: Surrounding -> [color]
getTopRightCell Empty = []
getTopRightCell (SubQuadTree (Cell ce)) = [ce]
getTopRightCell (SubQuadTree (Grid a b c d)) = getTopRightCell (SubQuadTree a)

getBottomLeftCell :: Surrounding -> [Color]
getBottomLeftCell Empty = []
getBottomLeftCell (SubQuadTree (Cell ce)) = [ce]
getBottomLeftCell (SubQuadTree (Grid a b c d)) = getBottomLeftCell (SubQuadTree c)

getBottomRightCell :: Surrounding -> [Color]
getBottomRightCell Empty = []
getBottomRightCell (SubQuadTree (Cell ce)) = [ce]
getBottomRightCell (SubQuadTree (Grid a b c d)) = getBottomRightCell (SubQuadTree d)

-- update border cells of given surroundings into neighbour list of each cell (recursion from root to leaves)
updateNeighbours :: QuadTreeWN -> Surroundings -> QuadTreeWN
updateNeighbours (CellWN ce neigs) surr = CellWN ce (neigs ++
        getBottomCells (top surr) ++
        getTopCells (bottom surr) ++
        getRightCells (left surr) ++
        getLeftCells (right surr) ++
        getBottomRightCell (topLeft surr) ++
        getBottomLeftCell (topRight surr) ++
        getTopRightCell (bottomLeft surr) ++
        getTopLeftCell (bottomRight surr)
    )

-- pass specific sub-QuadTree of given surrounding QuadTree to form use sub-Surroundings
updateNeighbours (GridWN a b c d) surr = GridWN
    (updateNeighbours a (Surroundings {
        top = getGridD (top surr),
        bottom = Empty,
        left = Empty,
        right = getGridB (right surr),
        topLeft = getGridC (top surr),
        topRight = getGridC (topRight surr),
        bottomLeft = Empty,
        bottomRight = getGridC (right surr)
    }))
    (updateNeighbours b (Surroundings {
        top = getGridC (top surr),
        bottom = Empty,
        left = getGridA (left surr),
        right = Empty,
        topLeft = getGridD (topLeft surr),
        topRight = getGridD (top surr),
        bottomLeft = getGridD (left surr),
        bottomRight = Empty
    }))
    (updateNeighbours c (Surroundings {
        top = Empty,
        bottom = getGridB (bottom surr),
        left = getGridD (left surr),
        right = Empty,
        topLeft = getGridA (left surr),
        topRight = Empty,
        bottomLeft = getGridA (bottomLeft surr),
        bottomRight = getGridA (bottom surr)
    }))
    (updateNeighbours d (Surroundings {
        top = Empty,
        bottom = getGridA (bottom surr),
        left = Empty,
        right = getGridC (right surr),
        topLeft = Empty,
        topRight = getGridB (right surr),
        bottomLeft = getGridB (bottom surr),
        bottomRight = getGridB (bottomRight surr)
    }))

-- compute neighbour list of each cell (from leaves to root)
computeNeighbours :: QuadTree -> QuadTreeWN
computeNeighbours (Cell ce) = CellWN ce []

-- pass surroundings at each level to updateNeighbours
computeNeighbours (Grid a b c d) = GridWN
    (updateNeighbours (computeNeighbours a) (Surroundings {
        top = Empty,
        bottom = SubQuadTree d,
        left = SubQuadTree b,
        right = Empty,
        topLeft = Empty,
        topRight = Empty,
        bottomLeft = SubQuadTree c,
        bottomRight = Empty
    }))
    (updateNeighbours (computeNeighbours b) (Surroundings {
        top = Empty,
        bottom = SubQuadTree c,
        left = Empty,
        right = SubQuadTree a,
        topLeft = Empty,
        topRight = Empty,
        bottomLeft = Empty,
        bottomRight = SubQuadTree d
    }))
    (updateNeighbours (computeNeighbours c) (Surroundings {
        top = SubQuadTree b,
        bottom = Empty,
        left = Empty,
        right = SubQuadTree d,
        topLeft = Empty,
        topRight = SubQuadTree a,
        bottomLeft = Empty,
        bottomRight = Empty
    }))
    (updateNeighbours (computeNeighbours d) (Surroundings {
        top = SubQuadTree a,
        bottom = Empty,
        left = SubQuadTree c,
        right = Empty,
        topLeft = SubQuadTree b,
        topRight = Empty,
        bottomLeft = Empty,
        bottomRight = Empty
    }))


-- generate resulting matrix according to information in neighbour lists, which computes edges
detectEdges :: QuadTreeWN -> QuadTree
detectEdges (CellWN ce neigs) = if isSameColor ce neigs then allWhite 1 else allBlack 1
detectEdges (GridWN a b c d) = Grid (detectEdges a) (detectEdges b) (detectEdges c) (detectEdges d)
-- my crude edge detector
ndiff :: QuadTree -> QuadTree
ndiff (Cell _) = allWhite 1
ndiff grid = detectEdges (computeNeighbours grid)