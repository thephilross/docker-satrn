# thephilross/satrn
# VERSION 0.3

FROM rocker/hadleyverse

MAINTAINER Philipp Ross, philippross369@gmail.com

# update
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get dist-upgrade -y

#RUN apt-get install -y -f \
	#mesa-common-dev \
	#libglu1-mesa-dev \
	#libdrm-dev \
	#libharfbuzz-dev \
	#libcairo2-dev \
	#libpango1.0-dev \
	#nodejs-legacy \
	#npm \
	#libgif-dev && \
	#npm install vega && \
	#ln -s /node_modules/vega/bin/* /usr/bin/ && \
	
# Install from CRAN
# add pipeR and rlist
RUN install.r ggvis \
	gplots \
	foreach \
	cowplot \
	NeatMap \
	RJSONIO \
	DT \
	glmnet \
	vioplot \
	optparse

# Install from github
RUN installGithub.r rstudio/rticles 

ADD install_bioconductor_pkgs /usr/bin/install_bioconductor_pkgs
RUN chmod +x /usr/bin/install_bioconductor_pkgs
RUN /usr/bin/install_bioconductor_pkgs && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# install bioinformatics command line tools
RUN mkdir /src && \
	cd /src && \
	wget https://github.com/samtools/samtools/releases/download/1.2/samtools-1.2.tar.bz2 && \
	tar -xvjf samtools-1.2.tar.bz2 && \
	cd samtools-1.2 && \
	make && \
	make prefix=/usr/local install

RUN cd /src && \
	git clone https://github.com/arq5x/bedtools2.git && \
	cd bedtools2 && \
	make && \
	make prefix=/usr/local install

RUN apt-get clean && rm -rf /var/lib/apt/lists/ && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
