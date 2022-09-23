SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_R1_Revenue_Class_2]
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
		SELECT 	ord_RevType2 AS [RevClass Abbr], 
			(SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'RevType2' and abbr = ord_RevType2) AS [Revenue Class],
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
		FROM orderheader (NOLOCK) 
		WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND ord_RevType2 = @ItemID
			AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)

		END
		ELSE
		BEGIN
		SELECT 	ord_RevType2 AS [RevClass Abbr], 
			(SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'RevType2' and abbr = ord_RevType2) AS [Revenue Class],
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
		FROM orderheader (NOLOCK) 
		WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND ord_RevType2 NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
			ORDER BY ord_RevType2 
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
				[ItemID] = ord_RevType2, 
				[ItemDescription] = (SELECT name FROM labelfile (NOLOCK) where labeldefinition = 'RevType2' and abbr = ord_RevType2),
				[Count] = COUNT(*),
				[Percentage] = CONVERT(decimal(24,5) , 100 * COUNT(*) / 
					CONVERT(decimal(20, 5),	(	SELECT COUNT(*) 
												FROM orderheader (NOLOCK) 
												WHERE ord_completiondate BETWEEN @DateStart and @DateEnd 
												AND ord_status in ('AVL','PLN','DSP','STD','CMP')
												AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
											)))
			FROM orderheader (NOLOCK) 
			WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
			GROUP BY ord_RevType2 
			ORDER BY COUNT(*) DESC
		SET ROWCOUNT 0
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_R1_Revenue_Class_2] TO [public]
GO
