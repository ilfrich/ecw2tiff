FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    g++ build-essential autoconf automake m4 libtool gcc make unzip wget swig \
    python3 python3-pip python3-dev

RUN apt install -y libpq-dev gdal-bin libgdal-dev

# Install libecwj2 (ECW 3.3 SDK)
RUN wget https://github.com/bogind/libecwj2-3.3/raw/master/libecwj2-3.3-2006-09-06.zip \
    && wget http://trac.osgeo.org/gdal/raw-attachment/ticket/3162/libecwj2-3.3-msvc90-fixes.patch \
    && unzip libecwj2-3.3-2006-09-06.zip \
    && patch -p0< libecwj2-3.3-msvc90-fixes.patch \
    && cd libecwj2-3.3 \
    && rm config.guess && wget https://cvs.savannah.gnu.org/viewvc/*checkout*/config/config/config.guess && chmod +x config.guess \
    && ./configure \
    && make \
    && make install \
    && cd ..

# Install gdal 3.5.3
RUN wget http://download.osgeo.org/gdal/3.5.3/gdal-3.5.3.tar.gz \
    && tar -xvf gdal-3.5.3.tar.gz \
    && cd gdal-3.5.3 \
    && ./configure --with-ecw=/usr/local --with-python \
    && make \
    && make install

RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> ~/.profile \
    && echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> ~/.bashrc \
    && ldconfig

RUN echo 'GDAL_DATA="/usr/local/share/gdal"' > /etc/environment \
    && echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"' >> /etc/environment

RUN gdalinfo --version && gdalinfo --formats | grep ECW

CMD ["/bin/bash"]
