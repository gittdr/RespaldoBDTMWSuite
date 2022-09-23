SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
-- PROVIDES TMT_TRACTOR_UPDATE_SP_V1
-- REQUIRES none
-- MINVERSION 18.2.5

--- TMT_TRACTOR_UPDATE_SP_V1
--- Custom proc changed to support re-use of existing fields and new custom fields without impacting existing customers.
--- Changes made to the non custom section of this proc should be replicated to TMT_TRACTOR_UPDATE_SP

--- SK  12/07/2018 AM-304701 Commented out update to GrossWeight. Should only update TareWeight
--- MRH 10/14/16 Cloned original proc to create this custom version.
--- MRH 02/20/17 JIRA https://jira.tmwsystems.com/browse/WE-205401 Commented out standard branch update.

--MRH JIRA INT-200029 custom Enhancement
-- Changes to existing data.
--		@COSTCTCODE sent to TMW Branch. Send to trc_fleet, trl_fleet (change is in TMW update proc [TMT_TRACTOR_UPDATE_SP])
--      @UNITUSERFLD1 noramally sent to trc_type1, send to trc_axle, trl_axle (change is in TMW update proc [TMT_TRACTOR_UPDATE_SP])
-- New data sent to TMW
--		Empdrvid (join to employee.EMPDRVID for name)	send to trc_teamleader, trl_teamleader
--		Capacity										send to trc_grossweight, trl_grossweight
--		Option to send ACTIVCODE to trc_type			send to trc_type1
--		Option to send ACTIVCODE to trl_type			send to trl_type1
--		Option to send UNITTYPE (@TYPE) to trc_type		send to trc_type1
--		Option to send UNITTYPE (@TYPE) to trl_type		send to trl_type1
------
--- MRH 07/15/2015 Added ablity to include only selected unit customers on the transfer.
--- TMT AMS from TMWSYSTEMS
--- CHANGED 02/06/2014  MB PCR:
--- CHANGED 08/21/2013  MB PCR: 9006
--- CHANGED 12/20/2012  MB PCR:8558
---  CHANGED 06/15/2010 JP
---  CHANGED 06/01/2010 MB
---  CHANGED 02/04/2010 MB
---  CHANGED 12/15/2009 MB
---  CHANGED 02/06/2009 MB
---  CHANGED 01/12/2009 MH
---  CHANGED 03/15/2007 MB
---  CHANGED 12/20/2006 MB
---  CHANGED 11/17/2006 MH
---  CHANGED 05/17/2006 MB
----------------------------------

CREATE PROCEDURE [dbo].[TMT_TRACTOR_UPDATE_SP_V1]
@TRC_NUMBER          VARCHAR(8)
, @TRC_MPG             NUMERIC(15, 6)
, @TRC_OPERCOSTPERMI   NUMERIC(15, 6)
, @TRC_LICSTATE        CHAR(2)
, @TRC_LICNUM          VARCHAR(12)
, @TRC_MAKE            VARCHAR(12)
, @TRC_MODEL           VARCHAR(12)
, @TRC_MODELYEAR       VARCHAR(12)
, @TRC_CURRENTHUB      INT
, @TRC_SERIALNO        VARCHAR(24)
, @UNIT_IDTYPE         VARCHAR(12)
, @COMPANY             VARCHAR(6)       = NULL
--MRH 10/6/05
, @DIVISION            VARCHAR(6)       = NULL
--MRH 10/6/05
, @TERMINAL            VARCHAR(6)       = NULL
--MRH 10/6/05
, @BRANCH              VARCHAR(12)      = NULL
--MRH 05/15/06 Unit branch (Cost center in Transman)
, @TRC_UDF1            VARCHAR(12)      = NULL
, @TRC_UDF2            VARCHAR(12)      = NULL
, @TRC_UDF3            VARCHAR(12)      = NULL
, @TRC_UDF4            VARCHAR(12)      = NULL
, @TRC_UDF5            VARCHAR(12)      = NULL
, @TRC_UDF6            VARCHAR(12)      = NULL
, @TRC_UDF7            VARCHAR(12)      = NULL
, @TRC_UDF8            VARCHAR(12)      = NULL
, @TRC_MISC1           VARCHAR(12)      = NULL
, @TRC_MISC2           VARCHAR(12)      = NULL
, @TRC_MISC3           VARCHAR(12)      = NULL
, @TRC_MISC4           VARCHAR(12)      = NULL
, @TRC_MISC5           VARCHAR(12)      = NULL
, @TRC_MISC6           VARCHAR(12)      = NULL
, @TRC_MISC7           VARCHAR(12)      = NULL
, @TRC_MISC8           VARCHAR(12)      = NULL
, @PREFIX              VARCHAR(32)      = NULL
, @WEIGHT              [NUMERIC](15, 6) = NULL
, @WHEELBASE           [INTEGER]        = NULL
, @CUSTOMERNAME        [VARCHAR](12)    = NULL
, @TRC_TANKCAPACITY    INT
--KPM 8/7/12   ADDED TRACTOR TANK CAPACITY..NO TRAILER EQUVILENT
, @TRC_MCTID           VARCHAR(20)      = NULL
--KPM 8/7/12   ADDED TRACTOR MOBILE COMMUNICATION TERMINAL ID..NO TRAILER EQUVILENT
, @FIFTHWHEELTRAVEL    INTEGER          = NULL
-- trc_fifthwhltvl
, @FIFTHWHEELTRAVELUOM VARCHAR(12)      = NULL
-- trc_fifthwhltvl_uom
, @FIFTHWHEELHEIGHT    [INTEGER]        = NULL
-- trc_fifthwheelht
, @FIFTHWHEELHEIGHTUOM VARCHAR(12)      = NULL
-- trc_fifthwheelht_uom
, @MCTPARTNAME         VARCHAR(20)      = NULL
, @MCTSERIALNUMBER     VARCHAR(20)      = NULL
--MRH JIRA INT-200029 Custom Enhancement
, @EMPLOYEE            VARCHAR(60)      = NULL
, @CAPACITY            CHAR(12)         = NULL
, @TRL_TYPE1           VARCHAR(6)       = NULL
, @TRC_TYPE1           VARCHAR(6)       = NULL
-------
, @EXP_KEY             INT OUTPUT
AS
BEGIN
PRINT 'START TMT_TRACTOR_UPDATE_SP_V1'

