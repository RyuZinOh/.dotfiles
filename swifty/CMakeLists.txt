cmake_minimum_required(VERSION 3.16)
project(SwiftyWallpaperSelector)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets Core Gui)

add_executable(swifty main.cpp)

target_link_libraries(swifty
    PRIVATE
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
)

if(WIN32)
    set_target_properties(swifty PROPERTIES WIN32_EXECUTABLE TRUE)
endif()
