#' @title Holiday Data
#'
#' @description Build Holiday Dataframe of holiday dates between 2 dates in the
#' form of 'yyyy-mm-dd'.  Pass a dataframe with the column of dates.
#'
#' @return The result of the function can be either a dataframe with days between
#' the minimum and maximum of the dates provided, or, the default option which is
#'  to return a dataframe with weeks instead of days.
#'
#' @name holiday_data
#'
#' @note https://github.com/cran/timeDate/blob/master/R/holiday-Dates.R
#' https://www.federalpay.org/holidays
#'
#' @return The paramater `out_df` gives the user 2 choices for output.  The
#' default output a weeks dataframe with beginning week, ending week, a holiday
#' flag, and a column for the holiday name.  The second option returns a
#' dataframe with all the days and day names with the 4 columns mention above.
#'
#' @import timeDate
#' @importFrom dplyr summarise mutate left_join if_else group_by distinct row_number filter select rename
#' @importFrom tidyr replace_na
#' @importFrom  tibble tibble
#' @importFrom lubridate year wday floor_date ceiling_date
#' @importFrom rlang .data
#' @export
#' @examples
#' \dontrun{
#' weeks_df <- tibble::tibble(weeks = seq.Date(as.Date('2015-01-01'),
#' as.Date('2020-01-01'), by = 'week'))
#' holidays_weeks(df = weeks_df) %>% head(10)
#'
#' ## Individual Holidays
#' years <- seq(2015,2020, by = 1)
#' US_ValentinesDay <- USValentinesDay(years) %>% as.Date()
#' Name_Valentines <- Holiday_Names("ValentinesDay",US_ValentinesDay)
#' }
#' @param df `dataframe` A dataframe with 1 date column with at least 2 dates.
#' @param out_df `character` `"weeks"` is the default, but can also use `"days"`
#' @rdname holiday_data

## Main Holiday Data Function -------------------------------------------------

