SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_UnbilledOrders]
	(
		--Standard Parameters
		@MINThreshold FLOAT = 7,	-- Grace days from completion to invoice 
		@MinsBack INT = 0,			-- not used
		@TempTableName VARCHAR(255) = '##WatchDogGlobalUnbilledOrders',
		@WatchName VARCHAR(255)='UnbilledOrders',
		@ThresholdFieldName VARCHAR(255) = 'Days',
		@ColumnNamesONly BIT = 0,
		@ExecuteDirectly BIT = 0,
		@ColumnMode VARCHAR(50) = 'Selected',

		--Additional/Optional Parameters
		@OnlyRevClass1List VARCHAR(255)='',
		@OnlyRevClass2List VARCHAR(255)='',
		@OnlyRevClass3List VARCHAR(255)='',
		@OnlyRevClass4List VARCHAR(255)='',
		@OnlyCompanyList VARCHAR(255)='',
		@InvoiceStatusListToConsiderBilled VARCHAR(255)=''	-- PRN,HLA,HLD
	)
						
	AS

	--Standard Setting
	SET NOCOUNT ON

	--Reserved/Mandatory WatchDog Variables
	DECLARE @SQL VARCHAR(8000)
	DECLARE @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables

	--Standard Parameter Initialization  
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','  
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','  
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','  
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','  
	Set @OnlyCompanyList= ',' + ISNULL(@OnlyCompanyList,'') + ','  
	Set @InvoiceStatusListToConsiderBilled= ',' + ISNULL(@InvoiceStatusListToConsiderBilled,'') + ','  
  
	-- Initialize the #orderheader table (temporary) to be used for many calculations.  
	SELECT  'OrdNum' = OH.ord_hdrnumber
		,'BookDate' = ord_bookdate
		,'BillTo' = OH.ord_billto
		,'ShipDate' = ord_startdate
		,'Shipper' = ord_shipper
		,'DelvDate' = ord_completiondate
		,'Consignee' = ord_consignee
		,'Asset' =	Case When lgh_driver1 = 'UNKNOWN' then
						'Carrier: ' + lgh_carrier
					Else
						'Driver: ' + lgh_driver1 + ' in ' + lgh_tractor + ' using ' + lgh_primary_trailer
					End
		,'LH_Charge' = convert(money,IsNull(dbo.fnc_convertcharge(ord_charge,ord_currency,'Revenue',OH.ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
		,'Total_Charge' = convert(money,IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',OH.ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0))
		,'BillMiles' = ISNULL((	Select SUM(ISNULL(stp_ord_mileage,0))  
								From stops s (NOLOCK)  
								where s.mov_number=OH.mov_number  
								and s.ord_hdrnumber=OH.ord_hdrnumber),0)
		,'Commodity' = OH.cmd_code
		,'TotalWeight' = ord_totalweight
		,'TotalCount' = ord_totalpieces
	INTO    #TempResults
	FROM orderheader OH(NOLOCK) join legheader LH (NOLOCK) on OH.mov_number = LH.mov_number
	WHERE   DateAdd(dd,@MinThreshold,ord_completiondate) <= GetDate()
		AND ord_invoicestatus <> 'XIN'
		AND ord_status = 'CMP'
		AND NOT EXISTS	(	Select *   
							from invoiceheader i (NOLOCK)  
							where  i.ord_hdrnumber=OH.ord_hdrnumber   
							AND	(	i.ivh_invoicestatus = 'XFR'
										OR 
									(@InvoiceStatusListToConsiderBilled = ',,' or CHARINDEX(',' + i.ivh_invoicestatus + ',', @InvoiceStatusListToConsiderBilled ) > 0)  
								)
						)  
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + ord_revtype1 + ',', @OnlyRevClass1List) > 0)  
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + ord_revtype2 + ',', @OnlyRevClass2list) > 0)  
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + ord_revtype3 + ',', @OnlyRevClass3List) > 0)  
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + ord_revtype4 + ',', @OnlyRevClass4List) > 0)  
		AND (@OnlyCompanyList =',,' or CHARINDEX(',' + ord_subcompany + ',', @OnlyCompanyList) > 0)  
	Order by OH.ord_hdrnumber, LH.lgh_enddate

	--Begin Reserved/Mandatory recordset wrapper for the content of the email
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
	BEGIN
		SET @SQL = 'SELECT * FROM #TempResults'
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName, @ColumnMode=@ColumnMode, @SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
	END

	EXEC (@SQL)
	--End Reserved/Mandatory recordset wrapper for the content of the email

	--Standard Setting
	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[WatchDog_UnbilledOrders] TO [public]
GO
