SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ResNowOV_TableColumns]
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
	SET NOCOUNT ON

	/* GENERIC MEMORY TABLE LEAVE AS IS*/
 	Declare @RNTrial_Cache TABLE (
		unique_number int,
		unique_date  datetime,
		[ItemID] [varchar] (50),
		[Count] Money
	)   

	IF IsNull(@NumberOfValues,0) = 0
	BEGIN /* START DETAIL SECTION */
		IF IsNull(@ItemID, '') > '' 
		BEGIN
			/* START EXISTING SLICE */
			/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH OTHER SLICE QUERY BELOW */
			SELECT [Table Name] = t1.name, [Table Create Date] = t1.crdate, [Column Name] = t2.name, [Data Type] = t3.name
			FROM sysobjects t1 INNER JOIN syscolumns t2 ON t1.id = t2.id INNER JOIN systypes t3 ON t2.xtype = t3.xtype
			WHERE t1.type = 'u' AND t1.name = @ItemID
			/* END EXISTING SLICE */
		END 
		ELSE
		BEGIN
			/* START OTHER SLICE */
			SELECT [Table Name] = t1.name, [Table Create Date] = t1.crdate, [Number Of Columns] = COUNT(*)
			FROM sysobjects t1 INNER JOIN syscolumns t2 ON t1.id = t2.id INNER JOIN systypes t3 ON t2.xtype = t3.xtype
			WHERE t1.type = 'u' -- AND t1.name = @ItemID
			/* CONDITION OF OTHER SLICE. ONLY CHANGE FIRST FIELD NAME (IVD.cht_itemcode) BELOW WHERE APPROPRIATE */
				AND t1.name NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) )
			/* ORDER BY CLAUSE CHANGE FIELD NAME WHERE APPROPRIATE */
			GROUP BY t1.name, t1.crdate
			ORDER BY COUNT(*) DESC
			/* END OTHER SLICE */
		END
	END /* END DETAIL SECTION */
	ELSE IF @Refresh = 1
	BEGIN  /* START UPDATE CACHE SECTION */
		/* POPULATE MEMORY TABLE */
		INSERT @RNTrial_Cache
		SELECT 	t1.id, -- field not critical, record id for debugging purposes
				t1.crdate, -- field not critical, date for debugging purposes
				t1.name, -- Use same field as above that indicates the slice of pie
				/* COUNT IS HOW THE VALUE OF THE SLICE IS MEASURED. HERE IT IS REVENUE */
				[Count] = COUNT(*)  ---*** Count the number of fields.
			/* FROM AND DATE CLAUSE SHOULD MATCH ABOVE */
			FROM sysobjects t1 INNER JOIN syscolumns t2 ON t1.id = t2.id INNER JOIN systypes t3 ON t2.xtype = t3.xtype
			WHERE t1.type = 'u'
			GROUP BY t1.id, t1.crdate, t1.name
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
				[ItemDescription] = RNTC.[ItemID],
				/* Item description is specific to mode */
				[Count] = SUM(RNTC.[Count]),
				[Percentage] = CONVERT(decimal(24, 5) , 100 * SUM([Count]) / CONVERT(decimal(20, 5), (SELECT SUM(RNTC1.[Count]) FROM @RNTrial_Cache RNTC1)))
		FROM @RNTrial_Cache RNTC 
		GROUP BY RNTC.[ItemID]
		ORDER BY SUM(RNTC.[Count]) DESC
		SET ROWCOUNT 0
	END 	/* END UPDATE CACHE SECTION */
GO
GRANT EXECUTE ON  [dbo].[ResNowOV_TableColumns] TO [public]
GO
