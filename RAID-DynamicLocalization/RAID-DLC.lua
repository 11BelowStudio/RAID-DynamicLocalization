
--- dynamicLocalization handles the dynamic localization malarkey
-- 
-- @param loc the input to DLC. Can be a string, table, or a function.
-- @param str_id the original string ID.
--               Used as a parameter when calling any functions.
-- @return string (dynamically localized based on the input).
local function dynamicLocalization(loc, str_id)

  local t = type(loc)

  if t == "string" then
    -- return strings as-is
    return loc
  elseif t == "function" then
    -- call the loc function, and call dynamicLocalization on the result of loc.
    -- we pass the original string ID as an argument to that function.
    return dynamicLocalization(loc(str_id), str_id)
  elseif t == "table" then
    if not loc.fstring then
      -- if the table doesn't include a 'fstring=' definition, treat it as list.
      -- simply pick a random item from that table (and call DLC on it)
      return dynamicLocalization(loc[math.random(#loc)],str_id)
    else
      -- if table contains 'fstring=' definition, we engage in string formatting
      -- 1. go through int indexed items (will be inserted into format string),
      --    and use DLC to prepare each of them to be inserted into fstring
      local vals = {}
      for _, v in ipairs(loc) do
        table.insert(vals, dynamicLocalization(v, str_id))
      end
      -- 2. use DLC to prepare the fstring, and then insert the 'vals' into
      --    the prepared fstring using string.format (and return it).
      return string.format(
        dynamicLocalization(loc.fstring, str_id),
        unpack(vals) -- replace with 'table.unpack' in lua 5.4
      )
    end

  end
  return loc

end


-- override the localization behaviours
local text = LocalizationManager.text
function LocalizationManager:text(str, macros, ...)
  local custom_loc = self._custom_localizations[str]
  if custom_loc then
		custom_loc = dynamicLocalization(custom_loc, str)
		-- goes back to the default SuperBLT behaviour.
		macros = type(macros) == "table" and macros or {}

		custom_loc = custom_loc:gsub("($([%w_-]+);?)", function(full_match, macro_name)
			return macros[macro_name] or self._default_macros[macro_name] or full_match
		end)

		return custom_loc
  end

  return text(self, str, macros, ...)
end