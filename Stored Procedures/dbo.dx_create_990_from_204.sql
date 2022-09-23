SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [dbo].[dx_create_990_from_204] @p_ordnum varchar(12), @p_decision char(1), @p_scac varchar(4) = ''
as

/*****Change Log *****
*
*
* 03.08.10 - Changed Appt Generation to TP based setting versus global GI
* 04.19.10 - Added unique doc id to 990ob.  Value is written to dx_sourcename field and replaces dedfault C:\ value
* 07.01.10 - Updated to use tp specific settings for 990 creation/suppression

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  09/07/2016   David Wilks      99730        support trading partner wrapper setting 
********************************************************************************************************************/


DECLARE @SCAC varchar(60), @revstart int, @revtype varchar(8), @ordrevtype varchar(6), 
	@sourceident int, @sourcedate datetime, @scacident int, @p_ordhdr int, @p_mov int,
	@p_edistate tinyint, @p_declinereason varchar(30),@p_ordstatus varchar(6),@priorIdent int,
	@p_accepttext varchar(60)

DECLARE @EDI990 TABLE
(dx_importid varchar(8) NOT NULL, 
 dx_sourcename varchar(255) NOT NULL, 
 dx_sourcedate datetime NOT NULL, 
 dx_seq int NOT NULL, 
 dx_updated char(1) NULL, 
 dx_accepted bit NULL, 
 dx_ordernumber varchar(30) NULL, 
 dx_orderhdrnumber int NULL, 
 dx_movenumber int NULL, 
 dx_stopnumber int NULL,
 dx_freightnumber int NULL, 
 dx_docnumber varchar(9) NULL, 
 dx_manifestnumber varchar(30) NULL, 
 dx_manifeststop int NULL,  
 dx_batchref int NULL,
 dx_field001 varchar(200) NULL, 
 dx_field002 varchar(200) NULL,
 dx_field003 varchar(200) NULL,
 dx_field004 varchar(200) NULL,
 dx_field005 varchar(200) NULL,
 dx_field006 varchar(200) NULL,
 dx_field007 varchar(200) NULL,
 dx_field008 varchar(200) NULL,
 dx_sourcedate_reference datetime)
	
--get orderheader number
SELECT @p_ordhdr = ord_hdrnumber, @p_mov = mov_number
     , @p_edistate = ISNULL(ord_edistate, 0), @p_declinereason = ISNULL(ord_edideclinereason,'') 
     , @p_ordstatus = ord_status, @p_accepttext = ISNULL(ord_ediaccepttext,'') 
  FROM orderheader WHERE ord_number = @p_ordnum
  
IF @p_ordhdr IS NULL RETURN -1


DECLARE @sourceseq int, @purpose char(1), @ordnum varchar(20), @docnumber varchar(9), 
	@tpid varchar(20), @date datetime, @dxseq int, @startdate varchar(6), 
	@reftype varchar(3), @sid char(1), @starttime varchar(4), @visualedi char(1),
	@enddate varchar(6), @endtime varchar(4),@getdate datetime ,@docID varchar(30),
	@max204source int, @min204source int, @min204sourceNext int, @processSeq int
 
 /***Insert loop control logic for 990 here  ***/
 DECLARE @loop int,
 			@record_count int
 			
 --temp table for pending 990 data
 DECLARE @temp990 Table(
 		process_seq int not null,
 		dx_ident	int,
 		purpose	char(1),
		dx_sourcedate datetime
 		)

--generate unique ID
select @getdate = GETDATE()
select @docID = '990-' + RTRIM(@p_ordhdr) + '-' +
      CONVERT(varchar(8),@getdate,12) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),1,2) + 
      SUBSTRING(CONVERT(varchar(8),@getdate,8),4,2) +
      SUBSTRING(CONVERT(varchar(8),@getdate,8),7,2) +
      CONVERT(varchar(3),DATEPART(Ms,@getdate))


 		
