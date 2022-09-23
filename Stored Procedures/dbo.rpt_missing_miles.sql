SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[rpt_missing_miles]
	(@startdt datetime,
	@Enddt datetime)


AS


select 	mov_number,
	stp_number,
	stp_mfh_sequence,
	cmp_id,
	stp_city,
	stp_ord_mileage,
	stp_lgh_mileage	
into #t1
	from stops 
	where 

	stp_arrivaldate >@startdt 
and
	stp_arrivaldate <@Enddt
and 
	(stp_ord_mileage <0 
	or
	stp_lgh_mileage <0 )

select #t1.mov_number,
	--stops.stp_number S1tp_number,
	--stops.stp_mfh_sequence S1SEQ,
	stops.cmp_id S1Cmp_id,
	--stops.stp_city stop1stp_city,
	cty1.cty_name S1CityName,
	cty1.cty_state S1St,
	--#t1.stp_number,
	--#t1.stp_mfh_sequence,
	#t1.cmp_id S2CmpId,
	cty2.cty_name S2CityName,
	cty2.cty_state S2St,
	#t1.stp_ord_mileage,
	#t1.stp_lgh_mileage	

	--#t1.stp_city
	from 
		#t1,
		stops,
		city as cty1,
		city as cty2
where stops.mov_number= #t1.mov_number
	and
	stops.stp_mfh_sequence=
	(#t1.stp_mfh_sequence-1)
	and
	cty1.cty_code =#t1.stp_city
	and 
	cty2.cty_code =Stops.stp_city


	


drop table #t1

GO
GRANT EXECUTE ON  [dbo].[rpt_missing_miles] TO [public]
GO
