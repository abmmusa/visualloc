cmake_minimum_required (VERSION 2.6)

if (EXISTS "${CMAKE_SOURCE_DIR}/cmake")
  set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)
endif ()

find_package (LAPACK)
find_package (GMM)
find_package (OpenMesh)
find_package (FLANN)
find_package( OpenCV REQUIRED )

#source and header of the exif reader
set (exif_SRC exif_reader/exif_reader.cc exif_reader/jhead-2.90/exif.cc exif_reader/jhead-2.90/gpsinfo.cc exif_reader/jhead-2.90/iptc.cc exif_reader/jhead-2.90/jhead.cc exif_reader/jhead-2.90/jpgfile.cc exif_reader/jhead-2.90/makernote.cc exif_reader/jhead-2.90/paths.cc )
set (exif_HDR exif_reader/exif_reader.hh exif_reader/jhead-2.90/jhead.hh)

# source and header of the feature library
set (features_SRC features/SIFT_loader.cc features/visual_words_handler.cc)
set (features_HDR features/SIFT_keypoint.hh features/SIFT_loader.hh features/visual_words_handler.hh)

# source and header of the math library
set (math_SRC math/math.cc math/matrix3x3.cc math/matrix4x4.cc math/matrixbase.cc math/projmatrix.cc math/pseudorandomnrgen.cc math/SFMT_src/SFMT.cc )
set (math_HDR math/math.hh math/matrix3x3.hh math/matrix4x4.hh math/matrixbase.hh math/projmatrix.hh  math/pseudorandomnrgen.hh math/SFMT_src/SFMT.hh math/SFMT_src/SFMT-params.hh math/SFMT_src/SFMT-params607.hh math/SFMT_src/SFMT-params1279.hh math/SFMT_src/SFMT-params2281.hh math/SFMT_src/SFMT-params4253.hh math/SFMT_src/SFMT-params11213.hh math/SFMT_src/SFMT-params19937.hh math/SFMT_src/SFMT-params44497.hh math/SFMT_src/SFMT-params86243.hh math/SFMT_src/SFMT-params132049.hh math/SFMT_src/SFMT-params216091.hh )

# source and header for the sfm functionality
set (sfm_SRC sfm/parse_bundler.cc sfm/bundler_camera.cc)
set (sfm_HDR sfm/parse_bundler.hh sfm/bundler_camera.hh)

# source and header for the 6-point pose solver
set (solver_SRC solver/solverbase.cc solver/solverproj.cc)
set (solver_HDR solver/solverbase.hh solver/solverproj.hh)

include_directories (
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${LAPACK_INCLUDE_DIR}
  ${GMM_INCLUDE_DIR}
  ${OPENMESH_INCLUDE_DIR}
  ${FLANN_INCLUDE_DIR}
)

link_directories (
  ${LAPACK_LIBRARY_DIR}
  ${OPENMESH_LIBRARY_DIR}
  ${FLANN_LIBRARY_DIR}
)

set (CMAKE_CXX_FLAGS "-fopenmp")

# set sources for the executables
add_executable (BundleAdjustCams features/SIFT_loader.cc features/SIFT_keypoint.hh features/SIFT_loader.hh ${sfm_SRC} ${sfm_HDR} math/matrix3x3.cc math/matrix4x4.cc math/matrixbase.cc math/projmatrix.cc math/matrix3x3.hh math/matrix4x4.hh math/matrixbase.hh math/projmatrix.hh BundleAdjustCams)
add_executable (pose_estimator_subdivided_wqueue_kalman ${sfm_SRC} ${exif_SRC} ${exif_HDR} ${math_SRC} ${math_HDR} ${solver_SRC} ${solver_HDR} timer.hh timer.cc RANSAC.hh RANSAC.cc features/SIFT_loader.cc features/SIFT_keypoint.hh features/SIFT_loader.hh util.hh util.cc global.hh kalman.cc kalman.hh pose_estimator_subdivided_wqueue_kalman)
add_executable (flann_matcher_reduced_allmatch features/SIFT_loader.cc features/SIFT_keypoint.hh features/SIFT_loader.hh util.hh util.cc spatialfunc.hh spatialfunc.cc flann_matcher_reduced_allmatch)



target_link_libraries (BundleAdjustCams
)


target_link_libraries (pose_estimator_subdivided_wqueue_kalman
  ${LAPACK_LIBRARY}
  ${LAPACK_LIBRARIES}
  ${GMM_LIBRARY}
  ${OpenCV_LIBS}
)


# install the executables


install( PROGRAMS ${CMAKE_BINARY_DIR}/src/BundleAdjustCams
         DESTINATION ${CMAKE_BINARY_DIR}/bin)

install( PROGRAMS ${CMAKE_BINARY_DIR}/src/pose_estimator_subdivided_wqueue_kalman
         DESTINATION ${CMAKE_BINARY_DIR}/bin)

install( PROGRAMS ${CMAKE_BINARY_DIR}/src/flann_matcher_reduced_allmatch
         DESTINATION ${CMAKE_BINARY_DIR}/bin)

install( PROGRAMS ${CMAKE_BINARY_DIR}/src/flann_matcher_reduced_allmatch_added
         DESTINATION ${CMAKE_BINARY_DIR}/bin)