--get scac
SELECT top 1 @max204source = dx_ident, @tpid = dx_trpid, @sourcedate = isnull(dx_sourcedate_reference, dx_sourcedate) FROM dx_Archive_header WITH (NOLOCK)
						join dx_Archive_detail with (nolock) on dx_Archive_header.dx_Archive_header_id = dx_Archive_detail.dx_Archive_header_id
 WHERE dx_orderhdrnumber = @p_ordhdr
   AND dx_importid = 'dx_204'
   AND dx_field001 = '02'
   AND (dx_processed = 'DONE' OR dx_processed = 'RESERV' OR dx_processed = 'IGNORE' OR dx_processed = 'REJ' OR dx_processed = 'WAIT')
   Order by dx_ident desc

IF @max204source IS NULL RETURN -1

SELECT @purpose = dx_field004 FROM dx_archive_detail WITH (NOLOCK) WHERE dx_ident = @max204source
 

declare @AllowReject990AfterAccept int
exec @AllowReject990AfterAccept = dx_GetLTSL2TradingPartnerSetting 'AllowReject990AfterAccept', @tpid 

set @processSeq = 1

if @AllowReject990AfterAccept = 1 and @p_decision = 'D'
begin
	 --insert placeholder into temp table for 990
	INSERT INTO @temp990
		VALUES(@processSeq,@max204source,@purpose,@sourcedate)
		set @processSeq = @processSeq + 1
end
else
	IF NOT EXISTS(SELECT 1 FROM dx_Archive_header WHERE dx_orderhdrnumber = @p_ordhdr and dx_importid = 'dx_990' and dx_sourcedate_reference = @sourcedate)
	begin
		INSERT INTO @temp990
			VALUES(@processSeq,@max204source,@purpose,@sourcedate)
		set @processSeq = @processSeq + 1
	end

declare @Send990ForEachUpdate204 int
exec @Send990ForEachUpdate204 = dx_GetLTSL2TradingPartnerSetting 'Send990ForEachUpdate204', @tpid 
if @Send990ForEachUpdate204  = 1 AND @p_decision <> 'D'
BEGIN
	set @min204source = 0
	set @min204sourceNext = 0
	--check each 204 to see if 990 was sent
	WHILE @min204sourceNext < @max204source
		BEGIN --990 process loop
		SELECT top 1 @min204sourceNext = dx_ident, @sourcedate = isnull(dx_sourcedate_reference, dx_sourcedate) FROM dx_Archive_header WITH (NOLOCK)
						join dx_Archive_detail with (nolock) on dx_Archive_header.dx_Archive_header_id = dx_Archive_detail.dx_Archive_header_id
		WHERE dx_orderhdrnumber = @p_ordhdr
		AND dx_importid = 'dx_204'
		AND dx_field001 = '02'
		AND dx_processed <> 'QUEUED'
		AND dx_processed <> 'RESERV'
		AND dx_processed <> 'REJ'
		AND dx_processed not like 'MOD%'
		AND dx_processed not like 'PEND%'
		AND dx_ident > @min204source 
		Order by dx_ident 

		if @min204sourceNext is null break

		if @min204source = @min204sourceNext 
			break

		set @min204source = @min204sourceNext 
		
		IF NOT EXISTS(SELECT 1 FROM dx_Archive_header WHERE dx_orderhdrnumber = @p_ordhdr and dx_importid = 'dx_990' and dx_sourcedate_reference = @sourcedate)
		AND NOT EXISTS(SELECT 1 FROM @temp990 WHERE dx_sourcedate = @sourcedate)
			BEGIN
				SET @processSeq = @processSeq + 1
				INSERT INTO @temp990
					VALUES(@processSeq,@min204source,'U',@sourcedate)
			END
		END
