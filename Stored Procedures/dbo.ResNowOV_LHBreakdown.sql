SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/* PARAMETER LIST. ONLY CHANGE NAME OF STORED PROCEDURE */
CREATE PROCEDURE [dbo].[ResNowOV_LHBreakdown]
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
	/* GENERIC MEMORY TABLE LEAVE AS IS*/
 	Declare @RNTrial_Cache TABLE
	(unique_number int,
	 unique_date  datetime,
	 [ItemID] [varchar] (50),
	 [Count] Money
	)   

		IF IsNull(@NumberOfValues,0) = 0
/* START DETAIL SECTION */
		BEGIN
			IF IsNull(@ItemID, '') > '' 
			BEGIN
	/* START EXISTING SLICE */
			/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH OTHER SLICE QUERY BELOW */
			SELECT
					IVH.ivh_invoicenumber,
					IVD.cht_itemcode,
					ISNULL(dbo.fnc_CONVERTcharge(ivd_charge,IVH.ivh_currency,'Revenue',IVD.ivh_hdrnumber,ivd_currencydate,IVH.ivh_shipdate,IVH.ivh_deliverydate,IVH.ivh_billdate, IVH.ivh_revenue_date,IVH.ivh_xferdate, DEFAULT,IVH.ivh_printdate, DEFAULT,DEFAULT,DEFAULT),0) as [Accessorial Charge]
			FROM InvoiceDetail IVD (NOLOCK) JOIN invoiceheader IVH (NOLOCK) ON IVD.ivh_hdrnumber = IVH.ivh_hdrnumber
			/* DATE RANGE CONDITION CHANGE FIELD NAME (ivh_billdate) WHERE APPROPRIATE */
			WHERE 	ivh_billdate BETWEEN @DateStart AND @DateEnd
		/* CONDITION OF EXISTING SLICE. ONLY CHANGE FIELD NAME (IVD.cht_itemcode) BELOW WHERE APPROPRIATE */
			AND 	@ItemID = IVD.cht_itemcode
	/* END EXISTING SLICE */
			END 
			ELSE
			BEGIN
	/* START OTHER SLICE */
			/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH EXISTING SLICE QUERY ABOVE */
			SELECT
					IVH.ivh_invoicenumber,
					IVD.cht_itemcode,
					ISNULL(dbo.fnc_CONVERTcharge(ivd_charge,IVH.ivh_currency,'Revenue',IVD.ivh_hdrnumber,ivd_currencydate,IVH.ivh_shipdate,IVH.ivh_deliverydate,IVH.ivh_billdate, IVH.ivh_revenue_date,IVH.ivh_xferdate, DEFAULT,IVH.ivh_printdate, DEFAULT,DEFAULT,DEFAULT),0) as [Accessorial Charge]
			FROM InvoiceDetail IVD (NOLOCK) JOIN invoiceheader IVH (NOLOCK) ON IVD.ivh_hdrnumber = IVH.ivh_hdrnumber
			/* DATE RANGE CONDITION CHANGE FIELD NAME (ivh_billdate) WHERE APPROPRIATE */
			WHERE 	ivh_billdate BETWEEN @DateStart AND @DateEnd
			/* CONDITION OF OTHER SLICE. ONLY CHANGE FIRST FIELD NAME (IVD.cht_itemcode) BELOW WHERE APPROPRIATE */
			AND IVD.cht_itemcode NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			/* ORDER BY CLAUSE CHANGE FIELD NAME WHERE APPROPRIATE */
			ORDER BY IVD.cht_itemcode 
	/* END OTHER SLICE */
			END
/* END DETAIL SECTION */
		END
		ELSE IF @Refresh = 1
		BEGIN
/* START UPDATE CACHE SECTION */
		/* POPULATE MEMORY TABLE */
		INSERT @RNTrial_Cache
		SELECT 	ivd_number, -- field not critical, record id for debugging purposes
				ivh_billdate, -- field not critical, date for debugging purposes
				[ItemID] = ivd.cht_itemcode, -- Use same field as above that indicates the slice of pie
				/* COUNT IS HOW THE VALUE OF THE SLICE IS MEASURED. HERE IT IS REVENUE */
				[Count] = ISNULL(dbo.fnc_CONVERTcharge(ivd_charge,IVH.ivh_currency,'Revenue',IVD.ivh_hdrnumber,ivd_currencydate,IVH.ivh_shipdate,IVH.ivh_deliverydate,IVH.ivh_billdate, IVH.ivh_revenue_date,IVH.ivh_xferdate, DEFAULT,IVH.ivh_printdate, DEFAULT,DEFAULT,DEFAULT),0) 
			/* FROM AND DATE CLAUSE SHOULD MATCH ABOVE */
			FROM   	InvoiceDetail ivd (NOLOCK) 	Join InvoiceHeader ivh (NOLOCK) on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber 
												join chargetype c on ivd.cht_itemcode = c.cht_itemcode and c.cht_basis='shp'
			WHERE 	ivh_billdate BETWEEN @DateStart AND @DateEnd
		/* BELOW IS BOILER PLATE */	
		SET ROWCOUNT @NumberOfValues
		/* BELOW IS BOILER PLATE EXCEPT FOR Item Description */
		INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription], [Count], [Percentage])  
		SELECT 	[LastUpdate] = GETDATE(),
				[DateStart] = @DateStart,
				[DateEnd] = @DateEnd,
				[ItemCategory] = @Mode,
				[ItemID] = RNTC.[ItemID],
                /* Item description is specific to mode */
				[ItemDescription] = (SELECT cht_description FROM chargetype (NOLOCK) where chargetype.cht_itemcode = RNTC.[ItemID]),
                /* Item description is specific to mode */
				[Count] = SUM(RNTC.[Count]),
				[Percentage] = CONVERT(decimal(24, 5) , 100 * SUM([Count]) / CONVERT(decimal(20, 5), (SELECT SUM(RNTC1.[Count]) FROM @RNTrial_Cache RNTC1)))
		FROM @RNTrial_Cache RNTC 
		GROUP BY RNTC.[ItemID]
		ORDER BY SUM(RNTC.[Count]) DESC
		SET ROWCOUNT 0
/* END UPDATE CACHE SECTION */
		END
GO
GRANT EXECUTE ON  [dbo].[ResNowOV_LHBreakdown] TO [public]
GO