DECLARE @ERRORCODE INT
DECLARE @TMTSERVER VARCHAR(25)
DECLARE @TMTDB VARCHAR(25)
DECLARE @TMTUSER VARCHAR(25)
DECLARE @TMTPASSWORD VARCHAR(25)
DECLARE @SQL NVARCHAR(4000)
DECLARE @METERTYPE VARCHAR(12)
DECLARE @VALID_REVCLASS INT
DECLARE @V_USER VARCHAR(255)
DECLARE @V_MSG VARCHAR(255)
DECLARE @ABBR CHAR(6)
DECLARE @TRL_LEN DECIMAL --KPM 8/7/12   ADDED TRAILER LENGTH..NO TRACTOR EQUVILENT
DECLARE @TRC_GROSSWGT INT --KPM 8/7/12   ADDED TRACTOR GROSS WEIGHT..NO TRAILER EQUVILENT
DECLARE @TMT_UNIT_TYPE VARCHAR(12)
DECLARE @CustRestrictSet VARCHAR(60)

SET @ERRORCODE = 0

--Option to restrict by AMS Customer name.
IF ( SELECT COUNT( 0 ) FROM generalinfo WHERE gi_name = 'ShopLinkCustRestrict' AND ( ISNULL( gi_string1, '' ) <> '' )) > 0
BEGIN
SELECT @CustRestrictSet = gi_string1
FROM   generalinfo
WHERE  gi_name = 'ShopLinkCustRestrict'

IF ( SELECT CHARINDEX( @CUSTOMERNAME, @CustRestrictSet )) <= 0
RETURN
END

-- START TESTING IN TRACTOR OR TRAILER
-- Moved to top to insure that the correct meter type is selected.
SELECT @TMT_UNIT_TYPE = @UNIT_IDTYPE

IF @UNIT_IDTYPE <> 'TRC'
OR @UNIT_IDTYPE <> 'TRL'
BEGIN
IF EXISTS ( SELECT [TMWDESIGNATION] FROM [dbo].[TMTUNITTYPE] WITH ( NOLOCK ) WHERE [CODE] = @UNIT_IDTYPE )
BEGIN
SELECT @UNIT_IDTYPE = [TMWDESIGNATION]
FROM   [dbo].[TMTUNITTYPE] WITH ( NOLOCK )
WHERE  [CODE] = @UNIT_IDTYPE
END
END
ELSE
BEGIN
SELECT @ERRORCODE = -1

GOTO ERROR_EXIT
END

IF @UNIT_IDTYPE = 'TRACTOR'
BEGIN
SELECT @UNIT_IDTYPE = 'TRC'

SELECT @METERTYPE = [GI_STRING3]
FROM   [GENERALINFO] WITH ( NOLOCK )
WHERE  [GI_NAME] = 'SHOPLINK'

SELECT @METERTYPE = ISNULL( @METERTYPE, 'ODOMETER' )
END

IF @UNIT_IDTYPE = 'TRAILER'
BEGIN
SELECT @UNIT_IDTYPE = 'TRL'

SELECT @METERTYPE = [GI_STRING4]
FROM   [GENERALINFO] WITH ( NOLOCK )
WHERE  [GI_NAME] = 'SHOPLINK'

SELECT @METERTYPE = ISNULL( @METERTYPE, 'HUB METER' )
END

SET @EXP_KEY = 0
SET @ERRORCODE = NULL

-- CALL TMT_ADDUNIT TO ADD THE UNIT OR GET CANNOT ADD ERRORCODE
EXEC [dbo].[TMT_ADDUNIT] @UNIT_IDTYPE
, @TRC_NUMBER
, @TRC_CURRENTHUB
, @EXP_KEY OUTPUT

-- ADDED MB

-- ERROR OUT IF UNIT DOES NOT EXITS AND CANNOT ADD IT
IF @ERRORCODE = -1
BEGIN
GOTO ERROR_EXIT
END

