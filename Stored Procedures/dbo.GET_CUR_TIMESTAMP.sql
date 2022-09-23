SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
--- TMT AMS from TMWSYSTEMS
---
---  CREATED 6/10/2015 MB (DS: 1231) Use correct Integration_Conf Option for Timestamp
----------------------------------
CREATE PROCEDURE [dbo].[GET_CUR_TIMESTAMP]
(
@CURRENTDBTS [VARCHAR](1000) OUTPUT
)
AS
BEGIN
SELECT  @CURRENTDBTS = @@DBTS   -- current timestamp
END
GO
GRANT EXECUTE ON  [dbo].[GET_CUR_TIMESTAMP] TO [public]
GO
