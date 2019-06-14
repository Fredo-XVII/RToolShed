#' @title Prep Multiplyr
#'
#' @details expects a nested dataframe
#' @examples
#' \dontrun {
#' test <- prep_multidplyr(dev_data_2, cores = NA, location,vd,node_td)
#' multidplyr::cluster_library(test, "dplyr")
#' parallel::stopCluster(cluster)
#'
#' test %>% dplyr::mutate(row_cnt = purrr::map(.x = data, .f = dplyr::nrow))
#' dev_data_2 %>% dplyr::mutate(row_cnt = purrr::map(.x = data, .f = nrow)) %>%
#'   select(row_cnt) %>% unnest()
#' }
#' @export

prep_multidplyr <- function(.data, cores = NA, ...) {  # Needs to take "nested" data
  # Group by list for cores
  group_var <- enquos(...) #"location","vd","node_td"

  ### Generate cores
  n_cores <- if(is.na(cores)) {
    parallel::detectCores() * .75
  } else {cores}

  ### Establish groups of nodes for cores
  var_grps <- .data %>%
    dplyr::select(!!! group_var) # .data$location,.data$vd,.data$node_td

  n_grps <- rep(1:n_cores, length.out = nrow(var_grps))

  core_grps <- bind_cols(tibble(n_grps), var_grps)

  id_cluster_grps <- .data %>% dplyr::left_join(core_grps) %>%
    dplyr::select(.data$n_grps,dplyr::everything())

  ### Build Cluster
  cluster <- multidplyr::create_cluster(n_cores)
  multidplyr::set_default_cluster(cluster)
  id_cluster <-id_cluster_grps %>%
    multidplyr::partition(n_grps, cluster = cluster) # NOTE:.data$ is not used because it bombs.
  return(id_cluster)
}
