works_with_R("3.1.1", dplyr="0.3.0.2")

load("stations.RData")

codes <-
  c("501"="Update of the CRUTEM4 database provided by CRU -10/09/2012 - see release notes for version CRUTEM.4.1.1.0",
    "502"="Update of the CRUTEM4 database provided by CRU -16/04/2013 - see release notes for version CRUTEM.4.2.0.0",
    "900"="CLIMAT data quality controlled and added by the UKMO in monthly updates",
    "902"="MCDW (Monthly CLimatic Data for the World) data added by the UKMO in monthly updates")

temperature.list <- list()
for(station.i in 1:nrow(stations)){
  station <- stations[station.i, ]
  cat(sprintf("%4d / %4d stations\n", station.i, nrow(stations)))
  number <- as.character(station$Number)
  data.file <-
    file.path("CRUTEM.4.3.0.0.station_files", substr(number, 1, 2), number)
  temperature.list[[number]] <- if(file.exists(data.file)){
    data.lines <- readLines(data.file)
    obs.line.i <- which(data.lines=="Obs:")
    stopifnot(length(obs.line.i)==1)
    temp.lines <- data.lines[(obs.line.i+1):length(data.lines)]
    sub.lines <- gsub("[ ]+", " ", temp.lines)
    data.list <- strsplit(sub.lines, split=" ")
    data.length <- sapply(data.list, length)
    stopifnot(data.length[1] == data.length)
    data.mat <- do.call(rbind, data.list)
    year <- data.mat[,1]
    temp.list <- list()
    for(month in 1:12){
      temp.str <- data.mat[, month+1]
      status <- data.mat[, month+13]
      temp.num <- as.numeric(temp.str)
      temp.num[temp.num==-99] <- NA
      temp.list[[month]] <-
        data.frame(station=number,
                   date=ISOdate(year, month, 1),
                   celsius=temp.num, status)
    }
    do.call(rbind, temp.list) %>%
      filter(!is.na(celsius)) %>%
      arrange(date)
  }
}

temperatures <- do.call(rbind, temperature.list)

save(temperature.list, temperatures, file="temperatures.RData")
