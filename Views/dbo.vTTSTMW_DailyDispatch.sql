SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






--select * from legheader where lgh_number = 7451
--select * from vTTSTMW_DailyDispatch order by DrvID



CREATE       View [dbo].[vTTSTMW_DailyDispatch]

As

Select Top 100 Percent
TempWorkList2.*,
mpp_lastfirst as [Driver Name],
IsNull([Segment End City],'No Assignment Found') as Destination,
mpp_id as DrvID,
convert(decimal(5,1),isNull(mpp_hours1,0.0)) HrsAvlToday,
convert(decimal(5,1),isNull(mpp_hours2,0.0)) HrsTomorrow,
convert(varchar(8),mpp_last_log_date,1) HrsLastUpdated,
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
	
	Select Top 100 Percent
	
	legheader.lgh_startcty_nmstct Origin,
	
	lgh_startcty_nmstct  'Segment Start City',
	lgh_endcty_nmstct    'Segment End City',
	lgh_startstate 	     'Segment Start State',
	lgh_endstate 	     'Segment End State',
	lgh_startdate 	     [Segment Start Date],
	lgh_enddate 	     [Segment End Date],


	legheader.lgh_driver1 TripDrvId,

	stops.stp_arrivaldate [Stop Arrival Date],

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

	orderheader.ord_number as [Order Number],
	convert(varchar(2),stops.stp_mfh_sequence) Seq,
	(case 
	when stops.cmp_id is Null then ''
	when stops.cmp_id='UNKNOWN' then ''	
	else cmp_id
	end)	CompanyID, 

	--stops.cmp_id,
	(Case 
	when cmp_name is null then ''
	when cmp_name='UNKNOWN' then ''
	else cmp_name
	end)	CompanyName 
    
	from 
		Legheader 
		  	--Inner Join #worklist On #worklist.lgh_number = legheader.lgh_number
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
order by 
Lgh_driver1,
legheader.mov_number,
stops.stp_mfh_sequence,
lgh_startdate






	 ) as TempWorkList2
	

	Right Join manpowerprofile On mpp_id=TempWorkList2.TripDrvId
Where
mpp_terminationdt > GETDATE() 
and
mpp_id<>'UNKNOWN'
Order By mpp_lastfirst























GO
GRANT SELECT ON  [dbo].[vTTSTMW_DailyDispatch] TO [public]
GO
