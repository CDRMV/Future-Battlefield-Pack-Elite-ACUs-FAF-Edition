local version = tonumber( (string.gsub(string.gsub(GetVersion(), '1.5.', ''), '1.6.', '')) )

if version < 3652 then -- All versions below 3652 don't have buildin global icon support, so we need to insert the icons by our own function
	LOG('Future Battlefield Pack Elite ACUs: [unitview.lua '..debug.getinfo(1).currentline..'] - Gameversion is older then 3652. Hooking "UpdateWindow" to add our own unit icons')

local MyUnitIdTable = {
   UAB0305=true, -- Origin of the Way - (Aeon: ACU-HQ)
   UEB0305=true, -- Command Hangar - (UEF: ACU-HQ)
   URB0305=true, -- Master-Hub - (Cybran: ACU-HQ)
   XSB0305=true, -- Am-Sayasta - (Seraphim: ACU-HQ)
}

	local IconPath = "/Mods/Future Battlefield Pack Elite ACUs"

	local oldUpdateWindow = UpdateWindow
	function UpdateWindow(info)
		oldUpdateWindow(info)
		if MyUnitIdTable[info.blueprintId] then
			controls.icon:SetTexture(IconPath .. '/icons/units/' .. info.blueprintId .. '_icon.dds')
		end
	end

else
	LOG('Future Battlefield Pack Elite ACUs: [unitview.lua '..debug.getinfo(1).currentline..'] - Gameversion is 3652 or newer. No need to insert the unit icons by our own function.')
end -- All versions below 3652 don't have buildin global icon support, so we need to insert the icons by our own function