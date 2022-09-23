SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
----------------------------------
--- TMT AMS from TMWSYSTEMS
--- CHANGED 9/17/2015  Suphala DT:1573
--- CHANGED 04/04/2011 MH
--- CHANGED 09/11/2009 MB
--- Changed 05/05/2006 MB
--- Changed 11/07/2013 MH - Change the meter date to the legheader.lgh_enddate to allow retransfering historical data.
--- MRH 05/08/14 - Removed cross server meter lookup. Repaced with existing stored proc.
--- Added select stament PTS:94146 and Try, Catch blocks SK
----------------------------------
CREATE PROCEDURE [dbo].[TMT_METER_TRANSFER_SP]
(
@daysBack int,          -- Days to go back before @LatestDate
-- is NULL 1 day is used
@LatestDate datetime = NULL   -- Last Move date
-- If Null Midnight of previous day is used
)

AS
Declare @minMov_number int
Declare @minlgh int
Declare @minTractor varchar(8)
Declare @Lowdate DateTime
Declare @HighDate DateTime
Declare @cntLgh1 int
Declare @cntLgh2 int
Declare @MilesTest int
Declare @stop_miles int
Declare @tractor varchar(8)
Declare @lgh_miles      float
Declare @tmtserver varchar(25)
Declare @tmtdb varchar(25)
Declare @tmtuser varchar(25)
Declare @tmtpassword varchar(25)
Declare @sql nvarchar(4000)
Declare @metertype varchar(12)
Declare @meterdate datetime
Declare @shoplink int
Declare @Reverse_lgh_miles Float
Declare @SkipThisMove int
Declare @LocalServer int
DECLARE @DESCRIP [VARCHAR](60)
DECLARE @ERRORS [INTEGER]
DECLARE @PHYSICAL       [CHAR](1)
DECLARE @METERUOM       [VARCHAR](12)
DECLARE @TMTUNITTYPE	[VARCHAR] (12)
DECLARE @COMPCDKEY varchar(12)
DECLARE @COMPCODE varchar(12)
DECLARE @MODIFIEDBY varchar(40)
DECLARE @METERDEFID int
DECLARE @MESSAGE NVARCHAR(4000)
DECLARE @BLANK NVARCHAR(4000)

DECLARE @DEBUG INTEGER
SET @DEBUG = 1	-- 0 = Off, 1 = On

IF @DEBUG = 1
PRINT 'TMT_METER_TRANSFER_SP'

SELECT @shoplink =
COUNT(1)
FROM generalinfo
where gi_name = 'Shoplink' and
gi_integer1 > 0

IF @shoplink = 0 return                 -- SHOPLINK NOT ON, EXIT THIS PUPPY

SET @DESCRIP  = 'TMW Suite DIS Meter'
SET @PHYSICAL = 'N' --CHAR(89) -- 'Y'
SET @COMPCDKEY = NULL
SET @COMPCODE = NULL
SET @MODIFIEDBY = NULL
SET @METERDEFID = NULL
SET @METERUOM = 'MILE' -- OR 'KM'
SET @METERTYPE = 'DISPATCH'
SET @METERDATE = CONVERT(varchar(10), GetDate(), 101)
if isnull(@daysBack, '') = ''
SET @daysBack=7
If isnull(@LatestDate, '') = ''
Set @LatestDate=Convert(Datetime,FLOOR(convert(float, GETDATE())))
Set @HighDate= @LatestDate
Set @Lowdate =Convert   ( datetime,Floor( convert (float, @HighDate)) -@daysBack )

-- CREATE A LIST OF MOVES TO PROCESS.
Create Table #CompletedMoves
(
mov_number int
)

Insert into  #CompletedMoves
--Select Distinct mov_number
--From  legheader
--where lgh_enddate
--        between @Lowdate and @HighDate
--        and lgh_outstatus='CMP'

--PTS : 94146
Select Distinct l.mov_number
From  legheader l, assetassignment a
where lgh_enddate
between @Lowdate and @HighDate
and lgh_outstatus='CMP' and l.lgh_number = a.lgh_number and a.asgn_type = 'TRC'
--PTS : 94146

Set @minlgh = 0
Set @minMov_number=0

