SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
-- PROVIDES EXPIRATION_ADD_SP
-- REQUIRES none
-- MINVERSION 18.2.1

--- TMT AMS from TMWSYSTEMS
--- CHANGED 09/14/2018 SK AM-258494 Changed for updating promised date if completed section is reopened and promise date is changed
--- CHANGED 09/11/2018 SK WE-218531 Merge changes made by JP into sp and code base.
--- CHANGED 08/10/2018 SK WE-215032 Changes to reworked Suite synch
--- CHANGED 08/01/2018 JP WE-217408  Changed converting @EXP_COMPLDATE from VARhar 12 to small datetime
--- CHANGED 07/21/2018 SK WE-217408  Added new parameter and code to handle sending PromisedDate from TMT
--- CHANGED 05/15/2017 MRH Delete non complete expirations from TMT_expiraions that are not also in expirations to allow them to be recreated.
--- CHANGED 10/06/2016 MRH Restrict duplicate expiration check to only expirations that are not complete.
--- CHANGED 04/01/2016 MRH Added code to prevent creation of expirations with NULL descriptions. Added error return -1099.
--- CHANGED 07/22/2015 MH Fixed problem with OUT and completed expirations for OUT experations that had not previously been sent.
--- CHANGED 05/29/2015 MH Case: C869389 Add a final dup test on expiration to catch user changes that can cause duplicate errors.
--- CHANGED 05/28/2015 MH PTS 91026 Unit out of service catch
--- CHANGED 05/11/2015 MB Task 705: Pending system is now working
--- CHANGED 09/12/2014 MB case: C743507 When a user terminates (Soft delete or set to REPORTS ONLY status) a unit in TMWAMS,
---                                     the unit would create a TMWSuite, Out of Service expiration End Date 30 days from the date
---                                     of the of the Expiration Date.
--- CHANGED 02/18/2014 MRH - Fixed problem with identical PM expirations on the same day.
---		Fixed debug message type cast.
---		Fixed order number save on PM expirations which allows PMs expirations to be properly closed with a new RO.
--- CHANGED 11/19/2013 MRH - Fixed problem with Alt Company ID location.
--- CHANGED 7/22/2013  MH
--- CHANGED 07/17/2013 MB
--- CHANGED 12/21/2009 MH
--- CHANGED 03/04/2009 MRH
--- CHANGED 08/01/2007 MB
--- CHANGED 05/29/2007 MB
--- CHANGED 05/17/2007 MB
--- CHANGED 02/08/2007 MB
--- CHANGED 02/06/2007 MB
--- CHANGED 09/08/2006 MB
--- MRH 11/16/2006 Added logic to leave the unit at the last stop if shop is unknown or blank.
---           TMT to change calling logic to pass blank, null, or 'unknown' if the RO is a vendor RO.
--- MRH 5/07/08 Add ablility to take units OUT of service (remove from license count)
----------------------------------

CREATE PROCEDURE [dbo].[EXPIRATION_ADD_SP]
@EXP_KEY            INT     = -1
, @EXP_IDTYPE         VARCHAR(12)
, @EXP_ID             VARCHAR(13)
, @EXP_CODE           VARCHAR(6)
, @EXP_EXPIRATIONDATE DATETIME
, @EXP_ROUTETO        VARCHAR(8)
, @EXP_PRIORITY       VARCHAR(6)
, @EXP_COMPLDATE      DATETIME 
, @EXP_COMPCODE       VARCHAR(12)
, @EXP_CODEKEY        VARCHAR(12)
, @EXP_MILESTOEXP     INT
, @EXP_DESCRIPTION    VARCHAR(100)
, @EXP_STATUS         SMALLINT
, @EXP_OUTKEY         INT OUTPUT
, @EXP_DAYSINSHOP     INTEGER = NULL
, @EXP_PERCENT        INTEGER = NULL
, @EXP_COMPLETED      CHAR(1)  = NULL --ADDED BY EMOLVERA     -- MRH added to control OUT of service.
, @EXP_ISPROMISEDT    CHAR(1) = 'N' -- SK added to control sending a Promised date.
AS
SET NOCOUNT ON

DECLARE @ORDERID INT
DECLARE @SECTION INT
DECLARE @ERRORCODE INT
--DECLARE	@EXP_COMPLETED CHAR(1)
DECLARE @OLDEXP_COMPLETED CHAR(1)
DECLARE @OUTEXP_STATUS CHAR(1)
DECLARE @EXP_DESCRIP2 VARCHAR(100)
DECLARE @EXP_CITY INT
DECLARE @SUBSTRING VARCHAR(50)
DECLARE @EXP_MAXDAYSINSHOP INTEGER
DECLARE @INSERT_NEW_EXPIRATION INTEGER
DECLARE @TMW_EXP_ID INTEGER
DECLARE @ReOpenPM CHAR(1)
DECLARE @rowcount INT
DECLARE @ROWS INT
DECLARE @DEBUG INTEGER

SET @DEBUG = 0 -- 0 = Off, 1 = On

IF @DEBUG = 1
PRINT 'START EXPIRATION_ADD_SP'

SET @ERRORCODE = 0 -- SET TO KNOWN VALUE
SET @INSERT_NEW_EXPIRATION = 0
SET @EXP_MAXDAYSINSHOP = 30
SET @EXP_DAYSINSHOP = ISNULL( @EXP_DAYSINSHOP, 10 )
SET @EXP_PERCENT = ISNULL( @EXP_PERCENT, 0 )
SET @EXP_EXPIRATIONDATE = ISNULL( @EXP_EXPIRATIONDATE, '01/01/2049' )
SET @ReOpenPM = 'N'

IF @DEBUG = 1
PRINT @EXP_IDTYPE + ':' + @EXP_ID + ':' + @EXP_CODE

-- PERFORM DATA VALIDATION
IF @EXP_COMPLDATE <= '01/01/2001'
BEGIN
SELECT @EXP_COMPLDATE = DATEADD( DAY, @EXP_DAYSINSHOP, GETDATE())
END

--SELECT @EXP_COMPLDATE = CAST(CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS VARCHAR(12)) AS DATETIME)
SELECT @EXP_COMPLDATE = CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS DATETIME)

IF @EXP_EXPIRATIONDATE >= @EXP_COMPLDATE
BEGIN
SET @EXP_EXPIRATIONDATE = @EXP_COMPLDATE
END

-- Don't truncate the time from the expiration.
--SELECT @EXP_EXPIRATIONDATE = CAST(CAST(CAST(@EXP_EXPIRATIONDATE AS SMALLDATETIME) AS VARCHAR (12)) AS DATETIME)
IF ISNULL( @EXP_DESCRIPTION, '' ) = ''
RETURN -1099 -- Error exit if description is null.

IF ( ISNULL( @EXP_IDTYPE, '' ) = '' )
BEGIN
SELECT @ERRORCODE = 0

GOTO ERROR_EXIT
END

