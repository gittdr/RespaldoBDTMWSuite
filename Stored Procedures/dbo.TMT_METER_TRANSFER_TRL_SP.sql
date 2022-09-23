SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


----------------------------------
--- TMT AMS from TMWSYSTEMS
--- CHANGED 10/02/2015 MB DT:1573
--- CHANGED 9/17/2015  Suphala DT:1573
--- CHANGED 04/04/2011 MH
--- Changed 05/05/2006 MB
--- Changed 11/07/2013 MH - Change the meter date to the legheader.lgh_enddate to allow retransfering historical data.
--- MRH 05/08/14 - Removed cross server meter lookup. Repaced with existing stored proc.
-- Added select stament PTS:94146 and Try, Catch blocks SK
----------------------------------
CREATE PROCEDURE [dbo].[TMT_METER_TRANSFER_TRL_SP]
(
@daysBack INT ,          -- Days to go back before @LatestDate
-- is NULL 1 day is used
@LatestDate DATETIME = NULL    -- Last Move date
-- If Null Midnight of previous day is used

)
AS -- Required for cross server connections.
SET ANSI_NULLS ON
SET ANSI_WARNINGS ON

DECLARE @minMov_number INT
DECLARE @minlgh INT
DECLARE @minTrailer VARCHAR(8)
DECLARE @Lowdate DATETIME
DECLARE @HighDate DATETIME
DECLARE @cntLgh1 INT
DECLARE @cntLgh2 INT
DECLARE @MilesTest INT
DECLARE @stop_miles INT
DECLARE @trailer VARCHAR(8)
DECLARE @lgh_miles FLOAT
DECLARE @tmtserver VARCHAR(25)
DECLARE @tmtdb VARCHAR(25)
DECLARE @tmtuser VARCHAR(25)
DECLARE @tmtpassword VARCHAR(25)
DECLARE @sql NVARCHAR(4000)
DECLARE @metertype VARCHAR(12)
DECLARE @meterdate DATETIME
DECLARE @shoplink INT
DECLARE @Reverse_lgh_miles FLOAT
DECLARE @SkipThisMove INT
DECLARE @LocalServer INT
DECLARE @DESCRIP [VARCHAR](60)
DECLARE @ERRORS [INTEGER]
DECLARE @PHYSICAL [CHAR](1)
DECLARE @METERUOM [VARCHAR](12)
DECLARE @TMTUNITTYPE [VARCHAR](12)
DECLARE @COMPCDKEY VARCHAR(12)
DECLARE @COMPCODE VARCHAR(12)
DECLARE @MODIFIEDBY VARCHAR(40)
DECLARE @METERDEFID INT
DECLARE @MESSAGE NVARCHAR(4000)
DECLARE @BLANK NVARCHAR(4000)

DECLARE @DEBUG INTEGER
SET @DEBUG = 0	-- 0 = Off, 1 = On

IF @DEBUG = 1
PRINT 'TMT_METER_TRANSFER_TRL_SP'



SELECT @shoplink = COUNT(1)
FROM generalinfo
WHERE gi_name = 'Shoplink'
AND gi_integer1 > 0

IF @shoplink = 0
RETURN                 -- SHOPLINK NOT ON, EXIT THIS PUPPY
SET @DESCRIP = 'TMW Suite DIS Meter'
SET @PHYSICAL = 'N' --CHAR(89) -- 'Y'
SET @COMPCDKEY = NULL
SET @COMPCODE = NULL
SET @MODIFIEDBY = NULL
SET @METERDEFID = NULL
SET @METERUOM = 'MILE' -- OR 'KM'
SET @METERTYPE = 'DISPATCH'
SET @METERDATE = CONVERT(VARCHAR(10), GETDATE(), 101)
IF ISNULL(@daysBack, '') = ''
SET @daysBack = 1
IF ISNULL(@LatestDate, '') = ''
SET @LatestDate = CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, GETDATE())))
SET @HighDate = @LatestDate
SET @Lowdate = CONVERT   (DATETIME, FLOOR(CONVERT (FLOAT, @HighDate))
- @daysBack)

