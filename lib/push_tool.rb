def pushDataToCloud()

  while (true)
    items_to_push = CaptureCache.where(:processed => false)

    items_to_push.each do |item|
      new_item = RawPacketData.new do |ni|
        ni.packet_type = item.packet_type
        ni.captured_data = item.captured_data
        ni.raw_data = item.raw_data
        ni.location = $APP_CONFIG["location"] || "not known: " + $ipcfg.to_s
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
  
    sleep(1)
  end
end