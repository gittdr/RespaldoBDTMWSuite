SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_PayrollAmount] 
(
	--Standard Parameters
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	--Additional/Optional Parameters 
	@OnlyDrvType1List varchar(128)='',
	@OnlyDrvType2List varchar(128)='',
	@OnlyDrvType3List varchar(128)='',
	@OnlyDrvType4List varchar(128)='',
	@OnlyTeamleaderList varchar(128)='',
	@OnlyDrvFleetList varchar(128)='',
	@OnlyDrvDivisionList varchar(128)='',
	@OnlyDrvDomicileList varchar(128)='',
	@OnlyDrvCompanyList varchar(128)='',
	@OnlyDrvTerminalList varchar(128)='',
	@MetricCode varchar(255)='PayrollAmount', 
	@OnlyPayItemCodeList varchar(255)=' '
)
AS
	SET NOCOUNT ON  -- PTS46367

	--Populate default currency and currency date types
        Exec PopulateSessionIDParamatersInProc 'Pay',@MetricCode  

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'SettlementAmount', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 303, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Settlement Amount',
		@sCaptionFull = 'Settlement Amount',
		@sProcedureName = 'Metric_SettlementAmount',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	DECLARE @TotalPay decimal(20,5)

	SET @OnlyDrvType1List= ',' + ISNULL(@OnlyDrvType1List,'') + ','
	SET @OnlyDrvType2List= ',' + ISNULL(@OnlyDrvType2List,'') + ','
	SET @OnlyDrvType3List= ',' + ISNULL(@OnlyDrvType3List,'') + ','
	SET @OnlyDrvType4List= ',' + ISNULL(@OnlyDrvType4List,'') + ','
	SET @OnlyTeamleaderList= ',' + ISNULL(@OnlyTeamleaderList,'') + ','
	SET @OnlyDrvFleetList= ',' + ISNULL(@OnlyDrvFleetList,'') + ','
	SET @OnlyDrvDivisionList= ',' + ISNULL(@OnlyDrvDivisionList,'') + ','
	SET @OnlyDrvDomicileList= ',' + ISNULL(@OnlyDrvDomicileList,'') + ','
	SET @OnlyDrvCompanyList= ',' + ISNULL(@OnlyDrvCompanyList,'') + ','
	SET @OnlyDrvTerminalList= ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	SET @OnlyPayItemCodeList= ',' + ISNULL(@OnlyPayItemCodeList,'') + ','

	SELECT @TotalPay = IsNull(SUM(IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00)),0.00)
	FROM paydetail WITH (NOLOCK) join manpowerprofile (nolock) on asgn_id = mpp_id
	WHERE pyh_payperiod >= @DateStart AND pyh_payperiod < @DateEnd
		AND asgn_type = 'DRV'
		AND (@OnlyDrvType1List =',,' OR CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvType1List) >0)
		AND (@OnlyDrvType2List =',,' OR CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvType2List) >0)
		AND (@OnlyDrvType3List =',,' OR CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvType3List) >0)
		AND (@OnlyDrvType4List =',,' OR CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvType4List) >0) 
		AND (@OnlyTeamleaderList =',,' OR CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyTeamleaderList) >0) 
		AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) >0) 
		AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivisionList) >0) 
		AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicileList) >0) 
		AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0) 
		AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
		AND (@OnlyPayItemCodeList =',,' OR CHARINDEX(',' + RTRIM( pyt_itemcode ) + ',', @OnlyPayItemCodeList) >0)	
	--==============================================================================
	SET @ThisCount = @TotalPay
	
	SELECT @ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
							THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	if (@ShowDetail=1)
	BEGIN
		Select 
			@DateStart MinimumPayPeriodUsed,
			@DateEnd   MaximumPayPeriodUsed,
			lgh_number,
			asgn_type,
			asgn_id,
			mov_number,
			pyd_description PayDescription,
			pyd_quantity Quantity,
			pyd_rate 	Rate,
			IsNull(dbo.fnc_convertcharge(pyd_amount,pyd_currency,'Pay',pyd_number,pyd_currencydate,default,default,default,default,default,default,default,pyd_transdate,pyd_workperiod,pyh_payperiod),0.00) as 'Amount', 
			pyh_payperiod PayPeriod, 
			mpp_teamleader, 
			ord_hdrnumber,
			totalmiles = isNull(case 
							when pyt_basis = 'LGH' then 
								case when pyt_basisunit = 'DIS' then pyd_quantity else
								 	IsNull(dbo.fnc_TMWRN_Miles('segment','travel','Miles',default,ord_hdrnumber,lgh_number,default,'ALL',default,default,default),0) 
								end
							end,0)
-- 		    IsNull(dbo.fnc_TMWRN_Miles('segment','travel','Miles',default,ord_hdrnumber,lgh_number,default,'ALL',default,default,default),0) as TotalMiles
		From Paydetail (nolock) join manpowerprofile (nolock) on mpp_id = asgn_id JOIN paytype P (nolock) on paydetail.pyt_itemcode = p.pyt_itemcode

		where pyh_payperiod >= @DateStart AND pyh_payperiod < @DateEnd		 		
			AND asgn_type = 'DRV'
			AND (@OnlyDrvType1List =',,' OR CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvType1List) >0)
			AND (@OnlyDrvType2List =',,' OR CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvType2List) >0)
			AND (@OnlyDrvType3List =',,' OR CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvType3List) >0)
			AND (@OnlyDrvType4List =',,' OR CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvType4List) >0) 
			AND (@OnlyTeamleaderList =',,' OR CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyTeamleaderList) >0) 
			AND (@OnlyDrvFleetList =',,' OR CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) >0) 
			AND (@OnlyDrvDivisionList =',,' OR CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivisionList) >0) 
			AND (@OnlyDrvDomicileList =',,' OR CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicileList) >0) 
			AND (@OnlyDrvCompanyList =',,' OR CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0) 
			AND (@OnlyDrvTerminalList =',,' OR CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
			AND (@OnlyPayItemCodeList =',,' OR CHARINDEX(',' + RTRIM( paydetail.pyt_itemcode ) + ',', @OnlyPayItemCodeList) >0)

			
	END

GO
GRANT EXECUTE ON  [dbo].[Metric_PayrollAmount] TO [public]
GO
