# Doxygen
find_package(Doxygen OPTIONAL_COMPONENTS mscgen dia dot)
if(DOXYGEN_FOUND)
    include(CMakeDependentOption)
    option(FLAMEGPU_BUILD_API_DOCUMENTATION "Enable building documentation (requires Doxygen)" ON)
    # option to hide / not hide the detail namespace from the docs, developers can enable it if they want detail docs / the actual docs website might require this due to breathe/exhale not respecting doxygen exclude correctly and not having an equivalent option.
    cmake_dependent_option(FLAMEGPU_API_DOCUMENTATION_EXCLUDE_DETAIL "Exclude the detail namespace from doxygen documentation" ON "FLAMEGPU_BUILD_API_DOCUMENTATION" ON)
    mark_as_advanced(FLAMEGPU_API_DOCUMENTATION_EXCLUDE_DETAIL)
else()
	if(CMAKE_CUDA_COMPILER STREQUAL NOTFOUND)
		message(FATAL_ERROR 
			" Doxygen: NOT FOUND!\n"
			" Documentation project cannot be generated.\n"
			" Please install Doxygen and re-run configure.")
	
	else()
		message( 
			" Doxygen: NOT FOUND!\n"
			" Documentation project cannot be generated.\n"
			" Please install Doxygen and re-run configure if required.")
	endif()
endif()

