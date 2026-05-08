add_library(qml STATIC
  main.qml
  components/PanKnob.qml
  components/LevelMeter.qml
  components/FeedbackDial.qml
  components/LoopArc.qml
  components/StateIndicator.qml
  components/TrackRow.qml
)

target_link_libraries(qml PRIVATE
  Qt6::Core
  Qt6::Gui
  Qt6::Qml
  Qt6::Network
  Qt6::Quick
)
