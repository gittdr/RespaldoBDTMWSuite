SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* 
-- dpete the stpNumber passed to this proc by ps_w_edi214 is   
--    not the stop number AND not the stp_sequence - it is the stp_mfh_sequence.  
--    Make temp fix until code can be changed.  
-- dpete pts 7654 pass stp_sequence FROM ps_w_edi214 just as the auto  
--     214 stored proc passes the stp_sequence  
-- dpete bring up to level of BN auto 214  
   8848 dpete add docid to keep trans records together  
   
   DPETE pts11689 state field changed to char6 on database, must truncate for flat file  
   DPETE PTS 14433 if general info setting for loca time zone is missint, record does not get produced  
   BLEVON -- PTS 16223 -- allow for 'All' option on 'ref_table' and 'ref_type' on EDI_214_profile table  
   AROSS  PTS 27854 Allow 7 records to be created for the first status sent on each stop.  Previously 7 record was created once on the pickup only.  
   AROSS PTS 27619 Add OS&D record capabilities.  
   AROSS PTS 29607 Utilize the edi code from edi214reason labelfile when creating a manual 214.  
   AROSS PTS 33194 - Use the edicode for the EDI214Status labelfile.  
   AROSS PTS 32450 - Allow user to specify timezone code via general info setting  
   AROSS PTS 40837 - Add Trailer Two ID based on GI Setting.  
   AROSS PTS 41004/40747  - Added logic to use freight and freight reference data from delivery.  
   AROSS PTS 43205 6.11.08 - Increase variable size for weight,qty and volume to prevent truncation.  
   AROSS PTS 43369 6.24.08 - Corrected call to location record followin status detail for company based EDI.  
   AROSS PTS 45230 4.16.09 - Add POD as type 04 misc record output.  
   DWILK PTS 48939 implement old PTS 34923 for CDS in general release  
   AROSS PTS 49660 12.14.09 added support for trading partner reason codes.  
   AROSS PTS 49961 01.28.10 - Add Team/Single Indicator to status record pos. 169; Added Count2 to status record.  
   AROSS PTS 51829 4/5/2010 07:52:02 AM - Update for GPS Location setting to fix performance issues.  
   AROSS PTS 66307 12/18/2012 - Allow for adjustment of time when using CI in Localtimezone setting.  
   AROSS PTS 70732 02/17/14 - updated to prevent sp recompiles.  Added fast forward cursor for freight detail processing
   AROSS PTS 77172 04/21/14 - Added default cmd_code to position 54 of cargo record.
   MZERE PTS 67247 06/11/14 - Add ISNULL to stop "'data_col' column does not allow nulls.  INSERT fails" error.
*/  
CREATE PROCEDURE [dbo].[edi_214_record_id_3_39_sp]   
@StatusCode varchar(2),  
@StatusDateTime datetime,  
@TimeZone varchar(2),  
@StatusCity integer,  
@TractorID varchar(13),  
@MCUnitNumber int,  
@TrailerOwner varchar(4),  
@Trailerid varchar(13),  
@StatusReason varchar(3),  
@StopNumber varchar(3),  
@StopWeight integer,  
@StopQuantity integer,  
@StopReferenceNumber varchar(15),  
@ordhdrnumber integer,  
@stopevent varchar(6),  
@stopreasonlate varchar(6),  
@activity varchar(6),  
@docid varchar(30),  
@relativeMode int = 0,  
@relativeparentstopnumber int = 0,  
@UseGPSLocation char(1) = 'N',  
-- PTS 16223 -- BL   
@Company_id varchar(8)  
 as  
  
 DECLARE @TRPNbr varchar(20), @billtocmpid varchar(8)  
 DECLARE @weight varchar(12), @quantity varchar(12)  
 DECLARE @stopcmpid varchar(8), @n101code varchar(3), @stp_number int, @relativeAltStopNum int, @relativeStopType char(3)  
 DECLARE @nextfgtnumber int, @altstopnbr varchar(6), @stp_type varchar(6)  
 DECLARE @stpsequence int,@localzonenbr int, @trpzonenbr int, @diff int  
 DECLARE @localtimezone char(2), @trp_timezone char(2),@cty_lat numeric(13,5),@cty_long numeric(13,5)  
 DECLARE @countA int, @countB int, @last3record int  
 DECLARE @GPSCity int, @GPSCityName varchar(18), @GPSState varchar(2), @GPSZip varchar(9), @citylatlongunits char(1),  
  @weightunit varchar(6), @edicmdcode varchar(30), @cmdname varchar(50), @volume varchar(12),  
  @cmdcode varchar(8), @volumeunit varchar(6), @count varchar(12), @countunit varchar(6)  
 DECLARE @ExportSTCC varchar(1), @stcccode varchar(8)  
 --DPH PTS 24878  
 DECLARE @timezonecode int  
 --DPH PTS 24878  
 --DPH PTS 25067  
 DECLARE @gps_city_3record varchar(18),   
  @gps_state_3record varchar(2),  
  @start_location integer,   
  @end_location integer,   
  @driver_id varchar(8)  
 DECLARE @OSDRec char(1)  
 DECLARE @v_ShowSchedDates char(1)  
 DECLARE @v_SchedEarliest datetime, @v_SchedLatest datetime    
 declare @appname nvarchar(128)  
 DECLARE @TrlTwoFlag char(1),@TrailerTwo varchar(13) --PTS40837  
 DECLARE @v_usedrprefs char(1),@v_drpstopno int  --PTS 40747  
 DECLARE @v_addpod char(1),@v_podname varchar(20)  
 --FMM PTS 34923  
 declare @Process856 varchar(1), @Found856 int  
 --AR 47645  
 DECLARE @ssl_text1 varchar(50),@ssl_text2 varchar(50)  
 DECLARE @v_rsnlate varchar(6)--49660  
 DECLARE @v_teamSingle CHAR(1),@lgh_number int, @driver1 varchar(8),@driver2 varchar(8) ,@v_StopCount2 int,@v_Count2 varchar(12),@v_count2unit varchar(6) --49961  
DECLARE @v_RestrictByTerms CHAR(1),@ord_terms VARCHAR(6),@v_restrictTermsLevel CHAR(1) --50029  
 DECLARE @offset_local INT, @offset_city INT, @allowTimeAdj VARCHAR(10) --66307  
  
 --MTC20131010 begin
 DECLARE @stp_sequence int
 SELECT @stp_sequence = convert(int,@stopnumber)
 --MTC20131010 end
 
 SET @v_usedrprefs = 'N'  
/*****Get GI Settings***/   
 --50029  
Select @v_RestrictByTerms =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI_RestrictByTerms'  
  
select @ExportSTCC = left(upper(isnull(gi_string1,'N')),1) from generalinfo where gi_name = 'EDI214ExportSTCC'  
  
select @OSDRec = LEFT(UPPER(ISNULL(gi_string1,'N')),1)FROM generalinfo WHERE gi_name = 'EDI214_OSD' --PTS29341  
   
