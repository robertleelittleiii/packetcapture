#!/usr/bin/env ruby

# app uses gemfile
require 'bundler/setup'
Bundler.require

# app using a DB
require 'active_record'  
require 'sqlite3'

# app load all models
 $APP_PATH = File.expand_path(File.dirname(__FILE__)).split("/")[0...-1].join("/")
# $APP_PATH = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << $APP_PATH << $APP_PATH + "/lib"

Dir[$APP_PATH + '/models/*.rb'].each {|file| require file }

# Includes for apps

require 'yaml'
require 'packetfu'

$ipcfg = PacketFu::Utils.whoami?(:iface=>'en0')
$yourPIAddresquits="192.168.1.4"

#set the app env to development by default.

ENV["AppEnv"] = ENV["AppEnv"].blank? ? "development" : ENV["AppEnv"]

require "capture_tool"

$APP_CONFIG = YAML.load_file($APP_PATH + '/config/app_config.yml')[ENV["AppEnv"]]

# load yaml database config file

database_conf = YAML.load_file($APP_PATH + '/db/config.yml')

ActiveRecord::Base.establish_connection database_conf[ENV["AppEnv"]]


puts ($APP_CONFIG.inspect)
puts (database_conf.inspect)
puts (ENV["AppEnv"])
puts ($ipcfg.inspect)

puts(" Start of main program! ")
#
## To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

sniffDNSPacket()