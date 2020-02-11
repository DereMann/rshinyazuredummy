FROM rocker/shiny:3.5.1
  
RUN apt-get update && apt-get install alien libaio1 libaio-dev unixodbc unixodbc-dev -y libssl-dev libcurl4-openssl-dev libv8-3.14-dev curl gnupg apt-transport-https  -y &&\
  mkdir -p /var/lib/shiny-server/bookmarks/shiny
  
# MSSQL configuration

RUN apt-get update &&\
  curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - &&\
  curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list &&\
  apt-get update &&\
  ACCEPT_EULA=Y apt-get install msodbcsql17 -y &&\
  sudo ACCEPT_EULA=Y apt-get install mssql-tools &&\
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile &&\
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc 


# R SHINY configuration

# Download and install libraries
RUN R -e "install.packages(c('odbc', 'DBI','shinydashboard', 'shinyjs', 'DT'))"
#RUN R -e "install.packages(c('plotly', 'ggplot2', 'dplyr'))"
#RUN apt-get update
#RUN apt-get install liblzma-dev libbz2-dev libicu-dev default-jdk  -y
#RUN R -e "install.packages(c('DT'))"
#RUN R -e "install.packages(c('devtools', 'formattable'))"


RUN mkdir -p /srv/shiny-server/test
COPY . /srv/shiny-server/test

# copy the app to the image COPY shinyapps /srv/shiny-server/
# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"] 
