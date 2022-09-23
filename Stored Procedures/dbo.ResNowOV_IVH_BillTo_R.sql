SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

/* PARAMETER LIST. ONLY CHANGE NAME OF STORED PROCEDURE */
CREATE PROCEDURE [dbo].[ResNowOV_IVH_BillTo_R]
/* PARAMETER LIST. ONLY CHANGE NAME OF STORED PROCEDURE */
(
	@NumberOfValues int, -- when = 0 flags for ShowDetail
	@ItemID varchar(255),  -- when = '' flags for showing Detail of "other" (last piece of pie)
	@DateStart datetime = NULL, 
	@DateEnd datetime = NULL,
	@Parameters varchar(255)= Null,
	@Refresh int = 0,
    @Mode varchar(64) = Null
)

AS 

/* Revision History
05/04/2009:	modified to consider only trips with ord_status AVL,PLN,DSP,STD,CMP

*/

 	Declare @RNTrial_Cache TABLE
		(
			unique_number int
			,unique_date  datetime
			,[ItemID] [varchar] (50)
			,[Count] Money
		)   

	IF IsNull(@NumberOfValues,0) = 0
	BEGIN
		IF IsNull(@ItemID, '') > ''
		BEGIN
			SELECT 	ivh_billto AS BillToID
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_billto) AS BillTo
			,ord_hdrnumber AS [OrderNumber]
			,ivh_invoicenumber AS [InvoiceNumber]
			,ivh_deliverydate [CompletionDate]
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_originpoint) AS [Origin]
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_destpoint) AS [Destination]
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_order_by) AS OrderedBy
			,ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00) as TotalCharge
			,ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'L',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00) as LineHaulRevenue
			,IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,default,default,ivh_hdrnumber,ivh_billto),0) as TotalMiles
			,IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,'MT',default,ivh_hdrnumber,ivh_billto),0) as EmptyMiles
			FROM invoiceheader (NOLOCK) 
			WHERE ivh_deliverydate BETWEEN @DateStart and @DateEnd
			AND ivh_billto = @ItemID
		END
		ELSE
		BEGIN
			SELECT 	ivh_billto AS BillToID
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_billto) AS BillTo
			,ord_hdrnumber AS [OrderNumber]
			,ivh_invoicenumber AS [InvoiceNumber]
			,ivh_deliverydate [CompletionDate]
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_originpoint) AS [Origin]
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_destpoint) AS [Destination]
			,(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_order_by) AS OrderedBy
			,ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00) as TotalCharge
			,ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'L',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00) as LineHaulRevenue
			,IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,default,default,ivh_hdrnumber,ivh_billto),0) as TotalMiles
			,IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,'MT',default,ivh_hdrnumber,ivh_billto),0) as EmptyMiles
			FROM invoiceheader (NOLOCK) 
			WHERE ivh_deliverydate BETWEEN @DateStart and @DateEnd
			AND ivh_billto NOT IN (SELECT ItemID FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			ORDER BY ivh_billto 
		END
	END 
	ELSE IF @Refresh = 1
	BEGIN
		-- INSERT @RNTrial_Cache
			SELECT 	ivh_hdrnumber
			,ivh_deliverydate
			,[ItemID] = ivh_billto
			,[Count] = ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00)
			INTO #temp1
			FROM invoiceheader (NOLOCK) 
			WHERE ivh_deliverydate BETWEEN @DateStart and @DateEnd
			-- AND ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00) <> 0

		DELETE #temp1 WHERE ISNULL([Count], 0) = 0
		
		INSERT @RNTrial_Cache 
		SELECT ivh_hdrnumber, ivh_deliverydate, ItemId, [Count] FROM #temp1
		

		SET ROWCOUNT @NumberOfValues
		
		INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription], [Count], [Percentage])  
			SELECT 	[LastUpdate] = GETDATE()
			,[DateStart] = @DateStart
			,[DateEnd] = @DateEnd
			,[ItemCategory] = @Mode
			,[ItemID] = RNTC.[ItemID]
			,[ItemDescription] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = RNTC.[ItemID])
			,[Count] = SUM(RNTC.[Count])
			,[Percentage] = CONVERT(decimal(24, 5) , 100 * SUM([Count]) / CONVERT(decimal(20, 5), (SELECT SUM(RNTC1.[Count]) FROM @RNTrial_Cache RNTC1)))
			FROM @RNTrial_Cache RNTC 
			GROUP BY RNTC.[ItemID]
			ORDER BY SUM(RNTC.[Count]) DESC
		SET ROWCOUNT 0
	END


GO
GRANT EXECUTE ON  [dbo].[ResNowOV_IVH_BillTo_R] TO [public]
GO
