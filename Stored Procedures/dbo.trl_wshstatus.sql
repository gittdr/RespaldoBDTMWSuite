SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
					
CREATE PROCEDURE [dbo].[trl_wshstatus] @trl VARCHAR(13), @eventcode VARCHAR(6)
AS
DECLARE	@status VARCHAR(1) -- RE - PTS #42704
DECLARE @eventLikeAbbr VARCHAR(6)

SET @eventLikeAbbr = (SELECT ect_event_like_abbr FROM eventcodetable
					  WHERE abbr = @eventcode) -- PTS 95747

SELECT	@status = ISNULL(trl_wash_status, 'Z')
  FROM	trailerprofile 
 WHERE	trl_id = @trl

IF (ISNULL(@eventLikeAbbr, @eventcode) IN ('DTW',  'WSH')) AND @status <> 'Y'  -- RE - PTS #42704
 UPDATE trailerprofile  
    SET trl_wash_status = 'Y'  
  WHERE trl_id = @trl --AND  
--   ISNULL(trl_wash_status, 'Z') <> 'Y'   -- RE - PTS #42704
  
IF (ISNULL(@eventLikeAbbr, @eventcode) IN ('LLD', 'DLD', 'PLD', 'DRL')) AND @status <> 'N' -- RE - PTS #42704
 UPDATE trailerprofile  
    SET trl_wash_status = 'N'  
  WHERE trl_id = @trl --AND  
--   ISNULL(trl_wash_status, 'Z') <> 'N'   -- RE - PTS #42704
GO
GRANT EXECUTE ON  [dbo].[trl_wshstatus] TO [public]
GO
