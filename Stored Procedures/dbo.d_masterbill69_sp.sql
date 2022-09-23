SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_masterbill69_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8),
                                    @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
                                    @shipstart datetime,@shipend datetime,@delstart datetime, @delend datetime,
                                    @billdate datetime,@shipper varchar(8), @consignee varchar(8),
                                    @copy int,@ivh_invoicenumber varchar(12), @fromorder varchar(12))
AS
/**
 * 
 * NAME:
 * dbo.d_masterbill69_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored procedure from d_mb_format69
 *
 * RETURNS:
 * 
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS: 
 *
 * 	001 - ivh_invoicenumber varchar(12),  
 *	002 - ivh_hdrnumber int NULL, 
 *	003 - ivh_billto varchar(8) NULL,
 *	004 - ivh_shipper varchar(8) NULL,
 *	005 - ivh_consignee varchar(8) NULL,
 *	006 - ivh_totalcharge money NULL,   
 *	007 - ivh_originpoint  varchar(8) NULL,  
 *	008 - ivh_destpoint varchar(8) NULL,   
 *	009 - ivh_origincity int NULL,   
 *	010 - ivh_destcity int NULL,   
 *	011 - ivh_shipdate datetime NULL,   
 *	012 - ivh_deliverydate datetime NULL,   
 *	013 - ivh_revtype1 varchar(6) NULL,
 *	014 - ivh_mbnumber int NULL,
 *	015 - ivh_shipper_name varchar(100) NULL ,
 *	016 - ivh_shipper_address varchar(100) NULL,
 *	017 - ivh_shipper_address2 varchar(100) NULL,
 *	018 - ivh_shipper_nmstct varchar(30) NULL ,
 *	019 - ivh_shipper_zip varchar(10) NULL,
 *	020 - ivh_billto_name varchar(100)  NULL,
 *	021 - ivh_billto_address varchar(100) NULL,
 *	022 - ivh_billto_address2 varchar(100) NULL,
 *	023 - ivh_billto_nmstct varchar(30) NULL ,
 *	024 - ivh_billto_zip varchar(10) NULL,
 *	025 - ivh_consignee_name varchar(100)  NULL,
 *	026 - ivh_consignee_address varchar(100) NULL,
 *	027 - ivh_consignee_address2 varchar(100) NULL,
 *	028 - ivh_consignee_nmstct varchar(30)  NULL,
 *	029 - ivh_consignee_zip varchar(10) NULL,
 *	030 - origin_nmstct varchar(30) NULL,
 *	031 - origin_state varchar(2) NULL,
 *	032 - dest_nmstct varchar(30) NULL,
 *	033 - dest_state varchar(2) NULL,
 *	034 - billdate datetime NULL,
 *	035 - cmp_mailto_name varchar(30)  NULL,
 *	036 - bill_quantity dec(9,2)  NULL,
 *	037 - ivd_weight float NULL,
 *	038 - ivd_weightunit char(6) NULL,
 *	039 - ivd_count float NULL,
 *	040 - ivd_countunit char(6) NULL,
 *	041 - ivd_volume float NULL,
 *	042 - ivd_volunit char(6) NULL,
 *	043 - ivd_unit char(6) NULL,
 *	044 - ivd_rate money NULL,
 *	045 - ivd_rateunit char(6) NULL,
 *	046 - ivd_charge money NULL,
 *	047 - cht_description varchar(30) NULL,
 *	048 - cht_primary char(1) NULL,
 *	049 - cmd_name varchar(60)  NULL,
 *	050 - ivd_description varchar(60) NULL,
 *	051 - ivd_type char(6) NULL,
 *	052 - stp_city int NULL,
 *	053 - stp_cty_nmstct varchar(25) NULL,
 *	054 - ivd_sequence int NULL,
 *	055 - stp_number int NULL,
 *	056 - copy int NULL,
 *	057 - cmp_id varchar(8) NULL,
 *	058 - cht_itemcode varchar(6)NULL,
 *	059 - load_total int NULL,
 *	060 - weight_total dec(9,2) NULL,
 *	061 - FSC_total money NULL,
 *	062 - Freight_total money NULL
 *	063 - BOL_Number varchar(30)NULL
 *	064 - ref_typedesc varchar(20) NULL
 *	065 - ord_fromorder varchar(12)NULL
 *	066 - ord_number char(12) null
 *	067 - tax_total money NULL
 *	068 - material_total money NULL
 *	069 - misc_total money NULL
 *	
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 10/7/99 dpete retrieve cmp_id for d_mb_format05
 * dpete pts6691 make ivd_count and volume floats on temp table
 * 07/25/2002 Vern Jewett (label=vmj1)          PTS 14924: lengthen ivd_description from 30 to 60 chars.
 * 11/06/06 PTS 34594 EMK Broke total freight into delivery, tax, material and misceallaneous totals
 * DPETE 64352 ADD MORE CODES 
 **/                                                                              