-- Remove any manually deleted expirations from the TMT_Expirations table so that they can be recreated.
IF EXISTS ( SELECT gi_string1 FROM generalinfo WHERE gi_name = 'ShopLinkOptions' AND ISNULL( gi_string3, 'Y' ) = 'Y' )
DELETE    te
FROM      TMT_Expirations te
LEFT JOIN expiration      e
ON e.exp_key = te.EXP_KEY
WHERE     te.EXP_COMPLETED = 'N'
AND te.EXP_CODE  = 'INSHOP'
AND e.exp_key IS NULL

IF EXISTS ( SELECT gi_string1 FROM generalinfo WHERE gi_name = 'ShopLinkOptions' AND ISNULL( gi_string4, 'Y' ) = 'Y' )
DELETE    te
FROM      TMT_Expirations te
LEFT JOIN expiration      e
ON e.exp_key = te.EXP_KEY
WHERE     te.EXP_COMPLETED = 'N'
AND te.EXP_CODE  = 'PRE'
AND e.exp_key IS NULL

-- End of clean up
SET @EXP_IDTYPE = ISNULL( @EXP_IDTYPE, 'TRC' )

IF UPPER( @EXP_IDTYPE ) = 'TRACTOR'
BEGIN
SELECT @EXP_IDTYPE = 'TRC'
END

IF UPPER( @EXP_IDTYPE ) = 'TRAILER'
BEGIN
SELECT @EXP_IDTYPE = 'TRL'
END

IF UPPER( @EXP_IDTYPE ) NOT IN ( 'TRC', 'TRL' )
BEGIN
-- 2.01 ENHANCEMENT, LOOK UP UNIT TYPE
IF EXISTS ( SELECT [code] FROM [dbo].[TMTUNITTYPE] WHERE [code] = @EXP_IDTYPE )
BEGIN
SELECT @EXP_IDTYPE = [TMWDesignation]
FROM   [dbo].[TMTUNITTYPE]
WHERE  [code] = @EXP_IDTYPE
END
ELSE
BEGIN
SELECT @ERRORCODE = -1

GOTO ERROR_EXIT
END
END

------- Validate the unit before doing any updates.
IF UPPER( @EXP_IDTYPE ) = 'TRC'
BEGIN
IF NOT EXISTS ( SELECT [trc_number] FROM [dbo].[tractorprofile] WHERE [trc_number] = @EXP_ID )
BEGIN
SELECT @ERRORCODE = -2

GOTO ERROR_EXIT
END -- END TRC_NUMBER DOES NOT EXIST

IF NOT EXISTS ( SELECT [labeldefinition] FROM [dbo].[labelfile] WHERE UPPER( [labeldefinition] ) = 'TRCEXP' AND [abbr] = @EXP_CODE )
BEGIN
SELECT @ERRORCODE = -3

GOTO ERROR_EXIT
END -- END LABELDEFINITION DOES NOT EXIST
END
ELSE IF UPPER( @EXP_IDTYPE ) = 'TRL'
BEGIN
IF NOT EXISTS ( SELECT [trl_number] FROM [dbo].[trailerprofile] WHERE [trl_number] = @EXP_ID AND ISNULL( trl_ilt, 'N' ) = 'N' )
BEGIN
SELECT @ERRORCODE = -4

GOTO ERROR_EXIT
END -- END TRL_NUMBER DOES NOT EXIST

IF NOT EXISTS ( SELECT [labeldefinition] FROM [dbo].[labelfile] WHERE UPPER( [labeldefinition] ) = 'TRLEXP' AND [abbr] = @EXP_CODE )
BEGIN
SELECT @ERRORCODE = -5

GOTO ERROR_EXIT
END -- END LABELDEFINITION DOES NOT EXIST
END
ELSE
BEGIN
SELECT @ERRORCODE = 0

GOTO ERROR_EXIT
END

IF @DEBUG = 1
PRINT 'ORDER:' + CONVERT( VARCHAR(20), ISNULL( @ORDERID, 0 ))

IF @DEBUG = 1
PRINT 'DESCRIPTION:' + @EXP_DESCRIPTION

IF @DEBUG = 1
PRINT 'EXP_COMPLETED:' + ISNULL( @EXP_COMPLETED, 'N' )

IF @DEBUG = 1
PRINT 'EXP_COMPLDATE:' + CONVERT( VARCHAR(30), @EXP_COMPLDATE )

IF @DEBUG = 1
PRINT 'EXP_PRIORITY:' + @EXP_PRIORITY

IF @DEBUG = 1
PRINT 'EXP_CODE:' + ISNULL( @EXP_CODE, '' )

IF @DEBUG = 1
PRINT 'EXP_ROUTETO:' + ISNULL( @EXP_ROUTETO, '' )

IF @DEBUG = 1
PRINT 'EXP_COMPCODE:' + ISNULL( @EXP_COMPCODE, '' )

IF @DEBUG = 1
PRINT 'EXP_CODEKEY:' + ISNULL( @EXP_CODEKEY, '' )

IF @DEBUG = 1
PRINT 'EXP_STATUS:' + CONVERT( VARCHAR(30), ISNULL( @EXP_STATUS, 0 ))

------------------------------------------
--MRH There is logic tied around PMs and the completed status. Let's keep the original logic
-- adding new logic to support using the complted flag in conjunction with OUT.
SELECT @OUTEXP_STATUS = @EXP_COMPLETED

--SET @EXP_COMPLETED = 'N'
-- Update the TMT_Expirations table
--SET @EXP_COMPLETED = ISNULL(@EXP_COMPLETED, 'N')
SET @EXP_COMPLETED = ISNULL( @OLDEXP_COMPLETED, 'N' )

--             Select @ORDERID = -1
IF UPPER( @EXP_CODE ) = 'INSHOP'
BEGIN
SELECT @ORDERID = CONVERT( INT
, RTRIM( SUBSTRING( @EXP_DESCRIPTION
, CHARINDEX( ' ', @EXP_DESCRIPTION, 0 )
, CHARINDEX( ':', @EXP_DESCRIPTION, 0 ) - CHARINDEX( ' ', @EXP_DESCRIPTION, 0 )
)
)
)

IF @DEBUG = 1
BEGIN
PRINT 'ORDER:' + CONVERT( VARCHAR(20), @ORDERID )

SELECT @TMW_EXP_ID AS DEBUG_VALUE_OF_TMW_EXP_ID
, @ORDERID
, @EXP_IDTYPE
, @EXP_ID
END

IF
(
SELECT COUNT( 1 )
FROM   TMT_Expirations
WHERE  EXP_ORDERID    = @ORDERID
AND EXP_IDTYPE = @EXP_IDTYPE
AND EXP_ID     = @EXP_ID
AND EXP_CODE IN ( 'INSHOP', 'PEND' )
) > 0
BEGIN
SELECT @TMW_EXP_ID = texp_id
FROM   TMT_Expirations
WHERE  EXP_ORDERID    = @ORDERID
AND EXP_IDTYPE = @EXP_IDTYPE
AND EXP_ID     = @EXP_ID
AND EXP_CODE IN ( 'INSHOP', 'PEND' ) --and ISNULL(EXP_COMPLETED, 'N') = 'N'

IF @DEBUG = 1
SELECT @TMW_EXP_ID AS DEBUG_VALUE_OF_TMW_EXP_ID
, @ORDERID
, @EXP_IDTYPE
, @EXP_ID
END
ELSE
BEGIN
SET @INSERT_NEW_EXPIRATION = 1

