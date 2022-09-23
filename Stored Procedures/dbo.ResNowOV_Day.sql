SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_Day]
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
	(unique_number int,
	 unique_date  datetime,
	 [ItemID] [varchar] (50),
	 [Count] Money
	)   

	IF IsNull(@NumberOfValues,0) = 0
	BEGIN
		IF IsNull(@ItemID, '') > ''
		BEGIN
		SELECT 	DATENAME(dw , lgh_enddate) AS [Day of Week], 
			L.lgh_number AS [Leg #],
			lgh_enddate [Completion Date],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = cmp_id_start) AS [Origin],      
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = cmp_id_end) AS [Destination],
			IsNull((		select sum(IsNull(stp_lgh_mileage,0)) 
							from stops (NOLOCK) 
							where stops.lgh_number = L.lgh_number
						),0) as TotalMiles,
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,L.ord_hdrnumber,L.lgh_number,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,L.ord_hdrnumber,L.lgh_number,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue
		FROM Legheader L (NOLOCK)
		WHERE lgh_enddate BETWEEN @DateStart and @DateEnd
			AND	(
					IsNull(L.ord_hdrnumber,0) = 0
						OR
					Exists (	select *
								from orderheader (nolock)
								where L.ord_hdrnumber = orderheader.ord_hdrnumber
								AND orderheader.ord_status in ('AVL','PLN','DSP','STD','CMP'))
				)
			AND DATEPART(dw, lgh_enddate) = @ItemID
		END
		ELSE
		BEGIN
		SELECT 	DATENAME(dw , lgh_enddate) AS [Day of Week], 
			L.lgh_number AS [Leg #],
			lgh_enddate [Completion Date],
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = cmp_id_start) AS [Origin],      
			(SELECT cmp_name + ' - ' + cty_nmstct FROM company (NOLOCK) where cmp_id = cmp_id_end) AS [Destination],
			IsNull((	select sum(IsNull(stp_lgh_mileage,0)) 
							from stops (NOLOCK) 
							where stops.lgh_number = L.lgh_number
						),0) as TotalMiles,
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,L.ord_hdrnumber,L.lgh_number,Null,Null,Null,'','','','','','',''),0) as TotalCharge,
			IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,L.ord_hdrnumber,L.lgh_number,Null,Null,Null,'Y','','','','','',''),0) as LineHaulRevenue
		FROM Legheader L (NOLOCK) 
		WHERE lgh_enddate BETWEEN @DateStart and @DateEnd
			AND	(
					IsNull(L.ord_hdrnumber,0) = 0
						OR
					Exists (	select *
								from orderheader (nolock)
								where L.ord_hdrnumber = orderheader.ord_hdrnumber
								AND orderheader.ord_status in ('AVL','PLN','DSP','STD','CMP'))
				)
			AND DATEPART(dw, lgh_enddate) NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			ORDER BY DATENAME(dw , lgh_enddate)
		END
	END
	ELSE IF @Refresh = 1
	BEGIN
		SELECT 	lgh_number,
				lgh_enddate,
				[ItemID] = DATEPART(dw, lgh_enddate),
				[Count] = (select sum(IsNull(stp_lgh_mileage,0)) from stops (NOLOCK) where stops.lgh_number = L.lgh_number)
		INTO #RNTrial_Cache_Days
			FROM LegHeader L (NOLOCK) 
			WHERE lgh_enddate BETWEEN @DateStart and @DateEnd
			AND	(
					IsNull(L.ord_hdrnumber,0) = 0
						OR
					Exists (	select *
								from orderheader (nolock)
								where L.ord_hdrnumber = orderheader.ord_hdrnumber
								AND orderheader.ord_status in ('AVL','PLN','DSP','STD','CMP'))
				)
				
		DELETE #RNTrial_Cache_Days WHERE [COUNT] = 0
		
		SET ROWCOUNT @NumberOfValues
		INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],[ItemID],[ItemDescription],[Count],[Percentage])
		SELECT 		[LastUpdate] = GETDATE(),
				[DateStart] = @DateStart,
				[DateEnd] = @DateEnd,
				[ItemCategory] = @Mode,
				[ItemID] = #RNTrial_Cache_Days.[ItemID],
				[ItemDescription] = MIN(DATENAME(dw , lgh_enddate)),
				[Count] = SUM(#RNTrial_Cache_Days.[Count]),
				[Percentage] = CONVERT(decimal(24, 5) , 100 * SUM(#RNTrial_Cache_Days.[Count]) / CONVERT(decimal(20, 5), (SELECT SUM(#RNTrial_Cache_Days.[Count]) FROM #RNTrial_Cache_Days (NOLOCK))))
		FROM #RNTrial_Cache_Days (NOLOCK) 
		GROUP BY #RNTrial_Cache_Days.[ItemID]
		ORDER BY #RNTrial_Cache_Days.[ItemID]
		SET ROWCOUNT 0
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_Day] TO [public]
GO