IF @UNIT_IDTYPE = 'TRC'
BEGIN
IF NOT EXISTS ( SELECT [TRC_NUMBER] FROM [dbo].[TRACTORPROFILE] WITH ( NOLOCK ) WHERE [TRC_NUMBER] = @TRC_NUMBER )
BEGIN
SELECT @ERRORCODE = -2

GOTO ERROR_EXIT
END
END --@UNIT_IDTYPE = 'TRC'
ELSE IF @UNIT_IDTYPE = 'TRL'
BEGIN
IF NOT EXISTS ( SELECT [TRL_ID] FROM [dbo].[TRAILERPROFILE] WITH ( NOLOCK ) WHERE [TRL_ID] = @TRC_NUMBER AND ISNULL( trl_ilt, 'N' ) = 'N' )
BEGIN
SELECT @ERRORCODE = -4

GOTO ERROR_EXIT
END
END

-- MRH 9/6/2010. Transman only has a single entry for these. Use the same one for both.
SELECT @TRL_LEN = @WHEELBASE

-- SELECT @TRC_GROSSWGT = @WEIGHT  -- Commented out change to update [TRC_GEOSSWEIGHT] Jira AM-304701

-- START OF CODE TO UPDATE TRACTOR OR TRAILER
-----------------------------------------------------------------------------------------------------------
-- Tractor update
-----------------------------------------------------------------------------------------------------------
IF @UNIT_IDTYPE = 'TRC'
BEGIN
IF ( ISNULL( @ERRORCODE, 0 )) = 0 -- CHECK ERRORCODE CONDITION
BEGIN --UPDATE THE PROFILE, ORIGIONAL CODE.
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_ams_type] = @TMT_UNIT_TYPE
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_MPG, 0 ) <> 0
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MPG] = @TRC_MPG
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_OPERCOSTPERMI, 0 ) <> 0
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_OPERCOSTPERMI] = @TRC_OPERCOSTPERMI
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_LICSTATE, '' ) <> ''
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_LICSTATE] = @TRC_LICSTATE
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_LICNUM, '' ) <> ''
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_LICNUM] = @TRC_LICNUM
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_MAKE, '' ) <> ''
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MAKE] = LEFT(@TRC_MAKE, 8)
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_MODEL, '' ) <> ''
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MODEL] = LEFT(@TRC_MODEL, 8)
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_MODELYEAR, '' ) <> ''
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_YEAR] = @TRC_MODELYEAR
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_SERIALNO, '' ) <> ''
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_SERIAL] = LEFT(@TRC_SERIALNO, 20)
WHERE  [TRC_NUMBER] = @TRC_NUMBER

-- START TRC_FIFTHWHLTVL AND TRC_FIFTHWHEELHT
SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'DistanceUnits'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@FIFTHWHEELTRAVELUOM, 6)

IF ISNULL( @FIFTHWHEELTRAVEL, -1 ) > 0
AND @VALID_REVCLASS > 0
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_FIFTHWHLTVL] = @FIFTHWHEELTRAVEL
, [TRC_FIFTHWHLTVL_UOM] = LEFT(@FIFTHWHEELTRAVELUOM, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'DistanceUnits'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@FIFTHWHEELHEIGHTUOM, 6)

IF ISNULL( @FIFTHWHEELHEIGHT, -1 ) > 0
AND @VALID_REVCLASS > 0
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_FIFTHWHEELHT] = @FIFTHWHEELHEIGHT
, [TRC_FIFTHWHEELHT_UOM] = LEFT(@FIFTHWHEELHEIGHTUOM, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

-- END TRC_FIFTHWHLTVL AND TRC_FIFTHWHEELHT

--IF ISNULL(@TRC_CURRENTHUB, 0) > 0
--BEGIN
--UPDATE  [dbo].[TRACTORPROFILE]
--SET     [TRC_CURRENTHUB] = @TRC_CURRENTHUB
--WHERE   [TRC_NUMBER] = @TRC_NUMBER
--AND [TRC_CURRENTHUB] < @TRC_CURRENTHUB
--END
IF ISNULL( @WHEELBASE, -1 ) <> -1
AND ( @WHEELBASE <> '' )
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_WHLTOBASE] = @WHEELBASE
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

/*  ELSE -- 6/15/2010 JDP REMOVED SO VALUE IS NOT OVERIDDEN IN TMWSUITE IF TRANSMAN IS NULL
BEGIN
UPDATE [dbo].[TRACTORPROFILE] SET [TRC_WHLTOBASE] =0
WHERE [TRC_NUMBER]=@TRC_NUMBER
END */
IF ISNULL( @WEIGHT, -1 ) <> -1
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_TAREWEIGHT] = @WEIGHT
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

/* ELSE -- 6/15/2010 JDP REMOVED SO VALUE IS NOT OVERIDDEN IN TMWSUITE IF TRANSMAN IS NULL
BEGIN
UPDATE [dbo].[TRACTORPROFILE] SET [TRC_TAREWEIGHT] = 0
WHERE [TRC_NUMBER]=@TRC_NUMBER
END */
IF ( ISNULL( @CUSTOMERNAME, '' ) <> '' )
AND EXISTS ( SELECT [PTO_ID] FROM [dbo].[PAYTO] WHERE [PTO_ID] = @CUSTOMERNAME )
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_OWNER] = @CUSTOMERNAME
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

