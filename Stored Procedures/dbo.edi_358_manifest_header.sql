SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_358_manifest_header] @p_ord_number varchar(13),@p_manifest_typecode char(1), @p_iit_flag char(1),
					 @p_trl1_wgt int,@p_trl2_wgt int = Null,@p_trl1_count int,@p_trl2_count  int = Null,
					 @p_amendcode varchar(3),@p_updatetype varchar(3) = null,@p_updatecode varchar(3) =null,@p_updatescn varchar(16) =null,
					 @p_mov_number int
/**
 * 
 * NAME:
 * dbo.edi_358_manifest_header
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This procedure deletes note data for the specified registration.
 *
 * RETURNS:
 * A return value of zero indicates success. A non-zero return value
 * indicates a failure of some type
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_reg_number, varchar(10), input, null;
 *       This parameter indicates the number of the registration to which 
 *       the note data is associated. The value must be non-null and 
 *       non-empty.
 * 002 - @p_note_type, varchar(6), input, null;
 *       This parameter indicates the type of note for which deletion is
 *       requested. The value must be non-null and non-empty.
 * 003 - @p_ntb_table, varchar(18), input, null;
 *       This parameter indicates the table to which the note data is
 *       associated. The value must be non-null and non-empty.
 *
 * REFERENCES:
 * 001 - dbo.
 * 
 * REVISION HISTORY:
 * 02/24/2006.01 - A.Rossman - Initial release.
 * 04/10/2006.02 - PTS 32515 - A.Rossman - Updated to get receiver ID from GI setting ACE:ReceiverID. Also removed pipe
 *			delimiters from header and trailer records.
 * 04/14/2006.03 - PTS32601 - A.Rossman - Do not include freight and shipment data on preliminary 358 documents.
 * 01/18/2006.04 - PTS32601 - A.Rossman - Added amendment code and details for M13 segment reporting.
 * 05/24/2006.05 - PTS32601 - A.Rossman - Corrected Nesting of 4 and 5 records for multiple trailers
 * 07/05/2006.06 - PTS33469 - A.Rossman - Get the trailer ID from the border crossing event versus the legheader.
 * 09/20/2006.07 - PTS34551 - A.Rossman - Corrected logic for assigning an alpha character to the shipment control number.  Use trailer number fr output on 5 records.
 * 11/16/2006.08 - PTS35045 - A.Rossman - Only apply the IIT indicator to the tractor record if there is no trailer associated.
 * 12/13/2006.09 - PTS35457 - A.Rossman - Update lgh_acestatus for all legs on an ACE movement.
 * 03.21.2007.10 - PTS 36775 - A. Rossman - Ensure correct port code is retrieved.
 * 09.21.2007.11 - PTS 39508 - A. Rossman - Added move number parameter. Filtered shipment data based on input movement number.
 * 08.28.2008.12 - PTS 44182 - A. Rossman - Added support for alternate SCAC at the shipment level.
 * 10.04.2008.13 - PTS 44679 - A. Rossman - Allow for default Qty and Units.
 * 03.26.2009.14 - PTS 46718 - A. Rossman - Filter Shipments for Empty Commodity List
 **/
 
 AS
 
 DECLARE @v_358ctrl	int,	--control  number for the 358 document
 	 @v_scac	varchar(20),	--scac code
 	 @v_revstart	smallint,
 	 @v_revtype	varchar(9),
 	 @v_ord_revtype	varchar(6),
 	 @v_mov_number	int,
 	 @v_formatdate	varchar(8),
 	 @v_formattime	varchar(4),
 	 @v_broker	varchar(8),
 	 @v_port	varchar(4),
 	 @v_scheduled_arr	datetime,
 	 @mi		varchar(2),
 	 @hh		varchar(2),
 	 @v_ord_hdrnumber int,
 	 @v_shipper	varchar(8),
 	 @v_consignee	varchar(8),
 	 @v_othercomp	varchar(8),
 	 @v_driver	varchar(8),
 	 @v_codriver	varchar(8),
 	 @v_tractor	varchar(8),
 	 @v_trailer	varchar(13),
 	 @v_pup		varchar(13),
 	 @v_fgt_recs	int,
 	 @v_loop_count	int,
 	 @v_fgt_num	int,
 	 @v_ord_number	varchar(16),
 	 @v_reccount	int,
 	 @v_lgh_number	int,
 	 @v_pass_count	int,
 	 @v_passenger	varchar(8),
 	 @v_SCN		varchar(16),
 	 @v_loop_counter2	int,
 	 @v_stpnum	int,
 	 @v_drpcount	int,
 	 @v_char	int,
 	 @v_usealpha	char(1),
 	 @v_receiverid	varchar(24),
 	 @v_preliminary	char(1),
 	 @v_curr_ord	varchar(16),
 	 @v_last_ord	varchar(16),
 	 @v_stpseq	int,
 	 @v_freight_scn	varchar(16),
 	 @v_cbp_stop	int,
 	 @v_trl_number varchar(8),
 	 @v_trc_iit	 char(1),
 	 @v_output_scn varchar(16),
 	  @v_useAltScac char(1),		--44182
	  @v_altSCAC	varchar(4),		--44182
	 @v_altSCACRevtype	varchar(8) ,--44182
	 @v_totalweight	int,
	 @v_swapweight char(1)		--45638
	 DECLARE @v_usedefault char(1),@v_defaultUnit varchar(6),@v_defaultQty Int		--PTS#44679
	 DECLARE @cmdlist varchar(255)	--PTS 46718
 	 
