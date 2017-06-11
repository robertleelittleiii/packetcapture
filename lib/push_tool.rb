def pushDataToCloud()

  while (true)
    items_to_push = CaptureCache.where(:processed => false)

    if items_to_push.size == 0 then
      last_item_pushed = 0
    else
      items_to_push.each do |item|
      last_item_pushed = item.id
      new_item = RawPacketData.new do |ni|
        ni.packet_type = item.packet_type
        ni.captured_data = item.captured_data
        ni.raw_data = item.raw_data
        ni.location = $APP_CONFIG["location"] || "not known: " + $ipcfg.to_s
        ni.time_stamp = item.created_at
        ni.processed = false
      end
      begin
        Timeout::timeout(5) do
          new_item.save
          item.processed = true
          item.save
        end
        
      rescue
        puts("! " * 40)
        puts("SSH and Database Connection failed.  Trying to Reastablish")
        RawPacketData.reestablish_ssh_connection
        puts("! " * 40)
        break

      end
      puts("*" * 80)
      puts("record: #{item.id} processed (#{item.captured_data})")
      puts("*" * 80)

    end
    end
  
    last_record_pushed = last_item_pushed
    
    sleep(1)
  end
end