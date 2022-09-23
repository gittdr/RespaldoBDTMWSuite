SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_AvgLoadUnloadWaitTimeByCompany]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_AvgLoadUnloadWaitTimeByCompany]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_AvgLoadUnloadWaitTimeByCompany
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_AvgLoadUnloadWaitTimeByCompany]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/

SELECT TempUnloadLoad.*      
FROM
(
SELECT  vSSRSRB_OrderStopDetail.*,
        DATEDIFF(n,CASE WHEN  [Original Scheduled Date] > [Arrival Date] AND ([Original Scheduled Date] < '2049-12-31') THEN [Original Scheduled Date] ELSE [Arrival Date] END,[Departure Date]) as TotalTimeAtCompanyMinutes,
        CONVERT(float,DATEDIFF(ss,CASE WHEN  [Original Scheduled Date] > [Arrival Date] AND ([Original Scheduled Date] < '2049-12-31') THEN [Original Scheduled Date] ELSE [Arrival Date] END,[Departure Date]))/3600 as TotalTimeAtCompanyHours,
        CASE WHEN  [Original Scheduled Date] > [Arrival Date] AND ([Original Scheduled Date] < '2049-12-31') THEN [Original Scheduled Date] ELSE [Arrival Date] END as [Used Arrival Date]
FROM 	vSSRSRB_OrderStopDetail
WHERE [Load Status] = 'LD'
AND [Stop Status] = 'DNE'
) As TempUnloadLoad
WHERE TotalTimeAtCompanyMinutes > 1
AND ([Used Arrival Date] > '1950-01-01' AND [Used Arrival Date] < '2049-12-31')
AND ([Departure Date] > '1950-01-01' AND [Departure Date] < '2049-12-31')

GO
GRANT SELECT ON  [dbo].[vSSRSRB_AvgLoadUnloadWaitTimeByCompany] TO [public]
GO
