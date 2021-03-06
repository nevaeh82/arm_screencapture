if(SOLVER_INCLUDE_DIR AND SOLVER_LIBRARY)
  set(SOLVER_FIND_QUIETLY TRUE)
endif(SOLVER_INCLUDE_DIR AND SOLVER_LIBRARY)

find_library(SOLVER_LIBRARY Solver${BICYCLE_DEBUG_POSTFIX} PATHS ${PROJECT_BASE_DIR}/redist/solver/${FULL_QT_VERSION}/lib)

set(SOLVER_INCLUDE_DIR ${PROJECT_BASE_DIR}/redist/solver/include)

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Solver DEFAULT_MSG SOLVER_LIBRARY SOLVER_INCLUDE_DIR)

MARK_AS_ADVANCED(
  SOLVER_INCLUDE_DIR
  SOLVER_LIBRARY
)