IF @DEBUG = 1
PRINT 'INSHOP NEW Expiration'
END

IF @DEBUG = 1
PRINT 'TEXP_ID:' + CONVERT( VARCHAR(20), ISNULL( @TMW_EXP_ID, -1 ))
END
ELSE IF UPPER( @EXP_CODE ) = 'PRE'
BEGIN
IF @DEBUG = 1
BEGIN
PRINT 'PRE code start'
PRINT LEFT(@EXP_DESCRIPTION, 7)
END

IF LEFT(@EXP_DESCRIPTION, 7) = 'OrderID' -- This can happen if a RO is canceled and the RO job has not executed yet to clean up the outstanding ROs.
GOTO NO_ERROR_EXIT

--See if there is an existing expiration for the same unit / comp_code.
IF
(
SELECT COUNT( 0 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
AND EXP_COMPCODE                 = @EXP_COMPCODE
AND EXP_CODEKEY                  = @EXP_CODEKEY
AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND UPPER( EXP_CODE )            = 'PRE'
) > 0
SELECT @TMW_EXP_ID = MAX( texp_id )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
AND EXP_COMPCODE                 = @EXP_COMPCODE
AND EXP_CODEKEY                  = @EXP_CODEKEY
AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND UPPER( EXP_CODE )            = 'PRE'
ELSE IF
(
SELECT COUNT( 0 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE              = @EXP_IDTYPE
AND EXP_ID              = @EXP_ID
AND EXP_COMPCODE        = @EXP_COMPCODE
AND EXP_CODEKEY         = @EXP_CODEKEY
AND @EXP_EXPIRATIONDATE = EXP_EXPIRATIONDATE
AND UPPER( EXP_CODE )   = 'PRE'
) > 0
BEGIN
SELECT @TMW_EXP_ID = MAX( texp_id )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE              = @EXP_IDTYPE
AND EXP_ID              = @EXP_ID
AND EXP_COMPCODE        = @EXP_COMPCODE
AND EXP_CODEKEY         = @EXP_CODEKEY
AND @EXP_EXPIRATIONDATE = EXP_EXPIRATIONDATE
AND UPPER( EXP_CODE )   = 'PRE'

-- Note. In TMWS, the primary key is desc and date.
-- If the above finds a closed PM which can happen
-- when cycling through PMs and ROs on the same day.
-- In this case we must reopen the existing PM.
SET @ReOpenPM = 'Y'

SELECT @TMW_EXP_ID AS TMW_EXP_ID
END
ELSE
BEGIN
IF @DEBUG = 1
PRINT 'Thinks it is a new exp'

SET @INSERT_NEW_EXPIRATION = 1
END

--if (select count(0) from TMT_Expirations where EXP_IDTYPE = @EXP_IDTYPE and EXP_ID = @EXP_ID and EXP_COMPCODE = @EXP_COMPCODE AND EXP_CODEKEY = @EXP_CODEKEY and ISNULL(EXP_COMPLETED, 'N') = 'N' and UPPER(EXP_CODE) = 'PRE') > 0
--             select @TMW_EXP_ID = max(texp_id) from TMT_Expirations where EXP_IDTYPE = @EXP_IDTYPE and EXP_ID = @EXP_ID and EXP_COMPCODE = @EXP_COMPCODE AND EXP_CODEKEY = @EXP_CODEKEY and ISNULL(EXP_COMPLETED, 'N') = 'N' and UPPER(EXP_CODE) = 'PRE'
--else if LEFT(@EXP_DESCRIPTION, 7) = 'OrderID'-- This can happen if a RO is canceled and the RO job has not executed yet to clean up the outstanding ROs.
--             goto NO_ERROR_EXIT -- The PRE will get reactivated from Expiration_cancel
--else if (select count(0) from TMT_Expirations where EXP_IDTYPE = @EXP_IDTYPE and EXP_ID = @EXP_ID and EXP_COMPCODE = @EXP_COMPCODE AND EXP_CODEKEY = @EXP_CODEKEY and @EXP_EXPIRATIONDATE = EXP_EXPIRATIONDATE and UPPER(EXP_CODE) = 'PRE') > 0
--             select @TMW_EXP_ID = max(texp_id) from TMT_Expirations where EXP_IDTYPE = @EXP_IDTYPE and EXP_ID = @EXP_ID and EXP_COMPCODE = @EXP_COMPCODE AND EXP_CODEKEY = @EXP_CODEKEY and @EXP_EXPIRATIONDATE = EXP_EXPIRAT IONDATE and UPPER(EXP_CODE) = 'PRE'
--else
--             SET @INSERT_NEW_EXPIRATION = 1
END
ELSE IF UPPER( @EXP_CODE ) = 'OUT'
OR UPPER( @EXP_CODE ) = 'PEND'
BEGIN
IF @DEBUG = 1
BEGIN
PRINT 'Exp OUT or PEND'
PRINT '@EXP_IDTYPE:' + ISNULL( @EXP_IDTYPE, 'NULL' ) + ' @EXP_ID:' + ISNULL( @EXP_ID, 'NULL' ) + ' @EXP_CODE:' + ISNULL( @EXP_CODE, 'NULL' )
END

IF @EXP_CODE = 'PEND'
BEGIN
SELECT @ORDERID = CONVERT( INT
, RTRIM( SUBSTRING( @EXP_DESCRIPTION
, CHARINDEX( ' ', @EXP_DESCRIPTION, 0 )
, CHARINDEX( ':', @EXP_DESCRIPTION, 0 ) - CHARINDEX( ' ', @EXP_DESCRIPTION, 0 )
)
)
)

IF
(
SELECT COUNT( 1 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
--	AND EXP_CODE IN ( 'PEND', 'INSHOP' )
AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND EXP_DESCRIPTION              = @EXP_DESCRIPTION
) > 0
BEGIN
SELECT @TMW_EXP_ID = MAX( texp_id )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
--	AND EXP_CODE IN ( 'PEND', 'INSHOP' )
AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND EXP_DESCRIPTION              = @EXP_DESCRIPTION

SELECT @EXP_OUTKEY = ( SELECT EXP_KEY FROM TMT_Expirations WHERE texp_id = @TMW_EXP_ID )
END
ELSE
SET @INSERT_NEW_EXPIRATION = 1
END
ELSE -- OUT of service
BEGIN

--See if there is an existing OUT expiration for the same unit
IF
(
SELECT COUNT( 1 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE   = @EXP_IDTYPE
AND EXP_ID   = @EXP_ID
AND EXP_CODE = @EXP_CODE
--AND ISNULL(EXP_COMPLETED, 'N') = 'N'
) > 0
AND @EXP_CODE = 'OUT'
BEGIN
SELECT @TMW_EXP_ID = MAX( texp_id )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE   = @EXP_IDTYPE
AND EXP_ID   = @EXP_ID
AND EXP_CODE = @EXP_CODE

--AND ISNULL(EXP_COMPLETED, 'N') = 'N'
SELECT @EXP_OUTKEY = ( SELECT EXP_KEY FROM TMT_Expirations WHERE texp_id = @TMW_EXP_ID )
END
ELSE
BEGIN
IF @DEBUG = 1
PRINT 'EXP_CODE:' + ISNULL( @EXP_CODE, '' )

IF @DEBUG = 1
PRINT 'EXP_COMPLETED:' + ISNULL( @OUTEXP_STATUS, 'N' )

--Now recieving All units in and out of service.
IF @EXP_CODE = 'OUT'
AND @OUTEXP_STATUS = 'Y'
BEGIN
SELECT @EXP_OUTKEY = 0 -- No error return

GOTO NO_ERROR_EXIT -- Exit, no work to do.
END

SET @INSERT_NEW_EXPIRATION = 1
END
END
END
ELSE
BEGIN
SELECT @ERRORCODE = -6 --INVALID EXP_CODE

GOTO ERROR_EXIT
END

SELECT @ORDERID = ISNULL( @ORDERID, -1 )

IF @INSERT_NEW_EXPIRATION <> 1
AND ( SELECT EXP_KEY FROM TMT_Expirations WHERE texp_id = @TMW_EXP_ID ) = -1
BEGIN
SELECT @ERRORCODE = -7 -- Duplicate or Unit does not exist.

GOTO ERROR_EXIT
END

IF @DEBUG = 1
BEGIN
PRINT 'Insert New Expiration:' + CONVERT( VARCHAR(20), @INSERT_NEW_EXPIRATION )
END

IF @INSERT_NEW_EXPIRATION = 1
BEGIN -- The following test will eliminate duplicate key errors on the expiration table indexes.
SET @EXP_OUTKEY = NULL

IF @DEBUG = 1
PRINT 'EXP_COMPLDATE TMT_EXPIRATIONS:' + CONVERT( VARCHAR(30), @EXP_COMPLDATE )

INSERT INTO TMT_Expirations ( EXP_KEY
, EXP_IDTYPE
, EXP_ID
, EXP_CODE
, EXP_EXPIRATIONDATE
, EXP_ROUTETO
, EXP_PRIORITY
, EXP_COMPLDATE
, EXP_COMPCODE
, EXP_CODEKEY
, EXP_MILESTOEXP
, EXP_DESCRIPTION
, EXP_STATUS
, EXP_OUTKEY
, EXP_DAYSINSHOP
, EXP_PERCENT
, EXP_ORDERID
, EXP_SECTION
, EXP_COMPLETED
, EXP_TRANSFER_STATUS )
VALUES ( @EXP_KEY
, @EXP_IDTYPE
, @EXP_ID
, @EXP_CODE
, @EXP_EXPIRATIONDATE
, @EXP_ROUTETO
, @EXP_PRIORITY
, @EXP_COMPLDATE
, @EXP_COMPCODE
, @EXP_CODEKEY
, @EXP_MILESTOEXP
, @EXP_DESCRIPTION
, @EXP_STATUS
, @EXP_OUTKEY
, @EXP_DAYSINSHOP
, @EXP_PERCENT
, @ORDERID
, @SECTION
, 'N'
, 'RECIEVED' )

--                SET @TMW_EXP_ID = NULL
--                 SELECT @EXP_OUTKEY = SCOPE_IDENTITY()
SELECT @TMW_EXP_ID = SCOPE_IDENTITY()

IF @DEBUG = 1
BEGIN
PRINT 'tmt_expirations record inserted'
END
END
ELSE
UPDATE TMT_Expirations
SET    [EXP_TRANSFER_STATUS] = 'RECIEVED'
WHERE  @TMW_EXP_ID = texp_id

SELECT @EXP_ROUTETO = ISNULL( @EXP_ROUTETO, 'UNKNOWN' ) -- SET TO UNKNOWN AND GO ON IF NULL

IF @EXP_ROUTETO <> ''
BEGIN
IF (
NOT EXISTS ( SELECT [cmp_altid] FROM [dbo].[company] WHERE [cmp_active] = 'Y' AND [cmp_altid] = @EXP_ROUTETO )
AND @EXP_ROUTETO IS NOT NULL
)
BEGIN
IF (
NOT EXISTS ( SELECT [cmp_id] FROM [dbo].[company] WHERE [cmp_active] = 'Y' AND [cmp_id] = @EXP_ROUTETO )
AND @EXP_ROUTETO IS NOT NULL
)
BEGIN
SELECT @EXP_ROUTETO = 'UNKNOWN'
END
ELSE
BEGIN
SELECT @EXP_CITY = [cmp_city]
FROM   [dbo].[company]
WHERE  [cmp_id]         = @EXP_ROUTETO
AND [cmp_active] = 'Y'
END
END
ELSE
BEGIN
-- MRH 11/14/2011 Find the Company id assoicated with the ALT ID and use that as the expiration location.
SELECT @EXP_ROUTETO = [cmp_id]
FROM   [dbo].[company]
WHERE  [cmp_altid] = @EXP_ROUTETO

SELECT @EXP_CITY = [cmp_city]
FROM   [dbo].[company]
--WHERE   [CMP_ALTID] = @EXP_ROUTETO
WHERE  [cmp_id] = @EXP_ROUTETO
END
END

-- END @EXP_ROUTETO<>''

--------------------------
-- MRH 11/16/2006
-- If the shop is UNKNOWN Position the unit at the last known completed stop
--------------------------
IF UPPER( @EXP_ROUTETO ) = 'UNKNOWN' --APPLIES FOR INSHOP & PEVENTITIVE MAINT
BEGIN
IF EXISTS ( SELECT gi_string1 FROM generalinfo WHERE gi_name = 'ShopLinkOptions' AND gi_string1 = 'Y' )
BEGIN
IF UPPER( @EXP_IDTYPE ) = 'TRL'
BEGIN
SELECT @EXP_CITY    = [stp_city]
, @EXP_ROUTETO = [cmp_id]
FROM   [dbo].[stops]
WHERE  [stp_number] =
(
SELECT MAX( [stp_number] )
FROM   event
WHERE  [evt_trailer1]      = @EXP_ID
AND [evt_status]    = 'DNE'
AND [evt_startdate] = ( SELECT MAX( EVT1.[evt_startdate] ) FROM event EVT1 WHERE EVT1.[evt_trailer1] = @EXP_ID AND EVT1.[evt_status] = 'DNE' )
)
END
ELSE IF UPPER( @EXP_IDTYPE ) = 'TRC'
BEGIN
SELECT @EXP_CITY    = [stp_city]
, @EXP_ROUTETO = [cmp_id]
FROM   [dbo].[stops]
WHERE  [stp_number] =
(
SELECT MAX( [stp_number] )
FROM   event
WHERE  [evt_tractor]       = @EXP_ID
AND [evt_status]    = 'DNE'
AND [evt_startdate] = ( SELECT MAX( EVT1.[evt_startdate] ) FROM event EVT1 WHERE EVT1.[evt_tractor] = @EXP_ID AND EVT1.[evt_status] = 'DNE' )
)
END
END
ELSE
BEGIN -- GI_STRING1 <> 'Y'
IF UPPER( @EXP_IDTYPE ) = 'TRL'
BEGIN
SELECT @EXP_CITY    = [stp_city]
, @EXP_ROUTETO = [cmp_id]
FROM   [dbo].[stops]
WHERE  [lgh_number]        =
(
SELECT MAX( [lgh_number] )
FROM   [dbo].[legheader]
WHERE  UPPER( [lgh_outstatus] )  = 'CMP'
AND [lgh_primary_trailer] = @EXP_ID
)
AND [ord_hdrnumber] <> 0
AND [stp_sequence]  =
(
SELECT MAX( STP1.[stp_sequence] )
FROM   [dbo].[stops] STP1
WHERE  STP1.[lgh_number]   =
(
SELECT MAX( [lgh_number] )
FROM   [dbo].[legheader]
WHERE  UPPER( [lgh_outstatus] )  = 'CMP'
AND [lgh_primary_trailer] = @EXP_ID
)
AND [ord_hdrnumber] <> 0
)
END
ELSE IF UPPER( @EXP_IDTYPE ) = 'TRC'
BEGIN
SELECT @EXP_CITY    = [stp_city]
, @EXP_ROUTETO = [cmp_id]
FROM   [dbo].[stops]
WHERE  [lgh_number]        = ( SELECT MAX( [lgh_number] ) FROM [dbo].[legheader] WHERE UPPER( [lgh_outstatus] ) = 'CMP' AND [lgh_tractor] = @EXP_ID )
AND [ord_hdrnumber] <> 0
AND [stp_sequence]  =
(
SELECT MAX( STP1.[stp_sequence] )
FROM   [dbo].[stops] STP1
WHERE  STP1.[lgh_number]   = ( SELECT MAX( [lgh_number] ) FROM [dbo].[legheader] WHERE UPPER( [lgh_outstatus] ) = 'CMP' AND [lgh_tractor] = @EXP_ID )
AND [ord_hdrnumber] <> 0
)
END
END -- GI_STRING1
END

-- End UNKNOWN @routeto

--select @EXP_Priority
IF UPPER( @EXP_CODE ) = 'PRE'
OR @EXP_PRIORITY = 3 -- IS a PM DUE
BEGIN
IF ( SELECT ISNULL( [gi_integer1], 0 ) FROM [dbo].[generalinfo] WHERE UPPER( [gi_name] ) = 'SHOPLINK' ) = 2
BEGIN
--MRH Progressive PMS
IF @EXP_PERCENT >= 100
AND ( SELECT ISNULL( [gi_string1], 'Y' ) FROM [dbo].[generalinfo] WHERE UPPER( [gi_name] ) = 'Shoplink_exp' ) = 'Y'
SET @EXP_PRIORITY = 1
ELSE
BEGIN
-- 2.01 ENHANCEMENT, PRIORITY LOOK UP
IF NOT EXISTS ( SELECT [descript] FROM [dbo].[TMTPM] WHERE [codekey] = @EXP_CODEKEY AND [compcode] = @EXP_COMPCODE )
BEGIN
SET @EXP_PRIORITY = 9
END
ELSE
BEGIN
SELECT @EXP_PRIORITY = ISNULL( [exp_priority], 9 )
FROM   [dbo].[TMTPM]
WHERE  [codekey]      = @EXP_CODEKEY
AND [compcode] = @EXP_COMPCODE

IF ISNULL( @EXP_PRIORITY, '' ) = ''
BEGIN
SET @EXP_PRIORITY = 9
END
END
END -- END Progressive pms
END -- END GI setting =- 2
END -- END PRE Expiration type
ELSE IF @EXP_STATUS = 1
AND UPPER( @EXP_CODE ) <> 'OUT' --Unit is in shop
BEGIN
IF @DEBUG = 1
PRINT 'Unit Is in Shop'

IF @EXP_ISPROMISEDT = 'N'
SET @EXP_COMPLDATE = DATEADD( DAY, @EXP_DAYSINSHOP, GETDATE())

--SELECT @EXP_COMPLDATE = CAST(CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS VARCHAR(12)) AS DATETIME)
SELECT @EXP_COMPLDATE = CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS DATETIME)

SET @EXP_PRIORITY = ISNULL( @EXP_STATUS, 1 )

IF ISNULL(( SELECT gi_string2 FROM generalinfo WHERE gi_name = 'ShopLinkOptions' ), '' ) > ''
SELECT @EXP_PRIORITY = gi_string2
FROM   generalinfo
WHERE  gi_name = 'ShopLinkOptions'
ELSE
SET @EXP_PRIORITY = ISNULL( @EXP_STATUS, 1 )
END
ELSE IF @EXP_STATUS > 1
AND UPPER( @EXP_CODE ) <> 'OUT' -- WORK PENDING
BEGIN
IF @DEBUG = 1
BEGIN
PRINT 'UNIT HAS WORK PENDING'

SELECT @EXP_COMPLDATE
END

IF @EXP_ISPROMISEDT = 'N'
SET @EXP_COMPLDATE = DATEADD( DAY, @EXP_MAXDAYSINSHOP, GETDATE())

--SELECT @EXP_COMPLDATE = CAST(CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS VARCHAR(12)) AS DATETIME)
SELECT @EXP_COMPLDATE = CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS DATETIME)

