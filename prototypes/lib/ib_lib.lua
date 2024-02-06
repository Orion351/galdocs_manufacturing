
-- MAYHEM
-- MAYHEM
-- MAYHEM

-- Search for MAYHEM when removing the old icon badge stuff oh my god it hurts my soul so bad

-- Variables
-- *********
Ib_local = {}

-- Debug and Logging
Ib_local.debug                             = false
Ib_local.log_errors                        = true
Ib_local.log_prefix                        = "Icon Badges Error: "

-- Graphical variables
Ib_local.default_badge_shift_icon          = {-13, -13}
Ib_local.default_badge_shift_icon_adjust   = {5.5, 5.5} -- FIXME: WHAT HAPPENED HERE
Ib_local.default_badge_icon_scale          = .3125

Ib_local.default_badge_scale_picture       = Ib_local.default_badge_icon_scale / 2
Ib_local.default_badge_shift_picture       = {0.25, 0.25}

Ib_local.badge_image_size                  = 64
Ib_local.icon_to_pictures_ratio            = 0.25

-- 3-char badges
Ib_local.three_char_icon_shift             = {-1, 0, 1}
Ib_local.char_width_icon_scale             = 0.7
Ib_local.char_width_picture_scale          = Ib_local.char_width_icon_scale / 2

-- Structure Variables
Ib_local.filepath                          = "__icon-badges__/graphics/badges/"
Ib_local.char_whitelist                    = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

-- Character width nonsense 
Ib_local.char_widths = {
  -- 14
  ["il I"] = 14,

  -- 15
  -- [""] = 15,

  -- 16
  ["j J"] = 16,

  -- 17
  -- [""] = 17,

  -- 18
  -- [""] = 18,

  -- 19
  -- [""] = 19,

  -- 20
  ["1frt"] = 20,

  -- 21
  -- [""] = 21,

  -- 22
  ["cz"] = 22,

  -- 23
  -- [""] = 23,

  -- 24
  ["hknsu L 237"] = 24,

  -- 25
  -- [""] = 25,

  -- 26
  -- ["bdegopqvxy CEFSZ 459"] = 26,
  ["abdegopqvxy CEFSZ 459"] = 26,

  -- 27
  -- [""] = 27,

  -- 28
  ["ABDGHKNPRTUVXY 680"] = 28,

  -- 29
  -- [""] = 29,

  -- 30
  ["OQ"] = 30,

  -- 31
  -- [""] = 31,

  -- 32
  -- [""] = 32,

  -- 33
  -- [""] = 33,

  -- 34
  -- [""] = 34,

  -- 35
  -- [""] = 35,

  -- 36
  ["mw M"] = 36,

  -- 37
  -- [""] = 37,

  -- 38
  -- [""] = 38,

  -- 39
  -- [""] = 39,

  -- 40
  ["W"] = 40,

  -- 41
  -- [""] = 41,
}

Ib_local.ib_badge_opacity = 1

-- Parsing character widths
function Parse_char_widths(character)
  local current_width = 0
  for group, width in pairs(Ib_local.char_widths) do
    local i, j = string.find(group, character)
    if i then
      current_width = width
    end
  end
  return current_width
end

Ib_local.user_badge_scale = 1

-- Parsing Badge Mipmaps
Ib_local.mipmaps = "mipAuto"




-- Small functions
function Corner_to_direction(corner)
  local direction = {1, 1}
  if corner == "left-bottom" then
    direction = {1, -1}
  end
  if corner == "right-bottom" then
    direction = {-1, -1}
  end
  if corner == "left-top" then
    direction = {1, 1}
  end
  if corner == "right-top" then
    direction = {-1, 1}
  end
  return direction
end

function Get_case(char)
  local case = ""
  if char == string.upper(char) then case = "cap-" end
  if char == string.lower(char) then case = "low-" end
  if tonumber(char) then case = "" end
  return case
end

-- Build Letter Badge functions
-- Icons Letter
function GM_Build_single_letter_badge_icon(letter, case, invert, justify, corner, three_position, middle_char)
  -- Credit to Elusive for helping with badges
  
  -- One or Two character Shift
  local direction = Corner_to_direction(corner)
  local shift = {
    direction[1] * (Ib_local.default_badge_shift_icon[1] + (Ib_local.user_badge_scale * Ib_local.default_badge_shift_icon_adjust[1] / 2)),
    direction[2] * (Ib_local.default_badge_shift_icon[2] + (Ib_local.user_badge_scale * Ib_local.default_badge_shift_icon_adjust[2] / 2))
  }

  -- Three character Shift (can only be centered (going left-to-right) but can be on top or bottom)
  local three_shift = 0
  if three_position then
    three_shift = Ib_local.three_char_icon_shift[three_position]
    shift = {
      direction[1] * ((Ib_local.user_badge_scale * three_shift * (Parse_char_widths(middle_char))) / 8 ),
      direction[2] * (Ib_local.default_badge_shift_icon[2] + (Ib_local.user_badge_scale * Ib_local.default_badge_shift_icon_adjust[2] / 2))
    }
  end

  return {
    tint = {r = Ib_local.ib_badge_opacity, b = Ib_local.ib_badge_opacity, g = Ib_local.ib_badge_opacity, a = Ib_local.ib_badge_opacity},
    scale = Ib_local.user_badge_scale * Ib_local.default_badge_icon_scale,
    icon = Ib_local.filepath .. Ib_local.mipmaps .. "/" .. Ib_local.mipmaps .. "-" .. justify .. "-" .. case .. letter .. invert .. ".png", 
    icon_size = Ib_local.badge_image_size,
    icon_mipmaps = 0,
    shift = shift
  }