END
else
begin
	IF @purpose = 'U'
	BEGIN /*checks for update loop */
		IF (SELECT COUNT(*) FROM dx_archive_header WITH (NOLOCK) WHERE dx_orderhdrnumber =  @p_ordhdr AND dx_importid = 'dx_990')  < 1
			IF (SELECT MAX(dx_ident) FROM dx_Archive_header WITH (NOLOCK)
						join dx_Archive_detail with (nolock) on dx_Archive_header.dx_Archive_header_id = dx_Archive_detail.dx_Archive_header_id
			WHERE dx_orderhdrnumber = @p_ordhdr AND dx_importid = 'dx_204' AND dx_field001 = '02' AND dx_field004 = 'N') > 0
				BEGIN --create a new placeholder for the 'new' 204 that was not previously acknowledged
				
					SELECT top 1 @sourceident = dx_ident, @sourcedate = isnull(dx_sourcedate_reference, dx_sourcedate)
					FROM dx_archive WITH (NOLOCK) 
					WHERE dx_orderhdrnumber = @p_ordhdr 
						AND dx_importid = 'dx_204' 
						AND dx_field001 = '02' 
						AND dx_field004 = 'N'
					Order by dx_ident desc
				  
						--update the sequence for current update record
						UPDATE @temp990 SET process_seq  =  2
						IF NOT EXISTS(SELECT 1 FROM dx_Archive_header WHERE dx_orderhdrnumber = @p_ordhdr and dx_importid = 'dx_990' and dx_sourcedate_reference = @sourcedate)
						AND NOT EXISTS(SELECT 1 FROM @temp990 WHERE dx_sourcedate = @sourcedate)
						BEGIN
							INSERT INTO @temp990
							VALUES(1,@sourceident,'N',@sourcedate)
						END
				END
	END /*update check loop*/
end 
 
SELECT @record_count =  ISNULL((SELECT COUNT(*) FROM @temp990),0)
SET @loop = 1

WHILE @loop <= @record_count

BEGIN --990 process loop

SELECT @sourceident = dx_ident 
FROM @temp990
WHERE process_seq =  @loop
 
  --moved down for multiple 990 processing
  SELECT @sourcedate = isnull(dx_sourcedate_reference, dx_sourcedate), @sourceseq = dx_seq
       , @purpose = dx_field004, @ordnum = dx_ordernumber
       , @docnumber = dx_docnumber, @tpid = rtrim(dx_field003)
       , @startdate = substring(dx_field007,5,4) + substring(dx_field007,3,2)
       , @starttime = substring(dx_field007,9,4)
       , @enddate = substring(dx_field008,5,4) + substring(dx_field008,3,2)
       , @endtime = substring(dx_field008,9,4), @SCAC = LEFT(RTRIM(ISNULL(dx_field020,'')),4)
    FROM dx_Archive_header WITH (NOLOCK)
		join dx_Archive_detail with (nolock) on dx_Archive_header.dx_Archive_header_id = dx_Archive_detail.dx_Archive_header_id
 WHERE dx_ident = @sourceident
 
