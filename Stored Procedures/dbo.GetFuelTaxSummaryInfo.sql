SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetFuelTaxSummaryInfo](@startDate datetime, @endDate datetime, @fleet varchar(8), @fuel_type varchar(8), @tractorID varchar(12))

AS

BEGIN
	DECLARE	@fleet_mpg			float,
			@sum_fuel_purch		float,
			@country			varchar(3),
			@id int,
			@state varchar(4),
			@rate_start_date datetime,
			@rate float

	-- Temp table to store all the state mileage calculated information from RAND miles
	CREATE TABLE #temp_summary_info (
			id							INT	NOT NULL IDENTITY(1,1),
			si_state 					VARCHAR(4), 
			si_statetotalmiles 			DECIMAL(12,2) NULL DEFAULT 0,
			si_statetollmiles 			DECIMAL(12,2) NULL DEFAULT 0,
			si_statefreemiles 			DECIMAL(12,2) NULL DEFAULT 0,
			si_fuel_purchased 			DECIMAL(12,2) NULL DEFAULT 0,
			si_fuel_used				DECIMAL(12,2) NULL DEFAULT 0,
			si_taxable_fuel				DECIMAL(12,2) NULL DEFAULT 0,
			si_tax_rate 				DECIMAL(12,5) NULL DEFAULT 0,
			si_tax_rate_effective_date	DATETIME NULL,
			si_fuel_tax_credit			DECIMAL(12,2) NULL DEFAULT 0,
			si_fuel_tax_due				DECIMAL(12,2) NULL DEFAULT 0,
			si_fuel_tax_balance			DECIMAL(12,2) NULL DEFAULT 0,
			si_mileage_tax_rate			DECIMAL(12,2) NULL DEFAULT 0,
			si_mileage_tax_due			DECIMAL(12,2) NULL DEFAULT 0
		)

	-- Temp table to store all the Fuel Purchases for the quarter
	CREATE TABLE #temp_fuel_purchased (
			tfp_id			INTEGER	IDENTITY(1,1) NOT NULL,
			tfp_state 					VARCHAR(4), 
			tfp_fuel_purchased 			DECIMAL(12,2) NULL,
		)

	-- Temp table to store all the State tax rates for the quarter
	CREATE TABLE #temp_states (
			ts_id			INTEGER	IDENTITY(1,1) NOT NULL,
			ts_state 		VARCHAR(6) NOT NULL, 
			ts_start_date	datetime, 
			ts_end_date		datetime,
			ts_rate			float
		)

	-- Temp table to store all the State tax rates for the quarter
	CREATE TABLE #temp_states_mileage (
			ts_id			INTEGER	IDENTITY(1,1) NOT NULL,
			ts_state 		VARCHAR(6) NOT NULL, 
			ts_start_date	datetime, 
			ts_end_date		datetime,
			ts_rate			float
		)

	-- Temp table to store all the mileagetax rate information
	CREATE TABLE #temp_mileage_taxes (
			mt_state 							VARCHAR(4), 
			mt_lgh_number						INT,
			mt_trc_number						VARCHAR(12),
			mt_statetotalmiles 					DECIMAL(12,2) NULL DEFAULT 0,
			mt_statetollmiles 					DECIMAL(12,2) NULL DEFAULT 0,
			mt_statefreemiles 					DECIMAL(12,2) NULL DEFAULT 0,
			mt_mileage_tax_rate					DECIMAL(12,2) NULL DEFAULT 0,
			mt_mileage_tax_due_total_miles		DECIMAL(12,2) NULL DEFAULT 0,
			mt_mileage_tax_due_non_toll_miles	DECIMAL(12,2) NULL DEFAULT 0
		)				
		
