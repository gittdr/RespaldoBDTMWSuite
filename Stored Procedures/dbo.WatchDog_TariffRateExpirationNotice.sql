SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--WatchDogProcessing 'WatchDog_TariffRateExpirationNotice' ,1

CREATE PROC [dbo].[WatchDog_TariffRateExpirationNotice] 
	(
		@MinThreshold FLOAT = 30, -- Days
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalDriverExpirationNotice',
		@WatchName VARCHAR(255)='WatchDriverExpirationNotice',
		@ThresholdFieldName VARCHAR(255) = 'Days',
		@ColumnNamesOnly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@MODO VARCHAR(10) = ''
	)
						

AS

SET NOCOUNT ON

/*
Procedure Name:    WatchDog_TariffRateExpirationNotice
Author/CreateDate: Lori Brickley / 10-19-2005
Purpose: 	  Returns rates which will be expiring in x Days
Revision History: david wilks 3/31/06 exclude rates that already expired
*/

/*
if not exists (select WatchName from WatchDogItem where WatchName = 'TariffRateExpirationNotice')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('TariffRateExpirationNotice','12/30/1899','12/30/1899','WatchDog_TariffRateExpirationNotice','','',0,0,'','','','','',1,0,'','','')
*/

--Reserved/Mandatory WatchDog Variables
DECLARE @SQL VARCHAR(8000)
DECLARE @COLSQL VARCHAR(4000)
--Reserved/Mandatory WatchDog Variables
declare @temprc table (tarifa int,ciudadorigen varchar(50),destino varchar(50),inicia datetime,termina datetime)

--Standard Parameter Initialization



/*******************************************************************************************
	Select Driver and Expiration data where the expiration is not completed and it is
	within the minimum threshold days.
*******************************************************************************************/

IF @MODO = 'TARKEY'
 BEGIN

	SELECT 	tariffheader.tar_number as [Tariff Number],
       		tar_description as Descripcion,
       		format(trk_startdate,'dd-MM-yy') as FechaInicio,
			format(trk_enddate,'dd-MM-yy') as FechaCaducidad,
			trk_billto as [Cliente]  --Se agrego cliente MOAM
	INTO   	#TempResults 
	FROM   	tariffkey (NOLOCK) JOIN tariffheader (NOLOCK) on tariffkey.tar_number = tariffheader.tar_number
	WHERE  	DateDiff(day,GetDate(),trk_enddate) <=  @MinThreshold
	AND trk_enddate >= GetDate()
	ORDER BY trk_billto ASC

--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults order by Cliente'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults order by Cliente'
END

EXEC (@SQL)

SET NOCOUNT OFF




 END
 ELSE IF @MODO = 'TARROUTE'
  BEGIN

  /*
    SELECT 	
	        trk_billto as [Cliente],
	        tariffheader.tar_number as [Tariff Number],
			
       		(select cty_nmstct from city  where cty_code = trk_origincity) as Origen,
			(select cty_nmstct from city  where cty_code = trk_destcity) as Destino,
			tar_description as [Description],
			trk_enddate as [Fecha Termino],
       		trk_startdate as [Fecha Inicio]
			
		
	INTO   	#TempResultsdos 
	FROM   	tariffkey (NOLOCK) JOIN tariffheader (NOLOCK) on tariffkey.tar_number = tariffheader.tar_number
	WHERE  	DateDiff(day,GetDate(),trk_enddate) <= @MinThreshold
	AND trk_enddate >= GetDate()
	ORDER BY trk_billto ASC
	*/


	
select 
(select  max(trk_billto) from 	tariffkey (nolock)  where 	tariffkey.tar_number = tariffrate.tar_number ) as Cliente,
tar_number,

isnull((select replace(cty_nmstct,',',' ') from city (nolock)  where cast(cty_code as varchar(20)) = (select trc_matchvalue from  tariffrowcolumn (nolock) where tariffrowcolumn.trc_number = tariffrate.trc_number_row )),
(select trc_matchvalue from  tariffrowcolumn (nolock) where tariffrowcolumn.trc_number = tariffrate.trc_number_row )) as Origen,

isnull((select replace(cty_nmstct,',',' ') from city (nolock)  where cast(cty_code as varchar(20)) = (select trc_matchvalue from  tariffrowcolumn (nolock) where tariffrowcolumn.trc_number = tariffrate.trc_number_col )), 
(select trc_matchvalue from  tariffrowcolumn (nolock) where tariffrowcolumn.trc_number = tariffrate.trc_number_col )) as Destino,

tra_rate,

(select  (min(trk_enddate)) from 	tariffkey (nolock)  where 	tariffkey.tar_number = tariffrate.tar_number  )  as FechaTermino,

(select  (min(trk_startdate)) from 	tariffkey (nolock)  where 	tariffkey.tar_number = tariffrate.tar_number  ) as FechaCreacion

		
INTO   	#TempResultsdos 
from [tariffrate]
where  
--(select  year(min(trk_enddate)) from 	tariffkey (nolock)  where 	tariffkey.tar_number = tariffrate.tar_number  ) = 2016

DateDiff(day,GetDate(),(select  (min(trk_enddate)) from 	tariffkey (nolock)  where 	tariffkey.tar_number = tariffrate.tar_number  )) <= @MinThreshold AND (select  (min(trk_enddate)) from 	tariffkey (nolock)  where 	tariffkey.tar_number = tariffrate.tar_number  ) >= GetDate()

and tra_rate > 0
order by Cliente desc




	

	


	--Commits the results to be used in the wrapper
IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResultsdos order by Cliente'
END
ELSE
BEGIN
	SET @COLSQL = ''
	EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
	SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResultsdos order by Cliente'
END

EXEC (@SQL)

SET NOCOUNT OFF



  END




GO