--declare a temp table for the freight info
CREATE TABLE #temp_freight 
(	record_id	int identity(1,1) NOT NULL,
	fgt_number	int NULL,
	ord_number	varchar(16) NULL,
	stp_number	int	NULL,
	stp_mfh_sequence	int NULL,
	fgt_count	int	NULL,
	fgt_weight	int	NULL,
	fgt_volume int NULL,
	ord_hdrnumber int	NULL,
	cmd_code	varchar(8) NULL		--46718
)
 	--PTS38123 add temp table for moves.
	create table #movs (mov_number int)
	 
 
--get the  control number for the 358 document
EXEC @v_358ctrl = getsystemnumber 'EDI358',''

/*IF UPPER(LEFT(@p_ord_number,2)) = 'MT'
	SELECT @v_mov_number = RIGHT(@p_ord_number,datalength(@p_ord_number)- 2)
ELSE
	SELECT @v_mov_number = mov_number,
	       @v_ord_hdrnumber = ord_hdrnumber
	FROM 	orderheader 
	WHERE 	ord_number = @p_ord_number		*/ 
--PTS 39508 Set move based on input parm
SELECT @v_mov_number = @p_mov_number

/**** Get General Info Table Settings ****/

	 /*PTS 32515 AROSS; Get the receiver ID from the generalinfo table */
	 SELECT	@v_receiverid = UPPER(ISNULL(gi_string1,'CBP-ACE-TEST'))
	 FROM	generalinfo
	 WHERE	gi_name = 'ACE:ReceiverID'

		IF @v_receiverid <> 'CBP-ACE' AND @v_receiverid <> 'CBP-ACE-TEST'
			SET @v_receiverid = 'CBP-ACE-TEST'

	/*end PTS 32515 */ 

	/*PTS 44679 */
	 SELECT @v_usedefault = LEFT(UPPER(ISNULL(gi_string1,'N')),1)
	 FROM	generalinfo
	 WHERE	gi_name = 'ACE:DefaultManifestQty'
	 /*end PTS 44679*/

	 --PTS 45638 Aross
	 SELECT	@v_swapweight = LEFT(UPPER(ISNULL(gi_string1,'N')),1)
	 FROM		generalinfo
	 WHERE	gi_name = 'ACE:ApplyVolumeforZeroWeight'
	
	--PTS46718
	SELECT @cmdlist = ISNULL(UPPER(gi_string1),'XXX') 
	FROM	  generalinfo
	WHERE	gi_name = 'ACE:IgnoreCommodityOn358'

