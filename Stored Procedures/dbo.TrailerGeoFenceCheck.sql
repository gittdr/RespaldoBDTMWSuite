SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[TrailerGeoFenceCheck] @trlId varchar(13), @CmpId varchar(8), @SightingDate datetime
as
declare @CurTZSightingDate datetime, @NxtTZSightingDate datetime
declare @SightingCountry varchar(4), @DupSightingDate datetime
declare @CurAsgnSttMfh int, @CurAsgnEndMfh int
declare @CurAsgnSttStp int, @CurAsgnEndStp int
declare @CurMov int, @CurStp int, @CurCmp varchar(8), @CurSeq int, @CurDate datetime, @CurCty int
declare @CurCar varchar(8), @CurDrv1 varchar(8), @CurDrv2 varchar(8), @CurTrc varchar(8), @CurLgh int
DECLARE @CurDptDate datetime, @CurDptStatus varchar(6), @CurDptDtInSysTZ datetime
declare @DptStat varchar(6), @DptMov int, @DptStp int, @DptSeq int, @DptDate datetime
declare @DptCar varchar(8), @DptDrv1 varchar(8), @DptDrv2 varchar(8), @DptTrc varchar(8)
declare @NxtAsgnSttMfh int, @NxtAsgnEndMfh int
declare @NxtAsgnSttStp int, @NxtAsgnEndStp int
declare @NxtMov int, @NxtStp int, @NxtCmp varchar(8), @NxtSeq int, @NxtCty int
declare @NxtCar varchar(8), @NxtDrv1 varchar(8), @NxtDrv2 varchar(8), @NxtTrc varchar(8), @NxtLgh int
declare @NxtDptDate datetime, @NxtDptDtInSysTZ datetime
declare @TmpMov int, @TmpSeq int, @Result varchar(6), @ErrDescription varchar(MAX), @TrlGeoFncRules int
declare @CurTargetable varchar(1), @DptTargetable varchar(1), @NxtTargetable varchar(1)
declare @IncompleteExternalArrival varchar(1)
declare @SysTZ int, @SysTZMins int, @MakeTZAdjusts char(1), @SysDSTCode int
declare @CurTZ int, @CurTZMins int, @CurDSTCode int, @CurDSTFlag varchar(1)
declare @NxtTZ int, @NxtTZMins int, @NxtDSTCode int, @NxtDSTFlag varchar(1)

IF ISNULL(@CmpId, '') = '' SET @CmpId = 'UNKNOWN'

SET @MakeTZAdjusts = 'N'
SET @SysTZ = -15
SET @SysTZMins = 0
SET @SysDSTCode = 0
SET @Result='NONE'

-- Get operational flags
SELECT @TrlGeoFncRules = 60
SELECT @TrlGeoFncRules = ISNULL(gi_integer1, 60) from generalinfo where gi_name = 'TrlGeoFncRules'

-- Get info from current assetassignment
select top 1 @CurMov = asn.mov_number, @CurAsgnSttStp = sttStp.stp_number, @CurAsgnEndStp = endStp.stp_number,
  @CurAsgnSttMfh = sttStp.stp_mfh_sequence, @CurAsgnEndMfh = endStp.stp_mfh_sequence
 from assetassignment asn 
 left outer join 
  (event sttEvt inner join stops sttStp on sttEvt.stp_number = sttStp.stp_number) 
  on asn.evt_number = sttEvt.evt_number
 left outer join 
  (event endEvt inner join stops endStp on endEvt.stp_number = endStp.stp_number) 
  on asn.last_evt_number = endEvt.evt_number
 where asgn_type='TRL' and asgn_id = @trlId and (asgn_status = 'CMP' or asgn_status = 'STD')
 order by asgn_Date desc