/*ELSE -- 6/15/2010 JDP REMOVED SO VALUE IS NOT OVERIDDEN IN TMWSUITE IF TRANSMAN IS NULL
BEGIN
UPDATE [dbo].[TRACTORPROFILE] SET [TRC_OWNER] ='UNKNOWN'
WHERE [TRC_NUMBER]=@TRC_NUMBER
END */
IF ISNULL( @TRC_TANKCAPACITY, 0 ) <> 0
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_tank_capacity] = @TRC_TANKCAPACITY
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

-- Commented out change to update [trc_grosswgt] Jira AM-304701
--IF ISNULL(@TRC_GROSSWGT, 0) <> 0
--   BEGIN
--         UPDATE  [dbo].[TRACTORPROFILE]
--         SET     [trc_grosswgt] = @TRC_GROSSWGT
--         WHERE   [TRC_NUMBER] = @TRC_NUMBER
--  END
IF ISNULL( @TRC_MCTID, '' ) <> ''
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MCTID] = @TRC_MCTID
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END --- End of error condition?
END

-- END OF Tractor update

-----------------------------------------------------------------------------------------------------------
-- Trailer update
-----------------------------------------------------------------------------------------------------------
IF @UNIT_IDTYPE = 'TRL'
BEGIN
IF ( ISNULL( @ERRORCODE, 0 )) = 0 -- CHECK ERRORCODE CONDITION
BEGIN --UPDATE THE PROFILE, ORIGIONAL CODE.
UPDATE [dbo].[TRAILERPROFILE]
SET    [trl_ams_type] = @TMT_UNIT_TYPE
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @TRC_OPERCOSTPERMI, 0 ) <> 0
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_OPERCOSTMILE] = @TRC_OPERCOSTPERMI
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @TRC_LICSTATE, '' ) <> ''
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_LICSTATE] = @TRC_LICSTATE
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @TRC_LICNUM, '' ) <> ''
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_LICNUM] = @TRC_LICNUM
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @TRC_MAKE, '' ) <> ''
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_MAKE] = LEFT(@TRC_MAKE, 8)
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @TRC_MODEL, '' ) <> ''
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_MODEL] = LEFT(@TRC_MODEL, 8)
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @TRC_MODELYEAR, '' ) <> ''
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_YEAR] = @TRC_MODELYEAR
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @TRC_SERIALNO, '' ) <> ''
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_SERIAL] = LEFT(@TRC_SERIALNO, 20)
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

IF ISNULL( @WEIGHT, -1 ) <> -1
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_TAREWEIGHT] = @WEIGHT
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( TRL_ILT, 'N' ) = 'N'
END

/*ELSE -- 6/15/2010 JDP REMOVED SO VALUE IS NOT OVERIDDEN IN TMWSUITE IF TRANSMAN IS NULL
BEGIN
UPDATE [dbo].[TRAILERPROFILE] SET [TRL_TAREWEIGHT] =0
WHERE [TRL_ID]=@TRC_NUMBER  AND ISNULL(TRL_ILT, 'N') = 'N'
END*/
IF ISNULL( @WHEELBASE, -1 ) <> -1
AND ( @WHEELBASE <> '' )
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_KP_TO_AXLE1] = @WHEELBASE
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( TRL_ILT, 'N' ) = 'N'
END

/*ELSE -- 6/15/2010 JDP REMOVED SO VALUE IS NOT OVERIDDEN IN TMWSUITE IF TRANSMAN IS NULL
BEGIN
UPDATE [dbo].[TRAILERPROFILE] SET [TRL_KP_TO_AXLE1] =0
WHERE [TRL_ID]=@TRC_NUMBER  AND ISNULL(TRL_ILT, 'N') = 'N'
END*/
IF ( ISNULL( @CUSTOMERNAME, '' ) <> '' )
AND EXISTS ( SELECT [PTO_ID] FROM [dbo].[PAYTO] WHERE [PTO_ID] = @CUSTOMERNAME )
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_OWNER] = @CUSTOMERNAME
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( TRL_ILT, 'N' ) = 'N'
END

