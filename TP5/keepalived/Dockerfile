FROM debian
RUN apt update -y
RUN apt upgrade -y
RUN apt install -y keepalived

ENV STATE="MASTER"
ENV INTERFACE="enp0s8"
ENV ROUTER_ID="51"
ENV PRIORITY="100"
ENV PASSWORD="PASSWORD"
ENV VIRTUAL_IP="10.102.1.100\/24"

COPY keepalived.template /etc/keepalived/keepalived.template
RUN sed -i "s/<STATE>/${STATE}/g" /etc/keepalived/keepalived.template
RUN sed -i "s/<INTERFACE>/${INTERFACE}/g" /etc/keepalived/keepalived.template
RUN sed -i "s/<ROUTER_ID>/${ROUTER_ID}/g" /etc/keepalived/keepalived.template
RUN sed -i "s/<PRIORITY>/${PRIORITY}/g" /etc/keepalived/keepalived.template
RUN sed -i "s/<PASSWORD>/${PASSWORD}/g" /etc/keepalived/keepalived.template
RUN sed -i "s/<VIRTUAL_IP>/${VIRTUAL_IP}/g" /etc/keepalived/keepalived.template
RUN mv /etc/keepalived/keepalived.template /etc/keepalived/keepalived.conf

CMD [ "/usr/sbin/keepalived", "-n" ]