-- Get current Stop
if ISNULL(@CurMov, 0)>0 and ISNULL(@CurAsgnSttMfh, 0)>0 and ISNULL(@CurAsgnEndMfh, 0)>0
 select top 1 @CurStp = stops.stp_number, @CurCmp = cmp_id, @CurSeq = stp_mfh_sequence, @CurDate = stp_arrivalDate,
   @CurCar = event.evt_carrier, @CurDrv1 = event.evt_driver1, @CurDrv2 = event.evt_driver2, @CurCty = stp_city,
   @CurTrc = event.evt_tractor, @CurDptDate = stp_departureDate, @CurDptStatus = stp_departure_status, 
   @CurLgh = stops.lgh_number
  from stops inner join event on stops.stp_number=event.stp_number
  where mov_number=@CurMov and stp_status ='DNE' and event.evt_trailer1=@trlid and event.evt_sequence=1 
   and stp_mfh_sequence >= @CurAsgnSttMfh and stp_mfh_sequence <= @CurAsgnEndMfh
  order by stp_mfh_sequence DESC

IF ISNULL(@CurCmp, '') = '' SET @CurCmp = 'UNKNOWN'

-- Make sure sighting does not occur before currently actualized activity.
-- First Timezone adjust the sighting to be in current stop city's timezone.
IF ISNULL(@CurCty, 0) > 0
 BEGIN
 SELECT @MakeTZAdjusts = LEFT(UPPER(ISNULL(gi_string1, 'N')), 1)
  FROM generalinfo 
  WHERE gi_name = 'MakeTZAdjustments'
 
 IF @MakeTZAdjusts = 'Y'
  BEGIN
  SELECT @SysTZ = ISNULL(CONVERT(int, gi_string1), -15)
   FROM generalinfo 
   WHERE gi_name = 'SysTZ'
  
  IF @SysTZ<-14 OR @SysTZ>14 -- If SysTZ is invalid, then turn timezone adjustments back off.
   SELECT @MakeTZAdjusts = 'N', @SysTZ = Null
  END
 END

IF @MakeTZAdjusts = 'Y'
 BEGIN
 SELECT @SysTZMins = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no additional minutes
 FROM generalinfo 
  WHERE gi_name = 'SysTZMins'
 
 SELECT @SysDSTCode = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to US DST
  FROM generalinfo 
  WHERE gi_name = 'SysDSTCode'
 
 SELECT  @CurTZ = ISNULL(city.cty_GMTDelta, -15),
   @CurDSTFlag = LEFT(ISNULL(city.cty_DSTApplies, 'N'), 1),
   @CurTZMins = ISNULL(city.cty_TZMins, 0)
 FROM city
 WHERE city.cty_code = @CurCty
 
 IF @CurDSTFlag = 'Y'
  SET @CurDSTCode = 0
 ELSE 
  SET @CurDSTCode = -1
 
 IF @CurTZ > -15 AND @CurTZ < 15
  BEGIN
  SELECT @CurTZSightingDate = dbo.ChangeTZ(@CurTZSightingDate, @SysTZ, @SysDSTCode, @SysTZMins, @CurTZ, @CurDSTCode, @CurTZMins)
  SELECT @CurDptDtInSysTZ = dbo.ChangeTZ(@CurDptDate, @CurTZ, @CurDSTCode, @CurTZMins, @SysTZ, @SysDSTCode, @SysTZMins)
  END
 ELSE
  BEGIN
  SELECT @CurTZSightingDate = @SightingDate
  SELECT @CurDptDtInSysTZ = @CurDptDate
  END
 END
ELSE
 BEGIN
 SET @CurTZSightingDate = @SightingDate
 SELECT @CurDptDtInSysTZ = @CurDptDate
 END