--PTS 29961  
Select @v_ShowSchedDates =  IsNull(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI214_EarliestLatest'  
  
--PTS 40837  
SELECT @TrlTwoFlag = ISNULL(UPPER(LEFT(gi_string1,1)),'N') FROM generalinfo WHERE gi_name = 'EDI214_AddTrlTwo'  
  
  
  
IF @v_RestrictByTerms = 'Y'   
BEGIN  --50029  Check Terms  
  select @ord_terms  = isnull(ord_terms,'UNK') from orderheader where ord_hdrnumber = @ordhdrnumber  
    
  --get terms restriction  
  select @v_restrictTermsLevel = isnull(trp_214_restrictTerms,'B')   
  from edi_trading_partner  
  where cmp_id = @company_id  
  
 --allow PPD only   
 if (@v_restrictTermsLevel = 'P' and @ord_terms <> 'PPD')  
  RETURN  
 --allow COL only  
 if (@v_restrictTermsLevel = 'C' and @ord_terms <> 'COL')  
  RETURN   
END --50029   
   
-- This should be passed, but had to be determined here, because  
-- v2000 cutoff makes software changes impossible. Code to call this  
--is in ps_w_edi214 in VisDisp pfc_save code  
 SELECT  @stp_number = stp_number,  
  @stopcmpid = cmp_id,  
 @n101code =   
    CASE stp_type  
         WHEN 'PUP' THEN 'PU'  
  --WHEN 'XDL' THEN 'PU'  
                WHEN 'DRP' THEN 'DR'  
                --WHEN 'XDU' THEN 'DR'  
                ELSE 'XX'  
           END,  
 @stp_type = stp_type,  
 @v_SchedEarliest =  stp_schdtearliest,@v_SchedLatest = stp_schdtlatest,  
 @v_StopCount2 = isnull(stp_count2,0)  
 FROM stops  
 WHERE ord_hdrnumber = @ordhdrnumber  
 AND  stp_sequence = @stp_sequence --CONVERT(int,@StopNumber) MTC20131010
   
 --45230 Get POD from stops  
 SELECT @v_podname = ISNULL(stp_podname,'')  
 FROM stops   
 WHERE stp_number = @stp_number  
 --END 45230  
   
 --49660 get raw stop reason code  
 select @v_rsnlate = case @activity  
    when 'ARV' then stp_reasonlate  
    when 'DEP' then stp_reasonlate_depart  
    else stp_reasonlate  
        end  
from  stops  
where stp_number = @stp_number  
--end 49660  
  
--49961 Determine Team/Single  
SELECT @lgh_number = lgh_number FROM stops WHERE stp_number = @stp_number  
SELECT @driver1 = ISNULL(lgh_driver1,'UNKNOWN'),@driver2 = ISNULL(lgh_driver2,'UNKNOWN') FROM legheader WHERE lgh_number = @lgh_number  
  
 IF (@driver1 = 'UNKNOWN' and @driver2 = 'UNKNOWN')  
  SET @v_teamSingle = 'X'  
 IF (@driver1 <> 'UNKNOWN' and @driver2 = 'UNKNOWN')  
  SET @v_teamSingle = 'S'  
 IF (@driver1 <> 'UNKNOWN' and @driver2 <> 'UNKNOWN')  
  SET @v_teamSingle = 'T'  
  
--END 49961     
--PTS 40747  Add logic for using drop references for pickup stops  
 IF @stp_type = 'PUP'  
  BEGIN  
   SELECT @v_usedrprefs = ISNULL(e214_ref_from_drp,'N')  
   FROM  edi_214_profile  
   WHERE e214_cmp_id =  @company_id  
     AND  e214_level = 'SH'  --always for pickup stops  
     AND  e214_triggering_activity = @activity  
     AND  e214_edi_status = @statuscode   --requires a 1:1 match on status code  
     
   IF @v_usedrprefs = 'Y'  
    --get the drop stop number  
    SELECT @v_drpstopno = stp_number  
    FROM  stops  
    WHERE ord_hdrnumber =  @ordhdrnumber  
      AND stp_type = 'DRP'  
      AND  stp_sequence = (SELECT MAX(stp_sequence) FROM stops WHERE ord_hdrnumber = @ordhdrnumber and stp_type = 'DRP'   
             and stp_sequence >  @stp_sequence) --CONVERT(int,@StopNumber))  MTC20131010
 END    
    
 IF @stp_type = 'PUP' or @stp_type = 'DRP'   
 BEGIN  
   SELECT @altstopnbr = convert(varchar(6),COUNT(*))  
   FROM stops   
   WHERE ord_hdrnumber = @ordhdrnumber  
   AND   stp_type = @stp_type  
   AND   stp_sequence <= @stp_sequence --CONVERT(int,@StopNumber)  MTC20131010
  END   
  
  
SELECT @localtimezone = left(ltrim(rtrim(isnull(gi_string1,'LT'))),2),  
  @allowTimeAdj = ISNULL(UPPER(LEFT(gi_string2,1)),'N')  
FROM generalinfo   
WHERE gi_name = 'Localtimezone'  
  
Select @localtimezone = Isnull(@localtimezone,'LT')  
If @localtimezone = '' Select @localtimezone = 'LT'  
  
--PTS 40837 Get the trailer 2 ID if necessary  
IF @TrlTwoFlag = 'Y'  
 SELECT @TrailerTwo = ISNULL(evt_trailer2,' ')  
 FROM   event  
 WHERE stp_number = @stp_number  
          AND  evt_sequence = 1  
ELSE  
 SET @TrailerTwo = ' '  
            
  
  
-- Condition parameters  
SELECT @StatusCode=isnull( @StatusCode ,' ')  
SELECT @TimeZone=isnull( @localtimezone ,'LT') --PTS 32450 AROSS  
SELECT @TractorID=isnull( @TractorID ,' ')  
SELECT @MCUnitnUMBER=ISNULL( @MCUnitNumber ,0)  
SELECT @TrailerOwner=isnull( @TrailerOwner ,' ')  
SELECT @Trailerid=isnull( @Trailerid ,' ')  
SELECT @StatusReason = ISNULL(@StatusReason,'')  
SELECT @StopNumber=isnull( @StopNumber ,' ')  
SELECT @Weight=CONVERT(varchar(6),isnull( @StopWeight ,0))  
SELECT @Quantity=CONVERT(varchar(6),isnull( @StopQuantity ,0))  
SELECT @StopReferenceNumber=isnull( @StopReferenceNumber ,' ')  
SELECT @stopreasonlate = ISNULL(@stopreasonlate,' ')  
SELECT @stopevent = ISNULL(@stopevent,' ')  
SELECT @altstopnbr = ISNULL(@altstopnbr,0)  
SELECT @TrailerTwo = ISNULL(@TrailerTwo,' ')  --PTS 40837  
SELECT @v_teamSingle = ISNULL(@v_teamSingle,'X')  
SELECT @v_Count2 = CONVERT(varchar(6),isnull(@v_StopCount2,0))  
-- Find bill to company  
SELECT @billtocmpid = ord_billto  
FROM  orderheader  
WHERE ord_hdrnumber = @ordhdrnumber  
  
-- Find trading partner ID  
SELECT @TRPNbr = trp_id,  
 @v_addpod = UPPER(ISNULL(trp_214_pod,'N')) --45230  
FROM edi_trading_partner  
-- PTS 24107 -- BL (start)  
--WHERE  cmp_id = @billtocmpid  
WHERE  cmp_id = @Company_id  
-- PTS 24107 -- BL (end)  
  
  
-- If none found default to bill to cmp id  
SELECT @TRPNbr = ISNULL(@TRPNbr,@billtocmpid)  
  
