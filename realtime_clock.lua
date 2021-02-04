obs           = obslua
source_name   = ""
last_text     = ""

hotkey_id     = obs.OBS_INVALID_HOTKEY_ID

-- Function to set the time text
function set_time_text()
	local time = os.date("*t")
	local seconds = math.floor(time.sec)
	local minutes = math.floor(time.min + seconds / 60.0)
	local hours = math.floor(time.hour + (minutes * 60.0) / 3600.0)
	local text = string.format("%02d:%02d:%02d", hours, minutes, seconds)

	if text ~= last_text then
		local source = obs.obs_get_source_by_name(source_name)
		if source ~= nil then
			local settings = obs.obs_data_create()
			obs.obs_data_set_string(settings, "text", text)
			obs.obs_source_update(source, settings)
			obs.obs_data_release(settings)
			obs.obs_source_release(source)
		end
	end

	last_text = text
end

function timer_callback()
	set_time_text()
end

function script_properties()
	local props = obs.obs_properties_create()
	local p = obs.obs_properties_add_list(props, "source", "Text Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_unversioned_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(p, name, name)
			end
		end
	end
	obs.source_list_release(sources)

	return props
end

obs.obs_register_source(source_def)

function script_description()
	return "Sets a text source to act as a real time clock when the source is active.\n\nMade by serega404"
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
	source_name = obs.obs_data_get_string(settings, "source")
	enable_timer()
end

function script_load(settings)
	if source ~= nil then
		enable_timer()
	end
end

function enable_timer()
	print("Timer started")
	set_time_text()
	obs.timer_add(timer_callback, 1000)
end