DECLARE @int0  int, 
        @v_FSC_total money, 
        @v_weight_total dec(9,2), 
        @v_freight_total money,
        @v_grand_total money,
        @v_loads_total int,
        @v_minord int,
        @v_minseq int,
        @v_ref_number varchar(30),
        @v_ref_typedesc varchar(20),
        @v_master_order varchar(12),
        @v_rate money,
        @v_quantity float,
        @v_charge money ,
	@v_cnt int,
	@v_seq int,    
	@v_showshipper varchar(8),
	@v_showcons varchar(8),
	@v_misc_total money     

-- PTS 34594 11/06/06 EMK - Begin
DECLARE @v_tax_total money,
		@v_material_total money

DECLARE @TaxTypes table (cht_itemcode varchar(6))
DECLARE @MaterialTypes table (cht_itemcode varchar(6))
DECLARE @FSCTypes table (cht_itemcode varchar(6))

INSERT INTO @TaxTypes  SELECT cht_itemcode FROM chargetype WHERE cht_itemcode IN ('SALEGC','TAX','TAXIN','TAXKY','TAXMO','SALESW','SALEIR','SALECD')
INSERT INTO @MaterialTypes  SELECT cht_itemcode FROM chargetype 
	WHERE cht_itemcode IN ('MATLKT','MATLH','MATFL','MATER','MATERS','MATCDL','MATFLS','MATHID','MATIDS','MATLCL','MATLHS','MATLKD','CQCMAL','CQCMAT','CQDMAL','CQDMAT','CQWMAL','CQWMAT','TRAMAL','TRAMAT')
INSERT INTO @FSCTypes  SELECT cht_itemcode FROM chargetype WHERE cht_itemcode IN ('FSC','FSCFIX','FSC3','FSCFIX','TERMFS','TRNSFU')
-- PTS 34594 11/06/06 EMK - End

SELECT @int0 = 0
SELECT @shipstart = convert(char(12),isnull(@shipstart,'19500101'))+'00:00:00'
SELECT @shipend   = convert(char(12),isnull(@shipend,'20491231') )+'23:59:59'
SELECT @delstart  = convert(char(12),isnull(@delstart,'19500101'))+'00:00:00'
SELECT @delend    = convert(char(12),isnull(@delend,'20491231')  )+'23:59:59'
CREATE TABLE #masterbill_temp (                  ord_hdrnumber int,
                        ivh_invoicenumber varchar(12),  
                        ivh_hdrnumber int NULL, 
                        ivh_billto varchar(8) NULL,
                        ivh_shipper varchar(8) NULL,
                        ivh_consignee varchar(8) NULL,
                        ivh_totalcharge money NULL,   
                        ivh_originpoint  varchar(8) NULL,  
                        ivh_destpoint varchar(8) NULL,   
                        ivh_origincity int NULL,   
                        ivh_destcity int NULL,   
                        ivh_shipdate datetime NULL,   
                        ivh_deliverydate datetime NULL,   
                        ivh_revtype1 varchar(6) NULL,
                        ivh_mbnumber int NULL,
                        ivh_shipper_name varchar(100) NULL ,
                        ivh_shipper_address varchar(100) NULL,
                        ivh_shipper_address2 varchar(100) NULL,
                        ivh_shipper_nmstct varchar(30) NULL ,
                        ivh_shipper_zip varchar(10) NULL,
                        ivh_billto_name varchar(100)  NULL,
                        ivh_billto_address varchar(100) NULL,
                        ivh_billto_address2 varchar(100) NULL,
                        ivh_billto_nmstct varchar(30) NULL ,
                        ivh_billto_zip varchar(10) NULL,
                        ivh_consignee_name varchar(100)  NULL,
                        ivh_consignee_address varchar(100) NULL,
                        ivh_consignee_address2 varchar(100) NULL,
                        ivh_consignee_nmstct varchar(30)  NULL,
                        ivh_consignee_zip varchar(10) NULL,
                        origin_nmstct varchar(30) NULL,
                        origin_state varchar(2) NULL,
                        dest_nmstct varchar(30) NULL,
                        dest_state varchar(2) NULL,
                        billdate datetime NULL,
                        cmp_mailto_name varchar(30)  NULL,
                        bill_quantity dec(9,2)  NULL,
                        ivd_weight float NULL,
                        ivd_weightunit char(6) NULL,
                        ivd_count float NULL,
                        ivd_countunit char(6) NULL,
                        ivd_volume float NULL,
                        ivd_volunit char(6) NULL,
                        ivd_unit char(6) NULL,
                        ivd_rate money NULL,
                        ivd_rateunit char(6) NULL,
                        ivd_charge money NULL,
                        cht_description varchar(30) NULL,
                        cht_primary char(1) NULL,
                        cmd_name varchar(60)  NULL,
                        --vmj1+
                        ivd_description varchar(60) NULL,
