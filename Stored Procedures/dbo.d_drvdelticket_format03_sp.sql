SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_drvdelticket_format03_sp] @p_ord_number int
AS

/************* USED FOR d_delivery_receipt03   ONLY  NOT d_drvdelticket_format03  *****************************8
 * 
 * NAME:
 * dbo.d_drvdelticket_format03_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the drops/pickups for a driver
 *
 * RETURNS:
 * 
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_ord_number, int, input, null;
 *       This parameter indicates the MOVE NUMBER(ie.mov_number)
 *       The value must be non-null and non-empty.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * 
 *
 * REVISION HISTORY:
 * 03/01/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 11/22/2005 PTS29841 - ILB - New delivery ticket format
 * 3/1/7 pts 36451 Customer wants delivery stop name and address returned as the consignee
 * 41158 DPETE 1/31/08 city information for the "Consignee" on the report should com from the sop not the cosignee
 **/

DECLARE @v_rs varchar(255),@v_cnt int, @v_ord_hdr int, @v_mov_number int,
        @v_sequence int, @v_next_sequence int, @v_lul int, @v_bl_cnt int,
        @v_drp_sequence int, @v_stp_num int, @v_fgt_num int, @v_ref_num varchar(255),
        @v_lrq_seq int, @v_lrq_text varchar(255), @pup_cnt int, @v_stp_number int,
        @v_early_date datetime , @v_late_date datetime, @v_drp_stpnumber INT,
        @evt_driver2 varchar(8), @evt_tractor varchar(13), @evt_trailer1 varchar(13),
	@evt_driver1 varchar(8), @evt_trailer2 varchar(13),
        @fgt_code varchar(8), @fgt_wgt float, @fgt_vol float,	@fgt_desc varchar(60),
	@v_fgt_seq int, @v_pupdrp char(1), @v_stp_test int, @V_NEXTSTP_NUMBER INT,
        @v_nextdrp_sequence int, @v_nextdrp_NUMBER int, @v_nextdrp_seq INT, @v_CMP_ID VARCHAR(20),
        @v_pupcnt int, @v_pupstp_number int
        

SELECT @v_mov_number = mov_number
  FROM STOPS
 WHERE ord_hdrnumber = @p_ord_number

CREATE TABLE #trips (
	shipper_name		VARCHAR(100)	NOT NULL,
        shipper_cmpid           VARCHAR (20)     NULL,
	shipper_address1	VARCHAR(100)	NULL,
	shipper_address2	VARCHAR(100)	NULL,
	shipper_cty_nmstct	VARCHAR(25)     NULL,	
	shipper_primaryphone    VARCHAR(20)     NULL,
	consignee_name		VARCHAR(100)	NOT NULL,
        consignee_cmpid         VARCHAR (20)     NULL,
	consignee_address1	VARCHAR(100)	NULL,
	consignee_address2	VARCHAR(100)	NULL,
	consignee_cty_nmstct	VARCHAR(25)    	NULL,	
	consignee_primaryphone  VARCHAR(20)     NULL,
	billto_name		VARCHAR(100)	NOT NULL,
	billto_address1		VARCHAR(100)	NULL,
	billto_address2		VARCHAR(100)	NULL,
	billto_cty_nmstct	VARCHAR(25)    	NULL,	
	billto_primaryphone   	VARCHAR(20)     NULL,
        stop_event              CHAR(6)         NULL,
        order_number            INT NULL,
        mov_number              INT NULL,
        order_mintemp           INT NULL,
        tractor_id              VARCHAR(8) NULL,
        driver1_id              VARCHAR(8) NULL,
        driver2_id              VARCHAR(8) NULL,
        trailer                 VARCHAR(13) NULL,
        trailer2                VARCHAR(13) NULL,
        ord_status              VARCHAR(6) NULL,
        ord_remarks		VARCHAR(255) NULL,
        fgt_cmdcode_1		VARCHAR(8) NULL,
	fgt_cmdcode_2		VARCHAR(8) NULL,
	fgt_cmdcode_3		VARCHAR(8) NULL,
	fgt_cmdcode_4		VARCHAR(8) NULL,
        fgt_description_1	VARCHAR(60) NULL,
	fgt_description_2	VARCHAR(60) NULL,
	fgt_description_3	VARCHAR(60) NULL,
	fgt_description_4	VARCHAR(60) NULL,
        fgt_weight_1		FLOAT NULL,
	fgt_weight_2		FLOAT NULL,
	fgt_weight_3		FLOAT NULL,
	fgt_weight_4		FLOAT NULL,
        fgt_volume_1		FLOAT NULL,
	fgt_volume_2		FLOAT NULL,
	fgt_volume_3		FLOAT NULL,
 	fgt_volume_4		FLOAT NULL,        
        stp_lgh_mileage		INT NULL,
        evt_startdate		DATETIME NULL,
        evt_earlydate		DATETIME NULL,
        evt_latedate		DATETIME NULL,
        refnum_header           VARCHAR(255) NULL,
        refnum_rail1		VARCHAR(255) NULL,
        refnum_rail2		VARCHAR(255) NULL,
        refnum_cont_iso         VARCHAR(255) NULL,
        refnum_wt_1             VARCHAR(255) NULL,
	refnum_wt_2             VARCHAR(255) NULL,
	refnum_wt_3             VARCHAR(255) NULL,
	refnum_wt_4             VARCHAR(255) NULL,
        refnum_seal             VARCHAR(255) NULL,
        pup_drp			CHAR(1) NULL,        
        stp_mfh_sequence        INT NULL,
	pickup_driver1          VARCHAR(8) NULL,
        pickup_driver2 VARCHAR(8) NULL,
        pickup_tractor_id       VARCHAR(8) NULL,
        pickup_trailer          VARCHAR(13) NULL,
        pickup_trailer2         VARCHAR(13) NULL,
        notes_1                 VARCHAR(255) NULL,
        notes_2			VARCHAR(255) NULL,	
        stp_number              INT NULL,
        load_requirements       VARCHAR(255)NULL,
        pup_cnt			INT NULL,
        lgh_number              INT NULL,
        stp_cmpid               varchar(20))

