FROM debian:bullseye

# Update and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        sudo \
        pkg-config \
        ca-certificates \
        locales \
        tzdata \
        golang \
        fontconfig \
        gcc \
        cron \
        ffmpeg \
    && dpkg-reconfigure locales \
    && apt-get clean

# Create system link to python3
RUN ln -s /usr/bin/python3 /usr/bin/python

ENV USERNAME=realwiseman

# Set up the download directories
RUN mkdir -p /downloads

# Set up the cron environment
RUN mkdir /etc/crontabs

# Set up the locale environment
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Clone the scdl repository
RUN git clone https://github.com/flyingrub/scdl.git

# Change the working directory
WORKDIR /scdl

# Install the package
RUN python setup.py install

# Set up the timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Validate SCDL
RUN scdl --version

# Create a crontab file that logs to stdout through a named pipe
RUN mkdir -p /var/log/cron && \
    echo "0 0 * * * scdl -f -c --onlymp3 -l https://soundcloud.com/$USERNAME --path /downloads --debug 2>&1 | tee /proc/1/fd/1" > /crontab.txt && \
    crontab /crontab.txt && \
    rm /crontab.txt

# Create an entrypoint script that will send logs to stdout
RUN echo '#!/bin/sh\n\
echo "Starting initial download for $USERNAME..."\n\
scdl -f -c --onlymp3 -l https://soundcloud.com/$USERNAME --path /downloads --debug 2>&1\n\
\n\
echo "Starting cron service..."\n\
cron -f' > /entrypoint.sh && chmod +x /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