--                      ivd_description varchar(30) NULL,
                        --vmj1-
                        ivd_type char(6) NULL,
                        stp_city int NULL,
                        stp_cty_nmstct varchar(25) NULL,
                        ivd_sequence int NULL,
                        stp_number int NULL,
                        copy int NULL,
                        cmp_id varchar(8) NULL,
                cht_itemcode varchar(6)NULL,
                load_total int NULL,
                weight_total dec(9,2) NULL,
                FSC_total money NULL,
                Freight_total money NULL,
                BOL_Number varchar(30)NULL,
                ref_typedesc varchar(20) NULL,
                ord_fromorder varchar(12)NULL,
		tax char(1) NULL,
                cht_rollintolh int null,
		--06/29/2006 ILB
                ivh_showshipper varchar(8)null,
                ivh_showcons    varchar(8) null,
		--06/29/2006 ILB
 		ord_number char(12) null,
		-- PTS 34594 11/06/06 EMK - Begin
		tax_total money NULL,
		material_total money NULL,
		misc_total money NULL)
		-- PTS 34594 11/06/06 EMK - End
CREATE TABLE #MASTERBILL_TEMP2
(ivh_hdrnumber int NULL,
 rate money NULL,                    
 charge money NULL)
-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO         #masterbill_temp
    SELECT        IsNull(invoiceheader.ord_hdrnumber, -1),
                        invoiceheader.ivh_invoicenumber,  
                        invoiceheader.ivh_hdrnumber, 
                        invoiceheader.ivh_billto,
                        invoiceheader.ivh_shipper,
                        invoiceheader.ivh_consignee,   
                        invoiceheader.ivh_totalcharge,   
                        invoiceheader.ivh_originpoint,  
                        invoiceheader.ivh_destpoint,   
                        invoiceheader.ivh_origincity,   
                        invoiceheader.ivh_destcity,   
                        invoiceheader.ivh_shipdate, 
                        CAST( FLOOR( CAST( invoiceheader.ivh_deliverydate AS FLOAT ) ) AS DATETIME),  
                        --invoiceheader.ivh_deliverydate,   
                        invoiceheader.ivh_revtype1,
                        invoiceheader.ivh_mbnumber,
                        ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
             ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),    
             ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),               
             ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
                                    WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
                                    ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
                              END),'') ,              
            ivh_shipto_zip = ISNULL(cmp2.cmp_zip ,'') , 
                        ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
             ivh_billto_address = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
                        ELSE ISNULL(cmp1.cmp_mailto_address1,'')
                END,
             ivh_billto_address2 = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
                        ELSE ISNULL(cmp1.cmp_mailto_address2,'')
                END,
             ivh_billto_nmstct = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL THEN 
                           ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
                           WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
                           0
                           ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
                           END),'')
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
                           ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
                           WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
                           0
                           ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
                           END),'')
                        ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
                           WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN
                           0
                           ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
                        END),'')
                END,
            ivh_billto_zip = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
                        ELSE ISNULL(cmp1.cmp_mailto_zip,'')
                END,
                        ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
             ivh_consignee_address = ISNULL(cmp3.cmp_address1,'') ,            
             ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),                
             ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
                                    WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0                                          
                                    ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
                                      END),''),
             ivh_consignee_zip = ISNULL(cmp3.cmp_zip ,''),  
                        cty1.cty_nmstct   origin_nmstct,
                        cty1.cty_state               origin_state,
                        cty2.cty_nmstct   dest_nmstct,
                        cty2.cty_state              dest_state,
                        ivh_billdate      billdate,
                        ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
                        cast(ivd.ivd_quantity as dec(9,2)) 'bill_quantity',
                        IsNull(ivd.ivd_wgt, 0),
                        IsNull(ivd.ivd_wgtunit, ''),
                        IsNull(ivd.ivd_count, 0),
                        IsNull(ivd.ivd_countunit, ''),
                        IsNull(ivd.ivd_volume, 0),
                        IsNull(ivd.ivd_volunit, ''),
                        IsNull(ivd.ivd_unit, ''),
                        IsNull(ivd.ivd_rate, 0),
                        IsNull(ivd.ivd_rateunit, ''),
                        ivd.ivd_charge,
                        cht.cht_description,
                        cht.cht_primary,
                        cmd.cmd_name,
                        IsNull(ivd_description, ''),
                        ivd.ivd_type,
                        stp.stp_city,
                        '',
                        ivd_sequence,
                        IsNull(stp.stp_number, -1),
                        @copy,
                        ivd.cmp_id cmp_id, 
                cht.cht_itemcode,
                0, --Load Total
                0, --Weight Total
                0, --FSC Total
                0, --Freight Total                  
                '', --BOL Number
                '', -- ref desc		
               '', --ord_fromorder
		0, --Tax
                cht.cht_rollintolh,
		--06/29/2006 ILB
                invoiceheader.ivh_showshipper,
                invoiceheader.ivh_showcons,
		--06/29/2006 ILB
		invoiceheader.ord_number,
		-- PTS 34594 11/06/06 EMK - Begin
		0, 	-- Tax Total 
		0, 	-- Material Total 
		0 	-- Misc Total
		-- PTS 34594 11/06/06 EMK - End
    FROM                --invoiceheader, 
                        company cmp1, 
                        company cmp2,
                        company cmp3,
                        city cty1, 
                        city cty2, 
                        --invoicedetail ivd, 
                        --commodity cmd, 
                        chargetype cht,
                        --stops stp
			invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		        left outer join stops as stp on (ivd.stp_number = stp.stp_number)
                        left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code)                       
   WHERE               ( invoiceheader.ivh_mbnumber = @mbnumber )
                        --AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
                        --AND (ivd.stp_number *= stp.stp_number)
                        --AND (ivd.cmd_code *= cmd.cmd_code)
                        AND (cmp1.cmp_id = invoiceheader.ivh_billto)
                        AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
                        AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
                        AND (cty1.cty_code = invoiceheader.ivh_origincity)
                        AND (cty2.cty_code = invoiceheader.ivh_destcity)
                        AND (ivd.cht_itemcode = cht.cht_itemcode)
                        AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
                        AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))                    			
  END
