SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cur_activity_asgn_number] @type VARCHAR(6), 
                              @id VARCHAR(13), 
                              @lgh INT OUTPUT,
			      @asgn_number INT OUTPUT
AS
--PTS 62031 NLOKE changes from Mindy to enhance performance
Set nocount on
set transaction isolation level read uncommitted
--end 62031

DECLARE	@mov_number INT, 
        @maxdt DATETIME 

SELECT @maxdt = MAX(asgn_enddate) 
  FROM assetassignment 
 WHERE asgn_type = @type AND 
       asgn_id = @id AND 
       asgn_status IN ('STD', 'CMP') 

SET ROWCOUNT 1
SELECT @lgh = lgh_number, 
       @mov_number = mov_number, 
	@asgn_number = asgn_number
  FROM assetassignment 
 WHERE asgn_type = @type AND 
       asgn_id = @id AND 
       asgn_status IN ('STD', 'CMP') AND 
       asgn_enddate = @maxdt
SET ROWCOUNT 0

IF @lgh < 1 OR @lgh IS NULL
   BEGIN
        SELECT @lgh = 0
        RETURN -1
   END

IF @mov_number < 1 OR @mov_number IS NULL
   SELECT @mov_number = mov_number 
     FROM legheader
    WHERE lgh_number = @lgh

IF @mov_number < 1 OR @mov_number IS NULL
   RETURN -1

RETURN @mov_number
GO
GRANT EXECUTE ON  [dbo].[cur_activity_asgn_number] TO [public]
GO
