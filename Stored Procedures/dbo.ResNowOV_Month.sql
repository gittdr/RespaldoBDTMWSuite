SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ResNowOV_Month]
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
 	Declare @RNTrial_Cache TABLE
	(unique_number int,
	 unique_date  datetime,
	 [ItemID] [varchar] (50),
	 [Count] Money
	)   


	IF IsNull(@NumberOfValues,0) = 0
	BEGIN
		IF IsNull(@ItemID, '') > ''
		BEGIN
		SELECT 	DATENAME(m , ivh_deliverydate ) AS [Month], 
			ord_hdrnumber AS [Order #],
			ivh_deliverydate [Delivery Date],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_originpoint) AS [Origin],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_destpoint) AS [Destination],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_BillTo) AS [Bill To],
			CONVERT(MONEY,ISNULL(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT),0)) as TotalCharge,
			CONVERT(MONEY,ISNULL(dbo.fnc_CONVERTcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT),0)) as LineHaulRevenue
		FROM Invoiceheader (NOLOCK) 
		WHERE ivh_deliverydate BETWEEN @DateStart and @DateEnd
		AND DATEPART(m, ivh_deliverydate) = @ItemID
		END
		ELSE
		BEGIN
		SELECT 	DATENAME(m , ivh_deliverydate ) AS [Month], 
			ord_hdrnumber AS [Order #],
			ivh_deliverydate [Delivery Date],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_originpoint) AS [Origin],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_destpoint) AS [Destination],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_BillTo) AS [Bill To],
			CONVERT(MONEY,ISNULL(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT),0)) as TotalCharge,
			CONVERT(MONEY,ISNULL(dbo.fnc_CONVERTcharge(ivh_charge,ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,DEFAULT,ivh_printdate,DEFAULT,DEFAULT,DEFAULT),0)) as LineHaulRevenue
		FROM Invoiceheader (NOLOCK) 
		WHERE ivh_deliverydate BETWEEN @DateStart and @DateEnd
			AND DATEPART(m, ivh_deliverydate) NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			ORDER BY DATENAME(m , ivh_deliverydate)
		END
	END
	ELSE IF @Refresh = 1
	BEGIN
		INSERT @RNTrial_Cache 
		SELECT 	ord_hdrnumber,
				ivh_deliverydate, 
				[ItemID] = DATEPART(m, ivh_deliverydate),
				[Count] = IsNull(convert(money,IsNull(dbo.fnc_convertcharge(ivh_totalcharge,ivh_currency,'Revenue',InvoiceHeader.ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0.00)),0.00)
			FROM InvoiceHeader (NOLOCK) 
			WHERE ivh_deliverydate BETWEEN @DateStart and @DateEnd
		SET ROWCOUNT @NumberOfValues
		INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage])
		SELECT 	[LastUpdate] = GETDATE(),
				[DateStart] = @DateStart,
				[DateEnd] = @DateEnd,
				[ItemCategory] = @Mode,
				[ItemID] = RNTC.[ItemID],
				[ItemDescription] = MIN(DATENAME(m , unique_date)),
				[Count] = SUM(RNTC.[Count]),
				[Percentage] = CONVERT(decimal(24, 5) , 100 * SUM([Count]) / CONVERT(decimal(20, 5), (SELECT SUM(RNTC1.[Count]) FROM @RNTrial_Cache RNTC1)))
		FROM @RNTrial_Cache RNTC 
		GROUP BY RNTC.[ItemID]
		ORDER BY CONVERT(INT, RNTC.[ItemID])
		SET ROWCOUNT 0
	END



GO
GRANT EXECUTE ON  [dbo].[ResNowOV_Month] TO [public]
GO
