works_with_R("3.1.1",
             data.table="1.9.4",
             dplyr="0.3.0.2",
             "tdhock/animint@18a87f618ad8e6139a374ca9f04ae2a01de7e943",
             "tdhock/ggplot2@aac38b6c48c016c88123208d497d896864e74bd7")

load("crutem.grid.RData")
load("temperatures.RData")

head(stations.grid)

station.disp <- stations.grid %>%
  inner_join(crutem.grid, "square") %>%
  arrange(StartYear, EndYear) %>%
  mutate(station=factor(Number, Number),
         name=sub("-+$", "", Name),
         elevation.meters=ifelse(Height==-999, NA, Height),
         Lat.norm=Lat-Lat.min,
         Long.norm=Long-Long.min)

station.counts <- station.disp %>%
  group_by(square) %>%
  summarise(stations=n())

grid.counts <- inner_join(station.counts, crutem.grid)

temperatures$square <-
  factor(stations.grid[as.character(temperatures$station), "square"])

square.dates <- temperatures %>%
  group_by(square) %>%
  summarise(first.month=strftime(min(date), "%Y-%m"),
            last.month=strftime(max(date), "%Y-%m")) %>%
  arrange(first.month, last.month)
data.table(square.dates)

some.squares <- c(2050, 1375)
some.temp <- filter(temperatures, square %in% some.squares)
some.stations <- filter(station.disp, square %in% some.squares)

some.temp %>%
  group_by(square, station) %>%
  summarise(data=n())

some.temp.extra <- some.temp %>%
  group_by(square, station) %>%
  mutate(year.num=as.numeric(strftime(date, "%Y")),
         month.num=as.numeric(strftime(date, "%m")),
         date.num=year.num + month.num/12,
         date.diff=c(0, 1/12 - diff(date.num)),
         diff.thresh=ifelse(abs(date.diff) < 1e-5, 0, date.diff),
         line.id=cumsum(diff.thresh != 0)) %>%
  group_by(square, station, line.id) %>%
  mutate(line.data=n())
data.table(some.temp.extra)
data.table(head(some.temp.extra, 13))
table(some.temp.extra$line.data)
some.temp.lines <- some.temp.extra %>%
  filter(line.data > 1)
some.temp.points <- some.temp.extra %>%
  filter(line.data == 1)

ggplot()+
  theme_bw()+
  theme(panel.margin=grid::unit(0, "cm"))+
  facet_grid(station ~ .)+
  geom_line(aes(date, celsius,
                group=line.id,
                color=square),
            data=some.temp.lines)+
  geom_point(aes(date, celsius,
                color=square),
            data=some.temp.points,
             pch=1)

## Now do the same for the whole temperature data set.
temp.extra <- temperatures %>%
  filter(celsius < 50) %>% # over 50 is outlier, ignore.
  group_by(square, station) %>%
  mutate(year.num=as.numeric(strftime(date, "%Y")),
         month.num=as.numeric(strftime(date, "%m")),
         date.num=year.num + month.num/12,
         date.diff=c(0, 1/12 - diff(date.num)),
         diff.thresh=ifelse(abs(date.diff) < 1e-5, 0, date.diff),
         line.id=cumsum(diff.thresh != 0)) %>%
  group_by(square, station, line.id) %>%
  mutate(line.data=n())
data.table(temp.extra)
temp.lines <- temp.extra %>%
  filter(line.data > 1)
temp.points <- temp.extra %>%
  filter(line.data == 1)

viz <-
  list(stationMap=ggplot()+
       ggtitle("map of all stations, select square")+
       theme(axis.line=element_blank(),
             axis.text=element_blank(),
             axis.title=element_blank(),
             axis.ticks=element_blank())+
       theme_animint(width=720)+
       geom_point(aes(-Long, Lat,
                      clickSelects=station,
                      fill=elevation.meters),
                  data=station.disp,
                  pch=21)+
       geom_rect(aes(xmin=-Long.max, xmax=-Long.min,
                     ymin=Lat.min, ymax=Lat.max,
                     clickSelects=square),
                 data=grid.counts, alpha=0.5)+
       ##coord_map()+
       guides(fill="none")+
       scale_fill_gradient2(),

       squareMap=ggplot()+
       ggtitle("map zoomed to square, select stations")+
       theme(axis.line=element_blank(),
             axis.text=element_blank(),
             axis.title=element_blank(),
             axis.ticks=element_blank())+
       geom_text(aes(-2.5, 5,
                     showSelected=square,
                     label=paste0(stations, " station",
                       ifelse(stations==1, "", "s"))),
                 data=station.counts)+
       geom_point(aes(-Long.norm, Lat.norm,
                      fill=elevation.meters,
                      tooltip=paste0(name, " ",
                        Country, "Elevation=", elevation.meters),
                      showSelected=square,
                      clickSelects=station),
                  data=station.disp,
                  pch=21,
                  size=4)+
       geom_text(aes(-Long.norm, Lat.norm,
                     label=paste(name, Country),
                     showSelected=square,
                     clickSelects=station,
                     showSelected2=station),
                  data=station.disp)+
       ##coord_map()+
       scale_fill_gradient2(),

       ## observationRanges=ggplot()+
       ## geom_segment(aes(-StartYear, station,
       ##                  xend=-EndYear, yend=station,
       ##                  clickSelects=station),
       ##              data=station.disp),

       selector.types=list(station="multiple"),

       first=list(square=1861, station=c(SF=724940, Berkeley=724932)),

       title="CRUTEM4 temperature sensor stations",

       timeSeries=ggplot()+
       ggtitle("temperature time series for selected square")+
       theme_animint(width=2000, height=600)+
       geom_line(aes(date, celsius,
                     group=interaction(station, line.id),
                     showSelected=square,
                     clickSelects=station),
                 data=temp.lines, alpha=11/20)+
       geom_point(aes(date, celsius, 
                      showSelected=square,
                      clickSelects=station),
                  data=temp.points, alpha=11/20))

animint2dir(viz, "figure-stations")

## TODO: make a similar map that animates over time with
## aes(fill=temperature).

pdf("figure-stations.pdf", h=5)
print(viz$stationMap)
dev.off()
