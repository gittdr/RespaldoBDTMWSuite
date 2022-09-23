SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[ResNow_RoundTripCacheBackfillXD]
(
	--Standard Parameters
	@RT_DefName varchar(255),
	@BackFillDays int
)
AS

/*
This stored procedure updates financial data in the cache table of round trip legs
*/

	--Standard Setting
	SET NOCOUNT ON

	-- local variables
	declare @DailyHours float 
	declare @AvgMPH float 
	declare @FuelRate float 
	declare @FuelCostInSettlementsParameter varchar(50) 	-- TrcAcctTypeList,TrcType1List,TrcType2List,TrcType3List,TrcType4List,TrcCompanyList,TrcDivisionList,TrcFleetList,TrcOwnerExcludedList
	declare @FuelInSettlementValue varchar(255)	-- appropriate value(s) to match up with label field selected above

	SET @DailyHours = 
		Case When IsNull((Select rt_DailyHours from Metric_RTDefinitions where rt_DefName = @RT_DefName),0.0) = 0.0 then
			14.0
		Else
			(Select rt_DailyHours from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @AvgMPH = 
		Case When IsNull((Select rt_AvgMPH from Metric_RTDefinitions where rt_DefName = @RT_DefName),0.0) = 0.0 then
			59.0
		Else
			(Select rt_AvgMPH from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @FuelRate = IsNull((Select rt_FuelRate from Metric_RTDefinitions where rt_DefName = @RT_DefName),0.0)
	SET @FuelCostInSettlementsParameter = 
		Case When IsNull((Select rt_FuelCostInSettlementsParameter from Metric_RTDefinitions where rt_DefName = @RT_DefName),'') = '' then
			'TrcAcctTypeList'
		Else
			(Select rt_FuelCostInSettlementsParameter from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @FuelInSettlementValue = 
		Case When IsNull((Select rt_FuelInSettlementValue from Metric_RTDefinitions where rt_DefName = @RT_DefName),'') = '' then
			'A'
		Else
			(Select rt_FuelInSettlementValue from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End


	Update Metric_RTLegCache 
		Set rt_TimeForLeg = IsNull(dbo.fnc_TMWRN_GetEstLegTime(rt_Leg,@DailyHours,0.25,@AvgMPH,Default,Default),0)
			--	revenue
			,rt_LHRevForLeg =  Round(IsNull(dbo.fnc_TMWRN_Revenue3('Leg',default,default,Legheader.mov_number,default,rt_Leg,default,default,'L',default,default,'N','N',default,default,'ALL',default,default,default),0),2)
			,rt_ACCRevForLeg = Round(IsNull(dbo.fnc_TMWRN_Revenue3('Leg',default,default,Legheader.mov_number,default,rt_Leg,default,default,'A',default,default,'N','N',default,default,'ALL',default,default,default),0),2)
			--	TVC
			,rt_GrossPayForLeg = IsNull(dbo.fnc_TMWRN_Pay(default,default,default,default,default,rt_Leg,default,default,NULL,1),0)
			,rt_TollForLeg = IsNull(dbo.fnc_TMWRN_GetTollCharge('Leg',rt_Leg),0)
			,rt_EstFuelCostForLeg = dbo.fnc_TMWRN_GetEstFuelCost(rt_Leg,@FuelRate,@FuelCostInSettlementsParameter,@FuelInSettlementValue)
	From Metric_RTLegCache join LegHeader on Metric_RTLegCache.rt_Leg = LegHeader.lgh_number
	Where rt_DefName = @RT_DefName
		AND rt_EndDate >= DateAdd(d,-@BackfillDays,GetDate())

GO
GRANT EXECUTE ON  [dbo].[ResNow_RoundTripCacheBackfillXD] TO [public]
GO
