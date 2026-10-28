fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

name 'kartik-ghostscare-redm'
author 'Kartik'
description 'Ghosts that haunt players who are alone at night, for VORP and RSG'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/sounds/*.ogg',
}

shared_scripts {
    'config.lua',
    'bridge/shared/*.lua',
}

client_scripts {
    'bridge/**/client/*.lua',
    'client/*.lua',
    'client/scares/*.lua',
}

server_scripts {
    'bridge/**/server/*.lua',
    'server/*.lua',
}
