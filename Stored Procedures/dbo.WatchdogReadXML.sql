SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogReadXML](@sn int)
AS
	SET NOCOUNT ON
	DECLARE @sql VARCHAR(4000), @LoopSn int, @fldList varchar(2000)
	CREATE TABLE #FieldNames  (sn int identity, localname varchar(100))

	SET @SQL = '
		DECLARE @idoc int
		DECLARE @doc xml
		SELECT @doc = WatchXMLData from tblWatchDogWorkFlowQueue WHERE sn = ' + CONVERT(varchar(10), @sn) + '

		EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

		SELECT DISTINCT localname FROM OPENXML (@idoc, ''/NewDataSet/Table'',2)
			WHERE (nodetype = 1 AND localname <> ''Table'' )
				OR  (nodetype = 1 AND localname = ''Table'' AND parentid <> 0)
		'

	INSERT INTO #FieldNames (localname)
	EXEC ( @SQL )

	SELECT @fldList = ''
	SELECT @LoopSn = MIN(sn) FROM #FieldNames
	WHILE ISNULL(@LoopSn, 0) > 0
	BEGIN
		SELECT @fldList = @fldList + '[' + localname + '] VARCHAR(100), ' FROM #FieldNames WHERE sn = @LoopSn
		SELECT @LoopSn = MIN(sn) FROM #FieldNames WHERE sn > @LoopSn
	END
	IF @fldList <> '' 
		SELECT @fldList = LEFT(@fldList, LEN(@fldList)-1)

	
	SET @SQL = '
		DECLARE @idoc int
		DECLARE @doc xml
		SELECT @doc = WatchXMLData from tblWatchDogWorkFlowQueue WHERE sn = ' + CONVERT(varchar(10), @sn) + '

		EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

		SELECT    *
		FROM  OPENXML (@idoc, ''/NewDataSet/Table'', 2)
            WITH (' + @fldList + ')
		'
	EXEC ( @SQL )
	
GO
GRANT EXECUTE ON  [dbo].[WatchdogReadXML] TO [public]
GO
