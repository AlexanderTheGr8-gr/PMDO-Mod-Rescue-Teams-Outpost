rto_icons = {}

-- none / bug / dark / dragon / electric / fairy / fighting / fire / flying / ghost
-- grass / rock / ice / normal / poison / psychic / ground / steel / water
function rto_icons.element(t)
    if (t == nil or t == "")    then return STRINGS:Format("")
    elseif t == "none"          then return STRINGS:Format("\\uE080")
    elseif t == "bug"           then return STRINGS:Format("\\uE081")
    elseif t == "dark"          then return STRINGS:Format("\\uE082")
    elseif t == "dragon"        then return STRINGS:Format("\\uE083")
    elseif t == "electric"      then return STRINGS:Format("\\uE084")
    elseif t == "fairy"         then return STRINGS:Format("\\uE085")
    elseif t == "fighting"      then return STRINGS:Format("\\uE086")
    elseif t == "fire"          then return STRINGS:Format("\\uE087")
    elseif t == "flying"        then return STRINGS:Format("\\uE088")
    elseif t == "ghost"         then return STRINGS:Format("\\uE089")
    elseif t == "grass"         then return STRINGS:Format("\\uE08A")
    elseif t == "rock"          then return STRINGS:Format("\\uE08B")
    elseif t == "ice"           then return STRINGS:Format("\\uE08C")
    elseif t == "normal"        then return STRINGS:Format("\\uE08D")
    elseif t == "poison"        then return STRINGS:Format("\\uE08E")
    elseif t == "psychic"       then return STRINGS:Format("\\uE08F")
    elseif t == "ground"        then return STRINGS:Format("\\uE090")
    elseif t == "steel"         then return STRINGS:Format("\\uE091")
    elseif t == "water"         then return STRINGS:Format("\\uE092")
    else                             return STRINGS:Format("")
    end
end

-- "Heart" / "♥", "Music note" / "Music" / "Note", "Tick" / "V" / "Check", "Cross" / "X"
-- "Star" / "*", "Half Star", "Letter closed", "Letter opened", "Notes" / "Stone tablet" / "Tablet" / "Slab"
-- "Exclamation" / "!", "Text-PoKe" / "PoKe", "Poke" / "P" / "Money" / "Zennies", "Cloud bubble"
function rto_icons.misc(m)
    if m == nil                     then return ""
    elseif (m == "Heart" or m == "♥")
                                    then return STRINGS:Format("\\u2661")
    elseif (m == "Music note" or m == "Music" or m == "Note")
                                    then return STRINGS:Format("\\u266A")
    elseif (m == "Tick" or m == "V" or m == "Check")
                                    then return STRINGS:Format("\\uE10A")
    elseif (m == "Cross" or m == "X")
                                    then return STRINGS:Format("\\uE10B")
    elseif (m == "Star" or m == "*")
                                    then return STRINGS:Format("\\uE10C")
    elseif (m == "Half Star" or m == "Half-Star" or m == "*/2")
                                    then return STRINGS:Format("\\uE10D")
    elseif m == "Letter closed"     then return STRINGS:Format("\\uE10E")
    elseif m == "Letter opened"     then return STRINGS:Format("\\uE10F")
    elseif (m == "Notes" or m == "Stone tablet" or m == "Tablet" or m == "Slab")
                                    then return STRINGS:Format("\\uE110")
    elseif (m == "Exclamation" or m == "!")
                                    then return STRINGS:Format("\\uE111")
    elseif (m == "Text-PoKe" or m == "PoKe")
                                    then return STRINGS:Format("\\uE023")
    elseif (m == "Poke" or m == "P" or m == "Money" or m == "Zennies" or m == "$" or m == "€")
                                    then return STRINGS:Format("\\uE024")
    elseif m == "Cloud bubble"      then return STRINGS:Format("\\uE040")
    elseif (m == "Question Mark" or m == "Question" or m == "?")
                                    then return STRINGS:Format("\\uF8BF")
    elseif (m == "Tilda" or m == "Wave" or m == "~")
                                    then return STRINGS:Format("\\uF8C0")
    elseif (m == "Tomb Stone" or m == "RIP" or m == "+")
                                    then return STRINGS:Format("\\uF86B")
    elseif m == "Red Circle"        then return STRINGS:Format("\\uF020")
    else                                 return ""
    end
end

-- Unknown font: \uE041-\uE05A
-- If you shift the characters in your text by E000, you will automatically translate English letters to Unown. Make sure everything is capitalized.
function rto_icons.to_unknown(text)
    if text == nil or text == "" then return "" end
    
    local result = ""
    for i = 1, #text do
        local c = text:sub(i,i)
        local byte = c:byte()
        if byte >= 65 and byte <= 90 then         -- A-Z
            result = result .. string.char(byte + 0xE000)
        elseif byte >= 97 and byte <= 122 then    -- a-z
            result = result .. string.char(byte - 32 + 0xE000)
        elseif byte == 32 then                     -- space
            result = result .. " "
        elseif byte == 33 then                     -- !
            result = result .. "!"
        elseif byte == 39 then                     -- '
            result = result .. "'"
        elseif byte == 44 then                     -- ,
            result = result .. ","
        elseif byte == 45 then                     -- -
            result = result .. "-"
        elseif byte == 46 then                     -- .
            result = result .. "."
        elseif byte == 63 then                     -- ?
            result = result .. "?"
        else
            result = result .. c                   -- unsupported characters are added as-is
        end
    end
    return result
