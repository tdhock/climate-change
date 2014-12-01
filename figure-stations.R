works_with_R("3.1.1",
             dplyr="0.3.0.2",
             "tdhock/animint@1ae7e8aa094027a44aedabbb49b997591d8345d9",
             "tdhock/ggplot2@aac38b6c48c016c88123208d497d896864e74bd7")

load("stations.RData")
load("temperatures.RData")

## From http://www.metoffice.gov.uk/hadobs/crutem4/data/Read_instructions.txt,
## Data Array (72x36)
## Item (1,1) stores the value for the 5-deg-area centred at 177.5W and 87.5N
## Item (72,36) stores the value for the 5-deg-area centred at 177.5E and 87.5S
long.edges <- seq(-177.5, 177.5, by=5)
lat.edges <- seq(-87.5, 87.5, by=5)
## Idea: use this grid to make some squares over the map so we can
## also show a second plot with a zoomed version of the map.

station.disp <- stations %>%
  arrange(StartYear, EndYear) %>%
  mutate(station=factor(Number, Number),
         name=sub("-+$", "", Name),
         elevation.meters=ifelse(Height==-999, NA, Height))
viz <-
  list(stationMap=ggplot()+
       geom_point(aes(-Long, Lat,
                      fill=elevation.meters,
                      tooltip=paste0(name, Country, "Elevation=", elevation.meters),
                      clickSelects=station),
                  data=station.disp,
                  pch=21)+
       scale_fill_gradient2()+
       coord_map(),

       ## observationRanges=ggplot()+
       ## geom_segment(aes(-StartYear, station,
       ##                  xend=-EndYear, yend=station,
       ##                  clickSelects=station),
       ##              data=station.disp),

       timeSeries=ggplot()+
       ##geom_text(aes(label=name),
       geom_point(aes(date, celsius, group=station,
                      showSelected=station),
                  data=temperatures))

pdf("figure-stations.pdf", h=5)
print(viz$stationMap)
dev.off()
