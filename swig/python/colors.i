%begin %{
// define SWIG_PYTHON_INTERPRETER_NO_DEBUG on windows debug builds as pythonXX_d is not packaged unless built from source
#ifdef _MSC_VER
#define SWIG_PYTHON_INTERPRETER_NO_DEBUG
#endif
%}

%module colors

%{
#include "flamegpu/visualiser/color/Color.h"
%}

%include "flamegpu/visualiser/color/Color.h"