-- CREATE A LIST OF MOVES TO PROCESS.
CREATE TABLE #CompletedMoves ( mov_number INT )

INSERT INTO #CompletedMoves
--Select Distinct mov_number
--From  legheader
--where lgh_enddate
--        between @Lowdate and @HighDate
--        and lgh_outstatus='CMP'
--PTS : 94146
SELECT DISTINCT l.mov_number
FROM legheader l ,
assetassignment a
WHERE lgh_enddate BETWEEN @Lowdate AND @HighDate
AND lgh_outstatus = 'CMP'
AND l.lgh_number = a.lgh_number
AND a.asgn_type = 'TRL'
--PTS : 94146

SET @minlgh = 0
SET @minMov_number = 0



--========================================================================================
-- Loop Through All Moves in the Temp table - MAIN LOOP
--========================================================================================
WHILE 1 = 1
BEGIN
-- GET NEXT MOV_NUMBER
SELECT @minMov_number = (
SELECT MIN(mov_number)
FROM #CompletedMoves
WHERE mov_number > @minMov_number
)

IF ISNULL(@minMov_number, '') = ''
BEGIN
-- NO MOVES LEFT, SO EXIT
BREAK
END
--========================================================================================
-- See if there is any change to previous Amounts for each Legheader
-- to limit number of calls to proc. Rumour has it, the TMT proc can't handle >15 calls
-- per Trailer per day
--========================================================================================

-- 1) Check to is Legheader numbers match first
--      Simple test to see if old legheaders match current one on meterhistory

SET @cntLgh1 = (
SELECT COUNT(1)
FROM legheader
WHERE mov_number = @minMov_number
)
SET @cntLgh2 = (
SELECT COUNT(1)
FROM TMTMeterTransferHistoryTrl
WHERE mov_number = @minMov_number
AND lgh_number IN (
SELECT lgh_number
FROM legheader
WHERE mov_number = @minMov_number )
)

-- If numbers are the same, then do the next test
IF ( @cntLgh1 = @cntLgh2 )
SET @SkipThisMovE = 1
ELSE
SET @SkipThisMoVe = 0

-- If still possible to skip, then see if miles match for each Legheader
IF @SkipThisMove <> 0
BEGIN
-- Loop through all Legheader on the move.
SET @minlgh = 0
WHILE 1 = 1
BEGIN
SELECT @minlgh = (
SELECT MIN(lh.lgh_number)
FROM legheader lh
WHERE lh.mov_number = @minMov_number
AND lh.lgh_number > @minlgh
)
IF ISNULL(@minlgh, '') = ''
BEGIN
BREAK  -- No More left
END

-- See if old value does not match new
-- IF so, give up trying to skip move
SELECT @MilesTest = TMT.lgh_miles
FROM TMTMeterTransferHistoryTrl TMT ,
legheader LH
WHERE TMT.mov_number = @minMov_number
AND TMT.lgh_number = @minlgh
AND LH.lgh_number = TMT.lgh_number
AND LH.lgh_primary_trailer = TMT.Trailer
IF @MilesTest IS NULL
SET @MilesTest = 0
SELECT @stop_miles = SUM(ISNULL(s.stp_lgh_mileage, 0))
FROM stops S ,
legheader LH
WHERE LH.lgh_number = @minlgh
AND S.lgh_number = lH.lgh_number
-- MRH Conversion to kilometers option
-- Compare kilos to kilos
IF (
SELECT COUNT(1)
FROM generalinfo
WHERE gi_name = 'Shoplink'
AND gi_integer3 = 1
) > 0
BEGIN
SET @stop_miles = @stop_miles * 1.60935
SET @METERUOM = 'KM'
END