--AROSS PTS 33194 Use EDI code for EDI 214 Status on Manual 214's  only  
select @appname = APP_NAME()  
If @appname <> 'PSA'  
Begin  
 SELECT @statuscode = ISNULL(LEFT(edicode,2),@statuscode)  
 FROM labelfile  
 WHERE labeldefinition = 'EDI214Status'  
  AND   RTRIM(Left(abbr,3)) = @StatusCode  
  AND  edicode <> ''  
End --33194  
  
--AROSS PTS 29607  Use EDI Code from labelfile for Manual 214's  
If @StatusReason <> ''  
 SELECT @StatusReason = ISNULL(edicode,@statusreason)  
 FROM labelfile   
 WHERE labeldefinition = 'EDI214Reason'  
  AND RTRIM(Left(abbr,3)) = @StatusReason  
  AND edicode <> ''  
--End PTS 29607    
  
--pts49660 tp reason codes  
  if exists(select 1 from edireasonlatecode where cmp_id = @Company_id and rsn_code = @v_rsnlate)  
 begin  
  --stop reasonlate  
  select @stopreasonlate = isnull(edi_rsn_code,'NS')  
  from edireasonlatecode  
  where cmp_id = @Company_id  
        and rsn_code = @v_rsnlate  
  if @appname  = 'PSA'  
  --status reasoncode(auto-214) only  
  select @statusreason = @stopreasonlate  
 end  
else --use the edicode as a global default if there is not a trading partner value setup  
 select @stopreasonlate = isnull(edicode,@stopreasonlate)  
 from labelfile  
 where labeldefinition = 'ReasonLate'  
  and abbr = @v_rsnlate  
  and edicode <> ''  
--end 49660     
--set timezone base on the  customers timezone value  
if @timezone = 'LT' begin  
    select @timezone = @localtimezone  
end  
--DPH PTS 24878  
IF @localtimezone = 'CI'  
BEGIN  
 select @timezonecode = cty_GMTDelta   
 from city  
 where cty_code = @statuscity  
   
 select @offset_local = ABS(DATEDIFF(HH,getutcdate(),getdate()))  
   
 SELECT @offset_city =  ISNULL(cty_GMTDelta,0)   
 FROM city   
 WHERE cty_code = @StatusCity  
  
--66307  adjust time to status city timezone if GI setting allows it  
 IF @allowTimeAdj = 'Y' AND @offset_city > 0  
  SELECT @StatusDateTime = DATEADD(HH,(@offset_local - @offset_city),@StatusDateTime)  
   
  
 SELECT @timezone =   
       CASE @timezonecode  
         WHEN 4 THEN 'AT'  
          WHEN 5 THEN 'ET'  
          WHEN 6 THEN 'CT'  
          WHEN 7 THEN 'MT'  
          WHEN 8 THEN 'PT'  
          ELSE 'LT'  
        END  
END  
--DPH PTS 24878  
  
select @cty_lat = isnull(cty_latitude,0),@cty_long = isnull(cty_longitude,0)  
 from city  
 WHERE cty_code=@statuscity   
--PTS 18306, if units are 's'econds divide by 3600 to convert to degrees.  
if @citylatlongunits = 'S'  
 select @cty_lat = @cty_lat/3600, @cty_long = @cty_long/3600  
  
--If units are null, determine if abs lat or long is greater than 360, the theoretical maximum degree value.  
--If one of the latitude and longitude is greater than 360, then convert them both from seconds to degrees.  
else if @citylatlongunits is null  
begin   
 if abs(@cty_lat) > 360 or abs(@cty_long) > 360  
  select @cty_lat = @cty_lat/3600, @cty_long = @cty_long/3600  
end  
  
