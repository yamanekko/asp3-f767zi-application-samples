MRuby::Build.new do |conf|
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  # Turn on `enable_debug` for better debugging
  enable_debug

  conf.cc.defines = %w(MRB_ENABLE_ALL_SYMBOLS)
  conf.cc.command = ENV["CC"] || "gcc"
  conf.gembox 'default'
end

MRuby::CrossBuild.new('nucleo-f767zi-tp') do |conf|

  GNU_TOOL_PREFX = "arm-none-eabi-"
  TOPPRES_ROOT = "../asp3-f767zi"

  toolchain :gcc

  enable_debug

  F767ZI_INCLUDES = %w(
    Inc
    Drivers/STM32F7xx_HAL_Driver/Inc
    Drivers/STM32F7xx_HAL_Driver/Inc/Legacy
    Drivers/CMSIS/Device/ST/STM32F7xx/Include
    Drivers/CMSIS/Include
  )
  
  TOPPERS_INCLUDES = %w(
    include
    library
    target
    target/nucleo_f767zi_gcc
    target/nucleo_f767zi_gcc/stm32fcube
    syssvc
    arch/gcc
    arch/arm_m_gcc/stm32f7xx_stm32cube
    arch/arm_m_gcc/common
    arch/arm_m_gcc/stm32f7xx_stm32cube/STM32F7xx_HAL_Driver/Inc
    arch/arm_m_gcc/stm32f7xx_stm32cube/CMSIS/Device/ST/STM32F7xx/Include
    arch/arm_m_gcc/stm32f7xx_stm32cube/CMSIS/Core/Include
  )

  conf.cc do |cc|
    cc.command = "#{GNU_TOOL_PREFX}gcc"

    cc.include_paths << ["#{MRUBY_ROOT}/build/"]
    cc.include_paths << TOPPERS_INCLUDES.map{|inc| File.join(TOPPRES_ROOT, inc)}

    # toppersにあわせる
    cc.flags = %w(-mcpu=cortex-m7 -mfloat-abi=softfp -mfpu=fpv5-d16
                  -MMD -MP -Wall
                  -DSTM32F767xx -DUSE_TIM_AS_HRT -DTOPPERS_CORTEX_M7
                  -D__TARGET_ARCH_THUMB=4 -D__TARGET_FPU_FPV5_DP -DTOPPERS_FPU_ENABLE
                  -DTOPPERS_FPU_LAZYSTACKING -DTOPPERS_FPU_CONTEXT  -DTLSF_USE_LOCKS -DTLSF_STATISTIC -DTOPPERS
                 )

    cc.flags << %w(-g)
#    cc.flags << %w(-Os)
    cc.flags << %w(-O2)
    cc.compile_options = "%{flags} -o %{outfile} -c %{infile}"

    #configuration for low memory environment
    cc.defines << %w(MRB_HEAP_PAGE_SIZE=64)
    cc.defines << %w(KHASH_DEFAULT_SIZE=8)
    cc.defines << %w(MRB_STR_BUF_MIN_SIZE=20)
    #cc.defines << %w(MRB_GC_STRESS)
    cc.defines << %w(MRB_DISABLE_STDIO) #if you dont need stdio.
    #cc.defines << %w(POOL_PAGE_SIZE=1000) #effective only for use with mruby-eval
    cc.defines << %w(MRB_ENABLE_ALL_SYMBOLS)
    cc.defines << %w(MRB_METHOD_T_STRUCT)
    cc.defines << %w(MRB_IV_SEGMENT_SIZE=4)
    cc.defines << %w(TOPPERS)
  end

  conf.cxx do |cxx|
    cc = conf.cc
    cxx.command = cc.command.dup
    cxx.include_paths = cc.include_paths.dup
    cxx.flags = cc.flags.dup
    cxx.flags << %w(-fno-rtti -fno-exceptions)
    cxx.defines = cc.defines.dup
    cxx.compile_options = cc.compile_options.dup
  end

  conf.archiver do |archiver|
    archiver.command = "#{GNU_TOOL_PREFX}ar"
    archiver.archive_options = 'rcs %{outfile} %{objs}'
  end

  #no executables
  conf.bins = []

  #do not build executable test
  conf.build_mrbtest_lib_only

  #disable C++ exception
  conf.disable_cxx_exception

  #gems from core
#  conf.gem :core => "mruby-string-ext"
  conf.gem "#{MRUBY_ROOT}/../mruby-stm-nucleo-toppers"
  conf.gem "#{MRUBY_ROOT}/../mruby-tlsf"
  conf.gem "#{MRUBY_ROOT}/../mruby-sample1"
end
