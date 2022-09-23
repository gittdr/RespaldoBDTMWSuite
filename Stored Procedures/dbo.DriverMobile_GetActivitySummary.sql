SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DriverMobile_GetActivitySummary]
@ASGN_ID VARCHAR(MAX), 
@ASGN_TYPE VARCHAR(MAX),
@PAGESIZE INT,
@PAGEINDEX INT,
@SORTDIRECTION VARCHAR(3),
@STATUSLIST AS Varchar50InParm READONLY
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides trip assignment details for a resource.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  12/06/2017   Chase Plante     WE-212496    Created
  12/12/2017   Chase Plante     WE-212496    Added dynamic sorting
*******************************************************************************************************************/

--DECLARE @ASGN_ID VARCHAR(MAX),
--        @ASGN_TYPE VARCHAR(MAX),
--        @PAGESIZE INT,
--        @PAGEINDEX INT,
--	      @SORTDIRECTION VARCHAR(3),
--		  @STATUSLIST as Varchar50InParm
--
--SELECT @ASGN_ID = '1422', 
--	     @ASGN_TYPE = 'DRV', 
--	     @PAGESIZE = 10, 
--	     @PAGEINDEX = 1,
--	     @SORTDIRECTION = 'DSC'
--INSERT @STATUSLIST (VarcharItem) SELECT 'PLN'
--INSERT @STATUSLIST (VarcharItem) SELECT 'DSP'

SELECT * 
FROM
(
	SELECT 
		lasta.asgn_number [AssignmentNumber], 
		lasta.mov_number [MoveNumber],
		lasta.lgh_number [LegNumber],
		starte.stp_number [StartStop],
		ende.stp_number [EndStop],
		lasta.evt_number [StartEvent],
		lasta.last_evt_number [EndEvent],
		starte.evt_startdate [StartDate],
		ende.evt_enddate [EndDate],
		lasta.asgn_controlling [Controlling],
		lasta.asgn_status [Status],
		lasta.asgn_type [AssignmentType],
		lasta.asgn_id [AssignmentId],
		ROW_NUMBER() OVER (ORDER BY starte.evt_startdate DESC) AS RowNum
	FROM assetassignment as lasta 
	JOIN event AS starte ON starte.evt_number = lasta.evt_number
	JOIN event AS ende ON ende.evt_number = lasta.last_evt_number
	JOIN @STATUSLIST as statuses ON lasta.asgn_status = statuses.VarcharItem
	WHERE 
		lasta.asgn_id = @ASGN_ID AND
		lasta.asgn_type = @ASGN_TYPE
) InnerQuery
WHERE 
	RowNum >= (@PAGESIZE * @PAGEINDEX) + 1 AND 
	RowNum < (@PAGESIZE * (@PAGEINDEX + 1) + 1)
ORDER BY
	CASE WHEN @SORTDIRECTION = 'ASC' THEN 1 ELSE RowNum	END DESC,
	CASE WHEN @SORTDIRECTION = 'DESC' THEN 1 ELSE RowNum END ASC
GO
GRANT EXECUTE ON  [dbo].[DriverMobile_GetActivitySummary] TO [public]
GO
