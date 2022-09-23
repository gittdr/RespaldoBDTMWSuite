SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ResNowOV_Revenue]
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
			SELECT 	ivh_hdrnumber AS [Invoice Number],
				InvoiceHeader.ord_hdrnumber AS [Order Number],
				ISNULL(CASE WHEN @ItemID = 'LineHaul' THEN 
				(SELECT dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'Y', 'N', 'N', DEFAULT, DEFAULT, DEFAULT, DEFAULT))
					WHEN @ItemID = 'Accessorial' THEN
				(SELECT dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'N', 'Y', 'N', DEFAULT, DEFAULT, DEFAULT, DEFAULT))
					ELSE -- ChargeTypes
				(SELECT dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'N', 'N', 'Y', DEFAULT, DEFAULT, DEFAULT, DEFAULT))
					END, 0) AS [Invoice Revenue],
				ivh_deliverydate as [Delivery Date],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_originpoint) AS [Origin],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_destpoint) AS [Destination],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_company) AS [Ordered By],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ivh_billto) AS [Bill To],
				ivh_totalmiles AS [Total Miles]
			FROM   	InvoiceHeader (NOLOCK)
			WHERE 	ivh_deliverydate BETWEEN @DateStart AND @DateEnd
			AND 	ISNULL(CASE WHEN @ItemID = 'LineHaul' THEN 
				(SELECT dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'Y', 'N', 'N', DEFAULT, DEFAULT, DEFAULT, DEFAULT))
					WHEN @ItemID = 'Accessorial' THEN
				(SELECT dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'N', 'Y', 'N', DEFAULT, DEFAULT, DEFAULT, DEFAULT))
					END, 0) > 0
			END -- Other not used since revenue is either 'LineHaul' 'Accessorial' or 'ChargeTypes'
			ELSE
			BEGIN
				SELECT 'Other is not applicable to Revenue'
			END
		END
		ELSE IF @Refresh = 1
		BEGIN
			DECLARE	@TotalRevenue Money 
			DECLARE	@TotalLineHaul Money 
			DECLARE	@TotalAccessorial Money 
			SET @TotalRevenue = IsNull((SELECT SUM(dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'N', 'N', 'N', DEFAULT, DEFAULT, DEFAULT, DEFAULT)) FROM InvoiceHeader (NOLOCK) 
										WHERE ivh_deliverydate BETWEEN @DateStart AND @DateEnd),0)
			SET @TotalLineHaul = IsNull((SELECT SUM(dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'Y', 'N', 'N', DEFAULT, DEFAULT, DEFAULT, DEFAULT)) FROM InvoiceHeader (NOLOCK) 
										WHERE ivh_deliverydate BETWEEN @DateStart AND @DateEnd),0)
			SET @TotalAccessorial = IsNull((SELECT SUM(dbo.fnc_TMWRN_Revenue('Invoice', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, ivh_hdrnumber, NULL, NULL, 'N', 'Y', 'N', DEFAULT, DEFAULT, DEFAULT, DEFAULT)) FROM InvoiceHeader (NOLOCK) 
										WHERE ivh_deliverydate BETWEEN @DateStart AND @DateEnd),0)
			IF @NumberOfValues > 0 AND @TotalRevenue > 0
			INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage])
			SELECT		[LastUpdate] = GETDATE(),
					[DateStart] = @DateStart,
					[DateEnd] = @DateEnd,
					[ItemCategory] = @Mode,
					[ItemID] = 'LineHaul',
					[ItemDescription] = 'Line Haul Revenue',
					[Count] = @TotalLineHaul, 
					[Percentage] = IsNull(CONVERT(decimal(20,1), 100 * @TotalLineHaul) / CONVERT(decimal(20, 5), @TotalRevenue),0)
			IF @NumberOfValues > 1 AND @TotalRevenue > 0
			INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage])
			SELECT 		[LastUpdate] = GETDATE(),
					[DateStart] = @DateStart,
					[DateEnd] = @DateEnd,
					[ItemCategory] = @Mode,
					[ItemID] = 'Accessorial',
					[ItemDescription] = 'Accessorial Revenue',
					[Count] = @TotalAccessorial, 
					[Percentage] = IsNull(CONVERT(decimal(20,1), 100 * @TotalAccessorial) / CONVERT(decimal(20, 5), @TotalRevenue),0)

		END


GO
GRANT EXECUTE ON  [dbo].[ResNowOV_Revenue] TO [public]
GO