-- Now check if the sighting is before other actualized activity (in which case it should be ignored).
if ISNULL(@CurStp, 0)>0 AND (@CurDate > @CurTZSightingDate OR (@CurDptStatus = 'DNE' and @CurDptDate > @CurTZSightingDate))
 BEGIN
 IF @CurDate > @CurTZSightingDate 
  SET @ErrDescription = 'Ping too early.  Stop '+ CONVERT(varchar(10), @CurStp) + ' arrival time: ' + CONVERT(varchar(20), @CurDate, 20) + ', TZ Adjusted ping time: ' + CONVERT(VARCHAR(20), @CurTZSightingDate, 20)
 ELSE
  SET @ErrDescription = 'Ping too early.  Stop '+ CONVERT(varchar(10), @CurStp) + ' departure time: ' + CONVERT(varchar(20), @CurDptDate, 20) + ', TZ Adjusted ping time: ' + CONVERT(VARCHAR(20), @CurTZSightingDate, 20)
 IF (@TrlGeoFncRules & 1)<>0
  SET @Result = 'ERR'
 IF (@TrlGeoFncRules & 2)<>0
  UPDATE legheader SET lgh_tm_status = 'ERROR' WHERE lgh_number = @CurLgh
 SELECT @DupSightingDate = @CurDptDtInSysTZ
 SELECT @Result Result, @CurMov CurMov, @CurStp CurStp, @DptMov DptMov, @DptStp DptStp, 
  @DptStat DptStat, @NxtMov NxtMov, @NxtStp NxtStp, 
  @IncompleteExternalArrival IncompleteExternalArrival, @CurAsgnEndStp CurAsgnEndStp, 
  @NxtAsgnSttStp NxtAsgnSttStp, @NxtAsgnEndStp NxtAsgnEndStp, @CurTZSightingDate CurTZSightingDate, 
  @NxtTZSightingDate NxtTZSightingDate, @DupSightingDate DupSightingDate, @ErrDescription ErrDescription
 RETURN
 END

-- Given a current Stp, next location begins with the first Stp after the current Stp for that trailer on that Move at a 
-- different company.
if ISNULL(@CurStp, 0)>0
 SELECT top 1 @NxtMov = mov_number, @NxtStp = stops.stp_number, @NxtCmp = stops.cmp_id, @NxtCty = stp_city,
   @NxtSeq = stops.stp_mfh_sequence, @NxtCar = event.evt_carrier, @NxtDrv1 = event.evt_driver1, 
   @NxtDrv2 = event.evt_driver2, @NxtTrc = event.evt_tractor, @NxtLgh = stops.lgh_number,
   @NxtDptDate = stops.stp_departuredate
  from stops inner join event on stops.stp_number=event.stp_number
  where mov_number=@CurMov and event.evt_trailer1=@trlid and event.evt_sequence=1 and stp_mfh_sequence > @CurSeq
   and cmp_id <> @CurCmp
   and stp_mfh_sequence >= @CurAsgnSttMfh and stp_mfh_sequence <= @CurAsgnEndMfh
  order by stp_mfh_sequence
  
-- If we have determined a next Stp here, must have also determined a current Stp.  So departure Stp will be the last
-- Stp with the equipment on the Move before the next Stp (at the very least, the current Stp will fit this criteria).
if ISNULL(@NxtStp, 0)>0
 select top 1 @DptMov=@CurMov, @DptStp = stops.stp_number,
   @DptSeq = stp_mfh_sequence, @DptCar = event.evt_carrier, @DptDrv1 = event.evt_driver1, 
   @DptDrv2 = event.evt_driver2, @DptTrc = event.evt_tractor, @DptStat = stp_departure_status,
   @DptDate = stp_departureDate
  from stops inner join event on stops.stp_number=event.stp_number
  where mov_number=@CurMov and event.evt_trailer1=@trlid and event.evt_sequence=1 and stp_mfh_sequence<@NxtSeq
   and stp_mfh_sequence >= @CurAsgnSttMfh and stp_mfh_sequence <= @CurAsgnEndMfh
  order by stp_mfh_sequence DESC