IF ( @stop_miles ) <> ( @MilesTest )
BEGIN	--Miles do not match, Do not skip this move.
SET @SkipThisMove = 0
BREAK
END
END -- WHILE LOOP

END--@SkipThisMove<>0
IF @SkipThisMove <> 0
GOTO NEXT_MOVE

--========================================================================================
-- REVERSE OUT ALL PREVIOUS AMOUNTS FOR THIS MOVE.
--      By this, I mean send the negative of old amount to the same proc for
--      each legheader on the move
--========================================================================================
SET @minTrailer = ''
SET @minlgh = 0 -- Note: Set to 0, METER History stores corrected LGH_numbers as - LGH_numbers
WHILE 1 = 1       --====================
BEGIN           -- Loop through all Legheaders on move in the TMTMeterTransferHistoryTrl
--====================
SELECT @minlgh = (
SELECT MIN(lgh_number)
FROM TMTMeterTransferHistoryTrl
WHERE TMTMeterTransferHistoryTrl.mov_number = @minMov_number
AND lgh_number > @minlgh
)
IF ISNULL(@minlgh, '') = ''
BEGIN
BREAK -- FINISHED
END

SET @trailer = ISNULL((
SELECT Trailer
FROM TMTMeterTransferHistoryTrl
WHERE TMTMeterTransferHistoryTrl.mov_number = @minMov_number
AND lgh_number = @minlgh
), 'UNKNOWN')



SET @Reverse_lgh_miles = (
SELECT lgh_miles
FROM TMTMeterTransferHistoryTrl
WHERE TMTMeterTransferHistoryTrl.mov_number = @minMov_number
AND lgh_number = @minlgh
)

IF @Reverse_lgh_miles > 0
AND ( @trailer <> 'UNKNOWN' )
AND ( LTRIM(@trailer) <> '' )
BEGIN
SET @lgh_miles = -@Reverse_lgh_miles

--================================================================
--=== ACTUAL CALL STUFF-- assumes @lgh_miles, @Notrailer already SET
--================================================================
SELECT @TMTUNITTYPE = ISNULL(trl_ams_type, 'TRAILER')
FROM TRAILERPROFILE
WHERE TRL_NUMBER = @TRAILER
SELECT @METERDATE = lgh_enddate
FROM legheader
WHERE lgh_number = @minlgh

IF (
SELECT GI_STRING1
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'
) <> @@servername
BEGIN
BEGIN TRY
SELECT @TMTSERVER = '[' + GI_STRING1 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql = 'EXEC '+ @tmtserver + '.' + @tmtdb
+ '.[dbo].[USP_METERDEF_CREATE] ' + '  @ERRORID OUTPUT'
+ ', @METERDEFID OUTPUT' + ', @METERTYPE'
+ ', @COMPCDKEY' + ', @COMPCODE' + ', @PHYSICAL'
+ ', @METERUOM' + ', @DESCRIP' + ', @MODIFIEDBY'


EXEC SP_EXECUTESQL
@SQL ,
N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)' ,
@ERRORS OUTPUT ,
@METERDEFID OUTPUT ,
@METERTYPE ,
@COMPCDKEY ,
@COMPCODE ,
@PHYSICAL ,
@METERUOM ,
@DESCRIP ,
@MODIFIEDBY


--						  SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' +
--									 @tmtserver + '.' + @tmtdb +
--									 '.[dbo].METERDEF WHERE METERTYPE = ' + @METERTYPE + ') EXEC ' +
--									 @tmtserver + '.' + @tmtdb +
--									 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--																  @LOCALDESCRIP,
--																  @LOCALPHYSICAL,
--																  @LOCALMETERUOM,
--																  @LOCALERRORS OUTPUT '
--IF @DEBUG = 1 PRINT '@LOCALMETERTYPE1' + ':' + ISNULL(@METERTYPE, 'NULL')
--IF @DEBUG = 1 PRINT 'SQL1' +  ':' + @SQL

