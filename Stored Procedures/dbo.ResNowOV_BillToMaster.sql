SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_BillToMaster]
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
		SELECT c1.cmp_mastercompany AS [Master ID],
			ord_billto AS [BillTo ID],
			MIN(c1.cmp_name + ' - ' + c1.cty_nmstct) AS [Bill To],
			SUM(1) AS [Total Orders],
			SUM(IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0)) as TotalCharge,
			SUM(IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0)) as LineHaulRevenue,
			SUM(IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0)) as TotalMiles,
			SUM(IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0)) as EmptyMiles
		FROM orderheader (NOLOCK) join company c1 (nolock) on ord_billto = c1.cmp_id
		WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND IsNull(c1.cmp_mastercompany,'UNKNOWN') = @ItemID
		GROUP BY c1.cmp_mastercompany, ord_billto
		ORDER BY SUM(1) DESC
		END
		ELSE
		BEGIN
		SELECT c1.cmp_mastercompany AS [Master ID],
		 	ord_billto AS [BillTo ID],
			MIN(c1.cmp_name + ' - ' + c1.cty_nmstct) AS [Bill To],
			SUM(1) AS [Total Orders],
			SUM(IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'','','','','','',''),0)) as TotalCharge,
			SUM(IsNull(dbo.fnc_TMWRN_Revenue('Order',Null,Null,Null,ord_hdrnumber,Null,Null,Null,Null,'Y','','','','','',''),0)) as LineHaulRevenue,
			SUM(IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,default,default,default,default),0)) as TotalMiles,
			SUM(IsNull(dbo.fnc_TMWRN_Miles('Order','Travel','Miles',default,ord_hdrnumber,default,default,'MT',default,default,default),0)) as EmptyMiles
		FROM orderheader (NOLOCK) join company c1 (nolock) on ord_billto = c1.cmp_id
		WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			AND IsNull(c1.cmp_mastercompany,'UNKNOWN') NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
		GROUP BY c1.cmp_mastercompany, ord_billto 
			ORDER BY SUM(1) DESC

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
				[ItemID] = IsNull(cmp_mastercompany,'UNKNOWN'),
				[ItemDescription] = (SELECT cmp_name + ' - ' + cty_nmstct FROM company c2 (NOLOCK) where c2.cmp_id = IsNull(c1.cmp_mastercompany,'UNKNOWN')),
				[Count] = COUNT(*),
				[Percentage] = CONVERT(decimal(24, 5), 100 * COUNT(*) / CONVERT(decimal(20, 5), (SELECT COUNT(*) FROM orderheader (NOLOCK) WHERE ord_completiondate BETWEEN @DateStart and @DateEnd AND ord_status in ('AVL','PLN','DSP','STD','CMP'))))
			FROM orderheader (NOLOCK) JOIN company c1 (NOLOCK) on c1.cmp_id = ord_billto
			WHERE ord_completiondate BETWEEN @DateStart and @DateEnd
			AND ord_status in ('AVL','PLN','DSP','STD','CMP')
			GROUP BY IsNull(cmp_mastercompany,'UNKNOWN')
			ORDER BY COUNT(*) DESC		
		SET ROWCOUNT 0
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_BillToMaster] TO [public]
GO
