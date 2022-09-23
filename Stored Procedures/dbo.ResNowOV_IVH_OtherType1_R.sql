SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_IVH_OtherType1_R]
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
03/14/2011: modified to use invoiceheader instead of orderheader to bring in Misc invoices

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
			SELECT 	[OtherType1Abbr] = company.cmp_othertype1
			,[OtherType1] = (SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'OtherTypes1' and abbr = company.cmp_othertype1) 
			,[OrderNum] = ord_hdrnumber
			,[CompletionDate] = IH.ivh_deliverydate
			,[Origin] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_originpoint)
			,[Destination] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_destpoint)
			,[OrderedBy] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_order_by) 
			,[BillTo] =(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_billto)
			,[TotalCharge] = ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00)
			,[LinehaulCharge] = ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'L',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00)
			,[TotalMiles] = IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,default,default,ivh_hdrnumber,ivh_billto),0)
			,[EmptyMiles] = IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,'MT',default,ivh_hdrnumber,ivh_billto),0)
			FROM invoiceheader IH (NOLOCK) Join Company (NOLOCK) on IH.ivh_billto = company.cmp_id
			WHERE IH.ivh_deliverydate BETWEEN @DateStart and @DateEnd
			AND company.cmp_othertype1 = @ItemID
		END
		ELSE
		BEGIN
			SELECT 	[OtherType1Abbr] = company.cmp_othertype1
			,[OtherType1] = (SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'OtherTypes1' and abbr = company.cmp_othertype1) 
			,[OrderNum] = ord_hdrnumber
			,[CompletionDate] = IH.ivh_deliverydate
			,[Origin] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_originpoint)
			,[Destination] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_destpoint)
			,[OrderedBy] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_order_by) 
			,[BillTo] =(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = IH.ivh_billto)
			,[TotalCharge] = ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00)
			,[LinehaulCharge] = ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,ivh_hdrnumber,'L',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00)
			,[TotalMiles] = IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,default,default,ivh_hdrnumber,ivh_billto),0)
			,[EmptyMiles] = IsNull(dbo.fnc_TMWRN_Miles('Invoice','Travel','Miles',mov_number,ord_hdrnumber,default,default,'MT',default,ivh_hdrnumber,ivh_billto),0)
			FROM invoiceheader IH (NOLOCK) Join Company (NOLOCK) on IH.ivh_billto = company.cmp_id
			WHERE IH.ivh_deliverydate BETWEEN @DateStart and @DateEnd
			AND company.cmp_othertype1 NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			ORDER BY company.cmp_othertype1 
		END
	END
	ELSE IF @Refresh = 1
	BEGIN
		-- INSERT @RNTrial_Cache
		SELECT 	IH.ivh_hdrnumber
		,IH.ivh_deliverydate
		,[ItemID] = IsNull(Company.cmp_othertype1,'UNKNOWN')
		,[Count] = ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,IH.ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00)
		,Rev = ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,IH.ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00)
		INTO #temp1
		FROM invoiceheader IH (NOLOCK) Join Company (NOLOCK) on IH.ivh_billto = company.cmp_id
		WHERE IH.ivh_deliverydate BETWEEN @DateStart and @DateEnd
		--	AND ISNULL(dbo.fnc_TMWRN_XDRevenueInvoice(DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,IH.ivh_hdrnumber,'T',DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0.00) <> 0

		DELETE #temp1 WHERE ISNULL(Rev, 0) = 0
		
		INSERT @RNTrial_Cache 
		SELECT ivh_hdrnumber, ivh_deliverydate, ItemId, [Count] FROM #temp1

		SET ROWCOUNT @NumberOfValues

		INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription], [Count], [Percentage])  
		SELECT 	[LastUpdate] = GETDATE(),
				[DateStart] = @DateStart,
				[DateEnd] = @DateEnd,
				[ItemCategory] = @Mode,
				[ItemID] = RNTC.[ItemID],
				[ItemDescription] = (SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'OtherTypes1' and abbr = RNTC.[ItemID]),
				[Count] = SUM(RNTC.[Count]),
				[Percentage] = CONVERT(decimal(24, 5) , 100 * SUM([Count]) / CONVERT(decimal(20, 5), (SELECT SUM(RNTC1.[Count]) FROM @RNTrial_Cache RNTC1)))
		FROM @RNTrial_Cache RNTC 
		GROUP BY RNTC.[ItemID]
		ORDER BY SUM(RNTC.[Count]) DESC

		SET ROWCOUNT 0
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_IVH_OtherType1_R] TO [public]
GO
