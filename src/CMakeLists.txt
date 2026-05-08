add_executable(LoopDisplay
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
)
