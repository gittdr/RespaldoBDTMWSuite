SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [dbo].[d_ace_freightdata] @p_ordnum varchar(13), @p_mov_number int

AS
/**  
 *   
 * NAME:  
 * dbo.d_ace_freightdata  
 *  
 * TYPE:  
 * StoredProcedure  
 *  
 * DESCRIPTION:  
 * Retrieves freight detail information for the ace 309/358 creation window in visual dispatch.  
 *  
 * RETURNS:  
 * NONE  
 *  
 * RESULT SETS:   
 * Freight information.  
 *  
 * PARAMETERS:  
 * 001 - @p_ordnum, varchar(13), input;  
 *       This parameter indicates the order number in which related data is being retrieved  
 * 002 - @p_mov_number int input not null;  
 *  The move number for the current ACE trip.  Used mainly for empty moves  
 *  
 * REFERENCES: (called by and calling references only, don't   
 *              include table/view/object references)  
 * Calls001    ? Name of Proc / Function Called  
 *   
 * REVISION HISTORY:  
 * 03/01/2006.01 ? PTS31886 - A. Rossman ? Initial Release  
 * 04/18/2006.02 - PTS32601 - A. Rossman - Alpha character was being displayed on-screen and not appended to SCN in actual doc. Only use alpha  
 *      character for trips with more than two shipments. Added move number to parameters.  
 * 06/28/2006.03 - PTS33469 - A. Rossman - Updated to allow for shipment control numbers to be assigned at the freight level.  
 * 08/23/2006.04 - PTS34110 - A. Rossman - Updates for freight information on in-bond movements with no US drops.  
 * 02/07/2007.05 - PTS  - A. Rossman - Allow for retrieval of freight information where  
 * 06/26/2007 - M. Curnutt - Branch select stmts for > one mov_number and for 1 mov_number. 
 * 09.21.2007 - PTS 39508 - A.Rossman - Added new criteria for filtering the available shipment data for current shipment
 * 11.05.2007 - PTS 40194 - A. Rossman - Updated freight description retrieval.
 * 01/17.2008 - PTS 41005 - A. Rossman - updates for in-transit shipments.
 * 02.25.2008 - PTS 41340 - A. Rossman - Add order number to result set.
 * 08.28.2008 - PTS 44182 - A.Rossman - Added support for Alternate ACE SCAC.
 *  
 **/  
  
  
DECLARE @v_mov_number int,@v_ord_hdrnumber int,@v_SCN varchar(15)  
DECLARE @v_scac varchar(20),@v_revstart smallint,@v_revtype varchar(9), @v_ord_revtype varchar(6)  
DECLARE @v_drpcount smallint,@v_loop_counter smallint,@v_stpnum int,@v_char int,@v_curr_ord varchar(16),@v_last_ord varchar(16)  
DECLARE @v_usealpha char(1),@v_freight_scn varchar(16),@v_fgt_num int,@v_stpseq int  
 DECLARE 	 @v_useAltScac char(1), @v_altSCAC	varchar(4),	@v_altSCACRevtype	varchar(8)		--44182
--create temp table  
CREATE TABLE #freightdata (  
       stp_number int   NULL,  
       fgt_number int  NULL,  
       cmd_code varchar(8) NULL,  
       cmd_desc varchar(50) NULL,  
       fgt_weight int  NULL,  
       fgt_wgtunit varchar(6) NULL,  
       fgt_pkgunit varchar(6) NULL,  
       cmd_hazardous  char(1) NULL,  
       cmd_haz_num varchar(30) NULL,  
       cmd_haz_contact varchar(30) NULL,  
       cmd_haz_phone  varchar(30) NULL,  
       marks_and_numbers varchar(30) NULL,  
       cbp_release_no  varchar(30) NULL,  
       ord_number   varchar(16) NULL,  
       fgt_count   int  NULL,  
       stp_mfh_sequence int NULL,  
       cmp_name varchar(50) NULL,  
       ord_hdrnumber int NULL,  
       fgt_value money NULL,  
       origin_country varchar(2) NULL,  
       harmonized_code varchar(20) NULL ,
       carrierPro	varchar(12) NULL				--PTS 41340
         
      )  
        
