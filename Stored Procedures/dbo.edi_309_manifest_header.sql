SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

	CREATE PROCEDURE [dbo].[edi_309_manifest_header] @p_ord_number varchar(13),@p_manifest_typecode char(2), @p_iit_flag char(1),
						 @p_trl1_wgt int,@p_trl2_wgt int = Null,@p_trl1_count int,@p_trl2_count  int = Null,
						 @p_importer varchar(8) = 'UNKNOWN',@p_updatetype varchar(8) = null,@p_updatecode varchar(6) = null,@p_updatescn varchar(16) = null,
						 @p_mov_number int
	/**
	 * 
	 * NAME:
	 * dbo.edi_309_manifest_header
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
	 * 003 - @p_ntb_table varchar(18), input, null;
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
	 * 05/05/2006.03 - PTS 32601 - A.Rossman - Specify 'SYSTEM' as the trip number for preliminary 309 documents instead
	 *				of the move number.
	 * 07/06/2006.04 - PTS 33469 - Add SCN assignment at the freight level capability.
	 * 08/23/2006.05 - PTS 34110 - Add Customs Broker "CB" company record.  Handle freight records for in-bond moves where there are no US drops on the trip. Update lgh_ace_status on creation of file.
	 * 09/19/2006.06 - PTS 34551 - Correct assignment of alpha characters to the SCN for multi-drop/multi commodity orders.
	 *11/07/2006.07 - PTS 35045 - IIT indocator should only be applied to the conveyance OR the equipment.  Never both.
	 * 05/11/2007.08 - PTS 34784 - Allow for designation of the ACE Shipper for a given shipment via a reference attached to the freightdetail of type ACESH
	 * 05/23/2007.09 -PTS 34784 - Add new parm for move number to be passed into the proc for more accurate data retrieval.
	 * 06/28/2007.10 -PTS 38123 -  Add orderheader number to the temp freight table to get shipper information
	 *				-PTS 38123 - Added branch selects for #temp_freight for one move and > one move for performance.
	 * 09/21/2007.11 - PTS 39508 - Filtered available shipment data based on current ACE movement data.
	 * 08/28/2008.12 - PTS 44182 - Added support for new alternate scac setting at shipment/freight level.
	 * 01/09/2009.13 - PTS 45638 - Swap volume for weight when value is zero.
	 **/

	 AS

	 DECLARE @v_309ctrl	int,		--control  number for the 309 document
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
		 @v_loop_counter	int,
		 @v_fgt_num	int,
		 @v_ord_number	varchar(16),
		 @v_reccount	int,
		 @v_lgh_number	int,
		 @v_pass_count	int,
		 @v_passenger	varchar(8),
		 @v_amendment	varchar(2),
		 @v_SCN		varchar(16),
		 @v_drpcount	int,
		 @v_loop_counter2	int,
		 @v_char	int,
		 @v_stpnum	int,
		 @v_usealpha	char(1),
		 @v_trlcount	int,
		 @v_receiverid	varchar(24),
		 @v_curr_ord	varchar(16),
		 @v_last_ord	varchar(16),
		 @v_stpseq	int,
		 @v_cbp_stop	int,
		 @v_filerno	varchar(9),
		 @v_brokerName	varchar(60),
		 @v_trc_iit	char(1),
		 @temp_shipper varchar(8),	--37484
		 @v_currordhdr int,	--38123
		 @v_useAltScac char(1),
		 @v_altSCAC	varchar(4),		--44182
		@v_altSCACRevtype	varchar(8),
		@v_totalweight int,		--45638
		@v_swapweight char(1)	--45638
		
	--declare a temp table for the freight info
	CREATE TABLE #temp_freight 
	(	record_id	int identity(1,1) NOT NULL,
		fgt_number	int NULL,
		ord_number	varchar(16) NULL,
		stp_number	int	NULL,
		stp_mfh_sequence	int NULL,
		fgt_count	int	 NULL,
		fgt_weight	int	NULL,
		fgt_volume int NULL,		--45638 added col.
		ord_hdrnumber int NULL			--PT 38123 Added column
	)

--PTS38123 add temp table for moves.
create table #movs (mov_number int)