-- for master bills with 'RTP' status
IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO        #masterbill_temp
     SELECT       IsNull(invoiceheader.ord_hdrnumber,-1),
                        invoiceheader.ivh_invoicenumber,  
                        invoiceheader.ivh_hdrnumber, 
                        invoiceheader.ivh_billto,   
                        invoiceheader.ivh_shipper,
                        invoiceheader.ivh_consignee,
                        invoiceheader.ivh_totalcharge,   
                        invoiceheader.ivh_originpoint,  
                        invoiceheader.ivh_destpoint,   
                        invoiceheader.ivh_origincity,   
                        invoiceheader.ivh_destcity,   
                        invoiceheader.ivh_shipdate,   
                        CAST( FLOOR( CAST( invoiceheader.ivh_deliverydate AS FLOAT ) ) AS DATETIME),
                        --invoiceheader.ivh_deliverydate,                      
                invoiceheader.ivh_revtype1,
                        @mbnumber     ivh_mbnumber,
                        ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
             ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),    
             ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),               
             ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
                                    WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
                                    ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
                              END),''),               
            ivh_shipto_zip = ISNULL(cmp2.cmp_zip ,'') ,
                        ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
             ivh_billto_address = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
                        ELSE ISNULL(cmp1.cmp_mailto_address1,'')
                END,
             ivh_billto_address2 = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
                        ELSE ISNULL(cmp1.cmp_mailto_address2,'')
                END,
             ivh_billto_nmstct = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL THEN 
                           ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
                           WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
                           0
                           ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
                           END),'')
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
                           ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
                           WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
                           0
                           ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
                           END),'')
                        ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
                        WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1 < 0 THEN
                        0
                        ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1
                        END),'')
                END,
            ivh_billto_zip = 
                CASE
                        WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
                        WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
                        ELSE ISNULL(cmp1.cmp_mailto_zip,'')
                END,
                        ivh_consignee_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
             ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),             
             ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),                
             ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
                                    WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0                                          
                                    ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
                                      END),''),
             ivh_consignee_zip = ISNULL(cmp3.cmp_zip ,''),  
                        cty1.cty_nmstct   origin_nmstct,
                        cty1.cty_state               origin_state,
                        cty2.cty_nmstct   dest_nmstct,
                        cty2.cty_state              dest_state,
                        @billdate          billdate,
                        ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
                         cast(ivd.ivd_quantity as dec(9,2)) 'bill_quantity',
                        IsNull(ivd.ivd_wgt, 0),
                        IsNull(ivd.ivd_wgtunit, ''),
                        IsNull(ivd.ivd_count, 0),
                        IsNull(ivd.ivd_countunit, ''),
                        IsNull(ivd.ivd_volume, 0),
                        IsNull(ivd.ivd_volunit, ''),
                        IsNull(ivd.ivd_unit, ''),
                        IsNull(ivd.ivd_rate, 0),
                        IsNull(ivd.ivd_rateunit, ''),
                        ivd.ivd_charge,
                        cht.cht_description,
                        cht.cht_primary,
                        cmd.cmd_name,
                        IsNull(ivd_description, ''),
                        ivd.ivd_type,                 stp.stp_city,
                        '',
                        ivd_sequence,
                        IsNull(stp.stp_number, -1),
                        @copy,
                        ivd.cmp_id cmp_id,
                cht.cht_itemcode,
                0, --Load Total
                0, --Weight Total
                0, --FSC Total
                0, --Freight Total
                        '', --BOL Number
                        '', -- ref desc
                '', --ord_fromorder
		0, --Tax
                cht.cht_rollintolh,
		--06/29/2006 ILB
		invoiceheader.ivh_showshipper,
                invoiceheader.ivh_showcons,
		--06/29/2006 ILB
		invoiceheader.ord_number,
		-- PTS 34594 11/06/06 EMK - Begin
		0,	-- Tax Total 
		0, 	-- Material Total
		0  -- Misc Total
		-- PTS 34594 11/06/06 EMK - End
            FROM   --invoiceheader,
                   company cmp1,
                   company cmp2,
                   company cmp3,
                   city cty1, 
                   city cty2,
                   --stops stp, 
                   --invoicedetail ivd, 
                   --commodity cmd, 
                   chargetype cht,
		   invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		   left outer join stops as stp on (ivd.stp_number = stp.stp_number)
                   left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code)
            WHERE  (invoiceheader.ivh_billto = @BILLTO )
                    --AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
                    --AND (ivd.stp_number *= stp.stp_number)
                    --AND (ivd.cmd_code *= cmd.cmd_code)			
		    --Per Sue M. use delivery date instead of shipdate 04/24/2006
		    AND (invoiceheader.ivh_shipdate between @SHIPSTART AND @SHIPEND ) 				   
		    AND( invoiceheader.ivh_deliverydate between @DELSTART AND @DELEND ) 		        
                    --AND ( invoiceheader.ivh_shipdate between @SHIPSTART AND @SHIPEND ) 
	    	    --Per Sue M. use delivery date instead of shipdate 04/24/2006
                    AND     (invoiceheader.ivh_mbstatus = @mbstatus ) 
                    AND (@REVTYPE1 in (invoiceheader.ivh_revtype1,'UNK'))
                    AND (@REVTYPE2 in (invoiceheader.ivh_revtype2,'UNK')) 
                    AND (cmp1.cmp_id = invoiceheader.ivh_billto)
                    AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
                    AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
                    AND (cty1.cty_code = invoiceheader.ivh_origincity)                   
                    AND (cty2.cty_code = invoiceheader.ivh_destcity)
                    AND (ivd.cht_itemcode = cht.cht_itemcode)
                    AND (@SHIPPER IN(invoiceheader.ivh_shipper,'UNKNOWN'))
                    AND (@CONSIGNEE IN (invoiceheader.ivh_consignee,'UNKNOWN'))
                    AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
  END

  UPDATE         #masterbill_temp 
  SET                #masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM             #masterbill_temp, city 
  WHERE                      #masterbill_temp.stp_city = city.cty_code 