--========================================================================================
-- Loop Through All Moves in the Temp table - MAIN LOOP
--========================================================================================
While 1=1
BEGIN
-- GET NEXT MOV_NUMBER
Select @minMov_number=
(  select  min(mov_number)
from #CompletedMoves
where mov_number>@minMov_number )

if isnull(@minMov_number,'') = ''
BEGIN
-- NO MOVES LEFT, SO EXIT
BREAK
END
--========================================================================================
-- See if there is any change to previous Amounts for each Legheader
-- to limit number of calls to proc. Rumour has it, the TMT proc can't handle >15 calls
-- per tractor per day
--========================================================================================

-- 1) Check to is Legheader numbers match first
--      Simple test to see if old legheaders match current one on meterhistory

Set @cntLgh1=
(Select count(1)
from legheader
where mov_number=@minMov_number)
Set @cntLgh2=
(Select count(1)
from  TMTMeterTransferHistory
where  mov_number=@minMov_number
and
lgh_number  in
(Select  lgh_number
from legheader
where  mov_number=@minMov_number ) )

-- If numbers are the same, then do the next test
if (@cntLgh1 =@cntLgh2) SET @SkipThisMovE=1 else SET @SkipThisMoVe=0

-- If still possible to skip, then see if miles match for each Legheader
IF @SkipThisMove<>0
Begin
-- Loop through all Legheader on the move.
Set @minlgh=0
While 1=1
Begin
Select @minlgh=  (
select min(lh.lgh_number)
from  legheader lh
where lh.mov_number= @minMov_number
and lh.lgh_number > @minlgh)
IF isnull(@minlgh, '') = ''
BEGIN
break  -- No More left
END

-- See if old value does not match new
-- IF so, give up trying to skip move
Select  @MilesTest = TMT.lgh_miles
From  TMTMeterTransferHistory TMT,
legheader LH
where   TMT.mov_number=@minMov_number
and TMT.lgh_number = @minlgh
and LH.lgh_number = TMT.lgh_number
and LH.lgh_tractor=TMT.tractor
if @MilesTest IS NULL
set @MilesTest = 0

Select  @stop_miles = sum (isnull(s.stp_lgh_mileage,0))
from  stops S,
legheader LH
where  LH.lgh_number=@minlgh and
S.lgh_number = lH.lgh_number
-- MRH Conversion to kilometers option
-- Compare kilos to kilos
if (SELECT COUNT(1) FROM generalinfo where gi_name = 'Shoplink' and gi_integer3 = 1) > 0
BEGIN
set @stop_miles = @stop_miles * 1.60935
SET @METERUOM = 'KM'
END

IF (@stop_miles) <> (@MilesTest)
Begin	--Miles do not match, Do not skip this move.
Set @SkipThisMove=0
Break
end
End -- WHILE LOOP

end--@SkipThisMove<>0
IF @SkipThisMove<>0 GOTO NEXT_MOVE

--========================================================================================
-- REVERSE OUT ALL PREVIOUS AMOUNTS FOR THIS MOVE.
--      By this, send the negative of old amount to the same proc for
--      each legheader on the move
--========================================================================================
Set @minTractor =''
Set @minlgh=0 -- Note: Set to 0, METER History stores corrected LGH_numbers as - LGH_numbers
WHILE 1=1       --====================

BEGIN           -- Loop through all Legheaders on move in the TMTMeterTransferHistory
--====================
Select @minlgh=
(
select min(lgh_number)
from  TMTMeterTransferHistory
where TMTMeterTransferHistory.mov_number=@minMov_number
and lgh_number>@minlgh )
if isnull(@minlgh, '') = ''
BEGIN
BREAK -- FINISHED
END

Set @tractor=
ISNULL  ((Select  tractor
from    TMTMeterTransferHistory
where   TMTMeterTransferHistory.mov_number=@minMov_number and
lgh_number=@minlgh)
,'UNKNOWN')
Set @Reverse_lgh_miles=
( Select  lgh_miles
From TMTMeterTransferHistory
where TMTMeterTransferHistory.mov_number=@minMov_number
and lgh_number=@minlgh )

If @Reverse_lgh_miles > 0 and (@tractor<> 'UNKNOWN') AND (LTRIM(@tractor)<>'')
BEGIN
Set @lgh_miles= - @Reverse_lgh_miles

