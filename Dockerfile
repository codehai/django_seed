FROM python:3.6

LABEL maintainer="szzxsh@163.com"

# Install basic tools, Sqlite and Nginx
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
ADD ./service_conf/sources.list /etc/apt/sources.list

# RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 437D05B5
# RUN gpg --export --armor 437D05B5 | apt-key add -
RUN apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        postgresql-client nginx supervisor \
    && rm -rf /var/lib/apt/lists/*
    
# Copy requirements.txt and install pip packages
ADD ./requirements.txt /requirements.txt
RUN pip install wheel -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install -r /requirements.txt -i  https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /

ADD ./conduit /app/conduit
ADD ./startup.sh /app
ADD ./manage.py /app
ADD ./service_conf /config
# ADD ./data/chromedriver /usr/bin

# Configure Nginx, uwsgi, Neo4j, and supervisord
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /config/nginx.conf /etc/nginx/sites-enabled/
RUN ln -s /config/supervisor.conf /etc/supervisor/conf.d/

# Expose ports
EXPOSE 80

# Set the default directory
WORKDIR /app

# Entry point
CMD ["bash", "startup.sh"]
