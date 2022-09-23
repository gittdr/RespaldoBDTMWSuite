SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[Get_DB_Versions] 
AS
BEGIN

	CREATE TABLE #Temp (
		Product			VARCHAR(100),
		Version			VARCHAR(256)
      )

	DECLARE	@Catalog			VARCHAR(100),
		@Server				VARCHAR(100),
        @SQLServerVersion	VARCHAR(256)

		SET @Catalog = DB_NAME();
		SET @Server = @@SERVERNAME;
		SET @SQLServerVersion = @@VERSION;

	Insert into #Temp 
		select distinct f1.description as Product, f1.dbversion as Version from fd_version_log f1
			inner join (select description, max(begindate) as maxDb from fd_version_log group by description) f2  on f1.description=f2.description and f1.begindate = f2.maxDb
			union select  'TMWSuite' as Product, dbversion as Version from (select top 1 description, dbversion from ps_version_log order by begindate desc)x;

	Insert into #Temp (Product, Version) Values('Catalog', @Catalog)
	Insert into #Temp (Product, Version) Values('Server', @Server)
	Insert into #Temp (Product, Version) Values('SQLServerVersion', @SQLServerVersion)

	Select * from #Temp;

	Drop Table #Temp;

END
GO
GRANT EXECUTE ON  [dbo].[Get_DB_Versions] TO [public]
GO