--						  EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--													 @LOCALMETERTYPE VARCHAR(12),
--													 @LOCALDESCRIP VARCHAR(60),
--													 @LOCALPHYSICAL CHAR(1),
--													 @LOCALMETERUOM VARCHAR(12),
--													 @LOCALERRORS INTEGER',
--													 @METERTYPE,
--													 @METERTYPE,
--													 @DESCRIP,
--													 @PHYSICAL,
--													 @METERUOM,
--													 @ERRORS


SET @SQL = 'DECLARE @INTEGRATIONID int
SELECT  @INTEGRATIONID = [INTEGRATIONID]   FROM '
+ @tmtserver + '.' + @tmtdb
+ '.[dbo].[INTEGRATION]  WHERE [INTNAME] =''TMWSUITE''  EXEC '
+ @tmtserver + '.' + @tmtdb
+ '.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
@ORDERTYPE,
@ORDERID,
@METERTYPE,
@METERREADING,
@METERDATE,
@VALIDATE,
@ERRORS OUTPUT,
@CUSTOMERNAME,
@INTEGRATIONID,
@UNITTYPE'


IF @DEBUG = 1
PRINT 'SQL2' + ':' + @SQL
EXEC SP_EXECUTESQL
@SQL ,
N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)' ,
@TRAILER ,
NULL ,
NULL ,
@METERTYPE ,
@LGH_MILES ,
@METERDATE ,
NULL ,
@ERRORS ,
NULL ,
@TMTUNITTYPE

END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_TRL_SP  1 :  '
+ 'ERROR NUMBER:' + CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(), @BLANK)

SELECT @MESSAGE [ERROR MESSAGE] ,
@Trailer [TRAILER] ,
@METERTYPE [METERTYPE] ,
@LGH_MILES [GH_MILES] ,
@METERDATE [METERDATE] ,
@ERRORS [ERRORS] ,
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH
END --(select gi_string1 from generalinfo (NOLOCK) where gi_name = 'Shoplink') <> @@servername
ELSE
BEGIN
BEGIN TRY
SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql = 'EXEC '+  @tmtdb + '.[dbo].[USP_METERDEF_CREATE] '
+ '@ERRORID OUTPUT' + ', @METERDEFID OUTPUT'
+ ', @METERTYPE' + ', @COMPCDKEY' + ', @COMPCODE'
+ ', @PHYSICAL' + ', @METERUOM' + ', @DESCRIP'
+ ', @MODIFIEDBY'

EXEC SP_EXECUTESQL
@SQL ,
N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)' ,
@ERRORS OUTPUT ,
@METERDEFID OUTPUT ,
@METERTYPE ,
@COMPCDKEY ,
@COMPCODE ,
@PHYSICAL ,
@METERUOM ,
@DESCRIP ,
@MODIFIEDBY


--						  SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' + @tmtdb +
--									 '.[dbo].METERDEF WHERE METERTYPE = @LOCALMETERTYPE1) EXEC '+ @tmtdb +
--									 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--																  @LOCALDESCRIP,
--																  @LOCALPHYSICAL,
--																  @LOCALMETERUOM,
--																  @LOCALERRORS OUTPUT '

--IF @DEBUG = 1 PRINT 'SQL3' +  ':' + @SQL
--						  EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--													 @LOCALMETERTYPE VARCHAR(12),
--													 @LOCALDESCRIP VARCHAR(60),
--													 @LOCALPHYSICAL CHAR(1),
--													 @LOCALMETERUOM VARCHAR(12),
--													 @LOCALERRORS INTEGER',
--													 @METERTYPE,
--													 @METERTYPE,
--													 @DESCRIP,
--													 @PHYSICAL,
--													 @METERUOM,
--													 @ERRORS


