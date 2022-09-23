SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Perf_BuildCMPData] @BaseMsgSN INT, @outsideLatnc TINYINT

/*******************************************************************************************************************  
  Object Description:
    Builds Latancy/performance data
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/05/27   W. Riley Wolfe    PTS101024    Init
  2016/09/26   W. Riley Wolfe    PTS101024    DBA recommended changes and Table name change
********************************************************************************************************************/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE 
  @SQLMain NVARCHAR(3500),
	@SQLWhere NVARCHAR(100),
	@SQLBaseSN NVARCHAR(100) = N' BaseMsgSN = @BaseMsgSN ',
	@SQLstdSource NVARCHAR(200) = N' FROM tblRawMsgPerformance raww JOIN tblEventsMsgPerformance evt ON raww.PerfEventNum = evt.PerfEventNum ';

DECLARE 
  @Start DATETIME,
	@Final DATETIME,
	@ToVend FLOAT,
	@Total FLOAT,
	@count INT,
	@hitVend DATETIME,
	@tFl AS FLOAT,
	@tF2 AS FLOAT;


if @outsideLatnc > 0 
  SET @SQLWhere = N' Where ';
ELSE
  SET @SQLWhere = N' Where evt.SequenceNum BETWEEN 0 AND 150 AND ';

SELECT @count = Count(TrueMsgSN)
FROM (
	SELECT DISTINCT TrueMsgSN
	FROM tblRawMsgPerformance
	WHERE BaseMsgSN = @BaseMsgSN
	) part;

SET @SQLMain =
 'SELECT @Start = Min(raww.EventTime) ' +
  @SQLstdSource + 
  @SQLWhere +
  @SQLBaseSN;

EXEC sp_ExecuteSQL @SQLMain,
	N'@BaseMsgSN INT, @Start DATETIME OUTPUT',
	@BaseMsgSN, @Start OUTPUT;

SET @SQLMain =
 'SELECT @Final = Max(EventTime) ' +
  @SQLstdSource + 
  @SQLWhere +
  @SQLBaseSN;

EXEC sp_ExecuteSQL @SQLMain,
	N'@BaseMsgSN INT, @Final DATETIME OUTPUT',
	@BaseMsgSN, @Final OUTPUT;

SET @SQLMain =
 'Select Top 1 @hitVend = raww.EventTime ' +
  @SQLstdSource + 
  @SQLWhere +
  @SQLBaseSN + 
  N' AND evt.EventCode = ''SENTVENDOR'' ' +
  N' ORDER BY raww.EventTime DESC ';

EXEC sp_ExecuteSQL @SQLMain,
	N'@BaseMsgSN INT, @hitVend DATETIME OUTPUT',
	@BaseMsgSN, @hitVend OUTPUT;

--Math

--Total
Set @tfl = Cast(@Start as float);
Set @tf2 = Cast(@Final as float);
Set @Total = @tF2 - @tFl;
 

--Hit vendor
Set @tfl = Cast(@Start as float);
Set @tf2 = Cast(@hitVend as float);
Set @ToVend = @tF2 - @tFl;

IF NOT EXISTS (
		SELECT TOP 1 1
		FROM tblAggMsgGrpPerformance
		WHERE BaseMsgSN = @BaseMsgSN
		)
  BEGIN
    INSERT INTO tblAggMsgGrpPerformance (
	    BaseMsgSN,
      Start,
	    Final,
	    MsgCount,
	    ToVendorRAW,
	    TotalRAW
	    )
    SELECT @BaseMsgSN,
      @Start,
	    @Final,
	    @count,
	    @ToVend,
	    @Total;

  END
  ELSE
  BEGIN
    UPDATE tblAggMsgGrpPerformance
    SET Start = @Start,
	    Final = @Final,
	    MsgCount = @count,
	    ToVendorRAW = @ToVend,
	    TotalRAW = @Total
    WHERE BaseMsgSN = @BaseMsgSN;
  END

GO
GRANT EXECUTE ON  [dbo].[tm_Perf_BuildCMPData] TO [public]
GO
