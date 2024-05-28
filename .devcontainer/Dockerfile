FROM iwajlowantulew1/dhr:v3 as base
FROM base as build
WORKDIR /workspace
RUN ln -fs /usr/share/zoneinfo/Europe/Sofia /etc/localtime
FROM build as final
