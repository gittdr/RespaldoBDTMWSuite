SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[update_raildispatchstatus] @mov_number INTEGER
AS
DECLARE @lgh_count		INTEGER,
	@minid			INTEGER,
	@lgh_number		INTEGER,
	@orig_cmp_id		VARCHAR(8),
	@orig_cmp_railramp	CHAR(1),
	@dest_cmp_id		VARCHAR(8),
	@dest_cmp_railramp	CHAR(1),
	@prev_lgh_number	INTEGER,
	@stp_status		VARCHAR(6),
	@stp_departure_status	VARCHAR(6)

CREATE TABLE #legs (
	temp_id		INT IDENTITY(1,1) NOT NULL,
	lgh_number  	INTEGER		NULL,
	lgh_startdate	DATETIME	NULL
)

INSERT INTO #legs (lgh_number, lgh_startdate)
   SELECT lgh_number, lgh_startdate
     FROM legheader
    WHERE mov_number = @mov_number
   ORDER BY lgh_startdate

SELECT @lgh_count = COUNT(*)
  FROM #legs

IF @lgh_count < 3
   RETURN

SET @minid = 2
WHILE @minid <= @lgh_count
BEGIN
   SELECT @lgh_number = lgh_number
     FROM #legs
    WHERE temp_id = @minid

   SET @orig_cmp_id = 'UNKNOWN'
   SET @dest_cmp_id = 'UNKNOWN'
   SET @orig_cmp_railramp = 'N'
   SET @dest_cmp_railramp = 'N'

   SELECT @orig_cmp_id = stops.cmp_id, 
          @orig_cmp_railramp = UPPER(ISNULL(company.cmp_railramp, 'N'))
     FROM stops JOIN company ON stops.cmp_id = company.cmp_id
    WHERE stops.lgh_number = @lgh_number AND
          stops.stp_event = 'HLT'

   SELECT @dest_cmp_id = stops.cmp_id,
          @dest_cmp_railramp = UPPER(ISNULL(company.cmp_railramp, 'N'))
     FROM stops JOIN company ON stops.cmp_id = company.cmp_id
    WHERE stops.lgh_number = @lgh_number AND
          stops.stp_event = 'DLT'

   IF @orig_cmp_railramp = 'Y' AND @dest_cmp_railramp = 'Y'
   BEGIN
   --PTS55147 MBR 12/20/10 commented out most of the next section
   /*
      SELECT @prev_lgh_number = lgh_number
        FROM #legs
       WHERE temp_id = @minid - 1

      SET @stp_status = 'OPN'

      SELECT @stp_status = stops.stp_status
        FROM stops
       WHERE lgh_number = @prev_lgh_number AND
             stops.stp_event = 'DLT'
      IF @stp_status = 'DNE'
      BEGIN
         UPDATE legheader
            SET lgh_raildispatchstatus = 'A'
          WHERE lgh_number = @lgh_number

         SET @minid = @minid + 1

         CONTINUE
      END

      SET @stp_departure_status = 'OPN'
      
      SELECT @stp_departure_status = stops.stp_departure_status
        FROM stops
       WHERE lgh_number = @prev_lgh_number AND
            (stp_number = (SELECT MIN(stp_number)
                             FROM stops
                            WHERE lgh_number = @prev_lgh_number AND
                                  stp_type = 'PUP') OR
             stp_event = 'HLT')
      IF @stp_departure_status = 'DNE'
      BEGIN
         UPDATE legheader
            SET lgh_raildispatchstatus = 'D'
          WHERE lgh_number = @lgh_number

         SET @minid = @minid + 1

         CONTINUE
      END  */

      UPDATE legheader
         SET lgh_raildispatchstatus = 'D'
       WHERE lgh_number = @lgh_number
   END

   SET @minid = @minid + 1

END

GO
GRANT EXECUTE ON  [dbo].[update_raildispatchstatus] TO [public]
GO
