SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create FUNCTION [dbo].[fnc_TMWRN_GetEstFuelCost] 
	(
		@LegNumber int = 0,		--
		@FuelRate float = 0.00,
		@FuelCostInSettlementsParameter varchar(50)='TrcAcctTypeList',	--
		@FuelInSettlementValue varchar(255)='A'	--
	)
RETURNS Money
AS
-- test
/*
This function returns an estimate of fuel costs for a leg.

If the @FuelRate parameter is zero it looks up the price paid in
the FuelPurchased table in the time frame during which the leg
was performed.

The @FuelCostInSettlementsParameter and @FuelInSettlementValue
parameters allow the user to distinguish between fuel paid
by the company directly and fuel paid by the company in the
form of reimbursements to carriers or owner operators.  

If the asset is reimbursed for fuel the company's fuel cost is
that reimbursement.  In that case this function returns ZERO.
It is expected that the fuel cost will be supplied by a call
to one of the pay (settlement) functions.

If the fuel cost is paid directly by the company the function
estimates this cost using the current fuel price (@FuelRate),
the leg mileage returned by a call to dbo.fnc_TMWRN_Miles
and the estimated MPG for the tractor assigned to the leg
returned by a call to dbo.fnc_TMWRN_GetTractorMPG.
*/
BEGIN

	declare @EstFuelCost money


	SET @FuelInSettlementValue = ',' + ISNULL(@FuelInSettlementValue,'') + ','

	If IsNull(@FuelRate,0) = 0.00 
		begin
			Set @FuelRate = (	Select max(fp_cost_per) 
								From FuelPurchased 
								where fp_date = (	select max(fp_date) 
													from FuelPurchased
													where fp_date <= (	Select lgh_enddate
																		From legheader
																		Where lgh_number = @LegNumber	)	)	)
		end

	Select @EstFuelCost =	
		Case 
		-- first part is to ID if fuel is contained in PayForLeg value.  If so, EstFuelCost here is zero.
			When	(lgh_tractor = 'UNKNOWN') 
					OR 
				(@FuelCostInSettlementsParameter = 'TrcType1List' AND CHARINDEX(',' + (Select trc_type1
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcType2List' AND CHARINDEX(',' + (Select trc_type2
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcType3List' AND CHARINDEX(',' + (Select trc_type3
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcType4List' AND CHARINDEX(',' + (Select trc_type4
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcCompanyList' AND CHARINDEX(',' + (Select trc_company
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcDivisionList' AND CHARINDEX(',' + (Select trc_division
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcFleetList' AND CHARINDEX(',' + (Select trc_fleet
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcAcctTypeList' AND CHARINDEX(',' + (Select trc_actg_type
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) > 0)
					OR 
				(@FuelCostInSettlementsParameter = 'TrcOwnerExcludedList' AND CHARINDEX(',' + (Select trc_owner
																									from tractorprofile (NOLOCK)
																									where trc_number = lgh_tractor)
																								+ ',', @FuelInSettlementValue) = 0)
			then
				0
		Else
		-- second part is to estimate fuel costs based on current price & tractor MPG
			(IsNull(dbo.fnc_TMWRN_Miles('LegHeader','Travel','Miles',default,default,lgh_number,default,'ALL',default,default,default),0)
				/
			IsNull(dbo.fnc_TMWRN_GetTractorMPG(lgh_tractor),1))
				*
			@FuelRate
		End
	from LegHeader
	where lgh_number = @LegNumber

	Set @EstFuelCost = Round(@EstFuelCost,2)
	
	return @EstFuelCost 
	
END
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_GetEstFuelCost] TO [public]
GO
