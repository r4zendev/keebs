if(CONFIG_SHIELD_CHARYBDIS_DONGLE)
  zephyr_library()
  zephyr_library_sources(src/dongle_backlight.c)
endif()
