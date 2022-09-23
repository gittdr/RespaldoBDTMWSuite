SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_Commodity]
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

/* Revision History
05/04/2009:	modified to consider only trips with ord_status AVL,PLN,DSP,STD,CMP

*/


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
		SELECT 	t1.cmd_code AS [Commodity Code],
			(SELECT t2.cmd_name FROM commodity t2 (NOLOCK) WHERE t1.cmd_code = t2.cmd_code) AS [Commodity],
			(SELECT ord_hdrnumber FROM Stops t3 (NOLOCK) WHERE t1.stp_number = t3.stp_number) AS [Order #],
			(SELECT stp_arrivaldate FROM Stops t3 (NOLOCK) WHERE t1.stp_number = t3.stp_number) AS [Arrival Date],
			t1.fgt_weight AS [Weight],
			t1.fgt_volume AS [Volume]
		FROM freightdetail t1 (NOLOCK) 
		WHERE 	t1.cmd_code = @ItemID
		AND t1.stp_number IN 
			(	SELECT stp_number 
				FROM stops (NOLOCK)
				WHERE stp_arrivaldate BETWEEN @DateStart AND @DateEnd
				AND Exists (	select *	
								from orderheader (nolock) 
								where stops.ord_hdrnumber = orderheader.ord_hdrnumber
								AND ord_status in ('AVL','PLN','DSP','STD','CMP')))
		END
		ELSE
		BEGIN
		SELECT 	t1.cmd_code AS [Commodity Code],
			(SELECT t2.cmd_name FROM commodity t2 (NOLOCK) WHERE t1.cmd_code = t2.cmd_code) AS [Commodity],
			(SELECT ord_hdrnumber FROM Stops t3 (NOLOCK) WHERE t1.stp_number = t3.stp_number) AS [Order #],
			(SELECT stp_arrivaldate FROM Stops t3 (NOLOCK) WHERE t1.stp_number = t3.stp_number) AS [Arrival Date],
			t1.fgt_weight AS [Weight],
			t1.fgt_volume AS [Volume]
		FROM freightdetail t1 (NOLOCK)
		WHERE 	t1.cmd_code NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
		AND 	IsNull(t1.cmd_code, 'UNKNOWN') <> 'UNKNOWN'
		AND t1.stp_number IN 
			(	SELECT stp_number 
				FROM stops (NOLOCK)
				WHERE stp_arrivaldate BETWEEN @DateStart AND @DateEnd
				AND Exists (	select *	
								from orderheader (nolock) 
								where stops.ord_hdrnumber = orderheader.ord_hdrnumber
								AND ord_status in ('AVL','PLN','DSP','STD','CMP')))
		ORDER BY t1.cmd_code 
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
				[ItemID] = t1.cmd_code,
				[ItemDescription] = t2.cmd_name,
				[Count] = COUNT(*), 
				[Percentage] = CONVERT(decimal(24, 5) , 100 * COUNT(*) / CONVERT(decimal(20, 5), (SELECT COUNT(*) FROM freightdetail f1 (NOLOCK) 
								WHERE IsNull(f1.cmd_code, 'UNKNOWN') <> 'UNKNOWN' AND f1.stp_number IN (SELECT stp_number FROM stops (NOLOCK) WHERE stp_arrivaldate BETWEEN @DateStart and @DateEnd))))
	FROM freightdetail t1 (NOLOCK), commodity t2 (NOLOCK)
	WHERE t1.cmd_code = t2.cmd_code
	AND IsNull(t1.cmd_code, 'UNKNOWN') <> 'UNKNOWN'
	AND t1.stp_number IN 
		(	SELECT stp_number 
			FROM stops (NOLOCK)
			WHERE stp_arrivaldate BETWEEN @DateStart AND @DateEnd
			AND Exists (	select *	
							from orderheader (nolock) 
							where stops.ord_hdrnumber = orderheader.ord_hdrnumber
							AND ord_status in ('AVL','PLN','DSP','STD','CMP')))
	GROUP BY t1.cmd_code, t2.cmd_name
	ORDER BY COUNT(*) DESC
	SET ROWCOUNT 0
	END

GO
GRANT EXECUTE ON  [dbo].[ResNowOV_Commodity] TO [public]
GO
