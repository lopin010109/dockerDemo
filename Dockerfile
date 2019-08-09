FROM node:6.2.2
MAINTAINER joshhsieh
LABEL description="這是LABEL的範例" version="1.0" owner="我是owner"
WORKDIR /app
EXPOSE 300
CMD npm start