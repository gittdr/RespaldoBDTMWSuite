SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_R1_OtherType2]
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
02/23/2011: modified to filter by RevType1
*/

	SET @Parameters= ',' + ISNULL(@Parameters,'') + ','

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
		SELECT 	cmp_othertype2 AS [OtherType2 Abbr], 
			(SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'OtherTypes2' and abbr = cmp_othertype2) AS [Other Type 2],
			ord_hdrnumber AS [Order #],
			Ord_CompletionDate [Completion Date],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_originpoint) AS [Origin],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_destpoint) AS [Destination],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_company) AS [Ordered By],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_BillTo) AS [Bill To],
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue,
			IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0) as TotalMiles,
			IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0) as EmptyMiles
		FROM orderheader (NOLOCK) Join Company (NOLOCK) on cmp_id = ord_billto
		WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND cmp_othertype2 = @ItemID
			AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
		END
		ELSE
		BEGIN
		SELECT 	cmp_othertype2 AS [OtherType2 Abbr], 
			(SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'OtherTypes2' and abbr = cmp_othertype2) AS [Other Type 2],
			ord_hdrnumber AS [Order #],
			Ord_CompletionDate [Completion Date],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_originpoint) AS [Origin],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_destpoint) AS [Destination],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_company) AS [Ordered By],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_BillTo) AS [Bill To],
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue,
			IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0) as TotalMiles,
			IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0) as EmptyMiles
		FROM orderheader (NOLOCK) Join Company (NOLOCK) on cmp_id = ord_billto
		WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND cmp_othertype2 NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
			ORDER BY cmp_othertype2 
		END
	END
	ELSE IF @Refresh = 1
	BEGIN
		SET ROWCOUNT @NumberOfValues
			INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage])
		SELECT 		[LastUpdate] = GETDATE(),
				[DateStart] = @DateStart,
				[DateEnd] = @DateEnd,
				[ItemCategory] = @Mode,
				[ItemID] = cmp_othertype2, 
				[ItemDescription] = (SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'OtherTypes2' and abbr = cmp_othertype2),
				[Count] = COUNT(*),
				[Percentage] = CONVERT(decimal(24,5) , 100 * COUNT(*) / 
					CONVERT(decimal(20, 5),	(	SELECT COUNT(*) 
												FROM orderheader (NOLOCK) 
												WHERE ord_completiondate BETWEEN @DateStart and @DateEnd 
												AND ord_status in ('AVL','PLN','DSP','STD','CMP')
												AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
											)))
		FROM orderheader (NOLOCK) Join Company (NOLOCK) on cmp_id = ord_billto
			WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
			GROUP BY cmp_othertype2
			ORDER BY COUNT(*) DESC
		SET ROWCOUNT 0
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_R1_OtherType2] TO [public]
GO
