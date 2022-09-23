SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[TMT_LOCATION_UPDATE]
AS

/**
*
* NAME:
* dbo.TMT_LOCATION_UPDATE
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Transfer Tractor and Trailer location information to Transman if the Tractor or Trailer is in a service location.
*
* RETURNS:
* None
* RESULT SETS:
* none.
*
* PARAMETERS:
*
* REVISION HISTORY:
* 10/05/2010.01 - MRH – Created
* 09/29/2011.01 - MRH / Mindy Revised for performance.
* 04/13/2015.01 - MB Task 892 add nolock to events table
*
**/

--
--

-- Loop through all active tractors If the tractor is currently in an company that is flagged as a service location send it to Transman. Else clear the Transman location
SET ANSI_NULLS ON

SET ANSI_WARNINGS ON

DECLARE @tmtserver VARCHAR(25)
DECLARE @tmtdb VARCHAR(25)
DECLARE @shoplink INT
DECLARE @SQL [NVARCHAR](4000)
DECLARE @ERRORS [INTEGER]
DECLARE @SAMESERVER CHAR(1)
DECLARE @UNIT VARCHAR(8)
DECLARE @cmp_service_location CHAR(1)
DECLARE @CMP_ID VARCHAR(8)
DECLARE @CMPIDTYPE VARCHAR(30)
DECLARE @USEEXPLOC CHAR(1)

DECLARE @EVTTBL TABLE ( evt_trailer1 VARCHAR(13), evt_tractor VARCHAR(8), evt_startdate DATETIME )

DECLARE @TRC_LOCATIONS TABLE ( TRC_NUMBER VARCHAR(8), cmp_service_location CHAR(1), CMP_ID VARCHAR(8), cmp_altid VARCHAR(25))

DECLARE @TRL_LOCATIONS TABLE ( TRL_NUMBER VARCHAR(8), cmp_service_location CHAR(1), CMP_ID VARCHAR(8), cmp_altid VARCHAR(25))

SELECT @shoplink = COUNT( 1 )
FROM   generalinfo ( NOLOCK )
WHERE  gi_name         = 'Shoplink'
AND gi_integer1 > 0

IF @shoplink = 0
RETURN -- SHOPLINK NOT installed, exit

SELECT @SAMESERVER = 'Y'

IF ( SELECT gi_string1 FROM generalinfo ( NOLOCK ) WHERE gi_name = 'Shoplink' ) <> @@SERVERNAME
BEGIN
SELECT @tmtserver = '[' + gi_string1 + ']'
FROM   generalinfo ( NOLOCK )
WHERE  gi_name = 'Shoplink'

SELECT @tmtdb = '[' + gi_string2 + ']'
FROM   generalinfo ( NOLOCK )
WHERE  gi_name = 'Shoplink'

SELECT @SAMESERVER = 'N'
END
ELSE
BEGIN
SELECT @tmtdb = '[' + gi_string2 + ']'
FROM   generalinfo ( NOLOCK )
WHERE  gi_name = 'Shoplink'
END

SELECT @CMPIDTYPE = ISNULL( gi_string1, 'CMPID' ) --- AM-304249 added isnull check
, @USEEXPLOC = LEFT(ISNULL( gi_string2, 'N' ), 1)
FROM   generalinfo ( NOLOCK )
WHERE  gi_name = 'Shoplink_Loc_ID'

---------------------------------------------
-- Tractor logic
---------------------------------------------
IF @USEEXPLOC = 'N'
BEGIN -- Optional lookup based on last completed event.
INSERT @EVTTBL -- Has the last completed event for all tractors.
SELECT   NULL
, evt_tractor
, MAX( evt_startdate ) AS evt_startdate
FROM     [event] WITH ( NOLOCK )
WHERE    evt_status      = 'DNE'
AND evt_tractor <> 'UNKNOWN'
GROUP BY evt_tractor

INSERT @TRC_LOCATIONS -- Get the company for the tractor and last event.
SELECT     trc_number
, ISNULL( cmp_service_location, 'N' ) AS cmp_service_location
, stops.cmp_id
, cmp_altid
FROM       tractorprofile trc WITH ( NOLOCK )
INNER JOIN
(
SELECT     MAX( stp_number ) AS stp_number
, t.evt_tractor
FROM       [event] e WITH ( NOLOCK )
INNER JOIN @EVTTBL t
ON e.evt_tractor       = t.evt_tractor
AND e.evt_startdate = t.evt_startdate
GROUP BY   t.evt_tractor
)              eventtbl
ON trc.trc_number   = eventtbl.evt_tractor
INNER JOIN stops WITH ( NOLOCK )
ON stops.stp_number = eventtbl.stp_number
INNER JOIN company WITH ( NOLOCK )
ON company.cmp_id   = stops.cmp_id
END
ELSE
BEGIN -- Default Logic ... Use the tractor profile info.
INSERT @TRC_LOCATIONS
SELECT     trc_number
, ISNULL( cmp_service_location, 'N' ) AS cmp_service_location
, trc_avl_cmp_id                      AS CMP_ID
, cmp_altid
FROM       tractorprofile trc WITH ( NOLOCK )
INNER JOIN company WITH ( NOLOCK )
ON company.cmp_id = trc_avl_cmp_id
END