SET @SQL = ' DECLARE @INTEGRATIONID int
SELECT  @INTEGRATIONID = [INTEGRATIONID]   FROM '
+ @tmtdb
+ '.[dbo].[INTEGRATION]  WHERE [INTNAME] =''TMWSUITE'';
EXEC ' + @tmtdb
+ '.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
@ORDERTYPE,
@ORDERID,
@METERTYPE,
@METERREADING,
@METERDATE,
@VALIDATE,
@ERRORS OUTPUT,
@CUSTOMERNAME,
@INTEGRATIONID,
@UNITTYPE'

IF @DEBUG = 1
PRINT 'SQL4' + ':' + @SQL
EXEC SP_EXECUTESQL
@SQL ,
N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)' ,
@TRAILER ,
NULL ,
NULL ,
@METERTYPE ,
@LGH_MILES ,
@METERDATE ,
NULL ,
@ERRORS ,
NULL ,
@TMTUNITTYPE
END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_TRL_SP  2 :  '
+ 'ERROR NUMBER:' + CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(), @BLANK)

SELECT @MESSAGE [ERROR MESSAGE] ,
@TRAILER [TRAILER] ,
@METERTYPE [METERTYPE] ,
@LGH_MILES [GH_MILES] ,
@METERDATE [METERDATE] ,
@ERRORS [ERRORS] ,
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH
END
--================================================================
--=== END ACTUAL CALL STUFF-- assumes @lgh_miles, @trailer already SET
--================================================================
-- LOG WHAT WAS SENT
--===========================================================

-- NOTE
INSERT TMTMeterTransferHistoryTrl
( Mov_number ,
Trailer ,
lgh_miles ,
ReverseEntry ,
lgh_number
)
VALUES
( @minMov_number ,
@trailer ,
@lgh_miles ,
'Y' ,
-@minlgh
) -- NOTE LGH_NUMBER= 0- LGHNUMBER

--Clear any other records with postive lgh_number
-- equal to the one we just inserted
--so it won't be processed again
UPDATE TMTMeterTransferHistoryTrl          -- Clear Lgh_number
SET	lgh_number = -@minlgh         -- so Only lastest
WHERE Mov_number = @minMov_number-- Record has it.
AND lgh_number = @minlgh
--===========================================================
-- END LOG WHAT WAS SENT
--===========================================================
END
END -- END REVERSE OUT ALL PREVIOUS AMOUNTS FOR THIS MOVE
--
--========================================================================================
-- INSERT ONE RECORD FOR EACH LEGHEADER FOR THE MOVE
--========================================================================================

SET @minTrailer = ''
SET @minlgh = 0
WHILE 1 = 1 -- Loop through all Legheader on the move
BEGIN

SELECT @minlgh = (
SELECT MIN(lgh_number)
FROM legheader
WHERE legheader.mov_number = @minMov_number
AND lgh_number > @minlgh
)

IF ISNULL(@minlgh, '') = ''
BREAK -- FINISHED

SET @minTrailer = ISNULL((
SELECT lgh_primary_trailer
FROM legheader
WHERE lgh_number = @minlgh
), 'UNKNOWN')
SET @trailer = @minTrailer

IF ( ( @trailer <> 'UNKNOWN' )
AND ( LTRIM(@trailer) <> '' )
) -- SKIP UNKNOWN or blank
BEGIN
SELECT @lgh_miles = SUM(ISNULL(stp_lgh_mileage, 0))
FROM stops
WHERE lgh_number = @minlgh

IF ISNULL(@lgh_miles, '') = ''
SELECT @lgh_miles = 0

IF @lgh_miles > 0
BEGIN
-- MRH Conversion to kilometers option
IF (
SELECT COUNT(1)
FROM generalinfo
WHERE gi_name = 'Shoplink'
AND gi_integer3 = 1
) > 0
BEGIN
SET @lgh_miles = @lgh_miles * 1.60935
SET @METERUOM = 'KM'
END

