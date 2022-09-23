SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vSSRSRB_DailyDispatch]
As

/**
 *
 * NAME:
 * dbo.[vSSRSRB_DailyDispatch]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View based on the old vttstmw_DailyDispatch
 
 *
**************************************************************************

Sample call


SELECT * FROM [vSSRSRB_DailyDispatch]

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

Select 
TempWorkList2.*,
mpp_lastfirst as [Driver Name],
IsNull([Segment End City],'No Assignment Found') as Destination,
mpp_id as [Driver ID],
convert(decimal(5,1),isNull(mpp_hours1,0.0)) HrsAvlToday,
convert(decimal(5,1),isNull(mpp_hours2,0.0)) HrsTomorrow,
convert(varchar(8),mpp_last_log_date,1) HrsLastUpdated,
(Cast(Floor(Cast(mpp_last_log_date as float))as smalldatetime)) [HrsLastUpdated Date Only],
mpp_type1 'DrvType1', 
mpp_type2 'DrvType2', 
mpp_type3 'DrvType3', 
mpp_type4 'DrvType4', 
mpp_fleet as 'Driver Fleet',
mpp_division as 'Driver Division',
mpp_domicile as 'Driver Domicile',
mpp_company as 'Driver Company',
mpp_terminal as 'Driver Terminal'
from 
	(
	Select 
	legheader.lgh_startcty_nmstct Origin,
	lgh_startcty_nmstct  'Segment Start City',
	lgh_endcty_nmstct    'Segment End City',
	lgh_startstate 	     'Segment Start State',
	lgh_endstate 	     'Segment End State',
	lgh_startdate 	     [Segment Start Date],
	(Cast(Floor(Cast(lgh_startdate as float))as smalldatetime)) AS [Segment Start Date Only],
	lgh_enddate 	     [Segment End Date],
	(Cast(Floor(Cast(lgh_Enddate as float))as smalldatetime)) AS [Segment End Date Only],
	legheader.lgh_driver1 TripDrvId,
	stops.stp_arrivaldate [Stop Arrival Date],
	(Cast(Floor(Cast(sTOPs.stp_arrivaldate as float))as smalldatetime)) AS [Stop Arrival Date Only],
	Stops.stp_status Status,
	stops.stp_event Event,
	StopCity.cty_nmstct StopCity,
	legheader.lgh_tractor Tractor,
	evt_trailer1 Trailer,
	legheader.mov_number as [Move Number],
	lgh_class1	'RevType1',
	lgh_class2	'RevType2',
	lgh_class3	'RevType3',
	lgh_class4	'RevType4',
	isNull(ord_remark,'') Remarks,
		(Case when legheader.lgh_driver2='UNKNOWN' Then ''
	 	else legheader.lgh_driver2
		end ) 
	Driver2,
	orderheader.ord_number as [ORDER Number],
	convert(varchar(2),stops.stp_mfh_sequence) Seq,
	(case 
	when stops.cmp_id is Null then ''
	when stops.cmp_id='UNKNOWN' then ''	
	else cmp_id
	end)	CompanyID, 
	(Case 
	when cmp_name is null then ''
	when cmp_name='UNKNOWN' then ''
	else cmp_name
	end)	CompanyName 
	from Legheader 
		  	Inner Join stops On Stops.lgh_number=legheader.lgh_number
		  	Inner Join event On stops.stp_number=event.stp_number
		  	Left Join city StopCity On StopCity.cty_code=stops.stp_city
		  	Left Join orderheader On legheader.ord_hdrnumber = orderheader.ord_hdrnumber
	where 
	legheader.lgh_driver1<> 'UNKNOWN'	
	and
	evt_sequence=1
	and
	exists (select a.lgh_number
			     from assetassignment a
			     where asgn_type = 'DRV' and (asgn_status='CMP' or asgn_status = 'STD') 
				   And 
				   asgn_enddate = (select max(b.asgn_enddate) 
						   from assetassignment b 
						   where
     				                 	(b.asgn_type = 'DRV' and a.asgn_id = b.asgn_id)
     				    			and 
							(b.asgn_status='CMP' or b.asgn_status = 'STD'))
		      		   And
				   a.lgh_number = legheader.lgh_number
			    )
--order by asgn_id 

	 ) as TempWorkList2
	Right Join manpowerprofile On mpp_id=TempWorkList2.TripDrvId
Where
mpp_terminationdt > GETDATE() 
and
mpp_id<>'UNKNOWN'

GO
GRANT DELETE ON  [dbo].[vSSRSRB_DailyDispatch] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_DailyDispatch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_DailyDispatch] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_DailyDispatch] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_DailyDispatch] TO [public]
GO
