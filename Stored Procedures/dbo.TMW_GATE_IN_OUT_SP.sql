SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

----------------------------------
---    TMW_GATE_IN_OUT_SP.SQL

----------------------------------
CREATE     PROCEDURE [dbo].[TMW_GATE_IN_OUT_SP]
@TRC_NUMBER VARCHAR(8)
,@Message VARCHAR(256) OUT
AS
BEGIN
SET @message = ''
---create temp table to hold the data
CREATE TABLE #temp
(
Currently_loaded VARCHAR(1)
,ord_hdrnumber INT
,lgh_number INT
,mov_number INT
,lgh_driver1 VARCHAR(8)
,lgh_type2 VARCHAR(8)
,lgh_primary_trailer VARCHAR(8)
,ord_billto VARCHAR(8)
,trc_owner VARCHAR(12)
,ord_mintemp INT
,due_out DATETIME
,lgh_outstatus VARCHAR(8)
)


DECLARE @lghnumber INT
,@lgh_startdate DATETIME
,@TRC_AMS_TYPE VARCHAR (12)
,@TRL_AMS_TYPE VARCHAR (12)
---start with the current started legheader
INSERT INTO #temp
( ord_hdrnumber
,lgh_number
,mov_number
,lgh_driver1
,lgh_primary_trailer
,ord_billto
,lgh_outstatus
)
SELECT  ord_hdrnumber
,lgh_number
,mov_number
,lgh_driver1
,lgh_primary_trailer
,ord_billto
,lgh_outstatus

FROM    legheader_active WITH ( NOLOCK )
WHERE   lgh_tractor = @TRC_NUMBER
AND lgh_outstatus = 'STD'


-- if no current STD leg found then look for DSP

SELECT @lghnumber = ISNULL(lgh_number, 0)
FROM   #temp
IF ISNULL(@lghnumber, 0) < 1
BEGIN
SELECT  @lgh_startdate = MIN(lgh_startdate)
FROM    legheader_active
WHERE   lgh_startdate >= GETDATE()
AND lgh_outstatus = 'PLN'
AND lgh_tractor = @TRC_NUMBER
SELECT  @lghnumber = lgh_number
FROM    legheader_active
WHERE   lgh_tractor = @TRC_NUMBER
AND lgh_outstatus = 'DSP'
AND lgh_startdate = @lgh_startdate
END
IF ISNULL(@lghnumber, 0) > 0
BEGIN
INSERT  INTO #temp
( ord_hdrnumber
,lgh_number
,mov_number
,lgh_driver1
,lgh_primary_trailer
,ord_billto
,lgh_outstatus
)
SELECT  ord_hdrnumber
,lgh_number
,mov_number
,lgh_driver1
,lgh_primary_trailer
,ord_billto
,lgh_outstatus
FROM    legheader_active WITH ( NOLOCK )
WHERE   @lghnumber = lgh_number
END

-- if no current DSP leg found then look for PLN
SELECT @lghnumber = ISNULL(lgh_number, 0)
FROM   #temp
IF ISNULL(@lghnumber, 0) < 1
BEGIN
SELECT  @lgh_startdate = MIN(lgh_startdate)
FROM    legheader_active
WHERE   lgh_startdate >= GETDATE()
AND lgh_outstatus = 'PLN'
AND lgh_tractor = @TRC_NUMBER

SELECT  @lghnumber = lgh_number
FROM    legheader_active
WHERE   lgh_tractor = @TRC_NUMBER
AND lgh_outstatus = 'PLN'
AND lgh_startdate = @lgh_startdate

END
IF ISNULL(@lghnumber, 0) > 0
BEGIN
INSERT  INTO #temp
( ord_hdrnumber
,lgh_number
,mov_number
,lgh_driver1
,lgh_primary_trailer
,ord_billto
,lgh_outstatus
)
SELECT  ord_hdrnumber
,lgh_number
,mov_number
,lgh_driver1
,lgh_primary_trailer
,ord_billto
,lgh_outstatus
FROM    legheader_active WITH ( NOLOCK )
WHERE   @lghnumber = lgh_number
END
-- if no current leg found then return message
SELECT @lghnumber = ISNULL(lgh_number, 0)
FROM   #temp
IF ISNULL(@lghnumber, 0) < 1
BEGIN
SELECT  @Message = @Message + ' ' + 'No Dispatch Found'
END


ELSE
BEGIN
--look for loaded or not
DECLARE @cntpup INT
,@cntdrp INT


--Check to see if at least one pickup has occured
SELECT  @cntpup = COUNT(*)
FROM    stops
,#temp
WHERE   stops.mov_number = #temp.mov_number
AND ( stp_type = 'PUP'
OR stp_event = 'XDL'
)
AND stp_status = 'DNE'