/**** End General Info Settings ****/	 

/*PTS 38123 -- Add data to moves temp table*/
	--insert move data
	insert #movs 
	select stops.mov_number from stops inner join stops stops2 on stops.ord_hdrnumber = stops2.ord_hdrnumber
	where stops2.mov_number = @v_mov_number and stops2.ord_hdrnumber > 0
	group by stops.mov_number

--end 38123	

/*SELECT @v_mov_number  =  ISNULL(stops.mov_number,@v_mov_number)
FROM 	   stops
	INNER JOIN #movs on stops.mov_number =  #movs.mov_number
WHERE	stp_event in ('NBCST','BCST')	*/

--PTS 32601
IF (SELECT COUNT(*) FROM ace_edidocument_archive WHERE mov_number = @v_mov_number AND aea_doctype = '309') <> 0
	SET @v_preliminary = 'N'
ELSE
	SET @v_preliminary = 'Y'
	
/*condition to IIT flag*/
SELECT @p_iit_flag = CASE @p_iit_flag
			WHEN 'N' THEN ' '
			ELSE @p_iit_flag
		     END

--END PTS 32601

--44182
SELECT @v_ord_hdrnumber =  MIN(ord_hdrnumber) FROM orderheader WHERE mov_number =  @v_mov_number

--Get the legheader for the first border crossing event
SELECT 	@v_lgh_number = lgh_number,
	@v_cbp_stop   = stp_number
