SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cur_activity] @type VARCHAR(6), 
                              @id VARCHAR(13), 
                              @lgh INT OUT
AS

DECLARE	@asgn_number INT, @ret int

exec @ret = cur_activity_asgn_number @type, 
                              @id, 
                              @lgh OUTPUT,
			      @asgn_number OUTPUT
RETURN @ret
GO
GRANT EXECUTE ON  [dbo].[cur_activity] TO [public]
GO
