SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_invoices_printqueue3_sp] (
  @status VARCHAR(6)
 ,@billto VARCHAR(8)
 ,@shipper VARCHAR(8)
 ,@consignee VARCHAR(8)
 ,@orderedby VARCHAR(8)
 ,@shipdate1 DATETIME
 ,@shipdate2 DATETIME
 ,@deldate1 DATETIME
 ,@deldate2 DATETIME
 ,@rev1 VARCHAR(6)
 ,@rev2 VARCHAR(6)
 ,@rev3 VARCHAR(6)
 ,@rev4 VARCHAR(6)
 ,@printdate DATETIME
 ,@doinvoices CHAR(1)
 ,@domasterbills CHAR(1)
 ,@mbnumber INT
 ,@billdate1 DATETIME
 ,@billdate2 DATETIME
 ,@breakon CHAR(1)
 ,@mbcompany_include CHAR(1)
 ,@user_id CHAR(20)
 ,@byuser CHAR(1)
 ,@paperworkstatus VARCHAR(6)
 ,@xfrdate1 DATETIME
 ,@xfrdate2 DATETIME
 ,@imagestatus TINYINT
 ,@usr_id CHAR(20)
 ,@company VARCHAR(6)
 ,@ord_number VARCHAR(12)
 ,@sch_date1 DATETIME
 ,@sch_date2 DATETIME
 ,@driverid VARCHAR(8)
 ,@dodedbills CHAR(1) -- 52067 CGK 6/29/2010
 ,@dbh_id INT -- PTS 55252 SGB
 ,@othertype1 VARCHAR(8) -- NQIAO 62654
 ,@othertype2 VARCHAR(8) -- NQIAO 62654
 ,@othertype3 VARCHAR(8) -- NQIAO 62654
 ,@othertype4 VARCHAR(8) -- NQIAO 62654
 ,@donone CHAR(1) -- PTS 62725 nloke
 ,@ord_invoice_effectivedate1 DATETIME -- NQIAO 62719 
 ,@ord_invoice_effectivedate2 DATETIME -- NQIAO 62719
 ,@dbh_custinvnum VARCHAR(30)-- NQIAO 63136
 ,@ref_table VARCHAR(50)-- NQIAO 73475
 ,@ref_type VARCHAR(6) -- NQIAO 73475
 ,@ref_number VARCHAR(30))-- NQIAO 73475
  --@xfrdate1 datetime, @xfrdate2 datetime,@ivhrefnumber varchar(20),@imagestatus tinyint)    
AS    
    

/**
 * 
 * NAME:
 * dbo.d_invoices_printqueue3_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_invoices_printqueue3
 * Created for Florida Rock which has complicated rules for qualifying    
 * an invoice for EDI transmission.  The stored proc returns the same    
 * information as the d_invoice_view datawindow (SQL in datawindow)    
 * But the edi code has been manipulated by passing thru Florida ROcks    
 * qualification rules.    
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * .....
 * 031 - @sch_date1 datetime sch earliest datetime from
 * 032 - @sch_date1 datetime sch earliest datetime to
 *
 * EXAMPLE CALL:
  EXEC	[dbo].[d_invoices_printqueue3_sp]
		@status = N'RTP',
		@billto = N'ACMATL',
		@shipper = N'UNKNOWN',
		@consignee = N'UNKNOWN',
		@orderedby = N'UNKNOWN',
		@shipdate1 = N'1/1/1950',
		@shipdate2 = N'12/31/2049',
		@deldate1 = N'1/1/1950',
		@deldate2 = N'12/31/2049',
		@rev1 = N'UNK',
		@rev2 = N'UNK',
		@rev3 = N'UNK',
		@rev4 = N'UNK',
		@printdate = N'1/1/1950',
		@doinvoices = N'Y',
		@domasterbills = N'N',
		@mbnumber = 0,
		@billdate1 = N'1/1/1950',
		@billdate2 = N'12/31/2049',
		@breakon = N'Y',
		@mbcompany_include = N'N',
		@user_id = N'UNK',
		@byuser = N'N',
		@paperworkstatus = N'UNK',
		@xfrdate1 = N'1/1/1950',
		@xfrdate2 = N'12/31/2049',
		@imagestatus = 0,
		@usr_id = N'UNK',
		@company = N'UNK',
		@ord_number = N'UNKNOWN',
		@sch_date1 = N'1/1/1950',
		@sch_date2 = N'12/31/2049',
		@driverid = N'UNKNOWN',
		@dodedbills = N'N',
		@dbh_id = 0,
		@othertype1 = N'UNK',
		@othertype2 = N'UNK',
		@othertype3 = N'UNK',
		@othertype4 = N'UNK',
		@donone = 'Y',
		@ord_invoice_effectivedate1 = '1/1/1950',
		@ord_invoice_effectivedate2 = '12/31/2049',
		@dbh_custinvnum = 0,
        @ref_table = '',
        @ref_type = '',
        @ref_number = ''
 * 
 * REVISION HISTORY:
 * Modified 8/8/00 pts7896 populate trasfertype for masterbills    
 * modified 11/27/00 pts9400 masterbills for earth transport    
 * modified 5/23/01 dpete pts8790 add cmp_invoicetype to return set so that no output option can be handled on printing when the     
 *  status is to be updated    
 * modified 03/06/02 jyang pts12901    
 * dpete pts 13822 need tar tariffitem for gobsons mastr bills 19 & 20    
 * DPETE PTS15533 Add ivh_ref number to selection and return set    
 * DPETE PTS15913 add image status to args and retrieve    
 * DPETE 15854 Masterbill format  14 s not working the selection for commodity code was dropped for ORGCMD    
 * DPETE PTS16354 add break on ord_fromorder for masterbill 29, remove ref number    
 * DPETE PTS 16789 make @shipper the default on masterbill retrieve if no cmp_mbgroup instead of UNKNOWN. Same for consignee    
 * DPETE 16739 add two more fields to breaks for Gibson master bills, revtype1 and ord_subcompany    
 * DPETE 16739 found subcompany filed has been 6 on proc when should be 8
 * DPETE 17999 Add REF#1 group to group by first ref on order/invoice
 * LOR PTS# 23109 add company
 * DMEEK PTS26599 Carter Splitbill functionality requires ability to que masterbills/invoices by ord_number
 *                as well group Masterbills by ord_hdrnumber.    
 * PTS 28682 - DJM - Keith found an easy performance enhancement.  Modified the Where clause to use the CharIndex statment
 *            to match RevType values.
 * LOR PTS# 30053 added sch earliest dates
 * DPETE PTS33511 queu not retrieving when an UNKNOWN order exists
 * PRB PTS32823 6/26/2006 - Added LEFT OUTER JOIN of referencennumber table to allow us to group reference numbers that 
 *                          are not in the 1st position.  Removal of this will cause MB Format 82 to fail. 
 * JG  PTS33540 rewrite "AND  ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )" to improve performance
 * JG  PTS34019 create table variable version for SQL 2000
 * DPETE PTS34005 if mbdays set -1 and bill date set to earlier than today, no mbs retrieve
 * EMK PTS 39333 Re-adding showshipper and showcons fields.  Lost them somewhere in 2005.
 * ILB/JJF 24619 add MASORD group to group by ord_fromord
 * ILB/JJF 24619 add TCKTNUM group to group by ivh_invoicenumbmer
 * EMK PTS 40126 Added CONSIGNEE group to group by ivh_consignee (add + SHIPPER as extra)
 * DPETE PTS 40753/40260 recode Puals
 *           recode DPETE 27221 Add mb break on company then revtype 2
 *           recodeDPETE 27908 change mb break on company and revtype2 to company revtype 2 and cuurency
 *           recode  PTS30355 add break on alt bill to address (car_key) NOTER: car_key is a way
 *                   to assoicate mutiple billing addresses with a single bill to company
 *           consolidate code 40929 JJF 20071211
 * PMILL PTS44805 12/11/2008 add new group by:  move # + shipper + consignee
 * DPETE PTS 45473 12/16/08 Customer has ref numbers for orderheader with zero ref_tablekey
 * DPETE 6/11/09 PTS 47661 if bad master bill number passed return nothing
 * PTS 48221 SGBAdd Driver as a selection criteria and a return set column 
 * PTS 54811 DPETE when Last Update by entered on select screen matches nto alwys made. Cusotmer had NULL values in ivh_user_id2
 * PTS 55252 SGB Added dbh_id for retrieiving by dedicated bill number  
 * PTS 55906 NQIAO 1) call new sp masterbillparseforprint_sp to add break point for groupby master bills based on the line item limit settings
 *                 2) Add invoiceheader.ivh_custom_groupby to group MB by up to 4 order header level reference number, and fgt_accountof of the first record in freightdetail table
 *       3) Add invoiceheader.ivh_custom_groupby to the output list
 * PTS 59864 SGB Add GI Setting to control if Dedicated Bills are retrieved by summary or detail
 * PTS 62654 NQIAO - add 4 new inputs (@othertyp1 ~ @othertype4)
 * PTS 65860 (64327) DPETE making changes requested by DBA Mindy
 * PTS 62725 nloke - add no output to print selection
 * PTS 73475 NQIAO - add 3 new inputs (@ref_table, @ref_type, @ref_number)
 * PTS 81376 NQIAO - related to PTS 73475 - print master bills issue
 * PTS 89330 EBLINN - DBA overhaul for performance - Changed to be dynamic SQL.  Reformatted single invoice portion of procedure for readability
                      Added GI master lookup
 * NSUITE-201212 / PTS 106658 - added support to print dedicated credit memo 
 **/

--GENERAL INFO MASTER LOOKUP START
 DECLARE @GI_VALUES_TO_LOOKUP TABLE (
  gi_name VARCHAR(30) PRIMARY KEY)

DECLARE @GIKEY TABLE (
  gi_name     VARCHAR(30) PRIMARY KEY
 ,gi_string1  VARCHAR(60)
 ,gi_string2  VARCHAR(60)
 ,gi_string3  VARCHAR(60)
 ,gi_string4  VARCHAR(60)
 ,gi_integer1 INT
 ,gi_integer2 INT
 ,gi_integer3 INT
 ,gi_integer4 INT)

INSERT 
  @GI_VALUES_TO_LOOKUP
VALUES
  ('MasterBill82DefaultRef')
 ,('MB_GroupBy')
 ,('DedicatedPrintSummary')
 ,('SplitbillMilkrun')
 ,('MasterBillCustomGroupBy')
 ,('RowSecurity')
 ,('SystemOwner')

INSERT @GIKEY 
SELECT 
  gi_name
 ,gi_string1
 ,gi_string2
 ,gi_string3
 ,gi_string4
 ,gi_integer1
 ,gi_integer2
 ,gi_integer3
 ,gi_integer4
FROM (
      SELECT 
        gvtlu.gi_name
       ,g.gi_string1
       ,g.gi_string2
       ,g.gi_string3 
       ,g.gi_string4
       ,gi_integer1
       ,gi_integer2
       ,gi_integer3
       ,gi_integer4
       --What we're doing here is checking the date of the generalInfo row in case there are multiples.
       --This will order the rows in descending date order with the following exceptions.
       --Future dates are dropped to last priority by moving to less than the apocalypse.
       --Nulls are moved to second to last priority by using the apocalypse.
       --Everything else is ordered descending.
       --We then take the "newest".
       ,ROW_NUMBER() OVER (PARTITION BY gvtlu.gi_name ORDER BY CASE WHEN g.gi_datein > GETDATE() THEN '1/1/1949' ELSE ISNULL(g.gi_datein, '1/1/1950') END DESC) RN 
      FROM 
        @GI_VALUES_TO_LOOKUP gvtlu
          LEFT OUTER JOIN 
        dbo.generalinfo g on gvtlu.gi_name = g.gi_name) subQuery
WHERE
  RN = 1 --   <---This is how we take the top 1.

--GENERAL INFO MASTER LOOKUP END


DECLARE
  @dummystatus VARCHAR(6)
 ,@Ord_hdrnumber INT
 ,@SplitbillMilkrun CHAR(1)
 ,@cmp_dflt_reftype VARCHAR(8)
 ,@DefaultGroupBy VARCHAR(30)
 ,@dummystatus2 VARCHAR(6)
 ,@MB_GroupByFlag CHAR(1)  -- PTS 50656 SGB 02/05/2010
 ,@MB_GroupBy VARCHAR(30) -- PTS 50656 SGB 02/05/2010
 ,@DedicatedSummary CHAR(1)   -- PTS 59864 SGB
 ,@sql NVARCHAR(MAX) -- PTS 89330
 ,@SharedSelectSQL NVARCHAR(MAX)-- PTS 89330
 ,@SharedWhereSQL NVARCHAR(MAX)-- PTS 89330
 ,@SharedFromSQL NVARCHAR(MAX);-- PTS 89330
 
SELECT 
  @dummystatus = '>'
 ,@dummystatus2 = '>';  
 
--PTS 40929 JJF 20071211
DECLARE 
  @rowsecurity CHAR(1);
--PTS 51570 JJF 20100510
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100510
--PTS 40929 JJF 20071211
 
DECLARE 
  @temp_dbh_id INT; -- 63136  
    
-- for reprinting invoices treat the PRN and PRO status as if they are the same    
-- (for reprinting masterbills the status is not used) 
IF @status = 'PRN'  
BEGIN   
  SELECT @dummystatus = 'PRO';
  SELECT @dummystatus2 = 'PRO'; 
END;    

IF @status = 'PRO' 
BEGIN    
 SELECT @dummystatus = 'PRN';
 SELECT @dummystatus2 = 'PRN'; 
END; 

IF @status = 'PRNXFR' 
BEGIN
  SELECT @status = 'XFR';  -- @status is used with transfer date params
  SELECT @dummystatus = 'PRN';
  SELECT @dummystatus2 = 'PRO';  
END;   

--PTS32823
SELECT 
  @Imagestatus = ISNULL(@imagestatus , 0); 

--PTS32823
SELECT 
  @cmp_dflt_reftype = ISNULL(NULLIF(RTRIM(gi_string1), ''), 'REF')
FROM 
  @GIKEY
WHERE 
  gi_name = 'MasterBill82DefaultRef';
--END PTS32823 

--40753
-- BEGIN PTS 50656 SGB 02/05/2010
SELECT 
  @MB_GroupByFlag = ISNULL(LEFT(gi_string1,1),'N')
 ,@MB_GroupBy = ISNULL(gi_string2,'') 
FROM 
  @GIKEY
WHERE 
  gi_name = 'MB_GroupBy';

IF @MB_GroupByFlag = 'Y' 
BEGIN
 SELECT @DefaultGroupBy = @MB_GroupBy;
END;
ELSE 
BEGIN
 IF NOT EXISTS (SELECT cmp_id FROM dbo.company  WITH (NOLOCK) WHERE cmp_mbgroup > '')
 BEGIN
    SELECT 
      @DefaultGroupBy = mbi_group 
    FROM 
      dbo.mbinvformats  WITH (NOLOCK)
    WHERE 
      mbi_format = (SELECT MAX(ivs_invoicedatawindow) FROM dbo.invoiceselection  WITH (NOLOCK) WHERE ivs_invoicetype = 'M');

    SELECT @DefaultGroupBy = ISNULL(@DefaultGroupBy,'');

 END;
 ELSE
  BEGIN 
    SELECT @DefaultGroupBy = '';
  END;
END;
--40753 end
-- END PTS 50656 SGB 02/05/2010

--PTS 59864 SGB
SELECT 
  @DedicatedSummary = ISNULL(LEFT(gi_string1,1),'N')
FROM 
   @GIKEY
WHERE 
  gi_name = 'DedicatedPrintSummary';

--PTS 25699
--SELECT @Ord_hdrnumber = Ord_hdrnumber from orderheader where ord_number = @ord_number
--If @ord_number = '' or @ord_number = 'UNKNOWN' SELECT @Ord_hdrnumber = isnull(@Ord_hdrnumber,0)
IF @ord_number = '' OR @ord_number = 'UNKNOWN' 
   SELECT @Ord_hdrnumber = 0;
ELSE
   SELECT @Ord_hdrnumber = Ord_hdrnumber FROM dbo.orderheader WITH (NOLOCK) WHERE ord_number = @ord_number;
   
SELECT @Ord_hdrnumber = ISNULL(@Ord_hdrnumber,0);

SELECT 
  @SplitbillMilkrun = gi_string1 
FROM 
  @GIKEY 
WHERE 
  gi_name = 'SplitbillMilkrun';

--PTS 62725 nloke
DECLARE 
  @invtype VARCHAR(10)
 ,@statusLIST TMWTable_char6;

IF @doinvoices = 'Y' AND @donone = 'Y'
BEGIN
  INSERT INTO @statusLIST VALUES ('INV');
  INSERT INTO @statusLIST VALUES ('BTH');
  INSERT INTO @statusLIST VALUES ('NONE');
END;

IF @doinvoices = 'Y' AND @donone = 'N'
BEGIN
  INSERT INTO @statusLIST VALUES ('INV');
  INSERT INTO @statusLIST VALUES ('BTH');
END;

IF @doinvoices = 'N' AND @donone = 'Y'
BEGIN
 INSERT INTO @statusLIST VALUES ('NONE');
  SET @doinvoices = 'Y';
END;
--62725 end 

--PTS 68745
IF @domasterbills = 'Y' OR @dodedbills = 'Y'
BEGIN
 INSERT INTO @statusLIST VALUES ('MAS');
 
  IF ISNULL (@doinvoices, '') <> 'Y' AND ISNULL (@donone, '') <> 'Y' 
 BEGIN /*69791* nloke*/
    INSERT INTO @statusLIST VALUES ('BTH');
 END;
  
END;
--end 68745  
     
