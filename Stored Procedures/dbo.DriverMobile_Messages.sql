SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DriverMobile_Messages]
@DRIVER VARCHAR(25), @PAGESIZE INT, @PAGEINDEX INT
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides messages for driver.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  07/14/2017   Chip Ciminero    WE-209030    Created
  03/12/2018   Jennifer Jackson	WE-214409	 Altered ToName source
*******************************************************************************************************************/
--DECLARE @DRIVER VARCHAR(25), @PAGESIZE INT, @PAGEINDEX INT
--SELECT @DRIVER = 'BEDV', @PAGESIZE = 50, @PAGEINDEX = 1

DECLARE @TRACTOR VARCHAR(25), @DRIVERSN INT, @TRACTORSN INT
SET		@TRACTOR = (SELECT mpp_tractornumber FROM manpowerprofile WHERE mpp_id = @DRIVER)
SET		@TRACTORSN = (SELECT SN FROM tblTrucks WHERE DISPSYSTRUCKID = @TRACTOR)
SET		@DRIVERSN = (SELECT SN FROM tblDrivers WHERE DISPSYSDRIVERID = @DRIVER)

;WITH   DATA AS 
(
SELECT	DriverId = @DRIVER, TractorId = @TRACTOR, DateSent = M.DTSent, M.FromName, ToName = CASE WHEN M.ToDrvSN = D.SN THEN COALESCE(D.DispSysDriverID, D1.DispSysDriverID) ELSE T.ToName END
		, M.Subject, [FullMessage]=MS.MsgImage, M.Priority, M.Status, NotReceived = CASE WHEN M.DTReceived IS NULL THEN 1 ELSE 0 END
		, Type AS [MsgType]
		, ROW_NUMBER() OVER(ORDER BY M.DTSent DESC) AS RowNum 
FROM	tblMessages M INNER JOIN
		tblMsgShareData MS ON  M.OrigMsgSN = MS.OrigMsgSN INNER JOIN
		(SELECT MsgSN FROM tblHistory WHERE (TruckSN = @TRACTORSN AND DriverSN = @DRIVERSN) OR DriverSN = @DRIVERSN) H ON M.SN = H.MsgSN INNER JOIN
		tblTo T ON M.SN = T.Message LEFT OUTER JOIN
		tblDrivers D ON M.ToDrvSN = D.SN LEFT OUTER JOIN
		tblDrivers D1 ON M.FromDrvSN = D1.SN
)

SELECT	* 
FROM	( 
		SELECT *, TotalNotReceived=SUM(NotReceived) OVER() FROM Data 
		) A  
WHERE	RowNum > + @PAGESIZE * (@PAGEINDEX - 1)
		AND RowNum <= @PAGESIZE * @PAGEINDEX
ORDER BY RowNum
GO
GRANT EXECUTE ON  [dbo].[DriverMobile_Messages] TO [public]
GO
