SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_needed_cmd_code_stops_sp] @ord_hdrnumber	INTEGER
AS
DECLARE @minid		INT,
        @cmd_code	VARCHAR(8)

CREATE TABLE #cmd_codes
(
	cmd_id		INT IDENTITY(1,1) NOT NULL,
	cmd_code	VARCHAR(8) NULL
)

CREATE TABLE #stops
(	stp_number	INT,
	cmd_code	VARCHAR(8)
)

INSERT INTO #cmd_codes
   SELECT DISTINCT cmd_code
     FROM freightdetail (nolock)
    WHERE stp_number IN (SELECT stp_number
                           FROM stops (nolock)
                          WHERE ord_hdrnumber = @ord_hdrnumber AND
                                stp_type = 'DRP')

SET @minid = 0
WHILE 1=1
BEGIN

     SELECT @minid = MIN(cmd_id) 
       FROM #cmd_codes
      WHERE cmd_id > @minid 
            
     IF @minid IS NULL
        BREAK

     SELECT @cmd_code = #cmd_codes.cmd_code
       FROM #cmd_codes 
      WHERE cmd_id = @minid

     INSERT INTO #stops
        SELECT stp_number,
               @cmd_code
          FROM stops (nolock)
         WHERE ord_hdrnumber = @ord_hdrnumber AND
               stp_type = 'DRP' AND
               stp_number NOT IN (SELECT stp_number
                                    FROM freightdetail (nolock)
                                   WHERE freightdetail.stp_number = stops.stp_number AND
                                         cmd_code = @cmd_code)
END

SELECT *
  FROM #stops
 
GO
GRANT EXECUTE ON  [dbo].[d_needed_cmd_code_stops_sp] TO [public]
GO