DECLARE @invview TABLE( 
  mov_number INT NULL
 ,ivh_invoicenumber VARCHAR(12) 
 ,ivh_invoicestatus VARCHAR(6) NULL 
 ,ivh_billto VARCHAR(8) NULL 
 --,billto_name varchar(30) NULL -- PTS 32357
 ,billto_name VARCHAR(100) NULL -- PTS 32357
 ,ivh_shipper VARCHAR(8) NULL 
 --,shipper_name varchar(30) NULL -- PTS 32357 
 ,shipper_name VARCHAR(100) NULL -- PTS 32357
 ,ivh_consignee VARCHAR(8) NULL 
 --,consignee_name varchar(30) NULL -- PTS 32357
 ,consignee_name VARCHAR(100) NULL -- PTS 32357
 ,ivh_shipdate DATETIME NULL 
 ,ivh_deliverydate DATETIME NULL 
 ,ivh_revtype1 VARCHAR(6) NULL 
 ,ivh_revtype2 VARCHAR(6) NULL 
 ,ivh_revtype3 VARCHAR(6) NULL 
 ,ivh_revtype4 VARCHAR(6) NULL 
 ,ivh_totalweight FLOAT NULL 
 ,ivh_totalpieces FLOAT NULL 
 ,ivh_totalmiles FLOAT NULL 
 ,ivh_totalvolume FLOAT NULL 
 ,ivh_printdate DATETIME NULL 
 ,ivh_billdate DATETIME NULL 
 ,ivh_lastprintdate DATETIME NULL 
 ,ord_hdrnumber INT NULL
 ,ivh_remark VARCHAR(254) NULL
 ,ivh_edi_flag CHAR(30) NULL
 ,ivh_totalcharge MONEY NULL
 ,RevType1 CHAR(8) NULL 
 ,RevType2 CHAR(8) NULL 
 ,Revtype3 CHAR(8) NULL 
 ,RevType4 CHAR(8) NULL 
 ,ivh_hdrnumber INT NULL 
 ,ivh_order_by VARCHAR(8) NULL 
 ,ivh_user_id1 CHAR(20) NULL 
 ,ord_number CHAR(12) NULL 
 ,ivh_terms CHAR(3) NULL 
 --,ivh_trailer varchar(8) NULL -- PTS 32357
 ,ivh_trailer VARCHAR(13) NULL -- PTS 32357
 ,ivh_tractor VARCHAR(8) NULL 
 ,commodities INT NULL
 ,validcommodities INT NULL
 ,accessorials INT NULL
 ,validaccessorials INT NULL
 ,trltype3 VARCHAR(6) NULL
 ,ord_subcompany VARCHAR(8) NULL
 ,totallinehaul MONEY NULL
 ,negativecharges INT NULL
 ,edi_210_flag INT NULL
 ,ismasterbill CHAR(1) NULL
 ,trltype3name CHAR(8) NULL
 ,cmp_mastercompany VARCHAR(8) NULL
 ,refnumber VARCHAR(30) NULL
 ,cmp_invoiceto CHAR(3) NULL
 ,cmp_invprintto CHAR(1) NULL
 ,cmp_invformat INT NULL
 ,cmp_transfertype VARCHAR(6) NULL
 ,ivh_Mbstatus VARCHAR(6) NULL
 ,trp_linehaulmax MONEY NULL
 ,trp_totchargemax MONEY NULL
 ,cmp_invcopies SMALLINT NULL
 ,cmp_mbgroup VARCHAR(20) NULL
 ,ivh_originpoint VARCHAR(8) NULL
 ,cmd_code VARCHAR(8) NULL
 ,cmp_invoicetype VARCHAR(6) NULL
 ,ivh_currency VARCHAR(6) NULL
 ,tar_tariffitem VARCHAR(12) NULL
 ,tar_tariffnumber VARCHAR(12) NULL
 --,ivh_ref_number varchar(20) NULL
 ,imagestatus TINYINT NULL
 ,ivh_definition VARCHAR(6) NULL
 ,ivh_applyto VARCHAR(12) NULL 
 ,ord_fromorder VARCHAR(12) NULL
 ,production_year SMALLINT NULL -- for mb 19,20,34,35 
 ,production_month TINYINT NULL
 ,cmp_image_routing1 VARCHAR(254) NULL
 ,cmp_image_routing2 VARCHAR(254) NULL
 ,cmp_image_routing3 VARCHAR(254) NULL
 ,ivh_company VARCHAR(6) NULL
 ,ivh_showshipper VARCHAR(8) NULL --PTS 39333
 ,ivh_showcons VARCHAR(8) NULL --PTS 39333
 ,car_key INT NULL --40753
 ,inv_accessorials MONEY NULL /* 08/24/2009 MDH PTS 42291: Added */
 ,inv_fuel MONEY NULL /* 08/24/2009 MDH PTS 42291: Added */
 ,inv_linehaul MONEY NULL /* 08/24/2009 MDH PTS 42291: Added */
 ,ivh_driver VARCHAR(8) -- PTS 48221 SGB 06/17/2010
 ,dbh_id INT NULL --52067 CGK 8/10/2010
 ,ivh_mb_customgroupby VARCHAR(60) NULL -- PTS 55906 NQIAO
 ,invoicetype VARCHAR(6) -- PTS 68745 nloke
 ,ivh_refnumber VARCHAR(30) NULL); -- PTS 73475 NQIAO


-- 66113 <start>
---- PTS 55906 NQIAO
--IF @domasterbills = 'Y'
-- EXEC masterbillparseforprint_sp @billto  

DECLARE 
  @DoMasterBillCustomGroupBy CHAR(1);

SELECT 
  @DoMasterBillCustomGroupBy = gi_string1
FROM 
  @GIKEY
WHERE 
  gi_name = 'MasterBillCustomGroupBy';

IF @domasterbills = 'Y' AND @DoMasterBillCustomGroupBy = 'Y'
BEGIN
  EXEC masterbillparseforprint_sp @billto;  
END;
-- 66113 <end> 


-- PTS 62654 <start>
IF @othertype1 IS NULL OR RTRIM(@othertype1) = '' OR SUBSTRING(@othertype1, 1, 3) = 'UNK' SELECT @othertype1 = '%';
IF @othertype2 IS NULL OR RTRIM(@othertype2) = '' OR SUBSTRING(@othertype2, 1, 3) = 'UNK' SELECT @othertype2 = '%';
IF @othertype3 IS NULL OR RTRIM(@othertype3) = '' OR SUBSTRING(@othertype3, 1, 3) = 'UNK' SELECT @othertype3 = '%';
IF @othertype4 IS NULL OR RTRIM(@othertype4) = '' OR SUBSTRING(@othertype4, 1, 3) = 'UNK' SELECT @othertype4 = '%';
IF @othertype1 <> '%'  SELECT @othertype1 = ',' + @othertype1 + ',';
IF @othertype2 <> '%'  SELECT @othertype2 = ',' + @othertype2 + ',';
IF @othertype3 <> '%'  SELECT @othertype3 = ',' + @othertype3 + ',';
IF @othertype4 <> '%'  SELECT @othertype4 = ',' + @othertype4 + ',';
-- PTS 62654 <end>


