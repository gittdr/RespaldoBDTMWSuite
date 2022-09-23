SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--DriverAwareSuite_GetStopDetailFromLegHeader 423536

CREATE           Proc [dbo].[DriverAwareSuite_GetStopDetailFromLegHeader]
	(@LegHeaderNumber int
		
	)
AS

Set NoCount On

--Basically the system offers two views as out of the box
--detail views plus a custom view which is due out in the future
--end of 2005 or beginning of 2006 (allows users to customize
--their header and detail level info for the segement)
Declare @StopDetailViewType varchar(255)

Set @StopDetailViewType = (select dsat_value from DriverAwareSuite_GeneralInfo where dsat_key = 'StopDetailView')


If @StopDetailViewType = 'DispatchPlus'
Begin

		

	Select -- Top 100 Percent
		1 as DetailOrder,
		DetailText = stops.cmp_name + ' ' + 'ARRIVED: ' + stp_status + ' ' + 'DEPARTED: ' + stp_departure_status + Char(13)  +
		(select IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') from city (NOLOCK) where stp_city = cty_code) + Char(13) + 
		RTrim(stp_event) + ' ' + 'Trailer: ' + IsNull(evt_trailer1,'') + Char(13) +  
		'    Appt Date:  ' + case when stp_schdtearliest <> stp_schdtlatest Then 
											cast(datepart(mm,stp_schdtearliest) as varchar(2)) + '/' +  cast(datepart(dd,stp_schdtearliest) as varchar(2)) + '/' + cast(datepart(yyyy,stp_schdtearliest) as varchar(4)) + ' ' + cast(datepart(hh,stp_schdtearliest) as varchar(2)) + ':' + case when len(datepart(mi,stp_schdtearliest)) < 2 Then '0' + cast(datepart(mi,stp_schdtearliest) as varchar(2)) Else cast(datepart(mi,stp_schdtearliest) as varchar(2)) End 
											+ ' - ' +
				   							cast(datepart(mm,stp_schdtlatest) as varchar(2)) + '/' +  cast(datepart(dd,stp_schdtlatest) as varchar(2)) + '/' + cast(datepart(yyyy,stp_schdtlatest) as varchar(4)) + ' ' + cast(datepart(hh,stp_schdtlatest) as varchar(2)) + ':' + case when len(datepart(mi,stp_schdtlatest)) < 2 Then '0' + cast(datepart(mi,stp_schdtlatest) as varchar(2)) Else cast(datepart(mi,stp_schdtlatest) as varchar(2)) End 
				     Else
											cast(datepart(mm,stp_schdtearliest) as varchar(2)) + '/' +  cast(datepart(dd,stp_schdtearliest) as varchar(2)) + '/' + cast(datepart(yyyy,stp_schdtearliest) as varchar(4)) + ' ' + cast(datepart(hh,stp_schdtearliest) as varchar(2)) + ':' + case when len(datepart(mi,stp_schdtearliest)) < 2 Then '0' + cast(datepart(mi,stp_schdtearliest) as varchar(2)) Else cast(datepart(mi,stp_schdtearliest) as varchar(2)) End 
				     End
		+ Char(13) + 
		'    Arrival Date:' + ' ' + cast(datepart(mm,stp_arrivaldate) as varchar(2)) + '/' +  cast(datepart(dd,stp_arrivaldate) as varchar(2)) + '/' + cast(datepart(yyyy,stp_arrivaldate) as varchar(4)) + ' ' + cast(datepart(hh,stp_arrivaldate) as varchar(2)) + ':' + case when len(datepart(mi,stp_arrivaldate)) < 2 Then '0' + cast(datepart(mi,stp_arrivaldate) as varchar(2)) Else cast(datepart(mi,stp_arrivaldate) as varchar(2)) End + Char(13) + Char(13)
		
	into   #Temp
	From   stops (NOLOCK) Left Join event (NOLOCK) On stops.stp_number = event.stp_number and event.evt_sequence = 1
	Where  lgh_number = @LegHeaderNumber
	Order By stp_mfh_sequence ASC

	Select Top 1  DetailText =      'Order# ' + orderheader.ord_number + 'Leg# ' + cast(@LegHeaderNumber as varchar(255)) + Char(13) +
			    	        'Loaded Miles: ' + cast((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = @LegHeaderNumber and stp_loadstatus = 'LD') as varchar(255)) + ' ' + 'Total Miles ' + cast((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = @LegHeaderNumber) as varchar(255)) + Char(13) + Char(13)
	       

	From   orderheader (NOLOCK),
	       stops (NOLOCK)
	     
 	Where  orderheader.ord_hdrnumber = stops.ord_hdrnumber
	       And
	       stops.lgh_number = @LegHeaderNumber
	Union ALL
	Select DetailText from #Temp



End
Else --some day custom but if the dispatch plus setting
     --isn't specified then show the default stop detail view
Begin

	
	Select  
		Case When stp_mfh_sequence <> (select min(b.stp_mfh_sequence) from stops b (NOLOCK) where b.lgh_number = stops.lgh_number) Then cast(IsNull(stp_lgh_mileage,0) as varchar(50)) + ' Miles' Else '' End + Char(13) +  
		RTrim(stp_event) + ' - ' + (select cmp_name from company where stops.cmp_id = company.cmp_id) + CHAR(13) +
		'Trailer: ' + IsNull(evt_trailer1,'') + Char(13) + 
		(select IsNull(cty_name,'') + ', ' + IsNull(cty_state,'') from city (NOLOCK) where stp_city = cty_code) + Char(13) + 
	     cast(datepart(mm,stp_arrivaldate) as varchar(2)) + '/' +  cast(datepart(dd,stp_arrivaldate) as varchar(2)) + '/' + cast(datepart(yyyy,stp_arrivaldate) as varchar(4)) + ' ' + cast(datepart(hh,stp_arrivaldate) as varchar(2)) + ':' + case when len(datepart(mi,stp_arrivaldate)) < 2 Then '0' + cast(datepart(mi,stp_arrivaldate) as varchar(2)) Else cast(datepart(mi,stp_arrivaldate) as varchar(2)) End + Char(13) + Char(13)
		
		--(select cty_nmstct from city (NOLOCK) where cty_code = stp_city) + (select
		--'
	From   stops (NOLOCK) Left Join event (NOLOCK) On stops.stp_number = event.stp_number and event.evt_sequence = 1
	Where  lgh_number = @LegHeaderNumber
	Order By stp_mfh_sequence ASC

End













GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetStopDetailFromLegHeader] TO [public]
GO