FROM	stops
WHERE	mov_number = @v_mov_number
	AND stp_event in ('BCST','NBCST')
	and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops 
				WHERE mov_number = @v_mov_number AND stp_event in ('BCST','NBCST')
							AND stp_state IN (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA'))



--get the scac code from the generalinfo table or from revtypeN value on order.
SELECT  @v_scac=UPPER(ISNULL(gi_string1, 'SCAC'))
FROM	generalinfo 
WHERE	gi_name='SCAC'

SELECT  @v_revstart = CHARINDEX('REVTYPE',@v_scac,1)

IF @v_revstart = 0
    SET @v_scac = SUBSTRING(@v_scac,1,4)
ELSE
    BEGIN
    SELECT @v_revtype = SUBSTRING(@v_scac,@v_revstart,8)
       SELECT @v_ord_revtype = 
         Case @v_revtype
           When 'REVTYPE1' Then ord_revtype1
           When 'REVTYPE2' Then ord_revtype2
           When 'REVTYPE3' Then ord_revtype3
           When 'REVTYPE4' Then ord_revtype4
           Else ord_revtype1
         End
   FROM orderheader
   WHERE  ord_hdrnumber = @v_ord_hdrnumber
	
    SELECT 	@v_SCAC = isnull(UPPER(edicode),abbr)
    FROM 	labelfile
    WHERE 	labeldefinition = @v_revtype
	AND     abbr = @v_ord_revtype

	-- handle spaces in edicode field
	IF LEN(RTRIM(@v_SCAC)) = 0 
	   SELECT @v_SCAC = 'ERRL' 

	SELECT @v_SCAC = SUBSTRING(@v_SCAC,1,4)
    END
    
    
    	    /*PTS 44182 Handling for Alternate SCAC value */
    	    IF (SELECT CHARINDEX('REVTYPE',gi_string1) FROM generalinfo WHERE gi_name = 'ACE:AlternateSCAC') > 0
    		    BEGIN
    
    				SET @v_useAltScac = 'Y'
    				SELECT @v_altSCACRevtype =  UPPER(SUBSTRING(gi_string1,1,8)) FROM generalinfo WHERE  gi_name = 'ACE:AlternateSCAC'
    
    				SELECT @v_altSCAC =  CASE @v_altSCACRevtype
    											WHEN 'REVTYPE1' THEN ord_revtype1
    											WHEN 'REVTYPE2' THEN ord_revtype2
    											WHEN 'REVTYPE3' THEN ord_revtype3
    											WHEN 'REVTYPE4' THEN ord_revtype4
    											ELSE ord_revtype1
    										END
    				FROM 	orderheader
    				WHERE ord_hdrnumber =  @v_ord_hdrnumber
    
    				--get the edicode for alternate scac
    				IF (SELECT LEN(edicode) FROM labelfile WHERE labeldefinition = @v_altSCACRevtype AND abbr  = @v_altSCAC) > 1
    					SELECT @v_altSCAC = isnull(UPPER(edicode),abbr)
    					FROM	labelfile
    					WHERE	labeldefinition =  @v_altSCACRevtype
    							AND abbr = @v_altSCAC
    
    		   END 
    	ELSE
    		SET @v_useAltSCAC = 'N'
    	/*end PTS 44182 */	   
	    	
    
    
    
    
    
-- format  current date to yymmdd , time to hhmi
SELECT @v_formatdate=CONVERT( VARCHAR(8),GETDATE(),112)
SELECT @v_formatdate = REPLICATE('0', 8 - DATALENGTH(@v_formatdate)) +
	@v_formatdate
    SELECT @mi=CONVERT( VARCHAR(2),DATEPART(mi,GETDATE()))
    SELECT @hh=CONVERT( VARCHAR(2),DATEPART(hh,GETDATE()))
    SELECT @v_formattime=
	REPLICATE('0',2-DATALENGTH(@hh)) + @hh +
	REPLICATE('0',2-DATALENGTH(@mi)) + @mi    
    
--insert the header record into the edi_358 table
INSERT INTO edi_358(data_col,batch_number,mov_number)
    VALUES('#TMW358 FROM ' +@v_scac+' TO '+ @v_receiverid + ' '+@v_formatdate+' '+@v_formattime+' '+CAST(@v_358ctrl AS varchar(8)),
@v_358ctrl,
@v_mov_number)


/*Begin creation of the manifest header #1 record */

--determine the broker company id in order to get the port code also get the scheduled arrival date and time
SELECT	 @v_broker =  cmp_id ,		--broker
	 @v_scheduled_arr = CASE stp_schdtearliest 
	 			WHEN '1/1/1950 00:00' Then stp_arrivaldate
	 			ELSE stp_schdtearliest
	 		    END	
FROM	 stops 
WHERE	 stp_event in ('BCST','NBCST') 
		and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops	WHERE mov_number = @v_mov_number AND stp_event in('BCST','NBCST')
		and stp_state in (SELECT stc_state_c from statecountry where stc_country_c = 'USA'))
		and mov_number = @v_mov_number
 --get the port code based on the broker's company ID
 
 SELECT @v_port = SUBSTRING(cmp_altid,1,4)
 FROM	company
 WHERE	cmp_id = @v_broker
 
--insert the record into the edi_358 table
IF (SELECT ISNULL(@v_usealtSCAC,'N')) <> 'Y'
	INSERT INTO edi_358(data_col,batch_number,mov_number)
	    VALUES('1|10|'+@v_scac+'|'+@v_port+'|'+ CONVERT(varchar(8),@v_scheduled_arr,112) + '|'+
	  SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),1,2) + SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),4,2)+ '|'
		+ @p_manifest_typecode + '|' +CAST(@v_mov_number AS varchar(15)) + '|' + CASE @p_amendcode
											  WHEN 'Y' THEN '24'
											  WHEN '3' THEN '24'
											  ELSE ' '
											END  +'|',
	  @v_358ctrl,
	  @v_mov_number)
	  
