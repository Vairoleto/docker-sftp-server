FROM alpine:3.10
RUN apk update && \
    apk add sqlite 
RUN mkdir /database && \
	sqlite3 /database/sftp.db "CREATE TABLE EMPRESA (ID INTEGER PRIMARY KEY AUTOINCREMENT,NOMBRE TEXT NOT NULL,PUERTO INT NOT NULL);"
CMD sleep 365d