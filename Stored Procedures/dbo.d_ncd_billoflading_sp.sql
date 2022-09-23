SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ncd_billoflading_sp](@p_ordnum int)
AS

/**
 * 
 * NAME:
 * dbo.d_ncd_billoflading_sp
 *
 * TYPE:
 * Stored Procedure 
 *
 * DESCRIPTION:
 * This trigger returns the information necessary for the NCD Bill of Lading Format
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * Set of data to be printed on NCD's custom bill of lading format
 *
 * PARAMETERS:
 * @p_ordnum	int	Ord Hdrnumber for which to retrieve the information
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * none
 *
 * 
 * REVISION HISTORY:
 * 12/23/05.01 ? PTS28716 - DHUDE ? Created Procedure
 * 10/31/2007.01 ? PTS40115 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE	@v_pu_trc_number	varchar(8),
	@v_pu_trl_number	varchar(8),
	@v_del_trc_number	varchar(8),
	@v_del_trl_number	varchar(8),
	@v_lh_drv_code		varchar(8),
	@v_splt_trl_number	varchar(8),
	@v_bol_refnum		varchar(100),
	@v_ref_refnum		varchar(100),
	@v_hazmat		char(1),
	@v_collect_terms	varchar(1),
	@v_prepaid_terms	varchar(1),
	@v_credit_terms		varchar(10),
	@v_shipper_id		varchar(8),
	@v_showshipper		varchar(8),
	@v_consignee_id		varchar(8),
	@v_showconsignee	varchar(8),
	@v_pu_lgh_number	int,
	@v_del_lgh_number	int,
	@v_mov_number		int,
	@v_pup_date		datetime,
	@v_cmd_hazardous	int,
	@v_ord_terms		varchar(6),
	@v_ord_rate		decimal(9, 2),
	@v_total_charge		decimal(9, 2),
	@v_alt_ord_number	int,
	@v_ord_number_list	varchar(50),
	@v_i			int,
	@v_total_orders		int,
	@v_temp_bol_refnum	varchar(30),
	@v_temp_ref_refnum	varchar(30),
	@v_ord_remark		varchar(254),
	@v_ord_remark2		varchar(254),
	@v_ord_revtype2		varchar(20)

SELECT 	@v_mov_number = min(mov_number)
  FROM	stops
 WHERE	ord_hdrnumber = @p_ordnum

SELECT	@v_total_orders = count(distinct(ord_hdrnumber))
FROM	stops
WHERE	ord_hdrnumber <> '0'
AND	mov_number = @v_mov_number

SELECT 	@v_ord_revtype2 = name
FROM	labelfile
WHERE	abbr = (SELECT 	ord_revtype2
		FROM	orderheader
		WHERE	ord_hdrnumber = @p_ordnum)

SELECT 	@v_i = 1
SELECT	@v_ord_number_list = ''
SELECT	@v_alt_ord_number = 0
SELECT	@v_bol_refnum = ''
SELECT	@v_ref_refnum = ''

WHILE	@v_i <= @v_total_orders
 BEGIN
	SELECT	@v_alt_ord_number = min(ord_hdrnumber)
	FROM	stops
	WHERE	mov_number = @v_mov_number
	AND	ord_hdrnumber <> '0'
	AND	ord_hdrnumber > @v_alt_ord_number

	SELECT 	@v_temp_bol_refnum = referencenumber.ref_number
  	FROM 	referencenumber
 	WHERE 	referencenumber.ord_hdrnumber = @v_alt_ord_number and
       		referencenumber.ref_type = 'B/L#' and
       		referencenumber.ref_table = 'orderheader'  

	SELECT 	@v_temp_ref_refnum = referencenumber.ref_number
	FROM 	referencenumber
	WHERE 	referencenumber.ord_hdrnumber = @v_alt_ord_number and
       		referencenumber.ref_type = 'REF#' and
       		referencenumber.ref_table = 'orderheader'

	SELECT	@v_ord_remark = ord_remark
	FROM	orderheader
	WHERE	ord_hdrnumber = @v_alt_ord_number

	IF @v_i = @v_total_orders
	 BEGIN
		SELECT	@v_ord_number_list = @v_ord_number_list + cast(@v_alt_ord_number as varchar(8))
		SELECT	@v_bol_refnum = @v_bol_refnum + @v_temp_bol_refnum
		SELECT	@v_ref_refnum = @v_ref_refnum + @v_temp_ref_refnum
	
		IF @v_total_orders <> 1
		 BEGIN		
			SELECT	@v_ord_remark2 = ord_remark
			FROM	orderheader
			WHERE	ord_hdrnumber = @v_alt_ord_number
		 END
	 END
	ELSE IF @v_i = 1
	 BEGIN
		SELECT	@v_ord_number_list = cast(@v_alt_ord_number as varchar(8)) + ' / '
		SELECT	@v_bol_refnum = @v_temp_bol_refnum + ' / '
		SELECT	@v_ref_refnum = @v_temp_ref_refnum + ' / '

		SELECT	@v_ord_remark = ord_remark
		FROM	orderheader
		WHERE	ord_hdrnumber = @v_alt_ord_number
	 END
	ELSE	
	 BEGIN
		SELECT	@v_ord_number_list = @v_ord_number_list + cast(@v_alt_ord_number as varchar(8)) + ' / '
		SELECT	@v_bol_refnum = @v_bol_refnum + @v_temp_bol_refnum + ' / '
		SELECT	@v_ref_refnum = @v_ref_refnum + @v_temp_ref_refnum + ' / '
	 END

	SELECT	@v_i = @v_i + 1
 END

SELECT	@v_pu_lgh_number = lgh_number
  FROM	stops
 WHERE	stp_sequence = (select 	min(stp_sequence)
			from	stops
			where	stp_type = 'PUP'
			and	mov_number = @v_mov_number)
   AND	mov_number = @v_mov_number
   AND	stp_type = 'PUP'

SELECT	@v_del_lgh_number = lgh_number
  FROM	stops
 WHERE	stp_sequence = (select 	min(stp_sequence)
			from	stops
			where	stp_type = 'DRP'
			and	mov_number = @v_mov_number)
   AND	mov_number = @v_mov_number
   AND  stp_type = 'DRP'

SELECT	@v_pup_date = stp_arrivaldate
  FROM	stops
 WHERE	stp_sequence = (select 	min(stp_sequence)
			from	stops
			where	stp_type = 'PUP'
			and	mov_number = @v_mov_number)
   AND	mov_number = @v_mov_number
   AND  stp_type = 'PUP'

SELECT 	@v_pu_trc_number = lgh_tractor
  FROM	legheader
 WHERE	lgh_number = @v_pu_lgh_number

SELECT 	@v_pu_trl_number = lgh_primary_trailer
  FROM	legheader
 WHERE	lgh_number = @v_pu_lgh_number

SELECT 	@v_del_trc_number = lgh_tractor
  FROM	legheader
 WHERE	lgh_number = @v_del_lgh_number

SELECT 	@v_del_trl_number = lgh_primary_trailer
  FROM	legheader
 WHERE	lgh_number = @v_del_lgh_number

--Check validity
SELECT 	@v_lh_drv_code = lgh_driver1
  FROM	legheader
 WHERE	lgh_number = @v_del_lgh_number

SELECT @v_splt_trl_number = lgh_primary_trailer
  FROM	legheader
 WHERE	lgh_number = @v_del_lgh_number
--Check validity

SELECT  @v_cmd_hazardous = cmd_hazardous
  FROM	commodity
 WHERE  cmd_code = (SELECT distinct(fgt.cmd_code)
		      FROM stops stp,
    		 	   orderheader ord,  
    		    	   freightdetail fgt
      		     WHERE ord.ord_hdrnumber = @p_ordnum AND
      			   stp.ord_hdrnumber = ord.ord_hdrnumber AND
			   stp.stp_number = fgt.stp_number AND
      			   stp.stp_event = 'LUL') 

IF @v_cmd_hazardous = 1
	SELECT @v_hazmat = 'Y'
Else
	SELECT @v_hazmat = 'N'

SELECT 	@v_collect_terms = '',
       	@v_prepaid_terms = ''

SELECT 	@v_credit_terms = cmp_terms
  FROM 	company
 WHERE 	cmp_id = (select ord_destpoint
		   from	orderheader
		  where	ord_hdrnumber = @p_ordnum)

IF @v_credit_terms = 'COL'
	SELECT @v_collect_terms = 'X'

IF @v_credit_terms = 'PPD'
	SELECT @v_prepaid_terms = 'X'

SELECT	@v_ord_terms = ord_terms
  FROM	orderheader
 WHERE	ord_hdrnumber = @p_ordnum

IF @v_ord_terms = 'COD'
 BEGIN
	SELECT	@v_ord_rate = cast(ord_rate as decimal(9,2)),
		@v_total_charge	= cast(ord_charge as decimal(9,2))
	FROM	orderheader
	WHERE 	ord_hdrnumber = @p_ordnum
 END
ELSE
 BEGIN
	SELECT	@v_ord_rate = 0,
		@v_total_charge = 0
 END

CREATE TABLE #ncdbol (
pu_trc_number		varchar(8) NULL,
pu_trl_number		varchar(8) NULL,
del_trc_number		varchar(8) NULL,
del_trl_number		varchar(8) NULL,
lh_drv_code		varchar(8) NULL,
splt_trl_number		varchar(8) NULL,
bol_refnum		varchar(30) NULL,
ref_refnum		varchar(30) NULL,
ord_number		varchar(50) NULL,
quantity		decimal(9,2) NULL,
cmd_code		varchar(8) NULL,
hazmat			char(1) NULL,
ord_remark		varchar(254) NULL,
ord_remark2		varchar(254) NULL,
ord_revtype2		varchar(20),
fgt_weight		float NULL,
fgt_weightunit		varchar(6),
ord_rate		money NULL,
total_charge		money NULL,
collect_terms		varchar(1),
prepaid_terms		varchar(1),
cmd_description		varchar(254),
pickup_date 		datetime NULL, 
shipper_id 		varchar(8) NULL,
shipper_name 		varchar(100) NULL,
shipper_addr1 		varchar(100) NULL,
shipper_addr2 		varchar(100) NULL,
shipper_cty_name 	varchar(18) NULL,
shipper_cty_state 	varchar(6) NULL,
shipper_cty_zip 	varchar(10) NULL,
shipper_addr 		varchar(201) NULL,
consignee_id 		varchar(8) NULL,
consignee_name 		varchar(100) NULL,
consignee_addr1  	varchar(100) NULL,
consignee_addr2 	varchar(100) NULL,
consignee_cty_name 	varchar(18) NULL,
consignee_cty_state 	varchar(6) NULL,
consignee_cty_zip 	varchar(10) NULL,
consignee_addr 		varchar(201) NULL,
billto_id 		varchar(8) NULL,
billto_name 		varchar(100) NULL,
billto_addr1 	 	varchar(100) NULL,
billto_addr2 		varchar(100) NULL,
billto_cty_code 	INT NULL,
billto_cty_name 	varchar(18) NULL,
billto_cty_state 	varchar(6) NULL,
billto_cty_zip 		varchar(10) NULL,
billto_addr 		varchar(201) NULL,
)


INSERT INTO  #ncdbol 
SELECT       
       	IsNull(@v_pu_trc_number, ''),
       	IsNull(@v_pu_trl_number, ''),
       	IsNull(@v_del_trc_number, ''),
	IsNull(@v_del_trl_number, ''),
	IsNull(@v_lh_drv_code, ''),
	IsNull(@v_splt_trl_number, ''),
        IsNull(@v_bol_refnum, ''),
       	IsNull(@v_ref_refnum, ''),  
	IsNull(@v_ord_number_list, ''), 
	IsNull(STP.STP_COUNT, 0),
	IsNull(FGT.CMD_CODE, ''),
	IsNull(@v_hazmat, ''),   
       	IsNull(@v_ord_remark, ''), 
	IsNull(@v_ord_remark2, ''), 
	IsNull(@v_ord_revtype2, ''),    
       	IsNull(FGT.FGT_WEIGHT, ''),
	IsNull(FGT.FGT_WEIGHTUNIT, ''),
	IsNull(@v_ord_rate, 0),
	IsNull(@v_total_charge, 0),
	IsNull(@v_collect_terms, ''),
       	IsNull(@v_prepaid_terms, ''),
	IsNull(FGT.FGT_DESCRIPTION, ''),
	IsNull(@v_pup_date, ''),
	IsNull(shipper.cmp_id, ''),
       	IsNull(shipper.cmp_name, ''),
       	IsNull(shipper.cmp_address1, ''),
       	IsNull(shipper.cmp_address2, ''),
       	IsNull(shipper_cty.cty_name, ''),
       	IsNull(shipper_cty.cty_state, ''),
       	IsNull(shipper_cty.cty_zip, ''),
       	Case
	     When isnull(shipper.cmp_address2,' ') = ' ' Then shipper.cmp_address1
	     When isnull(shipper.cmp_address2,' ')<> ' ' Then shipper.cmp_address1+' '+shipper.cmp_address2
	     Else ' '
	     End ,	
       	IsNull(ORD.ORD_DESTPOINT, ''),
       	IsNull(consignee.cmp_name, ''),
       	IsNull(consignee.cmp_address1, ''),
       	IsNull(consignee.cmp_address2, ''),
       	IsNull(consignee_cty.cty_name, ''),
       	IsNull(consignee_cty.cty_state, ''),
       	IsNull(consignee_cty.cty_zip, ''),
       	Case
	     When isnull(consignee.cmp_address2,' ') = ' ' Then consignee.cmp_address1
	     When isnull(consignee.cmp_address2,' ')<> ' ' Then consignee.cmp_address1+' '+ consignee.cmp_address2
	     Else ' '
	     End ,
       	IsNull(ORD.ORD_BILLTO, ''),
       	IsNull(billto.cmp_name, ''),
       	IsNull(billto.cmp_address1, ''),
       	IsNull(billto.cmp_address2, ''),
       	IsNull(billto.cmp_city, ''),
       	(select IsNull(cty_name, '')
         from city 
         where cty_code = billto.cmp_city ),
       	(select IsNull(cty_state, '')
          from city 
         where cty_code = billto.cmp_city ),
       	(select IsNull(cty_zip, '')
          from city 
         where cty_code = billto.cmp_city ),    
       	Case
	     When isnull(billto.cmp_address2,' ') = ' ' Then billto.cmp_address1
	     When isnull(billto.cmp_address2,' ')<> ' ' Then billto.cmp_address1+' '+ billto.cmp_address2
	     Else ' '
	     End 
--pts40115 jguo outer join conversion
FROM ORDERHEADER ORD  LEFT OUTER JOIN  company shipper  ON  ORD.ord_shipper  = shipper.cmp_id   
		LEFT OUTER JOIN  company consignee  ON  ORD.ord_consignee  = consignee.cmp_id   
		LEFT OUTER JOIN  company billto  ON  ORD.ord_billto  = billto.cmp_id   
		LEFT OUTER JOIN  city consignee_cty  ON  ORD.ORD_destcity  = consignee_cty.cty_code   
		LEFT OUTER JOIN  city shipper_cty  ON  ORD.ORD_origincity  = shipper_cty.cty_code ,
	 LEGHEADER LGH  LEFT OUTER JOIN  MANPOWERPROFILE MP1  ON  LGH.LGH_DRIVER1  = MP1.MPP_ID   
		LEFT OUTER JOIN  MANPOWERPROFILE MP2  ON  LGH.LGH_DRIVER2  = MP2.MPP_ID ,
	 STOPS STP,
	 FREIGHTDETAIL FGT 
      
WHERE ORD.ORD_HDRNUMBER = @p_ordnum AND
      STP.ORD_HDRNUMBER = ORD.ORD_HDRNUMBER AND
      STP.MOV_NUMBER = LGH.MOV_NUMBER AND
      STP.STP_NUMBER = FGT.STP_NUMBER AND
      STP.STP_EVENT = 'LUL'        

--Display Show Shipper/Consignee if applicable
select @v_shipper_id = shipper_id,
       @v_consignee_id = consignee_id
  from #ncdbol

select @v_showshipper   = ord_showshipper,
       @v_showconsignee = ord_showcons
  from orderheader
 where ord_hdrnumber = @p_ordnum

If (@v_shipper_id <> @v_showshipper) and (@v_showshipper <> 'UNKNOWN') 
   Begin
    Update #ncdbol
       set #ncdbol.shipper_id = @v_showshipper,
	   #ncdbol.shipper_name = shipper.cmp_name,
           #ncdbol.shipper_addr1 = shipper.cmp_address1,
           #ncdbol.shipper_addr2 = shipper.cmp_address2,
	   #ncdbol.shipper_cty_name = shipper_cty.cty_name,
           #ncdbol.shipper_cty_state = shipper_cty.cty_state,
           #ncdbol.shipper_cty_zip = shipper_cty.cty_zip
       from company shipper,city shipper_cty, #ncdbol
      where @v_showshipper = shipper.cmp_id and
            shipper.cmp_city = shipper_cty.cty_code and
            #ncdbol.ord_number = @p_ordnum  
   End

If (@v_consignee_id <> @v_showconsignee) and (@v_showconsignee <> 'UNKNOWN')
   Begin
     Update #ncdbol
	set #ncdbol.consignee_id = @v_showconsignee,
	    #ncdbol.consignee_name = consignee.cmp_name,
            #ncdbol.consignee_addr1 = consignee.cmp_address1,
            #ncdbol.consignee_addr2 = consignee.cmp_address2,
	    #ncdbol.consignee_cty_name = consignee_cty.cty_name,
            #ncdbol.consignee_cty_state = consignee_cty.cty_state,
            #ncdbol.consignee_cty_zip = consignee_cty.cty_zip
       from company consignee,city consignee_cty, #ncdbol
      where @v_showconsignee = consignee.cmp_id and
            consignee.cmp_city = consignee_cty.cty_code and
            #ncdbol.ord_number = @p_ordnum	
   End
--Display Show Shipper/Consignee if applicable
  
SELECT top 1 * FROM #ncdbol
GO
GRANT EXECUTE ON  [dbo].[d_ncd_billoflading_sp] TO [public]
GO