-- PTS 23854 -- DPH (start)  
IF (select gi_string1 from generalinfo where gi_name = 'AddGeoLocationToEDI214') = 'Y' and (@statuscode = 'AG')  
 BEGIN /*geoloc*/  
 SELECT  @driver_id = ord_driver1  
 FROM orderheader  
 WHERE  ord_hdrnumber = @ordhdrnumber  
  
 SELECT  @gps_city_3record = ''  
 SELECT  @gps_state_3record = ''  
   
 SELECT  @start_location = charindex('of', mpp_gps_desc) + 3  
 FROM  manpowerprofile  
 WHERE mpp_id = @driver_id  
  
 SELECT @end_location = charindex(', ', mpp_gps_desc) -- + 4  
 FROM manpowerprofile  
 WHERE  mpp_id = @driver_id  
  
 SELECT  @gps_city_3record = IsNull(substring(mpp_gps_desc, (@start_location), (@end_location - @start_location)),'')  
    FROM manpowerprofile  
    WHERE mpp_id = @driver_id  
  
 SELECT  @gps_state_3record = IsNull(substring(mpp_gps_desc, (@end_location + 2), 2), '')  
    FROM manpowerprofile  
    WHERE mpp_id = @driver_id   
  
 IF (@gps_city_3record = '') or (@gps_state_3record = '')  
  BEGIN /*339a*/  
  -- then insert results into edi_214  
  INSERT edi_214 (data_col,trp_id,doc_id)  
  SELECT   
  data_col = '3' +    -- Record ID  
  '39' +      -- Record Version  
  ISNULL(@StatusCode,'') +     -- StatusCode  
   REPLICATE(' ',2-datalength(ISNULL(@StatusCode,''))) +  
  CONVERT(varchar(8),ISNULL(@StatusDateTime,''),112)+   
  SUBSTRING(CONVERT(varchar(8),ISNULL(@StatusDateTime,''),8),1,2) +  
  SUBSTRING(CONVERT(varchar(8),ISNULL(@StatusDateTime,''),8),4,2) +   -- status date AND time  
  ISNULL(@timezone,'') +     -- timezone  
   REPLICATE(' ',2-datalength(ISNULL(@timezone,''))) +  
  SUBSTRING(ISNULL(cty_name,''),1,18) +     -- city  
   REPLICATE(' ',18-datalength(SUBSTRING(ISNULL(cty_name,''),1,18))) +  
  SUBSTRING(ISNULL(cty_state,''),1,2) +     -- state  
   REPLICATE(' ',2-datalength(SUBSTRING(ISNULL(cty_state,''),1,2))) +  
  ISNULL(@tractorid,'') +     -- Tractor  
   REPLICATE(' ',13-datalength(ISNULL(@tractorid,''))) +  
  CONVERT(varchar(12),ISNULL(@MCUnitNumber,'')) +     -- MCUnitNumber  
   REPLICATE(' ',12-datalength(CONVERT(varchar(12),ISNULL(@MCUnitNumber,'')))) +  
  ISNULL(@TrailerOwner,'') +     -- TrailerOwner  
   REPLICATE(' ',4-datalength(ISNULL(@TrailerOwner,''))) +  
  ISNULL(@Trailerid,'') +     -- Trailer Number  
   REPLICATE(' ',13-datalength(ISNULL(@Trailerid,''))) +  
  ISNULL(@StatusReason,'') +     -- StatusReason  
    REPLICATE(' ',3-datalength(ISNULL(@StatusReason,''))) +  
    REPLICATE('0',3-datalength(ISNULL(@StopNumber,''))) +  
  ISNULL(@StopNumber,'') +     -- StopNumber  
   REPLICATE('0',6-datalength(ISNULL(@Weight,''))) +  
  ISNULL(@Weight,'') +     -- StopWeight  
   REPLICATE('0',6-datalength(ISNULL(@Quantity,''))) +  
  ISNULL(@Quantity,'') +     -- StopQuantity  
  ISNULL(@StopReferenceNumber,'') +    -- StopReferenceNumber  
   REPLICATE(' ',15-datalength(ISNULL(@StopReferenceNumber,''))) +  
  REPLICATE('0',3-datalength(ISNULL(@altstopnbr,''))) + @altstopnbr +   
  --Take the right 9 of the lat and long just in case it'll still overflow the varchar  
  replicate('0',9-datalength(convert(varchar(9),right(ISNULL(@cty_lat,''),9))))+ right(ISNULL(@cty_lat,''),9)+'N'+  
  replicate('0',9-datalength(convert(varchar(9),right(ISNULL(@cty_long,''),9))))+right(ISNULL(@cty_long,''),9)+'W'+  
  ISNULL(@stopevent,'') + REPLICATE(' ',6-datalength(ISNULL(@stopevent,''))) +  
  ISNULL(@stopreasonlate,'') + REPLICATE(' ',6-datalength(ISNULL(@stopreasonlate,''))) +  
  ISNULL(@activity,'') + REPLICATE(' ',6-datalength(ISNULL(@activity,''))) +  
  ISNULL(@TrailerTwo,'') + REPLICATE(' ',13-datalength(ISNULL(@TrailerTwo,''))) +  --PTS 40837    
  isnull(@v_teamSingle,'X') +         --PTS 49961 Team Single  
   REPLICATE('0',6-datalength(ISNULL(@v_count2,''))) + ISNULL(@v_count2,'') ,   --PTS 49961 count2  
  trp_id = ISNULL(@TRPNbr,''), doc_id = ISNULL(@docid,'')
  
  FROM city WHERE cty_code=@statuscity  
  END/*339a*/  
  
 ELSE  
  BEGIN /*339b*/  
  -- then insert results into edi_214  
  INSERT edi_214 (data_col,trp_id,doc_id)  
  SELECT   
  data_col = '3' +    -- Record ID  
  '39' +      -- Record Version  
  ISNULL(@StatusCode,'') +     -- StatusCode  
   REPLICATE(' ',2-datalength(ISNULL(@StatusCode,''))) +  
  CONVERT(varchar(8),ISNULL(@StatusDateTime,''),112)+   
  SUBSTRING(CONVERT(varchar(8),ISNULL(@StatusDateTime,''),8),1,2) +  
  SUBSTRING(CONVERT(varchar(8),ISNULL(@StatusDateTime,''),8),4,2) +   -- status date AND time  
  ISNULL(@timezone,'') +     -- timezone  
   REPLICATE(' ',2-datalength(ISNULL(@timezone,''))) +  
  SUBSTRING(ISNULL(@gps_city_3record,''),1,18) +     -- city  
   REPLICATE(' ',18-datalength(SUBSTRING(ISNULL(cty_name,''),1,18))) +  
  SUBSTRING(ISNULL(@gps_state_3record,''),1,2) +     -- state  
   REPLICATE(' ',2-datalength(SUBSTRING(ISNULL(cty_state,''),1,2))) +  
  ISNULL(@tractorid,'') +     -- Tractor  
   REPLICATE(' ',13-datalength(ISNULL(@tractorid,''))) +  
  CONVERT(varchar(12),ISNULL(@MCUnitNumber,'')) +     -- MCUnitNumber  
   REPLICATE(' ',12-datalength(CONVERT(varchar(12),ISNULL(@MCUnitNumber,'')))) +  
  ISNULL(@TrailerOwner,'') +     -- TrailerOwner  
   REPLICATE(' ',4-datalength(ISNULL(@TrailerOwner,''))) +  
  ISNULL(@Trailerid,'') +     -- Trailer Number  
   REPLICATE(' ',13-datalength(ISNULL(@Trailerid,''))) +  
  ISNULL(@StatusReason,'') +     -- StatusReason  
    REPLICATE(' ',3-datalength(ISNULL(@StatusReason,''))) +  
    REPLICATE('0',3-datalength(ISNULL(@StopNumber,''))) +  
  ISNULL(@StopNumber,'') +     -- StopNumber  
   REPLICATE('0',6-datalength(ISNULL(@Weight,''))) +  
  ISNULL(@Weight,'') +     -- StopWeight  
   REPLICATE('0',6-datalength(ISNULL(@Quantity,''))) +  
  ISNULL(@Quantity,'') +     -- StopQuantity  
  ISNULL(@StopReferenceNumber,'') +    -- StopReferenceNumber  
   REPLICATE(' ',15-datalength(ISNULL(@StopReferenceNumber,''))) +  
  REPLICATE('0',3-datalength(ISNULL(@altstopnbr,''))) + ISNULL(@altstopnbr,'') +   
  --Take the right 9 of the lat and long just in case it'll still overflow the varchar  
  replicate('0',9-datalength(convert(varchar(9),right(ISNULL(@cty_lat,''),9))))+ right(ISNULL(@cty_lat,''),9)+'N'+  
  replicate('0',9-datalength(convert(varchar(9),right(ISNULL(@cty_long,''),9))))+right(ISNULL(@cty_long,''),9)+'W'+  
  ISNULL(@stopevent,'') + REPLICATE(' ',6-datalength(ISNULL(@stopevent,''))) +  
  ISNULL(@stopreasonlate,'') + REPLICATE(' ',6-datalength(ISNULL(@stopreasonlate,''))) +  
  ISNULL(@activity,'') + REPLICATE(' ',6-datalength(ISNULL(@activity,''))) +   
  ISNULL(@TrailerTwo,'') + REPLICATE(' ',13-datalength(ISNULL(@TrailerTwo,'')))+  --PTS 40837    
  isnull(@v_teamSingle,'X') +    --PTS 49961  
  REPLICATE('0',6-datalength(ISNULL(@v_count2,''))) + ISNULL(@v_count2,''),  
  trp_id = ISNULL(@TRPNbr,''), doc_id = ISNULL(@docid,'')
  FROM city WHERE cty_code=@statuscity  
  END /*339b*/  
 END/*geoloc*/  
 -- PTS 23854 -- DPH (end)  
