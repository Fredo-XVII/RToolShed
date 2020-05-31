#' @title  Convert radians to degree
#'
#' @description Convert radians to degree: d = r x 180 x (1/pi)
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
