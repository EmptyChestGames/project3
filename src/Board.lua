--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

DESTRUCTION = false
DIRECTION = 0

function Board:init(x, y)
    self.x = x
    self.y = y
    self.matches = {}

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            if LEVEL == 1 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(5), math.random(1), math.random(2)))
            elseif LEVEL == 2 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(8), math.random(2), math.random(5)))
            elseif LEVEL == 3 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(11), math.random(3), math.random(8)))
            elseif LEVEL == 4 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(15), math.random(4), math.random(11)))
            elseif LEVEL >= 5 then
                table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(18), math.random(6), math.random(15)))
            end
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1


    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        shineNum = 1
        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].shine == 1 and self.tiles[y][x].color == colorToMatch then
                shineNum = shineNum + 1
            end

            if shineNum >= 4 then
                DESTRUCTION = true
                direction = 0
            end

            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1    
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                   
                    local match = {}
                    if shineNum >= 3 then
                        DESTRUCTION = true
                        DIRECTION = 0
                    else
                        DESTRUCTION = false
                    end

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do
                            
                        -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                    
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1
        shineNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if self.tiles[y][x].shine == 1 and self.tiles[y][x].color == colorToMatch then
                    shineNum = shineNum + 1
                end

                if matchNum >= 3 then
                    local match = {}
                    if shineNum >= 4 then
                        DESTRUCTION = true
                        DIRECTION = 1
                    else
                        DESTRUCTION = false
                    end

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

function Board:calculateVariety()
    VARIETYBONUS = 1.00
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            if self.tiles[tile.gridY][tile.gridX].variety == 2 then
                VARIETYBONUS = VARIETYBONUS + 0.03
            elseif self.tiles[tile.gridY][tile.gridX].variety == 3 then
                VARIETYBONUS = VARIETYBONUS + 0.05
            elseif self.tiles[tile.gridY][tile.gridX].variety == 4 then
                VARIETYBONUS = VARIETYBONUS + 0.08
            elseif self.tiles[tile.gridY][tile.gridX].variety == 5 then
                VARIETYBONUS = VARIETYBONUS + 0.1
            elseif self.tiles[tile.gridY][tile.gridX].variety == 6 then
                VARIETYBONUS = VARIETYBONUS + 0.15
            end
        end
    end
end

function Board:testBoard()
    -- Variables for Testing Board
    local remains = 0
    local color = 0
    -- Testing for Horizontal Matches
    for y = 1,6 do
        for x = 1, 6 do
            color = self.tiles[y][x].color
            if self.tiles[y][x + 1].color == color then
                if self.tiles[y + 1][x + 2].color == color then
                    remains = 1
                end
            end
        end
        for x = 1, 6 do
            if y >= 2 then
                color = self.tiles[y][x].color
                if self.tiles[y][x + 1].color == color then
                    if self.tiles[y - 1][x + 2].color == color then
                        remains = 1
                    end
                end
            end
        end
        for x = 2, 6 do
            if y >= 2 then
                color = self.tiles[y][x].color
                if self.tiles[y - 1][x - 1].color == color then
                    if self.tiles[y - 1][x + 1].color == color then
                        remains = 1
                    end
                end
            end
        end
        for x = 2, 5 do
            color = self.tiles[y][x].color
            if y <= 5 then
                if self.tiles[y + 1][x - 1].color == color then
                    if self.tiles[y + 1][x + 1].color == color then
                        remains = 1
                    end
                end
            end
        end
        for x = 3, 8 do
            color = self.tiles[y][x].color
            if self.tiles[y][x - 1].color == color then
                if self.tiles[y + 1][x - 2] == color then
                    remains = 1
                end
            end
        end
        for x = 3, 8 do
            if y >= 2 then
                color = self.tiles[y][x].color
                if self.tiles[y][x - 1].color == color then
                    if self.tiles[y - 1][x - 2] == color then
                        remains = 1
                    end
                end
            end
        end
        for x = 1, 6 do
            if y <= 5 then
                color = self.tiles[y][x].color
                if self.tiles[y + 1][x].color == color then
                    if self.tiles[y + 3][x].color == color then
                        remains = 1
                    end
                end
            end
        end
        for x = 1, 6 do
            if y >= 4 then
                color = self.tiles[y][x].color
                if self.tiles[y - 1][x].color == color then
                    if self.tiles[y - 3][x].color == color then
                        remains = 1
                    end
                end
            end
        end

    end
    -- Testing for Vertical Matches
    for x = 1,6 do
        for y = 1, 6 do
            color = self.tiles[y][x].color
            if self.tiles[y + 1][x].color == color then
                if self.tiles[y + 2][x + 1].color == color then
                    remains = 1
                end
            end
        end
        for y = 1, 6 do
            if x >= 2 then
                color = self.tiles[y][x].color
                if self.tiles[y + 1][x].color == color then
                    if self.tiles[y + 2][x - 1].color == color then
                        remains = 1
                    end
                end
            end
        end
        for y = 2, 6 do
            if x >= 2 then
                color = self.tiles[y][x].color
                if self.tiles[y - 1][x - 1].color == color then
                    if self.tiles[y + 1][x - 1].color == color then
                        remains = 1
                    end
                end
            end
        end
        for y = 2, 5 do
            color = self.tiles[y][x].color
            if x <= 5 then
                if self.tiles[y - 1][x + 1].color == color then
                    if self.tiles[y + 1][x + 1].color == color then
                        remains = 1
                    end
                end
            end
        end
        for y = 2, 5 do
            color = self.tiles[y][x].color
            if self.tiles[y - 1][x].color == color then
                if self.tiles[y + 1][x - 2] == color then
                    remains = 1
                end
            end
        end
        for y = 3, 8 do
            if x >= 2 then
                color = self.tiles[y][x].color
                if self.tiles[y][x - 1].color == color then
                    if self.tiles[y -
                     1][x - 2] == color then
                        remains = 1
                    end
                end
            end
        end
        for y = 1, 6 do
            if x <= 5 then
                color = self.tiles[y][x].color
                if self.tiles[y][x + 1].color == color then
                    if self.tiles[y][x + 3].color == color then
                        remains = 1
                    end
                end
            end
        end
        for y = 1, 6 do
            if x >= 4 then
                color = self.tiles[y][x].color
                if self.tiles[y][x - 1].color == color then
                    if self.tiles[y][x - 3].color == color then
                        remains = 1
                    end
                end
            end
        end
    end

    return remains
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    if DESTRUCTION == false then
        for k, match in pairs(self.matches) do
            for k, tile in pairs(match) do
                self.tiles[tile.gridY][tile.gridX] = nil
            end
        end
    end
    if DESTRUCTION == true then
        if DIRECTION == 0 then
            for k, match in pairs(self.matches) do
                for k, tile in pairs(match) do
                    for x = 1, 8 do
                        self.tiles[tile.gridY][x]= nil
                    end
                end
            end
        end
        if DIRECTION == 1 then
            for k, match in pairs(self.matches) do
                for k, tile in pairs(match) do
                    for x = 1, 8 do
                        self.tiles[x][tile.gridX]= nil
                    end
                end
            end
        end
    end
    DESTRUCTION = false
    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile and LEVEL == 1 then

                -- new tile with random color and variety

                local tile = Tile(x, y, math.random(18), math.random(1), math.random(5))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            elseif not tile then

                -- new tile with random color and variety

                local tile = Tile(x, y, math.random(18), math.random(6), math.random(5))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end

end