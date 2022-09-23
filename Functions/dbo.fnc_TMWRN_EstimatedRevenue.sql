SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_EstimatedRevenue] 
(	
	@IncludeChargeTypeList varchar(255) = '',
	@ExcludeChargeTypeList  varchar(255) = '',
	@LineHaulRevenueOnlyYN	Char(1)='N',
	@AccRevenueOnlyYN		Char(1)='N',
	@OnlyRevenueFromChargeTypesYN Char(1) = 'N',
	@ExcludeBillToIDList varchar(255) = '',
	@IncludeBillToIDList varchar(255) = '',
	@OrderStatusList varchar(255) = '',
	@InvoiceStatusList varchar(255) = '',
	@RevType1List varchar(255) = '',
	@RevType2List varchar(255) = '',
	@RevType3List varchar(255) = '',
	@RevType4List varchar(255) = '',
	@DateEnd datetime = NULL,
	@DaysBackToStartEstimate int = 30,
	@DaysBackToEndEstimate int = 0,
	@DefaultEstimateAmount money = 350
) 


Returns @EstimatedRevenueResults Table
( BillToID varchar(50),
 EstimatedRevenue money,
 EstimatedLineHaulRevenue money,
 EstimatedTotalCharge money,
 ivh_hdrnumber int
)
As
Begin 




Declare @Revenue money
Declare @UnbilledLineHaulRevenue money
Declare @UnbilledTotalCharge money
Declare @BilledLineHaulRevenue money
Declare @AccessorialRevenue money
Declare @PercenttoAllocate float 
Declare @ExcludeRevenue money
Declare @IncludeRevenue money
Declare @BilledTotalCharge money                   
Declare @TotalCharge money
Declare @LineHaulRevenue money
Declare @other float
Declare @DateStart datetime

Set @DateStart = (@DateEnd - @DaysBackToStartEstimate)
Set @DateEnd = (@DateEnd - @DaysBackToEndEstimate)