/*ELSE -- 6/15/2010 JDP REMOVED SO VALUE IS NOT OVERIDDEN IN TMWSUITE IF TRANSMAN IS NULL
BEGIN
UPDATE [dbo].[TRAILERPROFILE] SET [TRL_OWNER] ='UNKNOWN'
WHERE [TRL_ID]=@TRC_NUMBER AND ISNULL(TRL_ILT, 'N') = 'N'
END */
IF EXISTS
(
SELECT COL_NAME( E.id, E.colid ) AS relation_name
FROM   sysobjects a
, syscolumns E
WHERE  a.id                          = E.id
AND a.xtype                   = 'U'
AND a.name                    = 'TRAILERPROFILE'
AND COL_NAME( E.id, E.colid ) = 'trl_prefix'
)
AND ISNULL( @PREFIX, '' ) <> ''
BEGIN
SET @PREFIX = LEFT(@PREFIX, 32)
SET @SQL = N'UPDATE [dbo].[TRAILERPROFILE] SET [TRL_PREFIX] =@LOCALPREFIX
WHERE [TRL_ID]=@LOCALTRC_NUMBER AND isnull(trl_ilt, ''N'') = ''N'''

EXEC sp_executesql @SQL
, N'@LOCALPREFIX CHAR(32), @LOCALTRC_NUMBER VARCHAR(8) '
, @PREFIX
, @TRC_NUMBER
END

IF ( (
SELECT ISNULL( TRL_STARTDATE, '' )
FROM   [dbo].[TRAILERPROFILE]
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'
) = ''
)
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_STARTDATE] = GETDATE()
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'
END

IF ISNULL( @TRC_CURRENTHUB, 0 ) <> 0
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_CURRENTHUB] = @TRC_CURRENTHUB
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND [TRL_CURRENTHUB]       < @TRC_CURRENTHUB
AND ISNULL( trl_ilt, 'N' ) = 'N'
END

IF ISNULL( @TRL_LEN, 0 ) <> 0
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_LEN] = @TRL_LEN
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END
END
END

-- END of Trailer update

-----------------------------------------------------------------------------------------------------------
-- Update user defined field values
-----------------------------------------------------------------------------------------------------------
IF ( SELECT COUNT( 0 ) FROM GENERALINFO ( NOLOCK ) WHERE GI_NAME = 'SHOPLINK' AND GI_INTEGER4 = 1 ) > 0
BEGIN
---------------- Update company ----------------
-- Validate the company
IF ( SELECT gi_string1 FROM generalinfo WHERE gi_name = 'LegalEntity' ) = 'Y'
BEGIN
SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   LEGAL_ENTITY ( NOLOCK )
WHERE  ISNULL( LE_RETIRED, 'N' ) <> 'Y'
AND LE_ID                 = @COMPANY
END
ELSE
BEGIN
SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   LABELFILE ( NOLOCK )
WHERE  labeldefinition            = 'COMPANY'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = @COMPANY
END

IF @VALID_REVCLASS = 0
BEGIN
SET @COMPANY = NULL

SELECT @ERRORCODE = 101 -- Invalid company ID.
END

-- Update the company
IF @UNIT_IDTYPE = 'TRC'
AND ISNULL( @COMPANY, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 101
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_COMPANY] = @COMPANY
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END
ELSE IF ISNULL( @COMPANY, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 101
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_COMPANY] = @COMPANY
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'
END

---------------- Update Division ----------------
-- Validate the Division
EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRCTYPE1'
, @ABBR
, @ABBR
, 'Tractor Type1'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile ( NOLOCK )
WHERE  labeldefinition            = 'DIVISION'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = @DIVISION

IF @VALID_REVCLASS = 0
BEGIN
SET @DIVISION = NULL

SELECT @ERRORCODE = 102 -- Invalid division ID.
--GOTO ERROR_EXIT
END

-- Update the Division
IF @UNIT_IDTYPE = 'TRC'
AND ISNULL( @DIVISION, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 102
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_DIVISION] = @DIVISION
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END
ELSE IF ISNULL( @DIVISION, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 102
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_DIVISION] = @DIVISION
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'
END

---------------- Update Terminal ----------------
-- Validate the Terminal
SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile ( NOLOCK )
WHERE  labeldefinition            = 'TERMINAL'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = @TERMINAL

IF @VALID_REVCLASS = 0
BEGIN
SET @TERMINAL = NULL

SELECT @ERRORCODE = 103 -- Invalid Terminal ID
END

-- Update the Terminal
IF @UNIT_IDTYPE = 'TRC'
AND ISNULL( @TERMINAL, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 103
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_TERMINAL] = @TERMINAL
WHERE  [TRC_NUMBER] = @TRC_NUMBER
ELSE IF ISNULL( @TERMINAL, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 103
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_TERMINAL] = @TERMINAL
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

----------------------------------------------------------------------
-- Tractor unit type updates
----------------------------------------------------------------------
IF @UNIT_IDTYPE = 'TRC'
BEGIN
---------------- Update UNITTYPE1 ----------------
-- TRC_TYPE1
SET @ABBR = LEFT(@TRC_UDF1, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRCTYPE1'
, @ABBR
, @ABBR
, 'Tractor Type1'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRCTYPE1'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF1, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF1 = NULL

SELECT @ERRORCODE = 104 -- Invalid TrcType1.
END

IF ISNULL( @TRC_UDF1, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 104
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_TYPE1] = LEFT(@TRC_UDF1, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

---------------- Update UNITTYPE2 ----------------
SET @ABBR = LEFT(@TRC_UDF2, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRCTYPE2'
, @ABBR
, @ABBR
, 'Tractor Type2'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRCTYPE2'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF2, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF2 = NULL

SELECT @ERRORCODE = 107 -- Invalid TrcType2.
END

IF ISNULL( @TRC_UDF2, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 107
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_TYPE2] = LEFT(@TRC_UDF2, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

---------------- Update UNITTYPE2 ----------------
-- TRC_TYPE3
SET @ABBR = LEFT(@TRC_UDF3, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRCTYPE3'
, @ABBR
, @ABBR
, 'Tractor Type3'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRCTYPE3'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF3, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF3 = NULL

SELECT @ERRORCODE = 108 -- Invalid TrcType3.
END

IF ISNULL( @TRC_UDF3, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 108
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_TYPE3] = LEFT(@TRC_UDF3, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

---------------- Update UNITTYPE2 ----------------
SET @ABBR = LEFT(@TRC_UDF4, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRCTYPE4'
, @ABBR
, @ABBR
, 'Tractor Type4'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRCTYPE4'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF4, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF4 = NULL

SELECT @ERRORCODE = 109 -- Invalid TrcType4.
END

IF ISNULL( @TRC_UDF4, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 109
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_TYPE4] = LEFT(@TRC_UDF4, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

-------------- Update TRC_MISC1 ----------------
PRINT 'updating misc1' + ISNULL( @TRC_MISC1, 'NULLVALUE' )

IF ISNULL( @TRC_MISC1, '' ) <> ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MISC1] = @TRC_MISC1
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

---------------- Update TRC_MISC2 ----------------
IF ISNULL( @TRC_MISC2, '' ) <> ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MISC2] = @TRC_MISC2
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

---------------- Update TRC_MISC3 ----------------
IF ISNULL( @TRC_MISC3, '' ) <> ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MISC3] = @TRC_MISC3
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

---------------- Update TRC_MISC4 ----------------
IF ISNULL( @TRC_MISC4, '' ) <> ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_MISC4] = @TRC_MISC4
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'MCommSystem'
, @MCTPARTNAME
, @MCTPARTNAME
, 'MCommSystem'

IF dbo.CheckLabel( LEFT(@MCTPARTNAME, 20), 'MCommSystem', 1 ) = 1
BEGIN
IF ISNULL( @MCTSERIALNUMBER, '' ) <> ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_mctid] = LEFT(@MCTSERIALNUMBER, 20)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

IF ISNULL( @MCTSERIALNUMBER, '' ) <> ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_mcommid] = LEFT(@MCTSERIALNUMBER, 30)
, [trc_mcommType] = LEFT(@MCTPARTNAME, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END
END
ELSE
BEGIN
IF ISNULL( @MCTSERIALNUMBER, '' ) = ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_mctid] = NULL
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END

IF ISNULL( @MCTSERIALNUMBER, '' ) = ''
BEGIN
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_mcommid] = NULL
, [trc_mcommType] = NULL
WHERE  [TRC_NUMBER] = @TRC_NUMBER
END
END
END
ELSE -- TRL_TYPES
----------------------------------------------------------------------
-- Trailer unit type updates
----------------------------------------------------------------------
BEGIN
-- TRL_TYPE1
SET @ABBR = LEFT(@TRC_UDF5, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRLTYPE1'
, @ABBR
, @ABBR
, 'Trailer Type1'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRLTYPE1'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF5, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF5 = NULL

SELECT @ERRORCODE = 105 -- Invalid TrlType1.
END

IF ISNULL( @TRC_UDF5, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 105
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_TYPE1] = LEFT(@TRC_UDF5, 6)
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

-- TRL_TYPE2    KPM 8/7/12
SET @ABBR = LEFT(@TRC_UDF6, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRLTYPE2'
, @ABBR
, @ABBR
, 'Trailer Type2'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRLTYPE2'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF6, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF6 = NULL

SELECT @ERRORCODE = 110 -- Invalid TrlType2.
END

IF ISNULL( @TRC_UDF6, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 110
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_TYPE2] = LEFT(@TRC_UDF6, 6)
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

-- TRL_TYPE3  KPM 8/7/12
SET @ABBR = LEFT(@TRC_UDF7, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRLTYPE3'
, @ABBR
, @ABBR
, 'Trailer Type3'

SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRLTYPE3'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF7, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF7 = NULL

SELECT @ERRORCODE = 111 -- Invalid TrlType3.
END

IF ISNULL( @TRC_UDF7, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 111
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_TYPE3] = LEFT(@TRC_UDF7, 6)
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

SET @ABBR = LEFT(@TRC_UDF8, 6)

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'TRLTYPE4'
, @ABBR
, @ABBR
, 'Trailer Type4'

-- TRL_TYPE4 KPM 8/7/12
SELECT @VALID_REVCLASS = COUNT( 0 )
FROM   labelfile
WHERE  labeldefinition            = 'TRLTYPE4'
AND ISNULL( retired, 'N' ) <> 'Y'
AND abbr                   = LEFT(@TRC_UDF8, 6)

IF @VALID_REVCLASS = 0
BEGIN
SET @TRC_UDF8 = NULL

SELECT @ERRORCODE = 112 -- Invalid TrlType4.
END

IF ISNULL( @TRC_UDF8, '' ) <> ''
AND ISNULL( @ERRORCODE, 0 ) <> 112
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_TYPE4] = LEFT(@TRC_UDF8, 6)
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

-------------- Update TRC_MISC1 ----------------
IF ISNULL( @TRC_MISC5, '' ) <> ''
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_MISC1] = @TRC_MISC5
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

---------------- Update TRC_MISC2 ----------------
IF ISNULL( @TRC_MISC6, '' ) <> ''
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_MISC2] = @TRC_MISC6
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

---------------- Update TRC_MISC3 ----------------
IF ISNULL( @TRC_MISC7, '' ) <> ''
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_MISC3] = @TRC_MISC7
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

---------------- Update TRC_MISC4 ----------------
IF ISNULL( @TRC_MISC8, '' ) <> ''
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_MISC4] = @TRC_MISC8
WHERE  [TRL_NUMBER] = @TRC_NUMBER
END

EXEC tmw_AddLabelFileEntries_sp @ERRORCODE OUT
, 'ADD'
, 'MCommSystem'
, @MCTPARTNAME
, @MCTPARTNAME
, 'MCommSystem'

IF dbo.CheckLabel( LEFT(@MCTPARTNAME, 20), 'MCommSystem', 1 ) = 1
BEGIN
IF ISNULL( @MCTSERIALNUMBER, '' ) <> ''
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [trl_mcommID] = LEFT(@MCTSERIALNUMBER, 20)
, [trl_mcommType] = LEFT(@MCTPARTNAME, 6)
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( TRL_ILT, 'N' ) = 'N'
END
END
ELSE
BEGIN
UPDATE [dbo].[TRAILERPROFILE]
SET    [trl_mcommID] = NULL
, [trl_mcommType] = NULL
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( TRL_ILT, 'N' ) = 'N'
END
END -- trc / trl specific

-----------------------------------------------------------------------------------------------------------
-- Update Branch
-----------------------------------------------------------------------------------------------------------
--MRH JIRA INT-200029 --> WE-205401 Remove the default branch update
--                      IF @UNIT_IDTYPE = 'TRC'
--                         BEGIN
--                               IF EXISTS ( SELECT relation_name = COL_NAME(E.id, E.colid)
--                                           FROM   sysobjects a
--                                                 ,syscolumns E
--                                           WHERE  A.id = E.id
--                                                  AND A.xtype = 'U'
--                                                  AND A.NAME = 'TRACTORPROFILE'
--                                                  AND COL_NAME(E.id, E.colid) = 'TRC_BRANCH' )
--                                  BEGIN
---- TRC_TYPE1
--                                        SELECT  @VALID_REVCLASS = COUNT(0)
--                                        FROM    Branch
--                                        WHERE   BRN_ID = @BRANCH

--                                        IF @VALID_REVCLASS = 0
--                                           BEGIN
--                                                 SET @BRANCH = NULL
--                                                 SELECT @ERRORCODE = 106         -- Invalid Branch.
--                                           END
--                                        IF ISNULL(@BRANCH, '') <> ''
--                                           AND ISNULL(@ERRORCODE, 0) <> 106
--                                           BEGIN
--                                                 UPDATE [dbo].[TRACTORPROFILE]
--                                                 SET    [TRC_BRANCH] = @BRANCH
--                                                 WHERE  [TRC_NUMBER] = @TRC_NUMBER
--                                           END
--                                  END  -- End if Exists
--                         END  -- End TRC
--                      ELSE    -- TRL_TYPE1
--                         BEGIN
--                               IF EXISTS ( SELECT relation_name = COL_NAME(E.id, E.colid)
--                                           FROM   sysobjects a
--                                                 ,syscolumns E
--                                           WHERE  A.id = E.id
--                                                  AND A.xtype = 'U'
--                                                  AND A.NAME = 'TRAILERPROFILE'
--                                                  AND COL_NAME(E.id, E.colid) = 'TRL_BRANCH' )
--                                  BEGIN
--                                        SELECT  @VALID_REVCLASS = COUNT(0)
--                                        FROM    Branch
--                                        WHERE   BRN_ID = @BRANCH

--                                        IF @VALID_REVCLASS = 0
--                                           BEGIN
--                                                 SET @BRANCH = NULL
--                                                 SELECT @ERRORCODE = 106         -- Invalid Branch.
----GOTO ERROR_EXIT
--                                           END
--                                        IF ISNULL(@BRANCH, '') <> ''
--                                           AND ISNULL(@ERRORCODE, 0) <> 106
--                                           BEGIN
--                                                 UPDATE [dbo].[TRAILERPROFILE]
--                                                 SET    [TRL_BRANCH] = @BRANCH
--                                                 WHERE  [TRL_ID] = @TRC_NUMBER
--                                                        AND ISNULL(trl_ilt, 'N') = 'N'
--                                           END
---- ELSE PRINT 'NO BRANCH'
--                                  END -- End If Exists
--                         END -- End Else TRL
--MRH JIRA INT-200029 END
--        -- USERDEFINED FIELD (TireSize) To MISC1
--        IF @UNIT_IDTYPE = 'TRC'
--        BEGIN
--                UPDATE [dbo].[TRACTORPROFILE] SET [TRC_MISC1] = @TRC_UDF2
--                        WHERE [TRC_NUMBER]=@TRC_NUMBER
--        END
--        ELSE
--        BEGIN
--                UPDATE [dbo].[TRAILERPROFILE] SET [TRL_MISC1] = @TRC_UDF2
--                    WHERE [TRL_ID]=@TRC_NUMBER and isnull(trl_ilt, 'N') = 'N'
--        END

--SET TO N WE WANT TO SEND UDF2 FROM UNIT MASTER OVERRIDING WHAT IS IN UNIT OPTIONS
-- AS PART OF THE DLL

--IF ISNULL(@TRC_MISC2, '') <> ''
--   BEGIN
--         IF @UNIT_IDTYPE = 'TRC'
--            BEGIN
--                  UPDATE  [dbo].[TRACTORPROFILE]
--                  SET     [TRC_MISC1] = CAST(@TRC_MISC2 AS VARCHAR(6))
--                  WHERE   [TRC_NUMBER] = @TRC_NUMBER
--            END
--         ELSE
--            BEGIN
--                  UPDATE  [dbo].[TRAILERPROFILE]
--                  SET     [TRL_MISC1] = CAST(@TRC_MISC2 AS VARCHAR(6))
--                  WHERE   [TRL_ID] = @TRC_NUMBER
--                          AND ISNULL(trl_ilt, 'N') = 'N'
--            END
--  END -- END @TRC_UDF2
END

-- Generalinfo integer4

-- IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[DBO].[#TEMP_READING]') AND OBJECTPROPERTY(ID, N'ISTABLE') = 1)
--   DROP TABLE [dbo].#Temp_SHOP

--- MRH JIRA INT-200029 Custom Enhancement

--		@COSTCTCODE (@BRANCH) Send to trc_fleet, trl_fleet
IF ISNULL( @BRANCH, '' ) <> ''
BEGIN
IF @UNIT_IDTYPE = 'TRC'
UPDATE [dbo].[TRACTORPROFILE]
SET    [TRC_FLEET] = LEFT(@BRANCH, 6)
WHERE  [TRC_NUMBER] = @TRC_NUMBER
ELSE
UPDATE [dbo].[TRAILERPROFILE]
SET    [TRL_FLEET] = LEFT(@BRANCH, 6)
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'
END

--      @UNITUSERFLD1 send to trc_axle, trl_axle
IF ISNULL( @TRC_UDF1, '' ) <> ''
AND @UNIT_IDTYPE = 'TRC'
AND ISNUMERIC( @TRC_UDF1 ) = 1
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_axles] = CONVERT( INT, @TRC_UDF1 )
WHERE  [TRC_NUMBER] = @TRC_NUMBER

IF ISNULL( @TRC_UDF1, '' ) <> ''
AND @UNIT_IDTYPE = 'TRL'
AND ISNUMERIC( @TRC_UDF1 ) = 1
UPDATE [dbo].[TRAILERPROFILE]
SET    [trl_axles] = CONVERT( INT, @TRC_UDF1 )
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'

--		Empdrvid send to trc_teamleader, trl_teamleader
--        IF ISNULL(@EMPLOYEE, '') <> ''
--            BEGIN
--                IF @UNIT_IDTYPE = 'TRC'
--					UPDATE [dbo].[TRACTORPROFILE]
--					SET    [trc_teamleader] = LEFT(@EMPLOYEE, 6)
--					WHERE  [TRC_NUMBER] = @TRC_NUMBER
--				ELSE  -- MRH TRAILER DOES NOT HAVE [trc_teamleader] FIELD.
--					UPDATE [dbo].[TRAILERPROFILE]
--					SET    [trl_misc2] = @EMPLOYEE
--					WHERE  [TRL_ID] = @TRC_NUMBER
--						AND ISNULL(trl_ilt, 'N') = 'N'
--            END
--
--		Capacity	send to trc_grossweight, trl_grossweight
IF ISNULL( @CAPACITY, '' ) <> ''
AND ISNUMERIC( @CAPACITY ) = 1
BEGIN
IF @UNIT_IDTYPE = 'TRC'
UPDATE [dbo].[TRACTORPROFILE]
SET    [trc_grosswgt] = @CAPACITY
WHERE  [TRC_NUMBER] = @TRC_NUMBER
ELSE
UPDATE [dbo].[TRAILERPROFILE]
SET    [trl_grosswgt] = @CAPACITY
WHERE  [TRL_ID]                   = @TRC_NUMBER
AND ISNULL( trl_ilt, 'N' ) = 'N'
END

--		Option to send ACTIVCODE to trc_type			send to trc_type1
--		Option to send ACTIVCODE to trl_type			send to trl_type1
--		Option to send UNITTYPE (@TYPE) to trc_type		send to trc_type1
--		Option to send UNITTYPE (@TYPE) to trl_type		send to trl_type1
--
--        IF ISNULL(@TRC_TYPE1, '') <> '' AND @UNIT_IDTYPE = 'TRC'
--			UPDATE [dbo].[TRACTORPROFILE]
--			SET    [trc_type1] = LEFT(@TRC_TYPE1, 6)
--			WHERE  [TRC_NUMBER] = @TRC_NUMBER
--
--        IF ISNULL(@TRL_TYPE1, '') <> '' AND @UNIT_IDTYPE = 'TRL'
--			UPDATE [dbo].[TRAILERPROFILE]
--			SET    [trl_type1] =LEFT( @TRL_TYPE1, 6)
--			WHERE  [TRL_ID] = @TRC_NUMBER
--				AND ISNULL(trl_ilt, 'N') = 'N'
--- MRH JIRA INT-200029 END
GOTO NO_ERROR_EXIT

ERROR_EXIT:
SELECT @ERRORCODE

NO_ERROR_EXIT:
PRINT 'END TMT_TRACTOR_UPDATE_SP_V1'
END
GO
GRANT EXECUTE ON  [dbo].[TMT_TRACTOR_UPDATE_SP_V1] TO [public]
GO
