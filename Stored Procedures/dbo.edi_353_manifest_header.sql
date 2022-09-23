SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_353_manifest_header] @p_ord_number varchar(13),@p_manifest_typecode char(1),@p_notification_type char(1),@p_inbond_scn varchar(16) = null
/**
 * 
 * NAME:
 * dbo.edi_353_manifest_header
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This procedure creates an edi 353 message
 *
 * RETURNS:
 * A return value of zero indicates success. A non-zero return value
 * indicates a failure of some type
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_ord_number varchar(13) input; represents the order being processed.,
 * 002 - @p_manifest_typecode char(1) input not null - manifest type being sent to USCBP, Z or H
 * 003 - @p_notification_type char(1) input not null - notification type. 1,2 or 3 for in-bond Z for end of manifest
 *
 * REFERENCES:
 * 001 - dbo.
 * 
 * REVISION HISTORY:
 * 02/24/2006.01 - A.Rossman - Initial release.
 * 04/10/2006.02 - PTS 32515 - A.Rossman - Updated to get receiver ID from GI setting ACE:ReceiverID. Also removed pipe
 *			delimiters from header and trailer records.
 * 05/25/2006.03 - PTS 32601 - A. Rossman - Corrected for inbond movement arrival data.
 * 08/17/2006.04 - PTS 34041 - A. Rossman - Update to Legheader status when 353 created.
 * 12/13/2006.05 - PTS 35457 - A. Rossman - Fix to legheader update.  update all legs for an ACE move.
 * 08/01/2007.06 - PTS 38675 - A. Rossman - Do not include BM or IB reference when arriving inbond by shipment or inbond control number
 * 08/28/2008.07 - PTS 44182 - A.Rossman - Added support for alternat SCAC setting.
 *
 *
 **/
 
 AS
 
 DECLARE @v_353ctrl	int,	--control  number for the 353 document
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
 	 @v_trailer	varchar(13),
 	 @v_ord_number	varchar(13),
 	 @v_reccount	int,
 	 @v_lgh_number	int,
 	 @v_SCN		varchar(15),
 	 @v_reftype	varchar(6),
 	 @v_refnum	varchar(30),
 	 @v_inbond_number varchar(30),
 	 @v_message	varchar(30),
 	 @v_receiverid	varchar(24),
 	 @v_us_port	varchar(4),
 	 @v_useAltScac char(1),
	 @v_altSCAC	varchar(4),		--44182
	@v_altSCACRevtype	varchar(8)
 	 
 	 
 	 

 
--get the  control number for the 353 document
EXEC @v_353ctrl = getsystemnumber 'EDI353',''

IF UPPER(LEFT(@p_ord_number,2)) = 'MT'
	SELECT @v_mov_number = RIGHT(@p_ord_number,datalength(@p_ord_number)- 2)
ELSE
	SELECT @v_mov_number = mov_number,
	       @v_ord_hdrnumber = ord_hdrnumber
	FROM 	orderheader 
	WHERE 	ord_number = @p_ord_number


/*SELECT  @v_mov_number = mov_number,
        @v_ord_hdrnumber = ord_hdrnumber
FROM 	orderheader 
WHERE 	ord_number = @p_ord_number	*/

 /*PTS 32515 AROSS; Get the receiver ID from the generalinfo table */
 SELECT	@v_receiverid = UPPER(ISNULL(gi_string1,'CBP-ACE-TEST'))
 FROM	generalinfo
 WHERE	gi_name = 'ACE:ReceiverID'
 
 	IF @v_receiverid <> 'CBP-ACE' AND @v_receiverid <> 'CBP-ACE-TEST'
 		SET @v_receiverid = 'CBP-ACE-TEST'

/*end PTS 32515 */ 