SELECT @IncludeChargeTypeList = Case When Left(@IncludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@IncludeChargeTypeList, ''))) + ',' Else @IncludeChargeTypeList End
SELECT @ExcludeChargeTypeList = Case When Left(@ExcludeChargeTypeList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeChargeTypeList, ''))) + ',' Else @ExcludeChargeTypeList End
SELECT @ExcludeBillToIDList = Case When Left(@ExcludeBillToIDList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeBillToIDList, ''))) + ',' Else @ExcludeBillToIDList End
SELECT @IncludeBillToIDList = Case When Left(@IncludeBillToIDList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@IncludeBillToIDList, ''))) + ',' Else @IncludeBillToIDList End
SELECT @OrderStatusList = Case When Left(@OrderStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OrderStatusList, ''))) + ',' Else @OrderStatusList End
SELECT @InvoiceStatusList = Case When Left(@InvoiceStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@InvoiceStatusList, ''))) + ',' Else @InvoiceStatusList End
SELECT @RevType1List = Case When Left(@RevType1List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@RevType1List, ''))) + ',' Else @RevType1List End
SELECT @RevType2List = Case When Left(@RevType2List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@RevType2List, ''))) + ',' Else @RevType2List End
SELECT @RevType3List = Case When Left(@RevType3List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@RevType3List, ''))) + ',' Else @RevType3List End
SELECT @RevType4List = Case When Left(@RevType4List,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@RevType4List, ''))) + ',' Else @RevType4List End


			Insert @EstimatedRevenueResults
			
				Select BillToID,
			       Case When @AccRevenueOnlyYN = 'Y' Then
			       	     	 Sum(((IsNull(BilledTotalCharge,0) - IsNull(BilledLineHaulRevenue,0))))
			       	    When @LineHaulRevenueOnlyYN = 'Y' Then
				         Sum(IsNull(BilledLineHaulRevenue,0))
			            When @OnlyRevenueFromChargeTypesYN = 'Y' Then
				         Sum(IsNull(IncludeRevenue,0))
			            When @IncludeChargeTypeList <> ',,' And @ExcludeChargeTypeList <> ',,' Then
				         Sum((IsNull(BilledLineHaulRevenue,0) - IsNull(ExcludeRevenue,0)) + IsNull(IncludeRevenue,0))
			            When @IncludeChargeTypeList <> ',,' Then 
					 Sum((IsNull(BilledLineHaulRevenue,0) + IsNull(IncludeRevenue,0)))
			            When @ExcludeChargeTypeList <> ',,' Then
					 Sum((IsNull(BilledTotalCharge,0) - IsNull(ExcludeRevenue,0)))
			            Else
					 Sum(IsNull(BilledTotalCharge,0))
			       End as EstimatedRevenue,
			       Case When @LineHaulRevenueOnlyYN = 'Y' Then
				         Sum(IsNull(BilledLineHaulRevenue,0))
			            When @IncludeChargeTypeList <> ',,' And @ExcludeChargeTypeList <> ',,' Then
				         Sum((IsNull(BilledLineHaulRevenue,0) - IsNull(ExcludeRevenue,0)) + IsNull(IncludeRevenue,0))
			            When @IncludeChargeTypeList <> ',,' Then 
					 Sum((IsNull(BilledLineHaulRevenue,0) + IsNull(IncludeRevenue,0)))
				    Else
					 Sum(IsNull(BilledLineHaulRevenue,0))
			       End as EstimatedLineHaulRevenue,
			       Case When @ExcludeChargeTypeList <> ',,' Then
					 Sum((IsNull(BilledTotalCharge,0) - IsNull(ExcludeRevenue,0)))
				    Else
					 Sum(IsNull(BilledTotalCharge,0))
			       End as EstimatedTotalCharge,
			       ivh_hdrnumber	

			From

			(

			SELECT  BilledTotalCharge = IsNull(convert(money,IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00)),0.00),
				BilledLineHaulRevenue = IsNull(convert(money,IsNull(dbo.fnc_convertcharge(ivh_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00)),0.00),
				0 as ExcludeRevenue,
				0 as IncludeRevenue,
				BillToID = ivh_billto,
				invoiceheader.ivh_hdrnumber	
                                FROM    invoiceheader (NOLOCK) 
						      
                       		WHERE 
                                	
					(@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
					And
					(@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
					And
					((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
					And
					(@RevType1List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @RevType1List) > 0)) 
					And
					(@RevType2List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @RevType2List) > 0)) 
					And
					(@RevType3List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @RevType3List) > 0)) 
					And
					(@RevType4List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @RevType4List) > 0)) 
					And
					ivh_billdate >= @DateStart and ivh_billdate <= @DateEnd
				

		    	Union ALL

		       	SELECT  convert(money,0) as BilledTotalCharge,
				convert(money,0) as BilledLineHaulRevenue,
				ExcludeRevenue = IsNull(convert(money,IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00)),0.00),
                                convert(money,0) as IncludeRevenue,
				ivh_billto as BillToID,
				invoiceheader.ivh_hdrnumber	                         
                       	FROM    invoicedetail (NOLOCK) Inner Join invoiceheader (NOLOCK) On invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
						       
                       	WHERE 
                                
				CHARINDEX(',' + RTRIM( invoicedetail.cht_itemcode ) + ',', @ExcludeChargeTypeList) >0
				and 
				ivd_charge is Not Null 
				And
				(@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
				And
				(@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
				And				((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
				And
				(@RevType1List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @RevType1List) > 0)) 
				And
				(@RevType2List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @RevType2List) > 0)) 
				And
				(@RevType3List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @RevType3List) > 0)) 
				And
				(@RevType4List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @RevType4List) > 0)) 
				And
				ivh_billdate >= @DateStart and ivh_billdate <= @DateEnd
					
			Union ALL		
			
 			SELECT  convert(money,0) as BilledTotalCharge,
				convert(money,0) as BilledLineHaulRevenue,
                                convert(money,0) as ExcludeRevenue,
				IncludeRevenue = IsNull(convert(money,IsNull(dbo.fnc_convertcharge(ivd_charge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00)),0.00),
				ivh_billto as BillToID,
				invoiceheader.ivh_hdrnumber	
                                                        
                       	FROM    invoicedetail (NOLOCK) Inner Join invoiceheader (NOLOCK) On invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber 
						      
                       	WHERE 
                               
                                CHARINDEX(',' + RTRIM( invoicedetail.cht_itemcode ) + ',', @IncludeChargeTypeList ) > 0
				and 
				ivd_charge is Not Null 
				And
				(@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @ExcludeBillToIDList) > 0)) 
				And
				(@IncludeBillToIDList = ',,' OR (CHARINDEX(',' + RTRIM( ivh_billto ) + ',', @IncludeBillToIDList) > 0)) 
				And
				((@InvoiceStatusList = ',,' And ivh_invoicestatus <> 'CAN') OR (CHARINDEX(',' + RTRIM( ivh_invoicestatus ) + ',', @InvoiceStatusList) > 0)) 
				And
				(@RevType1List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype1 ) + ',', @RevType1List) > 0)) 
				And
				(@RevType2List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype2 ) + ',', @RevType2List) > 0)) 
				And
				(@RevType3List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype3 ) + ',', @RevType3List) > 0)) 
				And
				(@RevType4List = ',,' OR (CHARINDEX(',' + RTRIM( ivh_revtype4 ) + ',', @RevType4List) > 0)) 
				And
				ivh_billdate >= @DateStart and ivh_billdate <= @DateEnd
		  	
			) as TempRev
	        	Group By BillToID,ivh_hdrnumber	                      
		

Return

End

GO
GRANT SELECT ON  [dbo].[fnc_TMWRN_EstimatedRevenue] TO [public]
GO