SET @EXP_PRIORITY = 9

IF @DEBUG = 1
BEGIN
PRINT 'UNIT HAS WORK PENDING2'

SELECT @EXP_COMPLDATE
END
END
ELSE IF UPPER( @EXP_CODE ) <> 'OUT'
BEGIN
IF @DEBUG = 1
PRINT 'Else Everthing else'

IF @EXP_ISPROMISEDT = 'N'
SET @EXP_COMPLDATE = DATEADD( DAY, @EXP_MAXDAYSINSHOP, GETDATE())

--SELECT @EXP_COMPLDATE = CAST(CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS VARCHAR(12)) AS DATETIME)
SELECT @EXP_COMPLDATE = CAST(CAST(@EXP_COMPLDATE AS SMALLDATETIME) AS DATETIME)

SET @EXP_PRIORITY = ISNULL( @EXP_STATUS, 9 ) -- this will be a 2
END

-------------------- NEW VERSION -------------------------------
-- Use TMT_expirations table to identify and process expirations.
-- If there is no order ID passed in,
--                             check for duplicate open exp,
--                                             if not found insert the expiration
--                                             if found update (percent due, date etc.).
-- If a order id is passed in
--             use comp code and unit, unit type, to find any assoicated expirations and complete them.
--             Check for existing order expiration
--                             If exists, update
--              If not exists create a new order expiration.
-- @TMW_EXP_ID
IF @INSERT_NEW_EXPIRATION = 1 -- PM or order that does not already exist.
BEGIN
IF @DEBUG = 1
PRINT 'New Expiration'