Update #masterbill_temp
   set ivd_rateunit = '%'      
  from chargetype cht
 WHERE #masterbill_temp.cht_itemcode = cht.cht_itemcode and
       cht.cht_rateunit = 'PERCNT'  
/*
Update #masterbill_temp
   set ivd_rate = ivd_rate * 100    
  from chargetype cht
 WHERE #masterbill_temp.cht_itemcode = cht.cht_itemcode and
       cht.cht_rateunit = 'PERCNT' and
       #masterbill_temp.cht_itemcode = 'FSC' 
 */
SET @v_MinOrd = 0
SET @v_MinSeq = 0
SET @v_ref_number = ''
WHILE (SELECT COUNT(*) 
         FROM #masterbill_temp 
        WHERE ord_hdrnumber > @v_MinOrd) > 0
            BEGIN
          SELECT @v_MinOrd = (SELECT MIN(ord_hdrnumber) 
                                FROM #masterbill_temp 
                               WHERE ord_hdrnumber > @v_MinOrd)
                          --Print cast(@v_minord as varchar(20))
                          SELECT @v_minseq = (SELECT MIN(ref_sequence) 
                                                FROM Referencenumber
                                               WHERE ref_tablekey = @v_MinOrd and
                                                     ref_type = 'BOL' and
                                                     ref_table = 'orderheader')
                          --print cast(@v_minseq as varchar(20))
                          SELECT @v_ref_number = ref_number,
                                 @v_ref_typedesc = l.name
                            FROM Referencenumber, labelfile l
                           WHERE ref_sequence = @v_minseq and
                                 ref_type = 'BOL' and
                                 ref_table = 'orderheader' and
                                 ref_type = l.abbr and
                                 l.labeldefinition = 'ReferenceNumbers' and
                                 ref_tablekey = @v_minord
                          --print @v_ref_number
                          UPDATE #masterbill_temp
                             SET bol_number = @v_ref_number,
                                 ref_typedesc = @v_ref_typedesc
                           WHERE ord_hdrnumber = @v_minord    
                        --Added per Matt Parker 03/03/2006
                        --Remove any detail records which have been designated as rolled into the LH   
                        INSERT INTO #MASTERBILL_TEMP2
                        SELECT  mas.ivh_hdrnumber, 
                                SUM(mas.ivd_rate) rate, 
                                SUM(mas.ivd_charge) charge                       
                           FROM invoiceheader ivh, #masterbill_temp mas, chargetype cht
                          WHERE  (cht.cht_itemcode = mas.cht_itemcode) AND 
                                 (IsNull(mas.cht_rollintolh,0) = 1) AND 
                                 (ivh.ivh_hdrnumber = mas.ivh_hdrnumber) AND
                          mas.ord_hdrnumber = @v_MinOrd     
                        GROUP BY mas.ivh_hdrnumber
                        IF (SELECT COUNT(*) FROM #masterbill_temp2) > 0  
                             BEGIN
                                    UPDATE #masterbill_temp 
                                       SET --#masterbill_temp.bill_quantity = #masterbill_temp.bill_quantity + #masterbill_temp2.quantity,
                                           #masterbill_temp.ivd_rate = #masterbill_temp.ivd_rate + #masterbill_temp2.rate,     
                                           #masterbill_temp.ivd_charge = #masterbill_temp.ivd_charge + #masterbill_temp2.charge        
                                      FROM #masterbill_temp2, chargetype
                                     WHERE #masterbill_temp.ivh_hdrnumber = #masterbill_temp2.ivh_hdrnumber 
                                           AND #masterbill_temp.cht_itemcode = chargetype.cht_itemcode    
                                           AND ivd_type = 'SUB'
                                   AND ord_hdrnumber = @v_MinOrd
                                    --UPDATE #masterbill_temp 
                                    --   SET #masterbill_temp.ivd_rate = #masterbill_temp.ivd_charge/ #masterbill_temp.bill_quantity     
                                    -- WHERE #masterbill_temp.IVD_TYPE = 'SUB'
                            --       AND ord_hdrnumber = @v_MinOrd      
                                    DELETE FROM #masterbill_temp
                                    WHERE cht_itemcode IN (SELECT cht_itemcode 
                                                                         FROM chargetype
                                                            WHERE cht_rollintolh = 1)
                                  AND ord_hdrnumber = @v_MinOrd
                        END
                         --END Added per Matt Parker 03/03/2006
                         SET @v_minseq = 0
                         SET @v_ref_number = ''
                         SET @v_ref_typedesc = ''
            END
UPDATE #masterbill_temp
   SET #masterbill_temp.ord_fromorder = RTRIM(orderheader.ord_fromorder)
  FROM orderheader
 WHERE #masterbill_temp.ord_hdrnumber = orderheader.ord_hdrnumber
--print @fromorder
--PTS# 24619 ILB 03/16/2006
--Per Sue Malick 03/16/2006
--For all tax charges the decimal should display 4 places to the left
SET @v_cnt = 0
SET @v_seq = 0
SET @v_MinOrd = 0
WHILE (SELECT COUNT(*) 
	 FROM #masterbill_temp 
	WHERE ord_hdrnumber > @v_MinOrd) > 0
	BEGIN
		SELECT @v_MinOrd = (SELECT MIN(ord_hdrnumber) 
                                      FROM #masterbill_temp 
                                     WHERE ord_hdrnumber > @v_MinOrd)
		WHILE (select count(*)
                        from #masterbill_temp
                       where ord_hdrnumber = @v_MinOrd and
                             ivd_sequence > @v_seq) > 0
		BEGIN
			SELECT @v_seq = (SELECT MIN(ivd_sequence) 
                                           FROM #masterbill_temp 
                                          WHERE ord_hdrnumber = @v_MinOrd
					    and ivd_sequence > @v_seq)
			SELECT @v_cnt = charindex('TAX',upper(cht_description))
			  FROM #masterbill_temp
			 WHERE ivd_sequence = @v_seq
			IF @v_cnt > 0 
			   BEGIN
				Update #masterbill_temp
		                   set tax = 1
				 where ivd_sequence = @v_seq
			   END
		END
	END
--END PTS# 24619 ILB 03/16/2006
set @v_loads_total = 0
set @v_weight_total = 0
set @v_FSC_total = 0
set @v_freight_total = 0
set @v_grand_total = 0
set @v_misc_total = 0
Select @v_loads_total = isnull(count(distinct(ord_hdrnumber)),0)
  From #masterbill_temp
 WHERE ord_fromorder = RTRIM(@fromorder)
UPDATE #masterbill_temp
   SET LOAD_TOTAL = @v_loads_total 
 Select @v_weight_total = isnull(sum(bill_quantity),0) 
   From #masterbill_temp
  where ivd_rateunit IN ('KLM','CWT','LBS','KGS','CBUSH','SBUSH','WBUSH','MBUSH','FLT','TON')
    and ivd_type = 'SUB'
    and (isnull(cht_rollintolh,0) <> 1)
    and ord_fromorder = RTRIM(@fromorder)
UPDATE #masterbill_temp
    SET WEIGHT_TOTAL = @v_weight_total 
  --04/19/2006 added the restriction ivd_type = SUB to only add quantities for the LH 
  --eliminate any Line Item charges Per Sue Malick.
  --04/19/2006 modified the types of line haul which should be totaled Per Sue Malick
  --and ivd_type = 'SUB'
  --03/03/2006 REMOVED PER Matt Parker
  --where ivd_rateunit IN ('KLM','CWT','LBS','KGS','BUSH','FLT','TON')
  --03/03/2006 REMOVED PER Matt Parker 
--print 'total weight is '+cast(@v_weight_total as varchar(20))

-- PTS 34594 11/06/06 EMK - Begin 

--  Select @v_FSC_total = isnull(sum(ivd_charge),0)
--    From #masterbill_temp
--   Where cht_itemcode IN ('FSC','FSCFIX','FSC3') 
--         and ord_fromorder = RTRIM(@fromorder)
-- UPDATE #masterbill_temp
--    SET FSC_Total = @v_FSC_total 
-- --print 'FSC total is '+cast(@v_FSC_total as varchar(20)) 
-- Select @v_freight_total = isnull(sum(ivd_charge),0)
--    From #masterbill_temp
--   Where cht_itemcode NOT IN ('FSC','FSCFIX','FSC3') 
--         and ord_fromorder = RTRIM(@fromorder)
-- UPDATE #masterbill_temp
--     SET freight_total = @v_freight_total 

Select @v_FSC_total = isnull(sum(ivd_charge),0)
	From #masterbill_temp
	Where cht_itemcode IN (SELECT cht_itemcode FROM @FSCTypes)
       and ord_fromorder = RTRIM(@fromorder)
UPDATE #masterbill_temp
   SET FSC_Total = @v_FSC_total 

Select @v_freight_total = isnull(sum(ivd_charge),0)
   From #masterbill_temp
	Where cht_itemcode NOT IN (SELECT cht_itemcode FROM @FSCTypes) and
		cht_itemcode NOT IN (SELECT cht_itemcode FROM @TaxTypes) and
		cht_itemcode NOT IN (SELECT cht_itemcode FROM @MaterialTypes)
		and cht_primary = 'Y'
      and ord_fromorder = RTRIM(@fromorder)	
UPDATE #masterbill_temp
    SET freight_total = @v_freight_total 

Select @v_material_total = isnull(sum(ivd_charge),0)
   From #masterbill_temp
	Where cht_itemcode  IN (SELECT cht_itemcode FROM @MaterialTypes) 
		and ord_fromorder = RTRIM(@fromorder)
UPDATE #masterbill_temp
    SET material_total = @v_material_total 

Select @v_tax_total = isnull(sum(ivd_charge),0)
   From #masterbill_temp
	Where cht_itemcode  IN (SELECT cht_itemcode FROM @TaxTypes) 
		and ord_fromorder = RTRIM(@fromorder)
UPDATE #masterbill_temp
    SET tax_total = @v_tax_total 

Select @v_misc_total = isnull(sum(ivd_charge),0)
   From #masterbill_temp
	Where cht_itemcode NOT IN (SELECT cht_itemcode FROM @FSCTypes) and
		cht_itemcode NOT IN (SELECT cht_itemcode FROM @TaxTypes) and
		cht_itemcode NOT IN (SELECT cht_itemcode FROM @MaterialTypes)
		and cht_primary = 'N'
       and ord_fromorder = RTRIM(@fromorder)	
UPDATE #masterbill_temp
    SET misc_total = @v_misc_total 

-- PTS 34594 11/06/06 EMK - End

--print 'freight total is '+cast(@v_freight_total as varchar(20)) 
select @v_grand_total = @v_freight_total + @v_FSC_total
--print 'grand total is '+cast(@v_grand_total as varchar(20))
--select @v_master_order = isnull(ord_fromorder,'')
--  from orderheader
-- where ord_hdrnumber in ( Select distinct(ord_hdrnumber)
--                            from #masterbill_temp)
--Update #masterbill_temp
--   set master_order = @v_master_order
--06/29/2006 ILB Display the show shipper/show consignee per Beelman
--if the show shipper/show cons is not null or ''
select @v_showshipper = isnull(min(ivh_showshipper),'') 
from #masterbill_temp
where ord_fromorder = UPPER(@FROMORDER)
IF @v_showshipper <> '' and @v_showshipper <> 'UNKNOWN'
	BEGIN
		update #masterbill_temp
		   set ivh_shipper_name = company.cmp_name,
		       ivh_shipper_address =  ISNULL(company.cmp_address1,''),				 
		       ivh_shipper_address2 = ISNULL(company.cmp_address2,''),				
		       ivh_shipper_nmstct =   ISNULL(SUBSTRING(company.cty_nmstct,1,CASE 
		                                    WHEN CHARINDEX('/',company.cty_nmstct)- 1 < 0 THEN 0                                          
		                                    ELSE CHARINDEX('/',company.cty_nmstct) - 1
		                                    END),''),
		       ivh_shipper_zip = ISNULL(company.cmp_zip ,'')
		from #masterbill_temp, company
		where company.cmp_id = @v_showshipper 
                  and ord_fromorder = UPPER(@FROMORDER)
	END
select @v_showcons = isnull(min(ivh_showcons),'') 
  from #masterbill_temp
 where ord_fromorder = UPPER(@FROMORDER)
IF @v_showcons <> '' and @v_showcons <> 'UNKNOWN'
	BEGIN
		update #masterbill_temp
		   set ivh_consignee_name = company.cmp_name,
		       ivh_consignee_address =  ISNULL(company.cmp_address1,''),		 
		       ivh_consignee_address2 = ISNULL(company.cmp_address2,''),
		       ivh_consignee_nmstct =   ISNULL(SUBSTRING(company.cty_nmstct,1,CASE 
		                                    WHEN CHARINDEX('/',company.cty_nmstct)- 1 < 0 THEN 0                                          
		                                    ELSE CHARINDEX('/',company.cty_nmstct) - 1
		                                    END),''),
		       ivh_consignee_zip = ISNULL(company.cmp_zip ,'')
		from #masterbill_temp, company
		where company.cmp_id = @v_showcons
		  and ord_fromorder = UPPER(@FROMORDER)
	END
SELECT
	ord_hdrnumber,
	ivh_invoicenumber ,
	ivh_hdrnumber ,
	ivh_billto ,
	ivh_shipper ,
	ivh_consignee, 
	ivh_totalcharge,
	ivh_originpoint , 
	ivh_destpoint,
	ivh_origincity, 
	ivh_destcity ,
	ivh_shipdate ,
	ivh_deliverydate, 
	ivh_revtype1 ,
	ivh_mbnumber ,
	ivh_shipper_name, 
	ivh_shipper_address, 
	ivh_shipper_address2, 
	ivh_shipper_nmstct ,
	ivh_shipper_zip ,
	ivh_billto_name ,
	ivh_billto_address, 
	ivh_billto_address2, 
	ivh_billto_nmstct ,
	ivh_billto_zip ,
	ivh_consignee_name, 
	ivh_consignee_address, 
	ivh_consignee_address2, 
	ivh_consignee_nmstct ,
	ivh_consignee_zip ,
	origin_nmstct ,
	origin_state ,
	dest_nmstct ,
	dest_state ,
	billdate ,
	cmp_mailto_name ,
	bill_quantity ,
	ivd_weight ,
	ivd_weightunit, 
	ivd_count ,
	ivd_countunit, 
	ivd_volume ,
	ivd_volunit ,
	ivd_unit ,
	ivd_rate ,
	ivd_rateunit, 
	ivd_charge,
	cht_description, 
	cht_primary ,
	cmd_name ,
	ivd_description ,
	ivd_type ,
	stp_city ,
	stp_cty_nmstct, 
	ivd_sequence ,
	stp_number ,
	copy ,
	cmp_id, 
	cht_itemcode, 
	load_total ,
	weight_total, 
	FSC_total ,
	Freight_total, 
	BOL_Number ,
	ref_typedesc, 
	ord_fromorder,
	ord_number, 
-- PTS 34594 11/06/06 EMK - Begin
--	tax,			-- Placeholder?  Didn't match datawindow
--	cht_rollintolh,	-- Placeholder?  Didn't match datawindow
	tax_total,
	material_total,
	misc_total	
-- PTS 34594 11/06/06 EMK - End
 FROM  #masterbill_temp
where ord_fromorder = UPPER(@FROMORDER)
order by ivh_deliverydate,BOL_NUMBER,ivd_sequence  
--  SELECT * 
--    FROM  #masterbill_temp
--   where ord_fromorder = UPPER(@FROMORDER)
--  order by ivh_deliverydate,BOL_NUMBER,ivd_sequence  
--06/29/06 ILB
DROP TABLE #masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill69_sp] TO [public]
GO
