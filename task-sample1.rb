PORT_ID = 1
logger = Nucleo::Serial.new(PORT_ID)
logger.syslog("###-- task#{Nucleo::TASK_NO} active\r\n")
loop = Nucleo::Sample1.new()
que = Nucleo::DataQue.new(Nucleo::DATA_QUE_ID)
counter = 0
command = 0
while true
  counter += 1
  command = que.receive_polling
  logger.syslog("task#{Nucleo::TASK_NO} is running #{counter} : #{command}.  |")
  loop.consume_time_task_loop

  if command
    case command
    when 101 #e
      logger.syslog("task#{Nucleo::TASK_NO}:e ext_tsk")
      Nucleo::Task.exit()
    when 115 #s
      logger.syslog("task#{Nucleo::TASK_NO}:s slp_tsk")
      Nucleo::Task.sleep()
    when 83 #S
      logger.syslog("task#{Nucleo::TASK_NO}:S tslp_tsk(10000000)")
      Nucleo::Task.sleep(10000)
    when 100 #d 10sは長いので5sにする
      logger.syslog("task#{Nucleo::TASK_NO}:d dly_tsk(5000000)")
      Nucleo::Task.delay(5000)
    when 121 #y
      logger.syslog("task#{Nucleo::TASK_NO}:y dis_ter")
      Nucleo::Task.disable_terminate()
    when 89 #Y
      logger.syslog("task#{Nucleo::TASK_NO}:Y ena_ter")
      # ena_ter
      Nucleo::Task.enable_terminate()
    else
      #NucleoではCPUEXXC1未定義のためz,Zもなし
      logger.syslog("Unknown task#{Nucleo::TASK_NO}: #{command}")
    end
  end
GC.start
end