create table #movs (mov_number int)
  
IF @p_mov_number > 0  
 SELECT @v_mov_number = @p_mov_number,  
  @v_ord_hdrnumber = ISNULL(MAX(DISTINCT(ord_hdrnumber)),0)  
 FROM legheader  
 WHERE mov_number = @p_mov_number  
ELSE   
	BEGIN
 		SELECT    @v_ord_hdrnumber = ord_hdrnumber  
 		FROM  orderheader   
		 WHERE ord_number = @p_ordnum  
		 
		 SELECT @v_mov_number =  mov_number
		 FROM		stops
		 			inner join statecountry on stp_state = stc_state_c
		 WHERE 	ord_hdrnumber = @v_ord_hdrnumber
		 			AND stp_type = 'DRP'
		 			AND stc_country_c = 'USA'
	END	 			
		 
  
IF @v_ord_hdrnumber = 0  
   SELECT    stp_number,  
    fgt_number,  
    cmd_code,  
    cmd_desc,  
    fgt_weight,  
    fgt_wgtunit,  
    fgt_pkgunit,  
    cmd_hazardous,  
    cmd_haz_num,  
    cmd_haz_contact,  
    cmd_haz_phone ,  
    marks_and_numbers,  
    cbp_release_no ,  
    ord_number,     
    fgt_count ,
    cmp_name,
    fgt_value,
    origin_country,
    harmonized_code,
    carrierPro
    FROM #freightdata  --if this is an empty move there is no freight return an empty row  
         
  	/*PTS 41005 - Special code for in-transit movements through US. Get movement from first delivery stop. */
  	IF (SELECT ISNULL(@v_mov_number,0)) = 0
  		SELECT @v_mov_number = MAX(mov_number)
  		FROM		Stops
  		WHERE	ord_hdrnumber = @v_ord_hdrnumber
  				AND stp_type = 'DRP'
	/* END 41005 */		
	
insert #movs 
select stops.mov_number from stops inner join stops stops2 on stops.ord_hdrnumber = stops2.ord_hdrnumber
where stops2.mov_number = @v_mov_number and stops2.ord_hdrnumber > 0
group by stops.mov_number