IF @DEBUG = 1
PRINT 'EXP_COMPLDATE BEFORE EXPIRATION:' + CONVERT( VARCHAR(30), @EXP_COMPLDATE )

-- Test to see that the users have not botched the data in the expiration table.
IF
(
SELECT COUNT( 0 )
FROM   expiration
WHERE  exp_idtype             = @EXP_IDTYPE
AND exp_id             = @EXP_ID
AND exp_code           = @EXP_CODE
AND exp_description    = @EXP_DESCRIPTION
AND exp_completed      = 'N' -- 10/06/2016 MRH
AND exp_expirationdate = @EXP_EXPIRATIONDATE
) = 0
BEGIN
SET @EXP_OUTKEY = NULL

INSERT [dbo].[expiration] ( [exp_idtype]
, [exp_id]
, [exp_code]
, [exp_expirationdate]
, [exp_routeto]
, [exp_city]
, [exp_priority]
, [exp_compldate]
, [exp_milestoexp]
, [exp_completed]
, [exp_description]
, [exp_updateby]
, [exp_updateon]
, [exp_creatdate] )
VALUES ( @EXP_IDTYPE
, @EXP_ID
, @EXP_CODE
, @EXP_EXPIRATIONDATE
, @EXP_ROUTETO
, @EXP_CITY
, @EXP_PRIORITY
, @EXP_COMPLDATE
, @EXP_MILESTOEXP
, @EXP_COMPLETED
, @EXP_DESCRIPTION
, 'AMS Interface'
, GETDATE()
, GETDATE())

