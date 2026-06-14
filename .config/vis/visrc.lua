-- load standard vis module, providing parts of the Lua API
require('vis')
require('plugins/filetype')

vis.events.subscribe(vis.events.INIT, function()
    -- Your global configuration options
    vis:command('set theme default')
    vis:command('set change256colors on')
    vis:command('set autoindent on')
    vis:command('set ignorecase on')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
    -- Your per window configuration options e.g.
    vis:command('set statusbar on')
    vis:command('set number on')
    vis:command('set relativenumber on')
    vis:command('set cursorline on')
    vis:command('set expandtab on')
    vis:command('set tabwidth 4')
    vis:command('set expandtab on')
    vis:command('set loadmethod auto')
    vis:command('set savemethod atomic')
end)

vis:map(vis.modes.NORMAL, "ZZ", function()
	if vis.win.file.modified then
		vis:command(':wq')
	else
		vis:command(':q!')
	end
end)
