SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_OriginZip3]
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

	Declare @StateOnly	as varchar(1)
	SET @StateOnly	= 'N'
	IF IsNull(@NumberOfValues,0) = 0
	BEGIN
		IF IsNull(@ItemID, '') > ''
		BEGIN	SELECT 
				dbo.fnc_zip3(c1.cmp_zip, c1.cmp_state, c1.cmp_city, @StateOnly) AS [Zip3Origin],
				ord_originpoint AS [Origin Code], 
				c1.cmp_name + ' - ' + c1.cty_nmstct AS [Origin],
				ord_hdrnumber AS [Order #],
				Ord_CompletionDate [Completion Date],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_destpoint) AS [Destination],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_company) AS [Ordered By],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_BillTo) AS [Bill To],
				IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
				IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue,
				IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0) as TotalMiles,
				IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0) as EmptyMiles
			FROM orderheader (NOLOCK) JOIN company c1 (NOLOCK) on c1.cmp_id = ord_originpoint
			WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
				AND ord_status in ('AVL','PLN','DSP','STD','CMP')
				AND dbo.fnc_zip3(c1.cmp_zip, c1.cmp_state, c1.cmp_city, @StateOnly) = @ItemID
		END
		ELSE
		BEGIN
			SELECT
				dbo.fnc_zip3(c1.cmp_zip, c1.cmp_state, c1.cmp_city, @StateOnly) AS [Zip3Origin],
				ord_originpoint AS [Origin Code], 
				c1.cmp_name + ' - ' + c1.cty_nmstct AS [Origin],
				ord_hdrnumber AS [Order #],
				Ord_CompletionDate [Completion Date],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_destpoint) AS [Destination],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_company) AS [Ordered By],
				(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_BillTo) AS [Bill To],
				IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
				IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue,
				IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0) as TotalMiles,
				IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0) as EmptyMiles
			FROM orderheader (NOLOCK) JOIN company c1 (NOLOCK) on c1.cmp_id = ord_originpoint
			WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
				AND ord_status in ('AVL','PLN','DSP','STD','CMP')
				AND dbo.fnc_zip3(c1.cmp_zip, c1.cmp_state, c1.cmp_city, @StateOnly) NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			ORDER BY dbo.fnc_zip3(c1.cmp_zip, c1.cmp_state, c1.cmp_city, @StateOnly) 
		END
	END
	ELSE IF @Refresh = 1
	BEGIN
		SELECT 	ord_number,
				[ItemID] = dbo.fnc_zip3(c1.cmp_zip, c1.cmp_state, c1.cmp_city, @StateOnly)
		INTO #RNTrial_Cache_OriginZip3 
		FROM orderheader (NOLOCK) JOIN company c1 (NOLOCK) on c1.cmp_id = ord_originpoint
		WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
		AND ord_status in ('AVL','PLN','DSP','STD','CMP')

		SET ROWCOUNT @NumberOfValues
		INSERT RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage])
		SELECT 	[LastUpdate] = GETDATE(),
				[DateStart] = @DateStart,
				[DateEnd] = @DateEnd,
				[ItemCategory] = @Mode,
				[ItemID] = #RNTrial_Cache_OriginZip3.[ItemID],
				[ItemDescription] = IsNull((SELECT TOP 1 State + '-' FROM ResNowZip3Translation (NOLOCK) WHERE PID = #RNTrial_Cache_OriginZip3.[ItemID]), '') + #RNTrial_Cache_OriginZip3.[ItemID],
				[Count] = COUNT(*),
				[Percentage] = CONVERT(decimal(24, 5) , 100 * COUNT(*) / CONVERT(decimal(20, 5), (SELECT COUNT(*) FROM orderheader (NOLOCK) WHERE ord_completiondate BETWEEN @DateStart and @DateEnd AND ord_status in ('AVL','PLN','DSP','STD','CMP'))))
		FROM #RNTrial_Cache_OriginZip3 (NOLOCK) 
		GROUP BY #RNTrial_Cache_OriginZip3.[ItemID]
			ORDER BY COUNT(*) DESC		
		SET ROWCOUNT 0
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_OriginZip3] TO [public]
GO
