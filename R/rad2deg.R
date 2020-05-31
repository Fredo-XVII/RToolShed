#' @title  Convert radians to degree: d = r ⋅ 180 ∕ π
#'
#' @details Convert radians to degree: d = r ⋅ 180 ∕ π
#'
#' @param r numeric - radians, or output from a trigonmetric functions.
#'
#' @return A number in degrees that was converted from radians.
#'
#' @examples
#' rads <- sin(4/5)
#' rad2deg(rads)
#'
#' @export

rad2deg <- function(r) r*180/pi