CREATE TABLE #trips2 (
	shipper_name		VARCHAR(100)	NOT NULL,
        shipper_cmpid           VARCHAR (20)     NULL,
	shipper_address1	VARCHAR(100)	NULL,
	shipper_address2	VARCHAR(100)	NULL,
	shipper_cty_nmstct	VARCHAR(25)     NULL,	
	shipper_primaryphone    VARCHAR(20)     NULL,
	consignee_name		VARCHAR(100)	NOT NULL,
        consignee_cmpid         VARCHAR (20)     NULL,
	consignee_address1	VARCHAR(100)	NULL,
	consignee_address2	VARCHAR(100)	NULL,
	consignee_cty_nmstct	VARCHAR(25)    	NULL,	
	consignee_primaryphone  VARCHAR(20)     NULL,
	billto_name		VARCHAR(100)	NOT NULL,
	billto_address1		VARCHAR(100)	NULL,
	billto_address2		VARCHAR(100)	NULL,
	billto_cty_nmstct	VARCHAR(25)    	NULL,	
	billto_primaryphone   	VARCHAR(20)     NULL,
        stop_event              CHAR(6)         NULL,
        order_number            INT NULL,
        mov_number              INT NULL,
        order_mintemp           INT NULL,
        tractor_id              VARCHAR(8) NULL,
        driver1_id              VARCHAR(8) NULL,
        driver2_id              VARCHAR(8) NULL,
        trailer                 VARCHAR(13) NULL,
        trailer2                VARCHAR(13) NULL,
        ord_status              VARCHAR(6) NULL,
        ord_remarks		VARCHAR(255) NULL,
        fgt_cmdcode_1		VARCHAR(8) NULL,
	fgt_cmdcode_2		VARCHAR(8) NULL,
	fgt_cmdcode_3		VARCHAR(8) NULL,
	fgt_cmdcode_4		VARCHAR(8) NULL,
        fgt_description_1	VARCHAR(60) NULL,
	fgt_description_2	VARCHAR(60) NULL,
	fgt_description_3	VARCHAR(60) NULL,
	fgt_description_4	VARCHAR(60) NULL,
        fgt_weight_1		FLOAT NULL,
	fgt_weight_2		FLOAT NULL,
	fgt_weight_3		FLOAT NULL,
	fgt_weight_4		FLOAT NULL,
        fgt_volume_1		FLOAT NULL,
	fgt_volume_2		FLOAT NULL,
	fgt_volume_3		FLOAT NULL,
 	fgt_volume_4		FLOAT NULL,	
        stp_lgh_mileage		INT NULL,
        evt_startdate		DATETIME NULL,
        evt_earlydate		DATETIME NULL,
        evt_latedate		DATETIME NULL,
        refnum_header           VARCHAR(255) NULL,
        refnum_rail1		VARCHAR(255) NULL,
        refnum_rail2		VARCHAR(255) NULL,
        refnum_cont_iso         VARCHAR(255) NULL,
        refnum_wt_1             VARCHAR(255) NULL,
	refnum_wt_2             VARCHAR(255) NULL,
	refnum_wt_3             VARCHAR(255) NULL,
	refnum_wt_4             VARCHAR(255) NULL,
        refnum_seal             VARCHAR(255) NULL,
        pup_drp			CHAR(1) NULL,        
        stp_mfh_sequence        INT NULL,
        pickup_driver1          VARCHAR(8) NULL,
        pickup_driver2          VARCHAR(8) NULL,
        pickup_tractor_id       VARCHAR(8) NULL,
        pickup_trailer          VARCHAR(13) NULL,
        pickup_trailer2         VARCHAR(13) NULL,
        notes_1                 VARCHAR(255) NULL,
        notes_2			VARCHAR(255) NULL,
        stp_number		INT NULL,
        load_requirements       VARCHAR(255)NULL,
        pup_cnt			INT NULL,
        lgh_number              INT NULL,
        stp_cmpid               varchar(20) null)

INSERT  INTO #trips
	SELECT	DISTINCT
	shipper.cmp_name	,
        shipper.cmp_id,
	shipper.cmp_address1	,
	shipper.cmp_address2	,
	shipper.cty_nmstct,  -- 41158 shipper_cty.cty_nmstct			,	
	shipper.cmp_primaryphone     ,
	consignee.cmp_name	,
        consignee.cmp_id,
	consignee.cmp_address1	,
	consignee.cmp_address2	,
    consignee.cty_nmstct,  -- 41158  consignee_cty.cty_nmstct			,	
	consignee.cmp_primaryphone ,
	billto.cmp_name		,
	billto.cmp_address1		,
	billto.cmp_address2		,
	billto.cty_nmstct, -- 41158 billto_cty.cty_nmstct			,	
	billto.cmp_primaryphone,
        stp.stp_event,
        ord.ord_hdrnumber,
        ord.mov_number,
        ord.ord_mintemp,
        Case lgh.lgh_tractor
           when 'UNKNOWN' THEN ''
           else lgh.lgh_tractor
	   end ,
        Case lgh.lgh_driver1
           when 'UNKNOWN' THEN ''
           else lgh.lgh_driver1
	   end ,
        Case lgh.lgh_driver2
           when 'UNKNOWN' THEN ''
           else lgh.lgh_driver2
	   end,
        Case lgh.lgh_primary_trailer
           when 'UNKNOWN' THEN ''
           else lgh.lgh_primary_trailer
	   end ,
        Case lgh.lgh_primary_pup
           when 'UNKNOWN' THEN ''
           else lgh.lgh_primary_pup
	   end ,
        ord.ord_status,
        ord.ord_remark,               
        '' fgt_cmdcode_1,
	'' fgt_cmdcode_2,
	'' fgt_cmdcode_3,
	'' fgt_cmdcode_4,
        '' fgt_description_1,
	'' fgt_description_2,
	'' fgt_description_3,
	'' fgt_description_4,
        0 fgt_weight_1,
	0 fgt_weight_2,
	0 fgt_weight_3,
	0 fgt_weight_4,
	0 fgt_volume_1,
	0 fgt_volume_2,
	0 fgt_volume_3,
	0 fgt_volume_4,        
        stp.stp_lgh_mileage,
        evt.evt_startdate,
        evt.evt_earlydate,
        --evt.evt_latedate,
	evt.evt_enddate,
	'' refnum_header,
        '' refnum_rail1,
        '' refnum_rail2,
        '' refnum_cont_iso,      
	'' refnum_wt_1,
	'' refnum_wt_2,
	'' refnum_wt_3,
	'' refnum_wt_4,
        '' refnum_seal,
        (Case stp.stp_event  
  		when 'DLT' then 'D'  
                when 'DRL' then 'D' 
		when 'HCT' then 'P' 
		when 'HLT' then 'P' 
		when 'HMT' then 'P' 
		--when 'HPL' then 'P' 
		when 'LLD' then 'P' 
		when 'LUL' then 'D' 
		when 'DMT' then 'D'		 
                --when 'PLD' then 'P'
  		else 'N'   
 		end) pup_drp, 
        stp.stp_mfh_sequence,
	'',
	'',
	'',
	'',
	'',
        '' notes_1, --notes for sequence 1   
        '' notes_2, --notes for sequence 2
        stp.stp_number,
        '' load_requirements,
        0 ,--pickup count,
       lgh.lgh_number,
       STP.CMP_ID --STOP COMPANY ID
   from orderheader ord , company shipper, company consignee, company billto,
        stops stp,  -- 41158 city shipper_cty, city consignee_cty, city billto_cty, stops stp, 
        legheader lgh, freightdetail fgt, event evt
  where ord.mov_number = @v_mov_number and
	--ord.ord_hdrnumber = stp.ord_hdrnumber and
        ord.mov_number = stp.mov_number and
        stp.lgh_number = lgh.lgh_number and
        stp.stp_number = fgt.stp_number and 
        stp.stp_number = evt.stp_number and
        stp.stp_event IN ('LLD','LUL','DLT','DRL','HCT','HLT','HMT','DMT') and
	--stp.stp_event IN ('HPL','PLD') codes not used per SR 33208
        ord.ord_shipper = shipper.cmp_id and
        stp.cmp_id = consignee.cmp_id and   --ord.ord_consignee = consignee.cmp_id and
        ord.ord_billto = billto.cmp_id 
     --  and  shipper_cty.cty_code = ord.ord_origincity and 
     --   consignee_cty.cty_code = ord.ord_destcity and
     --   billto_cty.cty_code = billto.cmp_city  
           

