cmake_minimum_required(VERSION 3.16)
project(LoopDisplay LANGUAGES CXX VERSION 1.0.0)

set(BUILD_NUMBER "1" CACHE STRING "Monotonically increasing build number for App Store / TestFlight")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

if(APPLE AND CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "16.0" CACHE STRING "Minimum iOS deployment version")
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Network Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

add_subdirectory(src)

install(TARGETS LoopDisplay
  BUNDLE DESTINATION .
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