SELECT @UNIT = MIN( TRC_NUMBER )
FROM   @TRC_LOCATIONS

WHILE @UNIT IS NOT NULL
BEGIN
SELECT @cmp_service_location = cmp_service_location
, @CMP_ID               = CASE @CMPIDTYPE
WHEN 'CMPID' THEN CMP_ID
ELSE cmp_altid
END
FROM   @TRC_LOCATIONS
WHERE  TRC_NUMBER = @UNIT

IF @cmp_service_location = 'N'
--SET @CMP_ID = NULL
SET @CMP_ID = ''

IF @SAMESERVER = 'N'
SET @SQL = N'EXEC ' + @tmtserver + N'.' + @tmtdb + N'.[dbo].[TMTEXT_PHYLOCATION_UPD]
@UNITID,
@LOCATION,
@SHOPID,
@ERRORS'
ELSE
SET @SQL = N'EXEC ' + @tmtdb + N'.[dbo].[TMTEXT_PHYLOCATION_UPD]
@UNITID,
@LOCATION,
@SHOPID,
@ERRORS'

EXEC sp_executesql @SQL
, N'@UNITID [VARCHAR](24),
@LOCATION [VARCHAR](12),
@SHOPID [VARCHAR](12),
@ERRORS [INTEGER] OUTPUT'
, @UNIT
, NULL
, @CMP_ID
, @ERRORS

SELECT @UNIT = MIN( TRC_NUMBER )
FROM   @TRC_LOCATIONS
WHERE  TRC_NUMBER > @UNIT
END

------------------------------------
--- Trailer logic
------------------------------------
IF @USEEXPLOC = 'N'
BEGIN
INSERT @EVTTBL
SELECT   evt_trailer1
, NULL
, MAX( evt_startdate ) AS evt_startdate
FROM     [event] WITH ( NOLOCK )
WHERE    evt_status       = 'DNE'
AND evt_trailer1 <> 'UNKNOWN'
GROUP BY evt_trailer1

INSERT @TRL_LOCATIONS
SELECT     trl_number
, ISNULL( cmp_service_location, 'N' ) AS cmp_service_location
, stops.cmp_id
, cmp_altid
FROM       trailerprofile trl WITH ( NOLOCK )
INNER JOIN
(
SELECT     MAX( stp_number ) AS stp_number
, t.evt_trailer1
FROM       [event] e WITH ( NOLOCK )
INNER JOIN @EVTTBL t
ON e.evt_trailer1      = t.evt_trailer1
AND e.evt_startdate = t.evt_startdate
GROUP BY   t.evt_trailer1
)              eventtbl
ON trl.trl_number   = eventtbl.evt_trailer1
INNER JOIN stops WITH ( NOLOCK )
ON stops.stp_number = eventtbl.stp_number
INNER JOIN company WITH ( NOLOCK )
ON company.cmp_id   = stops.cmp_id
END
ELSE
BEGIN -- Default Logic ... Use the tractor profile info.
INSERT @TRL_LOCATIONS
SELECT     trl_number
, ISNULL( cmp_service_location, 'N' ) AS cmp_service_location
, trl_avail_cmp_id                    AS CMP_ID
, cmp_altid
FROM       trailerprofile trl WITH ( NOLOCK )
INNER JOIN company WITH ( NOLOCK )
ON company.cmp_id = trl_avail_cmp_id
END

SELECT @UNIT = MIN( TRL_NUMBER )
FROM   @TRL_LOCATIONS

WHILE @UNIT IS NOT NULL
BEGIN
SELECT @cmp_service_location = cmp_service_location
, @CMP_ID               = CASE @CMPIDTYPE
WHEN 'CMPID' THEN CMP_ID
ELSE cmp_altid
END
FROM   @TRL_LOCATIONS
WHERE  TRL_NUMBER = @UNIT

IF @cmp_service_location = 'N'
--SET @CMP_ID = NULL
SET @CMP_ID = ''

IF @SAMESERVER = 'N'
SET @SQL = N'EXEC ' + @tmtserver + N'.' + @tmtdb + N'.[dbo].[TMTEXT_PHYLOCATION_UPD]
@UNITID,
@LOCATION,
@SHOPID,
@ERRORS'
ELSE
SET @SQL = N'EXEC ' + @tmtdb + N'.[dbo].[TMTEXT_PHYLOCATION_UPD]
@UNITID,
@LOCATION,
@SHOPID,
@ERRORS'

EXEC sp_executesql @SQL
, N'@UNITID [VARCHAR](24),
@LOCATION [VARCHAR](12),
@SHOPID [VARCHAR](12),
@ERRORS [INTEGER] OUTPUT'
, @UNIT
, NULL
, @CMP_ID
, @ERRORS

SELECT @UNIT = MIN( TRL_NUMBER )
FROM   @TRL_LOCATIONS
WHERE  TRL_NUMBER > @UNIT
END

-- Required for cross server connections.
SET ANSI_NULLS OFF

SET ANSI_WARNINGS OFF
GO
GRANT EXECUTE ON  [dbo].[TMT_LOCATION_UPDATE] TO [public]
GO
