SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ResNowOV_TableRowData]
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
	CREATE TABLE #temp (id int, tablename varchar(255), crdate datetime, rc int) 
	CREATE TABLE #t (name  varchar(255), rows int, reserved varchar(50), data varchar(50), index_size varchar(50), unused varchar(50))

	DECLARE @id int, @sql varchar(2000), @name varchar(255)
    SET NOCOUNT ON 

	/* GENERIC MEMORY TABLE LEAVE AS IS*/
 	Declare @RNTrial_Cache TABLE (
		unique_number int,
		unique_date  datetime,
		[ItemID] [varchar] (50),
		[Count] Money
	)   

	-- *************************** THIS SECTION IS CALLED WHEN USER CLICKS ON SECTION ***************************
	IF IsNull(@NumberOfValues,0) = 0
	BEGIN /* START DETAIL SECTION */ 
		-- *************************** THIS SECTION IS CALLED WHEN USER CLICKS ON A "TOP X" SECTION ***************************
		IF IsNull(@ItemID, '') > '' 
		BEGIN
			/* START EXISTING SLICE */
			/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH OTHER SLICE QUERY BELOW */

			EXEC sp_spaceused @ItemID
			/* END EXISTING SLICE */
		END 
		ELSE
		BEGIN
			-- *************************** THIS SECTION IS CALLED WHEN USER CLICKS ON THE "OTHER" SECTION ***************************
			/* START OTHER SLICE */
			INSERT #temp(tablename, id, crdate)
			SELECT name, id, crdate FROM sysobjects t1 (READPAST) WHERE type = 'u' AND NOT EXISTS(SELECT id FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode AND ItemId = t1.name)
		 
			SELECT @id = MIN(id) FROM #temp
			WHILE ISNULL(@id, -1) > 0
			BEGIN
				SELECT @name = name FROM sysobjects WHERE id = @id
				INSERT INTO #t (name, rows, reserved, data, index_size, unused)	EXEC sp_spaceused @name

				SELECT @id = MIN(id) FROM #temp WHERE id > @id
			END
			UPDATE #t SET reserved = REPLACE(reserved, ' KB', ''), data = REPLACE(data, ' KB', ''),
							index_size = REPLACE(index_size, ' KB', ''), unused = REPLACE(unused, ' KB', '')

			SELECT * FROM #t ORDER BY CONVERT(int, Data) desc
			-- SELECT [Table Name] = tablename, [Number Of Rows] = rc  FROM #temp ORDER BY rc DESC
			
			/* CONDITION OF OTHER SLICE. ONLY CHANGE FIRST FIELD NAME (IVD.cht_itemcode) BELOW WHERE APPROPRIATE */
			--	AND t1.name NOT IN (SELECT ItemID  FROM RNTrial_Cache_TopValues (NOLOCK) )
			/* ORDER BY CLAUSE CHANGE FIELD NAME WHERE APPROPRIATE */
			/* END OTHER SLICE */
		END
	END /* END DETAIL SECTION */

	-- *************************** THIS SECTION IS CALLED WHEN "MetricOverviewProcessing" runs ***************************
	ELSE IF @Refresh = 1
	BEGIN  /* START UPDATE CACHE SECTION */  
		/* POPULATE MEMORY TABLE */
		SELECT @id = MIN(id) FROM sysobjects WHERE type = 'u'

select  MIN(id) FROM sysobjects WHERE type = 'u'

		WHILE ISNULL(@id, 0) > 0
		BEGIN
			SELECT @name = name FROM sysobjects WHERE id = @id


--			INSERT INTO #t (name, rows, reserved, data , index_size, unused)	EXEC sp_spaceused reports @name  ---ESTE SP CAUSA EL PROBLEMA
			SELECT @id = MIN(id) FROM sysobjects WHERE type = 'u' AND id > @id
		END

		UPDATE #t SET reserved = REPLACE(reserved, ' KB', ''), data = REPLACE(data, ' KB', ''),
						index_size = REPLACE(index_size, ' KB', ''), unused = REPLACE(unused, ' KB', '')

		INSERT @RNTrial_Cache (unique_number, unique_date, [ItemID], [Count])
		SELECT 	t2.id, -- field not critical, record id for debugging purposes
				t2.crdate, -- field not critical, date for debugging purposes
				t2.name, -- Use same field as above that indicates the slice of pie
				CONVERT(int, t1.data)  /* COUNT IS HOW THE VALUE OF THE SLICE IS MEASURED. HERE IT IS a count of SPACE. */
			/* FROM AND DATE CLAUSE SHOULD MATCH ABOVE */
			FROM #t t1 INNER JOIN sysobjects t2 (NOLOCK) ON t1.name = t2.name AND t2.type = 'u'
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
GRANT EXECUTE ON  [dbo].[ResNowOV_TableRowData] TO [public]
GO