IF (@AllowReject990AfterAccept = 1 and @p_decision = 'D') OR NOT EXISTS(SELECT 1 FROM dx_Archive_header WHERE dx_orderhdrnumber = @p_ordhdr and dx_importid = 'dx_990' and dx_sourcedate_reference = @sourcedate)
BEGIN
		IF EXISTS(SELECT 1 FROM dx_xref where dx_trpid = @tpid and dx_entitytype = 'CustomSettings' and dx_entityname = 'Create990OnAssignment' and dx_xrefkey = 1)
		BEGIN
			IF @p_ordstatus <> 'PLN'
				RETURN 1
		END			

						IF @p_decision = 'A'
						BEGIN
							IF @purpose = 'N'
							BEGIN
								IF EXISTS(SELECT 1 FROM dx_xref WHERE dx_trpid = @tpid AND dx_entitytype = 'TPSettings' AND dx_entityname = 'CreateAppt214OnAccept' AND dx_xrefkey = 1)
								--IF (SELECT LEFT(ISNULL(gi_string1,'N'), 1) FROM generalinfo WHERE gi_name = 'LTSLGenerateAppt214s') = 'Y'
									EXEC dx_create_appointment214 @p_ordhdr
							END
							--PTS 52940 Add Handling for 990 Suppression Settings
							IF @purpose = 'N' AND (SELECT ISNULL(etp_AcceptRequired,0) FROM edi_tender_partner WHERE etp_partnerID = @tpid) <> 1 RETURN 1
							IF @purpose = 'U' AND (SELECT ISNULL(etp_AcceptOnUpdate,0) FROM edi_tender_partner WHERE etp_partnerID = @tpid) <> 1 RETURN 1
							IF @purpose = 'C' AND (SELECT ISNULL(etp_AcceptOnCancel,0) FROM edi_tender_partner WHERE etp_partnerID = @tpid) <> 1 RETURN 1
						END

						IF @p_decision = 'D'
						BEGIN
							IF @p_edistate = 39 RETURN 1
							--PTS52940 Add Handling for 990 Suppression by Trading Partner
							IF @purpose = 'N' AND (SELECT ISNULL(etp_DeclineRequired,0) FROM edi_tender_partner WHERE etp_partnerID = @tpid) <> 1 RETURN 1
							IF @purpose = 'U' AND (SELECT ISNULL(etp_DeclineOnUpdate,0) FROM edi_tender_partner WHERE etp_partnerID = @tpid) <> 1 RETURN 1
							IF @purpose = 'C' AND (SELECT ISNULL(etp_DeclineOnCancel,0) FROM edi_tender_partner WHERE etp_partnerID = @tpid) <> 1 RETURN 1
						END

						IF RTRIM(ISNULL(@p_scac,'')) = ''
							BEGIN
								Declare @etp_ExportWrapper varchar(6)
								SELECT @etp_ExportWrapper = etp_ExportWrapper
								FROM edi_tender_partner WHERE edi_tender_partner.etp_partnerID = @tpid 
								IF @etp_ExportWrapper is null or @etp_ExportWrapper = ''
									SELECT @etp_ExportWrapper = IsNull(gi_string1,'FULL')
									FROM generalinfo WHERE gi_name = 'EDI990WrapOverride'

								IF ISNULL(@SCAC,'') = '' OR @etp_ExportWrapper = 'FULL' 
									exec dbo.dx_get_scac @p_ordhdr, @SCAC OUTPUT
							END
						ELSE
							SELECT @SCAC = UPPER(@p_scac)

						SELECT @date = getdate(), @dxseq = 0, @sid = 'N'

						SELECT @visualedi = UPPER(LEFT(gi_string1,1)) FROM generalinfo WHERE gi_name = 'LTSLUsingVisualEDI'

						INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
							dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
							dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
							dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
							dx_field006, dx_sourcedate_reference)
						VALUES ('dx_990',@docID, @date, @dxseq, @purpose,
							case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
							0, @docnumber, null, 0, null,
							'#TMW','990',' FROM ',@SCAC,' TO ',
							case ISNULL(@visualedi,'') when 'Y' then left(@tpid, 10) else @tpid end, @sourcedate)

						SELECT @dxseq = @dxseq + 1
						INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
							dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
							dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
							dx_field001, dx_field002, dx_sourcedate_reference)
						VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
							case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
							0, @docnumber, null, 0, null,
							'\\P:', case ISNULL(@visualedi,'') when 'Y' then left(@tpid,10) else @tpid end, @sourcedate)

						--save 01 record
						SELECT @dxseq = @dxseq + 1
						INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
							dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
							dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
							dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
							dx_field006, dx_field007, dx_field008, dx_sourcedate_reference)
						VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
							case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
							0, @docnumber, null, 0, null,
							'01','39',@SCAC,@ordnum,replace(convert(varchar,@date,1),'/',''),
							@p_decision,left(@tpid,14),@purpose,@sourcedate)

						--save 02 CN record
						IF @p_decision = 'A'
						BEGIN
							SELECT @dxseq = @dxseq + 1
							INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
								dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
								dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
								dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
								dx_field006, dx_field007, dx_field008, dx_sourcedate_reference)
							VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
								case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
								0, @docnumber, null, 0, null,
								'02','39','CN ',@p_ordhdr,'','','','',@sourcedate)
						END

						--Add 02 doc id record
						BEGIN
							SELECT @dxseq = @dxseq + 1
							INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
								dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
								dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
								dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
								dx_field006, dx_field007, dx_field008, dx_sourcedate_reference)
							VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
								case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
								0, @docnumber, null, 0, null,
								'02','39','RID',@docID,'','','','',@sourcedate)
						END
				
						--save 02 misc records
						DECLARE @sourcetype varchar(2)

						WHILE 1=1
						BEGIN
							SELECT @sourceseq = @sourceseq + 1
					
							SELECT @sourceident = dx_ident, @sourcetype = dx_field001, @reftype = dx_field003
							  FROM dx_Archive_header WITH (NOLOCK)
								join dx_Archive_detail with (nolock) on dx_Archive_header.dx_Archive_header_id = dx_Archive_detail.dx_Archive_header_id
							 WHERE dx_sourcedate = @sourcedate
							   AND dx_orderhdrnumber = @p_ordhdr
							   AND dx_importid = 'dx_204'
							   AND dx_seq = @sourceseq

							IF @sourceseq > 999 and @sourceident is null break

							IF ISNULL(@sourcetype,'03') in ('03','06') break
							--11.23.09 AR Update for short cancellation error
							IF @sourceident = @priorIdent break

							IF @sourcetype = '05'
							BEGIN
								SELECT @dxseq = @dxseq + 1
								INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
									dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
									dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
									dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
									dx_field006, dx_field007, dx_field008, dx_sourcedate_reference)
								SELECT 'dx_990', @docID, @date, @dxseq, @purpose,
									case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
									0, @docnumber, null, 0, null,
									'02','39', dx_field003, dx_field004, dx_field005,
									dx_field006, dx_field007, dx_field008, @sourcedate
								  FROM dx_Archive_header WITH (NOLOCK)
									join dx_Archive_detail with (nolock) on dx_Archive_header.dx_Archive_header_id = dx_Archive_detail.dx_Archive_header_id
								 WHERE dx_ident = @sourceident
								IF @reftype = 'SID' SELECT @sid = 'Y'
							END
							SELECT @priorIdent = @sourceident
						END

						--save 02 SID record
						IF @sid = 'N'
						BEGIN
							SELECT @dxseq = @dxseq + 1
							INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
										dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
										dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
										dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
										dx_field006, dx_field007, dx_field008, dx_sourcedate_reference)
							VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
									case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
									0, @docnumber, null, 0, null,
									'02','39','SID',@ordnum,'','','','',@sourcedate)
						END
						/*
						IF (SELECT COUNT(1) FROM dx_xref 
							 WHERE dx_importid = 'dx_204' and dx_trpid = @tpid 
							   and dx_entitytype = 'TPSettings' and dx_entityname = 'UseMiscRefs'
							   and dx_xrefkey = '-1') = 1
						BEGIN
							DECLARE @sidnum varchar(20)
							SELECT @sidnum = MAX(ref_number)
							  FROM referencenumber
							 WHERE ref_tablekey = @p_ordhdr and ref_type = 'SID' and ref_table = 'orderheader'
							IF ISNULL(@sidnum,'') > ''
							BEGIN
								SELECT @dxseq = @dxseq + 1
								INSERT dx_archive (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
									dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
									dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
									dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
									dx_field006, dx_field007, dx_field008)
								SELECT 'dx_990', 'C:\', @date, @dxseq, @purpose,
									case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
									0, @docnumber, null, 0, null,
									'02','39','SID', @ordnum, dx_field005,
									dx_field006, dx_field007, dx_field008
								  FROM dx_archive WITH (NOLOCK)
								 WHERE dx_ident = @sourceident
							END
						END
						*/

						--save 03 record
						SELECT @dxseq = @dxseq + 1
						INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
							dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
							dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
							dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
							dx_field006, dx_field007, dx_field008,dx_sourcedate_reference)
						VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
							case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
							0, @docnumber, null, 0, null,
							'03','39','  ',@startdate,' ',@starttime,'','',@sourcedate)

						--additional 03 record
						IF (SELECT COUNT(1) FROM dx_xref 
							 WHERE dx_importid = 'dx_204' and dx_entitytype = 'LtslSettings' 
							   and dx_entityname = 'IncludeDeliveryDateIn990' and dx_xrefkey = '1') = 1
						BEGIN
							SELECT @dxseq = @dxseq + 1
							INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
								dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
								dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
								dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
								dx_field006, dx_field007, dx_field008,dx_sourcedate_reference)
							VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
								case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
								0, @docnumber, null, 0, null,
								'03','39','17',@enddate,' ',@endtime,'','',@sourcedate)
						END

						--save 07 record
						IF @p_decision = 'D' AND LEN(@p_declinereason) > 0
						BEGIN
							SELECT @dxseq = @dxseq + 1
							INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
								dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
								dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
								dx_field001, dx_field002, dx_field003, dx_field004, dx_sourcedate_reference)
							VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
								case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
								0, @docnumber, null, 0, null,
								'07','39',@p_declinereason,'',@sourcedate)
						END
						--save 07 record
						IF @p_decision = 'A' AND LEN(@p_accepttext) > 0
						BEGIN
							declare @p_accepttext2 varchar(30)
							IF LEN(@p_accepttext) > 30
								BEGIN
									SET @p_accepttext2 = substring(@p_accepttext,31,30)
									SET @p_accepttext = substring(@p_accepttext,1,30)
								END
							ELSE
								SET @p_accepttext2 = ''
						
							SELECT @dxseq = @dxseq + 1
							INSERT @EDI990 (dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, 
								dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,
								dx_freightnumber, dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref,
								dx_field001, dx_field002, dx_field003, dx_field004, dx_sourcedate_reference)
							VALUES ('dx_990', @docID, @date, @dxseq, @purpose,
								case @p_decision when 'A' then 1 else 0 end, @ordnum, @p_ordhdr, @p_mov, 0,
								0, @docnumber, null, 0, null,
								'07','39',@p_accepttext,@p_accepttext2,@sourcedate)
						END
				
						INSERT dx_archive_header (dx_importid, dx_sourcename, dx_sourcedate, dx_updated, 
							dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, 
							dx_docnumber, dx_manifestnumber, dx_batchref,
							dx_sourcedate_reference, dx_updatedate)
						SELECT dx_importid, dx_sourcename, dx_sourcedate, dx_updated, 
							dx_accepted, dx_ordernumber, dx_orderhdrnumber, dx_movenumber, 
							dx_docnumber, dx_manifestnumber, dx_batchref,
							dx_sourcedate_reference, GETDATE()
						  FROM @EDI990 where dx_seq = 1

						declare @dx_archive_header_id bigint
						select @dx_archive_header_id = @@IDENTITY

						INSERT dx_archive_detail (dx_seq, 
							dx_stopnumber,
							dx_freightnumber, dx_manifeststop, 
							dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
							dx_field006, dx_field007, dx_field008,dx_Archive_header_id)
						SELECT dx_seq, 
							dx_stopnumber,
							dx_freightnumber, dx_manifestnumber, 
							dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
							dx_field006, dx_field007, dx_field008, @dx_archive_header_id
						  FROM @EDI990
						 ORDER BY dx_seq

						--save record in queue
						EXEC dx_EDI990InsertPending @p_ordhdr, @ordnum, @docnumber, @date, @tpid
				
		END -- Else dx_sourcedate_reference already exists so do nothing

		--clear 990 data table
		Delete FROM @EDI990
				
		--increment loop counter
		SELECT @loop = @loop + 1
 END --990 process Loop
RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_create_990_from_204] TO [public]
GO