SELECT @EXP_OUTKEY = SCOPE_IDENTITY()

IF @DEBUG = 1
BEGIN
PRINT 'UPDATING tmt_expirations adding the Exp_OutKey:' + CONVERT( VARCHAR(20), @EXP_OUTKEY )
PRINT 'texp_id:' + ISNULL( CONVERT( VARCHAR(20), @TMW_EXP_ID ), 'NULL' )
END

UPDATE TMT_Expirations
SET    EXP_KEY = @EXP_OUTKEY
, EXP_OUTKEY = @EXP_OUTKEY
WHERE  texp_id = @TMW_EXP_ID
END -- Bad data
END

IF @ORDERID <> -1 -- Order, close any existing expirations based on the PM
BEGIN
IF @DEBUG = 1
PRINT 'Closing assoicated PM Expirations'

IF
(
SELECT COUNT( 1 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
AND EXP_COMPCODE                 = @EXP_COMPCODE
AND EXP_CODEKEY                  = @EXP_CODEKEY
AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND UPPER( EXP_CODE )            <> 'INSHOP'
AND UPPER( EXP_CODE )            <> 'PEND'
) > 0
BEGIN
IF @DEBUG = 1
PRINT 'Update Expiration'

UPDATE [dbo].[expiration]
SET    exp_completed = 'Y'
WHERE  exp_key IN
(
SELECT EXP_KEY
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
AND EXP_COMPCODE                 = @EXP_COMPCODE
AND EXP_CODEKEY                  = @EXP_CODEKEY
AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND UPPER( EXP_CODE )            <> 'INSHOP'
AND UPPER( EXP_CODE )            <> 'PEND'
)

IF @DEBUG = 1
PRINT 'Update Expiration1'

UPDATE TMT_Expirations
SET    EXP_COMPLETED = 'Y'
, EXP_ORDERID = @ORDERID
WHERE  EXP_KEY IN
(
SELECT EXP_KEY
FROM   TMT_Expirations
WHERE  EXP_IDTYPE            = @EXP_IDTYPE
AND EXP_ID            = @EXP_ID
AND EXP_COMPCODE      = @EXP_COMPCODE
AND EXP_CODEKEY       = @EXP_CODEKEY
AND UPPER( EXP_CODE ) <> 'INSHOP'
AND UPPER( EXP_CODE ) <> 'PEND'
)

IF @DEBUG = 1
PRINT 'Update Expiration2'
END
ELSE IF ( SELECT COUNT( 1 ) FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id AND ISNULL( EXP_COMPLETED, 'N' ) = 'Y' ) > 0
BEGIN
IF @DEBUG = 1
PRINT 'Setting inshop to uncompleted. TMW_EXP_ID:' + CONVERT( VARCHAR(20), @TMW_EXP_ID )

UPDATE [dbo].[expiration]
SET    exp_completed = 'N'
WHERE  exp_key = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )

UPDATE TMT_Expirations
SET    EXP_COMPLETED = 'N'
WHERE  @TMW_EXP_ID = texp_id
END
END

IF @INSERT_NEW_EXPIRATION <> 1 -- Update an existing Expiration
BEGIN
IF @DEBUG = 1
PRINT 'Start Update an existing Expiration 1'

IF @DEBUG = 1
BEGIN
PRINT '@TMW_EXP_ID:' + CONVERT( VARCHAR(20), ISNULL( @TMW_EXP_ID, 0 ))

SELECT @EXP_IDTYPE         AS EXP_IDTYPE
, @EXP_ID             AS EXP_ID
, @EXP_COMPCODE       AS EXP_COMPCODE
, @EXP_CODEKEY        AS EXP_CODEKEY
, @EXP_COMPLETED      AS EXP_COMPLETED
, @EXP_EXPIRATIONDATE AS [EXP_EXPIRATIONDATE]
, @EXP_COMPLDATE      AS exp_compldate

IF @EXP_ISPROMISEDT = 'N'
BEGIN
SELECT 'Testing'
, *
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                                  = @EXP_IDTYPE
AND EXP_ID                                  = @EXP_ID
AND ( ISNULL( EXP_COMPCODE, @EXP_COMPCODE ) = @EXP_COMPCODE OR LEN( EXP_COMPCODE ) = 0 )
AND ( ISNULL( EXP_CODEKEY, @EXP_CODEKEY )   = @EXP_CODEKEY OR LEN( EXP_CODEKEY ) = 0 )
AND ISNULL( EXP_COMPLETED, 'N' )            = 'N'
AND [EXP_EXPIRATIONDATE]                    <> @EXP_EXPIRATIONDATE
END
ELSE
BEGIN
SELECT 'Testing'
, *
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                                  = @EXP_IDTYPE
AND EXP_ID                                  = @EXP_ID
AND ( ISNULL( EXP_COMPCODE, @EXP_COMPCODE ) = @EXP_COMPCODE OR LEN( EXP_COMPCODE ) = 0 )
AND ( ISNULL( EXP_CODEKEY, @EXP_CODEKEY )   = @EXP_CODEKEY OR LEN( EXP_CODEKEY ) = 0 )
--AND ISNULL( EXP_COMPLETED, 'N' )            = 'N'
AND [EXP_EXPIRATIONDATE]                    <> @EXP_EXPIRATIONDATE
END
END

