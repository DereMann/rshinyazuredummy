library(DBI)

DRIVERNAME <- switch(Sys.info()[['sysname']],
                     Windows = 'SQL Server',
                     Linux = 'ODBC Driver 17 for SQL Server')
DBCONN <- DBI::dbConnect(
  odbc::odbc(),
  Driver = DRIVERNAME,
  Server = 'tcp:jrz-shinytestdb.database.windows.net,1433',
  Database = 'jrzshinyTestDB',
  UID = Sys.getenv("JRZShinyDBUser"),
  PWD = Sys.getenv("JRZShinyDBPwd")
)


dt <- dbGetQuery(DBCONN,"SELECT * FROM testtable")

dt