ELSE  
 BEGIN  /*no geoloc*/  
 -- then insert results into edi_214  
 INSERT edi_214 (data_col,trp_id,doc_id)  
 SELECT   
 data_col = '3' +    -- Record ID  
 '39' +      -- Record Version  
 ISNULL(@StatusCode,'') +     -- StatusCode  
  REPLICATE(' ',2-datalength(ISNULL(@StatusCode,''))) +  
 CONVERT(varchar(8),ISNULL(@StatusDateTime,''),112)+   
 SUBSTRING(CONVERT(varchar(8),ISNULL(@StatusDateTime,''),8),1,2) +  
 SUBSTRING(CONVERT(varchar(8),ISNULL(@StatusDateTime,''),8),4,2) +   -- status date AND time  
 ISNULL(@timezone,'') +     -- timezone  
  REPLICATE(' ',2-datalength(ISNULL(@timezone,''))) +  
 SUBSTRING(ISNULL(cty_name,''),1,18) +     -- city  
  REPLICATE(' ',18-datalength(SUBSTRING(ISNULL(cty_name,''),1,18))) +  
 SUBSTRING(ISNULL(cty_state,''),1,2) +     -- state  
  REPLICATE(' ',2-datalength(SUBSTRING(ISNULL(cty_state,''),1,2))) +  
 ISNULL(@tractorid,'') +     -- Tractor  
  REPLICATE(' ',13-datalength(ISNULL(@tractorid,''))) +  
 CONVERT(varchar(12),ISNULL(@MCUnitNumber,'')) +     -- MCUnitNumber  
  REPLICATE(' ',12-datalength(CONVERT(varchar(12),ISNULL(@MCUnitNumber,'')))) +  
 ISNULL(@TrailerOwner,'') +     -- TrailerOwner  
  REPLICATE(' ',4-datalength(ISNULL(@TrailerOwner,''))) +  
 ISNULL(@Trailerid,'') +     -- Trailer Number  
  REPLICATE(' ',13-datalength(ISNULL(@Trailerid,''))) +  
 ISNULL(@StatusReason,'') +     -- StatusReason  
   REPLICATE(' ',3-datalength(ISNULL(@StatusReason,''))) +  
   REPLICATE('0',3-datalength(ISNULL(@StopNumber,''))) +  
 ISNULL(@StopNumber,'') +     -- StopNumber  
  REPLICATE('0',6-datalength(ISNULL(@Weight,''))) +  
 ISNULL(@Weight,'') +     -- StopWeight  
  REPLICATE('0',6-datalength(ISNULL(@Quantity,''))) +  
 ISNULL(@Quantity,'') +     -- StopQuantity  
 ISNULL(@StopReferenceNumber,'') +    -- StopReferenceNumber  
  REPLICATE(' ',15-datalength(ISNULL(@StopReferenceNumber,''))) +  
 REPLICATE('0',3-datalength(ISNULL(@altstopnbr,''))) + ISNULL(@altstopnbr,'') +   
 --Take the right 9 of the lat and long just in case it'll still overflow the varchar  
 replicate('0',9-datalength(convert(varchar(9),right(ISNULL(@cty_lat,''),9))))+ right(ISNULL(@cty_lat,''),9)+'N'+  
 replicate('0',9-datalength(convert(varchar(9),right(ISNULL(@cty_long,''),9))))+right(ISNULL(@cty_long,''),9)+'W'+  
 ISNULL(@stopevent,'') + REPLICATE(' ',6-datalength(ISNULL(@stopevent,''))) +  
 ISNULL(@stopreasonlate,'') + REPLICATE(' ',6-datalength(ISNULL(@stopreasonlate,''))) +  
 ISNULL(@activity,'') + REPLICATE(' ',6-datalength(ISNULL(@activity,''))) +  
 ISNULL(@TrailerTwo,'') + REPLICATE(' ',13-datalength(ISNULL(@TrailerTwo,'')))+  --PTS 40837    
 isnull(@v_teamSingle,'X') +          --PTS 49961  
 REPLICATE('0',6-datalength(ISNULL(@v_count2,''))) + ISNULL(@v_count2,''),    --PTS 49961  
 trp_id = ISNULL(@TRPNbr,''), doc_id = ISNULL(@docid,'')
 FROM city WHERE cty_code=@statuscity  
 END /*no geoloc*/  
  
-- create #2 record for this stop  
-- If relativedrop or pickups are used, the n101code is going to be backwards  
  
If @relativeMode > 0   
begin  
 select @relativestoptype = stp_type from stops where stp_number = @relativeparentstopnumber   
 select @n101code =   
    CASE @relativestoptype  
         WHEN 'PUP' THEN 'PU'  
  WHEN 'DRP' THEN 'DR'  
                  
                ELSE 'XX'  
           END  
End   
  
if @UseGPSLocation <>'Y'  
 exec edi_214_record_id_2_39_sp @stopcmpid,@n101code,@TRPNbr,@Company_Id,@docid  --PTS43369  
 --exec edi_214_record_id_2_39_sp @stopcmpid,@n101code,@TRPNbr,@billtocmpid,@docid  
Else --17519 get GPS details for ESTA UseGPSLocation 214s  
Begin /*gps data*/  
-- SELECT  @GPSCity = isnull(ckc_city,0),  
--  @GPSCityName = left(isnull(ckc_cityname,' '),18),  
--  @GPSState = left(isnull(ckc_state,' '),2),   
--  @GPSZip = left(isnull(ckc_zip,' '),9)  
-- FROM checkcall a  
-- INNER JOIN (select max(ckc_date) as maxdate, ckc_number from checkcall where ckc_tractor = @tractorID group by ckc_number) b  
-- ON a.ckc_number = b.ckc_number and a.ckc_date = b.maxdate  
   
 /* PTS 51829 REPLACE ABOVE */  
 SELECT  top 1 @GPSCity = isnull(ckc_city,0),    
               @GPSCityName = left(isnull(ckc_cityname,' '),18),    
               @GPSState = left(isnull(ckc_state,' '),2),     
               @GPSZip = left(isnull(ckc_zip,' '),9)    
 FROM checkcall a where ckc_tractor = @tractorID order by ckc_date desc     
/* END PTS 51829  REPLACE */  
  
 --Use the city table to find the city name, state and zip if city name is not valued  
 if @GPSCity <> 0 and @GPSCityName = ' '  
  select @GPSCityName = isnull(cty_name,@GPSCityname),  
   @GPSState = isnull(cty_state,@GPSState),  
   @GPSZip = isnull(cty_zip,@GPSZip)  
  from city where cty_code = @GPSCity  
  
  
 INSERT edi_214 (data_col, trp_id, doc_id)  
 SELECT data_col = '239' +  
 ISNULL(@n101code,'') + replicate(' ',2-datalength(ISNULL(@n101code,''))) +  
 replicate(' ',60) +  
 ISNULL(@GPSCityName,'') + replicate(' ',18-datalength(ISNULL(@GPSCityName,''))) +  
 ISNULL(@GPSState,'') + replicate(' ',2-datalength(ISNULL(@GPSState,''))) +  
 ISNULL(@GPSZip,'') + replicate(' ',9-datalength(ISNULL(@GPSZip,''))) +  
 replicate(' ',20) +  
 'XX',   
 trp_id = ISNULL(@TRPNbr,''),  
 doc_id = ISNULL(@docid,'')  
End /*gps data */  
  
--PTS 45230 AR. Add stop pod name field to output as MISC record for delivery stops.  
IF ( ISNULL(@v_addpod,'N') = 'Y' AND LEN(@v_podname) >0)  
 INSERT INTO edi_214  (data_col, trp_id, doc_id)  
 SELECT data_col = '439POD   ' +  
   UPPER(ISNULL(@v_podname,'')) + REPLICATE(CHAR(32), 20 - DATALENGTH(ISNULL(@v_podname,''))),  
   trp_id = ISNULL(@TRPnbr,''),  
   doc_id = ISNULL(@docid,'')  
--END 45230  