--Get the legheader for the first border crossing event
SELECT 	@v_lgh_number = lgh_number 
FROM	stops
WHERE	mov_number = @v_mov_number
	AND stp_event in ('BCST','NBCST')
	and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number AND stp_event in ('BCST','NBCST')
	AND stp_state IN (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA'))
	
	

	--get the SCN from the reference number table if necessary
	SELECT @v_SCN =  MAX(ref_number)
	FROM	referencenumber r
		JOIN labelfile l
			ON l.abbr = r.ref_type
	WHERE	r.ref_table = 'orderheader'
		AND r.ref_tablekey = @v_ord_hdrnumber
		AND l.edicode = 'SCN'
		
	SELECT @v_SCN = ISNULL(@v_SCN,@p_ord_number)
	
	--Get the in-bond entry number if it exists
	SELECT @v_inbond_number = ISNULL(aid_entryno,ISNULL(aid_controlno,@p_inbond_scn)),
		@v_us_port = ISNULL(aid_usport,' ')
	FROM	ace_inbond_data
	WHERE	aid_shipment_number = @p_inbond_scn
	
/*	SELECT @v_inbond_number =  MAX(ref_number)
	FROM	referencenumber r
		JOIN labelfile l
			ON l.abbr = r.ref_type
	WHERE	r.ref_table = 'orderheader'
		AND r.ref_tablekey = @v_ord_hdrnumber
		AND l.edicode = 'IBEN'
		*/
	--condition for output
	SELECT @v_inbond_number = ISNULL(@v_inbond_number,' ')
	
	--get the trailer ID
	SELECT @v_trailer = lgh_primary_trailer
	FROM	legheader 
	WHERE	lgh_number = @v_lgh_number



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
    
--insert the header record into the edi_353 table
INSERT INTO edi_353(data_col,batch_number,mov_number)
    VALUES('#TMW353 FROM ' +@v_scac+' TO '+@v_receiverid+' '+@v_formatdate+' '+@v_formattime+' '+CAST(@v_353ctrl AS varchar(8)),
@v_353ctrl,
@v_mov_number)


/*Begin creation of the manifest header #1 record */

--determine the broker company id in order to get the port code also get the scheduled arrival date and time
SELECT	 @v_broker =  cmp_id ,		--broker
	 @v_scheduled_arr = CASE stp_schdtearliest  
	 			WHEN '1/1/1950 00:00' Then stp_arrivaldate
	 			ELSE stp_schdtearliest
	 		    END	
FROM	 stops 
WHERE		 stp_event in ('BCST','NBCST') 
		and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops	WHERE mov_number = @v_mov_number AND stp_event in('BCST','NBCST')
		and stp_state in (SELECT stc_state_c from statecountry where stc_country_c = 'USA'))
		and mov_number = @v_mov_number
 --get the port code based on the broker's company ID
 
 SELECT @v_port = SUBSTRING(cmp_altid,1,4)
 FROM	company
 WHERE	cmp_id = @v_broker
 
--insert the record into the edi_353 table
IF (SELECT ISNULL(@v_usealtSCAC,'N')) <> 'Y'
	INSERT INTO edi_353(data_col,batch_number,mov_number)
	    VALUES('1|10|'+@v_scac+'|'+@v_port+'|'+ CONVERT(varchar(8),@v_scheduled_arr,112) + '|'+
	  SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),1,2) + SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),4,2)+ '|'+ @p_manifest_typecode + '|' +CAST(@v_mov_number AS varchar(15))+'|',
	  @v_353ctrl,
	  @v_mov_number)
ELSE --44182
	INSERT INTO edi_353(data_col,batch_number,mov_number)
	    VALUES('1|10|'+@v_altSCAC+'|'+@v_port+'|'+ CONVERT(varchar(8),@v_scheduled_arr,112) + '|'+
	  SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),1,2) + SUBSTRING(CONVERT(varchar(8),@v_scheduled_arr,8),4,2)+ '|'+ @p_manifest_typecode + '|' +CAST(@v_mov_number AS varchar(15))+'|',
	  @v_353ctrl,
	  @v_mov_number)

 
 SELECT @v_message = CASE @p_notification_type
 			WHEN 'Z' THEN 'EOM'
 			WHEN '1' THEN @v_inbond_number
 			WHEN '2' THEN @p_inbond_scn
 			WHEN '3' THEN @v_trailer
 			WHEN '5' THEN @v_inbond_number
 			WHEN '6' THEN @p_inbond_scn
 		      END
 
 /*PTS 38675:: Do not include reference to inbond control or shipment number */
IF  @p_notification_type = '1'
	SELECT @v_reftype = '',@v_refnum = ''
	--SELECT @v_reftype = 'IB',@v_refnum = @v_inbond_number
IF @p_notification_type = '2'
	SELECT @v_reftype = '',@v_refnum = ''
	--SELECT @v_reftype = 'BM',@v_refnum = @p_inbond_scn
IF  @p_notification_type = '5'
	SELECT @v_reftype = '',@v_refnum = ''
IF  @p_notification_type = '6'
	SELECT @v_reftype = '',@v_refnum = ''	
	
--Condition for output
SELECT @v_reftype = ISNULL(@v_reftype,' ')
SELECT @v_refnum = ISNULL(@v_refnum,' ')
 
 /* Create the 2 record */
 INSERT INTO edi_353(data_col,batch_number,mov_number)
 	VALUES('2|10|'+@p_notification_type + '|'+@v_message +'|'+ @v_formatdate +'|'+@v_formattime+'|'+@v_reftype+'|'+@v_refnum + '|'+ @v_us_port + '|',
 	@v_353ctrl,
 	@v_mov_number)





/* create a trailer record */
SELECT @v_reccount = Count(*)  FROM edi_353 WHERE batch_number = @v_353ctrl

SET @v_reccount = @v_reccount - 1

INSERT INTO edi_353(data_col,batch_number,mov_number)
	VALUES('#EOT '+ CAST(@v_353ctrl as varchar(10)) + ' ' + CAST(@v_reccount as varchar(10)) + ' ',@v_353ctrl,@v_mov_number)
	
	
/*end trailer */	

/* AJR PTS 34041 - Update to lgh_ace_status on creation of 353 */
UPDATE	legheader
SET	lgh_ace_status = '353XFR'
WHERE  mov_number = @v_mov_number--	lgh_number = @v_lgh_number

/*END 34041*/

GO
GRANT EXECUTE ON  [dbo].[edi_353_manifest_header] TO [public]
GO
