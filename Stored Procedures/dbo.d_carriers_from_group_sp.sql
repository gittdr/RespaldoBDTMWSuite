SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[d_carriers_from_group_sp] ( @carrier_group varchar(6), 
											@car_overall_rating varchar(12), 
											@R1_and_higher char(1)) 							

AS 
Set NoCount On 

-- PTS 53396 Created for Lane Auction Process

IF @carrier_group IS NULL
BEGIN
	SET @carrier_group = 'UNK'
END

IF @car_overall_rating IS NULL
BEGIN
	SET @car_overall_rating = 'UNK'
END 

IF @R1_and_higher IS NULL
BEGIN
	SET @R1_and_higher = 'N'
END

Create table #temp_resultset	(	car_id varchar(8) null,  
										car_name varchar(64) null,
										car_overall_rating varchar(12) null,
										car_group varchar(6) null ) 

IF @carrier_group <> 'UNK' 
BEGIN 
insert into #temp_resultset( car_id, car_name, car_overall_rating, car_group) 
		select carrier.car_id, carrier.car_name, carrier.car_rating, CarrierGroups.cgp_type
		from carrier, CarrierGroups 
		where carrier.car_id = 	CarrierGroups.cgp_carrier_id
		AND carrier.car_status = 'ACT'
		AND CarrierGroups.cgp_type = @carrier_group 
END 

IF @carrier_group = 'UNK' 
Begin 
insert into #temp_resultset( car_id, car_name, car_overall_rating, car_group) 
		select carrier.car_id, carrier.car_name, carrier.car_rating,  NULL
		from carrier
		where carrier.car_status = 'ACT'		
end

IF @car_overall_rating <> 'UNK'
BEGIN
		select code, abbr
		INTO	#temp_rating
		from labelfile 
		where labeldefinition = 'CarrierServiceRating' 		
END		


IF @car_overall_rating <> 'UNK' 
BEGIN
	IF @R1_and_higher = 'N'
		BEGIN 
			delete from #temp_resultset where car_overall_rating <> @car_overall_rating
		END
		
	IF @R1_and_higher = 'Y'
		Declare @r1_code int
		set @r1_code = ( select #temp_rating.code from #temp_rating where #temp_rating.abbr = @car_overall_rating ) 
		BEGIN 
			delete from #temp_resultset 
			where car_overall_rating NOT IN ( select abbr from #temp_rating where #temp_rating.code >= @r1_code ) 
		END		
		
END
	
delete from #temp_resultset where ( car_id in ( 'UNKNOWN', 'UNK' )  OR car_name in ( 'UNKNOWN', 'UNK' ) ) 
	
	
select * from #temp_resultset

GO
GRANT EXECUTE ON  [dbo].[d_carriers_from_group_sp] TO [public]
GO