If (select count(*) from #movs) > 1

INSERT INTO #freightdata 
SELECT 	fd.stp_number,
	fd.fgt_number,
 	fd.cmd_code,
 	ISNULL(fd.fgt_description,ISNULL(cm.cmd_name,'UNKNOWN')),
 	fd.fgt_weight,
 	fd.fgt_weightunit,
 	CASE fd.fgt_packageunit
 		WHEN 'UNK' Then fd.fgt_countunit
 		Else ISNULL(fd.fgt_packageunit,fd.fgt_countunit)
 		END,
 	cm.cmd_hazardous,
 	cm.cmd_haz_num,
 	cm.cmd_haz_contact,
 	cm.cmd_haz_telephone,
 	'',
 	'',
 	st.ord_hdrnumber,
 	fd.fgt_count,
 	st.stp_mfh_sequence,
 	st.cmp_name,
 	st.ord_hdrnumber,
 	0,
 	'',
 	'',
 	0
 FROM	freightdetail fd
		INNER JOIN stops st ON fd.stp_number = st.stp_number
		inner join #movs on st.mov_number = #movs.mov_number
		inner join statecountry on st.stp_state = stc_state_c
		LEFT OUTER JOIN commodity cm ON fd.cmd_code = cm.cmd_code
 WHERE	stc_country_c = 'USA'
		and st.stp_type = 'DRP'

else

INSERT INTO #freightdata 
SELECT 	fd.stp_number,
	fd.fgt_number,
 	fd.cmd_code,
 	ISNULL(fd.fgt_description,ISNULL(cm.cmd_name,'UNKNOWN')),
 	fd.fgt_weight,
 	fd.fgt_weightunit,
 	CASE fd.fgt_packageunit
 		WHEN 'UNK' Then fd.fgt_countunit
 		Else ISNULL(fd.fgt_packageunit,fd.fgt_countunit)
 		END,
 	cm.cmd_hazardous,
 	cm.cmd_haz_num,
 	cm.cmd_haz_contact,
 	cm.cmd_haz_telephone,
 	'',
 	'',
 	st.ord_hdrnumber,
 	fd.fgt_count,
 	st.stp_mfh_sequence,
 	st.cmp_name,
 	st.ord_hdrnumber,
 	0,
 	'',
 	'',
 	0
 FROM	freightdetail fd
		INNER JOIN stops st ON fd.stp_number = st.stp_number
		inner join statecountry on st.stp_state = stc_state_c
		LEFT OUTER JOIN commodity cm ON fd.cmd_code = cm.cmd_code
 WHERE	stc_country_c = 'USA'
		and st.stp_type = 'DRP'
		and st.mov_number = @v_mov_number
		
--PTS 39508; Cleanup data for current ACE shipment(s) only
--remove any freightdata that should not be included on the manifest for the main movement
DELETE FROM #freightdata where ord_number NOT IN (select ord_hdrnumber FROM stops where stp_type = 'DRP' and mov_number = @v_mov_number)
     
DELETE FROM #freightdata WHERE ord_number NOT IN(SELECT ord_hdrnumber FROM stops
				inner join #movs on stops.mov_number = #movs.mov_number
				inner join statecountry on stops.stp_state = stc_state_c
				 WHERE	stc_country_c <> 'USA'
						and stops.stp_type = 'PUP')    
     
     
 --PTS 34110 Aross - Updates to add freight information when there are mutiple border crossings and no drops in the US.  
 -- records are only added to the temp table when a) there are no other records already in the table and b) there are two or more border crossing events on the move.  
 IF (SELECT COUNT(*) FROM #freightdata )= 0  AND  (SELECT Count(*) FROM stops WHERE mov_number = @v_mov_number and stp_event in ('BCST','NBCST'))> 1  
 BEGIN  
  IF (SELECT COUNT(*) FROM stops WHERE stp_type = 'DRP' and stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number and stp_event in ('BCST','NBCST')))> 0  
  INSERT INTO #freightdata  
  SELECT  fd.stp_number,  
   fd.fgt_number,  
   fd.cmd_code,  
   ISNULL(fd.fgt_description,ISNULL(cm.cmd_name,'UNKNOWN')),  
   fd.fgt_weight,  
   fd.fgt_weightunit,  
   CASE fd.fgt_packageunit  
    WHEN 'UNK' Then fd.fgt_countunit  
    Else ISNULL(fd.fgt_packageunit,fd.fgt_countunit)  
    END,  
   cm.cmd_hazardous,  
   cm.cmd_haz_num,  
   cm.cmd_haz_contact,  
   cm.cmd_haz_telephone,  
   '',  
   '',  
   st.ord_hdrnumber,  
   fd.fgt_count,  
   st.stp_mfh_sequence,  
   st.cmp_name,  
   st.ord_hdrnumber,  
   0,  
   '',  
   ''  ,
   o.ord_number
   FROM freightdetail fd  
    LEFT OUTER JOIN stops st  
    ON fd.stp_number = st.stp_number  
    LEFT OUTER JOIN commodity cm  
    ON fd.cmd_code = cm.cmd_code  
    INNER JOIN orderheader o  
    ON st.mov_number = o.mov_number  
   WHERE fd.stp_number IN (SELECT stp_number from stops where mov_number = @v_mov_number and stp_type = 'DRP')  
    AND stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number and stp_event in ('BCST','NBCST'))  
    AND st.ord_hdrnumber = o.ord_hdrnumber  
   END --PTS 34110   
     
   
   
 --get the scac code from the generalinfo table or from revtypeN value on order.  
 SELECT  @v_scac=UPPER(ISNULL(gi_string1, 'SCAC'))  
 FROM generalinfo   
 WHERE gi_name='SCAC'  
   
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
    
     SELECT  @v_SCAC = isnull(UPPER(edicode),abbr)  
     FROM  labelfile  
     WHERE  labeldefinition = @v_revtype  
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
	    	
    
    
 --Update Harmonized Code and Country of origin for .Net module  
  UPDATE #freightdata  
  SET harmonized_code = ref_number  
  FROM referencenumber  
  INNER JOIN labelfile  
    ON labelfile.abbr = referencenumber.ref_type  
  WHERE ref_tablekey = fgt_number  
  AND ref_table = 'freightdetail'  
  AND edicode = 'HTC'  
  AND labeldefinition = 'ReferenceNumbers'  
    
  UPDATE #freightdata  
  SET origin_country = ref_number  
  FROM referencenumber  
  INNER JOIN labelfile  
    ON labelfile.abbr = referencenumber.ref_type  
  WHERE ref_tablekey = fgt_number  
 AND ref_table = 'freightdetail'  
 AND edicode = 'COO'  