--================================================================
--=== ACTUAL CALL STUFF-- assumes @lgh_miles, @trailer already SET
--================================================================
SELECT @TMTUNITTYPE = ISNULL(trl_ams_type, 'TRAILER')
FROM TRAILERPROFILE
WHERE TRL_NUMBER = @TRAILER
SELECT @METERDATE = lgh_enddate
FROM legheader
WHERE lgh_number = @minlgh

IF (
SELECT GI_STRING1
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'
) <> @@servername
BEGIN
BEGIN TRY
SELECT @TMTSERVER = '[' + GI_STRING1 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql ='EXEC '+ @tmtserver + '.' + @tmtdb
+ '.[dbo].[USP_METERDEF_CREATE] '
+ '@ERRORID OUTPUT' + ', @METERDEFID OUTPUT'
+ ', @METERTYPE' + ', @COMPCDKEY' + ', @COMPCODE'
+ ', @PHYSICAL' + ', @METERUOM' + ', @DESCRIP'
+ ', @MODIFIEDBY'

EXEC SP_EXECUTESQL
@SQL ,
N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)' ,
@ERRORS OUTPUT ,
@METERDEFID OUTPUT ,
@METERTYPE ,
@COMPCDKEY ,
@COMPCODE ,
@PHYSICAL ,
@METERUOM ,
@DESCRIP ,
@MODIFIEDBY

--									  SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' +
--												 @tmtserver + '.' + @tmtdb +
--												 '.[dbo].METERDEF WHERE METERTYPE = @LOCALMETERTYPE1) EXEC ' +
--												 @tmtserver + '.' + @tmtdb +
--												 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--																			  @LOCALDESCRIP,
--																			  @LOCALPHYSICAL,
--																			  @LOCALMETERUOM,
--																			  @LOCALERRORS OUTPUT '

--IF @DEBUG = 1 PRINT 'SQL5' +  ':' + @SQL
--									  EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--																 @LOCALMETERTYPE VARCHAR(12),
--																 @LOCALDESCRIP VARCHAR(60),
--																 @LOCALPHYSICAL CHAR(1),
--																 @LOCALMETERUOM VARCHAR(12),
--																 @LOCALERRORS INTEGER',
--																 @METERTYPE,
--																 @METERTYPE,
--																 @DESCRIP,
--																 @PHYSICAL,
--																 @METERUOM,
--																 @ERRORS


SET @SQL = 'DECLARE @INTEGRATIONID int
SELECT  @INTEGRATIONID = [INTEGRATIONID]   FROM '
+ @tmtserver + '.' + @tmtdb
+ '.[dbo].[INTEGRATION]  WHERE [INTNAME] =''TMWSUITE'';  EXEC '
+ @tmtserver + '.' + @tmtdb
+ '.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
@ORDERTYPE,
@ORDERID,
@METERTYPE,
@METERREADING,
@METERDATE,
@VALIDATE,
@ERRORS OUTPUT,
@CUSTOMERNAME,
@INTEGRATIONID,
@UNITTYPE'

IF @DEBUG = 1
PRINT 'SQL6' + ':' + @SQL
EXEC SP_EXECUTESQL
@SQL ,
N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)' ,
@TRAILER ,
NULL ,
NULL ,
@METERTYPE ,
@LGH_MILES ,
@METERDATE ,
NULL ,
@ERRORS ,
NULL ,
@TMTUNITTYPE
END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_TRL_SP 3   :  '
+ 'ERROR NUMBER:'
+ CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(),
@BLANK)

SELECT @MESSAGE [ERROR MESSAGE] ,
@TRAILER [TRAILER] ,
@METERTYPE [METERTYPE] ,
@LGH_MILES [GH_MILES] ,
@METERDATE [METERDATE] ,
@ERRORS [ERRORS] ,
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH

END --(select gi_string1 from generalinfo (NOLOCK) where gi_name = 'Shoplink') <> @@servername
ELSE
BEGIN
BEGIN TRY
SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql ='EXEC '+  @tmtdb + '.[dbo].[USP_METERDEF_CREATE] '
+ '@ERRORID OUTPUT' + ', @METERDEFID OUTPUT'
+ ', @METERTYPE' + ', @COMPCDKEY' + ', @COMPCODE'
+ ', @PHYSICAL' + ', @METERUOM' + ', @DESCRIP'
+ ', @MODIFIEDBY'