--include order-level refnums in comma-separated list 
BEGIN
		
	SELECT @v_rs = ','
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
 	
	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
	BEGIN
	  
		SELECT @v_ord_hdr = MIN(order_number) 
	          FROM #trips 
	         WHERE mov_number = @v_mov_number and	
		       order_number > @v_ord_hdr 
                 
		WHILE 1=1
		BEGIN
			SELECT @v_cnt = min(ref_sequence)
			FROM referencenumber
			WHERE 	ord_hdrnumber = @v_ord_hdr
				and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                        and ref_type IN ('BL#')			 
				and ref_sequence > @v_cnt
			
			
			SELECT @v_bl_cnt = @v_bl_cnt + 1

			IF @v_cnt is null or @v_bl_cnt > 5 BREAK
				SELECT @v_rs = @v_rs + ref_type + '-' + ref_number + ', ' 
				  FROM referencenumber
				 WHERE ord_hdrnumber = @v_ord_hdr
				       and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                               and ref_type IN ('BL#')			 
				       and ref_sequence = @v_cnt
			
		END
          END

END
Update #trips
   set refnum_header = substring(LEFT(@v_rs, len(@v_rs)-1), 2, len(@v_rs)) 

BEGIN	
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
 	
	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
	BEGIN
	  
		SELECT @v_ord_hdr = MIN(order_number) 
	          FROM #trips 
	         WHERE mov_number = @v_mov_number and	
		       order_number > @v_ord_hdr 
                 
		WHILE 1=1
		BEGIN
			SELECT @v_cnt = min(ref_sequence)
			FROM referencenumber
			WHERE 	ord_hdrnumber = @v_ord_hdr
				and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                        and ref_type IN ('SHORD','REF','SHPO','COPO','SI','LOT','WRKORD')			 
				and ref_sequence > @v_cnt
			IF @v_cnt IS NULL BREAK
				SELECT @v_rs = @v_rs + ref_type + '-' +ref_number + ', ' 
				  FROM referencenumber
				 WHERE ord_hdrnumber = @v_ord_hdr
				       and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                               and ref_type IN ('SHORD','REF','SHPO','COPO','SI','LOT','WRKORD')			 
				       and ref_sequence = @v_cnt
		END
          END
END
Update #trips
   set refnum_header = substring(LEFT(@v_rs, len(@v_rs)-1), 2, len(@v_rs)) 

--'Rail1' reference number
BEGIN
		
	SELECT @v_rs = ','
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
 	
	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
	BEGIN
	  	
		SELECT @v_ord_hdr = MIN(order_number) 
	          FROM #trips 
	         WHERE mov_number = @v_mov_number and	
		       order_number > @v_ord_hdr 
               
                 
		WHILE 1=1
		BEGIN
			SELECT @v_cnt = min(ref_sequence)
			FROM referencenumber
			WHERE 	ord_hdrnumber = @v_ord_hdr
				and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                        and ref_type IN ('RAIL1')			 
				and ref_sequence > @v_cnt

			
			
			IF @v_cnt IS NULL BREAK
				SELECT @v_rs = @v_rs + ref_number + ', ' 
				  FROM referencenumber
				 WHERE ord_hdrnumber = @v_ord_hdr
				       and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                               and ref_type IN ('RAIL1')			 
				       and ref_sequence = @v_cnt				
		END		
          END

END

Update #trips
   set refnum_rail1 = substring(LEFT(@v_rs, len(@v_rs)-1), 2, len(@v_rs)) 


--'Rail2' reference number
BEGIN	
	SELECT @v_rs = ','
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
 	
	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
	BEGIN
	  
		SELECT @v_ord_hdr = MIN(order_number) 
	          FROM #trips 
	         WHERE mov_number = @v_mov_number and	
		       order_number > @v_ord_hdr 
                 
		WHILE 1=1
		BEGIN
			SELECT @v_cnt = min(ref_sequence)
			FROM referencenumber
			WHERE 	ord_hdrnumber = @v_ord_hdr
				and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                        and ref_type IN ('RAIL2')			 
				and ref_sequence > @v_cnt
			IF @v_cnt IS NULL BREAK
				SELECT @v_rs = @v_rs + ref_number + ', ' 
				  FROM referencenumber
				 WHERE ord_hdrnumber = @v_ord_hdr
				       and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                               and ref_type IN ('RAIL2')			 
				       and ref_sequence = @v_cnt
		END
          END

END
Update #trips
   set refnum_rail2 = substring(LEFT(@v_rs, len(@v_rs)-1), 2, len(@v_rs)) 

--'CONT OR ISO' reference number
BEGIN	
	SELECT @v_rs = ','
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
 	
	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
	BEGIN
	  
		SELECT @v_ord_hdr = MIN(order_number) 
	          FROM #trips 
	         WHERE mov_number = @v_mov_number and	
		       order_number > @v_ord_hdr 
                 
		WHILE 1=1
		BEGIN
			SELECT @v_cnt = min(ref_sequence)
			FROM referencenumber
			WHERE 	ord_hdrnumber = @v_ord_hdr
				and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                        and ref_type IN ('CONT','ISO')			 
				and ref_sequence > @v_cnt
			IF @v_cnt IS NULL BREAK
				SELECT @v_rs = @v_rs + ref_number + ', ' 
				  FROM referencenumber
				 WHERE ord_hdrnumber = @v_ord_hdr
				       and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                               and ref_type IN ('CONT','ISO')			 
				       and ref_sequence = @v_cnt
		END
          END

END
Update #trips
   set refnum_cont_iso = substring(LEFT(@v_rs, len(@v_rs)-1), 2, len(@v_rs)) 


--'SEAL' reference number
BEGIN	
	SELECT @v_rs = ','
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
 	
	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
	BEGIN
	  
		SELECT @v_ord_hdr = MIN(order_number) 
	          FROM #trips 
	         WHERE mov_number = @v_mov_number and	
		       order_number > @v_ord_hdr 
                 
		WHILE 1=1
		BEGIN
			SELECT @v_cnt = min(ref_sequence)
			FROM referencenumber
			WHERE 	ord_hdrnumber = @v_ord_hdr
				and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                        and ref_type IN ('SEAL')			 
				and ref_sequence > @v_cnt
			IF @v_cnt IS NULL BREAK
				SELECT @v_rs = @v_rs + ref_number + ', ' 
				  FROM referencenumber
				 WHERE ord_hdrnumber = @v_ord_hdr
				       and (ref_table='orderheader' and ord_hdrnumber <> 0)
	                               and ref_type IN ('SEAL')			 
				       and ref_sequence = @v_cnt
		END
          END

END
Update #trips
   set refnum_seal = substring(LEFT(@v_rs, len(@v_rs)-1), 2, len(@v_rs))

--include ALL load requirements in comma-separated list 
BEGIN			
	SELECT @v_cnt = 0
        SELECT @v_lrq_seq = 0
	SELECT @v_lrq_text = ','
	                 
	WHILE (SELECT Count(*)
		 FROM loadrequirement
		WHERE lrq_sequence > @v_lrq_seq
		  AND mov_number = @v_mov_number) > 0                       
		
		BEGIN
			SELECT @v_lrq_seq = min(lrq_sequence)
			  FROM loadrequirement
			 WHERE lrq_sequence > @v_lrq_seq
			   AND mov_number = @v_mov_number	
		
			SELECT @v_lrq_text = @v_lrq_text + lrq.def_id_type + '-'+ lbl.name + ', ' 
			  FROM loadrequirement lrq, labelfile lbl
			 WHERE lrq.mov_number = @v_mov_number
			       and lrq.lrq_sequence = @v_lrq_seq
                               and lrq.lrq_type = lbl.abbr		
		END         