holiday_data <- function(df, out_df = c('weeks','days')) {

  weeks <- df
  names(weeks) <- c("weeks")
  min_max_data <- weeks %>%
    dplyr::summarise(min_wk = min(.data$weeks),
                     min_yr = lubridate::year(.data$min_wk),
                     max_wk = max(.data$weeks),
                     max_yr = lubridate::year(.data$max_wk))

  cal_base <- tibble::tibble('greg_d' = seq.Date(from = min_max_data[['min_wk']], to = min_max_data[['max_wk']], by = 'day')) %>%
    dplyr::mutate(day_n = lubridate::wday(.data$greg_d, label = TRUE),
                  wk_beg_d = lubridate::floor_date(.data$greg_d,'week'),
                  wk_end_d = lubridate::ceiling_date(.data$greg_d, 'week') - 1)

  years <- seq(from = min_max_data[['min_yr']], to = min_max_data[['max_yr']], by = 1)

  ## Holidays in DFE: Easter, Black Friday, Christmas

  # Retail Holidays -----------------------------------------------------------
  US_ValentinesDay <- USValentinesDay(years) %>% as.Date()
  Name_Valentines <- Holiday_Names("ValentinesDay",US_ValentinesDay)

  US_SuperBowl <- USSuperBowl(years) %>% as.Date()
  Name_SuperBowl <- Holiday_Names("SuperBowl",US_SuperBowl)

  US_EasterEve <- timeDate::Easter(years) %>% as.Date() - 1
  Name_EasterEve <- Holiday_Names("EasterEve",US_EasterEve)

  US_Easter <- timeDate::Easter(years) %>% as.Date()
  Name_Easter <- Holiday_Names("Easter",US_Easter)

  US_SaintPatricksDay <- USSaintPatricksDay(years)%>% as.Date()
  Name_SaintPatricksDay <- Holiday_Names("SaintPatricksDay",US_SaintPatricksDay)

  US_MothersDay <- USMothersDay(years)%>% as.Date()
  Name_MothersDay <- Holiday_Names("MothersDay",US_MothersDay)

  US_FathersDay <- USFathersDay(years)%>% as.Date()
  Name_FathersDay <- Holiday_Names("FathersDay",US_FathersDay)

  US_HalloweenDay <- USHalloweenDay(years)%>% as.Date()
  Name_HalloweenDay <- Holiday_Names("HalloweenDay",US_HalloweenDay)

  US_CyberMonday <- USCyberMonday(years)%>% as.Date()
  Name_CyberMonday <- Holiday_Names("CyberMonday",US_CyberMonday)
  # Retail Holidays -----------------------------------------------------------

  # Federal Holidays ----------------------------------------------------------
  US_NewYearsEve <- as.Date(timeDate::USNewYearsDay(years)) - 1
  Name_NewYearsEve <- Holiday_Names("NewYearsEve",US_NewYearsEve)

  US_NewYearsDay <- timeDate::USNewYearsDay(years) %>% as.Date()
  Name_NewYearsDay <- Holiday_Names("NewYearsDay",US_NewYearsDay)

  US_MlkDay <- timeDate::USMLKingsBirthday(years) %>% as.Date()
  Name_MlkDay <- Holiday_Names("MlkDay",US_MlkDay)

  US_MemorialDay <- timeDate::USMemorialDay(years) %>% as.Date()
  Name_MemorialDay <- Holiday_Names("MemorialDay",US_MemorialDay)

  US_Juneteenth <- USJuneteenthDay(years) %>% as.Date()
  Name_Juneteenth <- Holiday_Names("Juneteenth",US_Juneteenth)

  US_IndependenceDay <- timeDate::USIndependenceDay(years) %>% as.Date()
  Name_IndependenceDay <- Holiday_Names("IndependenceDay",US_IndependenceDay)

  US_LaborDay <- timeDate::USLaborDay(years) %>% as.Date()
  Name_LaborDay <- Holiday_Names("LaborDay",US_LaborDay)

  US_VeteransDay <- timeDate::USVeteransDay(years) %>% as.Date()
  Name_VeteransDay <- Holiday_Names("VeteransDay",US_VeteransDay)

  US_ThanksgivingDay <- timeDate::USThanksgivingDay(years) %>% as.Date()
  Name_ThanksgivingDay <- Holiday_Names("ThanksgivingDay",US_ThanksgivingDay)

  US_ChristmasEve <- as.Date(timeDate::USChristmasDay(years)) - 1
  Name_ChristmasEve <- Holiday_Names("ChristmasEve",US_ChristmasEve)

  US_ChristmasDay <- timeDate::USChristmasDay(years) %>% as.Date()
  Name_ChristmasDay <- Holiday_Names("ChristmasDay",US_ChristmasDay)
  # Federal Holidays ----------------------------------------------------------

  #Helper code for pasting object names...NOT needed for function, only for updating code.
  #holiday_list <- ls() %>% stringr::str_which('US_') #US_, Name_
  #holiday_vector <- paste(ls()[holiday_list], collapse = ",")

  # Combine the vectors for holiday dates and holidays into a tibble for left joining
  holiday_dates <- c(US_ChristmasDay,US_ChristmasEve,US_CyberMonday,US_Easter,US_EasterEve,US_FathersDay,US_HalloweenDay,US_IndependenceDay,US_Juneteenth,US_LaborDay,US_MemorialDay,US_MlkDay,US_MothersDay,US_NewYearsDay,US_NewYearsEve,US_SaintPatricksDay,US_SuperBowl,US_ThanksgivingDay,US_ValentinesDay,US_VeteransDay)
  holiday_names <- c(Name_ChristmasDay,Name_ChristmasEve,Name_CyberMonday,Name_Easter,Name_EasterEve,Name_FathersDay,Name_HalloweenDay,Name_IndependenceDay,Name_Juneteenth,Name_LaborDay,Name_MemorialDay,Name_MlkDay,Name_MothersDay,Name_NewYearsDay,Name_NewYearsEve,Name_SaintPatricksDay,Name_SuperBowl,Name_ThanksgivingDay,Name_Valentines,Name_VeteransDay)
  holiday_df <- tibble::tibble(holiday_dates, holiday_names) %>%
    dplyr::mutate(holiday_dates = as.Date(.data$holiday_dates))
  # ---------------------------------------------------------------------------

  # Build Daily Holidays
  merge_holidays <- cal_base %>%
    dplyr::left_join(holiday_df, by = c("greg_d" = "holiday_dates")) %>%
    dplyr::mutate(
      holiday_flag = dplyr::if_else(!is.na(.data$holiday_names), 1, 0)) %>%
    tidyr::replace_na(list(holiday_names = 'NoHoliday'))

  # Removes greg_d, keeps weeks.
  filter_dates <- merge_holidays %>%
    filter(!holiday_names %in% c('NoHoliday','Juneteenth','NewYearsEve')) %>%
    dplyr::group_by(.data$wk_beg_d, .data$wk_end_d) %>%
    dplyr::mutate(wk_rank = dplyr::row_number()) %>%
    dplyr::filter(.data$wk_rank == max(.data$wk_rank)) %>%
    dplyr::select(-.data$wk_rank)

  # Build Weekly Holidays
  merge_wkly_holidays <- merge_holidays %>%
    dplyr::select(.data$greg_d, .data$day_n, .data$wk_beg_d, .data$wk_end_d) %>%
    dplyr::left_join(filter_dates) %>%
    dplyr::distinct() %>%
    dplyr::group_by(.data$wk_beg_d, .data$wk_end_d) %>%
    dplyr::select(.data$wk_beg_d, .data$wk_end_d, .data$holiday_flag) %>%
    dplyr::distinct() %>%
    tidyr::replace_na(list('holiday_flag' = 0)) %>%
    dplyr::summarise(holiday_flag = sum(.data$holiday_flag)) %>%
    dplyr::left_join(filter_dates %>% select(.data$wk_beg_d, .data$holiday_names)) %>%
    tidyr::replace_na(list(holiday_names = 'NoHoliday')) %>%
    dplyr::select(.data$wk_beg_d, .data$wk_end_d, .data$holiday_names, .data$holiday_flag)

  # Output choices
  # 1. All days with flag for holiday in for that day
  # 2. Weekly dates with flag for holiday in that week

  if(out_df[[1]] == 'days') {
    return(merge_holidays)
  } else {
    return(merge_wkly_holidays)
  }
}