--insert move data
insert #movs 
select stops.mov_number from stops inner join stops stops2 on stops.ord_hdrnumber = stops2.ord_hdrnumber
where stops2.mov_number = @p_mov_number and stops2.ord_hdrnumber > 0
group by stops.mov_number

--end 38123


	 --determine if this is an amendment or delete manifest
	 SELECT @v_amendment = CASE @p_manifest_typecode
					WHEN 'W' Then ' '
					WHEN 'P' Then ' '
					WHEN '3' Then '03'
					WHEN 'Y' Then '03'
					WHEN 'YP' Then ''			--PTS 36896 No code needed for preliminary updates
					Else ' '
				END	

	--PTS 36896; condotion the manifest Typecode
	SELECT @p_manifest_typecode = LEFT(@p_manifest_typecode,1)
	
	 /* PTS32601 Condition the IIT indicator to not display when equal to 'N' */

	 SELECT @p_iit_flag = CASE @p_iit_flag
				WHEN 'N' THEN ' '
				ELSE @p_iit_flag
			      END	

	 /*PTS 32515 AROSS; Get the receiver ID from the generalinfo table */
	 SELECT	@v_receiverid = UPPER(ISNULL(gi_string1,'CBP-ACE-TEST'))
	 FROM	generalinfo
	 WHERE	gi_name = 'ACE:ReceiverID'

		IF @v_receiverid <> 'CBP-ACE' AND @v_receiverid <> 'CBP-ACE-TEST'
			SET @v_receiverid = 'CBP-ACE-TEST'

	/*end PTS 32515 */ 		
	
		 --PTS 45638 Aross
		 SELECT	@v_swapweight = LEFT(UPPER(ISNULL(gi_string1,'N')),1)
		 FROM		generalinfo
	 WHERE	gi_name = 'ACE:ApplyVolumeforZeroWeight'


	--get the  control number for the 309 document
	EXEC @v_309ctrl = getsystemnumber 'EDI309',''

	SELECT @v_mov_number = @p_mov_number,			--PTS 37484 Aross; change move parm to passed in value.
	       		   @v_ord_hdrnumber = ord_hdrnumber
	FROM 		orderheader 
	WHERE 	ord_number = @p_ord_number


	--Get the legheader for the first border crossing event
	SELECT 	@v_lgh_number = lgh_number,
				@v_cbp_stop   = stp_number
	FROM	stops
	WHERE	mov_number = @v_mov_number
		AND stp_event in ('BCST','NBCST')
		and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number AND stp_event in ('BCST','NBCST')
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

	--insert the header record into the edi_309 table
	INSERT INTO edi_309(data_col,batch_number,mov_number)
	    VALUES('#TMW309 FROM ' +@v_scac+' TO '+@v_receiverid+' ' +@v_formatdate+' '+@v_formattime+' '+CAST(@v_309ctrl AS varchar(8)),
	@v_309ctrl,
	@v_mov_number)


	/*Begin creation of the manifest header #1 record */

	--determine the broker company id in order to get the port code also get the scheduled arrival date and time
	SELECT	 @v_broker =  cmp_id ,		--broker
		 @v_scheduled_arr = CASE stp_schdtearliest  
					WHEN '1/1/1950 00:00' Then stp_arrivaldate
					ELSE stp_schdtearliest
				    END
	FROM	 stops 
	WHERE	 stp_number = @v_cbp_stop
	/*WHERE	 stp_event in ('BCST','NBCST')   	***Use the cbp stop number to get the broker***
			and stp_sequence = (SELECT MIN(stp_sequence) FROM stops	WHERE mov_number = @v_mov_number AND stp_event in('BCST','NBCST'))
			and mov_number = @v_mov_number */
	 --get the port code based on the broker's company ID

	 SELECT @v_port = SUBSTRING(cmp_altid,1,4),
		@v_filerno = ISNULL(SUBSTRING(cmp_aceid,1,9),' '),
		@v_brokerName = ISNULL(cmp_name,' ')
	 FROM	company
	 WHERE	cmp_id = @v_broker

	--insert the 1 record into the edi_309 table
	IF (SELECT ISNULL(@v_useAltSCAC,'N')) <> 'Y'
		INSERT INTO edi_309(data_col,batch_number,mov_number)
		    VALUES('1|10|'+@v_scac+'|'+@v_port+'|'+ CONVERT(varchar(8),@v_scheduled_arr,112) + '|'+
		  SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),1,2) + SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),4,2)+ '|'+ RTRIM(@p_manifest_typecode) + '|' +CAST(@v_mov_number AS varchar(15))+'|'+ @v_amendment + '|',
		  @v_309ctrl,
		  @v_mov_number)
	
	ELSE	--PTS 44182 use alternate scac for 1 and 6 records
		INSERT INTO edi_309(data_col,batch_number,mov_number)
		    VALUES('1|10|'+@v_altSCAC+'|'+@v_port+'|'+ CONVERT(varchar(8),@v_scheduled_arr,112) + '|'+
		  SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),1,2) + SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),4,2)+ '|'+ RTRIM(@p_manifest_typecode) + '|' +CAST(@v_mov_number AS varchar(15))+'|'+ @v_amendment + '|',
		  @v_309ctrl,
		  @v_mov_number)


	 /*In a multi-drop order situation the shipment control number must be unique for each drop.  Customs will not accept multi-drop orders
	 under a single shipment control.  In this case the shipment control number will be the SCAC + order number + 
	 incrementing alpha character A,B,C etc... 
	 since the driver and tractor information does not change the company,trailer and freight logic will follow.*/


	 /* Start creation of Driver/Crew/Passenger records
		-The records will only be included on a regular-complete manifest.
		-Preliminary manifests do not include the driver and crew data*/
	 IF @p_manifest_typecode in('W','Y','3')
	 BEGIN

		/*SELECT @v_driver = ISNULL(ord_driver1,'UNKNOWN'),
			@v_codriver = ISNULL(ord_driver2,'UNKNOWN')
		FROM 	orderheader 
		WHERE	ord_hdrnumber = @v_ord_hdrnumber	*/

		SELECT @v_driver = ISNULL(lgh_driver1,'UNKNOWN'),
			@v_codriver = ISNULL(lgh_driver2,'UNKNOWN')
		FROM	legheader
		WHERE	lgh_number = @v_lgh_number

		IF @v_driver <> 'UNKNOWN'
			exec edi_309_crew_record @v_driver,'EJ',@v_309ctrl,@v_mov_number

		IF @v_codriver <> 'UNKNOWN'
			exec edi_309_crew_record @v_codriver,'CRW',@v_309ctrl,@v_mov_number

		--look for passengers and create records here
		SELECT @v_pass_count = COUNT(*) FROM movepassenger WHERE mov_number = @v_mov_number
		SELECT @v_passenger = ' '
		WHILE @v_pass_count > 0
			BEGIN
				SELECT @v_passenger = MIN(psgr_id) 
				FROM	movepassenger
				WHERE	mov_number = @v_mov_number 
					AND psgr_id <> @v_passenger

				exec edi_309_crew_record @v_passenger,'QF',@v_309ctrl,@v_mov_number

				SELECT @v_pass_count = @v_pass_count -1
			END 	
			--passengers will be associated to an order/move in a new movepassenger association table
	 END



	 /*end driver/crew/passenger logic */


	 /*begin creating the conveyance detail record
		-Conveyance records will only be included in a standard complete manifest(type W)*/
	 IF @p_manifest_typecode in ('W','Y','3')
	 BEGIN
		--get the tractor ID and create the conveyance detail record
		/*SELECT @v_tractor = ord_tractor 
		FROM	orderheader
		WHERE	ord_hdrnumber = @v_ord_hdrnumber		*/

		SELECT @v_tractor = ISNULL(lgh_tractor,'UNKNOWN')
		FROM	legheader
		WHERE	lgh_number = @v_lgh_number

		IF (SELECT ISNULL(evt_trailer1,'UNKNOWN') FROM event WHERE stp_number = @v_cbp_stop) <> 'UNKNOWN'
			SET @v_trc_iit = ''
		ELSE 
			SET @v_trc_iit = @p_iit_flag			--set the IIT field for the tractor based on the existance/non-existance of a trailer on the trip.

		IF @v_tractor <> 'UNKNOWN'
		exec edi_309_conveyance_record @v_tractor,@v_trc_iit,@v_309ctrl,@v_mov_number

	 END 
		/*end conveyance detail record creation */

	--PTS 38123 Branched select statements for single and multiple move loads
	/* Begin Mod */
	If (select count(*) from #movs) > 1	--multi move loads
	
		INSERT INTO #temp_freight(fgt_number,ord_number,stp_number,stp_mfh_sequence,fgt_count,fgt_weight,fgt_volume,ord_hdrnumber)
		SELECT 	fd.fgt_number,
			st.ord_hdrnumber,
			st.stp_number,
			st.stp_mfh_sequence,
			 fd.fgt_count,
		 	fd.fgt_weight,
		 	fd.fgt_volume,	--45638 added volume
	 		st.ord_hdrnumber			-- pts 38123 added to insert 
	 	 FROM	freightdetail fd
				INNER JOIN stops st ON fd.stp_number = st.stp_number
				inner join #movs on st.mov_number = #movs.mov_number
				inner join statecountry on st.stp_state = stc_state_c
				LEFT OUTER JOIN commodity cm ON fd.cmd_code = cm.cmd_code
		 WHERE	stc_country_c = 'USA'
						and st.stp_type = 'DRP'
	else
		--single move
		INSERT INTO #temp_freight(fgt_number,ord_number,stp_number,stp_mfh_sequence,fgt_count,fgt_weight,fgt_volume,ord_hdrnumber)
		SELECT 	fd.fgt_number,
			st.ord_hdrnumber,
			st.stp_number,
			st.stp_mfh_sequence,
			 fd.fgt_count,
			fd.fgt_weight,
			fd.fgt_volume,			--45638 added volume
			st.ord_hdrnumber			-- pts 38123 added to insert 
		 FROM	freightdetail fd
				INNER JOIN stops st ON fd.stp_number = st.stp_number
				inner join statecountry on st.stp_state = stc_state_c
				LEFT OUTER JOIN commodity cm ON fd.cmd_code = cm.cmd_code
		 WHERE	stc_country_c = 'USA'
				and st.stp_type = 'DRP'
				and st.mov_number = @v_mov_number	
	
	
	/*end mod*/
	
	/*PTS 39508 - Filter the shipment data based on the current movement. */
	--remove any freight that is not associated with the main movement passed in
	delete from #temp_freight where ord_hdrnumber NOT IN( SELECT ord_hdrnumber FROM stops WHERE stp_type ='DRP' and mov_number = @v_mov_number)
		
	--remove any orders that do not originate outside the US
	DELETE FROM #temp_freight WHERE ord_number NOT IN(SELECT ord_hdrnumber FROM stops 
					inner join #movs on stops.mov_number = #movs.mov_number
					inner join statecountry on stops.stp_state = stc_state_c
					 WHERE	stc_country_c <> 'USA'
						and stops.stp_type = 'PUP')
	


	/* AJR PTS 34110 - Add check for inbond moves with no US stops.  */
	 IF (SELECT COUNT(*) FROM #temp_freight )= 0  AND  (SELECT Count(*) FROM stops WHERE mov_number = @v_mov_number and stp_event in ('BCST','NBCST'))> 1
	 BEGIN
		IF (SELECT COUNT(*) FROM stops WHERE stp_type = 'DRP' and stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number and stp_event in ('BCST','NBCST'))) > 0
		    BEGIN
			--If we detect an inbond move add the freight records that are not already included.(Adds CA freight for TE or possibly IT  type inbonds
			INSERT INTO #temp_freight(fgt_number,ord_number,stp_number,stp_mfh_sequence,fgt_count,fgt_weight,fgt_volume,ord_hdrnumber)
				SELECT f.fgt_number,RTRIM(o.ord_number),s.stp_number,s.stp_mfh_sequence,f.fgt_count,f.fgt_weight,f.fgt_volume,s.ord_hdrnumber
				FROM freightdetail f
					INNER JOIN stops s
						ON s.stp_number =  f.stp_number
					INNER JOIN orderheader o
						ON s.mov_number = o.mov_number
				WHERE	s.mov_number = @v_mov_number
					AND s.stp_type = 'DRP'
					AND stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number and stp_event in ('BCST','NBCST'))
					AND s.ord_hdrnumber = o.ord_hdrnumber
					AND f.fgt_number NOT IN(SELECT DISTINCT(fgt_number) FROM #temp_freight)


		     END
	END  --PTS 34110		



	     SET @v_loop_counter = ISNULL((SELECT COUNT(DISTINCT(stp_number)) FROM #temp_freight),0)

	     SET @v_drpcount = 1
	     SET @v_char = 65	--alpha character incremented value

		/*IF @v_loop_counter > 1		--only use the alpha character when there are multiple shipments.
			SET @v_usealpha = 'Y'
		ELSE
			SET @v_usealpha = 'N' */

	SELECT @v_stpnum =  stp_number,	--get the first drop stop number
		@v_stpseq = stp_mfh_sequence
	FROM	#temp_freight
	WHERE	stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM #temp_freight)

	WHILE @v_loop_counter > 0 and @v_drpcount <= @v_loop_counter
	BEGIN /*shipment control loop */

		 /*Start creating the company or 2 records 
			Note: At a minimum the shipper and consignee records are required
				-other possibilities include IM - Importer; IC - Intermediate Consignee;CB - Customs broker*/

		/* Only use alpha characters when there are multiple drops for the same order */
		SELECT @v_curr_ord = ord_number ,
				  @v_currordhdr = ord_hdrnumber
		FROM	#temp_freight
		WHERE	stp_number = @v_stpnum

		IF @v_curr_ord <> @v_last_ord		--reset the alpha character if this is a new order
			SET @v_char = 65

		IF (SELECT COUNT(*) FROM #temp_freight WHERE ord_number = @v_curr_ord) > 1 AND (SELECT COUNT(DISTINCT(stp_number)) FROM #temp_freight WHERE ord_number = @v_curr_ord) > 1
			SET @v_usealpha = 'Y'
		ELSE
			SET @v_usealpha = 'N'

		/*PTS 34110 Add a company record for the broker if the download is enabled from the company profile */

		IF @v_filerno <> ' '
			INSERT INTO edi_309(data_col,batch_number,mov_number)
				VALUES('2|10|CB|'+@v_brokerName+'|||||||||||',@v_309ctrl,  @v_mov_number)

		/*END PTS 34110 */			


		--Determine the shipper ID
	/*	SELECT 	@v_shipper = cmp_id 
		FROM 	stops
		WHERE	mov_number = @v_mov_number
			AND stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number =@v_mov_number AND stp_type = 'PUP') */
			
			SELECT @v_shipper = cmp_id
			FROM	stops
			WHERE	ord_hdrnumber = @v_currordhdr --@v_ord_hdrnumber
				AND stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE ord_hdrnumber =@v_currordhdr AND stp_type = 'PUP') 
				AND stp_type= 'PUP' 	--PTS 37484 added restriction for stop type
				

		--generate the shipper company record
		--Moved to freight section below
		--exec edi_309_company_record @v_shipper,'SH',@v_309ctrl,@v_mov_number

		 --determine the consignee for the trip and generate the consignee company record

		 SELECT	@v_consignee  = cmp_id
		 FROM	stops
		 WHERE	stp_number = @v_stpnum

		 --generate the consignee record for this shipment  
		 --moved creation of company record to the freight section below
		--exec edi_309_company_record @v_consignee,'CN',@v_309ctrl,@v_mov_number 


		--loop for additional company records to be added here
		--The importer company name will be passed from the interface when needed.
		IF (SELECT ISNULL(@p_importer,'UNKNOWN')) <> 'UNKNOWN'
		    exec edi_309_company_record @p_importer,'IM',@v_309ctrl,@v_mov_number


		/* End creating company records */





		/*begin creation of freight detail records 
			all the freight records for drops ocuring after the customs event are counted and a record is created for each */

		--get the SCN from the reference number table if necessary
		SELECT @v_SCN =  MAX(ref_number)
		FROM	referencenumber r
			JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	r.ref_table = 'orderheader'
			AND r.ref_tablekey = @v_currordhdr--@v_ord_hdrnumber
			AND l.edicode = 'SCN'


		/*Change SCN to ordernumber from temp_freight table */
		SELECT @v_SCN = ISNULL(@v_SCN,ord_number)
		FROM	#temp_freight
		WHERE	stp_number = @v_stpnum				

		IF @v_usealpha = 'Y' 
		 SET @v_SCN =  @v_SCN + CHAR(@v_char)

		--get the number of freight details for the stop
		SELECT @v_loop_counter2 =  Count(fgt_number) FROM #temp_freight WHERE stp_number = @v_stpnum
		SET @v_fgt_recs = 1
		SET @v_fgt_num = 0

		     WHILE @v_loop_counter2 > 0 AND @v_fgt_recs <= @v_loop_counter2
			BEGIN
				SELECT @v_fgt_num = MIN(fgt_number)
				FROM	#temp_freight
				WHERE	stp_number = @v_stpnum
					AND fgt_number > @v_fgt_num


			/*Add logic to check for a shipment control number attached at the freight level here 
			  if the number exists update the @v_SCN variable to the new Shipment control number and set use alpha to N */
				IF (SELECT COUNT(*) FROM referencenumber r JOIN labelfile l ON l.abbr = r.ref_type
				    WHERE r.ref_table = 'freightdetail' AND r.ref_tablekey = @v_fgt_num AND l.edicode = 'SCN') > 0
				    BEGIN
					SELECT @v_SCN =  MAX(ref_number)
					FROM	referencenumber r
						JOIN labelfile l
							ON l.abbr = r.ref_type
					WHERE	r.ref_table = 'freightdetail'
						AND r.ref_tablekey = @v_fgt_num
						AND l.edicode = 'SCN'


				    END

				--IF LEFT(@v_SCN,4) <> @v_scac AND LEFT(@v_SCN,4) <> @v_altSCAC
				--SELECT @v_SCN = @v_scac + @v_SCN
				IF (SELECT CHARINDEX(@v_scac,@v_SCN)) < 1 AND (SELECT CHARINDEX(ISNULL(@v_altscac,'xxxx'),@v_SCN)) < 1
				BEGIN
					SELECT @v_SCN = CASE @v_useAltSCAC
										WHEN 'N' THEN @v_scac + @v_SCN
										WHEN 'Y' THEN @v_altSCAC + @v_SCN
										ELSE	@v_scac + @v_SCN
									  END
				END									  
				/* Look for ACE Shipper attached to the freightdetail record.  If exists pass that value in as the shipper */
				IF(SELECT COUNT(*) FROM referencenumber r JOIN labelfile l ON l.abbr = r.ref_type
				   WHERE r.ref_table = 'freightdetail' AND r.ref_tablekey = @v_fgt_num AND l.edicode = 'ACESH') > 0
				   BEGIN
				   	SELECT 	@temp_shipper = MAX(ref_number)
				   	FROM	referencenumber r
				   		JOIN labelfile l
				   			ON l.abbr = r.ref_type
				   	WHERE	r.ref_table = 'freightdetail'		
				   		AND r.ref_tablekey = @v_fgt_num
				   		AND l.edicode = 'ACESH'
				   		
				   	--generate new shipper and consignee records for this freight
				   		exec edi_309_company_record @temp_shipper,'SH',@v_309ctrl,@v_mov_number
				   			
				   			--PTS 37484 for schedule K code city identification
				   			SET @v_shipper = @temp_shipper	
				   			
				   		--consignee will still be the same based on the stop information
				   		exec edi_309_company_record @v_consignee,'CN',@v_309ctrl,@v_mov_number 
				   		
				   END
				ELSE	--use the defaulted company values PTS34784
					BEGIN
						exec edi_309_company_record @v_shipper,'SH',@v_309ctrl,@v_mov_number

						exec edi_309_company_record @v_consignee,'CN',@v_309ctrl,@v_mov_number 

					END	
				
				--Moved Down as part of PTS34784
				--loop for additional company records to be added here
				--The importer company name will be passed from the interface when needed.
				IF (SELECT ISNULL(@p_importer,'UNKNOWN')) <> 'UNKNOWN'
				    exec edi_309_company_record @p_importer,'IM',@v_309ctrl,@v_mov_number


				exec edi_309_freight_record @v_SCN,@v_fgt_num,@v_309ctrl,@v_mov_number,@v_cbp_stop,@v_shipper


				 /*PTS 32601 Create a miscellaneous type record for manifest amendment details
				  Record will have a type of AMEND a qualifier that represents the amendment type A,D or M and the SCN being modified */

				  IF @p_updatetype in ('A','D','M') AND @v_SCN = @p_updatescn
					INSERT INTO edi_309(data_col,batch_number,mov_number)
						VALUES('7|10|'+ CASE @p_updatetype
									WHEN 'A' Then 'ADD'
									WHEN 'D' Then 'DELETE'
									WHEN 'M' Then 'MODIFY'
								END
							+'|' + @p_updatecode + '|' + @p_updatescn +'|',
							@v_309ctrl,
							@v_mov_number)


				SET @v_fgt_recs = @v_fgt_recs + 1
			END

			SET @v_char = @v_char + 1
			SET @v_drpcount = @v_drpcount + 1

			SET @v_last_ord = @v_curr_ord

			/*SELECT @v_stpnum = MIN(stp_number),
				@v_stpseq = MIN(stp_mfh_sequence)
			FROM	#temp_freight
			WHERE	stp_mfh_sequence > @v_stpseq		*/
			
			SELECT @v_stpseq = MIN(stp_mfh_sequence)
			  FROM #temp_freight
			  WHERE stp_mfh_sequence > @v_stpseq
			 
			 --Get next Stop number
  			 SELECT @v_stpnum = MIN(stp_number) FROM #temp_freight WHERE stp_mfh_sequence = @v_stpseq
	


	 END	
		/* end freight record creation */     	

	/*create the equipment detail record(s) 
		- the trailer record will display as NO NUMBER for preliminary manifests*/
	IF @p_manifest_typecode in ('W','Y','3')
	BEGIN


		/* SELECT @v_trailer = ISNULL(lgh_primary_trailer,'UNKNOWN'),
			@v_pup = ISNULL(lgh_primary_pup,'UNKNOWN')
		FROM	legheader
		WHERE	lgh_number = @v_lgh_number	*/

		SELECT @v_trailer = ISNULL(evt_trailer1,'UNKNOWN'),
			@v_pup = ISNULL(evt_trailer2,'UNKNOWN')
		FROM	event
		WHERE	stp_number = @v_cbp_stop	
		
		SELECT @v_totalweight =  ISNULL(SUM(fgt_weight),0) FROM #temp_freight

		IF @v_pup = 'UNKNOWN' and @v_swapweight <> 'Y'   --45638
			SELECT @p_trl1_count = SUM(fgt_count),@p_trl1_wgt = SUM(fgt_weight) FROM #temp_freight --WHERE stp_number = @v_stpnum
		
		IF @v_pup = 'UNKNOWN' and @v_swapweight = 'Y'		--45638
			IF @v_totalweight <= 0
				SELECT @p_trl1_count = SUM(fgt_count),@p_trl1_wgt = SUM(fgt_volume) FROM #temp_freight --WHERE stp_number = @v_stpnum
			ELSE
				SELECT @p_trl1_count = SUM(fgt_count),@p_trl1_wgt = SUM(fgt_weight) FROM #temp_freight --WHERE stp_number = @v_stpnum
				
			
		IF @v_trailer <> 'UNKNOWN'
			exec edi_309_equipment_record @v_trailer,@p_iit_flag,'N',@p_trl1_wgt,@p_trl1_count,@v_309ctrl,@v_mov_number

		IF @v_pup <> 'UNKNOWN'
			exec edi_309_equipment_record @v_pup,@p_iit_flag,'Y',@p_trl2_wgt,@p_trl2_count,@v_309ctrl,@v_mov_number
	END
	ELSE	--This is a preliminary manifest
	BEGIN
		INSERT INTO edi_309(data_col,batch_number,mov_number)
			VALUES('5|10|NO NUMBER|||NC|||||||||||',@v_309ctrl,@v_mov_number)
	END		

	/* end of equipment record creation */	




	/* create a trailer record */
	SELECT @v_reccount = Count(*)  FROM edi_309 WHERE batch_number = @v_309ctrl

	SET @v_reccount = @v_reccount - 1

	INSERT INTO edi_309(data_col,batch_number,mov_number)
		VALUES('#EOT '+ CAST(@v_309ctrl as varchar(10)) + ' ' + CAST(@v_reccount as varchar(10)) + ' ',@v_309ctrl,@v_mov_number)


	/*end trailer */

	/* Add Update to lgh_ace_status.  Set Status to 309 Created(309XFR)  PTS34110 AJR */

	UPDATE legheader
	SET	lgh_ace_status = '309XFR'
	WHERE	mov_number = @v_mov_number  --lgh_number = @v_lgh_number

GO
GRANT EXECUTE ON  [dbo].[edi_309_manifest_header] TO [public]
GO