END
Update #trips
   set load_requirements = substring(LEFT(@v_lrq_text, len(@v_lrq_text)-1), 2, len(@v_lrq_text)) 


--Order Notes
BEGIN	
	SELECT @v_rs = ','
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
 	
	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
	BEGIN
	  
		SELECT @v_ord_hdr = MIN(order_number) 
	          FROM #trips 
	         WHERE mov_number = @v_mov_number and	
		       order_number > @v_ord_hdr 
                 
		WHILE 1=1
		BEGIN 
			SELECT @v_cnt = min(not_sequence)			  
			  FROM NOTES
			  WHERE ((nre_tablekey = cast(@v_ord_hdr as varchar(20))) or 
			          nre_tablekey IN (select ord_shipper
					             from orderheader
					            where mov_number = @v_mov_number) or
			          nre_tablekey IN (select ord_consignee
			                             from orderheader
			                            where mov_number = @v_mov_number) or
			          nre_tablekey IN (select ord_billto
			                             from orderheader 
			                            where mov_number = @v_mov_number))
			     AND nre_tablekey <> '0'
			     AND ntb_table IN ('orderheader','company')                 		 
			     AND not_sequence > @v_cnt
					
			IF @v_cnt IS NULL or @v_cnt > 2 BREAK

			IF @v_cnt = 1
			   BEGIN
				UPDATE #TRIPS
	                           SET NOTES_1 = NOT_TEXT 
	                          FROM NOTES
	                         WHERE ((nre_tablekey = cast(@v_ord_hdr as varchar(20))) or 
				         nre_tablekey IN (select ord_shipper
						            from orderheader
						           where mov_number = @v_mov_number) or
				         nre_tablekey IN (select ord_consignee
				                            from orderheader
				                           where mov_number = @v_mov_number) or
				         nre_tablekey IN (select ord_billto
				                            from orderheader 
				                           where mov_number = @v_mov_number))
				    AND nre_tablekey <> '0'
				    AND ntb_table IN ('orderheader','company')                 		 
				    AND not_sequence = @v_cnt
			   END

			IF @v_cnt = 2
			   BEGIN
				UPDATE #TRIPS
	                           SET NOTES_2 = NOT_TEXT 
	                          FROM NOTES
	                         WHERE ((nre_tablekey = cast(@v_ord_hdr as varchar(20))) or 
				         nre_tablekey IN (select ord_shipper
						            from orderheader
						           where mov_number = @v_mov_number) or
				         nre_tablekey IN (select ord_consignee
				                            from orderheader
				                           where mov_number = @v_mov_number) or 
				         nre_tablekey IN (select ord_billto
				                            from orderheader 
				                           where mov_number = @v_mov_number))
				    AND nre_tablekey <> '0'
				    AND ntb_table IN ('orderheader','company')                 		 
				    AND not_sequence = @v_cnt
			   END					
		END --Order

	  Select @v_cnt = 0
          END--Move

END

SET @v_sequence = 0
SET @v_next_sequence = 0

SELECT @PUP_CNT = COUNT(*)
  FROM #TRIPS
 WHERE PUP_DRP = 'P'

--print 'first '+ cast(@v_sequence as varchar(20))
--print 'pup count '+ cast(@PUP_CNT as varchar(20))


WHILE (SELECT COUNT(*) 
	 FROM #trips 
	WHERE stp_mfh_sequence > @v_sequence and pup_drp = 'P') > 0

 	  BEGIN	

		SELECT @v_sequence = min(stp_mfh_sequence)
                  FROM #trips
                 WHERE pup_drp = 'P' and 
                       stp_mfh_sequence > @v_sequence

		--print 'first '+ cast(@v_sequence as varchar(20))

		SELECT @v_next_sequence = isnull(min(stp_mfh_sequence),999)
                  FROM #trips
                 WHERE pup_drp = 'P' and
                       stp_mfh_sequence > @v_sequence	

		 --print 'second '+ cast(@v_next_sequence as varchar(20))	

		INSERT  INTO #trips2
		SELECT	shipper_name	,
			shipper_cmpid,
			shipper_address1	,
			shipper_address2	,
			shipper_cty_nmstct			,	
			shipper_primaryphone     ,
			consignee_name	,
			consignee_cmpid,
			consignee_address1	,
			consignee_address2	,
			consignee_cty_nmstct			,	
			consignee_primaryphone ,
			billto_name		,
			billto_address1		,
			billto_address2		,
			billto_cty_nmstct			,	
			billto_primaryphone,
		        stop_event,
		        order_number,
		        mov_number,
		        order_mintemp,
		        tractor_id,
		        driver1_id,
		        driver2_id,
		        trailer,
			trailer2,
		        ord_status,
		        ord_remarks,
			fgt_cmdcode_1,
			fgt_cmdcode_2,
			fgt_cmdcode_3,
			fgt_cmdcode_4,
		        fgt_description_1,
			fgt_description_2,
			fgt_description_3,
			fgt_description_4,
		        fgt_weight_1		,
			fgt_weight_2		,
			fgt_weight_3		,
			fgt_weight_4		,
		        fgt_volume_1		,
			fgt_volume_2		,
			fgt_volume_3		,
		 	fgt_volume_4		,
		        stp_lgh_mileage		,
		        evt_startdate		,
		        evt_earlydate		,
		        evt_latedate,
			refnum_header          ,
		        refnum_rail1	 ,
		        refnum_rail2,
		        refnum_cont_iso,
		        refnum_wt_1,
			refnum_wt_2,
			refnum_wt_3,
			refnum_wt_4,
                       refnum_seal,
		        pup_drp,
		        stp_mfh_sequence,
                        '',
                        '',
			'',
        		'',
        		'',
                        notes_1,
                        notes_2,
                        stp_number,
                        load_requirements,
                        0,
                        lgh_number,
			stp_cmpid
	   	   FROM #trips
                  WHERE stp_mfh_sequence between @v_sequence and @v_next_sequence 
			and pup_drp = 'D' 

		  IF @pup_cnt = 1
		     BEGIN
			  --print 'test' --+ cast(@v_drp_sequence as varchar(20))
			  UPDATE #trips2
	                    SET #trips2.pickup_driver1 = #trips.driver1_id,
	                        #trips2.pickup_driver2 = #trips.driver2_id,
	                        #trips2.trailer = #trips.trailer,
                                #trips2.evt_earlydate = #trips.evt_earlydate
	                   FROM #trips
	                  WHERE #trips.stp_mfh_sequence = @v_sequence 
				and #trips.pup_drp = 'P'
	                        --and  #trips2. stp_mfh_sequence = @v_drp_sequence
                     END

		IF @pup_cnt > 1 
		   BEGIN
			INSERT  INTO #trips2
			SELECT	shipper_name	,
				shipper_cmpid,
				shipper_address1	,
				shipper_address2	,
				shipper_cty_nmstct			,	
				shipper_primaryphone     ,
				consignee_name	,
				consignee_cmpid,
				consignee_address1	,
				consignee_address2	,
				consignee_cty_nmstct			,	
				consignee_primaryphone ,
				billto_name		,
				billto_address1		,
				billto_address2		,
				billto_cty_nmstct			,	
				billto_primaryphone,
			        stop_event,
			        order_number,
			        mov_number,
			        order_mintemp,
			        tractor_id,
			        driver1_id,
			        driver2_id,
			        trailer,
				trailer2,
			        ord_status,
			        ord_remarks,
				fgt_cmdcode_1,
				fgt_cmdcode_2,
				fgt_cmdcode_3,
				fgt_cmdcode_4,
			        fgt_description_1,
				fgt_description_2,
				fgt_description_3,
				fgt_description_4,
			        fgt_weight_1		,
				fgt_weight_2		,
				fgt_weight_3		,
				fgt_weight_4		,
			        fgt_volume_1		,
				fgt_volume_2		,
				fgt_volume_3		,
			 	fgt_volume_4		,
			        stp_lgh_mileage		,
			        evt_startdate		,
			        evt_earlydate		,
			        evt_latedate,
				refnum_header          ,
			        refnum_rail1	 ,
			        refnum_rail2,
			        refnum_cont_iso,
			        refnum_wt_1,
				refnum_wt_2,
				refnum_wt_3,
				refnum_wt_4,
	                        refnum_seal,
			        pup_drp,
			        stp_mfh_sequence,
	                        '',
	                        '',
				'',
			        '',
			        '',
	                        notes_1,
	                        notes_2,
	                        stp_number,
	                        load_requirements,
                                0, 
				lgh_number,
                                stp_cmpid
		   	   FROM #trips
	                  WHERE pup_drp = 'P' and 
                                stp_mfh_sequence = @v_sequence
                                 
			
		   END                 

		   --print 'update seq  '+ cast(@v_sequence as varchar(20))
	       	   SET @v_drp_sequence = @v_sequence + 1		 
			
		 END

