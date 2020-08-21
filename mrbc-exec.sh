rm ../../application-samples/main_task_rb.h
rm ../../application-samples/task1_rb.h

../../mruby/bin/mrbc -g -v -Bcode -o../../application-samples/main_task_rb.h ../../application-samples/main_task-sample1.rb
../../mruby/bin/mrbc -g -v -Bcode -o../../application-samples/task1_rb.h ../../application-samples/task1-sample1.rb