--================================================================
--=== ACTUAL CALL STUFF-- assumes @lgh_miles, @tractor already SET
--================================================================
SELECT @TMTUNITTYPE = isnull(trc_ams_type, 'TRACTOR') FROM TRACTORPROFILE WHERE TRC_NUMBER = @TRACTOR
SELECT @METERDATE = lgh_enddate from legheader where lgh_number = @minlgh

IF (SELECT GI_STRING1
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink') <> @@servername
BEGIN
BEGIN TRY
SELECT @TMTSERVER = '[' + GI_STRING1 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql =  'EXEC '+ @tmtserver + '.' + @tmtdb
+ '.dbo.USP_METERDEF_CREATE '
+ '@ERRORID OUTPUT'
+ ', @METERDEFID OUTPUT'
+ ', @METERTYPE'
+ ', @COMPCDKEY'
+ ', @COMPCODE'
+ ', @PHYSICAL'
+ ', @METERUOM'
+ ', @DESCRIP'
+ ', @MODIFIEDBY'

IF @DEBUG = 1
PRINT 'SQL1' + ':' + @SQL
EXEC SP_EXECUTESQL @SQL, N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)'
,@ERRORS OUTPUT
,@METERDEFID OUTPUT
,@METERTYPE
,@COMPCDKEY
,@COMPCODE
,@PHYSICAL
,@METERUOM
,@DESCRIP
,@MODIFIEDBY

--SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' +
--	 @tmtserver + '.' + @tmtdb +
--	 '.[dbo].METERDEF WHERE METERTYPE = @LOCALMETERTYPE1) EXEC ' +
--	 @tmtserver + '.' + @tmtdb +
--	 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--								  @LOCALDESCRIP,
--								  @LOCALPHYSICAL,
--								  @LOCALMETERUOM,
--								  @LOCALERRORS OUTPUT '

--EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--					 @LOCALMETERTYPE VARCHAR(12),
--					 @LOCALDESCRIP VARCHAR(60),
--					 @LOCALPHYSICAL CHAR(1),
--					 @LOCALMETERUOM VARCHAR(12),
--					 @LOCALERRORS INTEGER',
--					 @METERTYPE,
--					 @METERTYPE,
--					 @DESCRIP,
--					 @PHYSICAL,
--					 @METERUOM,
--					 @ERRORS

--Done
SET @SQL = 'DECLARE @INTEGRATIONID int
SELECT  @INTEGRATIONID = [INTEGRATIONID]   FROM ' +
@tmtserver + '.' + @tmtdb +
'.[dbo].[INTEGRATION]  WHERE [INTNAME] =''TMWSUITE'';  EXEC ' +
@tmtserver + '.' + @tmtdb +
'.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
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
EXEC SP_EXECUTESQL @SQL, N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)',
@TRACTOR,
NULL,
NULL,
@METERTYPE,
@LGH_MILES,
@METERDATE,
NULL,
@ERRORS,
NULL,
@TMTUNITTYPE

END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_SP   :  '
+ 'ERROR NUMBER:' + CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(), @BLANK)

SELECT @MESSAGE [ERROR MESSAGE],@TRACTOR [TRACTOR],
@METERTYPE [METERTYPE],
@LGH_MILES [GH_MILES],
@METERDATE [METERDATE],
@ERRORS [ERRORS],
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH
END --(select gi_string1 from generalinfo (NOLOCK) where gi_name = 'Shoplink') <> @@servername
ELSE
BEGIN
BEGIN TRY
SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql =  'EXEC '+ @tmtdb
+ '.dbo.USP_METERDEF_CREATE '
+ '@ERRORID OUTPUT'
+ ', @METERDEFID OUTPUT'
+ ', @METERTYPE'
+ ', @COMPCDKEY'
+ ', @COMPCODE'
+ ', @PHYSICAL'
+ ', @METERUOM'
+ ', @DESCRIP'
+ ', @MODIFIEDBY'


IF @DEBUG = 1
PRINT 'SQL3' + ':' + @SQL
EXEC SP_EXECUTESQL @SQL, N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)'
,@ERRORS OUTPUT
,@METERDEFID OUTPUT
,@METERTYPE
,@COMPCDKEY
,@COMPCODE
,@PHYSICAL
,@METERUOM
,@DESCRIP
,@MODIFIEDBY


--SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' + @tmtdb +
--	 '.[dbo].METERDEF WHERE METERTYPE = @LOCALMETERTYPE1) EXEC '+ @tmtdb +
--	 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--								  @LOCALDESCRIP,
--								  @LOCALPHYSICAL,
--								  @LOCALMETERUOM,
--								  @LOCALERRORS OUTPUT '

--EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--					 @LOCALMETERTYPE VARCHAR(12),
--					 @LOCALDESCRIP VARCHAR(60),
--					 @LOCALPHYSICAL CHAR(1),
--					 @LOCALMETERUOM VARCHAR(12),
--					 @LOCALERRORS INTEGER',
--					 @METERTYPE,
--					 @METERTYPE,
--					 @DESCRIP,
--					 @PHYSICAL,
--					 @METERUOM,
--					 @ERRORS

--Done
SET @SQL = 'DECLARE @INTEGRATIONID int  SELECT @INTEGRATIONID = ' +  @tmtdb +
'.[dbo].[TMT_INTEGRATIONID](''TMWSUITE''); EXEC ' + @tmtdb +
'.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
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
EXEC SP_EXECUTESQL @SQL, N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)',
@TRACTOR,
NULL,
NULL,
@METERTYPE,
@LGH_MILES,
@METERDATE,
NULL,
@ERRORS,
NULL,
@TMTUNITTYPE
END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_SP   :  '
+ 'ERROR NUMBER:' + CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(), @BLANK)

SELECT @MESSAGE [ERROR MESSAGE],@TRACTOR [TRACTOR],
@METERTYPE [METERTYPE],
@LGH_MILES [GH_MILES],
@METERDATE [METERDATE],
@ERRORS [ERRORS],
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH
END
-------------------------------------------------------------------------
--================================================================
--=== END ACTUAL CALL STUFF--
--================================================================

--================================================================
-- LOG WHAT WAS SENT
--===========================================================

-- NOTE, If Kilos, then kilos are reversed.
INSERT TMTMeterTransferHistory
(Mov_number,tractor,lgh_miles,ReverseEntry,lgh_number)
VALUES
(@minMov_number,@tractor,@lgh_miles,'Y',-@minlgh) -- NOTE LGH_NUMBER= 0- LGHNUMBER

--Clear any other records with postive lgh_number
-- equal to the one we just inserted
--so it won't be processed again
Update TMTMeterTransferHistory          -- Clear Lgh_number
set lgh_number=-@minlgh         -- so Only lastest
where  Mov_number=@minMov_number-- Record has it.
and
lgh_number=@minlgh
--===========================================================
-- END LOG WHAT WAS SENT
--===========================================================
END
END -- END REVERSE OUT ALL PREVIOUS AMOUNTS FOR THIS MOVE
--
--========================================================================================
-- INSERT ONE RECORD FOR EACH LEGHEADER FOR THE MOVE
--========================================================================================

Set @minTractor =''
Set @minlgh=0
WHILE 1=1 -- Loop through all Legheader on the move
BEGIN

Select @minlgh=
( select min(lgh_number)
from  legheader
where legheader.mov_number=@minMov_number
and lgh_number>@minlgh)

if isnull(@minlgh, '') = '' BREAK -- FINISHED

Set @minTractor=
ISNULL  (
(
Select
lgh_tractor
from
legheader
where  lgh_number=@minlgh
)
,'UNKNOWN'
)
Set @tractor=@minTractor

if (  (@tractor<> 'UNKNOWN') AND (LTRIM(@tractor)<>'')  ) -- SKIP UNKNOWN or blank

BEGIN
select @lgh_miles = sum (isnull(stp_lgh_mileage,0)) from stops where lgh_number = @minlgh

IF isnull(@lgh_miles, '') = ''
select @lgh_miles = 0

IF @lgh_miles>0
BEGIN
-- MRH Conversion to kilometers option
if (SELECT COUNT(1) FROM generalinfo where gi_name = 'Shoplink' and gi_integer3 = 1) > 0
begin
set @lgh_miles = @lgh_miles * 1.60935
SET @METERUOM = 'KM'
end

select @tmtserver = gi_string1 from generalinfo where gi_name = 'Shoplink'

if RTRIM(ISNULL(@tmtserver,'')) = RTRIM(ISNULL(Cast(@@SERVERNAME as varchar(50)),''))
set @localserver = 1
else set @localserver = 0

--================================================================
--=== ACTUAL CALL STUFF-- assumes @lgh_miles, @tractor already SET
--================================================================