## Supporting Functions -------------------------------------------------------

### Creates a vector of holiday names the same length as the holiday dates vector.
#' @export
#' @param name `character` Name of the holiday represented by the holiday_dates vector.
#' @param holiday_dates `Dates` A vector of dates representing the holiday.
#' @rdname holiday_data
Holiday_Names <- function(name, holiday_dates) {rep(name,length(holiday_dates))}

## New Retail Holiday Functions not in timeDate -------------------------------

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USValentinesDay <-
  function(year = timeDate::getRmetricsOptions("currentYear")) {
    ans = year*10000 + 0214
    timeDate::timeDate(as.character(ans)) }

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USSuperBowl <-
  function(year = timeDate::getRmetricsOptions("currentYear")) {
    ans = .nth.of.nday(year, 2, 7, 1)
    timeDate::timeDate(as.character(ans)) }

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USSaintPatricksDay <-
  function(year = timeDate::getRmetricsOptions("currentYear")) {
    ans = year*10000 + 0314
    timeDate::timeDate(as.character(ans)) }

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USMothersDay <-
  function(year = timeDate::getRmetricsOptions("currentYear")) {
    ans = .nth.of.nday(year, 5, 7, 2)
    timeDate::timeDate(as.character(ans)) }

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USFathersDay <-
  function(year = timeDate::getRmetricsOptions("currentYear")) {
    ans = .nth.of.nday(year, 6, 7, 3)
    timeDate::timeDate(as.character(ans)) }

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USHalloweenDay <-
  function(year = timeDate::getRmetricsOptions("currentYear")) {
    ans = year*10000 + 1031
    timeDate::timeDate(as.character(ans)) }

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USCyberMonday <- function(year) { as.Date(timeDate::USThanksgivingDay(year)) + 4 }

#' @export
#' @param year `numeric` A vector of year integers.
#' @rdname holiday_data
USJuneteenthDay <-
  function(year = timeDate::getRmetricsOptions("currentYear")) {
    ans = year*10000 + 0619
    timeDate::timeDate(as.character(ans)) }

## New Retail Holiday Functions not in timeDate -------------------------------
