-- mpv script to download subtitles using subdl.
-- requires subdl (2016 Sep master branch): https://github.com/alexanderwink/subdl

-- default keybinding: B  (capital B)
-- add the following to your input.conf to change the default keybinding:
-- keyname script_binding subdl_load_subs

local utils = require 'mp.utils'

function subdl_load()
    mp.msg.info("Searching subtitles...")
    mp.osd_message("Searching subtitles...")

    subdl = "/usr/bin/subdl" -- use 'which subdl' to find the path.
    language = "scc,hrv,bos,eng"
    download = "best-rating" --  Other options: first, most-downloaded

    t = {}
    t.args = {subdl, "--lang=" .. language, "--download=" .. download, mp.get_property("path")}

    res = utils.subprocess(t)

    if res.status == 0 then
        mp.commandv("rescan_external_files", "reselect") 
        mp.msg.info("Subtitle download succeeded.")
        mp.osd_message("Subtitle download succeeded.")
    else
        mp.msg.warn("Subtitle download failed!")
        mp.osd_message("Subtitle download failed!")
    end
end

mp.add_key_binding("B", "subdl_load_subs", subdl_load)
