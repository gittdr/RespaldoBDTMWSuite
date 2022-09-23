SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vTTSTMW_AssetAssignmentDriver]

AS

Select

	actg_type as [Acct Type],
	asgn_date as [Assign Date],

	--**Assign Date**
	--Day
        (Cast(Floor(Cast(asgn_date as float))as smalldatetime)) as [Assign Date Only], 
        Cast(DatePart(yyyy,asgn_date) as varchar(4)) +  '-' + Cast(DatePart(mm,asgn_date) as varchar(2)) + '-' + Cast(DatePart(dd,asgn_date) as varchar(2)) as [Assign Day],
        --Month
        Cast(DatePart(mm,asgn_date) as varchar(2)) + '/' + Cast(DatePart(yyyy,asgn_date) as varchar(4)) as [Assign Month],
        DatePart(mm,asgn_date) as [Assign Month Only],
        --Year
        DatePart(yyyy,asgn_date) as [Assign Year],
	--Ship Day Of Week
	CASE DatePart(dw,asgn_date)         WHEN 1 THEN 'Sunday'
                 			    WHEN 2 THEN 'Monday'
                 			    WHEN 3 THEN 'Tuesday'
                 			    WHEN 4 THEN 'Wednesday'
                 			    WHEN 5 THEN 'Thursday'
                 			    WHEN 6 THEN 'Friday'
                 			    WHEN 7 THEN 'Saturday'
                 			    ELSE SPACE(0)
	END as [Assign DayOfWeek],

asgn_dispdate as [Assign Dispdate],
asgn_dispmethod as [Assign Dispmethod],
asgn_enddate as [Assign End Date],
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

/* Pull all records from vTTSTMW_RevVsPay */
r.*


From assetassignment a (NOLOCK) left join vTTSTMW_RevVsPay r on a.lgh_number = r.[Leg Header Number] where asgn_type = 'DRV'


























































GO
GRANT SELECT ON  [dbo].[vTTSTMW_AssetAssignmentDriver] TO [public]
GO