-- Verify that something has changed before updating the expiration. Expiration date is a special case to avoid duplicate keys.
IF @EXP_ISPROMISEDT = 'N'
BEGIN
SELECT @ROWS = COUNT( 0 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
AND ( EXP_COMPCODE               = @EXP_COMPCODE OR LEN( EXP_COMPCODE ) = 0 )
AND ( EXP_CODEKEY                = @EXP_CODEKEY OR LEN( EXP_CODEKEY ) = 0 )
AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND [EXP_EXPIRATIONDATE]         <> @EXP_EXPIRATIONDATE
END
ELSE
BEGIN
SELECT @ROWS = COUNT( 0 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE               = @EXP_IDTYPE
AND EXP_ID               = @EXP_ID
AND ( EXP_COMPCODE       = @EXP_COMPCODE OR LEN( EXP_COMPCODE ) = 0 )
AND ( EXP_CODEKEY        = @EXP_CODEKEY OR LEN( EXP_CODEKEY ) = 0 )
--AND ISNULL( EXP_COMPLETED, 'N' ) = 'N'
AND [EXP_EXPIRATIONDATE] <> @EXP_EXPIRATIONDATE
END

IF @ROWS > 0
BEGIN
IF @DEBUG = 1
PRINT 'Updating expiration due date. TMW_EXP_ID:' + CONVERT( VARCHAR(20), @TMW_EXP_ID )

IF @DEBUG = 1
PRINT 'EXP_COMPLETED:' + @EXP_COMPLETED

IF @DEBUG = 1
PRINT 'EXP_EXPIRATIONDATE:' + CONVERT( VARCHAR(30), @EXP_EXPIRATIONDATE )

IF @DEBUG = 1
PRINT 'EXP_COMPLDATE:' + CONVERT( VARCHAR(30), @EXP_COMPLDATE )

IF @DEBUG = 1
PRINT 'EXP_PRIORITY:' + @EXP_PRIORITY

IF @DEBUG = 1
PRINT 'EXP_DESCRIPTION:' + @EXP_DESCRIPTION

IF @DEBUG = 1
PRINT 'EXP_CODE:' + @EXP_CODE

IF @DEBUG = 1
PRINT 'EXP_ROUTETO:' + @EXP_ROUTETO

IF @DEBUG = 1
PRINT 'EXP_CITY:' + CONVERT( VARCHAR(20), ISNULL( @EXP_CITY, '' ))

IF @DEBUG = 1
SELECT EXP_KEY AS [Getting EXP_Key]
FROM   TMT_Expirations
WHERE  @TMW_EXP_ID = texp_id

UPDATE [dbo].[expiration]
SET    [exp_expirationdate] = @EXP_EXPIRATIONDATE
, [exp_completed] = @EXP_COMPLETED
, [exp_compldate] = @EXP_COMPLDATE
, [exp_priority] = @EXP_PRIORITY
, [exp_description] = @EXP_DESCRIPTION
, [exp_code] = @EXP_CODE
, [exp_routeto] = @EXP_ROUTETO
, [exp_city] = @EXP_CITY
, [exp_updateby] = 'AMS Interface'
, [exp_updateon] = GETDATE()
WHERE  exp_key = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )

SELECT @rowcount = @@ROWCOUNT

IF @DEBUG = 1
BEGIN
PRINT @rowcount
PRINT 'Updated [expiration]'

SELECT 'Updated [expiration]'
, *
FROM   [dbo].[expiration]
WHERE  exp_key = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )
END

UPDATE TMT_Expirations
SET    [EXP_EXPIRATIONDATE] = @EXP_EXPIRATIONDATE
, [EXP_COMPLETED] = @EXP_COMPLETED
, [EXP_COMPLDATE] = @EXP_COMPLDATE
, [EXP_PRIORITY] = @EXP_PRIORITY
, [EXP_DESCRIPTION] = @EXP_DESCRIPTION
, [EXP_CODE] = @EXP_CODE
, [EXP_ROUTETO] = @EXP_ROUTETO
, EXP_COMPCODE = CASE WHEN LEN( EXP_COMPCODE ) = 0 THEN @EXP_COMPCODE
ELSE EXP_COMPCODE
END
, EXP_CODEKEY = CASE WHEN LEN( EXP_CODEKEY ) = 0 THEN @EXP_CODEKEY
ELSE EXP_CODEKEY
END
WHERE  EXP_KEY = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )

SELECT @rowcount = @@ROWCOUNT

IF @DEBUG = 1
BEGIN
PRINT @rowcount
PRINT 'Updated [TMT_Expirations]'

SELECT 'Updated [TMT_Expirations]'
, *
FROM   [dbo].TMT_Expirations
WHERE  EXP_KEY = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )
END
END
ELSE IF
(
SELECT COUNT( 0 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                                = @EXP_IDTYPE
AND EXP_ID                                = @EXP_ID
AND ISNULL( EXP_COMPCODE, @EXP_COMPCODE ) = @EXP_COMPCODE
AND ISNULL( EXP_CODEKEY, @EXP_COMPCODE )  = @EXP_CODEKEY
AND ISNULL( EXP_COMPLETED, 'N' )          = 'N'
AND
(
[EXP_COMPLETED]                       <> @EXP_COMPLETED
OR [EXP_COMPLDATE]                    <> @EXP_COMPLDATE
OR [EXP_PRIORITY]                     <> @EXP_PRIORITY
OR [EXP_DESCRIPTION]                  <> @EXP_DESCRIPTION
OR [EXP_CODE]                         <> @EXP_CODE
OR [EXP_ROUTETO]                      <> @EXP_ROUTETO
)
) > 0
BEGIN
IF @DEBUG = 1
PRINT 'Updating an existing expriation 2. TMW_EXP_ID:' + CONVERT( VARCHAR(20), @TMW_EXP_ID )

IF @DEBUG = 1
PRINT 'EXP_COMPLETED:' + @EXP_COMPLETED

IF @DEBUG = 1
PRINT 'EXP_EXPIRATIONDATE:' + CONVERT( VARCHAR(30), @EXP_EXPIRATIONDATE )

IF @DEBUG = 1
PRINT 'EXP_COMPLDATE:' + CONVERT( VARCHAR(30), @EXP_COMPLDATE )

IF @DEBUG = 1
PRINT 'EXP_PRIORITY:' + @EXP_PRIORITY

IF @DEBUG = 1
PRINT 'EXP_DESCRIPTION:' + @EXP_DESCRIPTION

IF @DEBUG = 1
PRINT 'EXP_CODE:' + @EXP_CODE

IF @DEBUG = 1
PRINT 'EXP_ROUTETO:' + @EXP_ROUTETO

IF @DEBUG = 1
PRINT 'EXP_CITY:' + CONVERT( VARCHAR(20), @EXP_CITY )

UPDATE [dbo].[expiration]
SET    [exp_completed] = @EXP_COMPLETED
, [exp_compldate] = @EXP_COMPLDATE
, [exp_priority] = @EXP_PRIORITY
, [exp_description] = @EXP_DESCRIPTION
, [exp_code] = @EXP_CODE
, [exp_routeto] = @EXP_ROUTETO
, [exp_city] = @EXP_CITY
, [exp_updateby] = 'AMS Interface'
, [exp_updateon] = GETDATE()
WHERE  exp_key = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )

--where EXP_IDTYPE = @EXP_IDTYPE and EXP_ID = @EXP_ID and EXP_COMPCODE = @EXP_COMPCODE AND EXP_CODEKEY = @EXP_CODEKEY and ISNULL(EXP_COMPLETED, 'N') = 'N')
UPDATE TMT_Expirations
SET    [EXP_COMPLETED] = @EXP_COMPLETED
, [EXP_COMPLDATE] = @EXP_COMPLDATE
, [EXP_PRIORITY] = @EXP_PRIORITY
, [EXP_DESCRIPTION] = @EXP_DESCRIPTION
, [EXP_CODE] = @EXP_CODE
, [EXP_ROUTETO] = @EXP_ROUTETO
WHERE  EXP_KEY = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )
END
ELSE IF @ReOpenPM = 'Y'
BEGIN -- This is a special case. See notes above in the PM section.
SET @EXP_COMPLETED = 'N'