else
 BEGIN
 -- If we have not determined a next Stp, then the next Stp must be on the next unstarted assetassignment.  Find the 
 -- earliest such assetassignment.
 select top 1 @NxtMov = asn.mov_number, @NxtAsgnSttStp = sttStp.stp_number, @NxtAsgnEndStp = endStp.stp_number,
   @NxtAsgnSttMfh = sttStp.stp_mfh_sequence, @NxtAsgnEndMfh = endStp.stp_mfh_sequence
  from assetassignment asn 
  left outer join 
   (event sttEvt inner join stops sttStp on sttEvt.stp_number = sttStp.stp_number) 
   on asn.evt_number = sttEvt.evt_number
  left outer join 
   (event endEvt inner join stops endStp on endEvt.stp_number = endStp.stp_number) 
   on asn.last_evt_number = endEvt.evt_number
  where asgn_type='TRL' and asgn_id = @trlId and asgn_status <> 'CMP' and asgn_status <> 'STD'
  order by asgn_date, asgn_number 
  
 if ISNULL(@NxtMov, 0)>0 and ISNULL(@NxtAsgnSttMfh, 0) > 0 and ISNULL(@NxtAsgnEndMfh, 0) > 0
  -- If we found one, get the information about the first Stp with the trailer.
  select top 1 @NxtStp = stops.stp_number, @NxtCmp = cmp_id, @NxtSeq = stp_mfh_sequence, @NxtCty = stp_city, 
   @NxtCar = event.evt_carrier, @NxtDrv1 = event.evt_driver1, @NxtDrv2 = event.evt_driver2, 
   @NxtTrc = event.evt_tractor, @NxtLgh = stops.lgh_number, @NxtDptDate = stp_departuredate
   from stops inner join event on stops.stp_number=event.stp_number
   where mov_number=@NxtMov and event.evt_trailer1=@trlid and event.evt_sequence=1 
   and stp_mfh_sequence >= @NxtAsgnSttMfh and stp_mfh_sequence <= @NxtAsgnEndMfh
   order by stp_mfh_sequence

 if ISNULL(@CurStp, 0)> 0 and ISNULL(@NxtStp, 0)>0 and @CurCmp = @NxtCmp
  begin
  -- If the current potential next Stp is at the same location as the current Stp, then it is actually not the next
  -- Stp.  Instead, the next Stp is the first other location for the trailer on the Move.
  select @TmpMov = @NxtMov, @TmpSeq = @NxtSeq
  select @NxtMov = null, @NxtStp = null, @NxtCmp = null, @NxtCty = null, @NxtSeq = null, @NxtCar =null, 
   @NxtDrv1 = null, @NxtDrv2 = null, @NxtTrc = null, @NxtLgh = null, @NxtDptDate = null
  SELECT top 1 @NxtMov = mov_number, @NxtStp = stops.stp_number, @NxtCmp = stops.cmp_id, @NxtCty = stops.stp_city,
    @NxtSeq = stops.stp_mfh_sequence, @NxtCar = event.evt_carrier, @NxtDrv1 = event.evt_driver1, 
    @NxtDrv2 = event.evt_driver2, @NxtTrc = event.evt_tractor, @NxtLgh = stops.lgh_number, 
    @NxtDptDate = stp_departuredate
   from stops inner join event on stops.stp_number=event.stp_number
   where mov_number = @TmpMov and event.evt_trailer1=@trlid and event.evt_sequence=1 and stp_mfh_sequence > @TmpSeq
    and cmp_id <> @CurCmp
    and stp_mfh_sequence >= @NxtAsgnSttMfh and stp_mfh_sequence <= @NxtAsgnEndMfh
  order by stp_mfh_sequence
  if ISNULL(@NxtMov, 0)>0
   -- Found the next Stp in the midst of the next assetassignment, so departure Stp is the last one for the 
   --  trailer before the next Stp.
   select top 1 @DptMov=@NxtMov, @DptStp = stops.stp_number, 
     @DptSeq = stp_mfh_sequence, @DptCar = event.evt_carrier, @DptDrv1 = event.evt_driver1, 
     @DptDrv2 = event.evt_driver2, @DptTrc = event.evt_tractor, @DptStat = stp_departure_status,
     @DptDate = stp_departureDate
    from stops inner join event on stops.stp_number=event.stp_number
    where mov_number=@NxtMov and event.evt_trailer1=@trlid and event.evt_sequence=1 and stp_mfh_sequence<@NxtSeq
     and stp_mfh_sequence >= @NxtAsgnSttMfh and stp_mfh_sequence <= @NxtAsgnEndMfh
    order by stp_mfh_sequence DESC
  else
   -- Activity with no trailer Movement is not currently allowed.  Treat the trailer as though it has no activity
   -- at all.
   select @CurMov = null, @CurStp = null, @CurCmp = null, @CurSeq = null,
    @CurDate = null, @CurLgh = null, @CurDptDate = null,
    @DptStat = null, @DptMov = null, @DptStp = null, @DptSeq = null,
    @DptCar = null, @DptDrv1 = null, @DptDrv2 = null, @DptTrc = null, @DptDate = null,
    @NxtMov = null, @NxtStp = null, @NxtCmp = null, @NxtCty = null, @NxtSeq = null,
    @NxtCar = null, @NxtDrv1 = null, @NxtDrv2 = null, @NxtTrc = null, @NxtLgh = null,
    @NxtDptDate = null
  End
 else if ISNULL(@CurMov, 0)>0
  -- There was a current Stp, but the next Stp was either at the start of the next leg or did not exist at all.
  -- In either case, the departure Stp is the last Stp with the trailer on the current assetassignment
  select top 1 @DptMov=@CurMov, @DptStp = stops.stp_number, 
    @DptSeq = stp_mfh_sequence, @DptCar = event.evt_carrier, @DptDrv1 = event.evt_driver1, 
    @DptDrv2 = event.evt_driver2, @DptTrc = event.evt_tractor, @DptStat = stp_departure_status,
    @DptDate = stp_departureDate
   from stops inner join event on stops.stp_number=event.stp_number
   where mov_number=@CurMov and event.evt_trailer1=@trlid and event.evt_sequence=1
    and stp_mfh_sequence >= @CurAsgnSttMfh and stp_mfh_sequence <= @CurAsgnEndMfh
   order by stp_mfh_sequence DESC
 END

