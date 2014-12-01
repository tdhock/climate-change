HOCKING-climate-change.pdf: HOCKING-climate-change.tex figure-stations.pdf
	pdflatex HOCKING-climate-change
	bibtex HOCKING-climate-change
	pdflatex HOCKING-climate-change
	pdflatex HOCKING-climate-change
CRUTEM.4.3.0.0.station_files/Index: 
	wget http://www.metoffice.gov.uk/hadobs/crutem4/data/station_file_format.txt
	wget http://www.metoffice.gov.uk/hadobs/crutem4/data/station_files/CRUTEM.4.3.0.0.station_files.zip
	unzip CRUTEM.4.3.0.0.station_files.zip
stations.RData: stations.R CRUTEM.4.3.0.0.station_files/Index
	R --no-save < $<
temperatures.RData: temperatures.R CRUTEM.4.3.0.0.station_files/Index
	R --no-save < $<
figure-stations.pdf: figure-stations.R stations.RData temperatures.RData
	R --no-save < $<