IF @DEBUG = 1
PRINT 'Reopening an existing PM. TMW_EXP_ID:' + CONVERT( VARCHAR(20), @TMW_EXP_ID )

IF @DEBUG = 1
PRINT 'EXP_COMPLETED:' + @EXP_COMPLETED

IF @DEBUG = 1
PRINT 'EXP_EXPIRATIONDATE:' + CONVERT( VARCHAR(30), @EXP_EXPIRATIONDATE )

IF @DEBUG = 1
PRINT 'EXP_COMPLDATE:' + CONVERT( VARCHAR(30), @EXP_COMPLDATE )

IF @DEBUG = 1
PRINT 'EXP_PRIORITY:' + @EXP_PRIORITY

IF @DEBUG = 1
PRINT 'EXP_DESCRIPTION:' + @EXP_DESCRIPTION

IF @DEBUG = 1
PRINT 'EXP_CODE:' + @EXP_CODE

IF @DEBUG = 1
PRINT 'EXP_ROUTETO:' + @EXP_ROUTETO

IF @DEBUG = 1
PRINT 'EXP_CITY:' + CONVERT( VARCHAR(20), @EXP_CITY )

UPDATE [dbo].[expiration]
SET    [exp_completed] = @EXP_COMPLETED
, [exp_compldate] = @EXP_COMPLDATE
, [exp_priority] = @EXP_PRIORITY
, [exp_description] = @EXP_DESCRIPTION
, [exp_code] = @EXP_CODE
, [exp_routeto] = @EXP_ROUTETO
, [exp_city] = @EXP_CITY
, [exp_updateby] = 'AMS Interface'
, [exp_updateon] = GETDATE()
WHERE  exp_key = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )

UPDATE TMT_Expirations
SET    [EXP_COMPLETED] = @EXP_COMPLETED
, [EXP_COMPLDATE] = @EXP_COMPLDATE
, [EXP_PRIORITY] = @EXP_PRIORITY
, [EXP_DESCRIPTION] = @EXP_DESCRIPTION
, [EXP_CODE] = @EXP_CODE
, [EXP_ROUTETO] = @EXP_ROUTETO
WHERE  EXP_KEY = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )
END
ELSE IF @EXP_CODE = 'OUT'
BEGIN
IF
(
SELECT COUNT( 0 )
FROM   TMT_Expirations
WHERE  EXP_IDTYPE                       = @EXP_IDTYPE
AND EXP_ID                       = @EXP_ID
AND EXP_CODE                     = 'OUT'
AND ISNULL( EXP_COMPLETED, 'N' ) <> @OUTEXP_STATUS
) > 0
BEGIN
SET @EXP_COMPLETED = @OUTEXP_STATUS

IF @DEBUG = 1
PRINT 'Closing a OUT of service expiration. TMW_EXP_ID:' + CONVERT( VARCHAR(20), @TMW_EXP_ID )

IF @DEBUG = 1
PRINT 'EXP_COMPLETED:' + @EXP_COMPLETED

IF @DEBUG = 1
PRINT 'EXP_EXPIRATIONDATE:' + CONVERT( VARCHAR(30), @EXP_EXPIRATIONDATE )

IF @DEBUG = 1
PRINT 'EXP_COMPLDATE:' + CONVERT( VARCHAR(30), @EXP_COMPLDATE )

IF @DEBUG = 1
PRINT 'EXP_PRIORITY:' + @EXP_PRIORITY

IF @DEBUG = 1
PRINT 'EXP_DESCRIPTION:' + @EXP_DESCRIPTION

IF @DEBUG = 1
PRINT 'EXP_CODE:' + @EXP_CODE

IF @DEBUG = 1
PRINT 'EXP_ROUTETO:' + @EXP_ROUTETO

IF @DEBUG = 1
PRINT 'EXP_CITY:' + CONVERT( VARCHAR(20), @EXP_CITY )

UPDATE [dbo].[expiration]
SET    [exp_completed] = @EXP_COMPLETED
, [exp_compldate] = @EXP_COMPLDATE
, [exp_priority] = @EXP_PRIORITY
, [exp_description] = @EXP_DESCRIPTION
, [exp_code] = @EXP_CODE
, [exp_routeto] = @EXP_ROUTETO
, [exp_city] = @EXP_CITY
, [exp_updateby] = 'AMS Interface'
, [exp_updateon] = GETDATE()
WHERE  exp_key = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )

UPDATE TMT_Expirations
SET    [EXP_COMPLETED] = @EXP_COMPLETED
, [EXP_COMPLDATE] = @EXP_COMPLDATE
, [EXP_PRIORITY] = @EXP_PRIORITY
, [EXP_DESCRIPTION] = @EXP_DESCRIPTION
, [EXP_CODE] = @EXP_CODE
, [EXP_ROUTETO] = @EXP_ROUTETO
WHERE  EXP_KEY = ( SELECT EXP_KEY FROM TMT_Expirations WHERE @TMW_EXP_ID = texp_id )
END
END
ELSE -- Nothing has changed exit without calling the update status update procs.
GOTO NO_ERROR_EXIT -- Do not call the status update procs or we will end up in an endless trigger loop.
END

-- END NEW VERSION CHANGES
IF @DEBUG = 1
PRINT 'Update unit status'

-- If there  is no identity key try and get one from the tmt_expirations.
IF ISNULL( @EXP_OUTKEY, -1 ) = -1
SELECT @EXP_OUTKEY = [EXP_KEY]
FROM   TMT_Expirations
WHERE  [EXP_ID]              = @EXP_ID
AND [EXP_DESCRIPTION] = @EXP_DESCRIPTION

-- Still didn't find one, return -1
IF ISNULL( @EXP_OUTKEY, -1 ) = -1
SELECT @EXP_OUTKEY = -1

-- MRH 11/19/03 UPDATE THE TMWS TRC / TRL STATUS
IF UPPER( @EXP_IDTYPE ) = 'TRC'
BEGIN
--EXEC [dbo].[TRC_EXPSTATUS] @EXP_KEY --TMWSuite changed in 05
EXEC [dbo].[trc_expstatus] @EXP_ID
END
ELSE
BEGIN
EXEC [dbo].[trl_expstatus] @EXP_ID
END

SET NOCOUNT OFF

GOTO NO_ERROR_EXIT

ERROR_EXIT:
SET @EXP_OUTKEY = @ERRORCODE

IF @DEBUG = 1
PRINT 'EXPERROR:' + ISNULL( CONVERT( VARCHAR(20), @ERRORCODE ), 'NULL' )

NO_ERROR_EXIT:
IF @DEBUG = 1
PRINT 'EXP_OUTKEY:' + ISNULL( CONVERT( VARCHAR(30), @EXP_OUTKEY ), 'NULL' )

IF @DEBUG = 1
PRINT 'END EXPIRATION_ADD_SP'
GO
GRANT EXECUTE ON  [dbo].[EXPIRATION_ADD_SP] TO [public]
GO
