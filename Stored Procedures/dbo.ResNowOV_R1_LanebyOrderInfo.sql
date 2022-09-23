SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_R1_LanebyOrderInfo]
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

Declare @StateOnly as varchar(1) 
set @StateOnly = 'N'

	IF IsNull(@NumberOfValues,0) = 0
		BEGIN
			IF IsNull(@ItemID, '') > ''
				BEGIN
					SELECT 	(dbo.fnc_zip3(ord_origin_zip, ord_originstate, ord_origincity, @StateOnly) + dbo.fnc_zip3(ord_dest_zip, ord_deststate, ord_destcity, @StateOnly)) AS [Lane],
						ord_hdrnumber AS [Order #],
						Ord_CompletionDate [Completion Date],
						(c1.cmp_name + ' - ' + c1.cty_nmstct) AS [Origin],
						(c2.cmp_name + ' - ' + c2.cty_nmstct) AS [Destination],
						(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_company) AS [Ordered By],
						(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_BillTo) AS [Bill To],
						IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
						IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue,
						IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0) as TotalMiles,
						IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0) as EmptyMiles

					FROM orderheader (NOLOCK) JOIN company c1 (NOLOCK) on c1.cmp_id = ord_originpoint
								  JOIN company c2 (NOLOCK) on c2.cmp_id = ord_destpoint
					WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
					AND ord_status in ('AVL','PLN','DSP','STD','CMP')
					AND dbo.fnc_zip3(ord_origin_zip, ord_originstate, ord_origincity, @StateOnly) + dbo.fnc_zip3(ord_dest_zip, ord_deststate, ord_destcity, @StateOnly) = @ItemID
					AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
				END
			ELSE
				BEGIN
					SELECT 	dbo.fnc_zip3(ord_origin_zip, ord_originstate, ord_origincity, @StateOnly) + dbo.fnc_zip3(ord_dest_zip, ord_deststate, ord_destcity, @StateOnly) AS [Lane],
						ord_hdrnumber AS [Order #],
						Ord_CompletionDate [Completion Date],
						(c1.cmp_name + ' - ' + c1.cty_nmstct) AS [Origin],
						(c2.cmp_name + ' - ' + c2.cty_nmstct) AS [Destination],
						(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_company) AS [Ordered By],
						(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = ord_BillTo) AS [Bill To],
						IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
						IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue,
						IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0) as TotalMiles,
						IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0) as EmptyMiles

					FROM orderheader (NOLOCK) JOIN company c1 (NOLOCK) on c1.cmp_id = ord_originpoint
								  JOIN company c2 (NOLOCK) on c2.cmp_id = ord_destpoint
					WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
					AND ord_status in ('AVL','PLN','DSP','STD','CMP')
					AND dbo.fnc_zip3(ord_origin_zip, ord_originstate, ord_origincity, @StateOnly) + dbo.fnc_zip3(ord_dest_zip, ord_deststate, ord_destcity, @StateOnly)
						NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
					AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)
					ORDER BY dbo.fnc_zip3(ord_origin_zip, ord_originstate, ord_origincity, @StateOnly) + dbo.fnc_zip3(ord_dest_zip, ord_deststate, ord_destcity, @StateOnly)
				END
		END
	ELSE IF @Refresh = 1
		BEGIN -- Use two step process to get lane information to reduce overhead
			SELECT 	ord_number,
					[ItemID] = dbo.fnc_zip3(ord_origin_zip, ord_originstate, ord_origincity, @StateOnly) + dbo.fnc_zip3(ord_dest_zip, ord_deststate, ord_destcity, @StateOnly)
			INTO #RNTrial_Cache_Lanes 
			FROM orderheader (NOLOCK) 
			WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND (@Parameters =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @Parameters) > 0)

			SET ROWCOUNT @NumberOfValues

			INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage])
			SELECT 		
					GETDATE(),
					[DateStart] = @DateStart,
					[DateEnd] = @DateEnd,
					[ItemCategory] = @Mode,
					[ItemID] = #RNTrial_Cache_Lanes.[ItemID],
					[ItemDescription] = IsNull((SELECT TOP 1 State + '-' FROM ResNowZip3Translation (NOLOCK) WHERE PID = LEFT(#RNTrial_Cache_Lanes.[ItemID],3)), '') + LEFT(#RNTrial_Cache_Lanes.[ItemID],3) + ' to ' + IsNull((SELECT TOP 1 State + '-' FROM ResNowZip3Translation (NOLOCK) 
										WHERE PID = RIGHT(#RNTrial_Cache_Lanes.[ItemID],3)), '') +  RIGHT(#RNTrial_Cache_Lanes.[ItemID],3),
					[Count] = COUNT(*),
					[Percentage] = CONVERT(decimal(24, 5) , 100 * COUNT(*) / CONVERT(decimal(20, 5), (SELECT COUNT(*) FROM #RNTrial_Cache_Lanes (NOLOCK) WHERE LEFT(#RNTrial_Cache_Lanes.[ItemID], 3) <> 'UNK' AND RIGHT(#RNTrial_Cache_Lanes.[ItemID], 3) <> 'UNK')))
			FROM #RNTrial_Cache_Lanes (NOLOCK) 
			WHERE LEFT(#RNTrial_Cache_Lanes.[ItemID], 3) <> 'UNK'
			AND RIGHT(#RNTrial_Cache_Lanes.[ItemID], 3) <> 'UNK'
			GROUP BY #RNTrial_Cache_Lanes.[ItemID]
			ORDER BY COUNT(*) DESC

			SET ROWCOUNT 0
		END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_R1_LanebyOrderInfo] TO [public]
GO