if (isnull(@CurCar, 'UNKNOWN')<>'UNKNOWN' and isnull(@CurTrc, 'UNKNOWN') = 'UNKNOWN' and 
  ISNULL(@CurDrv1, 'UNKNOWN') = 'UNKNOWN' and ISNULL(@CurDrv2, 'UNKNOWN') = 'UNKNOWN')
 set @CurTargetable = 'Y'
else
 set @CurTargetable = 'N'

if (isnull(@DptCar, 'UNKNOWN')<>'UNKNOWN' and isnull(@DptTrc, 'UNKNOWN') = 'UNKNOWN' and 
  ISNULL(@DptDrv1, 'UNKNOWN') = 'UNKNOWN' and ISNULL(@DptDrv2, 'UNKNOWN') = 'UNKNOWN')
 set @DptTargetable = 'Y'
else
 set @DptTargetable = 'N'

if (isnull(@NxtCar, 'UNKNOWN')<>'UNKNOWN' and isnull(@NxtTrc, 'UNKNOWN') = 'UNKNOWN' and 
  ISNULL(@NxtDrv1, 'UNKNOWN') = 'UNKNOWN' and ISNULL(@NxtDrv2, 'UNKNOWN') = 'UNKNOWN')
 set @NxtTargetable = 'Y'
else
 set @NxtTargetable = 'N'

if @DptTargetable = 'Y' and isnull(@CurMov, 0)<> 0 and @CurCmp <> 'UNKNOWN' and @CmpId = @CurCmp and @DptStat <> 'DNE' 
  and @CurTZSightingDate > @DptDate 
 set @Result = 'EXTEND'
if @DptTargetable = 'Y' and isnull(@CurMov, 0)<> 0 and @CurCmp <> 'UNKNOWN' and @CmpId <> @CurCmp and @DptStat <> 'DNE'
 set @Result = 'DEPART'