--Check to see if at least one drop is still open
SELECT  @cntdrp = COUNT(*)
FROM    stops
,#temp
WHERE   stops.mov_number = #temp.mov_number
AND ( stp_type = 'DRP'
OR stp_event = 'XDU'
)
AND stp_status = 'OPN'

--if one pickup is done and one drop is open then the tractor is "loaded"
IF @cntpup > 0
AND @cntdrp > 0
BEGIN
UPDATE #temp
SET    Currently_loaded = 'Y'
END
ELSE
BEGIN
UPDATE #temp
SET    Currently_loaded = 'N'
END

--add ord_min temp
UPDATE  #temp
SET     #temp.ord_mintemp = orderheader.ord_mintemp
FROM    orderheader WITH ( NOLOCK )
WHERE   orderheader.ord_hdrnumber = #temp.ord_hdrnumber

--add tractor owner
UPDATE  #temp
SET     #temp.trc_owner = ISNULL(tractorprofile.trc_owner, 'UNK')
FROM    tractorprofile WITH ( NOLOCK )
WHERE   trc_number = @TRC_NUMBER

--gather data to figure distance from current check call to next stop

---current check call lat long.
DECLARE @last_date DATETIME
,@lgh_number INT
,@check_call_lat DECIMAL
,@check_call_long DECIMAL
,@company VARCHAR(24)
,@company_lat DECIMAL
,@company_long DECIMAL
,@city INT
,@companycity INT
,@stop INT
,@nextstop_date DATETIME
,@mileage DECIMAL
,@lgh_type2 VARCHAR(8)
,@unit DECIMAL
,@mph DECIMAL

SELECT  @lgh_number = lgh_number
,@lgh_type2 = lgh_type2
FROM    #temp

SELECT  @last_date = MAX(ckc_date)
FROM    assetassignment
,checkcall
WHERE   ( assetassignment.asgn_id = @TRC_NUMBER )
AND ( assetassignment.asgn_type = 'TRC' )
AND ( @lgh_number = checkcall.ckc_lghnumber )


SELECT  @check_call_lat = ckc_latseconds
,@check_call_long = ckc_longseconds
FROM    assetassignment
,checkcall
WHERE   ( assetassignment.asgn_id = @TRC_NUMBER )
AND ( assetassignment.asgn_type = 'TRC' )
AND ( @lgh_number = checkcall.ckc_lghnumber )
AND ckc_date = @last_date
--next stop lat long
SELECT  @stop = MIN(stp_number)
FROM    stops
WHERE   lgh_number = @lgh_number
AND stp_status <> 'DNE'
AND ord_hdrnumber <> 0



SELECT  @company = cmp_id
,@city = stp_city
,@nextstop_date = stp_schdtearliest
FROM    stops
WHERE   stp_number = @stop

SELECT  @company_lat = CAST (cmp_latseconds AS DECIMAL(38, 20)) / 3600.00
,@company_long = CAST (cmp_longseconds AS DECIMAL(38, 20)) / 3600.00
,@companycity = cmp_city
FROM    company
WHERE   cmp_id = @company
IF @company_lat IS NULL
OR @company_long IS NULL
OR @company = 'UNKNOWN'
BEGIN
IF @companycity IS NULL
SELECT  @companycity = @city
SELECT @company_lat = cty_latitude
,@company_long = cty_longitude
FROM   city
WHERE  cty_code = @companycity
END

SELECT  @mileage = ISNULL(dbo.tmw_airdistance_fn(@check_call_lat, @check_call_long, @company_lat, @company_long),0)



IF @lgh_type2 = 'TEAM'
BEGIN
SELECT @mph = 46
END
ELSE
BEGIN
SELECT @mph = 28
END


SELECT  @unit = -1 * ( ( @mileage / @mph ) / 60 )
UPDATE  #temp
SET     due_out = DATEADD(MINUTE, @unit, @nextstop_date)


IF @mileage < 1
BEGIN
SELECT @Message = @Message + ' ' + 'No Mileage Found'
END

END

Select @TRC_AMS_TYPE = isnull (TRC_AMS_TYPE , 'TRACTOR')
from tractorprofile
where @TRC_NUMBER = trc_number

Select @TRl_AMS_TYPE = isnull (TRl_AMS_TYPE , 'TRAILER')
from trailerprofile, #temp
where lgh_primary_trailer = trl_number


SELECT Currently_loaded
,lgh_number
,due_out
,ord_billto
,ord_mintemp
,lgh_driver1
,trc_owner
,lgh_primary_trailer
,lgh_outstatus
,@TRC_AMS_TYPE TRC_AMS_TYPE
,@TRl_AMS_TYPE TRl_AMS_TYPE
FROM   #temp

END
GO
GRANT EXECUTE ON  [dbo].[TMW_GATE_IN_OUT_SP] TO [public]
GO
