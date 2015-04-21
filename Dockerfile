FROM octohost/ruby-2.0

ADD . /srv/www
RUN cd /srv/www; bundle install --deployment --without test development

#>> does't work --># LINK_SERVICE blobby
ENV BLOBBY_PORT_4000_TCP_PORT 80
ENV BLOBBY_PORT_4000_TCP_ADDR blobby.locallan.link

EXPOSE 4000
CMD ["/usr/local/bin/foreman","start","-d","/srv/www"]