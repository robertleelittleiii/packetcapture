class CaptureCache < ActiveRecord::Base

  establish_connection $DATABASE_CONF[ENV["AppEnv"]]
  
  puts($DATABASE_CONF.inspect)
  
 
end