UPDATE #trips
   SET pup_cnt = @pup_cnt


--Populate multiple 'WT' reference numbers and freightdetail
BEGIN	
	--PRINT 'let the games begin'

	SELECT @v_rs = ','
	SELECT @v_cnt = 0
	SELECT @v_ord_hdr = 0
        SELECT @v_stp_num = 0
 	SELECT @v_fgt_num = 0
        SELECT @v_ref_num = ''
	SELECT @v_fgt_seq = 0
	select @v_sequence = 0
	select @v_next_sequence = 0
	select @v_pupdrp = 0
	select @v_stp_test = 0
	
	

	WHILE (SELECT COUNT(*) 
		 FROM #trips 
		WHERE mov_number = @v_mov_number and   
                      order_number > @v_ord_hdr) >0
		BEGIN
	  
			SELECT @v_ord_hdr = MIN(order_number) 
		          FROM #trips
		         WHERE mov_number = @v_mov_number and	
			       order_number > @v_ord_hdr 

			--print 'order number '+ cast(@v_ord_hdr as varchar(20))			
     
			WHILE (select COUNT(*)
	                         from #trips
	                        where stp_number > @v_stp_num 
	                          and order_number = @v_ord_hdr) > 0

			BEGIN
				SELECT @v_stp_num = min(stp_number)
	                          FROM #trips
	                         WHERE order_number = @v_ord_hdr
	                           and stp_number > @v_stp_num 

				--print 'stop number '+ cast(@v_stp_num as varchar(20))				
		
				WHILE (SELECT COUNT(*)
                                         FROM FREIGHTDETAIL,#trips
                                        WHERE FREIGHTDETAIL.FGT_NUMBER > @V_FGT_NUM
                                          AND FREIGHTDETAIL.STP_NUMBER = @v_stp_num
                                          AND #trips.STP_NUMBER = @v_stp_num ) > 0 					

					BEGIN	
						--print 'stop number '+ cast(@v_stp_num as varchar(20))
						--print 'counter is '+ cast(@v_cnt as varchar(20))
						
						SELECT @v_fgt_num = min(fgt_number)
			                  	  FROM freightdetail
						 WHERE stp_number = @v_stp_num
						   and fgt_number > @v_fgt_num 

						--print 'freight number '+ cast(@V_FGT_NUM as varchar(20))
						
						SELECT @v_cnt = @v_cnt + 1	
						
						--print 'counter is '+ cast(@v_cnt as varchar(20))
						
						SELECT @v_ref_num = isnull(ref_number,'')
						  FROM referencenumber
						 WHERE ref_tablekey = @v_fgt_num						   
			                           and ord_hdrnumber = @v_ord_hdr
						   and (ref_table='freightdetail' and ord_hdrnumber <> 0)						   
				                   and ref_type IN ('WT')	
                                                   and ref_sequence = (select min(ref_sequence)
                                                                         from referencenumber
                                                                        where ref_tablekey = @v_fgt_num									 
			                           			  and ord_hdrnumber = @v_ord_hdr
						   			  and (ref_table='freightdetail' and ord_hdrnumber <> 0)									  
				                   			  and ref_type IN ('WT'))	

						--print 'reference number '+ isnull(@v_ref_num,'no refnumber for this fgt number')

						 IF @v_cnt = 1
						   BEGIN
   	 			   		     	update #trips 
                                                   	   set refnum_wt_1 = @v_ref_num
							 where order_number = @v_ord_hdr
														
                                                   	update #trips
                                                           set fgt_cmdcode_1 = fgt.cmd_code,
                                                               fgt_weight_1 = fgt.fgt_weight,
							       fgt_volume_1 = fgt.fgt_volume,
                                                               fgt_description_1 = fgt.fgt_description
                                                          from freightdetail fgt
                                                         where --fgt.fgt_sequence = @v_cnt or 
                                                               fgt.fgt_number = @v_fgt_num
                                                           --and fgt.stp_number = @v_stp_num
							   and fgt.stp_number = #trips.stp_number
							   and #trips.stp_number = @v_stp_num
								
							--print 'update record '+ cast(@v_cnt as varchar(20))
                                                            
						   END
						
						   IF @v_cnt = 2
						   BEGIN
   	 			   		     	update #trips 
                                                   	   set refnum_wt_2 = @v_ref_num
							 where order_number = @v_ord_hdr							
						
						       Select @v_fgt_seq = fgt.fgt_sequence								
							 from freightdetail fgt
                                                        where fgt.fgt_number = @v_fgt_num
                                                          and fgt.stp_number = @v_stp_num
							
							--print 'freight sequence '+ cast(@v_fgt_seq as varchar(20))
							
							IF @v_fgt_seq = 1
							  BEGIN
								update #trips
	                                                           set fgt_cmdcode_1 = fgt.cmd_code,
	                                                               fgt_weight_1 = fgt.fgt_weight,
								       fgt_volume_1 = fgt.fgt_volume,
	                                                               fgt_description_1 = fgt.fgt_description
	                                                          from freightdetail fgt
	                                                         where --fgt.fgt_sequence = @v_cnt 
	                                                           fgt.fgt_number = @v_fgt_num
	                                                           --and fgt.stp_number = @v_stp_num
								   and fgt.stp_number = #trips.stp_number
								   and #trips.stp_number = @v_stp_num
							  END
							ELSE
							  BEGIN
								update #trips
	                                                           set fgt_cmdcode_2 = fgt.cmd_code,
	                                                               fgt_weight_2 = fgt.fgt_weight,
								       fgt_volume_2 = fgt.fgt_volume,
	                                                               fgt_description_2 = fgt.fgt_description
	                                                          from freightdetail fgt
	                                                         where --fgt.fgt_sequence = @v_cnt 
	                                                           fgt.fgt_number = @v_fgt_num
	                                                           --and fgt.stp_number = @v_stp_num
								   and fgt.stp_number = #trips.stp_number
								   and #trips.stp_number = @v_stp_num
							  END
						   	--print 'update record '+ cast(@v_cnt as varchar(20))
							
						   END
				
						    IF @v_cnt = 3
						   BEGIN
   	 			   		     	update #trips 
                                                   	   set refnum_wt_3 = @v_ref_num
							 where order_number = @v_ord_hdr
							
							Select @v_fgt_seq = fgt.fgt_sequence								
							 from freightdetail fgt
                                                        where fgt.fgt_number = @v_fgt_num
                                                          and fgt.stp_number = @v_stp_num
							
							IF @v_fgt_seq = 1
							  BEGIN
								update #trips
	                                                           set fgt_cmdcode_1 = fgt.cmd_code,
	                                                               fgt_weight_1 = fgt.fgt_weight,
								       fgt_volume_1 = fgt.fgt_volume,
	                                                               fgt_description_1 = fgt.fgt_description
	                                                          from freightdetail fgt
	                                                         where --fgt.fgt_sequence = @v_cnt 
	                                                           fgt.fgt_number = @v_fgt_num
	                                                           --and fgt.stp_number = @v_stp_num
								   and fgt.stp_number = #trips.stp_number
								   and #trips.stp_number = @v_stp_num
							  END
							ELSE
							  BEGIN
								update #trips
	                                                           set fgt_cmdcode_3 = fgt.cmd_code,
	                                                               fgt_weight_3 = fgt.fgt_weight,
								       fgt_volume_3 = fgt.fgt_volume,
	                                                               fgt_description_3 = fgt.fgt_description
	                                                          from freightdetail fgt
	                                                         where --fgt.fgt_sequence = @v_cnt 
	                                                           fgt.fgt_number = @v_fgt_num
	                                                           --and fgt.stp_number = @v_stp_num
								   and fgt.stp_number = #trips.stp_number
								   and #trips.stp_number = @v_stp_num
							  END
								
						   --print 'update record '+ cast(@v_cnt as varchar(20))
						  
						   END

						 IF @v_cnt = 4
						   BEGIN
   	 			   		     	update #trips 
                                                   	   set refnum_wt_4 = @v_ref_num
							 where order_number = @v_ord_hdr
							
							Select @v_fgt_seq = fgt.fgt_sequence								
							 from freightdetail fgt
                                                        where fgt.fgt_number = @v_fgt_num
                                                          and fgt.stp_number = @v_stp_num
							
							IF @v_fgt_seq = 1
							  BEGIN
								update #trips
	                                                           set fgt_cmdcode_1 = fgt.cmd_code,
	                                                               fgt_weight_1 = fgt.fgt_weight,
								       fgt_volume_1 = fgt.fgt_volume,
	                                                               fgt_description_1 = fgt.fgt_description
	                                                          from freightdetail fgt
	                                                         where --fgt.fgt_sequence = @v_cnt 
	                                                           fgt.fgt_number = @v_fgt_num
	                                                           --and fgt.stp_number = @v_stp_num
								   and fgt.stp_number = #trips.stp_number
								   and #trips.stp_number = @v_stp_num
							  END
							ELSE
							  BEGIN
								update #trips
	                                                           set fgt_cmdcode_4 = fgt.cmd_code,
	                                                               fgt_weight_4 = fgt.fgt_weight,
								       fgt_volume_4 = fgt.fgt_volume,
	                                                               fgt_description_4 = fgt.fgt_description
	                                                          from freightdetail fgt
	                                                         where --fgt.fgt_sequence = @v_cnt 
	                                                           fgt.fgt_number = @v_fgt_num
	                                                           --and fgt.stp_number = @v_stp_num
								   and fgt.stp_number = #trips.stp_number
								   and #trips.stp_number = @v_stp_num
							  END				   
						   --print 'update record 4'+ cast(@v_cnt as varchar(20))
						   
						   END
						
					SELECT @v_ref_num = ''	
					SELECT @v_fgt_seq = 0
					select @v_sequence = 0
					select @v_next_sequence = 0					
					END --Freightdetail
				SELECT @v_cnt = 0
				SELECT @v_fgt_num = 0			
          			END --STOPS
			SELECT @v_cnt = 0	
			--SELECT @v_stp_num = 0
 			--SELECT @v_fgt_num = 0
			END --Order/Move
END


--Populate EVENT EARLY AND LATE DATE
BEGIN	

	SELECT @v_stp_number = 0
	SELECT @V_NEXTSTP_NUMBER = 0
	SELECT @V_EARLY_DATE = '01/01/1950'
	SELECT @V_LATE_DATE = '12/31/2049'
	SELECT @v_drp_stpnumber = 0
	SELECT @V_SEQUENCE = 0
	SELECT @v_next_sequence = 0
	SELECT @evt_driver1 = ''
        SELECT @evt_driver2 = ''
        SELECT @evt_tractor = ''
        SELECT @evt_trailer1 = ''
        SELECT @evt_trailer2 = ''
	SELECT @v_nextdrp_sequence = 0
	SELECT @v_nextdrp_NUMBER = 0
	SELECT @v_nextdrp_seq = 0
	SELECT @v_cmp_id = ''
	SELECT @V_CNT = 0

	WHILE (SELECT COUNT(*) 
	 	FROM #trips 
		WHERE stp_mfh_sequence > @v_sequence and pup_drp = 'P') > 0

		BEGIN	
			--print 'JR'
			SELECT @v_sequence = min(stp_mfh_sequence)
                 	  FROM #trips
                 	 WHERE pup_drp = 'P' and 
                       	      stp_mfh_sequence > @v_sequence

			--print 'CURRENT SEQ'+ cast(@v_sequence as varchar(20))

			SELECT @v_next_sequence = isnull(min(stp_mfh_sequence),999)
                  	  FROM #trips
                 	 WHERE pup_drp = 'P' and
                               stp_mfh_sequence > @v_sequence	

			SELECT @v_nextdrp_sequence = isnull(min(stp_mfh_sequence),999)
                  	  FROM #trips
                 	 WHERE pup_drp = 'P' and
                               stp_mfh_sequence > @v_sequence	

			--print 'NEXT SEQ'+ cast(@v_next_sequence as varchar(20))

	  		SELECT @v_stp_number = stp_number 
		          FROM #trips
		         WHERE stp_number > @v_stp_number 
                           AND PUP_DRP = 'P'
			   and stp_mfh_sequence = @v_sequence		

			--Print 'CURRENT STOP '+CAST(@V_STP_NUMBER AS VARCHAR(20))	

			SELECT @V_NEXTSTP_NUMBER = isnull(min(STP_NUMBER),999)
                          FROM #trips
		         WHERE PUP_DRP = 'D'
			   and stop_event <> 'DMT'
			   and stp_mfh_sequence between @v_sequence and @v_next_sequence

 			SELECT @v_nextdrp_seq = isnull(min(stp_mfh_sequence),999)
                  	  FROM #trips
                 	 WHERE PUP_DRP = 'D'
			   AND stop_event <> 'DMT'
			   and stp_mfh_sequence between @v_sequence and @v_next_sequence
			
			--Print  'NEXT STOP '+CAST(@V_NEXTSTP_NUMBER AS VARCHAR(20))
			
			SELECT @V_LATE_DATE = EVT_startDATE 
                          FROM EVENT
                         WHERE STP_NUMBER = @V_NEXTSTP_NUMBER

			select @evt_driver1 = evt_driver1,
                  	       @evt_driver2 = evt_driver2,
                               @evt_tractor = evt_tractor,
                               @evt_trailer1 = evt_trailer1,
                               @evt_trailer2 = evt_trailer2
			  from event
                         where STP_NUMBER = @v_stp_number
			
			--print @V_EARLY_DATE			
			--print @V_late_DATE

			UPDATE #TRIPS
			   SET EVT_startDATE = @V_EARLY_DATE ,
			       EVT_LATEDATE  = 	@V_late_DATE,
			       pickup_trailer   = @evt_trailer1,
       			       pickup_trailer2   = @evt_trailer2,
			       pickup_tractor_id = @evt_tractor ,
			       pickup_driver1    = @evt_driver1,
			       pickup_driver2    = @evt_driver2                             
			  WHERE --stp_mfh_sequence between @v_sequence and @v_next_sequence 
				stp_number = @v_nextstp_number
				and pup_drp = 'D' 
                                and stop_event <> 'DMT'
			
			SELECT @v_cmp_id = STP_CMPID
                          FROM #TRIPS
                         WHERE 	stp_number = @v_nextstp_number
				and pup_drp = 'D' 
                                and stop_event <> 'DMT'

			--PRINT @v_cmp_id

			UPDATE #TRIPS
		           SET consignee_name	= consignee.cmp_name	,	
			       consignee_cmpid = consignee.cmp_id,
			       consignee_address1 =consignee.cmp_address1,	
			       consignee_address2 =consignee.cmp_address2,	
			       consignee_cty_nmstct = consignee.cty_nmstct, -- 41158 consignee_cty.cty_nmstct	,				
			       consignee_primaryphone =consignee.cmp_primaryphone 
			  FROM COMPANY CONSIGNEE, city consignee_cty
                         WHERE CONSIGNEE.CMP_ID = @v_cmp_id AND
                              -- 41158 consignee_cty.cty_code = CONSIGNEE.cmp_city AND
                               stp_number = @v_nextstp_number
			       and pup_drp = 'D' 
                               and stop_event <> 'DMT'

			SELECT @v_cmp_id = STP_CMPID
                          FROM #TRIPS
                         WHERE 	stp_number = @v_stp_number
				and pup_drp = 'P' 
                                			
			UPDATE #TRIPS
		           SET SHIPPER_name	= SHIPPER.cmp_name	,	
			       SHIPPER_cmpid = SHIPPER.cmp_id,
			       SHIPPER_address1 =SHIPPER.cmp_address1,	
			       SHIPPER_address2 =SHIPPER.cmp_address2,	
			       SHIPPER_cty_nmstct = SHIPPER.cty_nmstct,  -- 41158 SHIPPER_cty.cty_nmstct	,				
			       SHIPPER_primaryphone =SHIPPER.cmp_primaryphone 
			  FROM COMPANY SHIPPER, city SHIPPER_cty
                         WHERE SHIPPER.CMP_ID = @v_cmp_id AND
                               --  41158 SHIPPER_cty.cty_code = SHIPPER.cmp_city AND
                               stp_number = @v_stp_number
			       and pup_drp = 'P'                                
			
			IF @v_next_sequence = 999 --PICKUP SEQUENCE
			   BEGIN	
				--print 'CURRENT DROP SEQUENCE'+ cast(@v_nextdrp_seq as varchar(20))
				--PRINT 'IMARI'	
			 	WHILE (SELECT COUNT(*)   
			     		 FROM #trips
		         		WHERE PUP_DRP = 'D'
			   		  and stop_event <> 'DMT'
			   		  and stp_mfh_sequence > @v_nextdrp_seq)>0
				
					BEGIN						
						
						SELECT @v_nextdrp_seq = isnull(min(STP_MFH_SEQUENCE),999)
                          			  FROM #trips
						 WHERE PUP_DRP = 'D'
			   		           and stop_event <> 'DMT'
			   		          and stp_mfh_sequence > @v_nextdrp_seq
						
						--print 'NEXT DROP SEQ'+ cast(@v_nextdrp_seq as varchar(20))						

						SELECT @v_next_sequence = isnull(min(stp_mfh_sequence),999)
			                  	  FROM #trips
			                 	 WHERE pup_drp = 'D' and
			                                stp_MFH_SEQUENCE > @v_nextdrp_seq	

						--print 'NEXT DROP SEQ'+ cast(@v_next_sequence as varchar(20))						
						
						SELECT @v_nextdrp_number = isnull(min(STP_NUMBER),999)
                          			  FROM #trips
						 WHERE PUP_DRP = 'D'
			   		           and stop_event <> 'DMT'
			   		           and stp_mfh_sequence = @v_nextdrp_seq
						
						--print 'NEXT NEXT DROP NUMBER'+ cast(@v_nextdrp_number as varchar(20))

						SELECT @V_NEXTSTP_NUMBER = isnull(min(STP_NUMBER),999)
                          			  FROM #trips
						 WHERE PUP_DRP = 'D'
			   		           and stop_event <> 'DMT'
			   		           and stp_mfh_sequence = @v_next_sequence

						--print 'NEXT NEXT STOP NUMBER'+ cast(@V_NEXTSTP_NUMBER as varchar(20))
												
						SELECT @V_EARLY_DATE = EVT_startDATE 
			                          FROM EVENT
			                         WHERE STP_NUMBER = @v_nextdrp_number						
						   			

						IF @V_NEXTSTP_NUMBER = 999
						   BEGIN
							--PRINT 'IMARI 999'

							SELECT @V_LATE_DATE = EVT_ENDDATE 
			                        	  FROM EVENT
			                        	 WHERE STP_NUMBER = @V_NEXTDRP_NUMBER
						   END
						ELSE
						   BEGIN
							--PRINT 'IMARI NOT 999'
							SELECT @V_LATE_DATE = EVT_startDATE 
			                          	  FROM EVENT
			                         	 WHERE STP_NUMBER = @V_NEXTSTP_NUMBER
						   END
						--print 'unloading date ' + cast(@V_EARLY_DATE as varchar(20))			
						--print 'loading date ' + cast(@V_late_DATE as varchar(20))						
						
						IF @V_NEXTSTP_NUMBER = 999
						   BEGIN
							UPDATE #TRIPS
							   SET --EVT_startDATE = @V_EARLY_DATE ,
							       --EVT_LATEDATE  = @V_late_DATE,
							       EVT_LATEDATE  = 	@V_EARLY_DATE,
							       pickup_trailer   = @evt_trailer1,
				       			       pickup_trailer2   = @evt_trailer2,
							       pickup_tractor_id = @evt_tractor ,
							       pickup_driver1    = @evt_driver1,
							       pickup_driver2    = @evt_driver2                             
							  WHERE stp_number = @V_NEXTDRP_NUMBER
								and pup_drp = 'D' 
				                                and stop_event <> 'DMT'		

							  SELECT @v_cmp_id = STP_CMPID
				                            FROM #TRIPS
				                           WHERE stp_number = @V_NEXTDRP_NUMBER
								and pup_drp = 'D' 
				                                and stop_event <> 'DMT'

							--print 'NEXT NEXT DROP NUMBER'+ cast(@v_nextdrp_number as varchar(20))
							--PRINT @v_cmp_id

							UPDATE #TRIPS
						           SET consignee_name	= consignee.cmp_name	,	
							       consignee_cmpid = consignee.cmp_id,
							       consignee_address1 =consignee.cmp_address1,	
							       consignee_address2 =consignee.cmp_address2,	
							       consignee_cty_nmstct = consignee.cty_nmstct, -- 41158  consignee_cty.cty_nmstct	,				
							       consignee_primaryphone =consignee.cmp_primaryphone 
							  FROM COMPANY CONSIGNEE, city consignee_cty
                        				 WHERE CONSIGNEE.CMP_ID = @v_cmp_id AND
                               				      -- 41158  consignee_cty.cty_code = CONSIGNEE.cmp_city AND
                                                               stp_number = @V_NEXTDRP_NUMBER 
							       and pup_drp = 'D' 
				                               and stop_event <> 'DMT'
						    END
						ELSE
						    BEGIN
							  --PRINT 'IMARI NOT 999 AGAIN'
							  
							  UPDATE #TRIPS
							   SET --EVT_startDATE = @V_EARLY_DATE ,
							       --EVT_LATEDATE  = @V_late_DATE,	
							       EVT_LATEDATE = @V_EARLY_DATE,				      	
							       pickup_trailer   = @evt_trailer1,
				       			       pickup_trailer2   = @evt_trailer2,
							       pickup_tractor_id = @evt_tractor ,
							       pickup_driver1    = @evt_driver1,
							       pickup_driver2    = @evt_driver2                             
							  WHERE stp_number = @V_NEXTDRP_NUMBER
								and pup_drp = 'D' 
				                                and stop_event <> 'DMT'
							  
							  SELECT @v_cmp_id = STP_CMPID
				                            FROM #TRIPS
				                           WHERE  stp_number = @V_NEXTDRP_NUMBER
								and pup_drp = 'D' 
				                                and stop_event <> 'DMT'

                                                       -- print 'NEXT STOP NUMBER'+ cast(@V_NEXTDRP_NUMBER as varchar(20)) 
							--PRINT @v_cmp_id

							UPDATE #TRIPS
						           SET consignee_name	= consignee.cmp_name	,	
							       consignee_cmpid = consignee.cmp_id,
							       consignee_address1 =consignee.cmp_address1,	
							       consignee_address2 =consignee.cmp_address2,	
							       consignee_cty_nmstct =consignee.cty_nmstct,  -- 41158  consignee_cty.cty_nmstct	,				
							       consignee_primaryphone =consignee.cmp_primaryphone 
							  FROM COMPANY CONSIGNEE, city consignee_cty
                         				 WHERE CONSIGNEE.CMP_ID = @v_cmp_id AND
                                                            --  41158     consignee_cty.cty_code = CONSIGNEE.cmp_city AND
							       stp_number = @V_NEXTDRP_NUMBER
							       and pup_drp = 'D' 
				                               and stop_event <> 'DMT'
						   END				
					  	
					END
				   
				END
				
		END

END

UPDATE #trips
   SET trailer = evt_trailer1,
       trailer2 = evt_trailer2,
       tractor_id = evt_tractor ,
       driver1_id = evt_driver1,
       driver2_id = evt_driver2
  FROM EVENT EVT
 WHERE EVT.STP_NUMBER IN (SELECT STP_NUMBER
                            FROM #trips) AND
       pup_drp = 'D' 

UPDATE #trips
   SET pickup_trailer   = evt_trailer1,
       pickup_trailer2   = evt_trailer2,
       pickup_tractor_id = evt_tractor ,
       pickup_driver1    = evt_driver1,
       pickup_driver2    = evt_driver2
  FROM EVENT EVT
 WHERE EVT.STP_NUMBER IN (SELECT STP_NUMBER
                            FROM #trips) AND
       pup_drp = 'D'

SELECT @v_cmp_id = STP_CMPID,
       @v_stp_number = stp_number
  FROM #TRIPS
 WHERE 	pup_drp = 'D' 
        and stop_event = 'DMT'

UPDATE #TRIPS
   SET consignee_name	= consignee.cmp_name	,	
       consignee_cmpid = consignee.cmp_id,
       consignee_address1 =consignee.cmp_address1,	
       consignee_address2 =consignee.cmp_address2,	
       consignee_cty_nmstct =consignee.cty_nmstct,  -- 41158 consignee_cty.cty_nmstct	,				
       consignee_primaryphone =consignee.cmp_primaryphone ,
       #TRIPS.evt_startdate = evt.evt_startdate
  FROM COMPANY CONSIGNEE, city consignee_cty, event evt
 WHERE CONSIGNEE.CMP_ID = @v_cmp_id --  41158 AND
      --  41158  consignee_cty.cty_code = CONSIGNEE.cmp_city        
       and pup_drp = 'D' 
       and stop_event = 'DMT'
       and evt.stp_number = @v_stp_number

select @v_cnt = count(*) 
  from #trips 
 where stop_event = 'LLD'

IF @v_cnt = 1 
  BEGIN
    SELECT @v_stp_number = 0
    SELECT @v_stp_number = stp_number
      FROM #TRIPS
     WHERE stop_event = 'LLD'

   --print cast(@v_stp_number as varchar(20))

    UPDATE #TRIPS
       SET #TRIPS.EVT_startDATE = evt.evt_startdate	
      FROM event evt
     WHERE #TRIPS.pup_drp = 'D' 
       AND evt.stp_number = @v_stp_number
  END

SELECT	shipper_name	,
	shipper_cmpid,
	shipper_address1	,
	shipper_address2	,
	shipper_cty_nmstct			,	
	shipper_primaryphone     ,
	consignee_name	,
	consignee_cmpid,
	consignee_address1	,
	consignee_address2	,
	consignee_cty_nmstct			,	
	consignee_primaryphone ,
	billto_name		,
	billto_address1		,
	billto_address2		,
	billto_cty_nmstct			,	
	billto_primaryphone,
        stop_event,
        order_number,
        mov_number,
        order_mintemp,
        tractor_id,
        driver1_id,
        driver2_id,
        trailer,
	trailer2,
	lbf.name ord_status,       
        ord_remarks,
	fgt_cmdcode_1,
	fgt_cmdcode_2,
	fgt_cmdcode_3,
	fgt_cmdcode_4,
        fgt_description_1,
	fgt_description_2,
	fgt_description_3,
	fgt_description_4,
        fgt_weight_1		,
	fgt_weight_2		,
	fgt_weight_3		,
	fgt_weight_4		,
	fgt_volume_1		,
	fgt_volume_2		,
	fgt_volume_3		,
	fgt_volume_4		,
        stp_lgh_mileage		,
        evt_startdate		,
        evt_earlydate		,
        evt_latedate,
	refnum_header          ,
        refnum_rail1	 ,
        refnum_rail2,
        refnum_cont_iso,
        refnum_wt_1,
	refnum_wt_2,
	refnum_wt_3,
	refnum_wt_4,
        refnum_seal,
        pup_drp,
        stp_mfh_sequence,
        pickup_driver1,
        pickup_driver2,
	pickup_tractor_id     ,
        pickup_trailer        ,
        pickup_trailer2        ,
        notes_1,
        notes_2,
        stp_number,
        load_requirements,
        pup_cnt,
	lgh_number
	
   FROM #trips   
        join labelfile as lbf on ( lbf.abbr = #trips.ord_status)
   WHERE lbf.labeldefinition = 'DispStatus' 
    and (pup_drp = 'D' or stop_event = 'DMT')
   ORDER BY stp_mfh_sequence
   --ORDER BY stp_number
   --order by pup_drp desc, stp_mfh_sequence

GO
GRANT EXECUTE ON  [dbo].[d_drvdelticket_format03_sp] TO [public]
GO
