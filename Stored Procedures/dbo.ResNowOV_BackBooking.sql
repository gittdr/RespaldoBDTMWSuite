SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[ResNowOV_BackBooking]
/* PARAMETER LIST. ONLY CHANGE NAME OF STORED PROCEDURE */
(
	@NumberOfValues int, -- when = 0 flags for ShowDetail
	-- ** ItemID determines how the pie pieces are defined **
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

	/* GENERIC MEMORY TABLE LEAVE AS IS*/
 	Declare @RNTrial_Cache TABLE
	(unique_number int,
	 unique_date  datetime,
	 [ItemID] [varchar] (50),
	 [Count] Money
	)   

		IF IsNull(@NumberOfValues,0) = 0  -- If TRUE, Show the Details
/* START DETAIL SECTION */
		BEGIN
			IF IsNull(@ItemID, '') > ''   -- If ItemID GREATER THAN (i.e., NOT) Blank, Process Top N Pie Piece(s)
			BEGIN
	/* START EXISTING SLICE */
			/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH OTHER SLICE QUERY BELOW */
			SELECT 
				Ord_hdrnumber as OrderNumber
				,ord_bookedby as BookingAssociate
				,ord_bookdate as BookingDate
				,ord_startdate as StartDate
			FROM orderheader (NOLOCK)
			/* DATE RANGE CONDITION CHANGE FIELD NAME (lgh_enddate) WHERE APPROPRIATE */
			WHERE 	ord_bookdate BETWEEN @DateStart AND @DateEnd
				AND ord_status in ('AVL','PLN','DSP','STD','CMP')
				AND ord_bookdate > ord_startdate  -- Only looking for BACKBOOKED Orders
		/* CONDITION OF EXISTING SLICE. ONLY CHANGE FIELD NAME (lgh_tm_status) BELOW WHERE APPROPRIATE */
				AND ord_bookedby = @ItemID
	/* END EXISTING SLICE */
			END 
			ELSE	-- If ItemID EQUALS (i.e., IS) Blank, Process ?Other? Pie Piece
			BEGIN
	/* START OTHER SLICE */
			/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH EXISTING SLICE QUERY ABOVE */
			SELECT 
				Ord_hdrnumber as OrderNumber
				,ord_bookedby as BookingAssociate
				,ord_bookdate as BookingDate
				,ord_startdate as StartDate
			FROM orderheader (NOLOCK)
			/* DATE RANGE CONDITION CHANGE FIELD NAME (lgh_enddate) WHERE APPROPRIATE */
			WHERE 	ord_bookdate BETWEEN @DateStart AND @DateEnd
				AND ord_status in ('AVL','PLN','DSP','STD','CMP')
				AND ord_bookdate > ord_startdate  -- Only looking for BACKBOOKED Orders
			/* CONDITION OF OTHER SLICE. ONLY CHANGE FIRST FIELD NAME (lgh_tm_status) BELOW WHERE APPROPRIATE */
			AND ord_bookedby NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)
			/* ORDER BY CLAUSE CHANGE FIELD NAME WHERE APPROPRIATE */
			ORDER BY ord_bookedby 
	/* END OTHER SLICE */
			END
/* END DETAIL SECTION */
		END
		ELSE IF @Refresh = 1
		BEGIN
/* START UPDATE CACHE SECTION */
		/* POPULATE MEMORY TABLE */
		INSERT @RNTrial_Cache
		SELECT 	ord_hdrnumber, -- field not critical, record id for debugging purposes
				ord_bookdate, -- field not critical, date for debugging purposes
				[ItemID] = ord_bookedby, -- Use same field as above that indicates the slice of pie
				/* COUNT IS HOW THE VALUE OF THE SLICE IS MEASURED. HERE IT IS SIMPLE COUNTER */
				[Count] = 1 
			/* FROM AND DATE CLAUSE SHOULD MATCH ABOVE */
			FROM   	orderheader  (NOLOCK) 	
			WHERE 	ord_bookdate BETWEEN @DateStart AND @DateEnd
					AND ord_status in ('AVL','PLN','DSP','STD','CMP')
					AND ord_bookdate > ord_startdate  -- Only looking for BACKBOOKED Orders
		/* BELOW IS BOILER PLATE */	
		SET ROWCOUNT @NumberOfValues	-- Establish Number of Pie Pieces
		/* BELOW IS BOILER PLATE EXCEPT FOR Item Description */
		INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],
[ItemID],[ItemDescription], [Count], [Percentage])  
		SELECT 	[LastUpdate] = GETDATE(),
				[DateStart] = @DateStart,
				[DateEnd] = @DateEnd,
				[ItemCategory] = @Mode,
				[ItemID] = RNTC.[ItemID],
                /* Item description is specific to mode */
				[ItemDescription] = RNTC.[ItemID],
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
GRANT EXECUTE ON  [dbo].[ResNowOV_BackBooking] TO [public]
GO