-- **********************************************************************************************
--	Initialize varables used.
-- **********************************************************************************************

	if ISNULL(@tractorID,'') = ''
		SET @tractorID = 'UNKNOWN'
		
	if ISNULL(@fleet,'') = ''
		SET @fleet = 'UNKNOWN'

	-- Get the proper country for the fleet. If not found default to USD
	select @country = ISNULL(country, 'USD') from fueltaxfleetcountrymapping where fleet = @fleet
	if isnull(@country,'') = ''
		set @country = 'USD'

	--**********************************************************************************************
	-- Get list of state rates for the quarter and put in a temp table 
	--**********************************************************************************************
	INSERT INTO #temp_states(ts_state, ts_start_date, ts_end_date, ts_rate) 
		SELECT DISTINCT sftState, sftDate, sftend_date, sftRate 
			FROM statefueltax 
			WHERE sftDate >= @startDate 
				  AND sftDate <= @endDate 
				  AND fuel_type =  @fuel_type 
				  AND country_code = @country 
				  AND fuel_mileage_tax_type = 'F'
			ORDER BY sftstate

	INSERT INTO #temp_states_mileage(ts_state, ts_start_date, ts_end_date, ts_rate) 
		SELECT DISTINCT sftState, sftDate, sftend_date, sftRate 
			FROM statefueltax 
			WHERE sftDate >= @startDate 
				  AND sftDate <= @endDate 
				  AND fuel_type =  @fuel_type 
				  AND country_code = @country 
				  AND fuel_mileage_tax_type = 'M'
			ORDER BY sftstate

	--**********************************************************************************************  
	-- Get list of FuelPurchases for the quarter and put in a temp table   
	--**********************************************************************************************  
	if isnull(@tractorID, 'UNKNOWN') = 'UNKNOWN'  
		BEGIN  
			insert into #temp_fuel_purchased(tfp_state, tfp_fuel_purchased)  
				SELECT fp_state, sum(fp_quantity) as fp_quantity
					FROM (SELECT fp.trc_number, trc.trc_fleet, fp.fp_state,	fp.fp_quantity as fp_quantity, fp.fp_amount as fp_amount
								FROM fuelpurchased fp
									INNER JOIN tractorprofile trc ON trc.trc_number = fp.trc_number
								WHERE fp.fp_date >= @startDate AND fp.fp_date < @endDate   
									AND fp.fp_fueltype = @fuel_type
									AND trc.trc_fleet = @fleet
									AND NOT EXISTS (select 1 from legheader where legheader.lgh_number = fp.lgh_number)
		      			  UNION ALL
		      			  SELECT fp.trc_number,	lgh.trc_fleet, fp.fp_state,	fp.fp_quantity as fp_quantity, fp.fp_amount as fp_amount
								FROM fuelpurchased fp
									INNER JOIN tractorprofile trc ON trc.trc_number = fp.trc_number
									INNER JOIN legheader lgh ON lgh.lgh_number = fp.lgh_number 
		      			  WHERE fp.fp_date >= @startDate AND fp.fp_date < @endDate
								AND fp.fp_fueltype = @fuel_type
								and lgh.trc_fleet = @fleet) as fuel
				GROUP BY fp_state  
		END  
	ELSE  
		BEGIN  
			insert into #temp_fuel_purchased(tfp_state, tfp_fuel_purchased)  
				SELECT fp_state, sum(fp_quantity) as fp_quantity
					FROM (SELECT fp.trc_number, trc.trc_fleet, fp.fp_state,	fp.fp_quantity as fp_quantity, fp.fp_amount as fp_amount
								FROM fuelpurchased fp
									INNER JOIN tractorprofile trc ON trc.trc_number = fp.trc_number
								WHERE fp.fp_date >= @startDate AND fp.fp_date < @endDate   
									AND fp.fp_fueltype = @fuel_type
									AND fp.trc_number = @tractorid
									AND trc.trc_fleet = @fleet
									AND NOT EXISTS (select 1 from legheader where legheader.lgh_number = fp.lgh_number)
		      			  UNION ALL
		      			  SELECT fp.trc_number,	lgh.trc_fleet, fp.fp_state,	fp.fp_quantity as fp_quantity, fp.fp_amount as fp_amount
								FROM fuelpurchased fp
									INNER JOIN tractorprofile trc ON trc.trc_number = fp.trc_number
									INNER JOIN legheader lgh ON lgh.lgh_number = fp.lgh_number 
		      			  WHERE fp.fp_date >= @startDate AND fp.fp_date < @endDate
								AND fp.fp_fueltype = @fuel_type
								and fp.trc_number = @tractorid
								and lgh.trc_fleet = @fleet) as fuel
				GROUP BY fp_state  
		END   
		
	--**********************************************************************************************  
	-- Get summary of mileage information
	--**********************************************************************************************  
	if isnull(@tractorID, 'UNKNOWN') = 'UNKNOWN'
		BEGIN
			INSERT INTO #temp_summary_info(si_state, si_statetotalmiles, si_statetollmiles, si_statefreemiles)
				SELECT	ftm_state,
					SUM(ftm_totalmiles) AS [TotalMiles], 
					SUM(ftm_tollmiles) AS [TollMiles], 
					SUM(ftm_freemiles) AS [FreeMiles] 
				FROM FuelTaxMileageDetail ftmd JOIN legheader lh ON ftmd.lgh_number = lh.lgh_number
											   JOIN tractorprofile tp ON tp.trc_number = lh.lgh_tractor
				WHERE ftmd.ftm_date >= @startdate and ftmd.ftm_date <= @enddate
						AND ISNULL(lh.trc_fleet,'UNK') = @fleet 
						AND ISNULL(tp.trc_fueltype,'') = @fuel_type
					group by ftm_state
					order by ftm_state
		END
	ELSE
		BEGIN
			INSERT INTO #temp_summary_info(si_state, si_statetotalmiles, si_statetollmiles, si_statefreemiles)
				SELECT	ftm_state,
					SUM(ftm_totalmiles) AS [TotalMiles], 
					SUM(ftm_tollmiles) AS [TollMiles], 
					SUM(ftm_freemiles) AS [FreeMiles]
					FROM FuelTaxMileageDetail ftmd JOIN legheader lh ON ftmd.lgh_number = lh.lgh_number
												   JOIN tractorprofile tp ON tp.trc_number = lh.lgh_tractor
					WHERE ftmd.ftm_date >= @startdate and ftmd.ftm_date <= @enddate
							AND ISNULL(lh.trc_fleet,'UNK') = @fleet 
							AND ISNULL(tp.trc_fueltype,'') = @fuel_type
							AND tp.trc_number = @tractorID
						group by ftm_state
						order by ftm_state
		END

	-- Update Fuel Purchases
	update #temp_summary_info set si_fuel_purchased = #temp_fuel_purchased.tfp_fuel_purchased 
		FROM #temp_summary_info inner join #temp_fuel_purchased on #temp_summary_info.si_state = #temp_fuel_purchased.tfp_state

	-- Update tax rates from StateFuelTaxTable
	update #temp_summary_info set si_tax_rate = #temp_states.ts_rate, si_tax_rate_effective_date = 	#temp_states.ts_start_date	
		FROM #temp_summary_info inner join #temp_states on #temp_summary_info.si_state = #temp_states.ts_state

	--**********************************************************************************************
	-- Get all records that need to have mileage tax caculated on them
	--**********************************************************************************************
	INSERT INTO #temp_mileage_taxes(mt_state ,mt_lgh_number, mt_trc_number, mt_statetotalmiles, mt_statetollmiles, 
						mt_statefreemiles, mt_mileage_tax_rate, mt_mileage_tax_due_total_miles, mt_mileage_tax_due_non_toll_miles)			
				select ftmd.ftm_state, ftmd.lgh_number, tp.trc_number, ftmd.ftm_totalmiles, ftmd.ftm_tollmiles, 
					   ftmd.ftm_freemiles, sft.sftrate, round((ftmd.ftm_totalmiles * sft.sftrate),2), round((ftmd.ftm_freemiles * sft.sftrate),2) 
					FROM FuelTaxMileageDetail ftmd 
						JOIN legheader lh ON ftmd.lgh_number = lh.lgh_number
						JOIN tractorprofile tp ON tp.trc_number = lh.lgh_tractor
						JOIN StateFuelTax sft on ftmd.ftm_state = sft.sftstate
					WHERE ftmd.ftm_date >= @startdate and ftmd.ftm_date <= @enddate
								and tp.trc_fueltype = @fuel_type 
								and tp.trc_fleet = @fleet
								and sft.country_code = @country
								and tp.trc_grosswgt >= sft.gross_min_wgt and tp.trc_grosswgt <= sft.gross_max_wgt
								and fuel_mileage_tax_type = 'M'
		
	DECLARE @total_miles float,
			@total_due float
							
	select @id = min(ts_id) from #temp_states_mileage
	WHILE ISNULL(@id, -1) <> -1
		BEGIN
			SELECT @state = ts_state from #temp_states_mileage where ts_id = @id
			if @state = 'NY'
				select @total_miles = SUM(mt_statefreemiles), @total_due = SUM(mt_mileage_tax_due_non_toll_miles) from #temp_mileage_taxes where mt_state = @state
			else
				select @total_miles = SUM(mt_statetotalmiles), @total_due = SUM(mt_mileage_tax_due_total_miles) from #temp_mileage_taxes where mt_state = @state
			
			update #temp_summary_info set si_mileage_tax_due = @total_due, si_mileage_tax_rate = round((@total_due / @total_miles),2)
				where si_state = @state
			-- Go get the next record to be processed.
			select @id = min(ts_id) from #temp_states_mileage where ts_id > @id
		END

	--**********************************************************************************************
	--**				Process Surcharge States												  **
	--**********************************************************************************************
	select @id = min(ts_id) from #temp_states where ts_state like '%-S'
	WHILE ISNULL(@id, -1) <> -1
		BEGIN
			-- Get all the values we need to calculate this iteration
			SELECT @state = ts_state, @rate_start_date = ts_start_date, @rate = ts_rate from #temp_states where ts_id = @id

			-- copy the regular state values for the surcharge - will clear out uneeded info later.
			INSERT INTO #temp_summary_info(si_state, si_tax_rate, si_tax_rate_effective_date, si_statetotalmiles, si_statetollmiles, si_statefreemiles, si_fuel_purchased)
				SELECT @state, @rate, @rate_start_date, si_statetotalmiles, si_statetollmiles, si_statefreemiles, si_fuel_purchased 
					from #temp_summary_info where si_state = LEFT(@state,2)

			-- Go get the next record to be processed.
			select @id = min(ts_id) from #temp_states where ts_id > @id and ts_state like '%-S'
		END			
			
			
	--**********************************************************************************************
	--**				CALCULATIONS                                                              **
	--**********************************************************************************************
	-- calculate the fleets mpg - this will be used for data validation.
	set @fleet_mpg = 0.1
	select @sum_fuel_purch = SUM(si_fuel_purchased) from #temp_summary_info WHERE si_state not like '%-S'
	
	IF @sum_fuel_purch > 0
			select @fleet_mpg = ROUND(SUM(si_statetotalmiles) / ISNULL(SUM(si_fuel_purchased), 1),2) FROM #temp_summary_info WHERE si_state not like '%-S' 

	if @fleet_mpg < 0.1
		set @fleet_mpg = 0.1
		
	 --Calculate Values
	update #temp_summary_info 
			set si_fuel_used = ROUND((si_statetotalmiles / @fleet_mpg), 2),
			si_taxable_fuel = ROUND((si_statetotalmiles / @fleet_mpg), 2),
			si_fuel_tax_credit = ROUND((si_fuel_purchased * si_tax_rate), 2),
			si_fuel_tax_due = ROUND(((si_statetotalmiles / @fleet_mpg) * si_tax_rate), 2),
			si_fuel_tax_balance = ROUND((((si_statetotalmiles / @fleet_mpg) * si_tax_rate) - (si_fuel_purchased * si_tax_rate)), 2),
			si_mileage_tax_due = ROUND((si_statetotalmiles * si_mileage_tax_rate),2)

	-- Clear out extra column values for Surcharge States
	UPDATE #temp_summary_info set si_statetotalmiles = 0, si_statetollmiles = 0, si_statefreemiles = 0, si_fuel_purchased = 0, 
								  si_fuel_used = 0, si_fuel_tax_credit = 0, si_mileage_tax_rate = 0, si_mileage_tax_due = 0, si_fuel_tax_balance = si_fuel_tax_due 
			WHERE si_state like '%-S'
			


	select * from #temp_summary_info order by si_state

END

GO
GRANT EXECUTE ON  [dbo].[GetFuelTaxSummaryInfo] TO [public]
GO
