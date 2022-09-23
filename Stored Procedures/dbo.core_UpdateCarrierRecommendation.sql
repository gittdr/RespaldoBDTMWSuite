SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_UpdateCarrierRecommendation] (@ord_hdrnumber	INT,
                                                       @start_date	DATETIME,
                                                       @lgh_carrier	VARCHAR(8),
                                                       @incdec		CHAR(3))
AS
DECLARE @laneid		INTEGER,
	@begindate	DATETIME,
	@BucketId	INTEGER

CREATE TABLE #BucketIDs (bucketid INT)

INSERT #BucketIDs 
   EXEC dbo.core_GetCarrierCommitmentBucketIdForLeg @ord_hdrnumber, @start_date, @lgh_carrier

SET @BucketId = 0
SET @BucketId = ISNULL((SELECT TOP 1 bucketid 
                          FROM #BucketIDs 
                         WHERE bucketid > @BucketId
                        ORDER BY bucketid),0)
WHILE @BucketId > 0
BEGIN
   IF @incdec = 'INC'
      UPDATE core_carriercommitmentbuckets
         SET ccb_recommended = ccb_recommended + 1
       WHERE ccb_id = @BucketId

   IF @incdec = 'DEC'
      UPDATE core_carriercommitmentbuckets
         SET ccb_recommended = ccb_recommended - 1
       WHERE ccb_id = @bucketid

   SET @BucketId = ISNULL((SELECT TOP 1 bucketid 
                             FROM #BucketIDs 
                            WHERE bucketid > @BucketId
                           ORDER BY bucketid),0)
END

GO
GRANT EXECUTE ON  [dbo].[core_UpdateCarrierRecommendation] TO [public]
GO