AND labeldefinition = 'ReferenceNumbers'  
   
   
   
 --Update the Marks and Numbers and the CBP release number reference data  
 UPDATE #freightdata  
 SET marks_and_numbers =  ref_number  
 FROM   referencenumber r  
  JOIN labelfile l  
   ON l.abbr = r.ref_type  
 WHERE ref_table = 'freightdetail'  
    AND ref_tablekey = fgt_number  
    AND l.edicode = 'MARKS'  
  
UPDATE #freightdata  
SET cbp_release_no = ref_number  
FROM referencenumber r   
 JOIN labelfile l  
 ON l.abbr = r.ref_type  
WHERE r.ref_table = 'freightdetail'  
 AND r.ref_tablekey  = fgt_number  
 AND l.edicode = 'CBPREL'  
   
 --get the SCN from the reference number table if necessary  
 SELECT @v_SCN =  LEFT(MAX(ref_number),15)  
 FROM referencenumber r  
  JOIN labelfile l  
   ON l.abbr = r.ref_type  
 WHERE r.ref_table = 'orderheader'  
  AND r.ref_tablekey = @v_ord_hdrnumber  
  AND l.edicode = 'SCN'   
   
  IF (SELECT ISNULL(@v_SCN,'XX')) <> 'XX'   
   UPDATE #freightdata  
   SET ord_number = CASE @v_usealtSCAC
   							WHEN 'Y' THEN @v_altSCAC + @v_SCN
   							ELSE	@v_scac +@v_SCN  
   					END		
  ELSE   
   UPDATE #freightdata  
   SET  ord_number = CASE @v_useAltSCAC	
   						WHEN 'Y' THEN @v_altSCAC + ord_number
   						ELSE	@v_scac + ord_number  
   					   END	
    
 UPDATE #freightdata  
 SET ord_number = CASE @v_useAltSCAC
 						WHEN 'Y' THEN @v_altSCAC + r.ref_number
 						ELSE @v_scac + r.ref_number  
 					END 
 FROM referencenumber r  
  JOIN labelfile l  
   ON l.abbr = r.ref_type  
 WHERE r.ref_table = 'freightdetail'  
  AND r.ref_tablekey =  fgt_number  
  AND l.edicode =  'SCN'  
  
 --if we have multiple destination locations then we need to create a unique shipment for each one.  
  SELECT @v_loop_counter = COUNT(DISTINCT(stp_number)) FROM #freightdata  
  SET @v_drpcount = 1  
  SET @v_char = 65   
  SELECT @v_stpnum = stp_number,@v_stpseq = stp_mfh_sequence FROM #freightdata WHERE stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM #freightdata)  
  SELECT @v_fgt_num = MIN(fgt_number) FROM #freightdata WHERE stp_number =  @v_stpnum  
 WHILE @v_loop_counter > 1 AND @v_drpcount <= @v_loop_counter  
 BEGIN  
  SELECT @v_curr_ord = ord_hdrnumber   
  FROM #freightdata  
  WHERE stp_number = @v_stpnum  
    
    
  /* add check for freightdetail level SCN */  
   WHILE @v_fgt_num IS NOT NULL  
     /* IF (SELECT COUNT(*) FROM referencenumber JOIN labelfile ON abbr= ref_type  
       WHERE ref_table = 'freightdetail' and ref_tablekey = @v_fgt_num and edicode = 'SCN') > 0 */  
    BEGIN  
     SELECT @v_freight_scn = CASE @v_useAltScac
     								WHEN 'Y' THEN @v_altSCAC + ref_number
     								ELSE @v_scac + ref_number   
     							END 	
     FROM   referencenumber  
         JOIN labelfile   
          ON abbr = ref_type  
     WHERE ref_table = 'freightdetail'  
      AND ref_tablekey = @v_fgt_num  
      AND edicode = 'SCN'  
       
     IF LEN(@v_freight_scn) > 4  
        UPDATE #freightdata  
        SET  ord_number =  @v_freight_scn  
        WHERE fgt_number = @v_fgt_num  
     ELSE  
        SET @v_freight_scn = 'N'  
       
     SELECT @v_fgt_num =  MIN(fgt_number) FROM #freightdata WHERE stp_number = @v_stpnum and fgt_number > @v_fgt_num  
    END  
         
         
    
       
  IF @v_curr_ord <> @v_last_ord  --reset the alpha character if this is a new order  
   SET @v_char = 65  
  
  IF (SELECT COUNT(*) FROM #freightdata WHERE ord_hdrnumber = @v_curr_ord) > 1  
  and (SELECT COUNT(DISTINCT(stp_number)) FROM #freightdata WHERE ord_hdrnumber = @v_curr_ord) > 1  
  and @v_freight_scn = 'N'  
   SET @v_usealpha = 'Y'  
  ELSE  
   SET @v_usealpha = 'N'  
    
  IF @v_usealpha = 'Y'  
   UPDATE #freightdata  
   SET ord_number =  ord_number + CHAR(@v_char) --Append an alpha character to the end of the SCN for each drop to  
   WHERE stp_number = @v_stpnum    --create a unique shipment.  
      
   SET @v_drpcount = @v_drpcount + 1  
   SET @v_char = @v_char +  1  
     
   SET @v_freight_scn = 'N'  
   SET @v_last_ord = @v_curr_ord  
     
   SELECT @v_stpnum = MIN(stp_number),  
    @v_stpseq = MIN(stp_mfh_sequence)  
   FROM #freightdata  
   WHERE stp_mfh_sequence  > @v_stpseq  --= (SELECT stp_mfh_sequence + 1  FROM #freightdata WHERE stp_number = @v_stpnum)  
   SELECT @v_fgt_num = MIN(fgt_number) FROM #freightdata WHERE stp_number =  @v_stpnum  
  END  
  
  --Add update to set carrier pro number
  UPDATE #freightdata
  SET		carrierPro =  o.ord_number
  FROM		orderheader o
  WHERE	#freightdata.ord_hdrnumber =  o.ord_hdrnumber
  		AND o.ord_hdrnumber > 0
    
    
 SELECT    stp_number,  
    fgt_number,  
    cmd_code,  
    cmd_desc,  
    fgt_weight,  
    fgt_wgtunit,  
    fgt_pkgunit,  
    cmd_hazardous,  
    cmd_haz_num,  
    cmd_haz_contact,  
    cmd_haz_phone ,  
    marks_and_numbers,  
    cbp_release_no ,  
    ord_number,     
    fgt_count,  
    cmp_name,  
    fgt_value,  
    harmonized_code,  
    origin_country ,
    carrierPro
FROM #freightdata  
GO
GRANT EXECUTE ON  [dbo].[d_ace_freightdata] TO [public]
GO
