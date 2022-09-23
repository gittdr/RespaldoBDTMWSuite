SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vSSRSRB_AssetAssignmentTractor]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_AssetAssignmentTractor]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_AssetAssignmentTractor
 *
**************************************************************************

Sample call

SELECT * FROM [vSSRSRB_AssetAssignmentTractor]

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

SELECT
actg_type as [Acct Type],
asgn_date as [Assign Date],
(Cast(Floor(Cast(asgn_date as float))as smalldatetime)) as [Assign Date Only], 
Cast(DatePart(yyyy,asgn_date) as varchar(4)) +  '-' + Cast(DatePart(mm,asgn_date) as varchar(2)) + '-' + Cast(DatePart(dd,asgn_date) as varchar(2)) as [Assign Day],
Cast(DatePart(mm,asgn_date) as varchar(2)) + '/' + Cast(DatePart(yyyy,asgn_date) as varchar(4)) as [Assign Month],
DatePart(mm,asgn_date) as [Assign Month Only],
DatePart(yyyy,asgn_date) as [Assign Year],
CASE DatePart(dw,asgn_date)     
	WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
    ELSE SPACE(0) END as [Assign DayOfWeek],
asgn_dispdate as [Assign Dispdate],
(Cast(Floor(Cast(asgn_dispdate as float))as smalldatetime)) AS 'Assign Dispdate Date Only',
asgn_dispmethod as [Assign Dispmethod],
asgn_enddate as [Assign End Date],
(Cast(Floor(Cast(asgn_enddate as float))as smalldatetime)) aS 'Assign End Date Only',
asgn_eventnumber as [Assign Eventnumber],
asgn_id as [Assign ID],
asgn_number as [Assign Number],
asgn_status as [Assign Status],
asgn_type as [Assign Type],
evt_number as [Event Number],
last_dne_evt_number as [Last Done Event Number],
last_evt_number as [Last Event Number],
next_opn_evt_number as [next opn evt number],
pyd_status as [Paid Status],
r.*
FROM assetassignment a with(NOLOCK) 
LEFT JOIN vSSRSRB_RevVsPay r   with(NOLOCK) 
	ON a.lgh_number = r.[Leg Number] 
WHERE asgn_type = 'TRC'

GO
GRANT SELECT ON  [dbo].[vSSRSRB_AssetAssignmentTractor] TO [public]
GO
