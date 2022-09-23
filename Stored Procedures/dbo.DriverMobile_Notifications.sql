SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DriverMobile_Notifications]
@DRIVER VARCHAR(25), @PAGESIZE INT, @PAGEINDEX INT
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides Notifications for driver.

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  07/14/2017   Chip Ciminero    WE-209030    Created
*******************************************************************************************************************/
--DECLARE @DRIVER VARCHAR(25), @PAGESIZE INT, @PAGEINDEX INT
--SELECT @DRIVER = 'BEDV', @PAGESIZE = 10, @PAGEINDEX = 1

;WITH   DATA AS 
(
SELECT	Name=L.name, Description=exp_description, ExpirationDate=exp_expirationdate
		,LastUpdatedBy=exp_updateby, Expired = CASE WHEN exp_expirationdate <= GETDATE() THEN 1 ELSE 0 END
		, ROW_NUMBER() OVER(ORDER BY E.exp_expirationdate) AS RowNum 
FROM	expiration E INNER JOIN
		labelfile L ON E.exp_code = abbr and labeldefinition = 'DrvExp'
WHERE	exp_id = @DRIVER AND exp_idtype = 'DRV' AND exp_completed = 'N'
)

SELECT	* 
FROM	( 
		SELECT *, TotalExpired=SUM(Expired) OVER() FROM Data 
		) A  
WHERE	RowNum > + @PAGESIZE * (@PAGEINDEX - 1)
		AND RowNum <= @PAGESIZE * @PAGEINDEX
ORDER BY RowNum
GO
GRANT EXECUTE ON  [dbo].[DriverMobile_Notifications] TO [public]
GO
