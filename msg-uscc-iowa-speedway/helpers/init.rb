# encoding: utf-8

require_relative 'msg_toolbox'
require_relative 'web_toolbox'
MyApp.helpers WebToolbox
require_relative 'speedway_tools'
MyApp.helpers SpeedwayTools

require_relative 'nicebytes'
MyApp.helpers NiceBytes

