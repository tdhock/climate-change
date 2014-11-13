works_with_R("3.1.1",
             "tdhock/ggplot2@aac38b6c48c016c88123208d497d896864e74bd7")

load("stations.RData")

p <-
  ggplot()+
  geom_point(aes(-Long, Lat), data=stations, pch=1)+
  coord_map()

pdf("figure-stations.pdf", h=5)
print(p)
dev.off()