end

function GM_Build_letter_badge_icon(icons, let_badge, invert_str, let_corner)
  local case

  -- One letter badge
  if #let_badge == 1 and Ib_local.ib_show_badges ~= "Only Belts" then
    case = Get_case(let_badge)
    icons[#icons + 1] = GM_Build_single_letter_badge_icon(let_badge, case, invert_str, "center", let_corner)
    icons[#icons].is_badge_layer = true
  end

  -- Two letter badge
  if #let_badge == 2 and Ib_local.ib_show_badges ~= "Only Belts" then
    local first = let_badge:sub(1,1)
    local second = let_badge:sub(2,2)

    case = Get_case(first)
    icons[#icons + 1] = GM_Build_single_letter_badge_icon(first, case, invert_str, "left", let_corner)
    icons[#icons].is_badge_layer = true
    case = Get_case(second)
    icons[#icons + 1] = GM_Build_single_letter_badge_icon(second, case, invert_str, "right", let_corner)
    icons[#icons].is_badge_layer = true
  end

  -- Three letter badge
  if #let_badge == 3 and Ib_local.ib_show_badges ~= "Only Belts" then

    local first = let_badge:sub(1,1)
    local second = let_badge:sub(2,2)
    local third = let_badge:sub(3,3)

    case = Get_case(first)
    icons[#icons + 1] = GM_Build_single_letter_badge_icon(first, case, invert_str, "left", let_corner, 1, second)
    icons[#icons].is_badge_layer = true
    case = Get_case(second)
    icons[#icons + 1] = GM_Build_single_letter_badge_icon(second, case, invert_str, "center", let_corner, 2, second)
    icons[#icons].is_badge_layer = true
    case = Get_case(third)
    icons[#icons + 1] = GM_Build_single_letter_badge_icon(third, case, invert_str, "right", let_corner, 3, second)
    icons[#icons].is_badge_layer = true
  end
end

-- Icons Images
function GM_Build_single_img_badge_icon(path, size, scale, mips, corner, spacing)
  -- Credit to Elusive for helping with badges

  -- Image Shift
  local direction = Corner_to_direction(corner)
  local shift = {
    direction[1] * (Ib_local.default_badge_shift_icon[1] + (Ib_local.user_badge_scale * ((Ib_local.default_badge_shift_icon_adjust[1] / 2) + spacing ))),
    direction[2] * (Ib_local.default_badge_shift_icon[2] + (Ib_local.user_badge_scale * Ib_local.default_badge_shift_icon_adjust[2] / 2))
  }

  return {
    tint = {r = Ib_local.ib_badge_opacity, b = Ib_local.ib_badge_opacity, g = Ib_local.ib_badge_opacity, a = Ib_local.ib_badge_opacity},
    scale = Ib_local.user_badge_scale * scale,
    icon = path, 
    icon_size = size,
    icon_mipmaps = mips or 0,
    shift = shift
  }
end

function GM_Build_img_badge_icon(icons, paths, size, scale, mips, corner, space)
  local spacing = 0
  for i, path in pairs(paths) do
    if space then spacing = spacing + ((i - 1) * space) end
    icons[#icons + 1] = GM_Build_single_img_badge_icon(path, size, scale, mips, corner, spacing)
    icons[#icons].is_badge_layer = true
  end
end

-- Pictures Letters
function GM_Build_single_letter_badge_pictures(letter, case, invert, justify, corner, three_position, middle_char)
  -- Credit to Elusive for helping with badges
  
  -- One or Two character Shift
  local direction = Corner_to_direction(corner)
  local shift = {
    - direction[1] * (Ib_local.default_badge_shift_picture[1] - (Ib_local.user_badge_scale * Ib_local.default_badge_scale_picture / 2)),
    - direction[2] * (Ib_local.default_badge_shift_picture[2] - (Ib_local.user_badge_scale * Ib_local.default_badge_scale_picture / 2)),
  }
  
  -- Three character Shift (can only be centered (going left-to-right) but can be on top or bottom)
  local three_shift = 0
  if three_position then
    three_shift = Ib_local.three_char_icon_shift[three_position]
    shift = {
      direction[1] * ((Ib_local.user_badge_scale * three_shift * Ib_local.default_badge_scale_picture * (Parse_char_widths(middle_char))) / 8 / 8),
      - direction[2] * (Ib_local.default_badge_shift_picture[2] - (Ib_local.user_badge_scale * Ib_local.default_badge_scale_picture / 2)),
    }
  end

  return {
    tint = {r = Ib_local.ib_badge_opacity, b = Ib_local.ib_badge_opacity, g = Ib_local.ib_badge_opacity, a = Ib_local.ib_badge_opacity},
    scale = Ib_local.user_badge_scale * Ib_local.default_badge_scale_picture,
    filename = Ib_local.filepath .. Ib_local.mipmaps .. "/" .. Ib_local.mipmaps .. "-" .. justify .. "-" .. case .. letter .. invert .. ".png",
    size = Ib_local.badge_image_size,
    mipmap_count = 0,
    shift = shift
  }
end

function GM_Build_letter_badge_pictures(picture, badge, invert, repeat_count, corner)
  local case

  if not picture.layers then
    local newLayer = table.deepcopy(picture)
    picture.layers = {newLayer}
  end

  -- One letter badge
  if #badge == 1 then
    case = Get_case(badge)
    picture.layers[#picture.layers + 1] = GM_Build_single_letter_badge_pictures(badge, case, invert, "center", corner)
    picture.layers[#picture.layers].repeat_count = repeat_count
    picture.layers[#picture.layers].is_badge_layer = true
  end

  -- Two letter badge
  if #badge == 2 then
    local first = badge:sub(1,1)
    local second = badge:sub(2,2)

    case = Get_case(first)
    picture.layers[#picture.layers + 1] = GM_Build_single_letter_badge_pictures(first, case, invert, "left", corner)
    picture.layers[#picture.layers].repeat_count = repeat_count
    picture.layers[#picture.layers].is_badge_layer = true

    case = Get_case(second)
    picture.layers[#picture.layers + 1] = GM_Build_single_letter_badge_pictures(second, case, invert, "right", corner)
    picture.layers[#picture.layers].repeat_count = repeat_count
    picture.layers[#picture.layers].is_badge_layer = true
  end

  if #badge == 3 then
    local first = badge:sub(1,1)
    local second = badge:sub(2,2)
    local third = badge:sub(3,3)

    case = Get_case(first)
    picture.layers[#picture.layers + 1] = GM_Build_single_letter_badge_pictures(first, case, invert, "left", corner, 1, second)
    picture.layers[#picture.layers].repeat_count = repeat_count
    picture.layers[#picture.layers].is_badge_layer = true

    case = Get_case(second)
    picture.layers[#picture.layers + 1] = GM_Build_single_letter_badge_pictures(second, case, invert, "center", corner, 2, second)
    picture.layers[#picture.layers].repeat_count = repeat_count
    picture.layers[#picture.layers].is_badge_layer = true

    case = Get_case(third)
    picture.layers[#picture.layers + 1] = GM_Build_single_letter_badge_pictures(third, case, invert, "right", corner, 3, second)
    picture.layers[#picture.layers].repeat_count = repeat_count
    picture.layers[#picture.layers].is_badge_layer = true
  end
end

-- Pictures Images
function GM_Build_single_img_badge_pictures(path, size, scale, mips, corner, spacing)
  -- Credit to Elusive for helping with badges
  
  -- Image Shift
  local direction = Corner_to_direction(corner)
  local shift = {
    - direction[1] * (Ib_local.default_badge_shift_picture[1] - (Ib_local.user_badge_scale * ((Ib_local.default_badge_scale_picture / 2) + (spacing/64))) ),
    - direction[2] * (Ib_local.default_badge_shift_picture[2] - (Ib_local.user_badge_scale * Ib_local.default_badge_scale_picture / 2)),
  }

  return {
    tint = {r = Ib_local.ib_badge_opacity, b = Ib_local.ib_badge_opacity, g = Ib_local.ib_badge_opacity, a = Ib_local.ib_badge_opacity},
    scale = Ib_local.user_badge_scale * scale / 2,
    filename = path,
    size = size,
    mipmap_count = mips or 0,
    shift = shift
  }
end

function GM_Build_img_badge_pictures(picture, paths, size, scale, mips, repeat_count, corner, spacing)
  if not picture.layers then
    local newLayer = table.deepcopy(picture)
    picture.layers = {newLayer}
  end

  local current_spacing = 0
  for i, path in pairs(paths) do
    -- Image Badge
    if spacing then current_spacing = current_spacing + ((i - 1) * spacing) end
    picture.layers[#picture.layers + 1] = GM_Build_single_img_badge_pictures(path, size, scale, mips, corner, current_spacing)
    picture.layers[#picture.layers].repeat_count = repeat_count
    picture.layers[#picture.layers].is_badge_layer = true
  end
end
