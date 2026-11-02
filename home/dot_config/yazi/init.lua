-- Icons in the same color as the file name, like rofi's launcher icons. Yazi
-- colors them per file type by default; this is its own Entity:icon (26.9.1)
-- without the per-icon style, so the icon inherits the entry's style.
function Entity:icon()
	local icon = th.icon:match(self._file, { hovered = self._file.is_hovered })
	return icon and icon.text .. " " or ""
end
