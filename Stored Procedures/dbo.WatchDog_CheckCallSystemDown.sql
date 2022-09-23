SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--WatchDogProcessing 'WatchDog_CheckCallSystemDown' ,2

CREATE PROC [dbo].[WatchDog_CheckCallSystemDown]           

            (
                        @MinThreshold FLOAT = 0, --Days Inactive
                        @MinsBack INT=-20, -- Overrides the TimeOut fields
                        @TempTableName VARCHAR(255) = '##WatchDogGlobalCheckCallSystemDown',
                        @WatchName VARCHAR(255)='WatchCheckCallSystemDown',
                        @ThresholdFieldName VARCHAR(255) = null,
                        @ColumnNamesOnly bit = 0,
                        @ExecuteDirectly bit = 0,
                        @ColumnMode VARCHAR(50) = 'Selected',
                        @asgn_type varchar(50) = 'TRC,DRV,TRL'
            )

                                                                        

AS

SET NOCOUNT ON

/***************************************************************

Procedure Name:    WatchDog_CheckCallSystemDown
Author/CreateDate: Lori Brickley / 3-22-2005
Purpose:                       Provides an alert for possible system down
                                which occured within the last x minutes               
Revision History:        
	10/11/06 Byoung - adding parm for Asset Type    
****************************************************************/

--Reserved/Mandatory WatchDog Variables

Declare @SQL VARCHAR(8000)
Declare @COLSQL VARCHAR(4000)

--Reserved/Mandatory WatchDog Variables

select   @asgn_type= ',' + @asgn_type +','
                                                                                

/****************************************************************************
            Create temp table #TempResults where the following conditions are met:
            Select the Tractor, Current Date/Time, Last Date/Time Stamp
            where the time between the last datetime stamp and current is greater than
            x minutes back
*****************************************************************************/

DECLARE @GETDATE datetime
SET @GETDATE = GETDATE()

SELECT 
	ckc_asgnid + ' (' + ltrim(rtrim(ckc_asgntype)) +')'[Asset ID], 
    GetDATE() [Current Date/Time], 
    max(ckc_date) as [Last Time Stamp]
INTO #TempResults
FROM checkcall (NOLOCK)
WHERE CHARINDEX(',' + ltrim(rtrim(ckc_asgntype)) + ',', @asgn_type) >0
GROUP BY ckc_asgnid + ' (' + ltrim(rtrim(ckc_asgntype)) +')'

DELETE FROM #TempResults WHERE DateDiff(mi,[Last Time Stamp],[Current Date/Time]) < @MinThreshold

--Commits the results to be used in the wrapper

IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
BEGIN
	SET @SQL = 'SELECT * FROM #TempResults'
END
ELSE
BEGIN
	SET @COLSQL = ''
    EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
    SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
END

EXEC (@SQL)

SET NOCOUNT OFF
 

GO
