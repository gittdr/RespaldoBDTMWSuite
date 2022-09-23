SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_GetCarrierCommitmentBucketIdForLeg] (@lgh_number 	INTEGER,
                                                              @start_date	DATETIME,
                                                              @car_id   	VARCHAR(8)) 

AS
DECLARE @activedate			DATETIME,
        @carrierlanecommitmentid	INTEGER


--normalize the date
SET @activedate = @start_date
SET @activedate = CAST(CAST(YEAR(@activedate) AS VARCHAR) + '-' + CAST(MONTH(@activedate) AS VARCHAR) + '-' + CAST(DAY(@activedate) AS VARCHAR) AS DATETIME)


-- Get the lanes
CREATE TABLE #lanes
(
   LaneId	INTEGER,
   LaneName	VARCHAR(50),
   Specificity	INTEGER,
   Radius	INTEGER
)

INSERT INTO #lanes
   SELECT * 
     FROM core_fncGetLanesForLeg (@lgh_number) 

-- Get the commitment for this carrier for the lane with the most specificity and a declared commitment

SELECT clc.carrierlanecommitmentid
  INTO #tempid
  FROM core_carrierlanecommitment AS clc (NOLOCK) JOIN #lanes AS l ON clc.laneid = l.laneid
 WHERE clc.car_id=@car_id AND
       clc.effectivedate <= @activedate AND
       clc.expiresdate >= @activedate

-- Create the bucket, if it doesn't exist
SET @carrierlanecommitmentid = 0
SET @carrierlanecommitmentid = ISNULL((SELECT TOP 1 carrierlanecommitmentid 
                                         FROM #tempid 
                                        WHERE carrierlanecommitmentid > @carrierlanecommitmentid
                                       ORDER BY carrierlanecommitmentid),0)
WHILE @carrierlanecommitmentid > 0
BEGIN
   IF (NOT EXISTS (SELECT ccb_id
                     FROM core_carriercommitmentbuckets (NOLOCK)
                    WHERE carrierlanecommitmentid = @carrierlanecommitmentid AND
                          ccb_date=@activedate))
   EXEC dbo.core_CreateCarrierCommitmentTrackingBuckets @carrierlanecommitmentid, @activedate

   SET @carrierlanecommitmentid = ISNULL((SELECT TOP 1 carrierlanecommitmentid 
                                            FROM #tempid 
                                           WHERE carrierlanecommitmentid > @carrierlanecommitmentid
                                          ORDER BY carrierlanecommitmentid),0)
END



-- Get the bucket
SELECT ccb.ccb_id
  FROM core_carriercommitmentbuckets AS ccb (NOLOCK)
 WHERE carrierlanecommitmentid IN (SELECT carrierlanecommitmentid 
                                     FROM #tempid) AND
       ccb_date = @activedate


-- Clean up our temporary tables
DROP TABLE #lanes
DROP TABLE #tempid
GO
GRANT EXECUTE ON  [dbo].[core_GetCarrierCommitmentBucketIdForLeg] TO [public]
GO