ELSE --44182
	INSERT INTO edi_358(data_col,batch_number,mov_number)
	    VALUES('1|10|'+@v_altSCAC+'|'+@v_port+'|'+ CONVERT(varchar(8),@v_scheduled_arr,112) + '|'+
	  SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),1,2) + SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),4,2)+ '|'
		+ @p_manifest_typecode + '|' +CAST(@v_mov_number AS varchar(15)) + '|' + CASE @p_amendcode
											  WHEN 'Y' THEN '24'
											  WHEN '3' THEN '24'
											  ELSE ' '
											END  +'|',
	  @v_358ctrl,
	  @v_mov_number)

 
 /*PTS 32601 Create a miscellaneous type record for manifest amendment details
  Record will have a type of AMEND a qualifier that represents the amendment type A,D or M and the SCN being modified */
  
  IF @p_updatetype in ('A','D','M')
  	INSERT INTO edi_358(data_col,batch_number,mov_number)
  		VALUES('6|10|'+ CASE @p_updatetype
  					WHEN 'A' Then 'ADD'
  					WHEN 'D' Then 'DELINK'
  					WHEN 'M' Then 'MODIFY'
  				END
  			+'|' + @p_updatecode + '|' + @p_updatescn +'|',
  			@v_358ctrl,
  			@v_mov_number)
 

/* Start creation of Driver/Crew/Passenger records
	-The records will only be included on a regular-complete manifest.
	-Preliminary manifests do not include the driver and crew data*/

BEGIN

	/*SELECT @v_driver = ISNULL(ord_driver1,'UNKNOWN'),
		@v_codriver = ISNULL(ord_driver2,'UNKNOWN')
	FROM 	orderheader 
	WHERE	ord_hdrnumber = @v_ord_hdrnumber */
	
	SELECT	@v_driver = ISNULL(lgh_driver1,'UNKNOWN'),
		@v_codriver = ISNULL(lgh_driver2,'UNKNOWN')
	FROM	legheader
	WHERE	lgh_number = @v_lgh_number

	IF @v_driver <> 'UNKNOWN'
		exec edi_358_crew_record @v_driver,'EJ',@v_358ctrl,@v_mov_number

	IF @v_codriver <> 'UNKNOWN'
		exec edi_358_crew_record @v_codriver,'CRW',@v_358ctrl,@v_mov_number
	
	--look for passengers and create records here
	SELECT @v_pass_count = COUNT(*) FROM movepassenger WHERE mov_number = @v_mov_number
	SELECT @v_passenger = ' '
	WHILE @v_pass_count > 0
		BEGIN
			SELECT @v_passenger = MIN(psgr_id) 
			FROM	movepassenger
			WHERE	mov_number = @v_mov_number 
				AND psgr_id <> @v_passenger
			
			exec edi_358_crew_record @v_passenger,'QF',@v_358ctrl,@v_mov_number
			
			SELECT @v_pass_count = @v_pass_count -1
		END 	
		--passengers will be associated to an order/move in a new movepassenger association table
END



/*end driver/crew/passenger logic */


/*begin creating the conveyance detail record
	-Conveyance records will only be included in a standard complete manifest(type W)*/

BEGIN
	--get the tractor ID and create the conveyance detail record
	/*SELECT @v_tractor = ord_tractor 
	FROM	orderheader
	WHERE	ord_hdrnumber = @v_ord_hdrnumber	*/
	
	SELECT	@v_tractor = lgh_tractor
	FROM	legheader
	WHERE	lgh_number = @v_lgh_number
	
--PTS 35045 IIT indicator not applied to tractor when a trailer is associated with the trip

		IF (SELECT ISNULL(evt_trailer1,'UNKNOWN') FROM event WHERE stp_number = @v_cbp_stop) <> 'UNKNOWN'
			SET @v_trc_iit = ''
		ELSE 
			SET @v_trc_iit = @p_iit_flag			--set the IIT field for the tractor based on the existance/non-existance of a trailer on the trip.

	exec edi_358_conveyance_record @v_tractor,@v_trc_iit,@v_358ctrl,@v_mov_number

END 
	/*end conveyance detail record creation */


/*loop for each shipment that is included on the trip.  Number of shipments is determined by the number
  of drops that ocurr after the border crossing event.
  Loop will include the trailer record and */
  

