works_with_R("3.1.1", data.table="1.9.4")

Index <- read.fwf("CRUTEM.4.3.0.0.station_files/Index",
                  widths=c(6, 23, 15, 7, 7, 6, 5, 5))
Index.lines <-
  readLines("CRUTEM.4.3.0.0.station_files/Index", encoding="latin1")
stopifnot(nchar(Index.lines) == 74)
pattern <-
  paste0("(?<Number>[0-9]{6})",
         " {3}",
         "(?<Name>.{20})",
         "(?<Country>.{15})",
         "(?<Lat>.{7})",
         "(?<Long>.{7})",
         "(?<Height>.{6})",
         "(?<StartYear>.{5})",
         "(?<EndYear>.{5})")
Index.mat <- str_match_perl(Index.lines, pattern)
stopifnot(!is.na(Index.mat))
strip <- function(x){
  gsub("^[- ]*", "", gsub("[- ]*$", "", x))
}
types <-
  c(Number=as.integer,
    Name=as.character,
    Country=as.character,
    Lat=as.numeric,
    Long=as.numeric,
    Height=as.integer,
    StartYear=as.integer,
    EndYear=as.integer)
Index.list <- list()
for(col.name in names(types)){
  type.fun <- types[[col.name]]
  Index.list[[col.name]] <- type.fun(strip(Index.mat[, col.name]))
}
stations <- do.call(data.frame, Index.list)
stopifnot(!is.na(stations))

save(stations, file="stations.RData")
