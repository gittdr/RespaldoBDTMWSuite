SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Adam Skinner
-- Create date: 2014-11-06
-- Description:	Get rates from origin to destination
-- Returns:		A distinct list of core_LaneRateMatrix.Id
-- =============================================
CREATE FUNCTION [dbo].[fn_LaneRateMatrixOriginToDestinationRateIds](	@originType varchar(50), 
																@originValue varchar(50), 
																@destinationType varchar(50), 
																@destinationValue varchar(50))
RETURNS @t table(Id int) AS
BEGIN
	declare @now datetime
	select @now = GETDATE()
	
	declare @locationGranularities table(LocationType varchar(20) primary key, GranularityLevel int)
	
	-- Seed our granularity levels.  Higher values are more granular than lower levels.
	-- City and postal code must have the same granularity value
insert into @locationGranularities 
       values ('Company', 10)
insert into @locationGranularities 
       values ('PostalCode%', 6)
insert into @locationGranularities 
       values ('CityState', 6)
insert into @locationGranularities 
       values ('State', 4)
			
	declare @originCompanyId varchar(50), @originPostalCode varchar(50), @originCity varchar(50), @originState varchar(2)
	declare @destinationCompanyId varchar(50), @destinationPostalCode varchar(50), @destinationCity varchar(50), @destinationState varchar(2)
	declare @originGranularityLevel int, @destinationGranularityLevel int
	declare @originCities table(CityName varchar(50))
	declare @destinationCities table(CityName varchar(50))
	
	-- Find our granularity levels to determine which rows in the LaneRateMatrix to check
	select @originGranularityLevel = lg.GranularityLevel
	from @locationGranularities lg
	where @originType like lg.LocationType

	select @destinationGranularityLevel = lg.GranularityLevel
	from @locationGranularities lg
	where @destinationType like lg.LocationType
		
	-- Initialize origin values from origin type/value combinations
	if @originType = 'Company'
		select	@originCompanyId = c.cmp_id, 
				@originPostalCode = c.cmp_zip, 
				@originCity = c.cty_nmstct, 
				@originState = c.cmp_state
		from dbo.company c
		where c.cmp_id = @originValue
		
	else if @originType = 'PostalCode'
	begin
		select	@originPostalCode = @originValue
		select	@originState = c.cty_state
		from dbo.city c 
		where c.cty_zip = @originValue
			or exists (select 1 from dbo.cityzip cz where @originValue = cz.zip and cz.cty_code = c.cty_code)
		
		insert into @originCities
		select c.cty_nmstct
		from dbo.city c 
		where c.cty_zip = @originValue
			or exists (select 1 from dbo.cityzip cz where @originValue = cz.zip and cz.cty_code = c.cty_code)

		if ((select count(1) from @originCities) = 0)
			select top 1 @originCity = c.cty_nmstct, @originState = c.cmp_state
			from dbo.company c
			where c.cmp_zip = @originValue
	end
	
	else if @originType = 'CityState'
		select	@originPostalCode = c.cty_zip, 
				@originCity = c.cty_nmstct, 
				@originState = c.cty_state
		from dbo.city c
		where c.cty_nmstct = @originValue
		
	else if @originType = 'State'
		select	@originState = @originValue
	
	if @originCity is not null
		insert into @originCities values(@originCity)
	
	-- Initialize destination values from destination type/value combinations	
	if @destinationType = 'Company'
		select	@destinationCompanyId = c.cmp_id, 
				@destinationPostalCode = c.cmp_zip, 
				@destinationCity = c.cty_nmstct, 
				@destinationState = c.cmp_state
		from dbo.company c
		where c.cmp_id = @destinationValue
		
	else if @destinationType = 'PostalCode'
	begin
		select	@destinationPostalCode = @destinationValue
		select	@destinationState = c.cty_state
		from dbo.city c 
		where c.cty_zip = @destinationValue
			or exists (select 1 from dbo.cityzip cz where @destinationValue = cz.zip and cz.cty_code = c.cty_code)
		
		insert into @destinationCities
		select c.cty_nmstct
		from dbo.city c 
		where c.cty_zip = @destinationValue
			or exists (select 1 from dbo.cityzip cz where @destinationValue = cz.zip and cz.cty_code = c.cty_code)

		-- If the destination state is missing (we didn't get it from the city)
		-- look to the company table to find a company that has the zip code we were given
		-- and set the city and state values from it
		if ((select count(1) from @destinationCities) = 0)
			select top 1 @destinationCity = c.cty_nmstct, @destinationState = c.cmp_state
			from dbo.company c
			where c.cmp_zip = @destinationValue
	end
		
	else if @destinationType = 'CityState'
		select	@destinationPostalCode = c.cty_zip, 
				@destinationCity = c.cty_nmstct, 
				@destinationState = c.cty_state
		from dbo.city c
		where c.cty_nmstct = @destinationValue
		
	else if @destinationType = 'State'
		select	@destinationState = @destinationValue
		
	if @destinationCity is not null
		insert into @destinationCities values(@destinationCity)
		
	-- Return the rows in the core_LaneRateMatrix table, starting with the specified location granularities 
	-- and moving down through less granular specifications.
	-- 
	-- Left outer joins on postal code pattern allow us to tie the a the @{origin|destination}PostalCode to
	-- a matching pattern defined in the lane rate matrix
	-- 
	-- Left outer joins on the @{origin|destination}Cities allow us to match city names against
	-- the city names in the lane rate matrix
	-- 
	-- Inner joining the location granularity levels and showing those that are less granular than what was provided
	-- allows us to see not only the specification at it's most granular, but also less granular matches across the board.
	
	insert into @t
	select distinct lrm.Id
	from dbo.core_LaneRateMatrix lrm
		inner join dbo.core_carrierlanecommitment cc on cc.laneid = lrm.LaneId 
			and cc.effectivedate <= @now and cc.expiresdate >= @now + 1
		inner join @locationGranularities olg on lrm.OriginType like olg.LocationType
		inner join @locationGranularities dlg on lrm.DestinationType like dlg.LocationType
		left outer join dbo.core_PostalCodePatternExpansion op on lrm.OriginType = 'PostalCodePattern'
			and op.PostalCodePattern = lrm.OriginValue
			and @originPostalCode like op.PostalCodePart + '%'
		left outer join dbo.core_PostalCodePatternExpansion dp on lrm.DestinationType = 'PostalCodePattern'
			and dp.PostalCodePattern = lrm.DestinationValue
			and @destinationPostalCode like dp.PostalCodePart + '%'
		left outer join @originCities oc on oc.CityName = lrm.OriginValue and lrm.OriginType = 'CityState'
		left outer join @destinationCities dc on dc.CityName = lrm.DestinationValue and lrm.DestinationType = 'CityState'
	where lrm.Rate <> 0
		and lrm.OriginValue =	case lrm.OriginType
									when 'Company' then @originCompanyId
									when 'CityState' then oc.CityName
									when 'State' then @originState
									when 'PostalCodePattern' then op.PostalCodePattern
								end
		and lrm.DestinationValue =	case lrm.DestinationType
										when 'Company' then @destinationCompanyId
										when 'CityState' then dc.CityName
										when 'State' then @destinationState
										when 'PostalCodePattern' then dp.PostalCodePattern
									end
		and olg.GranularityLevel <= @originGranularityLevel
		and dlg.GranularityLevel <= @destinationGranularityLevel
	
	return
END
GO
GRANT SELECT ON  [dbo].[fn_LaneRateMatrixOriginToDestinationRateIds] TO [public]
GO