--PTS 89330 <start>
SET @SharedSelectSQL = '
 SELECT 
   invoiceheader.mov_number 
  ,invoiceheader.ivh_invoicenumber
  ,invoiceheader.ivh_invoicestatus
  ,invoiceheader.ivh_billto
  ,SUBSTRING(bcmp.cmp_name,1,30)  billto_name
  ,invoiceheader.ivh_shipper
  ,SUBSTRING(scmp.cmp_name,1,30)  shipper_name
  ,invoiceheader.ivh_consignee
  ,SUBSTRING(Ccmp.cmp_name,1,30)  consignee_name
  ,invoiceheader.ivh_shipdate
  ,invoiceheader.ivh_deliverydate
  ,invoiceheader.ivh_revtype1
  ,invoiceheader.ivh_revtype2
  ,invoiceheader.ivh_revtype3
  ,invoiceheader.ivh_revtype4
  ,invoiceheader.ivh_totalweight
  ,invoiceheader.ivh_totalpieces
  ,invoiceheader.ivh_totalmiles
  ,invoiceheader.ivh_totalvolume
  ,invoiceheader.ivh_printdate
  ,invoiceheader.ivh_billdate
  ,invoiceheader.ivh_lastprintdate
  ,invoiceheader.ord_hdrnumber
  ,ivh_remark
  ,invoiceheader.ivh_edi_flag
  ,invoiceheader.ivh_totalcharge
  ,''RevType1'' RevType1
  ,''RevType2'' RevType2
  ,''RevType3'' Revtype3
  ,''RevType4'' RevType4
  ,invoiceheader.ivh_hdrnumber
  ,invoiceheader.ivh_order_by
  ,invoiceheader.ivh_user_id1
  ,invoiceheader.ord_number
  ,invoiceheader.ivh_terms
  ,invoiceheader.ivh_trailer
  ,invoiceheader.ivh_tractor
  ,0 [commodities]
  ,0 [validcommodities]
  ,0 [accessorials]
  ,0 [validaccessorials]
  ,CAST('''' AS VARCHAR(6)) [trltype3]
  ,ord_subcompany
  ,0.00 [totallinehaul]
  ,0 [negativecharges]
  ,bcmp.cmp_edi210 [edi_210_flag]
  ,''N'' [ismasterbill]
  ,''Trltype3'' trltype3name
  ,bcmp.cmp_mastercompany
  ,refnumber = ivh_ref_number
  ,bcmp.cmp_invoiceto
  ,bcmp.cmp_invprintto
  ,bcmp.cmp_invformat
  ,bcmp.cmp_transfertype
  ,invoiceheader.ivh_mbstatus
  ,0.00 trp_linehaulmax
  ,0.00 trp_totchargemax
  ,bcmp.cmp_invcopies
  ,bcmp.cmp_mbgroup
  ,invoiceheader.ivh_originpoint
  ,cmd_code = ISNULL(orderheader.cmd_code,''UNKNOWN'')
  ,bcmp.cmp_invoicetype
  ,ivh_currency
  ,ISNULL(invoiceheader.tar_tariffitem,'''')
  ,ISNULL(invoiceheader.tar_tarriffnumber,'''')
  --,IsNull(invoiceheader.ivh_ref_number,'''')
  ,ISNULL(invoiceheader.ivh_imagestatus,0)
  ,ivh_definition
  ,ivh_applyto
  ,ISNULL(orderheader.ord_fromorder, '''')
  ,0
  ,0
  ,CAST('''' AS VARCHAR(254)) cmp_image_routing1
  ,CAST('''' AS VARCHAR(6)) cmp_image_routing2
  ,CAST('''' AS VARCHAR(6)) cmp_image_routing3
  ,ISNULL(ivh_company, ''UNK'')
  ,ISNULL(ivh_showshipper,''UNKNOWN'') --PTS 39333
  ,ISNULL(ivh_showcons, ''UNKNOWN'')
  ,ISNULL(invoiceheader.car_key,0)  --40753
  ,dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber) 	/* 08/24/2009 MDH PTS 42291: Added */
  ,dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)          /* 08/24/2009 MDH PTS 42291: Added */
  ,dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)      /* 08/24/2009 MDH PTS 42291: Added */
  ,invoiceheader.ivh_driver -- PTS 48221
  ,0 dbh_id
  ,invoiceheader.ivh_mb_customgroupby	-- PTS 55906 NQIAO
  ,dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)  --PTS 68745 nloke
  ,''''  -- PTS 73475 NQIAO';


SET @SharedFromSQL = '
FROM 
  dbo.invoiceheader WITH (NOLOCK)
		LEFT OUTER JOIN 
  dbo.orderheader WITH (NOLOCK) ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
		INNER JOIN 
  dbo.company bcmp WITH (NOLOCK) ON bcmp.cmp_id = invoiceheader.ivh_billto
		INNER JOIN 
  dbo.company scmp WITH (NOLOCK) ON scmp.cmp_id = invoiceheader.ivh_shipper
		INNER JOIN 
  dbo.company ccmp WITH (NOLOCK) ON ccmp.cmp_id = invoiceheader.ivh_consignee';

SELECT @SharedWhereSQL = '
  WHERE ';

IF @status IN ('PRN', 'PRO')
BEGIN   
  SELECT @SharedWhereSQL = 'invoiceheader.ivh_invoicestatus IN (''PRN'', ''PRO'') ';
END;    
ELSE IF @status = 'XFR' AND @dummystatus = 'PRN'
BEGIN
  SELECT @SharedWhereSQL = 'invoiceheader.ivh_invoicestatus IN (''PRN'', ''PRO'', ''XFR'') ';
END;   
ELSE
BEGIN
  SELECT @SharedWhereSQL = 'invoiceheader.ivh_invoicestatus = @status ';
END;

IF @Billto <> 'UNKNOWN'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_billto = @Billto ';
END;        
IF @Shipper <> 'UNKNOWN'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_shipper = @Shipper ';
END;
IF @Consignee <> 'UNKNOWN'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_consignee = @Consignee ';
END;
IF @OrderedBy <> 'UNKNOWN'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_order_by = @OrderedBy ';
END;
IF @Rev1 <> 'UNK'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_revtype1 = @Rev1 ';
END;
IF @Rev2 <> 'UNK'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_revtype2 = @Rev2 ';
END;
IF @Rev3 <> 'UNK'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_revtype3 = @Rev3 ';
END;
IF @Rev4 <> 'UNK'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_revtype4 = @Rev4 ';
END;
IF ABS(DATEDIFF(yy, @ShipDate1, @ShipDate2)) < 97 --If you are asking for less than a 97 year range.  1/1/1950 to 12/31/2049 doesn't qualify
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + 'AND invoiceheader.ivh_shipdate BETWEEN @ShipDate1 AND @ShipDate2 ';
END;
IF ABS(DATEDIFF(yy, @DelDate1, @DelDate2)) < 97 --If you are asking for less than a 97 year range.  1/1/1950 to 12/31/2049 doesn't qualify
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + 'AND invoiceheader.ivh_deliverydate BETWEEN @DelDate1 AND @DelDate2 ';
END;
IF ABS(DATEDIFF(yy, @BillDate1, @BillDate2)) < 97 --If you are asking for less than a 97 year range.  1/1/1950 to 12/31/2049 doesn't qualify
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + 'AND invoiceheader.ivh_billdate BETWEEN @BillDate1 AND @BillDate2 ';
END;
IF ABS(DATEDIFF(yy, @ord_invoice_effectivedate1, @ord_invoice_effectivedate2)) < 97 --If you are asking for less than a 97 year range.  1/1/1950 to 12/31/2049 doesn't qualify
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + 'AND ISNULL(orderheader.ord_invoice_effectivedate,''19500101 00:00'') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ';
END;
IF @status = 'XFR' AND ABS(DATEDIFF(yy, @xfrdate1, @xfrdate2)) < 97 --If you are asking for XFR invoices in less than a 97 year range.  1/1/1950 to 12/31/2049 doesn't qualify
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + 'AND ISNULL(invoiceheader.ivh_xferdate, @xfrdate1) BETWEEN @xfrdate1 AND @xfrdate2 ';                 
END;
-- PTS 62654 <start>	
IF @othertype1 <> '%'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND bcmp.cmp_othertype1 = REPLACE(@othertype1, '','', '''') '; 
END;
IF @othertype2 <> '%'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND bcmp.cmp_othertype2 = REPLACE(@othertype2, '','', '''') '; 
END;
IF @othertype3 <> '%'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND bcmp.cmp_othertype3 = REPLACE(@othertype3, '','', '''') '; 
END;
IF @othertype4 <> '%'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND bcmp.cmp_othertype4 = REPLACE(@othertype4, '','', '''') '; 
END;	  
-- PTS 62654 <end>'
IF @ord_hdrnumber <> 0
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + 'AND invoiceheader.ord_hdrnumber = @ord_hdrnumber '; --PTS 25699
END;    
IF @paperworkstatus <> 'UNK'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_paperworkstatus = @paperworkstatus ';
END;          
IF @imagestatus <> 0
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND ivh_imagestatus = @imagestatus '; 
END;
IF @driverid <> 'UNKNOWN'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_driver = @driverid '; -- PTS 48221
END;
IF @company <> 'UNK'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND invoiceheader.ivh_company = @company '; 
END;
--DPH PTS 23007
--PTS 28804 -- BL (start)
IF @usr_id <> 'UNK'
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND COALESCE(ivh_user_id2, ivh_user_id1, invoiceheader.last_updateby) = @usr_id ';
END;
-- PTS 28804 -- BL (end)
--DPH PTS 23007     

IF ABS(DATEDIFF(yy, @sch_date1, @sch_date2)) < 97 --If you are asking for less than a 97 year range.  1/1/1950 to 12/31/2049 doesn't qualify 
BEGIN
  SET @SharedWhereSQL = @SharedWhereSQL + ' AND 
  (
        (SELECT TOP 1
          MIN(stp_schdtearliest)
	      FROM 
          dbo.stops WITH (NOLOCK) 
	      WHERE 
          stops.ord_hdrnumber <> 0
            AND
          stops.ord_hdrnumber = invoiceheader.ord_hdrnumber 
        GROUP BY 
          stp_sequence
        ORDER BY 
          stp_sequence
    ) BETWEEN @sch_date1 AND @sch_date2 
        OR
	  invoiceheader.ord_hdrnumber = 0)';
END;


--PTS 89330 <end>

-- PTS 63136 <start>
IF @dodedbills = 'Y' AND ISNULL(@dbh_custinvnum,'') > '' 
BEGIN
 SELECT 
   @temp_dbh_id = dbh_id 
 FROM 
   dbo.dedbillingheader
 WHERE 
   dbh_custinvnum = @dbh_custinvnum;
 
 IF ISNULL(@dbh_id, 0) = 0 OR ISNULL(@dbh_id, 0) <> @temp_dbh_id
  SET @dbh_id = @temp_dbh_id;
END; 
-- PTS 63136 <end>

--PTS 89330 <start>
IF @doinvoices = 'Y'    
BEGIN    
  IF @mbcompany_include = 'N'    
  BEGIN    
    IF @byuser = 'N'    
    BEGIN
     SET @SQL = 
          @SharedSelectSQL 
        + @SharedFromSQL     
        + '
        INNER JOIN 
      @statusLIST st ON bcmp.cmp_invoicetype = st.KeyField      --62725
    AND
	' + @SharedWhereSQL + '
        AND
      bcmp.cmp_invoicetype IN (''BTH'',''INV'',''NONE'') ';
    END;	--End MB NO byUser No
  	     
    IF @byuser = 'Y'    
    BEGIN
      SET @SQL =
        @SharedSelectSQL 
      + @SharedFromSQL
      + '
      INNER JOIN 
        @statusLIST st ON bcmp.cmp_invoicetype = st.KeyField      --62725
      ' + @SharedWhereSQL + 
        ' 
        AND 
          ivh_user_id1 = @user_id
        AND
          bcmp.cmp_invoicetype IN (''BTH'',''INV'',''NONE'')';        
    
    END; --End MB No byUser Yes
  END;    
    
  IF @mbcompany_include = 'Y'    
  BEGIN    
    IF @byuser = 'N'    
    SET @SQL = 
      @SharedSelectSQL
    + @SharedFromSQL
    + @SharedWhereSQL;
  END; -- End mb Yes byUser No
  	    
  IF @byuser = 'Y'    
  BEGIN
    SET @SQL = 
      @SharedSelectSQL
    + @SharedFromSQL
    + @SharedWhereSQL
    + '
      AND 
        ivh_user_id1 = @user_id ';
  
	
  END; -- End mb Yes byUser Yes
  --print @sql
  INSERT INTO 
    @invview
  EXEC sp_executesql @SQL
   ,@params=N'
      @BillDate1 DATETIME
     ,@BillDate2 DATETIME
     ,@Billto VARCHAR(8)
     ,@company VARCHAR(6)
	   ,@shipper VARCHAR(8)
     ,@Consignee VARCHAR(8)
     ,@DelDate1 DATETIME
     ,@DelDate2 DATETIME
     ,@driverid VARCHAR(8)
     ,@imagestatus TINYINT
     ,@ord_hdrnumber INT
     ,@OrderedBy VARCHAR(8)
     ,@othertype1 VARCHAR(6)
     ,@othertype2 VARCHAR(6)
     ,@othertype3 VARCHAR(6)
     ,@othertype4 VARCHAR(6)
     ,@paperworkstatus VARCHAR(6)
     ,@Rev1 VARCHAR(6)
     ,@Rev2 VARCHAR(6)
     ,@Rev3 VARCHAR(6)
     ,@Rev4 VARCHAR(6)
     ,@sch_date1 DATETIME
     ,@sch_date2 DATETIME
     ,@ShipDate1 DATETIME
     ,@ShipDate2 DATETIME
     ,@status VARCHAR(6)
     ,@user_id CHAR(20)
     ,@usr_id CHAR(20)
     ,@xfrdate1 DATETIME
     ,@xfrdate2 DATETIME
     ,@ord_invoice_effectivedate1 DATETIME
     ,@ord_invoice_effectivedate2 DATETIME
     ,@statusList TMWTable_char6 READONLY'
   ,@BillDate1=@BillDate1
   ,@BillDate2=@BillDate2
   ,@Billto=@Billto
   ,@company=@company
   ,@shipper=@shipper
   ,@Consignee=@Consignee
   ,@DelDate1=@DelDate1
   ,@DelDate2=@DelDate2
   ,@driverid=@driverid
   ,@imagestatus=@imagestatus
   ,@ord_hdrnumber=@ord_hdrnumber
   ,@OrderedBy=@OrderedBy
   ,@othertype1=@othertype1
   ,@othertype2=@othertype2
   ,@othertype3=@othertype3
   ,@othertype4=@othertype4
   ,@paperworkstatus=@paperworkstatus
   ,@Rev1=@Rev1
   ,@Rev2=@Rev2
   ,@Rev3=@Rev3
   ,@Rev4=@Rev4
   ,@sch_date1=@sch_date1
   ,@sch_date2=@sch_date2
   ,@ShipDate1=@ShipDate1
   ,@ShipDate2=@ShipDate2
   ,@status=@status
   ,@user_id=@user_id
   ,@usr_id=@usr_id
   ,@xfrdate1=@xfrdate1
   ,@xfrdate2=@xfrdate2
   ,@ord_invoice_effectivedate1=@ord_invoice_effectivedate1
   ,@ord_invoice_effectivedate2=@ord_invoice_effectivedate2
   ,@statusList=@statusList


 
--PTS 89330 <end>

 --PTS 51570 JJF 20100510
 -- --PTS 40929 JJF 20071211
 --SELECT @rowsecurity = gi_string1
 --FROM @GIKEY 
 --WHERE gi_name = 'RowSecurity'

 ----PTS 41877
 ----SELECT @tmwuser = suser_sname()
 --exec @tmwuser = dbo.gettmwuser_fn


 --IF @rowsecurity = 'Y' AND EXISTS(SELECT * 
 --    FROM dbo.UserTypeAssignment
 --    WHERE usr_userid = @tmwuser) BEGIN 

 -- --PTS42432 JJF 20080421 
 -- --DELETE @invview
 -- --from @invview tp inner join dbo.orderheader oh on tp.mov_number = oh.mov_number
 -- --where  NOT ((isnull(oh.ord_BelongsTo, 'UNK') = 'UNK' 
 -- --  or EXISTS(SELECT * 
 -- --     FROM dbo.UserTypeAssignment
 -- --     WHERE usr_userid = @tmwuser 
 -- --       and (uta_type1 = oh.ord_BelongsTo
 -- --         or uta_type1 = 'UNK'))))

 -- DELETE @invview
 -- FROM @invview tp inner join dbo.invoiceheader ivh on tp.ivh_hdrnumber = ivh.ivh_hdrnumber
 -- WHERE  NOT ((isnull(ivh.ivh_BelongsTo, 'UNK') = 'UNK' 
 --   or EXISTS(SELECT * 
 --      FROM dbo.UserTypeAssignment
 --      WHERE usr_userid = @tmwuser 
 --        and (uta_type1 = ivh.ivh_BelongsTo
 --          or uta_type1 = 'UNK'))))
 -- --END PTS42432 JJF 20080421 

 --END
 ----END PTS 40929 JJF 20071211

 SELECT 
   @rowsecurity = gi_string1
 FROM 
   @GIKEY
 WHERE 
   gi_name = 'RowSecurity';

 IF @rowsecurity = 'Y'
 BEGIN 
  DELETE 
    @invview
  FROM 
    @invview tp  
      INNER JOIN 
    dbo.invoiceheader ivh WITH (NOLOCK) ON tp.ivh_hdrnumber = ivh.ivh_hdrnumber
  WHERE 
    NOT EXISTS (SELECT 
                  *  
                FROM 
                  RowRestrictValidAssignments_invoiceheader_fn() rsva 
                WHERE 
                  ivh.rowsec_rsrv_id = rsva.rowsec_rsrv_id 
                    OR 
                  rsva.rowsec_rsrv_id = 0);
 END;
 --END PTS 51570 JJF 20100510
   
 -- LOR PTS# 15300 do updates for Floridarock only    
 IF (SELECT UPPER(gi_string1) FROM @GIKEY WHERE gi_name = 'SystemOwner') = 'FLORIDAROCK'    
 BEGIN    
  -- return the trltype3 column value (for flarock indicates tank, dump, flatbed)     
  UPDATE 
    invview      -- NQIAO 08/28/12 PTS 62059 add @ --removed @ with 89330
  SET 
    trltype3 = t.trl_type3     
  FROM 
    dbo.trailerprofile t WITH (NOLOCK)
      INNER JOIN
    @invview invview ON t.trl_number = invview.ivh_trailer;    
    
  -- Provide a total linehaul charge for each invoice    
  UPDATE 
    invview      -- NQIAO 08/28/12 PTS 62059 add @ --removed @ and modified subquery with 89330
  SET 
    totallinehaul = ISNULL(b.CHARGE, 0)
  FROM
    @invview invview
      LEFT OUTER JOIN 
    ( SELECT
        d.ivh_hdrnumber
       ,SUM(d.ivd_charge) CHARGE
      FROM  
        dbo.invoicedetail d WITH (NOLOCK)
          INNER JOIN 
        dbo.chargetype c WITH (NOLOCK) ON d.cht_itemcode = c.cht_itemcode
          INNER JOIN 
        @invview invviewSUB ON invviewSUB.ivh_hdrnumber = d.ivh_hdrnumber
      WHERE 
        c.cht_primary = 'Y'
      GROUP BY 
        d.ivh_hdrnumber) b ON invview.ivh_hdrnumber = b.ivh_hdrnumber;
        
  -- Count the  distinct commodities on the invoice    
  UPDATE  
    invview      -- NQIAO 08/28/12 PTS 62059 add @  --removed @ and subquery with 89330
  SET 
    commodities = ISNULL(b.TheCOUNTER, 0)
  FROM
    @invview invview
      LEFT OUTER JOIN 
    ( SELECT 
        d.ivh_hdrnumber
       ,COUNT(DISTINCT(d.cmd_code)) TheCOUNTER
      FROM 
        dbo.invoicedetail d WITH (NOLOCK) 
          INNER JOIN 
        dbo.CHARGETYPE C WITH (NOLOCK) ON d.cht_itemcode = c.cht_itemcode
          INNER JOIN 
        @invview invviewSUB ON invviewSUB.ivh_hdrnumber = d.ivh_hdrnumber
      WHERE
        d.cht_itemcode NOT IN ('MIN','ORDFLT')
          AND
        d.ivd_type <> 'SUB'    
          AND
        c.cht_primary = 'Y'
      GROUP BY 
        d.ivh_hdrnumber) b ON invview.ivh_hdrnumber = b.ivh_hdrnumber;
    
  -- Count the commodities which match to the edicommodity table    
  UPDATE  
    invview      -- NQIAO 08/28/12 PTS 62059 add @ --removed @ and modified subquery with 89330
  SET 
    validcommodities =  ISNULL(b.TheCounter, 0)
  FROM
    @invview invview
      LEFT OUTER JOIN 
    ( SELECT 
        d.ivh_hdrnumber
       ,COUNT(DISTINCT(d.cmd_code)) TheCounter  
      FROM 
        dbo.invoicedetail d WITH (NOLOCK)
          INNER JOIN 
        dbo.edicommodity e WITH (NOLOCK) ON e.cmd_code = d.cmd_code
          INNER JOIN
        dbo.chargetype c WITH (NOLOCK) ON d.cht_itemcode = c.cht_itemcode
          INNER JOIN 
        @invview invviewSUB ON invviewSUB.ivh_hdrnumber = d.ivh_hdrnumber AND e.cmp_id = invviewSUB.ivh_billto
      WHERE     
        d.cht_itemcode NOT IN ( 'MIN','ORDFLT')    
          AND 
        d.ivd_type <> 'SUB'    
          AND     
        c.cht_primary = 'Y'
      GROUP BY 
        d.ivh_hdrnumber) b ON invview.ivh_hdrnumber = b.ivh_hdrnumber;   
    
  -- Count the accessorial charge types on the invoice     
  UPDATE  
    invview      -- NQIAO 08/28/12 PTS 62059 add @ --removed @ and modified subquery with 89330
  SET 
    accessorials = ISNULL(b.TheCounter, 0)
  FROM
    @invview invview
      LEFT OUTER JOIN 
    ( SELECT
        d.ivh_hdrnumber
       ,COUNT(DISTINCT(d.cht_itemcode)) TheCounter
      FROM 
        dbo.invoicedetail d WITH (NOLOCK)
          INNER JOIN 
        dbo.chargetype c WITH (NOLOCK) ON d.cht_itemcode = c.cht_itemcode
          INNER JOIN
        @invview invviewSUB ON d.ivh_hdrnumber = invviewSUB.ivh_hdrnumber
      WHERE
        c.cht_primary <> 'Y'
      GROUP BY 
        d.ivh_hdrnumber) b ON invview.ivh_hdrnumber = b.ivh_hdrnumber;   
       
  -- Count the accessorial charge types on the invoice which      
  -- match the edicommodity table    
  UPDATE 
    invview      -- NQIAO 08/28/12 PTS 62059 add @ --removed @ and modified subquery with 89330
  SET 
    validaccessorials = ISNULL(b.TheCounter, 0)
  FROM
    @invview invview
      LEFT OUTER JOIN 
    ( SELECT
        d.ivh_hdrnumber
       ,COUNT(DISTINCT(d.cht_itemcode)) TheCounter
      FROM 
        dbo.invoicedetail d WITH (NOLOCK) 
          INNER JOIN 
        dbo.chargetype c WITH (NOLOCK) ON d.cht_itemcode = c.cht_itemcode
          INNER JOIN
        dbo.ediaccessorial e WITH (NOLOCK) ON e.cht_itemcode = d.cht_itemcode
          INNER JOIN 
        @invview invviewSUB ON d.ivh_hdrnumber = invviewSUB.ivh_hdrnumber AND e.cmp_id = invviewSUB.ivh_billto
      WHERE     
        c.cht_primary <> 'Y'
      GROUP BY 
        d.ivh_hdrnumber) b ON invview.ivh_hdrnumber = b.ivh_hdrnumber;    
     
  -- Count the number of charge lines which have either a negative qty or rate    
  UPDATE 
    invview      -- NQIAO 08/28/12 PTS 62059 add @ --removed @ and subquery with 89330
  SET 
    negativecharges = ISNULL(b.TheCounter, 0)
  FROM
    @invview invview
      LEFT OUTER JOIN 
    ( SELECT
        d.ivh_hdrnumber
       ,COUNT(*) TheCounter 
      FROM   
        dbo.invoicedetail d WITH (NOLOCK)
          INNER JOIN 
        @invview invviewSUB ON d.ivh_hdrnumber = invviewSUB.ivh_hdrnumber
      WHERE      
        (d.ivd_quantity < 0 OR d.ivd_rate < 0.0)     
          AND    
        d.ivd_charge <> 0.0
      GROUP BY 
        d.ivh_hdrnumber) b ON invview.ivh_hdrnumber = b.ivh_hdrnumber;     
    
  -- update the shippers ticket as the ref number    
  UPDATE  
    invview      -- NQIAO 08/28/12 PTS 62059 add @ --removed @ with 89330
  SET 
    invview.refnumber = r.ref_number    
  FROM 
    dbo.referencenumber r WITH (NOLOCK)
      INNER JOIN 
    @invview invview ON r.ref_tablekey = invview.ord_hdrnumber
  WHERE 
    r.ref_table = 'ORDERHEADER'    
      AND
    r.ref_type = 'SHIPTK'
      AND 
    ref_tablekey > 0;
    
  -- retrieve any max charges for edi qualification    
  UPDATE  
    invview      -- NQIAO 08/28/12 PTS 62059 add @  --removed @ with 89330  
  SET 
    invview.trp_linehaulmax = t.trp_linehaulmax
   ,invview.trp_totchargemax = t.trp_totchargemax    
  FROM 
    dbo.edi_trading_partner t WITH (NOLOCK)
      INNER JOIN 
    @invview invview ON t.cmp_id = invview.ivh_billto;
END; 

 -- NQIOA PTS 81376 <end> move this set of code from the botton to here to ONLY handle the regular invoices
 -- NQIAO PTS 73475 - if selection by ref number is desired remove any records that don't match on the ref number <start>
 SELECT @ref_number = LTRIM(RTRIM(ISNULL(@ref_number,'')));    
 IF @ref_number > ''
 BEGIN
  UPDATE 
    @invview 
  SET 
    ivh_refnumber = '' 
  WHERE 
    ord_hdrnumber > 0; 

  UPDATE 
    @invview
  SET  
    ivh_refnumber = max_ref_number
  FROM 
    @invview iv2 
      INNER JOIN
    (SELECT 
       REF.ord_hdrnumber
      ,MAX(REF.ref_number) AS max_ref_number
     FROM 
       dbo.referencenumber REF WITH (NOLOCK)
         INNER JOIN 
       @invview iv1 ON REF.ord_hdrnumber = iv1.ord_hdrnumber
     WHERE 
       @ref_table IN (REF.ref_table, 'any')
         AND 
       ref_type = @ref_type
         AND 
       REF.ref_number LIKE @ref_number
     GROUP BY 
       REF.ord_hdrnumber) maxgen ON maxgen.ord_hdrnumber = iv2.ord_hdrnumber;
  
  DELETE 
    @invview 
  WHERE 
    ISNULL(ivh_refnumber, '') = '';
 END;
 -- NQIAO PTS 73475 <end>
 -- NQIOA PTS 81376 <end> 
END;  -- @doinvoices = 'Y' END here  
    
    
-- for RTP masterbills (the invoice selection only allows masterbills    
-- requested for RTP status or status = "PRN' with a masterbill#    
-- @breakon <> 'Y'    
  
IF @domasterbills = 'Y' AND ISNULL(@mbnumber,0) = 0    
BEGIN -- @domasterbills = 'Y' for new MB BEGIN here 
  IF @status = 'RTP'    
    IF @byuser = 'N'
      IF @ref_number > ''  -- 81376 <start>
        INSERT INTO 
          @invview
        SELECT 
          MIN(invoiceheader.mov_number), --  0 mov_number,    --44805 pmill
          --ivh_invoicenumber = CASE max(IsNull(company.cmp_mbgroup,'')) 
          ivh_invoicenumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
                  WHEN '' THEN @DefaultGroupBy 
                  ELSE MAX(cmp_mbgroup) 
                  END ) 
                WHEN  'INV' THEN MIN(invoiceheader.ivh_invoicenumber) 
                  --ILB/JJF 24619 add TCKTNUM group to group by ivh_invoicenumbmer
                WHEN  'TCKTNUM' THEN MAX(invoiceheader.ivh_invoicenumber)  
                  --END ILB/JJF 24619 add TCKTNUM group to group by ivh_invoicenumbmer
                ELSE  'Master'        
                END,    
          MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
          MIN(invoiceheader.ivh_billto) ivh_billto,    
          CAST('' AS VARCHAR(30)) billto_name,    
          -- ivh_shipper = CASE max(IsNull(company.cmp_mbgroup,''))
          ivh_shipper = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
                WHEN '' THEN @DefaultGroupBy 
                ELSE MAX(cmp_mbgroup) 
                END )  
                WHEN 'SHIPPER' THEN MIN(invoiceheader.ivh_shipper)  --PTS 40126     
                WHEN 'SHPCON' THEN MIN (invoiceheader.ivh_shipper)    
                WHEN 'ORGCMD' THEN MIN(invoiceheader.ivh_shipper)    
                WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_shipper)    
                WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_shipper)    
                WHEN 'PUPO' THEN MIN(invoiceheader.ivh_shipper)    
                WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_shipper)  
                WHEN 'MOVSHPCON'  THEN MIN(invoiceheader.ivh_shipper)  --44805 pmill
                WHEN 'CMDPO' THEN 'ALL'    
                WHEN 'DRCMDPO' THEN 'ALL'    
                WHEN 'DRPO' THEN 'ALL'    
                WHEN 'PO' THEN 'ALL'    
                ELSE @shipper    
                END,    
          CAST('' AS VARCHAR(30)) shipper_name,    
          --ivh_consignee = CASE max(IsNull(company.cmp_mbgroup,'')) 
          ivh_consignee = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
                  WHEN '' THEN @DefaultGroupBy 
                  ELSE MAX(cmp_mbgroup) 
                  END )  
              WHEN 'SHPCON' THEN MIN(invoiceheader.ivh_consignee) 
              WHEN 'CONSIGNEE' THEN MIN(invoiceheader.ivh_consignee)  --PTS 40126   
              WHEN 'ORGCMD' THEN MIN(invoiceheader.ivh_consignee)    
              WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_consignee)    
              WHEN 'DRPUCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
              WHEN 'DRCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
              WHEN 'DRPO' THEN MIN(invoiceheader.ivh_consignee)    
              WHEN 'CMDPO' THEN 'ALL'    
              WHEN 'PO' THEN 'ALL'    
              WHEN 'PUCMDPO' THEN 'ALL'    
              WHEN 'PUPO' THEN 'ALL'  
              WHEN 'MOVSHPCON'  THEN MIN(invoiceheader.ivh_consignee)  --44805 pmill
              ELSE @consignee               
              END,    
          CAST('' AS VARCHAR(30)) consignee_name,    
          MIN(invoiceheader.ivh_shipdate) ivh_shipdate,    
          MAX(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
          -- ivh_revtype1 = CASE max(IsNull(company.cmp_mbgroup,'')) 
          ivh_revtype1 =  CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
                  WHEN '' THEN @DefaultGroupBy 
                  ELSE MAX(cmp_mbgroup) 
                  END )  
              WHEN 'REV1' THEN MIN(invoiceheader.ivh_revtype1)    
              WHEN 'CMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
              WHEN 'DRCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
              WHEN 'DRPO' THEN MIN(invoiceheader.ivh_revtype1)
              WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_revtype1) 
              WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_revtype1)    
              WHEN 'PO' THEN MIN(invoiceheader.ivh_revtype1)    
              WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
              WHEN 'PUPO' THEN MIN(invoiceheader.ivh_revtype1)              
              WHEN 'ALL' THEN 'ALL'    
              ELSE  @rev1    
              END,    
          --  @rev2 ivh_revtype2, 
          ivh_revtype2 = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
                WHEN '' THEN @DefaultGroupBy 
                ELSE MAX(cmp_mbgroup) 
                END )  
              WHEN 'CMPREV2CUR' THEN MIN(invoiceheader.ivh_revtype2)                 
              ELSE @rev2    
              END,      
     
          @rev3 ivh_revtype3,      
          @rev4 ivh_revtype4,    
          SUM(ISNULL(invoiceheader.ivh_totalweight,0)) ivh_totalweight,    
          SUM(ISNULL(invoiceheader.ivh_totalpieces,0)) ivh_totalpieces,    
          SUM(ISNULL(invoiceheader.ivh_totalmiles,0)) ivh_totalmiles,    
          SUM(ISNULL(invoiceheader.ivh_totalvolume,0)) ivh_totalvolume,    
          MAX(ISNULL(invoiceheader.ivh_printdate,'1-1-1950')) ivh_printdate,     
          MIN(ISNULL(invoiceheader.ivh_billdate,'12-31-2049')) ivh_billdate,    
          MAX(ISNULL(invoiceheader.ivh_lastprintdate,'1-1-1950')) ivh_lastprintdate,    
          --PTS 25699 - Make use of ord_hdrnumber conditional on SplitbillMilkrun General Info Setting
          ord_hdrnumber = CASE @SplitbillMilkrun 
              WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_hdrnumber,0)) 
              ELSE 0
              END,             
          '' ivh_remark ,    
          MIN(ISNULL(invoiceheader.ivh_edi_flag,'')) ivh_edi_flag,    
          SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
          'RevType1' revtype1,    
          'RevType2' Revtype2,    
          'RevType3' revtype3,    
          'RevType4' revtype4,    
          0 ivh_hdrnumber,    
          'UNKNOWN' ivh_order_by,    
          'N/A' ivh_user_id1,    
          --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
          ord_number = CASE @SplitbillMilkrun 
              WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_number,'')) 
              ELSE '' 
              END,        
          CAST('' as CHAR(3)) ivh_terms,    
          CAST('' AS VARCHAR(8)) ivh_trailer,    
          MAX(ISNULL(ivh_tractor,'UNKNOWN')) ivh_tractor,    
          0 commodities,    
          0 validcommodities,    
          0 accessorials,    
          0 validaccessorials,    
          CAST('' AS VARCHAR(6)) trltype3,    
          -- CAST('' AS VARCHAR(6)) cmp_subcompany,    
          MIN(ISNULL(ord_subcompany,'UNK')),    
          0.00 totallinehaul,    
          0 negativecharges,    
          0 edi_210_flag,    
          'Y' ismasterbill,    
          'TrlType3' trltype3name,    
          MAX(company.cmp_mastercompany) cmp_mastercompany,    
          --CAST('' AS VARCHAR(20)) refnumber,    
          -- PRB commented for PTS32823 max(IsNull(ivh_ref_number,'')),
          -- Placed this into case statement below.
          --refnumber = CASE min(IsNull(cmp_mbgroup,'')) 
          refnumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
                WHEN '' THEN @DefaultGroupBy 
                ELSE MAX(cmp_mbgroup) 
                END )  
              WHEN 'COMPREFTYPE' THEN @ref_number
              ELSE MAX(ISNULL(ivh_ref_number,''))  
              END,     
          CAST('' as CHAR(3)) cmp_invoiceto,    
          CAST('' as CHAR(1)) cmp_invprintto,    
          0  cmp_invformat,    
          MAX(ISNULL(company.cmp_transfertype,'')) cmp_transfertype,    
          @Status ivh_Mbstatus,    
          0.00 trp_linehaulmax,    
          0.00 trp_totchargemax,    
          MAX(company.cmp_invcopies) cmp_invcopies,    
          MAX(CASE RTRIM(ISNULL(cmp_mbgroup,'')) WHEN '' THEN @DefaultGroupBy ELSE cmp_mbgroup END) cmp_mbgroup,      
          MAX(invoiceheader.ivh_originpoint) ivh_originpoint,    
          --cmd_code = CASE max(IsNull(company.cmp_mbgroup,''))
          cmd_code = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
                WHEN '' THEN @DefaultGroupBy 
                ELSE MAX(cmp_mbgroup) 
                END )  
                WHEN 'DRPUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
                WHEN 'DRCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))   
                WHEN 'PUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
                WHEN 'CMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
                WHEN 'ORGCMD' THEN   MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))      
                WHEN 'DRPO' THEN 'ALL'    
                WHEN 'DRPUPO' THEN 'ALL'    
                WHEN 'PO' THEN 'ALL'    
                WHEN 'PUPO' THEN 'ALL'    
                ELSE 'UNKNOWN'    
                END,       
          MAX(company.cmp_invoicetype) cmp_invoicetype,    
          MAX(ISNULL(ivh_currency,'')),    
          MAX(ISNULL(invoiceheader.tar_tariffitem,'')),    
          MAX(ISNULL(invoiceheader.tar_tarriffnumber,'')),    
          --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
          MAX(ISNULL(invoiceheader.ivh_mbimagestatus,0)),    
          MAX(ISNULL(ivh_definition,'')) ivh_definition,    
          MAX(ISNULL(ivh_applyto,'')) ivh_applyto,    
          MAX(ISNULL(orderheader.ord_fromorder,'')),  
          production_year = MIN( DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) ,  
          production_month = MIN(DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate))),
          CAST('' AS VARCHAR(254)) cmp_image_routing1,
          CAST('' AS VARCHAR(254)) cmp_image_routing2,
          CAST('' AS VARCHAR(254)) cmp_image_routing3,
          MAX(ISNULL(ivh_company, 'UNK')), 
          MAX(ISNULL(ivh_showshipper, 'UNKNOWN')),  --PTS 39333
          MAX(ISNULL(ivh_showcons, 'UNKNOWN')),
          MAX(ISNULL(invoiceheader.car_key,0)), 
          SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
          SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
          SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
          MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')), -- PTS 48221
          0 dbh_id,
          MAX(ISNULL(invoiceheader.ivh_mb_customgroupby,'')), -- PTS 55906 NQIAO 
          'MAS',--min(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke
          ''  -- PTS 73475 NQIAO
        FROM 
          dbo.invoiceheader WITH (NOLOCK)
            LEFT OUTER JOIN 
          dbo.orderheader WITH (NOLOCK) ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
            INNER JOIN 
          dbo.company WITH (NOLOCK) ON company.cmp_id = invoiceheader.ivh_billto
        WHERE 
          (@ord_hdrnumber = 0 OR invoiceheader.ord_hdrnumber = @ord_hdrnumber) --PTS 25699
            AND  
          DATEADD (DAY, company.cmp_mbdays, company.cmp_lastmb) <= (CASE WHEN cmp_mbdays < 0 THEN '20491231 23:59' ELSE @PrintDate END) --<= @PrintDate )        
          -- AND  
          --@Status = case @status when 'XFR' then invoiceheader.ivh_invoicestatus else invoiceheader.ivh_mbstatus end       
            AND  
          @Status = invoiceheader.ivh_mbstatus
            AND  
          company.cmp_invoicetype IN ('BTH','MAS') 
            AND 
          ISNULL (company.cmp_dedicated_bill, 'N') <> 'Y' /*PTS 52067 CGK*/    
          --  AND  
          --@BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto )
            AND  
          (@BillTo = 'UNKNOWN' OR invoiceheader.ivh_billto = @BillTo)
            AND  
          @Shipper IN ('UNKNOWN', invoiceheader.ivh_shipper)
            AND  
          @Consignee IN ('UNKNOWN', invoiceheader.ivh_consignee)
            AND  
          @OrderedBy IN ('UNKNOWN', invoiceheader.ivh_order_by)
            AND  
          invoiceheader.ivh_shipdate BETWEEN @ShipDate1 AND @ShipDate2
            AND  
          invoiceheader.ivh_deliverydate BETWEEN @DelDate1 AND @DelDate2
            AND  
          ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 -- 62719     
          --  AND  
          --@Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 )
            AND  
          CHARINDEX(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
          --  AND  
          --@Rev2 in ( 'UNK', invoiceheader.ivh_revtype2)     
            AND  
          CHARINDEX(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
          --  AND  
          --@Rev3 in ( 'UNK', invoiceheader.ivh_revtype3)
            AND  
          CHARINDEX(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
          --  AND  
          --@Rev4 in ('UNK', invoiceheader.ivh_revtype4)
            AND  
          CHARINDEX(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
            AND  
          invoiceheader.ivh_billdate BETWEEN @BillDate1 AND @BillDate2
            AND  
          @paperworkstatus IN ('UNK', invoiceheader.ivh_paperworkstatus )
           -- 47582 extra if the master bill has not yet been assigned there cant be an transferdate     
           -- and  ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
           --   or invoiceheader.ivh_xferdate IS null)) or @status not in ('XFR'))    
            AND  
          @company IN ('UNK', invoiceheader.ivh_company) 
            AND  
          (  invoiceheader.ord_hdrnumber = 0
              OR 
            ( SELECT 
                MIN(stp_schdtearliest)  
              FROM 
                stops  WITH (NOLOCK)
              WHERE 
                stops.ord_hdrnumber = invoiceheader.ord_hdrnumber 
                  AND  
                stp_sequence = (SELECT 
                                  MIN(stp_sequence) 
                                FROM 
                                  stops b WITH (NOLOCK) 
                                WHERE 
                                  b.ord_hdrnumber = invoiceheader.ord_hdrnumber)) BETWEEN @sch_date1 AND @sch_date2)
        --  AND  
        --@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,''))
        --  AND  
        --@imagestatus in (0,IsNull(ivh_mbimagestatus,0)) --only used for reprint invoices  
            AND  
          @driverid IN ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221    
            AND  
          (@othertype1 = '%' OR CHARINDEX( ',' + company.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
            AND  
          (@othertype2 = '%' OR CHARINDEX( ',' + company.cmp_othertype2 + ',',@othertype2) > 0)
            AND  
          (@othertype3 = '%' OR CHARINDEX( ',' + company.cmp_othertype3 + ',',@othertype3) > 0)
            AND  
          (@othertype4 = '%' OR CHARINDEX( ',' + company.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
            AND  
          invoiceheader.ord_hdrnumber IN (SELECT DISTINCT 
                                            ord_hdrnumber       -- PTS81376 <start>
                                          FROM 
                                            referencenumber 
                                          WHERE 
                                            ref_table = CASE @ref_table
                                                          WHEN 'any' THEN ref_table
                                                          ELSE @ref_table
                                                        END
                                              AND  
                                            ref_type = @ref_type 
                                              AND  
                                            ref_number = @ref_number)      -- PTS81376 <emd>
        GROUP BY 
          CASE ( CASE RTRIM(ISNULL(cmp_mbgroup,'')) 
          WHEN '' THEN @DefaultGroupBy ELSE cmp_mbgroup 
          END)
         WHEN 'CO' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_company     
         WHEN 'TRC' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_tractor    
         WHEN 'ORIGIN' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_originpoint    
         WHEN 'REV1' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_revtype1 
         WHEN 'SHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper +
          invoiceheader.ivh_consignee    
         WHEN 'INV' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber +    
          invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
         WHEN 'ORGCMD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +  invoiceheader.ivh_shipper +     
          invoiceheader.ivh_consignee +  orderheader.cmd_code                                       
         WHEN 'DRPUPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + ISNULL(invoiceheader.ivh_currency ,'') +     
          ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
          invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
          CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'DRPUCMDPO'  THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + 
          ISNULL(invoiceheader.ivh_currency ,'') + ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
          invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + 
          CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'DRCMDPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
          ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
          orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
          CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'PUPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
          ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
          ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + 
          CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'PUCMDPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
          ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper + orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
          CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'PO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +    
          ISNULL(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
          CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'CMDPO'   THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'')  +     
          ISNULL(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
          CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'DRPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
          ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + 
          CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
         WHEN 'FROMORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(orderheader.ord_fromorder,'') 
         WHEN 'REF#1' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_ref_number,'') 
         WHEN 'CMPREV2CUR' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + 
          ISNULL(invoiceheader.ivh_company,'UNKNOWN')+ISNULL(invoiceheader.ivh_revtype2,'UNK') +
          CASE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
          WHEN 'UNK' THEN 'Z-C$' 
          ELSE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
          END  
            WHEN 'SHPCONREF' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
          invoiceheader.ivh_consignee + ISNULL(invoiceheader.ivh_ref_number,'') 
         WHEN 'ORD_HDRNUMBER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT (VARCHAR, invoiceheader.ord_hdrnumber) --PTS 25699 
         WHEN 'COMPREFTYPE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ @ref_number -- PTS 32823
          --ILB/JJF 24619
         WHEN 'MASORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ ISNULL(orderheader.ord_fromorder,'')
         WHEN 'TCKTNUM' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber
          --END ILB/JJF 24619
         WHEN 'CONSIGNEE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_consignee --PTS 40126
         WHEN 'SHIPPER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper -- PTS 40126 exztra
         WHEN 'MOVSHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT(CHAR(10),ISNULL(invoiceheader.mov_number,0)) + invoiceheader.ivh_shipper + invoiceheader.ivh_consignee  --PTS44805
         WHEN 'CUSKEY' THEN invoiceheader.ivh_mb_customgroupby  -- PTS 55906
         ELSE invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))   
       END;   
     ELSE   -- 81376 <end>
    INSERT INTO 
      @invview     
    SELECT 
      MIN(invoiceheader.mov_number), --  0 mov_number,    --44805 pmill
      --ivh_invoicenumber = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_invoicenumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
              WHEN '' THEN @DefaultGroupBy 
              ELSE MAX(cmp_mbgroup) 
              END ) 
           WHEN  'INV' THEN MIN(invoiceheader.ivh_invoicenumber) 
              --ILB/JJF 24619 add TCKTNUM group to group by ivh_invoicenumbmer
           WHEN  'TCKTNUM' THEN MAX(invoiceheader.ivh_invoicenumber)  
              --END ILB/JJF 24619 add TCKTNUM group to group by ivh_invoicenumbmer
           ELSE  'Master'        
           END,    
      MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
      MIN(invoiceheader.ivh_billto) ivh_billto,    
      CAST('' AS VARCHAR(30)) billto_name,    
      -- ivh_shipper = CASE max(IsNull(company.cmp_mbgroup,''))
      ivh_shipper = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
           WHEN '' THEN @DefaultGroupBy 
           ELSE MAX(cmp_mbgroup) 
           END )  
           WHEN 'SHIPPER' THEN MIN(invoiceheader.ivh_shipper)  --PTS 40126     
           WHEN 'SHPCON' THEN MIN (invoiceheader.ivh_shipper)    
           WHEN 'ORGCMD' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'PUPO' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_shipper)  
           WHEN 'MOVSHPCON'  THEN MIN(invoiceheader.ivh_shipper)  --44805 pmill
           WHEN 'CMDPO' THEN 'ALL'    
           WHEN 'DRCMDPO' THEN 'ALL'    
           WHEN 'DRPO' THEN 'ALL'    
           WHEN 'PO' THEN 'ALL'    
           ELSE @shipper    
           END,    
      CAST('' AS VARCHAR(30)) shipper_name,    
      --ivh_consignee = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_consignee = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
             WHEN '' THEN @DefaultGroupBy 
             ELSE MAX(cmp_mbgroup) 
             END )  
          WHEN 'SHPCON' THEN MIN(invoiceheader.ivh_consignee) 
          WHEN 'CONSIGNEE' THEN MIN(invoiceheader.ivh_consignee)  --PTS 40126   
          WHEN 'ORGCMD' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPUCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPO' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'CMDPO' THEN 'ALL'    
          WHEN 'PO' THEN 'ALL'    
          WHEN 'PUCMDPO' THEN 'ALL'    
          WHEN 'PUPO' THEN 'ALL'  
          WHEN 'MOVSHPCON'  THEN MIN(invoiceheader.ivh_consignee)  --44805 pmill
          ELSE @consignee               
          END,    
      CAST('' AS VARCHAR(30)) consignee_name,    
      MIN(invoiceheader.ivh_shipdate) ivh_shipdate,    
      MAX(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
      -- ivh_revtype1 = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_revtype1 =  CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
             WHEN '' THEN @DefaultGroupBy 
             ELSE MAX(cmp_mbgroup) 
             END )  
          WHEN 'REV1' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'CMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'DRCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'DRPO' THEN MIN(invoiceheader.ivh_revtype1)
          WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_revtype1) 
          WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'PO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'PUPO' THEN MIN(invoiceheader.ivh_revtype1)              
          WHEN 'ALL' THEN 'ALL'    
          ELSE  @rev1    
          END,    
      --  @rev2 ivh_revtype2, 
      ivh_revtype2 = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END )  
          WHEN 'CMPREV2CUR' THEN MIN(invoiceheader.ivh_revtype2)                 
          ELSE @rev2    
          END,      
     
      @rev3 ivh_revtype3,      
      @rev4 ivh_revtype4,    
      SUM(ISNULL(invoiceheader.ivh_totalweight,0)) ivh_totalweight,    
      SUM(ISNULL(invoiceheader.ivh_totalpieces,0)) ivh_totalpieces,    
      SUM(ISNULL(invoiceheader.ivh_totalmiles,0)) ivh_totalmiles,    
      SUM(ISNULL(invoiceheader.ivh_totalvolume,0)) ivh_totalvolume,    
      MAX(ISNULL(invoiceheader.ivh_printdate,'1-1-1950')) ivh_printdate,     
      MIN(ISNULL(invoiceheader.ivh_billdate,'12-31-2049')) ivh_billdate,    
      MAX(ISNULL(invoiceheader.ivh_lastprintdate,'1-1-1950')) ivh_lastprintdate,    
      --PTS 25699 - Make use of ord_hdrnumber conditional on SplitbillMilkrun General Info Setting
      ord_hdrnumber = CASE @SplitbillMilkrun 
          WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_hdrnumber,0)) 
          ELSE 0 
          END,             
      '' ivh_remark ,    
      MIN(ISNULL(invoiceheader.ivh_edi_flag,'')) ivh_edi_flag,    
      SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
      'RevType1' revtype1,    
      'RevType2' Revtype2,    
      'RevType3' revtype3,    
      'RevType4' revtype4,    
      0 ivh_hdrnumber,    
      'UNKNOWN' ivh_order_by,    
      'N/A' ivh_user_id1,    
      --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
      ord_number = CASE @SplitbillMilkrun 
          WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_number,'')) 
          ELSE '' 
          END,        
      CAST('' as CHAR(3)) ivh_terms,    
      CAST('' as VARCHAR(8)) ivh_trailer,    
      MAX(ISNULL(ivh_tractor,'UNKNOWN')) ivh_tractor,    
      0 commodities,    
      0 validcommodities,    
      0 accessorials,    
      0 validaccessorials,    
      CAST('' AS VARCHAR(6)) trltype3,    
      -- CAST('' AS VARCHAR(6)) cmp_subcompany,    
      MIN(ISNULL(ord_subcompany,'UNK')),    
      0.00 totallinehaul,    
      0 negativecharges,    
      0 edi_210_flag,    
      'Y' ismasterbill,    
      'TrlType3' trltype3name,    
      MAX(company.cmp_mastercompany) cmp_mastercompany,    
      -- CAST('' AS VARCHAR(20)) refnumber,    
      -- PRB commented for PTS32823 max(IsNull(ivh_ref_number,'')),
      -- Placed this into case statement below.
      --refnumber = CASE min(IsNull(cmp_mbgroup,'')) 
      refnumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END )  
          WHEN 'COMPREFTYPE' THEN MIN(referencenumber.ref_number)
          ELSE MAX(ISNULL(ivh_ref_number,''))  
         END,     
      CAST('' as CHAR(3)) cmp_invoiceto,    
      CAST('' as CHAR(1)) cmp_invprintto,    
      0  cmp_invformat,    
      MAX(ISNULL(company.cmp_transfertype,'')) cmp_transfertype,    
      @Status ivh_Mbstatus,    
      0.00 trp_linehaulmax,    
      0.00 trp_totchargemax,    
      MAX(company.cmp_invcopies) cmp_invcopies,    
      MAX(CASE RTRIM(ISNULL(cmp_mbgroup,'')) WHEN '' THEN @DefaultGroupBy ELSE cmp_mbgroup END) cmp_mbgroup,      
      MAX(invoiceheader.ivh_originpoint) ivh_originpoint,    
      --cmd_code = CASE max(IsNull(company.cmp_mbgroup,''))
      cmd_code = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
           WHEN '' THEN @DefaultGroupBy 
           ELSE MAX(cmp_mbgroup) 
           END )  
           WHEN 'DRPUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'DRCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))   
           WHEN 'PUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'CMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'ORGCMD' THEN   MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))      
           WHEN 'DRPO' THEN 'ALL'    
           WHEN 'DRPUPO' THEN 'ALL'    
           WHEN 'PO' THEN 'ALL'    
           WHEN 'PUPO' THEN 'ALL'    
           ELSE 'UNKNOWN'    
           END,       
      MAX(company.cmp_invoicetype) cmp_invoicetype,    
      MAX(ISNULL(ivh_currency,'')),    
      MAX(ISNULL(invoiceheader.tar_tariffitem,'')),    
      MAX(ISNULL(invoiceheader.tar_tarriffnumber,'')),    
      --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
      MAX(ISNULL(invoiceheader.ivh_mbimagestatus,0)),    
      MAX(ISNULL(ivh_definition,'')) ivh_definition,    
      MAX(ISNULL(ivh_applyto,'')) ivh_applyto,    
      MAX(ISNULL(orderheader.ord_fromorder,'')),  
      production_year = MIN( DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) ,  
      production_month = MIN(DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate))),
      CAST('' AS VARCHAR(254)) cmp_image_routing1,
      CAST('' AS VARCHAR(254)) cmp_image_routing2,
      CAST('' AS VARCHAR(254)) cmp_image_routing3,
      MAX(ISNULL(ivh_company, 'UNK')), 
      MAX(ISNULL(ivh_showshipper, 'UNKNOWN')),  --PTS 39333
      MAX(ISNULL(ivh_showcons, 'UNKNOWN')),
      MAX(ISNULL(invoiceheader.car_key,0)), 
      SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
      SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
      SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
      MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')), -- PTS 48221
      0 dbh_id,
      MAX(ISNULL(invoiceheader.ivh_mb_customgroupby,'')), -- PTS 55906 NQIAO 
      MIN(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke
      ''  -- PTS 73475 NQIAO
    FROM 
      dbo.invoiceheader WITH (NOLOCK)
        LEFT OUTER JOIN 
      dbo.orderheader WITH (NOLOCK) ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
        INNER JOIN 
      dbo.company WITH (NOLOCK) ON company.cmp_id = invoiceheader.ivh_billto
      --PRB PTS32823 added Left Join of reftable
      LEFT OUTER JOIN dbo.referencenumber WITH (NOLOCK) ON 
       ref_tablekey = CASE (invoiceheader.ord_hdrnumber) 
           WHEN 0 THEN invoiceheader.ivh_hdrnumber 
           ELSE invoiceheader.ord_hdrnumber
           END
       AND ref_table = CASE (invoiceheader.ord_hdrnumber) 
           WHEN 0 THEN 'invoiceheader' 
           ELSE 'orderheader' 
           END
       AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
           WHEN '' THEN @cmp_dflt_reftype
           WHEN 'UNK' THEN @cmp_dflt_reftype
           ELSE company.cmp_reftype_unique
           END
       AND ref_sequence = CASE (invoiceheader.ord_hdrnumber)
            WHEN 0 THEN (SELECT MIN(ref_sequence)
                     FROM referencenumber r WITH (NOLOCK)
                     WHERE r.ref_tablekey = invoiceheader.ivh_hdrnumber
                     AND ref_table = 'invoiceheader'
                           AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
                    WHEN '' THEN @cmp_dflt_reftype
                    WHEN 'UNK' THEN @cmp_dflt_reftype
                    ELSE company.cmp_reftype_unique
                    END)
            ELSE (SELECT MIN(ref_sequence)
                    FROM referencenumber r WITH (NOLOCK)
                    --65860 WHERE r.ord_hdrnumber = invoiceheader.ord_hdrnumber
                    WHERE r.ref_tablekey = invoiceheader.ord_hdrnumber
                    AND ref_table = 'orderheader'
                          AND ref_type =  CASE ISNULL(company.cmp_reftype_unique, '')
                  WHEN '' THEN @cmp_dflt_reftype
                  WHEN 'UNK' THEN @cmp_dflt_reftype
                  ELSE company.cmp_reftype_unique
                  END
               AND ref_tablekey > 0)
            END
            --END PRB  
    WHERE 
      (@ord_hdrnumber = 0 OR invoiceheader.ord_hdrnumber = @ord_hdrnumber) --PTS 25699
        AND  
      DATEADD (DAY, company.cmp_mbdays, company.cmp_lastmb ) <= (CASE WHEN cmp_mbdays < 0 THEN '20491231 23:59' ELSE @PrintDate END) --<= @PrintDate )        
      --  AND  
      --(@Status = case @status when 'XFR' then invoiceheader.ivh_invoicestatus else invoiceheader.ivh_mbstatus end)       
        AND  
      @Status = invoiceheader.ivh_mbstatus
        AND  
      company.cmp_invoicetype IN ('BTH','MAS') 
        AND 
      ISNULL (company.cmp_dedicated_bill, 'N') <> 'Y' /*PTS 52067 CGK*/    
      --  AND  
      --@BillTo in ('UNKNOWN', invoiceheader.ivh_billto)     
        AND  
      (@BillTo = 'UNKNOWN' OR invoiceheader.ivh_billto = @BillTo)     
        AND  
      @Shipper IN ('UNKNOWN', invoiceheader.ivh_shipper)
        AND  
      @Consignee IN ('UNKNOWN', invoiceheader.ivh_consignee)
        AND  
      @OrderedBy IN ( 'UNKNOWN' , invoiceheader.ivh_order_by)
        AND  
      invoiceheader.ivh_shipdate BETWEEN @ShipDate1 AND @ShipDate2
        AND  
      invoiceheader.ivh_deliverydate BETWEEN @DelDate1 AND @DelDate2
        AND  
      ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 -- 62719     
      --  AND  @Rev1 in ('UNK', invoiceheader.ivh_revtype1)
        AND  
      CHARINDEX(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
      --  AND  
      --@Rev2 in ('UNK', invoiceheader.ivh_revtype2)
        AND  
      CHARINDEX(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0
      --  AND  
      --@Rev3 in ('UNK', invoiceheader.ivh_revtype3)
        AND  
      CHARINDEX(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0
      --  AND  
      --@Rev4 in ('UNK', invoiceheader.ivh_revtype4)
        AND  
      CHARINDEX(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
        AND  
      invoiceheader.ivh_billdate BETWEEN @BillDate1 AND @BillDate2
        AND  
      @paperworkstatus IN ('UNK', invoiceheader.ivh_paperworkstatus)
      -- 47582 extra if the master bill has not yet been assigned there cant be an transferdate     
      --  and  
      --((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) or invoiceheader.ivh_xferdate IS null)) or @status not in ('XFR'))    
        AND  
      @company IN ('UNK', invoiceheader.ivh_company) 
        AND  
      (  invoiceheader.ord_hdrnumber = 0 
          OR
          (SELECT 
             MIN(stp_schdtearliest)  
           FROM 
             stops  WITH (NOLOCK)
           WHERE 
             stops.ord_hdrnumber = invoiceheader.ord_hdrnumber 
               AND  
             stp_sequence = (SELECT 
                               MIN(stp_sequence) 
                             FROM 
                               stops b WITH (NOLOCK) 
                             WHERE 
                               b.ord_hdrnumber = invoiceheader.ord_hdrnumber)) BETWEEN @sch_date1 AND @sch_date2)
      --  And  
      --@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,''))
      --  AND  
      --@imagestatus in (0,IsNull(ivh_mbimagestatus,0)) --only used for reprint invoices  
        AND  
      @driverid IN ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221    
        AND  
      (@othertype1 = '%' OR CHARINDEX( ',' + company.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
        AND  
      (@othertype2 = '%' OR CHARINDEX( ',' + company.cmp_othertype2 + ',',@othertype2) > 0)
        AND  
      (@othertype3 = '%' OR CHARINDEX( ',' + company.cmp_othertype3 + ',',@othertype3) > 0)
        AND  
      (@othertype4 = '%' OR CHARINDEX( ',' + company.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
    /*  
    group by CASE IsNull(cmp_mbgroup,'') 
    WHEN 'TRC'    then invoiceheader.ivh_billto + invoiceheader.ivh_tractor    
    WHEN 'ORIGIN' then invoiceheader.ivh_billto + invoiceheader.ivh_originpoint    
    WHEN 'REV1'   then invoiceheader.ivh_billto + invoiceheader.ivh_revtype1
    WHEN 'SHPCON' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee    
    WHEN 'INV'    then invoiceheader.ivh_billto + invoiceheader.ivh_invoicenumber +    
      invoiceheader.ivh_shipper + invoiceheader.ivh_consignee
    WHEN 'ORGCMD' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee +  orderheader.cmd_code                                       
    WHEN 'DRPUPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + ivh_revtype1 + IsNull(ord_subcompany,'UNK')    
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )    
    WHEN 'DRPUCMDPO'  then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRCMDPO' then invoiceheader.ivh_billto +IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
      orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
      +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )
    WHEN 'PUCMDPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PO'      then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +    
      isnull(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'CMDPO'   then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'')  +     
      isnull(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +      
      ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'FROMORD' Then invoiceheader.ivh_billto + IsNull(orderheader.ord_fromorder,'') 
    WHEN 'REF#1' Then  invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_ref_number,'') 
    WHEN 'SHPCONREF' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + IsNull(invoiceheader.ivh_ref_number,'') 
    WHEN 'ORD_HDRNUMBER' Then invoiceheader.ivh_billto + convert (varchar, invoiceheader.ord_hdrnumber) --PTS 25699 
    WHEN 'COMPREFTYPE' Then invoiceheader.ivh_billto + ISNULL(referencenumber.ref_number, '') -- PTS 32823
      --ILB/JJF 24619
    WHEN 'MASORD' Then invoiceheader.ivh_billto + IsNull(orderheader.ord_fromorder,'')
    WHEN 'TCKTNUM' Then invoiceheader.ivh_billto + invoiceheader.ivh_invoicenumber
      --END ILB/JJF 24619
    WHEN 'CONSIGNEE' Then invoiceheader.ivh_billto + invoiceheader.ivh_consignee --PTS 40126
    WHEN 'SHIPPER' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper -- PTS 40126 exztra
    ELSE invoiceheader.ivh_billto
    */
    GROUP BY CASE ( CASE RTRIM(ISNULL(cmp_mbgroup,'')) 
        WHEN '' THEN @DefaultGroupBy ELSE cmp_mbgroup 
        END)
       WHEN 'CO' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_company     
       WHEN 'TRC' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_tractor    
       WHEN 'ORIGIN' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_originpoint    
       WHEN 'REV1' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_revtype1 
       WHEN 'SHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper +
        invoiceheader.ivh_consignee    
       WHEN 'INV' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber +    
        invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
       WHEN 'ORGCMD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +  invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee +  orderheader.cmd_code                                       
       WHEN 'DRPUPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRPUCMDPO'  THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + 
        ISNULL(invoiceheader.ivh_currency ,'') + ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + 
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRCMDPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
        orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PUPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
        ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + 
        CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PUCMDPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper + orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +    
        ISNULL(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'CMDPO'   THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'')  +     
        ISNULL(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + 
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'FROMORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(orderheader.ord_fromorder,'') 
       WHEN 'REF#1' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_ref_number,'') 
       WHEN 'CMPREV2CUR' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + 
        ISNULL(invoiceheader.ivh_company,'UNKNOWN')+ISNULL(invoiceheader.ivh_revtype2,'UNK') +
        CASE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
        WHEN 'UNK' THEN 'Z-C$' 
        ELSE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
        END  
          WHEN 'SHPCONREF' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + ISNULL(invoiceheader.ivh_ref_number,'') 
       WHEN 'ORD_HDRNUMBER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT (VARCHAR, invoiceheader.ord_hdrnumber) --PTS 25699 
       WHEN 'COMPREFTYPE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ ISNULL(referencenumber.ref_number, '') -- PTS 32823
        --ILB/JJF 24619
       WHEN 'MASORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ ISNULL(orderheader.ord_fromorder,'')
       WHEN 'TCKTNUM' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber
        --END ILB/JJF 24619
       WHEN 'CONSIGNEE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_consignee --PTS 40126
       WHEN 'SHIPPER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper -- PTS 40126 exztra
       WHEN 'MOVSHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT(CHAR(10),ISNULL(invoiceheader.mov_number,0)) + invoiceheader.ivh_shipper + invoiceheader.ivh_consignee  --PTS44805
       WHEN 'CUSKEY' THEN invoiceheader.ivh_mb_customgroupby  -- PTS 55906
       ELSE invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))   
       END;   
   
  IF @byuser = 'Y'
   IF @ref_table <> 'none'  -- 81376 <start>
    INSERT INTO @invview
    SELECT MIN(invoiceheader.mov_number), --  0 mov_number,    --44805 pmill
      --ivh_invoicenumber = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_invoicenumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
              WHEN '' THEN @DefaultGroupBy 
              ELSE MAX(cmp_mbgroup) 
              END ) 
           WHEN  'INV' THEN MIN(invoiceheader.ivh_invoicenumber) 
              --ILB/JJF 24619 add TCKTNUM group to group by ivh_invoicenumbmer
           WHEN  'TCKTNUM' THEN MAX(invoiceheader.ivh_invoicenumber)  
              --END ILB/JJF 24619 add TCKTNUM group to group by ivh_invoicenumbmer
           ELSE  'Master'        
           END,    
      MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
      MIN(invoiceheader.ivh_billto) ivh_billto,    
      CAST('' AS VARCHAR(30)) billto_name,    
      -- ivh_shipper = CASE max(IsNull(company.cmp_mbgroup,''))
      ivh_shipper = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
           WHEN '' THEN @DefaultGroupBy 
           ELSE MAX(cmp_mbgroup) 
           END )  
           WHEN 'SHIPPER' THEN MIN(invoiceheader.ivh_shipper)  --PTS 40126     
           WHEN 'SHPCON' THEN MIN (invoiceheader.ivh_shipper)    
           WHEN 'ORGCMD' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'PUPO' THEN MIN(invoiceheader.ivh_shipper)    
           WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_shipper)  
           WHEN 'MOVSHPCON'  THEN MIN(invoiceheader.ivh_shipper)  --44805 pmill
           WHEN 'CMDPO' THEN 'ALL'    
           WHEN 'DRCMDPO' THEN 'ALL'    
           WHEN 'DRPO' THEN 'ALL'    
           WHEN 'PO' THEN 'ALL'    
           ELSE @shipper    
           END,    
      CAST('' AS VARCHAR(30)) shipper_name,    
      --ivh_consignee = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_consignee = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
             WHEN '' THEN @DefaultGroupBy 
             ELSE MAX(cmp_mbgroup) 
             END )  
          WHEN 'SHPCON' THEN MIN(invoiceheader.ivh_consignee) 
          WHEN 'CONSIGNEE' THEN MIN(invoiceheader.ivh_consignee)  --PTS 40126   
          WHEN 'ORGCMD' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPUCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPO' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'CMDPO' THEN 'ALL'    
          WHEN 'PO' THEN 'ALL'    
          WHEN 'PUCMDPO' THEN 'ALL'    
          WHEN 'PUPO' THEN 'ALL'  
          WHEN 'MOVSHPCON'  THEN MIN(invoiceheader.ivh_consignee)  --44805 pmill
          ELSE @consignee               
          END,    
      CAST('' AS VARCHAR(30)) consignee_name,    
      MIN(invoiceheader.ivh_shipdate) ivh_shipdate,    
      MAX(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
      -- ivh_revtype1 = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_revtype1 =  CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
             WHEN '' THEN @DefaultGroupBy 
             ELSE MAX(cmp_mbgroup) 
             END )  
          WHEN 'REV1' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'CMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'DRCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'DRPO' THEN MIN(invoiceheader.ivh_revtype1)
          WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_revtype1) 
          WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'PO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
          WHEN 'PUPO' THEN MIN(invoiceheader.ivh_revtype1)              
          WHEN 'ALL' THEN 'ALL'    
          ELSE  @rev1    
          END,    
      --  @rev2 ivh_revtype2, 
      ivh_revtype2 = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END )  
          WHEN 'CMPREV2CUR' THEN MIN(invoiceheader.ivh_revtype2)                 
          ELSE @rev2    
          END,      
     
      @rev3 ivh_revtype3,      
      @rev4 ivh_revtype4,    
      SUM(ISNULL(invoiceheader.ivh_totalweight,0)) ivh_totalweight,    
      SUM(ISNULL(invoiceheader.ivh_totalpieces,0)) ivh_totalpieces,    
      SUM(ISNULL(invoiceheader.ivh_totalmiles,0)) ivh_totalmiles,    
      SUM(ISNULL(invoiceheader.ivh_totalvolume,0)) ivh_totalvolume,    
      MAX(ISNULL(invoiceheader.ivh_printdate,'1-1-1950')) ivh_printdate,     
      MIN(ISNULL(invoiceheader.ivh_billdate,'12-31-2049')) ivh_billdate,    
      MAX(ISNULL(invoiceheader.ivh_lastprintdate,'1-1-1950')) ivh_lastprintdate,    
      --PTS 25699 - Make use of ord_hdrnumber conditional on SplitbillMilkrun General Info Setting
      ord_hdrnumber = CASE @SplitbillMilkrun 
          WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_hdrnumber,0)) 
          ELSE 0 
          END,             
      '' ivh_remark ,    
      MIN(ISNULL(invoiceheader.ivh_edi_flag,'')) ivh_edi_flag,    
      SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
      'RevType1' revtype1,    
      'RevType2' Revtype2,    
      'RevType3' revtype3,    
      'RevType4' revtype4,    
      0 ivh_hdrnumber,    
      'UNKNOWN' ivh_order_by,    
      'N/A' ivh_user_id1,    
      --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
      ord_number = CASE @SplitbillMilkrun 
          WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_number,'')) 
          ELSE '' 
          END,        
      CAST('' as CHAR(3)) ivh_terms,    
      CAST('' as VARCHAR(8)) ivh_trailer,    
      MAX(ISNULL(ivh_tractor,'UNKNOWN')) ivh_tractor,    
      0 commodities,    
      0 validcommodities,    
      0 accessorials,    
      0 validaccessorials,    
      CAST('' AS VARCHAR(6)) trltype3,    
      -- CAST('' AS VARCHAR(6)) cmp_subcompany,    
      MIN(ISNULL(ord_subcompany,'UNK')),    
      0.00 totallinehaul,    
      0 negativecharges,    
      0 edi_210_flag,    
      'Y' ismasterbill,    
      'TrlType3' trltype3name,    
      MAX(company.cmp_mastercompany) cmp_mastercompany,    
      --CAST('' AS VARCHAR(20)) refnumber,    
      -- PRB commented for PTS32823 max(IsNull(ivh_ref_number,'')),
      -- Placed this into case statement below.
      --refnumber = CASE min(IsNull(cmp_mbgroup,'')) 
      refnumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END )  
          WHEN 'COMPREFTYPE' THEN @ref_number
          ELSE MAX(ISNULL(ivh_ref_number,''))  
         END,     
      CAST('' as CHAR(3)) cmp_invoiceto,    
      CAST('' as CHAR(1)) cmp_invprintto,    
      0  cmp_invformat,    
      MAX(ISNULL(company.cmp_transfertype,'')) cmp_transfertype,    
      @Status ivh_Mbstatus,    
      0.00 trp_linehaulmax,    
      0.00 trp_totchargemax,    
      MAX(company.cmp_invcopies) cmp_invcopies,    
      MAX(CASE RTRIM(ISNULL(cmp_mbgroup,'')) WHEN '' THEN @DefaultGroupBy ELSE cmp_mbgroup END) cmp_mbgroup,      
      MAX(invoiceheader.ivh_originpoint) ivh_originpoint,    
      --cmd_code = CASE max(IsNull(company.cmp_mbgroup,''))
      cmd_code = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
           WHEN '' THEN @DefaultGroupBy 
           ELSE MAX(cmp_mbgroup) 
           END )  
           WHEN 'DRPUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'DRCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))   
           WHEN 'PUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'CMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'ORGCMD' THEN   MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))      
           WHEN 'DRPO' THEN 'ALL'    
           WHEN 'DRPUPO' THEN 'ALL'    
           WHEN 'PO' THEN 'ALL'    
           WHEN 'PUPO' THEN 'ALL'    
           ELSE 'UNKNOWN'    
           END,       
      MAX(company.cmp_invoicetype) cmp_invoicetype,    
      MAX(ISNULL(ivh_currency,'')),    
      MAX(ISNULL(invoiceheader.tar_tariffitem,'')),    
      MAX(ISNULL(invoiceheader.tar_tarriffnumber,'')),    
      --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
      MAX(ISNULL(invoiceheader.ivh_mbimagestatus,0)),    
      MAX(ISNULL(ivh_definition,'')) ivh_definition,    
      MAX(ISNULL(ivh_applyto,'')) ivh_applyto,    
      MAX(ISNULL(orderheader.ord_fromorder,'')),  
      production_year = MIN( DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) ,  
      production_month = MIN(DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate))),
      CAST('' AS VARCHAR(254)) cmp_image_routing1,
      CAST('' AS VARCHAR(254)) cmp_image_routing2,
      CAST('' AS VARCHAR(254)) cmp_image_routing3,
      MAX(ISNULL(ivh_company, 'UNK')), 
       MAX(ISNULL(ivh_showshipper, 'UNKNOWN')),  --PTS 39333
       MAX(ISNULL(ivh_showcons, 'UNKNOWN')),
      MAX(ISNULL(invoiceheader.car_key,0)), 
      SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
      SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
      SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
      MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')), -- PTS 48221
      0 dbh_id,
      MAX(ISNULL(invoiceheader.ivh_mb_customgroupby,'')), -- PTS 55906 NQIAO 
      'MAS',--min(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke
      ''  -- PTS 73475 NQIAO
    FROM invoiceheader WITH (NOLOCK)
      LEFT OUTER JOIN dbo.orderheader WITH (NOLOCK) ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
      JOIN dbo.company WITH (NOLOCK) ON ( company.cmp_id = invoiceheader.ivh_billto )
    WHERE ( @ord_hdrnumber = 0 OR invoiceheader.ord_hdrnumber = @ord_hdrnumber) --PTS 25699
    AND  ( DATEADD ( DAY , company.cmp_mbdays , company.cmp_lastmb ) <= (CASE WHEN cmp_mbdays < 0 THEN '20491231 23:59' ELSE @PrintDate END) )     --<= @PrintDate )        
   -- AND  (  @Status = case @status when 'XFR' then invoiceheader.ivh_invoicestatus else invoiceheader.ivh_mbstatus end)       
    AND  (  @Status = invoiceheader.ivh_mbstatus)     
    AND  (company.cmp_invoicetype IN ('BTH','MAS') ) AND ISNULL (company.cmp_dedicated_bill, 'N') <> 'Y' /*PTS 52067 CGK*/    
   -- AND  ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
    AND  ( @BillTo = 'UNKNOWN' OR invoiceheader.ivh_billto = @BillTo )     
    AND  ( @Shipper IN ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
    AND  ( @Consignee IN ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
    AND  ( @OrderedBy IN ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
    AND  ( invoiceheader.ivh_shipdate BETWEEN @ShipDate1 AND @ShipDate2 )     
    AND  ( invoiceheader.ivh_deliverydate BETWEEN @DelDate1 AND @DelDate2 )     
    AND  (ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ) -- 62719     
   -- AND  ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
    AND  CHARINDEX(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
   -- AND  ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
    AND  CHARINDEX(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
   -- AND  ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
    AND  CHARINDEX(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
   -- AND  ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
    AND  CHARINDEX(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
    AND  ( invoiceheader.ivh_billdate BETWEEN @BillDate1 AND @BillDate2 )    
    AND  (@paperworkstatus IN ('UNK', invoiceheader.ivh_paperworkstatus ))
      -- 47582 extra if the master bill has not yet been assigned there cant be an transferdate     
   -- and  ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
   --   or invoiceheader.ivh_xferdate IS null)) or @status not in ('XFR'))    
    AND  @company IN ('UNK', invoiceheader.ivh_company) 
    AND  ((( SELECT MIN(stp_schdtearliest)  
       FROM stops  WITH (NOLOCK)
       WHERE stops.ord_hdrnumber = invoiceheader.ord_hdrnumber 
       AND  stp_sequence = (SELECT MIN(stp_sequence) 
               FROM stops b WITH (NOLOCK) 
               WHERE b.ord_hdrnumber = invoiceheader.ord_hdrnumber)) BETWEEN @sch_date1 AND @sch_date2)
       OR invoiceheader.ord_hdrnumber = 0)
   -- And  (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
   -- AND  @imagestatus in (0,IsNull(ivh_mbimagestatus,0)) --only used for reprint invoices  
    AND  @driverid IN ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221    
    AND  (@othertype1 = '%' OR CHARINDEX( ',' + company.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
    AND  (@othertype2 = '%' OR CHARINDEX( ',' + company.cmp_othertype2 + ',',@othertype2) > 0)
    AND  (@othertype3 = '%' OR CHARINDEX( ',' + company.cmp_othertype3 + ',',@othertype3) > 0)
    AND  (@othertype4 = '%' OR CHARINDEX( ',' + company.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
    AND  invoiceheader.ord_hdrnumber IN (SELECT DISTINCT ord_hdrnumber       -- PTS81376 <start>
              FROM referencenumber 
              WHERE ref_table = CASE @ref_table
                   WHEN 'any' THEN ref_table
                   ELSE @ref_table
                   END
              AND  ref_type = @ref_type 
              AND  ref_number = @ref_number)      -- PTS81376 <emd>
    GROUP BY CASE ( CASE RTRIM(ISNULL(cmp_mbgroup,'')) 
        WHEN '' THEN @DefaultGroupBy ELSE cmp_mbgroup 
        END)
       WHEN 'CO' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_company     
       WHEN 'TRC' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_tractor    
       WHEN 'ORIGIN' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_originpoint    
       WHEN 'REV1' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_revtype1 
       WHEN 'SHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper +
        invoiceheader.ivh_consignee    
       WHEN 'INV' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber +    
        invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
       WHEN 'ORGCMD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +  invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee +  orderheader.cmd_code                                       
       WHEN 'DRPUPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRPUCMDPO'  THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + 
        ISNULL(invoiceheader.ivh_currency ,'') + ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + 
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRCMDPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
        orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PUPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
        ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + 
        CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PUCMDPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper + orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +    
        ISNULL(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'CMDPO'   THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'')  +     
        ISNULL(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') + 
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'FROMORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(orderheader.ord_fromorder,'') 
       WHEN 'REF#1' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_ref_number,'') 
       WHEN 'CMPREV2CUR' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + 
        ISNULL(invoiceheader.ivh_company,'UNKNOWN')+ISNULL(invoiceheader.ivh_revtype2,'UNK') +
        CASE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
        WHEN 'UNK' THEN 'Z-C$' 
        ELSE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
        END  
          WHEN 'SHPCONREF' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + ISNULL(invoiceheader.ivh_ref_number,'') 
       WHEN 'ORD_HDRNUMBER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT (VARCHAR, invoiceheader.ord_hdrnumber) --PTS 25699 
       WHEN 'COMPREFTYPE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ @ref_number -- PTS 32823
        --ILB/JJF 24619
       WHEN 'MASORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ ISNULL(orderheader.ord_fromorder,'')
       WHEN 'TCKTNUM' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber
        --END ILB/JJF 24619
       WHEN 'CONSIGNEE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_consignee --PTS 40126
       WHEN 'SHIPPER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper -- PTS 40126 exztra
       WHEN 'MOVSHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT(CHAR(10),ISNULL(invoiceheader.mov_number,0)) + invoiceheader.ivh_shipper + invoiceheader.ivh_consignee  --PTS44805
       WHEN 'CUSKEY' THEN invoiceheader.ivh_mb_customgroupby  -- PTS 55906
       ELSE invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))   
       END;   
   ELSE   -- 81376 <end>
    INSERT INTO @invview     
    SELECT MIN(invoiceheader.mov_number), --0 mov_number,    44805 pmill
      --ivh_invoicenumber = CASE max(IsNull(company.cmp_mbgroup,''))\
      ivh_invoicenumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
              WHEN '' THEN @DefaultGroupBy 
              ELSE MAX(cmp_mbgroup) 
              END )  
     
           WHEN 'INV' THEN MIN(invoiceheader.ivh_invoicenumber)    --ILB/JJF 24619  
           WHEN 'TCKTNUM' THEN MAX(invoiceheader.ivh_invoicenumber) 
           WHEN 'MASORD' THEN  MAX(invoiceheader.ivh_invoicenumber)
           --END ILB/JJF 24619
           ELSE 'Master'        
           END,    
      MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
      MIN(invoiceheader.ivh_billto) ivh_billto,    
      CAST('' AS VARCHAR(30)) billto_name,    
      --ivh_shipper = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_shipper = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
             WHEN '' THEN @DefaultGroupBy 
             ELSE MAX(cmp_mbgroup) 
             END )  
          WHEN 'SHIPPER' THEN MIN(invoiceheader.ivh_shipper)  --PTS 40126     
          WHEN 'SHPCON' THEN  MIN(invoiceheader.ivh_shipper)    
          WHEN 'ORGCMD' THEN  MIN(invoiceheader.ivh_shipper)    
          WHEN 'DRPUPO' THEN  MIN(invoiceheader.ivh_shipper)    
          WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_shipper)    
          WHEN 'PUPO' THEN MIN(invoiceheader.ivh_shipper)    
          WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_shipper)    
          WHEN 'CMDPO' THEN 'ALL'    
          WHEN 'DRCMDPO' THEN 'ALL'    
          WHEN 'DRPO' THEN 'ALL'    
          WHEN 'PO' THEN 'ALL' 
          WHEN 'MOVSHPCON' THEN MIN(invoiceheader.ivh_shipper) --44805 pmill
          ELSE @shipper    
          END,    
      CAST('' AS VARCHAR(30)) shipper_name,    
      --ivh_consignee = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_consignee = CASE ( CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END )  
     
          WHEN 'SHPCON' THEN MIN(invoiceheader.ivh_consignee) 
          WHEN 'CONSIGNEE' THEN MIN(invoiceheader.ivh_consignee) --PTS 40126   
          WHEN 'ORGCMD' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPUCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRCMDPO'THEN MIN(invoiceheader.ivh_consignee)    
          WHEN 'DRPO' THEN   MIN(invoiceheader.ivh_consignee)    
          WHEN 'CMDPO' THEN 'ALL'    
          WHEN 'PO' THEN 'ALL'    
          WHEN 'PUCMDPO' THEN 'ALL'    
          WHEN 'PUPO' THEN 'ALL'   
          WHEN 'MOVSHPCON' THEN MIN(invoiceheader.ivh_consignee) --44805 pmill
          ELSE @consignee               
          END,    
      CAST('' AS VARCHAR(30)) consignee_name,    
      MIN(invoiceheader.ivh_shipdate) ivh_shipdate,    
      MAX(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
      --ivh_revtype1 = CASE max(IsNull(company.cmp_mbgroup,'')) 
      ivh_revtype1 = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END ) 
            WHEN 'REV1' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'CMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'DRCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'DRPO' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'DRPUCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'DRPUPO' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'PO' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'PUCMDPO' THEN MIN(invoiceheader.ivh_revtype1)    
            WHEN 'PUPO' THEN MIN(invoiceheader.ivh_revtype1)              
            WHEN 'ALL' THEN 'ALL'    
            ELSE @rev1    
            END,    
      --  @rev2 ivh_revtype2, 
      ivh_revtype2 = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END )  
            WHEN 'CMPREV2CUR' THEN MIN(invoiceheader.ivh_revtype2)                 
            ELSE @rev2    
            END,    
      @rev3 ivh_revtype3,      
      @rev4 ivh_revtype4,    
      SUM(ISNULL(invoiceheader.ivh_totalweight,0)) ivh_totalweight,    
      SUM(ISNULL(invoiceheader.ivh_totalpieces,0)) ivh_totalpieces,    
      SUM(ISNULL(invoiceheader.ivh_totalmiles,0)) ivh_totalmiles,    
      SUM(ISNULL(invoiceheader.ivh_totalvolume,0)) ivh_totalvolume,    
      MAX(ISNULL(invoiceheader.ivh_printdate,'1-1-1950')) ivh_printdate,      
      MIN(ISNULL(invoiceheader.ivh_billdate,'12-31-2049')) ivh_billdate,    
      MAX(ISNULL(invoiceheader.ivh_lastprintdate,'1-1-1950')) ivh_lastprintdate,    
      --PTS 25699 - Make use of ord_hdrnumber conditional on SplitbillMilkrun General Info Setting
      ord_hdrnumber = CASE @SplitbillMilkrun 
          WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_hdrnumber,0)) 
          ELSE 0 
          END,           
      '' ivh_remark ,    
      MIN(ISNULL(invoiceheader.ivh_edi_flag,'')) ivh_edi_flag,    
      SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
      'RevType1' revtype1,    
      'RevType2' Revtype2,    
      'RevType3' revtype3,    
      'RevType4' revtype4,    
      0 ivh_hdrnumber,    
      'UNKNOWN' ivh_order_by,    
      'N/A' ivh_user_id1,    
      --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
      ord_number = CASE @SplitbillMilkrun 
          WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_number,'')) 
          ELSE '' 
          END,         
      CAST('' as CHAR(3)) ivh_terms,    
      CAST('' as VARCHAR(8)) ivh_trailer,    
      MAX(ISNULL(ivh_tractor,'UNKNOWN')) ivh_tractor,    
      0 commodities,    
      0 validcommodities,    
      0 accessorials,    
      0 validaccessorials,    
      CAST('' as VARCHAR(6)) trltype3,    
      -- CAST('' AS VARCHAR(6)) cmp_subcompany,    
      MIN(ISNULL(ord_subcompany,'UNK')),    
      0.00 totallinehaul,    
      0 negativecharges,    
      0 edi_210_flag,    
      'Y' ismasterbill,    
      'TrlType3' trltype3name,    
      MAX(company.cmp_mastercompany) cmp_mastercompany,    
      --CAST('' AS VARCHAR(20)) refnumber,    
      -- PRB commented out for PTS32823max(IsNull(ivh_ref_number,'')),
      --refnumber = CASE min(IsNull(cmp_mbgroup,''))
      refnumber = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE MAX(cmp_mbgroup) 
            END )  
         WHEN 'COMPREFTYPE' THEN MAX(ISNULL(ivh_ref_number,'')) 
         ELSE MAX(ISNULL(ivh_ref_number,''))  
         END,        
      CAST('' as CHAR(3)) cmp_invoiceto,    
      CAST('' as CHAR(1)) cmp_invprintto,    
      0  cmp_invformat,    
      MAX(ISNULL(company.cmp_transfertype,'')) cmp_transfertype,    
      @Status ivh_Mbstatus,    
      0.00 trp_linehaulmax,    
      0.00 trp_totchargemax,    
      MAX(company.cmp_invcopies) cmp_invcopies,    
      cmp_mbgroup = MAX(CASE RTRIM(ISNULL(cmp_mbgroup,'')) 
            WHEN '' THEN @DefaultGroupBy 
            ELSE cmp_mbgroup 
            END),    
      -- max(IsNull(company.cmp_mbgroup,'')) cmp_mbgroup,    
      MAX(invoiceheader.ivh_originpoint) ivh_originpoint,    
      -- cmd_code = CASE max(IsNull(company.cmp_mbgroup,'')) 
      cmd_code = CASE (CASE MAX(RTRIM(ISNULL(cmp_mbgroup,''))) 
           WHEN '' THEN @DefaultGroupBy 
           ELSE MAX(cmp_mbgroup) 
           END )    
           WHEN 'DRPUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'DRCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))   
           WHEN 'PUCMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'CMDPO' THEN MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))     
           WHEN 'ORGCMD' THEN   MIN(ISNULL(orderheader.cmd_code,'UNKNOWN'))      
           WHEN 'DRPO' THEN 'ALL'    
           WHEN 'DRPUPO' THEN 'ALL'    
           WHEN 'PO' THEN 'ALL'    
           WHEN 'PUPO' THEN 'ALL'    
           ELSE 'UNKNOWN'    
           END,       
      MAX(company.cmp_invoicetype) cmp_invoicetype,    
      MAX(ISNULL(ivh_currency,'')),    
      MAX(ISNULL(invoiceheader.tar_tariffitem,'')),    
      MAX(ISNULL(invoiceheader.tar_tarriffnumber,'')),    
      --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
      MAX(ISNULL(invoiceheader.ivh_mbimagestatus,0)),    
      MAX(ISNULL(ivh_definition,'')) ivh_definition,    
      MAX(ISNULL(ivh_applyto,'')) ivh_applyto,    
      MAX(ISNULL(orderheader.ord_fromorder,'')),  
      production_year = MIN( DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) ,  
      production_month = MIN(DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate))),
      CAST('' AS VARCHAR(254)) cmp_image_routing1,
      CAST('' AS VARCHAR(254)) cmp_image_routing2,
      CAST('' AS VARCHAR(254)) cmp_image_routing3,
      MAX(ISNULL(ivh_company, 'UNK')),
      MAX(ISNULL(ivh_showshipper, 'UNKNOWN')),  --PTS 39333
      MAX(ISNULL(ivh_showcons,'UNKNOWN')) ,
      MAX(ISNULL(invoiceheader.car_key,0)),
      SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
      SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
      SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
      MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')), -- PTS 48221 
      0 dbh_id,
      MAX(ISNULL(invoiceheader.ivh_mb_customgroupby, '')), -- PTS 55906 NQIAO 
      MIN(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke
      ''  -- PTS 73475 NQIAO
    FROM dbo.invoiceheader WITH (NOLOCK)
      LEFT OUTER JOIN dbo.orderheader WITH (NOLOCK) ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
      JOIN dbo.company WITH (NOLOCK) ON ( company.cmp_id = invoiceheader.ivh_billto )
      --PRB PTS32823 added Left Join of reftable
      LEFT OUTER JOIN dbo.referencenumber WITH (NOLOCK) ON 
       invoiceheader.ord_hdrnumber = ref_tablekey
       AND ref_table = 'orderheader' AND ref_tablekey > 0
       AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
           WHEN '' THEN @cmp_dflt_reftype
           WHEN 'UNK' THEN @cmp_dflt_reftype
           ELSE company.cmp_reftype_unique
           END
       AND ref_sequence = (SELECT MIN(ref_sequence)
                 FROM referencenumber r WITH (NOLOCK)
                 --65860  WHERE r.ord_hdrnumber = invoiceheader.ord_hdrnumber
                 WHERE r.ref_tablekey = invoiceheader.ord_hdrnumber
                 AND ref_table = 'orderheader' AND ref_tablekey > 0
                       AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
                WHEN '' THEN @cmp_dflt_reftype
                WHEN 'UNK' THEN @cmp_dflt_reftype
                ELSE company.cmp_reftype_unique
                END)
                --END PRB
    WHERE ( @ord_hdrnumber = 0 OR invoiceheader.ord_hdrnumber = @ord_hdrnumber) --PTS 25699
    AND  ( DATEADD ( DAY , company.cmp_mbdays , company.cmp_lastmb ) <= (CASE WHEN cmp_mbdays < 0 THEN '20491231 23:59' ELSE @PrintDate END) )     --<= @PrintDate )             
   -- AND  (  @Status = case @status when 'XFR' then invoiceheader.ivh_invoicestatus else invoiceheader.ivh_mbstatus end)      
    AND  (  @Status = invoiceheader.ivh_mbstatus)    
    AND  (company.cmp_invoicetype IN ('BTH','MAS') )    
   -- AND  ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
    AND  ( @BillTo = 'UNKNOWN' OR invoiceheader.ivh_billto = @BillTo )     
    AND  ( @Shipper IN ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
    AND  ( @Consignee IN ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
    AND  ( @OrderedBy IN ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
    AND  ( invoiceheader.ivh_shipdate BETWEEN @ShipDate1 AND @ShipDate2 )     
    AND  ( invoiceheader.ivh_deliverydate BETWEEN @DelDate1 AND @DelDate2 )     
    AND  (ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ) -- 62719    
   -- AND  ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
    AND  CHARINDEX(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
   -- AND  ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
    AND  CHARINDEX(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
   -- AND  ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
    AND  CHARINDEX(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
   -- AND  ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
    AND  CHARINDEX(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
    AND  ( invoiceheader.ivh_billdate BETWEEN @BillDate1 AND @BillDate2 )    
    AND  ivh_user_id1 = @user_id    
    AND  (@paperworkstatus IN ('UNK', invoiceheader.ivh_paperworkstatus )) 
    AND  ((@status = 'XFR' AND ((invoiceheader.ivh_xferdate BETWEEN @xfrdate1 AND @xfrdate2) OR invoiceheader.ivh_xferdate IS NULL)) OR    
      @status NOT IN ('XFR'))    
    AND  @company IN ('UNK', invoiceheader.ivh_company) AND
      ((( SELECT MIN(stp_schdtearliest)  
       FROM stops WITH (NOLOCK) 
       WHERE stops.ord_hdrnumber = invoiceheader.ord_hdrnumber 
       AND stp_sequence = (SELECT MIN(stp_sequence) 
            FROM  stops b WITH (NOLOCK) 
            WHERE b.ord_hdrnumber = invoiceheader.ord_hdrnumber)) 
        BETWEEN @sch_date1 AND @sch_date2) OR invoiceheader.ord_hdrnumber = 0)
    AND  @driverid IN ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221
    AND  (@othertype1 = '%' OR CHARINDEX( ',' + company.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
    AND  (@othertype2 = '%' OR CHARINDEX( ',' + company.cmp_othertype2 + ',',@othertype2) > 0)
    AND  (@othertype3 = '%' OR CHARINDEX( ',' + company.cmp_othertype3 + ',',@othertype3) > 0)
    AND  (@othertype4 = '%' OR CHARINDEX( ',' + company.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
   -- And  (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
      --(field does not appear on screen for MB reprint) AND @imagestatus in (0,IsNull(ivh_mbimagestatus,0))     
    /*  
    group by CASE IsNull(cmp_mbgroup,'') 
    WHEN 'TRC'    then invoiceheader.ivh_billto + invoiceheader.ivh_tractor    
    WHEN 'ORIGIN' then invoiceheader.ivh_billto + invoiceheader.ivh_originpoint    
    WHEN 'REV1'   then invoiceheader.ivh_billto + invoiceheader.ivh_revtype1
    WHEN 'SHPCON' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee    
    WHEN 'INV'    then invoiceheader.ivh_billto + invoiceheader.ivh_invoicenumber +    
      invoiceheader.ivh_shipper + invoiceheader.ivh_consignee
    WHEN 'ORGCMD' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee +  orderheader.cmd_code                                       
    WHEN 'DRPUPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + ivh_revtype1 + IsNull(ord_subcompany,'UNK')    
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )    
    WHEN 'DRPUCMDPO'  then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRCMDPO' then invoiceheader.ivh_billto +IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
      orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
      +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )
    WHEN 'PUCMDPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PO'      then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +    
      isnull(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'CMDPO'   then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'')  +     
      isnull(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +      
      ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
      + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'FROMORD' Then invoiceheader.ivh_billto + IsNull(orderheader.ord_fromorder,'') 
    WHEN 'REF#1' Then  invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_ref_number,'') 
    WHEN 'SHPCONREF' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + IsNull(invoiceheader.ivh_ref_number,'') 
    WHEN 'ORD_HDRNUMBER' Then invoiceheader.ivh_billto + convert (varchar, invoiceheader.ord_hdrnumber) --PTS 25699 
    WHEN 'COMPREFTYPE' Then invoiceheader.ivh_billto + ISNULL(referencenumber.ref_number, '') -- PTS 32823
      --ILB/JJF 24619
    WHEN 'MASORD' Then invoiceheader.ivh_billto + IsNull(orderheader.ord_fromorder,'')
    WHEN 'TCKTNUM' Then invoiceheader.ivh_billto + invoiceheader.ivh_invoicenumber
      --END ILB/JJF 24619
    WHEN 'CONSIGNEE' Then invoiceheader.ivh_billto + invoiceheader.ivh_consignee --PTS 40126
    WHEN 'SHIPPER' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper -- PTS 40126 exztra
    ELSE invoiceheader.ivh_billto     
    */
    GROUP BY CASE  (CASE RTRIM(ISNULL(cmp_mbgroup,'')) 
        WHEN '' THEN @DefaultGroupBy 
        ELSE cmp_mbgroup 
        END)
       WHEN 'CO' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_company     
       WHEN 'TRC' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_tractor    
       WHEN 'ORIGIN' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_originpoint    
       WHEN 'REV1'   THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_revtype1 
       WHEN 'SHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee    
       WHEN 'INV'    THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber +    
        invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
       WHEN 'ORGCMD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +  invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee +  orderheader.cmd_code                                       
       WHEN 'DRPUPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRPUCMDPO'  THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +  ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRCMDPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
        orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PUPO'  THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PUCMDPO' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
        orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +  
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'PO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +    
        ISNULL(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'CMDPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'')  +     
        ISNULL(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + ISNULL(ord_subcompany,'UNK')+
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'DRPO' THEN invoiceheader.ivh_billto +CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_currency ,'') +     
        ISNULL(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee + ivh_revtype1 + ISNULL(ord_subcompany,'UNK') +
        CONVERT(CHAR(4),DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) + CONVERT(CHAR(2),DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate)) )  
       WHEN 'FROMORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(orderheader.ord_fromorder,'') 
       WHEN 'REF#1' THEN  invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +ISNULL(invoiceheader.ivh_ref_number,'') 
       WHEN 'CMPREV2CUR' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) +
        ISNULL(invoiceheader.ivh_company,'UNKNOWN')+ISNULL(invoiceheader.ivh_revtype2,'UNK')+
        CASE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
        WHEN 'UNK' THEN 'Z-C$' 
        ELSE ISNULL(invoiceheader.ivh_currency,'Z-C$') 
        END  
       WHEN 'SHPCONREF' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
        invoiceheader.ivh_consignee + ISNULL(invoiceheader.ivh_ref_number,'') 
       WHEN 'ORD_HDRNUMBER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT (VARCHAR, invoiceheader.ord_hdrnumber) --PTS 25699 
       WHEN 'COMPREFTYPE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ ISNULL(referencenumber.ref_number, '') -- PTS 32823
        --ILB/JJF 24619
       WHEN 'MASORD' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ ISNULL(orderheader.ord_fromorder,'')
       WHEN 'TCKTNUM' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber
        --END ILB/JJF 24619
       WHEN 'CONSIGNEE' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))+ invoiceheader.ivh_consignee --PTS 40126
       WHEN 'SHIPPER' THEN invoiceheader.ivh_billto+ CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper -- PTS 40126 exztra
       WHEN 'MOVSHPCON' THEN invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0)) + CONVERT(CHAR(10),ISNULL(invoiceheader.mov_number,0)) + invoiceheader.ivh_shipper + invoiceheader.ivh_consignee  --PTS44805
       WHEN 'CUSKEY' THEN invoiceheader.ivh_mb_customgroupby  -- PTS 55906
       ELSE invoiceheader.ivh_billto + CONVERT(CHAR(6),ISNULL(invoiceheader.car_key,0))   
       END;   
END;  -- @domasterbills = 'Y' for new MB END here
      
  
-- If selection datawindow has masterbills and status = 'PRN' the    
-- only parameter used is the master bill number    
IF @domasterbills = 'Y' AND ISNULL(@mbnumber,0) > 0 AND EXISTS (SELECT 1 FROM invoiceheader WITH (NOLOCK) WHERE ivh_mbnumber = @mbnumber)   
BEGIN -- @domasterbills = 'Y' for existing MB BEGIN here    
 IF @byuser = 'N'         
  INSERT INTO @invview     
  SELECT MIN(invoiceheader.mov_number), --0 mov_number,    44805 pmill
    'Master' ivh_invoicenumber,   
    MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
    MIN(invoiceheader.ivh_billto) ivh_billto,    
    CAST('' AS VARCHAR(30)) billto_name,    
    'UNKNOWN' ivh_shipper,    
    CAST('' AS VARCHAR(30)) shipper_name,    
    'UNKNOWN' ivh_consignee,    
    CAST('' AS VARCHAR(30)) consignee_name,    
    MIN(invoiceheader.ivh_shipdate) ivh_shipdate,    
    MAX(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
    @rev1 ivh_revtype1,      
    @rev2 ivh_revtype2,    
    @rev3 ivh_revtype3,      
    @rev4 ivh_revtype4,    
    SUM(ISNULL(invoiceheader.ivh_totalweight,0)) ivh_totalweight,    
    SUM(ISNULL(invoiceheader.ivh_totalpieces,0)) ivh_totalpieces,    
    SUM(ISNULL(invoiceheader.ivh_totalmiles,0)) ivh_totalmiles,    
    SUM(ISNULL(invoiceheader.ivh_totalvolume,0)) ivh_totalvolume,    
    MAX(ISNULL(invoiceheader.ivh_printdate,'1-1-1950')) ivh_printdate,      
    MIN(ISNULL(invoiceheader.ivh_billdate,'12-31-2049')) ivh_billdate,    
    MAX(ISNULL(invoiceheader.ivh_lastprintdate,'1-1-1950')) ivh_lastprintdate,    
    --PTS 25699 - Make use of ordhdr_number conditional on SplitbillMilkrun General Info Setting
    ord_hdrnumber = CASE @SplitbillMilkrun 
        WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_hdrnumber,0)) 
        ELSE 0 
        END,       
    '' ivh_remark ,    
    MIN(ISNULL(invoiceheader.ivh_edi_flag,'')) ivh_edi_flag,    
    SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
    'RevType1' revtype1,    
    'RevType2' Revtype2,    
    'RevType3' revtype3,    
    'RevType4' revtype4,    
    0 ivh_hdrnumber,    
    'UNKNOWN' ivh_order_by,    
    'N/A' ivh_user_id1,    
    --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
    ord_number = CASE @SplitbillMilkrun 
        WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_number,'')) 
        ELSE CAST('' AS VARCHAR(8))  
        END,     
    CAST('' as CHAR(3)) ivh_terms,    
    CAST('' as VARCHAR(8)) ivh_trailer,    
    MAX(ISNULL(ivh_tractor,'UNKNOWN')) ivh_tractor,    
    0 commodities,    
    0 validcommodities,    
    0 accessorials,    
    0 validaccessorials,    
    CAST('' AS VARCHAR(6)) trltype3,    
    -- CAST('' AS VARCHAR(6)) cmp_subcompany,    
    MIN(ISNULL(ord_subcompany,'UNK')),    
    0.00 totallinehaul,    
    0 negativecharges,    
    0 edi_210_flag,    
    'Y' ismasterbill,    
    'TrlType3' trltype3name,    
    CAST('' AS VARCHAR(8)) cmp_mastercompany,    
    CAST('' AS VARCHAR(30)) refnumber,    
    CAST('' as CHAR(3)) cmp_invoiceto,    
    CAST('' as CHAR(1)) cmp_invprintto,    
    0  cmp_invformat,    
    CAST('' as VARCHAR(6)) cmp_transfertype,    
    MIN(invoiceheader.ivh_mbstatus)  ivh_Mbstatus,    
    0.00 trp_linehaulmax,    
    0.00 trp_totchargemax,    
    MAX(company.cmp_invcopies) cmp_invcopies,    
    MAX(ISNULL(company.cmp_mbgroup,'')) cmp_mbgroup,    
    MAX(invoiceheader.ivh_originpoint) ivh_originpoint,    
    MAX(ISNULL(orderheader.cmd_code,'UNKNOWN')) orderheader_cmd_code,    
    MAX(company.cmp_invoicetype) cmp_invoicetype,    
    MAX(ISNULL(ivh_currency,'')),    
    MAX(ISNULL(invoiceheader.tar_tariffitem,'')),    
    MAX(ISNULL(invoiceheader.tar_tarriffnumber,'')),    
    --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
    MAX(ISNULL(invoiceheader.ivh_mbimagestatus,0)),    
    MAX(ISNULL(ivh_definition,'')) ivh_definition,    
    MAX(ISNULL(ivh_applyto,'')) ivh_applyto,    
    MAX(ISNULL(orderheader.ord_fromorder,'')) ,  
    production_year = MIN( DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) ,  
    production_month = MIN(DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate))),
    CAST('' AS VARCHAR(254)) cmp_image_routing1,
    CAST('' AS VARCHAR(254)) cmp_image_routing2,
    CAST('' AS VARCHAR(254)) cmp_image_routing3  ,
    MAX(ISNULL(ivh_company, 'UNK')),
    MAX(ISNULL(ivh_showshipper,'UNKNOWN')),
    MAX(ISNULL(ivh_showcons,'UNKNOWN')),
    MAX(ISNULL(invoiceheader.car_key,0)),  --40753  
    SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
    SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
    SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
    MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')), -- PTS 48221 
    0 dbh_id,
    MAX(ISNULL(invoiceheader.ivh_mb_customgroupby, '')), -- PTS 55906 NQIAO
    MIN(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke
    ''  -- PTS 73475 NQIAO
    --INTO @invview    
  FROM dbo.invoiceheader WITH (NOLOCK)
    LEFT OUTER JOIN dbo.orderheader WITH (NOLOCK) ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
    JOIN dbo.company WITH (NOLOCK) ON ( company.cmp_id = invoiceheader.ivh_billto )  
  WHERE ( @ord_hdrnumber = 0 OR invoiceheader.ord_hdrnumber = @ord_hdrnumber) --PTS 25699
  AND  ( ivh_mbnumber = @mbnumber)
  AND  (@othertype1 = '%' OR CHARINDEX( ',' + company.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
  AND  (@othertype2 = '%' OR CHARINDEX( ',' + company.cmp_othertype2 + ',',@othertype2) > 0)
  AND  (@othertype3 = '%' OR CHARINDEX( ',' + company.cmp_othertype3 + ',',@othertype3) > 0)
  AND  (@othertype4 = '%' OR CHARINDEX( ',' + company.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
  AND  (ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ); -- 62719
 -- AND  @status = (case @status when 'XFR' then invoiceheader.ivh_invoicestatus else @status end)    
 -- And  invoiceheader.ivh_invoicestatus <> (case @status when 'XFR' then ' ' else 'XFR'  end)  and
 --   (((select MIN(stp_schdtearliest)  
 --   from stops 
 --   where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
 --   between @sch_date1 and @sch_date2) or
 --   invoiceheader.ord_hdrnumber = 0)
     
 IF @byuser = 'Y'       
  INSERT INTO @invview     
  SELECT MIN(invoiceheader.mov_number), --0 mov_number,    44805 pmill
    'Master' ivh_invoicenumber, 
    MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
    MIN(invoiceheader.ivh_billto) ivh_billto,    
    CAST('' AS VARCHAR(30)) billto_name,    
    'UNKNOWN' ivh_shipper,    
    CAST('' AS VARCHAR(30)) shipper_name,    
    'UNKNOWN' ivh_consignee,    
    CAST('' AS VARCHAR(30)) consignee_name,    
    MIN(invoiceheader.ivh_shipdate) ivh_shipdate,    
    MAX(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
    @rev1 ivh_revtype1,      
    @rev2 ivh_revtype2,    
    @rev3 ivh_revtype3,      
    @rev4 ivh_revtype4,    
    SUM(ISNULL(invoiceheader.ivh_totalweight,0)) ivh_totalweight,    
    SUM(ISNULL(invoiceheader.ivh_totalpieces,0)) ivh_totalpieces,    
    SUM(ISNULL(invoiceheader.ivh_totalmiles,0)) ivh_totalmiles,    
    SUM(ISNULL(invoiceheader.ivh_totalvolume,0)) ivh_totalvolume,    
    MAX(ISNULL(invoiceheader.ivh_printdate,'1-1-1950')) ivh_printdate,      
    MIN(ISNULL(invoiceheader.ivh_billdate,'12-31-2049')) ivh_billdate,    
    MAX(ISNULL(invoiceheader.ivh_lastprintdate,'1-1-1950')) ivh_lastprintdate,    
    --PTS 25699 - Make use of ord_hdrnumber conditional on SplitbillMilkrun General Info Setting
    ord_hdrnumber = CASE @SplitbillMilkrun 
        WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_hdrnumber,0)) 
        ELSE 0 
        END,      
    '' ivh_remark ,    
    MIN(ISNULL(invoiceheader.ivh_edi_flag,'')) ivh_edi_flag,    
    SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
    'RevType1' revtype1,    
    'RevType2' Revtype2,    
    'RevType3' revtype3,    
    'RevType4' revtype4,    
    0 ivh_hdrnumber,    
    'UNKNOWN' ivh_order_by,    
    'N/A' ivh_user_id1,    
    --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
    ord_number = CASE @SplitbillMilkrun 
        WHEN 'Y' THEN MAX(ISNULL(orderheader.ord_number,'')) 
        ELSE CAST('' AS VARCHAR(8))  
        END,        
    CAST('' as CHAR(3)) ivh_terms,    
    CAST('' as VARCHAR(8)) ivh_trailer,    
    MAX(ISNULL(ivh_tractor,'UNKNOWN')) ivh_tractor,    
    0 commodities,    
    0 validcommodities,    
    0 accessorials,    
    0 validaccessorials,    
    CAST('' as VARCHAR(6)) trltype3,    
    -- CAST('' AS VARCHAR(6)) cmp_subcompany,    
    MIN(ISNULL(ord_subcompany,'UNK')),    
    0.00 totallinehaul,    
    0 negativecharges,    
    0 edi_210_flag,    
    'Y' ismasterbill,    
    'TrlType3' trltype3name,    
    CAST('' AS VARCHAR(8)) cmp_mastercompany,    
    CAST('' AS VARCHAR(30)) refnumber,    
    CAST('' as CHAR(3)) cmp_invoiceto,    
    CAST('' as CHAR(1)) cmp_invprintto,    
    0  cmp_invformat,    
    CAST('' as VARCHAR(6)) cmp_transfertype,    
    MIN(invoiceheader.ivh_mbstatus)  ivh_Mbstatus,    
    0.00 trp_linehaulmax,    
    0.00 trp_totchargemax,    
    MAX(company.cmp_invcopies) cmp_invcopies,    
    MAX(ISNULL(company.cmp_mbgroup,'')) cmp_mbgroup,    
    MAX(invoiceheader.ivh_originpoint) ivh_originpoint,    
    MAX(ISNULL(orderheader.cmd_code,'UNKNOWN')) orderheader_cmd_code,    
    MAX(company.cmp_invoicetype) cmp_invoicetype,    
    MAX(ISNULL(ivh_currency,'')),    
    MAX(ISNULL(invoiceheader.tar_tariffitem,'')),    
    MAX(ISNULL(invoiceheader.tar_tarriffnumber,'')),    
    --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
    MAX(ISNULL(invoiceheader.ivh_mbimagestatus,0)),    
    MAX(ISNULL(ivh_definition,'')) ivh_definition,    
    MAX(ISNULL(ivh_applyto,'')) ivh_applyto,    
    MAX(ISNULL(orderheader.ord_fromorder,'')) ,  
    production_year = MIN( DATEPART(YEAR,DATEADD(HOUR,-7,ivh_deliverydate))) ,  
    production_month = MIN(DATEPART(MONTH,DATEADD(HOUR,-7,ivh_deliverydate))),
    CAST('' AS VARCHAR(254)) cmp_image_routing1,
    CAST('' AS VARCHAR(254)) cmp_image_routing2,
    CAST('' AS VARCHAR(254)) cmp_image_routing3,
    MAX(ISNULL(ivh_company, 'UNK')),
    MAX(ISNULL(ivh_showshipper,'UNKNOWN')),
    MAX(ISNULL(ivh_showcons,'UNKNOWN')),  --PTS 39333 
    MAX(ISNULL(invoiceheader.car_key,0)),
    SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
    SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
    SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
    MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')), -- PTS 48221
    0 dbh_id,
    MAX(ISNULL(invoiceheader.ivh_mb_customgroupby, '')), -- PTS 55906 NQIAO  
    MIN(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke
    ''  -- PTS 73475 NQIAO
  FROM dbo.invoiceheader WITH (NOLOCK)
    LEFT OUTER JOIN dbo.orderheader WITH (NOLOCK) ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
    JOIN dbo.company WITH (NOLOCK) ON ( company.cmp_id = invoiceheader.ivh_billto )  
  WHERE ( @ord_hdrnumber = 0 OR invoiceheader.ord_hdrnumber = @ord_hdrnumber) --PTS 25699
  AND  ( ivh_mbnumber = @mbnumber)    
  AND  ivh_user_id1 = @user_id 
  AND  (@othertype1 = '%' OR CHARINDEX( ',' + company.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
  AND  (@othertype2 = '%' OR CHARINDEX( ',' + company.cmp_othertype2 + ',',@othertype2) > 0)
  AND  (@othertype3 = '%' OR CHARINDEX( ',' + company.cmp_othertype3 + ',',@othertype3) > 0)
  AND  (@othertype4 = '%' OR CHARINDEX( ',' + company.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>  
  AND  (ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ); -- 62719
 -- AND  @status = (case @status when 'XFR' then invoiceheader.ivh_invoicestatus else @status end)  
 -- And  invoiceheader.ivh_invoicestatus <> (case @status when 'XFR' then ' ' else 'XFR'  end)  
 -- and  (((select MIN(stp_schdtearliest)  
 --   from stops 
 --   where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 
 --   (select min(stp_sequence) 
 --   from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
 --   between @sch_date1 and @sch_date2) or
 --   invoiceheader.ord_hdrnumber = 0)
END;  -- @domasterbills = 'Y' for existing MB END here 


-- Dedicated bills are assigned a value that holds them together until a master bill is produced   (ivh_dedicated_invnumber)  
--IF @dodedbills = 'Y' and ISNULL(@mbnumber,0) = 0   
IF @dodedbills = 'Y' AND ISNULL(@mbnumber,0) = 0   AND ISNULL(@dbh_id,0) = 0
BEGIN -- @dodedbills = 'Y' for new Dedicated Bill BEGIN here    
 --IF @byuser = 'N' where clause handle @byuser   
 INSERT INTO @invview     
 SELECT 0 mov_number,    
   'Dedicated' ivh_invoicenumber, 
   MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
   MIN(invoiceheader.ivh_billto) ivh_billto,    
   CAST('' AS VARCHAR(30)) billto_name,    
   'UNKNOWN' ivh_shipper,    
   CAST('' AS VARCHAR(30)) shipper_name,    
   'UNKNOWN' ivh_consignee,    
   CAST('' AS VARCHAR(30)) consignee_name,    
   '19500101 00:00' ivh_shipdate,    
   '20491231 23:59' ivh_deliverydate,    
   @rev1 ivh_revtype1,      
   @rev2 ivh_revtype2,    
   @rev3 ivh_revtype3,      
   @rev4 ivh_revtype4,    
   0 ivh_totalweight,    
   0 ivh_totalpieces,    
   0 ivh_totalmiles,    
   0 ivh_totalvolume,    
   '19500101 00:00'  ivh_printdate,      
   '20491231 23:59' ivh_billdate,    
   '19500101 00:00' ivh_lastprintdate,    
   0 ord_hdrnumber,       
   '' ivh_remark ,    
   '' ivh_edi_flag,    
   SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
   'RevType1' revtype1,    
   'RevType2' Revtype2,    
   'RevType3' revtype3,    
   'RevType4' revtype4,    
   0 ivh_hdrnumber,    
   'UNKNOWN' ivh_order_by,    
   'N/A' ivh_user_id1,    
   --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
   '' ord_number ,     
   CAST('' as CHAR(3)) ivh_terms,    
   CAST('' as VARCHAR(8)) ivh_trailer,    
   'UNKNOWN' ivh_tractor,    
   0 commodities,    
   0 validcommodities,    
   0 accessorials,    
   0 validaccessorials,    
   CAST('' as VARCHAR(6)) trltype3,      
   MIN(ISNULL(ord_subcompany,'UNK')),    
   0.00 totallinehaul,    
   0 negativecharges,    
   0 edi_210_flag,    
   'Y' ismasterbill,    
   'TrlType3' trltype3name,    
   CAST('' as VARCHAR(8)) cmp_mastercompany,    
   CAST('' as VARCHAR(30)) refnumber,    
   CAST('' as CHAR(3)) cmp_invoiceto,    
   CAST('' as CHAR(1)) cmp_invprintto,    
   0  cmp_invformat,    
   CAST('' as VARCHAR(6)) cmp_transfertype,    
   'RTP'  ivh_Mbstatus,    
   0.00 trp_linehaulmax,    
   0.00 trp_totchargemax,    
   MAX(company.cmp_invcopies) cmp_invcopies,    
   '' cmp_mbgroup,    
   'UNKNOWN' ivh_originpoint,    
   'UNKNOWN' orderheader_cmd_code,    
   '' cmp_invoicetype,    
   'UNK' ivh_currency,  
   '' tar_tariffitem,    
   '' tar_tarriffnumber,   
   0 ivh_mbimagestatus,  
   '' ivh_definition,    
   '' ivh_applyto,    
   '' ord_fromorder,  
   '00' production_year ,  
   0 production_month ,
   CAST('' AS VARCHAR(254)) cmp_image_routing1,
   CAST('' AS VARCHAR(254)) cmp_image_routing2,
   CAST('' AS VARCHAR(254)) cmp_image_routing3  ,
   'UNK' ivh_company,
   'UNKNOWN' ivh_showshipper,
   'UNKNOWN' ivh_showcons,
   0 car_key,
   SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
   SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
   SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
   MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')),
   MAX(dbh_id),
   MAX(ISNULL(invoiceheader.ivh_mb_customgroupby, '')), -- PTS 55906 NQIAO
   MIN(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke 
   ''  -- PTS 73475 NQIAO
 FROM dbo.invoiceheader WITH (NOLOCK)
   JOIN dbo.company ON ivh_billto = cmp_id
   LEFT OUTER JOIN dbo.orderheader ON invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND invoiceheader.ord_hdrnumber > 0
 WHERE  ivh_mbnumber = 0   
 AND  @status =  invoiceheader.ivh_mbstatus
 AND  (company.cmp_invoicetype IN ('BTH','MAS') AND ISNULL (company.cmp_dedicated_bill, 'N') = 'Y')
 AND  ivh_mbnumber = 0
 AND  dbh_id > 0
 AND  @driverid IN ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221
 AND  (SELECT COUNT (*) FROM invoiceheader invh WITH (NOLOCK) 
    WHERE invh.dbh_id = invoiceheader.dbh_id 
    AND invh.ivh_definition IN('DEDBIL', 'CRD')  --NSUITE-201212 / PTS 106658   
    AND invh.ivh_mbstatus = 'RTP'
    AND ( @BillTo = 'UNKNOWN' OR invoiceheader.ivh_billto = @BillTo )     
    AND ( invh.ivh_shipdate BETWEEN @ShipDate1 AND @ShipDate2 )     
    AND ( invh.ivh_deliverydate BETWEEN @DelDate1 AND @DelDate2 )   
    AND ( invh.ivh_billdate BETWEEN @BillDate1 AND @BillDate2 )) > 0
 AND  ISNULL (ivh_user_id1, '') = CASE @byuser WHEN 'Y' THEN  @user_id ELSE   ISNULL (ivh_user_id1, '') END
 AND  CHARINDEX(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0   --PTS 71676 nloke start: revtype1-4 restriction was not used when retrieving ded bill
 AND  CHARINDEX(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0    
 AND  CHARINDEX(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
 AND  CHARINDEX(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0  --PTS 71676 end
 AND  (@othertype1 = '%' OR CHARINDEX( ',' + company.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
 AND  (@othertype2 = '%' OR CHARINDEX( ',' + company.cmp_othertype2 + ',',@othertype2) > 0)
 AND  (@othertype3 = '%' OR CHARINDEX( ',' + company.cmp_othertype3 + ',',@othertype3) > 0)
 AND  (@othertype4 = '%' OR CHARINDEX( ',' + company.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
 AND  (ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ) -- 62719
 GROUP BY dbh_id;
END; -- @dodedbills = 'Y' for new Dedicated Bill END here  


-- Printing by dedicated bill number   
IF @dodedbills = 'Y' AND ISNULL(@dbh_id,0) > 0   
BEGIN -- @dodedbills = 'Y' for existing Dedicated Bill BEGIN here 
 IF @DedicatedSummary = 'Y'
 BEGIN -- @DedicatedSummary = 'Y' BEGIN here
  INSERT INTO @invview     
  SELECT 0 mov_number, 
    'Dedicated' ivh_invoicenumber,   
    MIN(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
    MIN(invoiceheader.ivh_billto) ivh_billto,    
    CAST('' AS VARCHAR(30)) billto_name,    
    'UNKNOWN' ivh_shipper,    
    CAST('' AS VARCHAR(30)) shipper_name,    
    'UNKNOWN' ivh_consignee,    
    CAST('' AS VARCHAR(30)) consignee_name,    
    '19500101 00:00' ivh_shipdate,    
    '20491231 23:59' ivh_deliverydate,    
    @rev1 ivh_revtype1,      
    @rev2 ivh_revtype2,    
    @rev3 ivh_revtype3,      
    @rev4 ivh_revtype4,    
    0 ivh_totalweight,    
    0 ivh_totalpieces,    
    0 ivh_totalmiles,    
    0 ivh_totalvolume,    
    '19500101 00:00'  ivh_printdate,      
    '20491231 23:59' ivh_billdate,    
    '19500101 00:00' ivh_lastprintdate,    
    0 ord_hdrnumber,       
    '' ivh_remark ,    
    '' ivh_edi_flag,    
    SUM(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
    'RevType1' revtype1,    
    'RevType2' Revtype2,    
    'RevType3' revtype3,    
    'RevType4' revtype4,    
    0 ivh_hdrnumber,    
    'UNKNOWN' ivh_order_by,    
    'N/A' ivh_user_id1,    
    --PTS 25699 - Make use of ord_number conditional on SplitbillMilkrun General Info Setting
    '' ord_number ,     
    CAST('' as CHAR(3)) ivh_terms,    
    CAST('' AS VARCHAR(8)) ivh_trailer,    
    'UNKNOWN' ivh_tractor,    
    0 commodities,    
    0 validcommodities,    
    0 accessorials,    
    0 validaccessorials,    
    CAST('' AS VARCHAR(6)) trltype3,      
    MIN(ISNULL(ord_subcompany,'UNK')),    
    0.00 totallinehaul,    
    0 negativecharges,    
    0 edi_210_flag,    
    'Y' ismasterbill,    
    'TrlType3' trltype3name,    
    CAST('' AS VARCHAR(8)) cmp_mastercompany,    
    CAST('' AS VARCHAR(30)) refnumber,    
    CAST('' as CHAR(3)) cmp_invoiceto,    
    CAST('' as CHAR(1)) cmp_invprintto,    
    0  cmp_invformat,    
    CAST('' AS VARCHAR(6)) cmp_transfertype,    
    'RTP'  ivh_Mbstatus,    
    0.00 trp_linehaulmax,    
    0.00 trp_totchargemax,    
    MAX(bcmp.cmp_invcopies) cmp_invcopies,    
    '' cmp_mbgroup,    
    'UNKNOWN' ivh_originpoint,    
    'UNKNOWN' orderheader_cmd_code,    
    '' cmp_invoicetype,    
    'UNK' ivh_currency,  
    '' tar_tariffitem,    
    '' tar_tarriffnumber,   
    0 ivh_mbimagestatus,  
    '' ivh_definition,    
    '' ivh_applyto,    
    '' ord_fromorder,  
    '00' production_year ,  
    0 production_month ,
    CAST('' AS VARCHAR(254)) cmp_image_routing1,
    CAST('' AS VARCHAR(254)) cmp_image_routing2,
    CAST('' AS VARCHAR(254)) cmp_image_routing3  ,
    'UNK' ivh_company,
    'UNKNOWN' ivh_showshipper,
    'UNKNOWN' ivh_showcons,
    0 car_key,
    SUM (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
    SUM (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)),   /* 08/24/2009 MDH PTS 42291: Added */
    SUM (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),  /* 08/24/2009 MDH PTS 42291: Added */
    MAX(ISNULL(invoiceheader.ivh_driver,'UNKNOWN')),
    MAX(dbh_id),
    MAX(ISNULL(invoiceheader.ivh_mb_customgroupby, '')), -- PTS 55906 NQIAO
    MIN(dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0)),  --PTS 68745 nloke 
    ''  -- PTS 73475 NQIAO
  FROM dbo.invoiceheader WITH (NOLOCK)
    JOIN dbo.company bcmp WITH (NOLOCK) ON bcmp.cmp_id = invoiceheader.ivh_billto
    JOIN dbo.company scmp WITH (NOLOCK) ON scmp.cmp_id = invoiceheader.ivh_shipper
    JOIN  dbo.company ccmp WITH (NOLOCK) ON ccmp.cmp_id = invoiceheader.ivh_consignee
    LEFT OUTER JOIN dbo.orderheader WITH (NOLOCK) ON invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber 
  WHERE invoiceheader.dbh_id = @dbh_id    
  AND  @driverid IN ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221
  AND  ISNULL (ivh_user_id1, '') = CASE @byuser WHEN 'Y' THEN  @user_id ELSE   ISNULL (ivh_user_id1, '') END
  AND  CHARINDEX(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0   --PTS 71676 nloke start: revtype1-4 restriction was not used when retrieving ded bill
  AND  CHARINDEX(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0    
  AND  CHARINDEX(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
  AND  CHARINDEX(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0  --PTS 71676 end
  AND  (@othertype1 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
  AND  (@othertype2 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype2 + ',',@othertype2) > 0)
  AND  (@othertype3 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype3 + ',',@othertype3) > 0)
  AND  (@othertype4 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
  AND  (ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ) -- 62719
  GROUP BY dbh_id;
 END; -- @DedicatedSummary = 'Y' END here
 ELSE
 BEGIN -- @DedicatedSummary <> 'Y' BEGIN here
  INSERT INTO @invview     
   SELECT invoiceheader.mov_number,
     invoiceheader.ivh_invoicenumber,
     invoiceheader.ivh_invoicestatus,
     invoiceheader.ivh_billto,
     SUBSTRING(bcmp.cmp_name,1,30) billto_name,
     invoiceheader.ivh_shipper,
     SUBSTRING(scmp.cmp_name,1,30) shipper_name,
     invoiceheader.ivh_consignee,
     SUBSTRING(ccmp.cmp_name,1,30) consignee_name,
     invoiceheader.ivh_shipdate,
     invoiceheader.ivh_deliverydate,
     invoiceheader.ivh_revtype1,
     invoiceheader.ivh_revtype2,
     invoiceheader.ivh_revtype3,
     invoiceheader.ivh_revtype4,
     invoiceheader.ivh_totalweight,
     invoiceheader.ivh_totalpieces,
     invoiceheader.ivh_totalmiles,
     invoiceheader.ivh_totalvolume,
     invoiceheader.ivh_printdate,
     invoiceheader.ivh_billdate,
     invoiceheader.ivh_lastprintdate,
     invoiceheader.ord_hdrnumber,
     ivh_remark,
     invoiceheader.ivh_edi_flag,
     invoiceheader.ivh_totalcharge,
    'RevType1' RevType1,
     'RevType2' RevType2,
     'RevType3' Revtype3,
     'RevType4' RevType4,
     invoiceheader.ivh_hdrnumber,
     invoiceheader.ivh_order_by,
     invoiceheader.ivh_user_id1,
     invoiceheader.ord_number,
    invoiceheader.ivh_terms,
    invoiceheader.ivh_trailer,
    invoiceheader.ivh_tractor,
    0 'commodities',
    0 'validcommodities',
    0 'accessorials',
    0 'validaccessorials',
    CAST('' AS VARCHAR(6)) 'trltype3',
    bcmp.cmp_subcompany ,
    0.00 'totallinehaul',
    0 'negativecharges',
    bcmp.cmp_edi210 'edi_210_flag',
    'N' 'ismasterbill',
    'Trltype3' trltype3name,
    bcmp.cmp_mastercompany,
    CAST('' AS VARCHAR(30)) 'refnumber',
    bcmp.cmp_invoiceto,
    bcmp.cmp_invprintto,
    bcmp.cmp_invformat,
    bcmp.cmp_transfertype,
    invoiceheader.ivh_mbstatus,
    0.00 trp_linehaulmax,
    0.00 trp_totchargemax,
    bcmp.cmp_invcopies,
    bcmp.cmp_mbgroup,
    invoiceheader.ivh_originpoint,
    invoiceheader.ivh_order_cmd_code,
    bcmp.cmp_invoicetype,
    invoiceheader.ivh_currency,
    ISNULL(invoiceheader.tar_tariffitem,''),
    ISNULL(invoiceheader.tar_tarriffnumber,''),
    --IsNull(invoiceheader.ivh_ref_number,''),
    ISNULL(invoiceheader.ivh_imagestatus,0),
    ivh_definition,
    ivh_applyto,
    orderheader.ord_fromorder,
    '00' AS production_year,
    0 AS production_month,       
    CAST('' AS VARCHAR(254)) cmp_image_routing1,
    CAST('' AS VARCHAR(254)) cmp_image_routing2,
    CAST('' AS VARCHAR(254)) cmp_image_routing3,
    ISNULL(ivh_company, 'UNK'),
    ISNULL(ivh_showshipper, 'UNKNOWN'),
    ISNULL(ivh_showcons, 'UNKNOWN'), 
    ISNULL(invoiceheader.car_key,0),  --40753 
    dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber),  /* 08/24/2009 MDH PTS 42291: Added */
    dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber),    /* 08/24/2009 MDH PTS 42291: Added */
    dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),  /* 08/24/2009 MDH PTS 42291: Added */
    ISNULL(invoiceheader.ivh_driver,'UNKNOWN'),
    dbh_id,
    invoiceheader.ivh_mb_customgroupby, -- PTS 55906 NQIAO 
    dbo.fn_inv_invoice_type (invoiceheader.ivh_hdrnumber,0),  --PTS 68745 nloke
    ''  -- PTS 73475 NQIAO
  FROM dbo.invoiceheader WITH (NOLOCK)
    JOIN dbo.company bcmp WITH (NOLOCK) ON bcmp.cmp_id = invoiceheader.ivh_billto
    JOIN dbo.company scmp WITH (NOLOCK) ON scmp.cmp_id = invoiceheader.ivh_shipper
    JOIN dbo.company ccmp WITH (NOLOCK) ON ccmp.cmp_id = invoiceheader.ivh_consignee
    LEFT OUTER JOIN dbo.orderheader WITH (NOLOCK) ON invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber 
  WHERE invoiceheader.dbh_id = @dbh_id    
  AND  @driverid IN ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221
  AND  ISNULL (ivh_user_id1, '') = CASE @byuser WHEN 'Y' THEN  @user_id ELSE   ISNULL (ivh_user_id1, '') END
  AND  (@othertype1 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype1 + ',',@othertype1) > 0) -- PTS65845 <start>
  AND  (@othertype2 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype2 + ',',@othertype2) > 0)
  AND  (@othertype3 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype3 + ',',@othertype3) > 0)
  AND  (@othertype4 = '%' OR CHARINDEX( ',' + bcmp.cmp_othertype4 + ',',@othertype4) > 0) -- PTS65845 <end>
  AND  (ISNULL(orderheader.ord_invoice_effectivedate,'19500101 00:00') BETWEEN @ord_invoice_effectivedate1 AND @ord_invoice_effectivedate2 ); -- 62719
  -- GROUP BY dbh_id
 END; -- @DedicatedSummary <> 'Y' END here
END;  -- @dodedbills = 'Y' for existing Dedicated Bill BEGIN here 

UPDATE @invview     -- NQIAO 08/28/12 PTS 62059 add @
SET  invview.cmp_image_routing1 = company.cmp_image_routing1,
  invview.cmp_image_routing2 = company.cmp_image_routing2,
  invview.cmp_image_routing3 = company.cmp_image_routing3
FROM dbo.company WITH (NOLOCK), @invview invview
WHERE invview.ivh_billto = company.cmp_id;

/* 81376 - move this set of code to the regular invoice section above @doinvoice
-- NQIAO PTS 73475 - if selection by ref number is desired remove any records that don't match on the ref number <start>
SELECT @ref_number = ltrim(rtrim(isnull(@ref_number,'')))    
IF @ref_number > '' and @domasterbills <> 'Y' and @dodedbills <> 'Y'  -- regular invoice(s)   
BEGIN
 UPDATE @invview SET ivh_refnumber = '' WHERE ord_hdrnumber > 0 

 UPDATE @invview
 SET  ivh_refnumber = max_ref_number
 FROM @invview iv2 inner join
   (SELECT ref.ord_hdrnumber, MAX(ref.ref_number) as max_ref_number
    FROM referencenumber ref with (nolock) inner join @invview iv1 on ref.ord_hdrnumber = iv1.ord_hdrnumber
    WHERE @ref_table in (ref.ref_table, 'any')
    AND ref_type = @ref_type
    AND ref.ref_number like @ref_number
    GROUP BY ref.ord_hdrnumber) maxgen ON maxgen.ord_hdrnumber = iv2.ord_hdrnumber
 
 DELETE FROM @invview WHERE ISNULL(ivh_refnumber, '') = ''
END
-- NQIAO PTS 73475 <end>
81376 */

--SELECT * from @invview  
SELECT * FROM @invview i
 JOIN @statusLIST st ON i.invoicetype = st.KeyField;  --PTS 68745 nloke - need to look at invoicetype from branch_assignedtype table for billto
 
GO
GRANT EXECUTE ON  [dbo].[d_invoices_printqueue3_sp] TO [public]
GO
