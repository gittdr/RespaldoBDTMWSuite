SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cur_mov_number_for_asset_include_dispatch_net] 
							  @type VARCHAR(6), 
                              @id VARCHAR(13), 
                              @lgh INT OUTPUT
AS

Set nocount on
set transaction isolation level read uncommitted


DECLARE	@mov_number INT

SELECT @mov_number = -1

/****** BEGIN PTS 90540 ******/
--SELECT TOP 1 @mov_number = assetassignment.mov_number 
--  FROM assetassignment 
-- WHERE asgn_type = @type AND 
--       asgn_id = @id AND 
--       asgn_status = 'PLN' 
       
--IF @mov_number > 0 
--   RETURN @mov_number
/****** END PTS 90540 ******/

SELECT TOP 1 @mov_number = assetassignment.mov_number 
  FROM assetassignment 
 WHERE asgn_type = @type AND 
       asgn_id = @id AND 
       asgn_status = 'STD' 
       
IF @mov_number > 0 
   RETURN @mov_number

SELECT TOP 1 @mov_number = assetassignment.mov_number 
  FROM assetassignment 
 WHERE asgn_type = @type AND 
       asgn_id = @id AND 
       asgn_status = 'DSP' 
 ORDER BY assetassignment.asgn_date

IF @mov_number > 0 
   RETURN @mov_number
   
SELECT TOP 1 @mov_number = assetassignment.mov_number 
  FROM assetassignment 
 WHERE asgn_type = @type AND 
       asgn_id = @id AND 
       asgn_status = 'CMP' 
 ORDER BY assetassignment.asgn_date DESC

IF @mov_number > 0 
   RETURN @mov_number
   
RETURN @mov_number

GO
GRANT EXECUTE ON  [dbo].[cur_mov_number_for_asset_include_dispatch_net] TO [public]
GO