--PTS 29961 Start.  Add earliest and latest dates when GI setting requires it.  
IF @v_ShowSchedDates = 'Y'  
  INSERT INTO edi_214  (data_col, trp_id, doc_id)  
  SELECT data_col = '439_DTEL ' +  
    CONVERT(varchar(8),ISNULL(ISNULL(@v_SchedEarliest,''),''),112)  +  
    SUBSTRING(CONVERT(varchar(8),ISNULL(ISNULL(@v_SchedEarliest,''),''),8),1,2)  +  
    SUBSTRING(CONVERT(varchar(8),ISNULL(ISNULL(@v_SchedEarliest,''),''),8),4,2)  +  
    CONVERT(varchar(8),ISNULL(ISNULL(@v_SchedLatest,''),''),112)  +  
    SUBSTRING(CONVERT(varchar(8),ISNULL(ISNULL(@v_SchedLatest,''),''),8),1,2)  +  
    SUBSTRING(CONVERT(varchar(8),ISNULL(ISNULL(@v_SchedLatest,''),''),8),4,2),  
    trp_id = ISNULL(@TRPnbr,''), doc_id = ISNULL(@docid,'')
  
--PTS47645 AR - Add appointment text from scheduled change log  
IF EXISTS(SELECT 1 FROM stop_schchange_log WHERE stp_number = @stp_number)  
BEGIN  
   SELECT @ssl_text1 = ISNULL(RTRIM(ssl_text1),''),@ssl_text2 = ISNULL(RTRIM(ssl_text2),'')  
   FROM   stop_schchange_log WHERE stp_number = @stp_number  AND  
     ssl_id = (SELECT MAX(ssl_id) FROM stop_schchange_log WHERE stp_number = @stp_number)  

   --output records  
   IF LEN(@ssl_text1) > 1  
    INSERT INTO edi_214  (data_col, trp_id, doc_id)  
    SELECT data_col = '439APTXT1' + ISNULL(@ssl_text1,''),  
     trp_id = ISNULL(@TRPnbr,''),  
     doc_id = ISNULL(@docid,'')  

      --output records  
   IF LEN(@ssl_text2) > 1  
    INSERT INTO edi_214  (data_col, trp_id, doc_id)  
    SELECT data_col = '439APTXT2' + ISNULL(@ssl_text2,''),  
     trp_id = ISNULL(@TRPnbr,''),  
     doc_id = ISNULL(@docid,'')           
END  
  
--END 47645  
  
-- PTS 34923 -- FM (start)  
SELECT @Process856 = LEFT(UPPER(ISNULL(gi_string1,'N')),1) FROM generalinfo WHERE gi_name = 'EDI856_Processing'  
-- PTS 34923 -- FM (end)  
  
--pts18466 Use a shortcut here to clear previous 7 "freight" records for this doc_id,  
-- otherwise maintaining the correct looping depth would require many more changes.  
--delete edi_214 where doc_id = @docid and data_col like '739%'  
  
-- create any needed ref numbers  
-- in relativemode, substitute target references when necessary  
-- use the pickup references for mode 1, and the drop refernces for mode 2  
-- need to use actual stop for m1 pups and relative stop for m1 drops  
-- need to use relative stop for m2 pups and actual stop for m2 drops  
  
If @relativemode > 0  
begin /*relative mode */  
  
 if @relativemode = 1  
  select @relativeAltStopNum = case @stp_type when 'PUP' then @stp_number  
        when 'DRP' then @relativeparentstopnumber  
        end  
 else if @relativemode = 2  
  select @relativeAltStopNum = case @stp_type when 'DRP' then @stp_number  
        when 'PUP' then @relativeparentstopnumber  
        end  
          
-- PTS 16223 -- BL (start)  
-- exec edi_214_record_id_4_39_sp @ordhdrnumber,'stops',@relativeAltStopNum,@TRPNbr,@docid   
 exec edi_214_record_id_4_39_sp @ordhdrnumber,'stops',@relativeAltStopNum,@TRPNbr,@docid,@Company_id  
-- PTS 16223 -- BL (end)  
  
-- PTS 34923 -- FM (start)  
        IF @Process856 = 'Y'  
  exec @Found856 = edi_214_record_id_6_39_from856_sp @TRPNbr, @docid, @ordhdrnumber, @statuscode  
 else  
  select @Found856 = 0  
-- PTS 34923 -- FM (end)  
  
 --SELECT @nextfgtnumber = MIN(fgt_number), @freightcount = count(fgt_number)  
 -- FROM freightdetail WHERE freightdetail.stp_number = @relativeAltStopNum 
 
  SELECT @last3record = min(identity_col) from edi_214 where @docid = doc_id   
     and @trpnbr = trp_id   
     and data_col like '339%'  
     and CAST(SUBSTRING(data_col,85,3)as int) = @stp_sequence --@stopnumber  --AROSS PTS 27854 MTC20131010 
 
 --MTC20131010  
 DECLARE FREIGHTNUMBER_CURSOR cursor fast_forward for
 select fgt_number from freightdetail f 
 where f.stp_number = @relativeAltStopNum
 order by fgt_number
 
 OPEN FREIGHTNUMBER_CURSOR

 FETCH NEXT FROM FREIGHTNUMBER_CURSOR 
 INTO @nextfgtnumber

 WHILE @@FETCH_STATUS = 0
 BEGIN /*fgt A  */
   
	IF (SELECT COUNT(*) FROM generalinfo WHERE gi_name = 'EDI214_OSD' AND LEFT(UPPER(ISNULL(gi_string1,'N')),1) = 'Y') > 0  
		--PTS27619  OSD  
		exec edi_214_record_id_6_39_sp @TRPNbr,@docid,@nextfgtnumber    
	If (Select count(*) From generalinfo where gi_name = 'EDI214CargoRecs' and LEFT(UPPER(IsNull(gi_string1,'N')),1) = 'Y') > 0   
	-- 18466 Only want to put the freights following the first 3 record  
		  Begin  /* for #7 records */  
		   Select  
				@weight = RIGHT(convert( varchar(12),convert(int,ISNULL(f.fgt_weight,0.00)*100)),9),  
				@weightunit = Isnull(f.fgt_weightunit,'UNK'),  
				@volume = RIGHT(convert( varchar(12),convert(int,ISNULL(f.fgt_volume,0.00)*100)),9),  
				@volumeunit = Isnull(f.fgt_volumeunit,'UNK'),  
				@count = RIGHT(convert( varchar(12),convert(int,ISNULL(f.fgt_count,0.00)*100)),9),  
				@countunit = Isnull(f.fgt_countunit,'UNK'),  
				@cmdcode = IsNull(f.cmd_code,'UNKNOWN'),  
				@cmdname = Substring(IsNull(f.fgt_description,''),1,50),  
				@stcccode = c.cmd_stcc,  
				@v_count2 =  RIGHT(convert( varchar(12),convert(int,ISNULL(f.fgt_count2,0.00)*100)),9), --49961  
				@v_count2unit = isnull(f.fgt_count2unit,'UNK')    --49961     
		   From freightdetail f, commodity c  
		   Where fgt_number = @nextfgtnumber and f.cmd_code = c.cmd_code  
		  
		   Select  @edicmdcode = null

		   Select  @edicmdcode = e.edi_cmd_code  
		   FROM edicommodity e  
		   WHERE e.cmp_id = @billtocmpid and e.cmd_code = @cmdcode  
		  
		   Select @edicmdcode =IsNull(@edicmdcode,@cmdcode)  

			Insert into edi_214 (data_col,doc_id,trp_id)  
			SELECT '739' +  
			ISNULL(@cmdname,'') + replicate(' ',50 - datalength(ISNULL(@cmdname,''))) +  
			ISNULL(@edicmdcode,'') + replicate(' ',30 - datalength(ISNULL(@edicmdcode,''))) +  
			replicate(' ',6)+  
			replicate('0',9 - datalength(ISNULL(@weight,''))) + ISNULL(@weight,'') + ISNULL(@weightunit,'') + replicate(' ',6 - datalength(ISNULL(@weightunit,'')))+  
			replicate('0',9 - datalength(ISNULL(@volume,''))) + ISNULL(@volume,'') + ISNULL(@volumeunit,'') + replicate(' ',6 - datalength(ISNULL(@volumeunit,'')))+  
			replicate('0',9 - datalength(ISNULL(@count,''))) + ISNULL(@count,'') + ISNULL(@countunit,'') + replicate(' ',6 - datalength(ISNULL(@countunit,'')))+  
			replicate('0',9 - datalength(ISNULL(@v_count2,''))) + ISNULL(@v_count2,'') + ISNULL(@v_count2unit,'') + replicate(' ',6 - datalength(ISNULL(@v_count2unit,''))), --49961  
			ISNULL(@docid,''),ISNULL(@TRPnbr,'')
		  End  /* for #7 records */  

