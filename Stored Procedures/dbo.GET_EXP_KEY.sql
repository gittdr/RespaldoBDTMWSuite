SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

----------------------------------
-- PROVIDES GET_EXP_KEY
-- REQUIRES none
-- MINVERSION 18.3

--- TMT AMS from TMWSYSTEMS
---
---  CHANGED 12/19/2018 SK AM-258032 Added existance check
---  CHANGED 11/06/2018 SK AM-304145 Modfied to get EXP_KEY for closes also
---  CREATED 03/08/2018 SK WE-212761 Gets EXP_KEY for TFW
----------------------------------

CREATE PROCEDURE [dbo].[GET_EXP_KEY] ( @EXP_ID VARCHAR(24), @EXP_COMPCODE VARCHAR(12), @EXP_KEY NVARCHAR(50) OUTPUT )
AS
BEGIN
SELECT @EXP_KEY = EXP_KEY
FROM   dbo.TMT_Expirations
WHERE  EXP_ID                         = @EXP_ID
AND ISNULL( EXP_COMPCODE, '' ) = RTRIM( ISNULL( @EXP_COMPCODE, '' ))
--AND EXP_CODE                   = 'PRE'
--AND EXP_COMPLETED              = 'N'
END
GO
