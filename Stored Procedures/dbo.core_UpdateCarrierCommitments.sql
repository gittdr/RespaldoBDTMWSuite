SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[core_UpdateCarrierCommitments] (@lgh_number			INTEGER,
                                                    @start_date			DATETIME,
                                                    @lgh_carrier		VARCHAR(8),
                                                    @incdec			VARCHAR(3),
                                                    @lgh_recommended_car_id	VARCHAR(8),
                                                    @lgh_recommended_startdate  DATETIME)
AS
DECLARE @BucketId	INTEGER

CREATE TABLE #BucketIDs
(
   bucketid INTEGER NULL
)

CREATE TABLE #RecommendedBucketIds
(
   bucketid INTEGER NULL
)

INSERT #BucketIDs 
   EXEC dbo.core_GetCarrierCommitmentBucketIdForLeg @lgh_number, @start_date, @lgh_carrier

SET @BucketId = 0
SET @BucketId = ISNULL((SELECT TOP 1 bucketid 
			  FROM #BucketIDs 
			 WHERE bucketid > @BucketId
			ORDER BY bucketid),0)
WHILE @BucketId > 0
BEGIN
   IF @incdec = 'INC'
      UPDATE core_carriercommitmentbuckets
         SET ccb_assigned = ccb_assigned + 1
       WHERE ccb_id=@BucketId

   IF @incdec = 'DEC'
      UPDATE core_carriercommitmentbuckets
         SET ccb_assigned = ccb_assigned - 1
       WHERE ccb_id=@BucketId

  SET @BucketId = ISNULL((SELECT TOP 1 bucketid 
			    FROM #BucketIDs 
			   WHERE bucketid > @BucketId
			  ORDER BY bucketid),0)
END

IF @lgh_recommended_car_id <> 'UNKNOWN' AND @incdec = 'INC'
BEGIN
   INSERT #RecommendedBucketIds
      EXEC dbo.core_GetCarrierCommitmentBucketIdForLeg @lgh_number, @lgh_recommended_startdate, @lgh_recommended_car_id
   SET @BucketId = 0
   SET @BucketId = ISNULL((SELECT TOP 1 bucketid 
                             FROM #RecommendedBucketIDs 
                            WHERE bucketid > @BucketId
                           ORDER BY bucketid),0)
   WHILE @BucketId > 0
   BEGIN
      UPDATE core_carriercommitmentbuckets
         SET ccb_recommended = ccb_recommended - 1
       WHERE ccb_id=@BucketId

      SET @BucketId = ISNULL((SELECT TOP 1 bucketid 
                                FROM #RecommendedBucketIDs 
                               WHERE bucketid > @BucketId
                              ORDER BY bucketid),0)

   END

   UPDATE legheader
      SET lgh_recommended_car_id = NULL
    WHERE lgh_number = @lgh_number
END

GO
GRANT EXECUTE ON  [dbo].[core_UpdateCarrierCommitments] TO [public]
GO