if @NxtTargetable = 'Y' and isnull(@NxtMov, 0)<> 0 and @NxtCmp <> 'UNKNOWN' and @CmpId = @NxtCmp
 BEGIN
 set @Result = 'ARRIVE'
 IF @MakeTZAdjusts IS NULL
  BEGIN
  SELECT @MakeTZAdjusts = LEFT(UPPER(ISNULL(gi_string1, 'N')), 1)
   FROM generalinfo 
   WHERE gi_name = 'MakeTZAdjustments'
 
  IF @MakeTZAdjusts = 'Y'
   BEGIN
   SELECT @SysTZ = ISNULL(CONVERT(int, gi_string1), -15)
    FROM generalinfo 
    WHERE gi_name = 'SysTZ'
  
   IF @SysTZ<-14 OR @SysTZ>14 -- If SysTZ is invalid, then turn timezone adjustments back off.
    SELECT @MakeTZAdjusts = 'N', @SysTZ = Null
   END
  
  IF @MakeTZAdjusts = 'Y'
   BEGIN
   SELECT @SysTZMins = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no additional minutes
    FROM generalinfo 
    WHERE gi_name = 'SysTZMins'
 
   SELECT @SysDSTCode = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to US DST
    FROM generalinfo 
    WHERE gi_name = 'SysDSTCode'
   END
  END
 IF @MakeTZAdjusts = 'Y'
  BEGIN
  SELECT  @NxtTZ = ISNULL(city.cty_GMTDelta, -15),
    @NxtDSTFlag = LEFT(ISNULL(city.cty_DSTApplies, 'N'), 1),
    @NxtTZMins = ISNULL(city.cty_TZMins, 0)
  FROM city
  WHERE city.cty_code = @NxtCty
  
  IF @NxtDSTFlag = 'Y'
   SET @NxtDSTCode = 0
  ELSE 
   SET @NxtDSTCode = -1
  
  IF @NxtTZ > -15 AND @NxtTZ < 15
   BEGIN
   SELECT @NxtTZSightingDate = dbo.ChangeTZ(@NxtTZSightingDate, @SysTZ, @SysDSTCode, @SysTZMins, @NxtTZ, @NxtDSTCode, @NxtTZMins)
   SELECT @NxtDptDtInSysTZ = dbo.ChangeTZ(@NxtDptDate, @NxtTZ, @NxtDSTCode, @NxtTZMins, @SysTZ, @SysDSTCode, @SysTZMins)
   END
  ELSE
   BEGIN
   SELECT @NxtTZSightingDate = @SightingDate 
   SELECT @NxtDptDtInSysTZ = @NxtDptDate
   END
  END
 ELSE
  BEGIN
  SELECT @NxtTZSightingDate = @SightingDate 
  SELECT @NxtDptDtInSysTZ = @NxtDptDate
  END
 END

if (@CurTargetable='N' and @DptTargetable = 'Y') 
 BEGIN
 IF ISNULL(@CurAsgnSttMfh, 0)>0 and ISNULL(@CurAsgnEndMfh, 0)>0 and 
   exists (
  select * from stops inner join event on stops.stp_number = event.stp_number and event.evt_sequence=1 
  where stops.mov_number = @CurMov and stops.stp_mfh_sequence >= @CurAsgnSttMfh and stops.stp_mfh_sequence <= @CurAsgnEndMfh
   and (ISNULL(event.evt_carrier, 'UNKNOWN') = 'UNKNOWN' or ISNULL(event.evt_tractor, 'UNKNOWN') <> 'UNKNOWN'
    or ISNULL(event.evt_driver1, 'UNKNOWN') <> 'UNKNOWN' or ISNULL(event.evt_driver2, 'UNKNOWN') <> 'UNKNOWN')
   and event.evt_trailer1 = @trlId and stops.stp_mfh_sequence >= ISNULL(@CurSeq, 0) 
   and (@CurMov <> ISNULL(@DptMov, 0) or stops.stp_mfh_sequence <= ISNULL(@DptSeq, 99))
   and (stops.stp_status='OPN' or stops.stp_departure_status = 'OPN')
   )
  SET @IncompleteExternalArrival='Y'
 else IF ISNULL(@NxtAsgnSttMfh, 0)>0 and ISNULL(@NxtAsgnEndMfh, 0)>0 
   and ISNULL(@DptMov, 0)>0 and ISNULL(@DptMov, 0) <> ISNULL(@CurMov, 0) 
   and exists (
  select * from stops inner join event on stops.stp_number = event.stp_number and event.evt_sequence=1 
  where stops.mov_number = @CurMov and stops.stp_mfh_sequence >= @CurAsgnSttMfh and stops.stp_mfh_sequence <= @CurAsgnEndMfh
   and (ISNULL(event.evt_carrier, 'UNKNOWN') = 'UNKNOWN' or ISNULL(event.evt_tractor, 'UNKNOWN') <> 'UNKNOWN'
    or ISNULL(event.evt_driver1, 'UNKNOWN') <> 'UNKNOWN' or ISNULL(event.evt_driver2, 'UNKNOWN') <> 'UNKNOWN')
   and event.evt_trailer1 = @trlId and stops.stp_mfh_sequence >= ISNULL(@CurSeq, 0) 
   and (stops.stp_status='OPN' or stops.stp_departure_status = 'OPN')
   )
  SET @IncompleteExternalArrival='Y'
 else
  SET @IncompleteExternalArrival='N'
 END