EXEC SP_EXECUTESQL
@SQL ,
N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)' ,
@ERRORS OUTPUT ,
@METERDEFID OUTPUT ,
@METERTYPE ,
@COMPCDKEY ,
@COMPCODE ,
@PHYSICAL ,
@METERUOM ,
@DESCRIP ,
@MODIFIEDBY

--									  SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' + @tmtdb +
--												 '.[dbo].METERDEF WHERE METERTYPE = @LOCALMETERTYPE1) EXEC '+ @tmtdb +
--												 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--																			  @LOCALDESCRIP,
--																			  @LOCALPHYSICAL,
--																			  @LOCALMETERUOM,
--																			  @LOCALERRORS OUTPUT '

--IF @DEBUG = 1 PRINT 'SQL7' +  ':' + @SQL
--									  EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--																 @LOCALMETERTYPE VARCHAR(12),
--																 @LOCALDESCRIP VARCHAR(60),
--																 @LOCALPHYSICAL CHAR(1),
--																 @LOCALMETERUOM VARCHAR(12),
--																 @LOCALERRORS INTEGER',
--																 @METERTYPE,
--																 @METERTYPE,
--																 @DESCRIP,
--																 @PHYSICAL,
--																 @METERUOM,
--																 @ERRORS

SET @SQL = ' DECLARE @INTEGRATIONID int
SELECT  @INTEGRATIONID = [INTEGRATIONID]   FROM '
+ @tmtdb
+ '.[dbo].[INTEGRATION]  WHERE [INTNAME] =''TMWSUITE'' EXEC '
+ @tmtdb
+ '.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
@ORDERTYPE,
@ORDERID,
@METERTYPE,
@METERREADING,
@METERDATE,
@VALIDATE,
@ERRORS OUTPUT,
@CUSTOMERNAME,
@INTEGRATIONID,
@UNITTYPE'

IF @DEBUG = 1
PRINT 'SQL8' + ':' + @SQL
EXEC SP_EXECUTESQL
@SQL ,
N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)' ,
@TRAILER ,
NULL ,
NULL ,
@METERTYPE ,
@LGH_MILES ,
@METERDATE ,
NULL ,
@ERRORS ,
NULL ,
@TMTUNITTYPE
END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_TRL_SP 4   :  '
+ 'ERROR NUMBER:'
+ CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(),
@BLANK)

SELECT @MESSAGE [ERROR MESSAGE] ,
@TRAILER [TRACTOR] ,
@METERTYPE [METERTYPE] ,
@LGH_MILES [GH_MILES] ,
@METERDATE [METERDATE] ,
@ERRORS [ERRORS] ,
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH

END

--================================================================
--=== END ACTUAL CALL STUFF-- assumes @lgh_miles, @trailer already SET
--================================================================

--===========================================================
-- LOG WHAT WAS SENT
--===========================================================

-- CLear any other updates so only latest has lgh_miles
UPDATE TMTMeterTransferHistoryTrl          -- Clear Lgh_number
SET	lgh_number = -@minlgh         -- so Only lastest
WHERE Mov_number = @minMov_number-- Record has it.
AND lgh_number = @minlgh

INSERT TMTMeterTransferHistoryTrl
( Mov_number ,
Trailer ,
lgh_miles ,
lgh_number
)
VALUES
( @minMov_number ,
@trailer ,
@lgh_miles ,
@minlgh
)
--===========================================================
-- END LOG WHAT WAS SENT
--===========================================================
END --IF @lgh_miles>0
END -- Trailer<> UNKNOWN
END -- WHILE LOOP FOR EACH LGH
NEXT_MOVE:
END -- MOVE LIST
GO