function(flamegpu_create_doxygen_target FLAMEGPU_ROOT DOXY_OUT_DIR XML_PATH)
    if(DOXYGEN_FOUND)
        # Modern method which generates unique doxyfile
        # These args taken from readme.md at time of commit
        set(DOXYGEN_OUTPUT_DIRECTORY "${DOXY_OUT_DIR}")
        set(DOXYGEN_PROJECT_NAME "FLAMEGPU 2.0")
        set(DOXYGEN_PROJECT_NUMBER "")
        set(DOXYGEN_PROJECT_BRIEF "Expansion of FLAMEGPU to provide middle-ware for complex systems simulations to utilise CUDA.")
        set(DOXYGEN_GENERATE_LATEX        NO)
        set(DOXYGEN_EXTRACT_ALL           YES)
        set(DOXYGEN_CLASS_DIAGRAMS        YES)
        set(DOXYGEN_HIDE_UNDOC_RELATIONS  NO)
        set(DOXYGEN_CLASS_GRAPH           YES)
        set(DOXYGEN_COLLABORATION_GRAPH   YES)
        set(DOXYGEN_UML_LOOK              YES)
        set(DOXYGEN_UML_LIMIT_NUM_FIELDS  50)
        set(DOXYGEN_TEMPLATE_RELATIONS    YES)
        set(DOXYGEN_DOT_TRANSPARENT       NO)
        set(DOXYGEN_CALL_GRAPH            YES)
		set(DOXYGEN_RECURSIVE             YES)
        set(DOXYGEN_CALLER_GRAPH          YES)
        set(DOXYGEN_GENERATE_TREEVIEW     YES)
        set(DOXYGEN_EXTRACT_PRIVATE       YES)
        set(DOXYGEN_EXTRACT_STATIC        YES)
        set(DOXYGEN_EXTRACT_LOCAL_METHODS NO)
        set(DOXYGEN_FILE_PATTERNS         "*.h" "*.cuh" "*.c" "*.cpp" "*.cu" "*.cuhpp" "*.md" "*.hh" "*.hxx" "*.hpp" "*.h++" "*.cc" "*.cxx" "*.c++")
        set(DOXYGEN_EXTENSION_MAPPING     "cu=C++" "cuh=C++" "cuhpp=C++")
        # Limit diagram graph node count / depth for simply diagrams.
        set(DOXYGEN_DOT_GRAPH_MAX_NODES   100)
        set(DOXYGEN_MAX_DOT_GRAPH_DEPTH   1)
        # Select diagram output format i.e png or svg
        set(DOXYGEN_DOT_IMAGE_FORMAT      png)
        # If using svg the interactivity can be enabled if desired.
        set(DOXYGEN_INTERACTIVE_SVG       NO)
        # Replace full absolute paths with relative paths to the project root.
        set(DOXYGEN_FULL_PATH_NAMES       YES)
        set(DOXYGEN_STRIP_FROM_PATH       ${FLAMEGPU_ROOT})
        set(DOXYGEN_STRIP_FROM_INC_PATH   ${FLAMEGPU_ROOT})
        # Upgrade warnings
        set(DOXYGEN_QUIET                 YES) # Supress non warning messages
        set(DOXYGEN_WARNINGS              YES)
        set(DOXYGEN_WARN_IF_UNDOCUMENTED  YES)
        set(DOXYGEN_WARN_IF_DOC_ERROR     YES)
        set(DOXYGEN_WARN_IF_INCOMPLETE_DOC YES)
        set(DOXYGEN_WARN_NO_PARAMDOC      YES) # Defaults off, unlike other warning settings
        if(FLAMEGPU_WARNINGS_AS_ERRORS)
            if(DOXYGEN_VERSION VERSION_GREATER_EQUAL 1.9.0)
                set(DOXYGEN_WARN_AS_ERROR     FAIL_ON_WARNINGS)
            else()
                set(DOXYGEN_WARN_AS_ERROR     YES)
            endif()
        endif()
        # Ignore some namespaces where forward declarationss lead to empty namespaces in the docs.
        set(DOXYGEN_EXCLUDE_SYMBOLS "jitify" "tinyxml2")
        # Ignore detail too if the advanced option is enabled, this is currently required for API docs due to exhale/breathe issues.
        if(FLAMEGPU_API_DOCUMENTATION_EXCLUDE_DETAIL)
            list(APPEND DOXYGEN_EXCLUDE_SYMBOLS "detail")
        endif()
        # These are required for expanding FLAMEGPUException definition macros to be documented
        set(DOXYGEN_ENABLE_PREPROCESSING  YES)
        set(DOXYGEN_MACRO_EXPANSION       YES)
        set(DOXYGEN_EXPAND_ONLY_PREDEF    YES)
        set(DOXYGEN_PREDEFINED            "DERIVED_FLAMEGPUException(name,default_message)=class name: public flamegpu::FLAMEGPUException { public: explicit name(const char *format = default_message)\; }" "FLAMEGPU_VISUALISATION= ")
        set(DOXY_INPUT_FILES              "${FLAMEGPU_ROOT}/include;${FLAMEGPU_ROOT}/src;${FLAMEGPU_ROOT}/README.md")
        # Do not generate a todo list page
        set(DOXYGEN_GENERATE_TODOLIST             NO)
        # Create doxygen target            
        if("${XML_PATH}" STREQUAL "")
            if(NOT TARGET "docs")
                set(DOXYGEN_GENERATE_HTML     YES)
                set(DOXYGEN_GENERATE_XML      NO)
                set(DOXYGEN_HTML_OUTPUT       docs)
                doxygen_add_docs("docs" "${DOXY_INPUT_FILES}")
                set_target_properties("docs" PROPERTIES EXCLUDE_FROM_ALL TRUE)
                if(COMMAND flamegpu_set_target_folder)
                    # Put within FLAMEGPU filter
                    flamegpu_set_target_folder("docs" "FLAMEGPU")
                endif()
            endif()
        else()
            if(NOT TARGET "api_docx_xml")
                set(DOXYGEN_GENERATE_HTML     NO)
                set(DOXYGEN_GENERATE_XML      YES)
                set(DOXYGEN_XML_OUTPUT        "${XML_PATH}")
                doxygen_add_docs("api_docs_xml" "${DOXY_INPUT_FILES}")
                set_target_properties("api_docs_xml" PROPERTIES EXCLUDE_FROM_ALL TRUE)
                if(COMMAND flamegpu_set_target_folder)
                    # Put within FLAMEGPU filter
                    flamegpu_set_target_folder("api_docs_xml" "FLAMEGPU")
                endif()
            endif()
        endif()
    endif()  
endfunction()