ELSE
 SET @IncompleteExternalArrival='N'

IF @Result = 'NONE' AND @NxtTargetable = 'N' AND (@TrlGeoFncRules & 12) <> 0 AND ISNULL(@NxtLgh, 0) <> 0 AND ISNULL(@CmpId, 'UNKNOWN')<>'UNKNOWN' AND ISNULL(@CmpId, 'UNKNOWN')<>'UNKNOWN'
 BEGIN
 SELECT @SightingCountry = cty_country from city inner join company on city.cty_code = company.cmp_city where company.cmp_id = @CmpId
 IF ISNULL(@SightingCountry, 'USA') = 'MEX'
  BEGIN
  SELECT @ErrDescription = 'Unexpected sighting at a Mexican company'
  IF (@TrlGeoFncRules & 4)<>0
   SET @Result = 'ERR'
  IF (@TrlGeoFncRules & 8)<>0
   UPDATE legheader SET lgh_tm_status = 'ERROR' WHERE lgh_number = @NxtLgh
  END
 END

IF (@Result = 'NONE' OR @Result = 'DEPART') AND @NxtTargetable = 'Y' AND (@TrlGeoFncRules & 48) <> 0 AND ISNULL(@NxtLgh, 0) <> 0 AND ISNULL(@CmpId, 'UNKNOWN')<>'UNKNOWN' AND ISNULL(@CmpId, 'UNKNOWN')<>'UNKNOWN'
 BEGIN
 IF @CmpId <> ISNULL(@CurCmp, 'UNKNOWN') AND @CmpId <> ISNULL(@NxtCmp, 'UNKNOWN')
  BEGIN
  SELECT @ErrDescription = 'Sighting at unexpected CmpID:'+ @CmpId +', (Current:' + CONVERT(varchar(20), ISNULL(@CurStp, 0)) + '/' + ISNULL(@CurCmp, 'UNKNOWN') + ', Next:' + CONVERT(varchar(20), ISNULL(@NxtStp, 0)) + '/' + ISNULL(@NxtCmp, 'UNKNOWN') + ')'
  IF (@TrlGeoFncRules & 16)<>0
   SET @Result = 'ERR'
  IF (@TrlGeoFncRules & 32)<>0
   UPDATE legheader SET lgh_tm_status = 'ERROR' WHERE lgh_number = @NxtLgh
  END
 END 

IF @Result = 'ARRIVE'
 SELECT @DupSightingDate = @NxtDptDtInSysTZ
ELSE IF @Result = 'DEPART'
 SELECT @DupSightingDate = '20491231 23:59:59'
ELSE
 SELECT @DupSightingDate = @CurDptDtInSysTZ
 
SELECT @Result Result, @CurMov CurMov, @CurStp CurStp, @DptMov DptMov, @DptStp DptStp, 
 @DptStat DptStat, @NxtMov NxtMov, @NxtStp NxtStp, 
 @IncompleteExternalArrival IncompleteExternalArrival, @CurAsgnEndStp CurAsgnEndStp, 
 @NxtAsgnSttStp NxtAsgnSttStp, @NxtAsgnEndStp NxtAsgnEndStp, @CurTZSightingDate CurTZSightingDate, 
 @NxtTZSightingDate NxtTZSightingDate, @DupSightingDate DupSightingDate, @ErrDescription ErrDescription
GO
GRANT EXECUTE ON  [dbo].[TrailerGeoFenceCheck] TO [public]
GO