-- pts 19357    
	if @exportSTCC = 'Y' and @stcccode is not null  
		insert into edi_214 (data_col,doc_id,trp_id) select '439REFSTC' + ISNULL(@stcccode,''), ISNULL(@docid,''), ISNULL(@trpnbr,'')

  If (Select count(*) from referencenumber where ref_table = 'freightdetail' and ref_tablekey = @nextfgtnumber) > 0  
-- PTS 16223 -- BL (start)  
--  exec edi_214_record_id_4_39_sp @ordhdrnumber,'freightdetail',@nextfgtnumber,@TRPNbr,@docid    
	exec edi_214_record_id_4_39_sp @ordhdrnumber,'freightdetail',@nextfgtnumber,@TRPNbr,@docid,@Company_id    
-- PTS 16223 -- BL (end)  
-- PTS 34923 -- FM (start)  
  If @Found856 > 0  
	exec edi_214_record_id_4_39_from856_sp @Found856,@cmdcode,@TRPNbr,@docid  
-- PTS 34923 -- FM (end) 

 FETCH NEXT FROM FREIGHTNUMBER_CURSOR 
 INTO @nextfgtnumber

 END /*fgt A */
 CLOSE FREIGHTNUMBER_CURSOR
 DEALLOCATE FREIGHTNUMBER_CURSOR 
   
End /*relative Mode */  
Else  
begin /*no relative mode */  
  
 -- PTS 16223 -- BL (start)  
 --exec edi_214_record_id_4_39_sp @ordhdrnumber,'stops',@stp_number,@TRPNbr,@docid  
 exec edi_214_record_id_4_39_sp @ordhdrnumber,'stops',@stp_number,@TRPNbr,@docid,@Company_id  
 -- PTS 16223 -- BL (end)  
-- PTS 34923 -- FM (start)  
    IF @Process856 = 'Y'  
  exec @Found856 = edi_214_record_id_6_39_from856_sp @TRPNbr, @docid, @ordhdrnumber, @statuscode  
 else  
  select @Found856 = 0  
-- PTS 34923 -- FM (end)  
  
  
 IF @v_usedrprefs = 'N'  
 BEGIN /* fgt B */  
 --SELECT @nextfgtnumber = MIN(fgt_number), @freightcount = count(fgt_number)  
 --       FROM freightdetail  
 --       WHERE freightdetail.stp_number = @stp_number  
  
     SELECT @last3record = min(identity_col) from edi_214 where @docid = doc_id   
    and @trpnbr = trp_id   
    and data_col like '339%'  
    and CAST(SUBSTRING(data_col,85,3)as int) = @stp_sequence --@stopnumber  --AROSS PTS 27854  
 
 --MTC20131010  
 DECLARE FREIGHTNUMBER_CURSOR cursor fast_forward for
 select fgt_number from freightdetail f 
 where f.stp_number = @stp_number
  order by fgt_number
 
 OPEN FREIGHTNUMBER_CURSOR

 FETCH NEXT FROM FREIGHTNUMBER_CURSOR 
 INTO @nextfgtnumber

 WHILE @@FETCH_STATUS = 0  
     BEGIN  /*fgt b2 */  
     IF (SELECT COUNT(*) FROM generalinfo WHERE gi_name = 'EDI214_OSD' AND LEFT(UPPER(ISNULL(gi_string1,'N')),1) = 'Y') > 0  
   --PTS27619  OSD  
   exec edi_214_record_id_6_39_sp @TRPNbr,@docid,@nextfgtnumber  
  If (Select count(*) From generalinfo where gi_name = 'EDI214CargoRecs' and LEFT(UPPER(IsNull(gi_string1,'N')),1) = 'Y') > 0   
  Begin  /* for #7 records */  
   Select  @weight = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_weight,0.00)*100)),9),  
                     @weightunit = Isnull(fgt_weightunit,'UNK'),  
                          @volume = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_volume,0.00)*100)),9),  
       @volumeunit = Isnull(fgt_volumeunit,'UNK'),  
                          @count = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_count,0.00)*100)),9),  
       @countunit = Isnull(fgt_countunit,'UNK'),  
                          @cmdcode = IsNull(f.cmd_code,'UNKNOWN'),  
                          @cmdname = Substring(IsNull(fgt_description,''),1,50),  
       @stcccode = cmd_stcc,  
       @v_count2 =  RIGHT(convert( varchar(12),convert(int,ISNULL(f.fgt_count2,0.00)*100)),9), --49961  
       @v_count2unit = isnull(f.fgt_count2unit,'UNK')    --49961   
      From freightdetail f, commodity c  
   Where fgt_number = @nextfgtnumber and c.cmd_Code = f.cmd_code  
-- pts 19357    
         if @exportSTCC = 'Y' and @stcccode is not null  
          insert into edi_214 (data_col,doc_id,trp_id) select '439REFSTC' + ISNULL(@stcccode,''), ISNULL(@docid,''), ISNULL(@trpnbr,'')
  
   Select @edicmdcode = Null
  
   Select  @edicmdcode = e.edi_cmd_code  
   FROM edicommodity e  
   WHERE e.cmp_id = @billtocmpid and e.cmd_code = @cmdcode  
  
   Select @edicmdcode =IsNull(@edicmdcode,@cmdcode)  
              Insert into edi_214 (data_col,doc_id,trp_id)  
              SELECT '739' +  
              @cmdname + replicate(' ',50 - datalength(ISNULL(@cmdname,''))) +  
                      ISNULL(@edicmdcode,'') + replicate(' ',30 - datalength(ISNULL(@edicmdcode,''))) +  
                      replicate(' ',6)+  
                      replicate('0',9 - datalength(ISNULL(@weight,''))) + ISNULL(@weight,'') + ISNULL(@weightunit,'') + replicate(' ',6 - datalength(ISNULL(@weightunit,'')))+  
                      replicate('0',9 - datalength(ISNULL(@volume,''))) + ISNULL(@volume,'') + ISNULL(@volumeunit,'') + replicate(' ',6 - datalength(ISNULL(@volumeunit,'')))+  
                      replicate('0',9 - datalength(ISNULL(@count,''))) + ISNULL(@count,'') + ISNULL(@countunit,'') + replicate(' ',6 - datalength(ISNULL(@countunit,'')))+  
                      replicate('0',9 - datalength(ISNULL(@v_count2,''))) + ISNULL(@v_count2,'') + ISNULL(@v_count2unit,'') + replicate(' ',6 - datalength(ISNULL(@v_count2unit,''))), --49961  
                    ISNULL(@docid,''),ISNULL(@TRPnbr,'')
  End  /* for #7 records */    
            
