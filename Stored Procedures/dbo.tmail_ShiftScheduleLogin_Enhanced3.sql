SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE PROCEDURE [dbo].[tmail_ShiftScheduleLogin_Enhanced3] (
@P_SSID VARCHAR(20), 
@Drv VARCHAR(30), 
@Trc VARCHAR(30), 
@TRL VARCHAR(30), 
@Trl2 VARCHAR(30), 
@LoginDATETIME VARCHAR(30),     
@Flags VARCHAR(30), 
@NumberMinutesToCheckPreviousNextDays VARCHAR (4),
@NumberMinutesOfPrevNextDayToCheck VARCHAR (4))    
          
AS    
    
/*    
    
 Purpose: UPDATEs the driver login ON the shift schedule alONg with     
   validating AND/or SETting the approapriate asSETs for     
   Tractor, Trailer1 AND Trailer2.    
       
   Flags:    
    1 - Login Shift Strictly based ON LoginDATETIME.  Does not require a shift plan.    
    2 - No error ON shift login exists.    
     IF shift already logged in, do nothing at all.    
    4 - No Error ON mismatch schedule TRC.    
    8 - No Error ON mismatch schedule TRL.    
    16 - Do Not Logout Previously Logged In Shifts    
    32 - No UPDATE of Last Mobile Comm.    
    64 - Login Shift Even If it is OFF Duty    
    128 - DON't Login - Just UPDATE the Trc,Trl,Trl2    
    256 - Switch Assets - Update only Trc,Trl,Trl2 if the Login is already set and new Trc,Trl, or Trl2    
    512 - On Re-Login, Reset Logoff    
    1024 - Use mpp_otherid (alt id) for DRV    
    2048 - Reserved (used by dbo.tmail_ShiftScheduleLookup helper routine)    
    4096 - Reserved (used by dbo.tmail_ShiftScheduleLookup helper routine)    
    8192 - Adjust all arrival/depature times on shift.    
     If all trips unstarted, and first trip starts at shift    
     start time and shift is not already logged    
     in, and flag 128 not set, then push/pull all     
     arrival/departure times of all stops on shift legheaders     
     by the number of minutes the login was late/early.    
    16384 - Ignore activity/shift status when determining shift date.    
     If time specified is within a single shift, then use    
     that shift.  Otherwise, if a shift was logged off less    
     that 1 hour before the time, use that shift.  Otherwise,    
     if a shift starts within 8 hours of the given time, use    
     that shift.    
     
 History:    
  LAB - 07/11/11 - PTS 41960 - CREATED    
  MTC - 11/2014 - PTS 87268 - Performance enhancements
  JP - 02/18/2015 - PTS 87268- Removed store proc call -UPDATE_move_light
*/    
  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  
    
 --Local Variable Declaration    
 DECLARE @SSID INT    
 DECLARE @ss_Trc VARCHAR(30)    
 DECLARE @ss_Trl VARCHAR(30)    
 DECLARE @ss_Trl_id_2 VARCHAR(30)    
 DECLARE @dtLoginDATETIME DATETIME    
 DECLARE @lgh_number INT    
 DECLARE @mov_number INT    
 DECLARE @sn INT    
 DECLARE @DEBUG INT    
 DECLARE @AlreadyLoggedIn  INT     
 DECLARE @TractorChange INT    
 DECLARE @DRVOUT VARCHAR (30)    
 DECLARE @ShiftLoginLateMinutes int, @stp int, @evt int    
 DECLARE @OrgDrv varchar(30)    
    
 --Debug -- Should be OFF when running LIVE with TotalMail    
 SET @DEBUG = 0 --0 IS OFF 1 IS ON    
    
 --Data Validation BEGIN    
 IF ISNULL(@P_SSID, '') = ''    
 BEGIN    
  --No SSID Provided, so set it to -1 (none)    
  SET @SSID = -1    
 END    
 ELSE    
 BEGIN    
  --SSID Provided    
  IF ISNUMERIC(@P_SSID)<>0    
   SET @SSID = ISNULL(CONVERT(int,@P_SSID),-1)    
  ELSE    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid SSID: %s.', 16, 1, @P_SSID)    
   RETURN    
  END     
 END      
    
 SET @OrgDrv = @Drv    
 IF ISNULL(@Drv,'') = ''    
  SET @Drv = 'UNKNOWN'    
      
 IF ISNULL(@Flags, '') = ''    
  SET @Flags = '0'    
    
 IF ISNUMERIC(@Flags)<>1    
 BEGIN    
  RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Flag: %s.', 16, 1, @Flags)    
  RETURN    
 END    
     
 IF @Flags & 1024 = 1024    
  IF NOT EXISTS (SELECT NULL FROM manpowerprofile (NOLOCK) WHERE mpp_otherid = @Drv)    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Alternate Driver ID: %s.', 16, 1, @Drv)    
   RETURN    
  END    
  ELSE    
  BEGIN    
   SELECT @Drv = mpp_id FROM manpowerprofile (NOLOCK) WHERE mpp_otherid = @Drv    
  END    
      
 IF ISNULL(@Drv,'UNKNOWN')<>'UNKNOWN'    
  IF NOT EXISTS (SELECT NULL FROM manpowerprofile (NOLOCK) WHERE mpp_id = @Drv)    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Driver ID: %s.', 16, 1, @Drv)    
   RETURN    
  END    
    
 IF ISNULL(@Trc,'')=''    
  SET @Trc = 'UNKNOWN'    
    
 IF ISNULL(@Trc,'UNKNOWN')<>'UNKNOWN'    
  IF NOT EXISTS (SELECT NULL FROM tractorprofile (NOLOCK) WHERE trc_number = @trc)    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Tractor Number: %s.', 16, 1, @trc)    
   RETURN    
  END    
      
 IF ISNULL(@Trl,'') = ''    
  SET @Trl = 'UNKNOWN'    
      
 IF ISNULL(@Trl,'UNKNOWN')<>'UNKNOWN'    
  IF NOT EXISTS (SELECT NULL FROM trailerprofile (NOLOCK) WHERE trl_number = @trl)    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Trailer Number: %s.', 16, 1, @trl)    
   RETURN    
  END    
      
 IF ISNULL(@Trl2,'')=''    
  SET @Trl2 = 'UNKNOWN'     
      
 IF ISNULL(@Trl2,'UNKNOWN')<>'UNKNOWN'    
  IF NOT EXISTS (SELECT NULL FROM trailerprofile (NOLOCK) WHERE trl_number = @Trl2)    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Trailer Number: %s.', 16, 1, @trl2)    
   RETURN    
  END     
    
 IF ISDATE(@LoginDATETIME) = 0    
 BEGIN    
  RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Login Date: %s.', 16, 1, @LoginDATETIME)    
  RETURN    
 END    
 ELSE     
 BEGIN    
  SET @dtLoginDATETIME = @LoginDATETIME    
 END    
    
 --Validate the Pairings of SSID to Driver and SSID to Login DateTime    
 IF ISNULL(@SSID,-1) > 0    
 BEGIN    
  IF NOT EXISTS (SELECT ss_id from ShiftSchedules where ss_id = @SSID and mpp_id = @Drv)    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Driver for SSID: DRV:%s,SSID:%s', 16, 1, @Drv, @P_ssid)    
   RETURN    
  END    
 END    
     
 IF ISNULL(@SSID,-1) > 0    
 BEGIN    
  IF NOT EXISTS (SELECT ss_id from ShiftSchedules where ss_id = @SSID and ss_date between dateadd(day,-1,CONVERT(varchar(20), @dtLoginDATETIME, 101)) and dateadd(day,1,CONVERT(varchar(20), @dtLoginDATETIME, 101)))    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Invalid Login Date for Shift: Login:%s,SSID:%s', 16, 1, @LoginDATETIME, @P_ssid)    
   RETURN    
  END    
 END    
     
 --Data Validation END    
    
 IF @SSID <= 0 --IF THERE IS NO SCHEDULED SHIFT ID PERFORM GET SSID    
 BEGIN    
  IF (@Flags & 16385 <> 0)     
  BEGIN    

   EXEC tmail_ShiftScheduleLookup @OrgDRV, @TRC, @LoginDATETIME, @Flags, @NumberMinutesToCheckPreviousNextDays, @NumberMinutesOfPrevNextDayToCheck,     
           @SSID OUTPUT, @AlreadyLoggedIn OUTPUT, @TractorChange OUTPUT, @DRVOUT  OUTPUT    
  END    
  ELSE    
  BEGIN    
   EXEC GetShiftForDrvAndDate_sp @Drv,@dtLoginDATETIME,@SSID OUTPUT    
  END    
    
 
 END    
 IF ISNULL(@SSID,-1)=-1    
 BEGIN    
  RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  No Shift Schedule Found For Driver: %s.', 16, 1, @Drv)    
  RETURN    
 END    
 ELSE    
 BEGIN    
  IF EXISTS (SELECT NULL FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID AND ss_shiftstatus='OFF')    
  BEGIN    
   IF @Flags & 64 = 0    
   BEGIN    
    RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Login Unsuccessful.  Shift is scheduled as OFF for Driver (%s): %s.', 16, 1, @DRV, @LoginDATETIME)    
    RETURN     
   END    
  END    
    
 IF EXISTS (SELECT NULL FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID AND ISNULL(ss_logindate,'01/01/1950 00:00')<>'01/01/1950 00:00' AND @Flags & 2 <> 0 and @Flags & 256 <> 0  AND @Flags & 128 = 0)    
  SET @Flags = @Flags + 128 -- Set the flag to only update the assets    
    
 IF EXISTS (SELECT NULL FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID AND (ISNULL(ss_logindate,'01/01/1950 00:00')='01/01/1950 00:00' OR @Flags & 128 <> 0  OR @Flags & 512 <> 0 ))    
 BEGIN    
      
  SELECT @ss_Trc = trc_number, @ss_Trl = trl_id, @ss_Trl_id_2= trl_id_2 FROM shiftschedules (NOLOCK) WHERE ss_id  = @SSID    
      
  --If the Trc FROM TotalMail is unknown then SET it to the known trc ON the shift    
  IF ISNULL(@TRC,'UNKNOWN') = 'UNKNOWN'    
   SET @TRC = @ss_Trc    
    
  --If the Trl FROM TotalMail is unknown then SET it to the known trc ON the shift    
  IF ISNULL(@TRL,'UNKNOWN') = 'UNKNOWN'    
   SET @TRL = @ss_Trl    
       
  IF ISNULL(@Trl2,'UNKNOWN')='UNKNOWN'    
   SET @Trl2 = @ss_Trl_id_2    
       
  IF @Flags & 4 = 0 AND ISNULL(@ss_TRC,'UNKNOWN')<>'UNKNOWN' AND ISNULL(@Trc,'UNKNOWN')<>@ss_Trc AND ISNULL(@Trc,'UNKNOWN')<>'UNKNOWN'    
  BEGIN    
   --Error ON Mismatch    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Schedule Tractor Mismatch (Schedule: %s, Login: %s).', 16, 1, @ss_Trc, @Trc)    
   RETURN    
  END    
      
  IF @Flags & 8 = 0 AND ISNULL(@ss_TRL,'UNKNOWN')<>'UNKNOWN' AND ISNULL(@Trl,'UNKNOWN')<>@ss_Trl AND ISNULL(@TRL,'UNKNOWN')<>'UNKNOWN'    
  BEGIN    
   --Error ON Mismatch    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Schedule Trailer Mismatch (Schedule: %s, Login: %s).', 16, 1, @ss_Trl, @Trl)    
   RETURN    
  END    
      
  IF @Flags & 8 = 0 AND ISNULL(@ss_Trl_id_2,'UNKNOWN')<>'UNKNOWN' AND ISNULL(@Trl2,'UNKNOWN')<>@ss_Trl_id_2 AND ISNULL(@Trl2,'UNKNOWN')<>'UNKNOWN'    
  BEGIN    
   --Error ON Mismatch    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Schedule Trailer 2 Mismatch (Schedule: %s, Login: %s).', 16, 1, @ss_Trl_id_2, @Trl2)    
   RETURN    
  END    
    
  IF @Flags & 16 = 0    
  BEGIN    
   --Logout any previously logged in but not logged out shifts    
   UPDATE shiftschedules    
   SET ss_logoutdate = ss_ENDtime    
   WHERE ss_id <> @SSID    
    AND mpp_id = @DRV    
    AND ISNULL(ss_logoutdate, '12/31/2049 00:00') >= '12/31/2049 00:00'    
    AND ISNULL(ss_logindate,'01/01/1950 00:00')<>'01/01/1950 00:00'    
    AND ss_date <= DATEADD(DAY,-1,@dtLoginDATETIME)    
    
  END    
      
  IF @Flags & 32 = 0    
  BEGIN    
   --UPDATE the driver's last mobile comm communicatiON DATETIME with login DATETIME    
   UPDATE manpowerprofile    
   SET mpp_lastmobilecomm = @dtLoginDATETIME    
   WHERE mpp_id = @DRV    
    AND ISNULL(mpp_lastmobilecomm,'01/01/1950 00:00')<@dtLoginDATETIME    
  END    
    
  SET @ShiftLoginLateMinutes = 0    
  IF (@Flags & 128) = 0 AND (@Flags & 8192) <> 0    
    AND (SELECT ISNULL(ss_logindate, CONVERT(datetime, '19500101')) FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID)<=CONVERT(datetime, '19500102')    
    AND (SELECT MIN(lgh_startdate) FROM legheader (NOLOCK) WHERE shift_ss_id = @ssid) = (SELECT ss_starttime FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID)     
    AND NOT EXISTS (SELECT * FROM legheader (NOLOCK) WHERE shift_ss_id = @SSID AND lgh_outstatus IN ('CMP', 'STD'))    
   SELECT @ShiftLoginLateMinutes = DATEDIFF(mi, ss_starttime, @dtLoginDATETIME) FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID    
    
  --UPDATE the Shift Itself    
  IF @Flags & 128 = 0    
    AND (SELECT ISNULL(ss_logindate, CONVERT(datetime, '19500101')) FROM shiftschedules (NOLOCK) WHERE ss_id = @SSID)<=CONVERT(datetime, '19500102')    
   UPDATE shiftschedules    
   SET ss_logindate = @dtLoginDATETIME,    
    trc_number = ISNULL(@TRC,'UNKNOWN'),    
    trl_id = ISNULL(@TRL,'UNKNOWN'),    
    trl_id_2= ISNULL(@Trl2,'UNKNOWN')    
   WHERE ss_id  = @SSID    
  ELSE    
   UPDATE shiftschedules    
   SET trc_number = ISNULL(@TRC,'UNKNOWN'),    
    trl_id = ISNULL(@TRL,'UNKNOWN'),    
    trl_id_2= ISNULL(@Trl2,'UNKNOWN')    
   WHERE ss_id  = @SSID     
  --NEW STUFF    
  IF @Flags & 512 <> 0     
   BEGIN    
    UPDATE Shiftschedules     
    SET ss_logoutdate = NULL    
    WHERE ss_id = @SSID     
    AND ISNULL(ss_logoutdate, '20491231')<'20491231'    
   END    
 
 
 
 
 
 
 ------MTC CHANGES 
 
 DECLARE LGHMOV CURSOR FAST_FORWARD FOR
 select l.lgh_number, l.mov_number--, l.lgh_tractor, l.lgh_startdate, 
 from legheader l inner join stops s on l.lgh_number = s.lgh_number 
 WHERE l.shift_ss_id = @SSID     
    AND l.lgh_driver1 = @Drv    
    AND l.lgh_outstatus IN ('PLN','DSP') 
    AND ((l.lgh_primary_trailer = @ss_trl) OR (l.lgh_primary_pup = @ss_Trl_id_2))  
  order by l.lgh_startdate    
 
 OPEN LGHMOV
 FETCH NEXT FROM LGHMOV INTO @lgh_number, @mov_number 
 WHILE @@FETCH_STATUS = 0
 BEGIN
    UPDATE legheader    
    SET lgh_primary_trailer = @Trl,   
     lgh_primary_pup = @Trl2,    
     lgh_tractor = @Trc    
    WHERE lgh_number = @lgh_number     
    
    DECLARE STPEVENT CURSOR FAST_FORWARD FOR
    select s.stp_number, evt_number from 
    stops s inner join [event] e on s.stp_number = e.stp_number
    where s.lgh_number = @lgh_number
    order by s.stp_number, e.evt_number
    
    OPEN STPEVENT
    FETCH NEXT FROM STPEVENT INTO @stp, @evt
    WHILE @@FETCH_STATUS = 0
    BEGIN
       
	   UPDATE stops    
	   SET trl_id =  @trl,    
	   stp_arrivaldate = DATEADD(mi, @ShiftLoginLateMinutes, stp_arrivaldate),    
	   stp_departuredate = DATEADD(mi, @ShiftLoginLateMinutes, stp_departuredate)    
	   WHERE stp_number = @stp    

	   UPDATE event    
	   SET evt_trailer1 = @ss_Trl,    
	   evt_trailer2 = @Trl2,    
	   evt_tractor = @trc    
	   WHERE evt_number = @evt  
	     
    FETCH NEXT FROM STPEVENT INTO @stp, @evt
    END
    CLOSE STPEVENT
    DEALLOCATE STPEVENT 
 
    EXEC UPDATE_asSETassignment @mov_number    
    EXEC UPDATE_ord @mov_number,'UNK'    
        
FETCH NEXT FROM LGHMOV INTO @lgh_number, @mov_number 
END
CLOSE LGHMOV
DEALLOCATE LGHMOV 
      
  SELECT @SSID as SSID    
 END    
 


 ELSE    
 BEGIN    
  IF @Flags & 2 = 0    
  BEGIN    
   RAISERROR ('(tmail_ShiftScheduleLogin_Enhanced3) Shift login exists for Driver (%s).  Login date/time was not Updated.', 16, 1, @Drv)    
   RETURN    
  END    
  ELSE    
  BEGIN    
   SELECT @SSID as SSID    
  END     
 END    
END    

GO
GRANT EXECUTE ON  [dbo].[tmail_ShiftScheduleLogin_Enhanced3] TO [public]
GO
