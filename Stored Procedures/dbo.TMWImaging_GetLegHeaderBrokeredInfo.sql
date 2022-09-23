SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TMWImaging_GetLegHeaderBrokeredInfo]
@LEGNUMBERS as IntInParm READONLY
AS

/*******************************************************************************************************************  
  Object Description:
  This stored proc provides legheader brokered data for the legnumbers provided

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  08/18/2017   Jennifer Jackson WE-209655    Created
*******************************************************************************************************************/
--DECLARE 
--@LEGNUMBERS as IntInParm

--insert @LEGNUMBERS (IntItem) SELECT 4786
--insert @LEGNUMBERS (IntItem) SELECT 4785

BEGIN

DECLARE @QUERY NVARCHAR(MAX)
SET @QUERY = '
SELECT lb.*, c.car_name
FROM
LegHeader_Brokered lb
JOIN
carrier c ON ( ord_booked_carrier = c.car_id )
INNER JOIN @LEGNUMS L1 ON lb.lgh_number = L1.IntItem
WHERE 1=1 '

EXEC sp_executesql @QUERY, N'@LEGNUMS IntInParm READONLY', @LEGNUMBERS

END

GO
GRANT EXECUTE ON  [dbo].[TMWImaging_GetLegHeaderBrokeredInfo] TO [public]
GO
