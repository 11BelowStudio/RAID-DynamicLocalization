
local function dynamicLocalization(loc)

  local t = type(loc)

  if t == "string" then
    return loc
  elseif t == "function" then
    return dynamicLocalization(loc())
  elseif t == "table" then
    return dynamicLocalization(loc[math.random(#loc)])
  end
  return loc

end


local text = LocalizationManager.text
function LocalizationManager:text(str, macros, ...)
    local custom_loc = self._custom_localizations[str]
    if custom_loc then
		custom_loc = dynamicLocalization(custom_loc)
		-- goes back to the default SuperBLT behaviour.
		macros = type(macros) == "table" and macros or {}

		custom_loc = custom_loc:gsub("($([%w_-]+);?)", function(full_match, macro_name)
			return macros[macro_name] or self._default_macros[macro_name] or full_match
		end)

		return custom_loc
    end

    return text(self, str, macros, ...)
end