SELECT @TMTUNITTYPE = isnull(trc_ams_type, 'TRACTOR') FROM TRACTORPROFILE WHERE TRC_NUMBER = @TRACTOR
SELECT @METERDATE = lgh_enddate from legheader where lgh_number = @minlgh

IF (SELECT GI_STRING1
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink') <> @@servername
BEGIN
BEGIN TRY
SELECT @TMTSERVER = '[' + GI_STRING1 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql =   'EXEC '+@tmtserver + '.' + @tmtdb
+ '.dbo.USP_METERDEF_CREATE '
+ '@ERRORID OUTPUT'
+ ', @METERDEFID OUTPUT'
+ ', @METERTYPE'
+ ', @COMPCDKEY'
+ ', @COMPCODE'
+ ', @PHYSICAL'
+ ', @METERUOM'
+ ', @DESCRIP'
+ ', @MODIFIEDBY'


IF @DEBUG = 1
PRINT 'SQL5' + ':' + @SQL
EXEC SP_EXECUTESQL @SQL, N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)'
,@ERRORS OUTPUT
,@METERDEFID OUTPUT
,@METERTYPE
,@COMPCDKEY
,@COMPCODE
,@PHYSICAL
,@METERUOM
,@DESCRIP
,@MODIFIEDBY

--SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' +
--	 @tmtserver + '.' + @tmtdb +
--	 '.[dbo].METERDEF WHERE METERTYPE = @LOCALMETERTYPE1) EXEC ' +
--	 @tmtserver + '.' + @tmtdb +
--	 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--								  @LOCALDESCRIP,
--								  @LOCALPHYSICAL,
--								  @LOCALMETERUOM,
--								  @LOCALERRORS OUTPUT '

--EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--					 @LOCALMETERTYPE VARCHAR(12),
--					 @LOCALDESCRIP VARCHAR(60),
--					 @LOCALPHYSICAL CHAR(1),
--					 @LOCALMETERUOM VARCHAR(12),
--					 @LOCALERRORS INTEGER',
--					 @METERTYPE,
--					 @METERTYPE,
--					 @DESCRIP,
--					 @PHYSICAL,
--					 @METERUOM,
--					 @ERRORS

--Done
SET @SQL = 'DECLARE @INTEGRATIONID int
SELECT  @INTEGRATIONID = [INTEGRATIONID]   FROM ' +
@tmtserver + '.' + @tmtdb +
'.[dbo].[INTEGRATION]  WHERE [INTNAME] =''TMWSUITE'';  EXEC ' +
@tmtserver + '.' + @tmtdb +
'.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
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
EXEC SP_EXECUTESQL @SQL, N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)',
@TRACTOR,
NULL,
NULL,
@METERTYPE,
@LGH_MILES,
@METERDATE,
NULL,
@ERRORS,
NULL,
@TMTUNITTYPE
END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_SP   :  '
+ 'ERROR NUMBER:' + CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(), @BLANK)

SELECT @MESSAGE [ERROR MESSAGE],@TRACTOR [TRACTOR],
@METERTYPE [METERTYPE],
@LGH_MILES [GH_MILES],
@METERDATE [METERDATE],
@ERRORS [ERRORS],
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH
END --(select gi_string1 from generalinfo (NOLOCK) where gi_name = 'Shoplink') <> @@servername
ELSE
BEGIN
BEGIN TRY
SELECT @tmtdb = '[' + GI_STRING2 + ']'
FROM GENERALINFO (NOLOCK)
WHERE GI_NAME = 'Shoplink'

SET @sql =  'EXEC '+ @tmtdb
+ '.dbo.USP_METERDEF_CREATE '
+ '@ERRORID OUTPUT'
+ ', @METERDEFID OUTPUT'
+ ', @METERTYPE'
+ ', @COMPCDKEY'
+ ', @COMPCODE'
+ ', @PHYSICAL'
+ ', @METERUOM'
+ ', @DESCRIP'
+ ', @MODIFIEDBY'

