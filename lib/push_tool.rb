def pushDataToCloud()

  while (true)
  items_to_push = CaptureCache.where(:processed => false)

  items_to_push.each do |item|
    new_item = RawPacketData.new do |ni|
      ni.packet_type = item.packet_type
      ni.captured_data = item.captured_data
      ni.raw_data = item.raw_data
      ni.location = $APP_CONFIG["local"] || "not known: " + $ipcfg.to_s
      ni.processed = true
    end
    new_item.save
    item.processed = true
    item.save
    puts("*" * 80)
    puts("record: #{item.id} processed (#{item.captured_data})")
    puts("*" * 80)

  end
  
  sleep(1)
  end
end