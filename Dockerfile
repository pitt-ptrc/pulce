# Example shiny app docker file
# https://blog.sellorm.com/2021/04/25/shiny-app-in-docker/

# get shiny serveR and a version of R from the rocker project
FROM rocker/shiny-verse:4.1

# system libraries
# Try to only install system libraries you actually need
# Package Manager is a good resource to help discover system deps
# RUN apt-get update && apt-get install -y \
#     libcurl4-gnutls-dev \
#     libssl-dev

#update all packages
RUN apt-get update

#upgrade
RUN apt-get upgrade -y

#install additional packages
RUN apt install gpg-agent -y unixodbc apt-utils curl

#get msodbcsql17 and install it
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update -y
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

RUN apt-get update && apt-get install -y  \
    git-core \
    libcurl4-openssl-dev \
    libgit2-dev libicu-dev \
    libssl-dev libxml2-dev \
    make \
    pandoc \
    pandoc-citeproc \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*


# Example shiny app docker file
# https://blog.sellorm.com/2021/04/25/shiny-app-in-docker/

# get shiny serveR and a version of R from the rocker project
FROM rocker/shiny-verse:4.1

# system libraries
# Try to only install system libraries you actually need
# Package Manager is a good resource to help discover system deps
# RUN apt-get update && apt-get install -y \
#     libcurl4-gnutls-dev \
#     libssl-dev

#update all packages
RUN apt-get update

#upgrade
RUN apt-get upgrade -y

#install additional packages
RUN apt install gpg-agent -y unixodbc apt-utils curl

#get msodbcsql17 and install it
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update -y
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

#rename SQL Driver title in odbcinst file
# RUN sed -i 's/ODBC Driver 17 for SQL Server/SQL Server/' etc/odbcinst.ini

RUN apt-get update && apt-get install -y  \
    git-core \
    libcurl4-openssl-dev \
    libgit2-dev libicu-dev \
    libssl-dev libxml2-dev \
    make \
    pandoc \
    pandoc-citeproc \
#    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# install R packages required 
# Change the packages list to suit your needs
# WIP
          
# UN R -e 'install.packages(c(\
#              "golem", \
#              "config", \
#              "spelling", \
#              "attempt", \
#              "odbc", \
#              "dbplot", \
#              "pool", \
#              "glue", \
#              "htmltools", \
#              "pkgload", \
#              "dbplyr", \
#              "bslib", \
#              "knitr", \
#              "gt", \
#              
#            ), \
#            repos="https://packagemanager.rstudio.com/cran/__linux__/focal/2021-09-03"\
#          )'

RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl', Ncpus = 4)" >> /usr/local/lib/R/etc/Rprofile.site
RUN R -e 'install.packages("remotes")'
#RUN Rscript -e 'remotes::install_version("magrittr",upgrade="never", version = "2.0.1")'
#RUN Rscript -e 'remotes::install_version("tibble",upgrade="never", version = "3.1.5")'
RUN Rscript -e 'remotes::install_version("glue",upgrade="never", version = "1.4.2")'
#RUN Rscript -e 'remotes::install_version("jsonlite",upgrade="never", version = "1.7.2")'
RUN Rscript -e 'remotes::install_version("htmltools",upgrade="never", version = "0.5.2")'
#RUN Rscript -e 'remotes::install_version("purrr",upgrade="never", version = "0.3.4")'
#RUN Rscript -e 'remotes::install_version("dplyr",upgrade="never", version = "1.0.7")'
#RUN Rscript -e 'remotes::install_version("stringr",upgrade="never", version = "1.4.0")'
#RUN Rscript -e 'remotes::install_version("ggplot2",upgrade="never", version = "3.3.5")'
#RUN Rscript -e 'remotes::install_version("tidyr",upgrade="never", version = "1.1.3")'
RUN Rscript -e 'remotes::install_version("pkgload",upgrade="never", version = "1.2.1")'
RUN Rscript -e 'remotes::install_version("bslib",upgrade="never", version = "0.3.0")'
#RUN Rscript -e 'remotes::install_version("knitr",upgrade="never", version = "1.33")'
RUN Rscript -e 'remotes::install_version("attempt",upgrade="never", version = "0.3.1")'
#RUN Rscript -e 'remotes::install_version("shiny",upgrade="never", version = "1.6.0")'
RUN Rscript -e 'remotes::install_version("DBI",upgrade="never", version = "1.1.1")'
RUN Rscript -e 'remotes::install_version("gt",upgrade="never", version = "0.3.1")'
#RUN Rscript -e 'remotes::install_version("testthat",upgrade="never", version = "3.0.4")'
RUN Rscript -e 'remotes::install_version("config",upgrade="never", version = "0.3.1")'
#RUN Rscript -e 'remotes::install_version("rmarkdown",upgrade="never", version = "2.9")'
RUN Rscript -e 'remotes::install_version("thematic",upgrade="never", version = "0.1.2.1")'
RUN Rscript -e 'remotes::install_version("shinyjs",upgrade="never", version = "2.0.0")'
RUN Rscript -e 'remotes::install_version("pool",upgrade="never", version = "0.1.6")'
RUN Rscript -e 'remotes::install_version("odbc",upgrade="never", version = "1.3.2")'
RUN Rscript -e 'remotes::install_version("gtsummary",upgrade="never", version = "1.5.0")'
RUN Rscript -e 'remotes::install_version("golem",upgrade="never", version = "0.3.1")'
RUN Rscript -e 'remotes::install_version("DT",upgrade="never", version = "0.18")'
RUN Rscript -e 'remotes::install_version("dbplyr",upgrade="never", version = "2.1.1")'
RUN Rscript -e 'remotes::install_version("dbplot",upgrade="never", version = "0.3.3")'
RUN Rscript -e 'remotes::install_version("ComplexUpset",upgrade="never", version = "1.3.1")'
RUN Rscript -e 'remotes::install_github("gaborcsardi/pkgconfig@b81ae038aa5fe5d7c66c363d45a002cd8f0a4503")'
RUN Rscript -e 'remotes::install_github("rstudio/shinyvalidate@5194db03d39fc7f86044fc5d467073cef030effe")'


ADD . /srv/shiny-server/
WORKDIR /srv/shiny-server/
RUN R -e 'remotes::install_local(upgrade="never")'

# RUN mkdir /build_zone
# ADD . /build_zone
# WORKDIR /build_zone
# RUN R -e 'remotes::install_local(upgrade="never")'
# RUN rm -rf /build_zone
# EXPOSE 80
# CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');egggolemreg::run_app()"