IF @DEBUG = 1
PRINT 'SQL7' + ':' + @SQL
EXEC SP_EXECUTESQL @SQL, N'@ERRORID INT OUTPUT
,@METERDEFID INT OUTPUT
,@METERTYPE VARCHAR(12)
,@COMPCDKEY VARCHAR(12)
,@COMPCODE VARCHAR(12)
,@PHYSICAL CHAR(1)
,@METERUOM CHAR(12)
,@DESCRIP VARCHAR(60)
,@MODIFIEDBY VARCHAR(40)'
,@ERRORS OUTPUT
,@METERDEFID OUTPUT
,@METERTYPE
,@COMPCDKEY
,@COMPCODE
,@PHYSICAL
,@METERUOM
,@DESCRIP
,@MODIFIEDBY


--SET @SQL = 'IF NOT EXISTS(SELECT METERDEFID FROM ' + @tmtdb +
--	 '.[dbo].METERDEF WHERE METERTYPE = @LOCALMETERTYPE1) EXEC '+ @tmtdb +
--	 '.[dbo].[SP_METERDEF_INSERT] @LOCALMETERTYPE,
--								  @LOCALDESCRIP,
--								  @LOCALPHYSICAL,
--								  @LOCALMETERUOM,
--								  @LOCALERRORS OUTPUT '

--EXEC SP_EXECUTESQL @SQL, N'@LOCALMETERTYPE1 VARCHAR(12),
--					 @LOCALMETERTYPE VARCHAR(12),
--					 @LOCALDESCRIP VARCHAR(60),
--					 @LOCALPHYSICAL CHAR(1),
--					 @LOCALMETERUOM VARCHAR(12),
--					 @LOCALERRORS INTEGER',
--					 @METERTYPE,
--					 @METERTYPE,
--					 @DESCRIP,
--					 @PHYSICAL,
--					 @METERUOM,
--					 @ERRORS

--Done
SET @SQL = 'DECLARE @INTEGRATIONID int  SELECT @INTEGRATIONID = ' +  @tmtdb +
'.[dbo].[TMT_INTEGRATIONID](''TMWSUITE'');  EXEC ' + @tmtdb +
'.[dbo].[TMTEXT_METERMAID_WITHVALIDATE] @UNITID,
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
EXEC SP_EXECUTESQL @SQL, N' @UNITID VARCHAR(24),
@ORDERTYPE VARCHAR(12),
@ORDERID INTEGER,
@METERTYPE VARCHAR(12),
@METERREADING NUMERIC(15,6),
@METERDATE DATETIME,
@VALIDATE CHAR(1),
@ERRORS INTEGER,
@CUSTOMERNAME  VARCHAR(12),
@UNITTYPE VARCHAR(12)',
@TRACTOR,
NULL,
NULL,
@METERTYPE,
@LGH_MILES,
@METERDATE,
NULL,
@ERRORS,
NULL,
@TMTUNITTYPE
END TRY
BEGIN CATCH

SELECT @MESSAGE = 'TMT_METER_TRANSFER_SP   :  '
+ 'ERROR NUMBER:' + CAST(ERROR_NUMBER() AS VARCHAR)
+ '  ERROR MESSAGE: ' + ISNULL(ERROR_MESSAGE(), @BLANK)

SELECT @MESSAGE [ERROR MESSAGE],@TRACTOR [TRACTOR],
@METERTYPE [METERTYPE],
@LGH_MILES [GH_MILES],
@METERDATE [METERDATE],
@ERRORS [ERRORS],
@TMTUNITTYPE [TMTUNITTYPE]
END CATCH
END
--================================================================
--=== END ACTUAL CALL STUFF-- assumes @lgh_miles, @tractor already SET
--================================================================

--===========================================================
-- LOG WHAT WAS SENT
--===========================================================

-- CLear any other updates so only latest has lgh_miles
Update TMTMeterTransferHistory          -- Clear Lgh_number
set lgh_number=-@minlgh         -- so Only lastest
where  Mov_number=@minMov_number-- Record has it.
and
lgh_number=@minlgh

INSERT TMTMeterTransferHistory
(Mov_number,tractor,lgh_miles, lgh_number)
VALUES
(@minMov_number,@tractor,@lgh_miles,@minlgh)
--===========================================================
-- END LOG WHAT WAS SENT
--===========================================================
END --IF @lgh_miles>0
END -- Tractor<> UNKNOWN
END -- WHILE LOOP FOR EACH LGH
NEXT_MOVE:
END -- MOVE LIST
GO
GRANT EXECUTE ON  [dbo].[TMT_METER_TRANSFER_SP] TO [public]
GO
