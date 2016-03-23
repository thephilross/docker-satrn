# thephilross/satrn
# VERSION 0.4

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
	optparse \
	purrr \
	seqinr \
	servr \
	knitcitations \
	rdrop2 \
	corrplot \
	tufte \
	rticles \
	rmdformats

# install bioconductor packages
ADD install_bioconductor_pkgs /usr/bin/install_bioconductor_pkgs
RUN chmod +x /usr/bin/install_bioconductor_pkgs
RUN /usr/bin/install_bioconductor_pkgs && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install from github
RUN installGithub.r \
	gaborcsardi/tamper \
	thephilross/seqLogo \
	thephilross/iver

# Install BSgenome for P. falciparum
RUN git clone https://github.com/thephilross/bsgenome.pf.v24.git /BSgenome.Pfalciparum.PlasmoDB.v24 && \
  tar -czvf /BSgenome.Pfalciparum.PlasmoDB.v24_1.0.tar.gz /BSgenome.Pfalciparum.PlasmoDB.v24 && \
	R CMD INSTALL BSgenome.Pfalciparum.PlasmoDB.v24_1.0.tar.gz

# add command line interface script
ADD run_rscript.sh /usr/bin/run_rscript.sh
RUN chmod +x /usr/bin/run_rscript.sh

# install bioinformatics command line tools

# samtools
RUN mkdir /src && \
	cd /src && \
	wget https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2 && \
	tar -xvjf samtools-1.3.tar.bz2 && \
	cd samtools-1.3 && \
	make && \
	make prefix=/usr/local install

# bedtools
RUN cd /src && \
	git clone https://github.com/arq5x/bedtools2.git && \
	cd bedtools2 && \
	make && \
	make prefix=/usr/local install

# UCSC command line scripts
RUN wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/gff3ToGenePred -O /usr/local/bin/gff3ToGenePred && \
  chmod +x /usr/local/bin/gff3ToGenePred

RUN wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/genePredToBed -O /usr/local/bin/genePredToBed && \
  chmod +x /usr/local/bin/genePredToBed

# install jekyll
RUN apt-get update -qq -m && apt-get dist-upgrade -y && apt-get install -y \
  ruby-dev \
  && gem install \
	github-pages \
	jekyll \
	jekyll-paginate \
	kramdown \
	rdiscount \
	rouge \
	bundler

# clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/ && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# change username to phil
RUN usermod -l phil rstudio \
  && usermod -m -d /home/phil phil \
  && groupmod -n phil rstudio \
  && git config --system user.name thephilross \
  && git config --system user.email philippross369@gmail.com \
  && git config --system push.default simple \
  && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
  && echo '"\e[6~": history-search-backward' >> /etc/inputrc \
  && echo "phil:explicit9" | chpasswd

EXPOSE 8787
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
