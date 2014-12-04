works_with_R("3.1.1",
             dplyr="0.3.0.2")

load("stations.RData")

## From http://www.metoffice.gov.uk/hadobs/crutem4/data/Read_instructions.txt,
## Data Array (72x36)
## Item (1,1) stores the value for the 5-deg-area centred at 177.5W and 87.5N
## Item (72,36) stores the value for the 5-deg-area centred at 177.5E and 87.5S
long.mid <- seq(-177.5, 177.5, by=5)
lat.mid <- seq(-87.5, 87.5, by=5)
## Idea: use this grid to make some squares over the map so we can
## also show a second plot with a zoomed version of the map.
crutem.grid <- expand.grid(Long.mid=long.mid, Lat.mid=lat.mid) %>%
  mutate(Long.min=Long.mid-2.5,
         Long.max=Long.mid+2.5,
         Lat.min=Lat.mid-2.5,
         Lat.max=Lat.mid+2.5)
crutem.grid$square <- 1:nrow(g)
## any way to use data.table foverlaps rather than this inefficient
## loop?
stations.grid.list <- list()
for(square in 1:nrow(g)){
  G <- crutem.grid[square, ]
  cat(sprintf("%4d / %4d\n", square, nrow(g)))
  some <- stations %>%
    filter(G$Lat.min < Lat, Lat <= G$Lat.max,
           G$Long.min < Long, Long <= G$Long.max)
  if(nrow(some)){
    some$square <- square
    stations.grid.list[[paste("square", square)]] <- some
  }
}

stations.grid <- do.call(rbind, stations.grid.list)
rownames(stations.grid) <- stations.grid$Number
nrow(stations)
nrow(stations.grid)
stations %>%
  filter(!Number %in% stations.grid$Number)

save(crutem.grid, stations.grid, file="crutem.grid.RData")
