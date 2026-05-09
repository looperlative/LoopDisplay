qt_add_executable(LoopDisplay
  main.cpp
  udpprotocol/protocol.h
  udpprotocol/protocol.cpp
  udpprotocol/devicefinder.h
  udpprotocol/devicefinder.cpp
  udpprotocol/devicenetwork.h
  udpprotocol/devicenetwork.cpp
  mixermodel/mixermodel.h
  mixermodel/mixermodel.cpp
  resources.qrc
  Assets.xcassets
  ${CMAKE_SOURCE_DIR}/qml/main.qml
  ${CMAKE_SOURCE_DIR}/qml/components/PanKnob.qml
  ${CMAKE_SOURCE_DIR}/qml/components/LevelMeter.qml
  ${CMAKE_SOURCE_DIR}/qml/components/FeedbackDial.qml
  ${CMAKE_SOURCE_DIR}/qml/components/LoopArc.qml
  ${CMAKE_SOURCE_DIR}/qml/components/StateIndicator.qml
  ${CMAKE_SOURCE_DIR}/qml/components/TrackRow.qml
)

target_compile_definitions(LoopDisplay PRIVATE
    APP_VERSION="${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}"
)

target_include_directories(LoopDisplay PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/udpprotocol
  ${CMAKE_CURRENT_SOURCE_DIR}/mixermodel
)

target_link_libraries(LoopDisplay PRIVATE
  Qt6::Core
  Qt6::Gui
  Qt6::Qml
  Qt6::Network
  Qt6::Quick
  Qt6::QuickControls2
)

if(APPLE AND CMAKE_SYSTEM_NAME STREQUAL "iOS")
  target_sources(LoopDisplay PRIVATE ioshelper.mm)
  target_link_libraries(LoopDisplay PRIVATE
    Qt6::qtquick2plugin
    Qt6::qtquickcontrols2plugin
    Qt6::qtquickcontrols2implplugin
    Qt6::qtquickcontrols2iosstyleplugin
    Qt6::qquicklayoutsplugin
  )
endif()

set_target_properties(LoopDisplay PROPERTIES
  MACOSX_BUNDLE TRUE
  MACOSX_BUNDLE_GUI_IDENTIFIER "com.amstadt.LoopDisplay"
  MACOSX_BUNDLE_BUNDLE_VERSION ${BUILD_NUMBER}
  MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
  XCODE_ATTRIBUTE_CURRENT_PROJECT_VERSION "${BUILD_NUMBER}"
  XCODE_ATTRIBUTE_MARKETING_VERSION "${PROJECT_VERSION}"
  XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
  XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT "dwarf-with-dsym"
)

if(APPLE AND CMAKE_SYSTEM_NAME STREQUAL "iOS")
  set_target_properties(LoopDisplay PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in"
  )
endif()

if(ANDROID)
  set_target_properties(LoopDisplay PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android"
    QT_ANDROID_TARGET_SDK_VERSION 36
  )
endif()

qt_import_qml_plugins(LoopDisplay)