/* PTS 38123 - branched insert by move for performance */
DECLARE @is_empty char(1)
SET @is_empty = 'Y'
IF (SELECT COUNT(*) FROM STOPS WHERE stops.mov_number in (SELECT mov_number FROM #movs)
	AND stp_state IN (SELECT stc_state_c FROM statecountry WHERE stc_country_c <>'USA')	AND stp_type = 'PUP') > 0
	SET @is_empty = 'N'													
													
If (select count(*) from #movs) > 1
	--insert for multiple moves
	INSERT INTO #temp_freight(fgt_number,ord_number,stp_number,stp_mfh_sequence,fgt_count,fgt_weight,fgt_volume,ord_hdrnumber,cmd_code)
		SELECT fd.fgt_number,RTRIM(st.ord_hdrnumber),st.stp_number,st.stp_mfh_sequence,fd.fgt_count,fd.fgt_weight,fd.fgt_volume,st.ord_hdrnumber,fd.cmd_code
		 FROM	freightdetail fd
				INNER JOIN stops st ON fd.stp_number = st.stp_number
				inner join #movs on st.mov_number = #movs.mov_number
				inner join statecountry on st.stp_state = stc_state_c
				LEFT OUTER JOIN commodity cm ON fd.cmd_code = cm.cmd_code
		 WHERE	stc_country_c = 'USA'
					and st.stp_type = 'DRP'
else
	--single movement
	INSERT INTO #temp_freight(fgt_number,ord_number,stp_number,stp_mfh_sequence,fgt_count,fgt_weight,fgt_volume,ord_hdrnumber,cmd_code)
		SELECT fd.fgt_number,RTRIM(st.ord_hdrnumber),st.stp_number,st.stp_mfh_sequence,fd.fgt_count,fd.fgt_weight,fd.fgt_volume,st.ord_hdrnumber,fd.cmd_code
		 FROM	freightdetail fd
				INNER JOIN stops st ON fd.stp_number = st.stp_number
				inner join statecountry on st.stp_state = stc_state_c
				LEFT OUTER JOIN commodity cm ON fd.cmd_code = cm.cmd_code
		 WHERE	stc_country_c = 'USA'
				and st.stp_type = 'DRP'
		and st.mov_number = @v_mov_number
		
/*PTS 39508 - Filter the temp table based on input mov number */
--remove any freight that is not associated with the main movement passed in
delete from #temp_freight where ord_hdrnumber NOT IN( SELECT ord_hdrnumber FROM stops WHERE stp_type ='DRP' and mov_number = @v_mov_number)
	
--remove any orders that do not originate outside the US
DELETE FROM #temp_freight WHERE ord_number NOT IN(SELECT ord_hdrnumber FROM stops 
				inner join #movs on stops.mov_number = #movs.mov_number
				inner join statecountry on stops.stp_state = stc_state_c
				 WHERE	stc_country_c <> 'USA'
						and stops.stp_type = 'PUP')
		
/* PTS 38123 - END(A) */		

--PTS 46718 Remove "empty" commodity records
DELETE FROM #temp_freight WHERE CHARINDEX(cmd_code,@cmdlist) > 0
IF(SELECT COUNT(*) FROM #temp_freight) < 1
	SELECT @is_empty ='Y'
--END 46718	

/* PTS 44679 Default the Qty based on Setting */
	IF (SELECT ISNULL(@v_usedefault,'N'))  = 'Y'
	BEGIN
		SELECT    @v_defaultQty = ISNULL(gi_integer1,1)
		FROM	  generalinfo
		WHERE	gi_name = 'ACE:DefaultManifestQty'
		
				--verify the Qty is a valid amount.  Must be at least 1
				IF @v_defaultQty < 1
					SET @v_defaultQty = 1
		
		--Update the temp table with default value
		UPDATE #temp_freight SET fgt_count = @v_defaultQty
	END
	
/* END PTS 44679 */	
		
	--PTS 34551 Add the SCAC to the ord_number column(B)
	UPDATE #temp_freight
	SET		ord_number = CASE @v_useAltSCAC
									WHEN 'Y'  THEN @v_altSCAC + ord_number		--44182
									ELSE	@v_scac + ord_number
   							     END
/*create the equipment detail record(s) */
	  /*	SELECT @v_trailer = ISNULL(lgh_primary_trailer,'UNKNOWN'),
			@v_pup =    ISNULL(lgh_primary_pup,'UNKNOWN')
		FROM	legheader   
		WHERE	lgh_number = @v_lgh_number		*/

		/* Get the trailer #'s from the event instead of the legheader */
		SELECT @v_trailer = ISNULL(evt_trailer1,'UNKNOWN'),
			@v_pup = 	ISNULL(evt_trailer2,'UNKNOWN')
		FROM	event
		WHERE	stp_number = @v_cbp_stop		


		IF @v_trailer <> 'UNKNOWN'
			IF @is_empty = 'Y'
			--Output for empty trips into US.
				EXEC edi_358_equipment_record @v_trailer,@p_iit_flag,'N','','',@v_358ctrl,@v_mov_number
			ELSE	
			BEGIN	
				SELECT @v_totalweight = ISNULL(SUM(fgt_weight),0) FROM #temp_freight
			
				IF @v_pup = 'UNKNOWN' and @v_swapweight <>'Y'
					SELECT @p_trl1_count = SUM(fgt_count),@p_trl1_wgt = SUM(fgt_weight) FROM #temp_freight-- WHERE stp_number = @v_stpnum			 

				IF @v_pup = 'UNKNOWN' and @v_swapweight = 'Y'
					IF @v_totalweight > 0
						SELECT @p_trl1_count = SUM(fgt_count),@p_trl1_wgt = SUM(fgt_weight) FROM #temp_freight-- WHERE stp_number = @v_stpnum			 
					ELSE
						SELECT @p_trl1_count = SUM(fgt_count),@p_trl1_wgt = SUM(fgt_volume) FROM #temp_freight-- WHERE stp_number = @v_stpnum			 
				
					exec edi_358_equipment_record @v_trailer,@p_iit_flag,'N',@p_trl1_wgt,@p_trl1_count,@v_358ctrl,@v_mov_number
			END
		
		/* update the temp table with any freight detail level shipment control numbers (C)*/
		UPDATE #temp_freight
		SET	ord_number = CASE @v_useAltSCAC					--44182
								WHEN 'Y' THEN @v_altSCAC + r.ref_number
								ELSE	@v_scac + r.ref_number
							    END
		FROM	referencenumber r
			JOIN labelfile l
				ON l.abbr= r.ref_type
		WHERE	r.ref_table = 'freightdetail'
			AND r.ref_tablekey = fgt_number
			AND l.edicode = 'SCN'	
			
			/*begin mod */
			
		SELECT @v_curr_ord =  MIN(ord_hdrnumber) FROM #temp_freight
		WHILE @v_curr_ord IS NOT NULL	
			BEGIN/*1*/
			
				IF (SELECT COUNT(DISTINCT(stp_number)) FROM #temp_freight WHERE ord_hdrnumber =  @v_curr_ord AND( ord_number =  (@v_scac + CONVERT(varchar(12),ord_hdrnumber)) OR ord_number = (@v_altSCAC + CONVERT(varchar(12),ord_hdrnumber)))) > 1
				BEGIN /*2*/
					SET @v_loop_counter2 = ISNULL((SELECT COUNT(DISTINCT(stp_number)) FROM #temp_freight where ord_hdrnumber = @v_curr_ord ),0)
					SET @v_char = 65	--alpha character incremented value
					SET @v_drpcount = 1



					--SELECT @v_fgt_num = MIN(fgt_number) FROM #temp_freight WHERE stp_number = @v_stpnum
					SELECT @v_stpnum =  stp_number,
							  @v_stpseq = stp_mfh_sequence 	--get the first drop stop number and sequence
					FROM	#temp_freight
					WHERE	stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM #temp_freight WHERE ord_hdrnumber = @v_curr_ord)

				WHILE @v_loop_counter2 > 0 AND @v_drpcount <= @v_loop_counter2
				BEGIN/*3*/
				--stops loop
					UPDATE #temp_freight
					SET	   ord_number = ord_number + CHAR(@v_char)
					WHERE stp_number = @v_stpnum
							AND ord_number = @v_scac + @v_curr_ord
							
					SET @v_char = @v_char + 1
					SET @v_drpcount =  @v_drpcount + 1
					
				         SELECT @v_stpseq = MIN(stp_mfh_sequence)
					  FROM #temp_freight
					  WHERE stp_mfh_sequence > @v_stpseq
											 
					--Get next Stop number
  					 SELECT @v_stpnum = MIN(stp_number) FROM #temp_freight WHERE stp_mfh_sequence = @v_stpseq
  				END/*3*/	 
			END /*2*/	
				SET @v_last_ord = @v_curr_ord
				SELECT @v_curr_ord =  MIN(ord_hdrnumber) FROM #temp_freight WHERE ord_hdrnumber  > @v_last_ord
		END/*1*/		
	
			SELECT @v_trl_number = trl_number FROM trailerprofile WHERE trl_id = @v_trailer
			
			--IF @v_preliminary =  'N'	--PTS32601 only add 5 record for associated trips
			
			SELECT @v_output_scn =  MIN(ord_number) FROM #temp_freight
			WHILE @v_output_scn IS NOT NULL
				BEGIN
					SELECT @p_trl1_count = SUM(fgt_count) FROM #temp_freight WHERE ord_number = @v_output_scn 
						IF @is_empty = 'N'
						INSERT INTO edi_358(data_col,batch_number,mov_number)
							VALUES('5|10|'+@v_trl_number +'|' + @v_output_scn +'|' + CAST(@p_trl1_count as varchar(10)) +'|',@v_358ctrl,@v_mov_number)
							
					SELECT @v_output_scn = MIN(ord_number) FROm #temp_freight WHERE ord_number >  @v_output_scn
					
				END		
		
		
			IF @v_pup <> 'UNKNOWN'
				IF @is_empty = 'Y'
					exec edi_358_equipment_record @v_pup,@p_iit_flag,'Y','','',@v_358ctrl,@v_mov_number
				ELSE
					BEGIN
						exec edi_358_equipment_record @v_pup,@p_iit_flag,'Y',@p_trl2_wgt,@p_trl2_count,@v_358ctrl,@v_mov_number

						SELECT @v_trl_number = trl_number from trailerprofile WHERE trl_id = @v_pup

						--IF @v_preliminary =  'N'	--PTS32601 only add 5 record for associated trips	
						IF @is_empty = 'N'
						INSERT INTO edi_358(data_col,batch_number,mov_number)
							VALUES('5|10|'+@v_trl_number +'|' + @v_SCN +'|' + CAST(@p_trl2_count as varchar(10))+'|',@v_358ctrl,@v_mov_number)
					END			
	


/* end of equipment record creation */	




/* create a trailer record */
SELECT @v_reccount = Count(*)  FROM edi_358 WHERE batch_number = @v_358ctrl

SET @v_reccount = @v_reccount - 1

INSERT INTO edi_358(data_col,batch_number,mov_number)
	VALUES('#EOT '+ CAST(@v_358ctrl as varchar(10)) + ' ' + CAST(@v_reccount as varchar(10)) + ' ',@v_358ctrl,@v_mov_number)
	
	
/*end trailer */

/* AJR PTS 34041 - Add update to lgh_ace_status */
UPDATE legheader
SET	lgh_ace_status = '358XFR'
WHERE	mov_number = @v_mov_number --lgh_number = @v_lgh_number  PTS35457

GO
GRANT EXECUTE ON  [dbo].[edi_358_manifest_header] TO [public]
GO