-- PTS 16223 -- BL (start)  
--             exec edi_214_record_id_4_39_sp @ordhdrnumber,'freightdetail',@nextfgtnumber,@TRPNbr,@docid    
             exec edi_214_record_id_4_39_sp @ordhdrnumber,'freightdetail',@nextfgtnumber,@TRPNbr,@docid,@Company_id    
-- PTS 16223 -- BL (end)  
  
  
    If @Found856 > 0  
     exec edi_214_record_id_4_39_from856_sp @Found856,@cmdcode,@TRPNbr,@docid  
  
  
 FETCH NEXT FROM FREIGHTNUMBER_CURSOR 
 INTO @nextfgtnumber
          END /* fgt B2 */ 
 CLOSE FREIGHTNUMBER_CURSOR
 DEALLOCATE FREIGHTNUMBER_CURSOR
       END /* fgt B*/  
  ELSE          
   BEGIN /*fgt C */ 
    
     SELECT @last3record = min(identity_col) from edi_214 where @docid = doc_id   
     and @trpnbr = trp_id   
     and data_col like '339%'  
     and CAST(SUBSTRING(data_col,85,3)as int) = @stp_sequence --@stopnumber  --AROSS PTS 27854  
 
 --MTC20131010   
 DECLARE FREIGHTNUMBER_CURSOR cursor fast_forward for
 select fgt_number from freightdetail f 
 where f.stp_number = @v_drpstopno
 order by fgt_number
 
 OPEN FREIGHTNUMBER_CURSOR

 FETCH NEXT FROM FREIGHTNUMBER_CURSOR 
 INTO @nextfgtnumber

 WHILE @@FETCH_STATUS = 0  
  BEGIN  
        IF (SELECT COUNT(*) FROM generalinfo WHERE gi_name = 'EDI214_OSD' AND LEFT(UPPER(ISNULL(gi_string1,'N')),1) = 'Y') > 0  
    --PTS27619  OSD  
    exec edi_214_record_id_6_39_sp @TRPNbr,@docid,@nextfgtnumber  
   If (Select count(*) From generalinfo where gi_name = 'EDI214CargoRecs' and LEFT(UPPER(IsNull(gi_string1,'N')),1) = 'Y') > 0   
    -- 18466 Only want to put the freights following the first 3 record  
   Begin  /* for #7 records */  
    Select  @weight = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_weight,0.00)*100)),9),  
                      @weightunit = Isnull(fgt_weightunit,'UNK'),  
                           @volume = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_volume,0.00)*100)),9),  
        @volumeunit = Isnull(fgt_volumeunit,'UNK'),  
                           @count = RIGHT(convert( varchar(12),convert(int,ISNULL(fgt_count,0.00)*100)),9),  
        @countunit = Isnull(fgt_countunit,'UNK'),  
                           @cmdcode = IsNull(f.cmd_code,'UNKNOWN'),  
                           @cmdname = Substring(IsNull(fgt_description,''),1,50),  
        @stcccode = cmd_stcc,  
        @v_count2 =  RIGHT(convert( varchar(12),convert(int,ISNULL(f.fgt_count2,0.00)*100)),9), --49961  
        @v_count2unit = isnull(f.fgt_count2unit,'UNK')    --49961    
       From freightdetail f, commodity c  
    Where fgt_number = @nextfgtnumber and c.cmd_Code = f.cmd_code  
 -- pts 19357    
          if @exportSTCC = 'Y' and @stcccode is not null  
           insert into edi_214 (data_col,doc_id,trp_id) select '439REFSTC' + ISNULL(@stcccode,''), ISNULL(@docid,''), ISNULL(@trpnbr,'')  
   
    Select  @edicmdcode = null

    Select  @edicmdcode = e.edi_cmd_code  
    FROM edicommodity e  
    WHERE e.cmp_id = @billtocmpid and e.cmd_code = @cmdcode  
   
    Select @edicmdcode =IsNull(@edicmdcode,@cmdcode)  
               Insert into edi_214 (data_col,doc_id,trp_id)  
               SELECT '739' +  
               ISNULL(@cmdname,'') + replicate(' ',50 - datalength(ISNULL(@cmdname,''))) +  
                       ISNULL(@edicmdcode,'') + replicate(' ',30 - datalength(ISNULL(@edicmdcode,''))) +  
                       replicate(' ',6)+  
                       replicate('0',9 - datalength(ISNULL(@weight,''))) + ISNULL(@weight,'') + ISNULL(@weightunit,'') + replicate(' ',6 - datalength(ISNULL(@weightunit,'')))+  
                       replicate('0',9 - datalength(ISNULL(@volume,''))) + ISNULL(@volume,'') + ISNULL(@volumeunit,'') + replicate(' ',6 - datalength(ISNULL(@volumeunit,'')))+  
                       replicate('0',9 - datalength(ISNULL(@count,''))) + ISNULL(@count,'') + ISNULL(@countunit,'') + replicate(' ',6 - datalength(ISNULL(@countunit,'')))+  
                       replicate('0',9 - datalength(ISNULL(@v_count2,''))) + ISNULL(@v_count2,'') + ISNULL(@v_count2unit,'') + replicate(' ',6 - datalength(ISNULL(@v_count2unit,''))), --49961  
                     ISNULL(@docid,''),ISNULL(@TRPnbr,'')
   End  /* for #7 records */    
             
 -- PTS 16223 -- BL (start)  
 --             exec edi_214_record_id_4_39_sp @ordhdrnumber,'freightdetail',@nextfgtnumber,@TRPNbr,@docid    
              exec edi_214_record_id_4_39_sp @ordhdrnumber,'freightdetail',@nextfgtnumber,@TRPNbr,@docid,@Company_id    
 -- PTS 16223 -- BL (end)  
  
 -- PTS 34923 -- FM (start)  
    If @Found856 > 0  
     exec edi_214_record_id_4_39_from856_sp @Found856,@cmdcode,@TRPNbr,@docid  
 -- PTS 34923 -- FM (end)  
  
 FETCH NEXT FROM FREIGHTNUMBER_CURSOR 
 INTO @nextfgtnumber
          END  
 CLOSE FREIGHTNUMBER_CURSOR
 DEALLOCATE FREIGHTNUMBER_CURSOR
 END  --40747     
  end  
GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_3_39_sp] TO [public]
GO
