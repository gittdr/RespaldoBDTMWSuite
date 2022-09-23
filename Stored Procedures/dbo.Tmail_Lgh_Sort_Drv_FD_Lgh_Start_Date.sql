SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*******************************************************************************************************************  
  Object Description:
  This trigger will cascade updates when a legheadaer update occurs.
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  06/30/2016   Tony Leonardi    Project: xxxxx   Legacy TM

********************************************************************************************************************/

CREATE PROC [dbo].[Tmail_Lgh_Sort_Drv_FD_Lgh_Start_Date] @drv varchar(20)

AS

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT lgh_number, ord_hdrnumber 
FROM legheader
WHERE (lgh_driver1 = @drv or lgh_driver2 = @drv)
	AND lgh_outstatus in ('PLN', 'DSP')
	AND lgh_startdate < DATEADD(hh, 12, GETDATE())
	AND lgh_startdate > DATEADD(hh, -24, GETDATE()) 
ORDER BY lgh_startdate;
GO
GRANT EXECUTE ON  [dbo].[Tmail_Lgh_Sort_Drv_FD_Lgh_Start_Date] TO [public]
GO
