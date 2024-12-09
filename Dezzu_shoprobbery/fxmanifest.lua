fx_version 'cerulean'
game 'gta5'
author 'Dezzu'
description 'Dezzu_shoprobbery'
lua54 'yes'

client_scripts {
    'client.lua',
}

server_scripts {
    'sv_config.lua',
    'server.lua',
    
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    
}
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/js.js',
}
dependencies {
    'ox_lib' 
}