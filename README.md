# git-mining

Mining github repositories, a set of perl scripts and such

## Install

	cpanm --installdeps .
	
## Run

The file comodification graphs can be extracted like this

	cd data
	../../file-coo-graph.pl path-to-repo
	
it will generate 9 files with the graphs relating files and
directories to one another. 

## Data

Contains data for different repositories, in network and csv format, including temporal information.