end

function rto_icons.button(b)
    if b == nil         then return ""
    elseif b == "1"     then return STRINGS:Format("\\uF000")
    elseif b == "2"     then return STRINGS:Format("\\uF001")
    elseif b == "3"     then return STRINGS:Format("\\uF002")
    elseif b == "4"     then return STRINGS:Format("\\uF003")
    elseif b == "5"     then return STRINGS:Format("\\uF004")
    elseif b == "6"     then return STRINGS:Format("\\uF005")
    elseif b == "7"     then return STRINGS:Format("\\uF006")
    elseif b == "8"     then return STRINGS:Format("\\uF007")
    elseif b == "9"     then return STRINGS:Format("\\uF008")
    elseif b == "10"    then return STRINGS:Format("\\uF009")
    elseif b == "11"    then return STRINGS:Format("\\uF00A")
    elseif b == "12"    then return STRINGS:Format("\\uF00B")
    elseif b == "13"    then return STRINGS:Format("\\uF00C")
    elseif b == "14"    then return STRINGS:Format("\\uF00D")
    elseif b == "15"    then return STRINGS:Format("\\uF00E")
    elseif b == "16"    then return STRINGS:Format("\\uF00F")
    elseif b == "17"    then return STRINGS:Format("\\uF010")
    elseif b == "18"    then return STRINGS:Format("\\uF011")
    elseif b == "19"    then return STRINGS:Format("\\uF012")
    elseif b == "20"    then return STRINGS:Format("\\uF013")
    elseif b == "21"    then return STRINGS:Format("\\uF014")
    elseif b == "22"    then return STRINGS:Format("\\uF015")
    elseif b == "23"    then return STRINGS:Format("\\uF016")
    elseif b == "24"    then return STRINGS:Format("\\uF017")
    elseif b == "25"    then return STRINGS:Format("\\uF018")
    elseif b == "26"    then return STRINGS:Format("\\uF019")
    elseif b == "27"    then return STRINGS:Format("\\uF01A")
    elseif b == "28"    then return STRINGS:Format("\\uF01B")
    elseif b == "29"    then return STRINGS:Format("\\uF01C")
    elseif b == "30"    then return STRINGS:Format("\\uF01D")
    elseif b == "31"    then return STRINGS:Format("\\uF01E")
    elseif b == "32"    then return STRINGS:Format("\\uF01F")
    elseif b == "33"    then return STRINGS:Format("\\uF020")
    elseif b == "34"    then return STRINGS:Format("\\uF021")
    elseif b == "35"    then return STRINGS:Format("\\uF022")
    elseif b == "36"    then return STRINGS:Format("\\uF023")
    elseif b == "37"    then return STRINGS:Format("\\uF024")
    elseif b == "38"    then return STRINGS:Format("\\uF025")
    elseif b == "39"    then return STRINGS:Format("\\uF026")
    elseif b == "40"    then return STRINGS:Format("\\uF027")
    elseif b == "41"    then return STRINGS:Format("\\uF028")
    elseif b == "42"    then return STRINGS:Format("\\uF029")
    else                     return STRINGS:Format("")
    end
end

function rto_icons.item(i)
    if i == nil         then return STRINGS:Format("")
    elseif i == "1"     then return STRINGS:Format("\\uE0A0")
    elseif i == "2"     then return STRINGS:Format("\\uE0A1")
    elseif i == "3"     then return STRINGS:Format("\\uE0A2")
    elseif i == "4"     then return STRINGS:Format("\\uE0A3")
    elseif i == "5"     then return STRINGS:Format("\\uE0A4")
    elseif i == "6"     then return STRINGS:Format("\\uE0A5")
    elseif i == "7"     then return STRINGS:Format("\\uE0A6")
    elseif i == "8"     then return STRINGS:Format("\\uE0A7")
    elseif i == "9"     then return STRINGS:Format("\\uE0A8")
    elseif i == "10"    then return STRINGS:Format("\\uE0A9")
    elseif i == "11"    then return STRINGS:Format("\\uE0AA")
    elseif i == "12"    then return STRINGS:Format("\\uE0AB")
    elseif i == "13"    then return STRINGS:Format("\\uE0AC")
    elseif i == "14"    then return STRINGS:Format("\\uE0AD")
    elseif i == "15"    then return STRINGS:Format("\\uE0AE")
    elseif i == "16"    then return STRINGS:Format("\\uE0AF")
    elseif i == "17"    then return STRINGS:Format("\\uE0B0")
    elseif i == "18"    then return STRINGS:Format("\\uE0B1")
    elseif i == "19"    then return STRINGS:Format("\\uE0B2")
    else                     return STRINGS:Format("")
    end
end

-- Convert an int to price icons
function rto_icons.price(p)
    if (p == nil or p == "") then return "" end
    
    local result = ""
    local str = tostring(p)
    for i = 1, #str do
        local c = str:sub(i,i)
        local byte = c:byte()
        
        -- For the range 0 - 9
        if byte >= 48 and byte <= 57 then   result = result .. string.char(0xE100 + byte - 48)
        -- unsupported characters are added as-is
        else                                result = result .. c
        end
    end
end