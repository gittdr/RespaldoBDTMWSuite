SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TMT_DELETEACCESSORY]
@UNIT_IDTYPE char(7),
@UNIT_ID char(13),
@ACC_TYPE CHAR(6),
@ACC_ID char(12),
@ERRORCODE int OUTPUT

AS

SET @ERRORCODE=0

-- ***************************************************************************************************
-- Check Parameters
-- ***************************************************************************************************

IF @UNIT_IDTYPE = 'TRACTOR'
BEGIN
SELECT @UNIT_IDTYPE = 'TRC'
END

IF @UNIT_IDTYPE = 'TRAILER'
BEGIN
SELECT @UNIT_IDTYPE = 'TRL'
END

-- ****************************************************************************
-- Grab Unit Type Definitions from TMT Lookup Table
-- ****************************************************************************
IF @UNIT_IDTYPE <> 'TRC' OR @UNIT_IDTYPE <> 'TRL'
BEGIN
IF EXISTS(SELECT [CODE]
FROM [dbo].[TMTUNITTYPE] (NOLOCK)
WHERE [CODE] = @UNIT_IDTYPE)
BEGIN
SELECT @UNIT_IDTYPE = [TMWDESIGNATION]
FROM [dbo].[TMTUNITTYPE] (NOLOCK)
WHERE [CODE] = @UNIT_IDTYPE
END
END
ELSE
BEGIN
SELECT @ERRORCODE=-1
GOTO ERROR_EXIT
END

IF @UNIT_IDTYPE = 'TRC'
DELETE FROM [dbo].[TRACTORACCESORIES] WHERE [TCA_TRACTOR] = @UNIT_ID AND [TCA_TYPE] = @ACC_TYPE AND [TCA_ID] = @ACC_ID
ELSE IF @UNIT_IDTYPE = 'TRL'
DELETE FROM [dbo].[TRLACCESSORIES] WHERE [TA_TRAILER] = @UNIT_ID AND [TA_TYPE] = @ACC_TYPE AND [TA_ID] = @ACC_ID

GOTO NO_ERROR_EXIT

ERROR_EXIT:

NO_ERROR_EXIT:



GO
GRANT EXECUTE ON  [dbo].[TMT_DELETEACCESSORY] TO [public]
GO
