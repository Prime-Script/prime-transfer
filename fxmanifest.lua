fx_version 'cerulean'
game 'gta5'

author "NOCITY SCRIPTS | SocialPeely#4095"
description 'Vehicle Transfer for QBCore'
version '1.0.0'


shared_scripts {
	'config.lua'
}

client_scripts {
	'client.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}


