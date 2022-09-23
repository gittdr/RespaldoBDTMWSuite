SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetAirMilesForLegByDate](@lgh_number int, @ckcdate datetime)

AS

BEGIN
	DECLARE @date datetime,
			@curLat int,
			@curLong int,
			@prevLat int,
			@prevLong int,
			@miles float,
			@state varchar(2)

	set @miles = 0
	set @state = 'XX'
	IF(select count(distinct stp_city) from stops where lgh_number = @lgh_number) = 1
	BEGIN
		-- Load check calls into temp table for processing.
		select * into #tempCC from checkcall where ckc_lghnumber = @lgh_number and ckc_date >= @ckcdate and ckc_date < DATEADD(second, -1, DATEADD(day, 1 ,@ckcdate)) order by ckc_date   
		
		-- get last check call from previous day
		insert into #tempCC select top 1 * from checkcall where ckc_tractor = (SELECT isnull(lgh_tractor,'UNKNOWN') from legheader where lgh_number = @lgh_number) and ckc_date >= DATEADD(day,-1,@ckcdate) and ckc_date < @ckcdate order by ckc_date desc

		select @state = isnull(cty_state,'XX') from city where cty_code = (select top 1 stp_city from stops where lgh_number = @lgh_number)

		set @prevLat = 0
		set @prevLong = 0

		SELECT @date = MIN(ckc_date) FROM #tempcc 
		WHILE ISNULL(@date, -1) <> -1  
			BEGIN  
				select @curLat = ckc_latseconds, @curLong = ckc_longseconds from #tempcc where ckc_date = @date
				
				if @prevLat <> 0 and @prevLong <> 0
					set @miles = @miles + dbo.fnc_AirMilesBetweenLatLongSeconds(@prevLat, @curLat, @prevLong, @curLong)
				
				set @prevLat = @curLat
				set @prevLong = @curLong
				SELECT @date = MIN(ckc_date) FROM #tempcc where ckc_date > @date
			END 
		
		  IF isnull(@state,'XX') = 'XX'
			INSERT INTO FuelTaxMileage_ErrorLog (lgh_number, fte_entrytype, fte_errorcode, fte_errorline, fte_createdate, fte_createdby)      
				VALUES (@lgh_number, 'C', 'XX', '0', getdate(), 'WorkCycle')  
		  ELSE     
			INSERT INTO FuelTaxMileageDetail (lgh_number, ftm_state, ftm_freemiles, ftm_tollmiles, ftm_totalmiles, ftm_date, ftm_entrytype, ftm_createdate, ftm_createdby, ftm_updatedate, ftm_updatedby)      
				VALUES (@lgh_number, @state, @miles, 0, @miles, @ckcdate, 'C', getdate(), 'WorkCycle', getdate(), 'WorkCycle')  	END
ELSE
	BEGIN
		INSERT INTO FuelTaxMileage_ErrorLog (lgh_number, fte_entrytype, fte_errorcode, fte_errorline, fte_createdate, fte_createdby)    
				 VALUES (@lgh_number, 'C', 'XX', '0', getdate(), 'WorkCycle')
	END	
END

GO
GRANT EXECUTE ON  [dbo].[GetAirMilesForLegByDate] TO [public]
GO
