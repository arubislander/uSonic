include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(
    Usonicbackend_SRCS
    modules/Usonic/backend.cpp
    modules/Usonic/mytype.cpp
)

# Make the unit test files visible on qtcreator
add_custom_target(Usonicbackend_UNITTEST_QML_FILES ALL SOURCES "tests/unit/tst_mytype.qml")

add_library(Usonicbackend MODULE
    ${Usonicbackend_SRCS}
)

set_target_properties(Usonicbackend PROPERTIES
         LIBRARY_OUTPUT_DIRECTORY Usonic)

qt5_use_modules(Usonicbackend Gui Qml Quick)

# Copy qmldir file to build dir for running in QtCreator
add_custom_target(Usonicbackend-qmldir ALL
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/modules/Usonic/qmldir ${CMAKE_CURRENT_BINARY_DIR}/Usonic
    DEPENDS ${QMLFILES}
)

# Install plugin file
install(TARGETS Usonicbackend DESTINATION ${QT_IMPORTS_DIR}/Usonic/)
install(FILES   modules/Usonic/qmldir DESTINATION ${QT_IMPORTS_DIR}/Usonic/)
