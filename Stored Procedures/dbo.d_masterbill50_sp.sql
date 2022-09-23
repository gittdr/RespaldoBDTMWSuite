SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_masterbill50_sp] (@p_reprintflag varchar(10),@p_mbnumber int,@p_billto varchar(8), 
	@p_revtype1 varchar(6), @p_mbstatus varchar(6),
	@p_shipstart datetime,@p_shipend datetime,@p_billdate datetime )
AS
 
/*
 * 
 * NAME:d_masterbill50_sp
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoices 
 * based on the Billto selected in the interface.
 *
 * RETURNS:
 * 0  - uniqueness has not been violated 
 * >0 - uniqueness has been violated   
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_reprintflag, int, input, null;
 *       Has the masterbill been printed
 * 002 - @p_mbnumber, varchar(20), input, null;
 *       masterbill number
 * 003 - @p_billto, varchar(6), input, null;
 *       Billto selected
 * 004 - @p_revtype1, varchar(8), input, null;
 *       revtype 1 value
 * 005 - @p_mbstatus, int, output, null;
 *       status of masterbill ie XFR 
 * 006 - @p_shipstart, int, input, null;
 *       start date
 * 007 - @p_shipend, varchar(20), input, null;
 *       end date
 * 008 - @p_billdate, varchar(6), input, null;
 *       bill date of the masterbill
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 * 04/06/2006 - PTS 25129 - Imari Bremer - Create new masterbill format for Arrow Trucking
 **/
 

DECLARE 
 @v_int0  int,
 @v_tmprtp_rows int,
 @v_temp_name   varchar(30) ,  
 @v_temp_addr   varchar(30) ,  
 @v_temp_addr2  varchar(30),  
 @v_temp_nmstct varchar(47),
 @v_temp_altid  varchar(25),
 @v_tariffkey_startdate datetime,
 @v_tar_number int,
 @v_tar_tariffitem varchar(12),
 @v_show_shipper varchar(8),
 @v_show_cons    varchar(8),
 @v_commodity   varchar(60),
 @v_MinInv int, 
 @v_MinSeq int,
 @v_Min_Ord int,
 @v_remarks varchar(254),
 @v_MinShipper varchar(100), 
 @v_MinShipperAddr varchar(100) ,
 @v_MinShipperAddr2 varchar(100)  ,
 @v_MinShipperNmctst varchar(47)   ,
 @v_MinShipperZip VARCHAR(10) ,
 @v_MinCon varchar(100) , 
 @v_MinConAddr varchar(100) ,
 @v_MinConAddr2 varchar(100)  ,
 @v_MinConNmctst varchar(47),
 @v_MinConZip varchar(10),
 @v_MinConAddr3 varchar(100),
 @v_MinShipperAddr3 varchar(100),
 @v_MinShipperCountry varchar(50),
 @v_MinConsigneeCountry varchar(50),
 @v_Balance_Due float,
 @v_Total_Paid float,
 @v_temp_revdesc varchar(20)  


SELECT @v_int0 = 0
SELECT @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'
SET @v_MinInv = 0
SET @v_MinSeq = 0
       
-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
  BEGIN

    SELECT 
	 invoiceheader.ivh_invoicenumber,  
	 invoiceheader.ivh_hdrnumber, 
         invoiceheader.ivh_billto,   
         invoiceheader.ivh_totalcharge,   
         invoiceheader.ivh_originpoint,  
         invoiceheader.ivh_destpoint,   
         invoiceheader.ivh_origincity,   
         invoiceheader.ivh_destcity,   
         invoiceheader.ivh_shipdate,   
         invoiceheader.ivh_deliverydate,   
         invoiceheader.ivh_revtype1,
	 invoiceheader.ivh_mbnumber,
	 billto_name = cmp1.cmp_name,
         -- dpete for LOR pts4785 provide for maitlto override of billto
	 billto_address = 
	    CASE
	 	WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
	 	WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
	 	ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 billto_address2 = 
	    CASE
	 	WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
	 	WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
	 	ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 billto_nmstct =
	    CASE
	 	WHEN cmp1.cmp_mailto_name IS NULL THEN 
	 	   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(case CHARINDEX('/',cmp1.cty_nmstct) when 0 then len(cmp1.cty_nmstct) else CHARINDEX('/',cmp1.cty_nmstct)- 1 end)),'')
	 	WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
	 	   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(case CHARINDEX('/',cmp1.cty_nmstct) when 0 then len(cmp1.cty_nmstct) else CHARINDEX('/',cmp1.cty_nmstct)- 1 end)),'')
	 	ELSE 
	 	   ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(case CHARINDEX('/',cmp1.mailto_cty_nmstct) when 0 then len(cmp1.mailto_cty_nmstct) else CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 end)),'')	
	    END,
	 billto_zip = 
	    CASE
	 	WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
	 	WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
	 	ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty1.cty_nmstct  origin_nmctst,
	cty1.cty_state	 origin_state,
	cty2.cty_nmstct  dest_nmctst,
	cty2.cty_state	 dest_state,
	ivh_billdate     billdate,
	--ISNULL(ref1.ref_number,'')   billoflading,
	ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	--ISNULL(ref2.ref_number,'')   serialnum,
        --PTS# 25129 ILB 10/28/2004
        invoiceheader.ivh_shipper,     
        @v_temp_name shipper_name,  
        @v_temp_addr shipper_addr,  
	@v_temp_addr2 shipper_addr2,  
	@v_temp_nmstct shipper_nmctst,  
	invoiceheader.ivh_consignee,     
	@v_temp_name consignee_name,  
	@v_temp_addr consignee_addr,  
	@v_temp_addr2 consignee_addr2,  
	@v_temp_nmstct consignee_nmctst,
        @v_show_shipper ivh_showshipper,	  
        @v_show_cons ivh_showcons,	
        @v_tariffkey_startdate tariffkey_startdate,
        @v_tar_number tar_number,
        @v_tar_tariffitem tar_tariffitem,
        @v_commodity ivd_description ,
        @v_remarks remarks, 
        billto_address3 = 
	    CASE
	 	WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
	 	WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
	 	ELSE ''
	    END,
        @v_temp_altid cmp_altid,
        invoiceheader.ord_hdrnumber,
        ivh_hideshipperaddr,  
        ivh_hideconsignaddr,
        0 ivd_sequence ,
        ivh_user_id1,
	@v_temp_addr2 shipper_addr3,
        @v_temp_addr2 consignee_addr3  ,
        @v_MinShipperZip shipper_zip,
        @v_MinConZip consignee_zip ,      
	--END PTS# 25129 ILB 10/28/2004
        --PTS# 27140 ILB 03/09/2005
	isnull(cmp1.cmp_country,'')billto_country,
	@v_MinShipperCountry shipper_country,
	@v_MinConsigneeCountry consignee_country,
	sum(isnull(fgt.fgt_length,0)) fgt_length,
	sum(isnull(fgt.fgt_height,0))fgt_height,
	sum(isnull(fgt.fgt_width,0)) fgt_width,
	sum(isnull(fgt.fgt_weight,0)) fgt_weight,
        sum(isnull(fgt.fgt_count,0)) fgt_count,
        --isnull(fgt.fgt_length,0) fgt_length,
	--isnull(fgt.fgt_height,0)fgt_height,
	--isnull(fgt.fgt_width,0) fgt_width,
	--isnull(fgt.fgt_weight,0) fgt_weight,
        --isnull(fgt.fgt_count,0) fgt_count,
        ivh_invoicestatus,
        isnull(@v_Balance_Due,0) Balance_Due,
        isnull(@v_Total_Paid,0) Total_Paid,
        ivh_revtype2,
        @v_temp_revdesc revtype1_desc,
 	@v_temp_revdesc revtype2_desc        
	--PTS# 27140 ILB 03/09/2005
    into #tmpreprint_tbl  

    FROM company cmp1, 
         city cty1, 
         city cty2,         
	 invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
         left outer join freightdetail as fgt on (ivd.stp_number = fgt.stp_number)
	 --invoiceheader
         --invoicedetail ivd
	 -- freightdetail fgt
         --referencenumber ref1,referencenumber ref2
   WHERE ( invoiceheader.ivh_mbnumber = @p_mbnumber ) 
        --AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
	AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	AND (cty2.cty_code = invoiceheader.ivh_destcity)
        --AND (ivd.stp_number *= fgt.stp_number)
	AND (ivd.ivd_type NOT IN ('SUB','LI'))
  group by ivd.ord_hdrnumber,invoiceheader.ivh_invoicenumber,invoiceheader.ivh_billto,
	   invoiceheader.ivh_totalcharge,invoiceheader.ivh_originpoint,invoiceheader.ivh_destpoint,
           invoiceheader.ivh_origincity,invoiceheader.ivh_destcity,invoiceheader.ivh_shipdate,
           invoiceheader.ivh_deliverydate,invoiceheader.ivh_revtype1,invoiceheader.ivh_mbnumber,
           invoiceheader.ivh_hdrnumber,cmp1.cmp_name,cmp1.cmp_address1,cmp1.cmp_mailto_name,
           cmp1.cmp_mailto_address1,cmp1.cmp_address2,cmp1.cmp_mailto_address2,cmp1.cty_nmstct,
           cmp1.mailto_cty_nmstct,cmp1.cmp_zip,cmp1.cmp_mailto_zip,cty1.cty_nmstct,cty1.cty_state,
           cty2.cty_nmstct,cty2.cty_state,invoiceheader.ivh_billdate,invoiceheader.ivh_shipper,
           invoiceheader.ivh_consignee,cmp1.cmp_address3,invoiceheader.ord_hdrnumber,invoiceheader.ivh_hideshipperaddr,
           invoiceheader.ivh_hideconsignaddr,invoiceheader.ivh_user_id1,cmp1.cmp_country,invoiceheader.ivh_invoicestatus,
           invoiceheader.ivh_revtype2
           
     
	--AND (ref1.ref_table = 'orderheader')
	--AND (ref1.ref_tablekey =* invoiceheader.ord_hdrnumber)
	--AND (ref1.ref_type ='BL#' ) 
	--AND (ref2.ref_table = 'orderheader')
	--AND (ref2.ref_tablekey =* invoiceheader.ord_hdrnumber)
	--AND (ref2.ref_type ='SER' )  
	
	--Get the minimum order
	SELECT @v_Min_Ord = MIN(ord_hdrnumber) FROM  #tmpreprint_tbl
        --select @v_Min_Ord = ivh.ord_hdrnumber
	--  from invoiceheader ivh, #tmpreprint_tbl t
        -- where ivh.ivh_invoicenumber = t.ivh_invoicenumber and
	--       ivh.ivh_hdrnumber = (select min(#tmpreprint_tbl.ivh_hdrnumber)         
        --                         from #tmpreprint_tbl)
	
	--Set the remarks based on the first order
	Update #tmpreprint_tbl
	   set #tmpreprint_tbl.remarks = invoiceheader.ivh_remark
	       --#tmpreprint_tbl.remarks = orderheader.ord_remark,
               --ord_hdrnumber = orderheader.ord_hdrnumber
          from invoiceheader
	       --orderheader
         where invoiceheader.ord_hdrnumber = @v_Min_Ord   
	       --orderheader.ord_hdrnumber = @v_Min_Ord   
	
	 --Get The show shipper/cons based on the first order
	 select @v_show_shipper = (Case invoiceheader.ivh_showshipper   
           			   when 'UNKNOWN' then invoiceheader.ivh_shipper  
           			   else IsNull(invoiceheader.ivh_showshipper,invoiceheader.ivh_shipper)   
           			   end),
                @v_show_cons    = (Case invoiceheader.ivh_showcons   
           			   when 'UNKNOWN' then invoiceheader.ivh_consignee  
                                   else IsNull(invoiceheader.ivh_showcons,invoiceheader.ivh_consignee)   
                                    end) 
	  from invoiceheader
         where ord_hdrnumber = @v_min_ord	 

	--Get the shipper information based on the first order
	select @v_MinShipper = company.cmp_name,  
	       @v_MinShipperAddr = Case ivh_hideshipperaddr when 'Y'   
	         then ''  
	         else isnull(company.cmp_address1,'')  
	         end,  
	       @v_MinShipperAddr2 = Case ivh_hideshipperaddr when 'Y'   
	         then ''  
	         else isnull(company.cmp_address2,'')  
	         end, 
	       @v_MinShipperAddr3 = isnull(company.cmp_address3 ,''),
	       @v_MinShipperNmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,'') ,
               @v_MInShipperZip = company.cmp_zip	,
               @v_MinShipperCountry = company.cmp_country 
	  from #tmpreprint_tbl, company  
	 where company.cmp_id = @v_show_shipper and
               #tmpreprint_tbl.ord_hdrnumber =  @v_min_ord	 

	--Get the consignee information based on the first order
	select @v_mincon = company.cmp_name,  
	       @v_minconnmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
	       @v_minconaddr = Case ivh_hideconsignaddr when 'Y'   
	         then ''  
	         else isnull(company.cmp_address1,'')  
	         end,      
	       @v_minconaddr2 = Case ivh_hideconsignaddr when 'Y'   
	         then ''  
	         else isnull(company.cmp_address2, '') 
	         end,
               @v_MinConAddr3 = isnull(company.cmp_address3 ,''),
               @v_MInConZip = company.cmp_zip,
               @v_MinConsigneeCountry = company.cmp_country	 
	  from #tmpreprint_tbl, company  
	 where company.cmp_id = @v_show_cons and
               #tmpreprint_tbl.ord_hdrnumber = @v_min_ord
	
	--Get the tariff info based on the first order
	select @v_tar_tariffitem = isnull(ivh.tar_tariffitem,''),
               @v_tar_number  = ivh.tar_number
          from invoiceheader ivh
         where ivh.ord_hdrnumber = @v_min_ord   
     
     --Set the commodity description based on the first commodity of the order	
     WHILE (SELECT COUNT(*) FROM #tmpreprint_tbl WHERE ivh_hdrnumber > @v_MinInv) > 0
	BEGIN
	  
	  SELECT @v_MinInv = (SELECT MIN(ivh_hdrnumber) 
                              FROM #tmpreprint_tbl 
                             WHERE ivh_hdrnumber > @v_MinInv)

	  Select @v_MinSeq = (Select MIN(ivd_sequence)
                              from invoicedetail
                             where ivd_type = 'DRP' and
                                   ivd_description <> 'UNKNOWN' and
                                   ivd_description IS NOT NULL and
                                   ivh_hdrnumber = @v_MinInv)
	  
	  Update #tmpreprint_tbl
             set ivd_description = ivd.ivd_description
            from #tmpreprint_tbl, invoicedetail ivd
           where #tmpreprint_tbl.ivh_hdrnumber = @v_MinInv and
                 #tmpreprint_tbl.ivh_hdrnumber = ivd.ivh_hdrnumber and
                 ivd.ivd_sequence = @v_MinSeq	
	END

	--Set the show shipper id and show consignee id 
	Update #tmpreprint_tbl
	   set #tmpreprint_tbl.ivh_showshipper = @v_show_shipper,
               #tmpreprint_tbl.ivh_showcons    = @v_show_cons	

	--Set tariff info 
        Update #tmpreprint_tbl
           set #tmpreprint_tbl.tar_tariffitem = @v_tar_tariffitem,
               #tmpreprint_tbl.tar_number     = @v_tar_number  
         
        --Set the tariff startdate
	update #tmpreprint_tbl
	   set #tmpreprint_tbl.tariffkey_startdate = tar.trk_startdate
	  from #tmpreprint_tbl,tariffkey tar
	 where #tmpreprint_tbl.tar_number = tar.tar_number
	
	-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
	update #tmpreprint_tbl  
	   set shipper_nmctst = #tmpreprint_tbl.origin_nmctst
	  from #tmpreprint_tbl  
	 where #tmpreprint_tbl.ivh_shipper = 'UNKNOWN'
	 --PTS# 27140 ILB 04/14/2005

	 IF UPPER(@v_MinShipperCountry) = 'MX' or UPPER(@v_MinShipperCountry) = 'MEX' or UPPER(@v_MinShipperCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinShipperNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_show_shipper and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')
		--print 	@v_MinShipperNmctst	
		END       
	--END PTS# 27140 ILB 04/14/2005	

	--Set the shipper information 
	update #tmpreprint_tbl  
	   set shipper_name   = @v_MinShipper,
	       shipper_addr   = @v_MinShipperAddr,  
	       shipper_addr2  = @v_MinShipperAddr2,  
	       shipper_nmctst = @v_MinShippernmctst,
               shipper_addr3  = @v_MinShipperAddr3,
               shipper_zip    = @v_Minshipperzip,
               shipper_country = @v_MinShipperCountry 	

	-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
	update #tmpreprint_tbl  
	   set consignee_nmctst = #tmpreprint_tbl.dest_nmctst  
	  from #tmpreprint_tbl  
	 where #tmpreprint_tbl.ivh_consignee = 'UNKNOWN' 

	--PTS# 27140 ILB 04/14/2005
	IF UPPER(@v_MinConsigneeCountry) = 'MX' or UPPER(@v_MinConsigneeCountry) = 'MEX' or UPPER(@v_MinConsigneeCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinConNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_show_cons and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')	
		print 	@v_MinConNmctst	
		END	
	--END PTS# 27140 ILB 04/14/2005	

        ---Set the consignee information 
	update #tmpreprint_tbl  
	   set consignee_name = @v_mincon,  
	       consignee_nmctst = @v_minconnmctst, 
	       consignee_addr = @v_minconaddr,      
	       consignee_addr2 = @v_minconaddr2,
               consignee_addr3 = @v_minconaddr3,
               consignee_zip = @v_minconzip,
               consignee_country = @v_minconsigneecountry		  
	
	--Set Billto altid	
        update #tmpreprint_tbl  
           set #tmpreprint_tbl.cmp_altid = company.cmp_altid	         	         
          from #tmpreprint_tbl, company  
         where company.cmp_id = #tmpreprint_tbl.ivh_billto	

	--27140
	Update #tmpreprint_tbl
	   set revtype1_desc = l.name
	  from #tmpreprint_tbl invtmp
	       inner join labelfile l on invtmp.ivh_revtype1 = l.abbr
	 where upper(l.labeldefinition) = 'REVTYPE1'
	
	Update #tmpreprint_tbl
	   set revtype2_desc = l.name
	  from #tmpreprint_tbl invtmp
	       inner join labelfile l on invtmp.ivh_revtype2 = l.abbr
	 where upper(l.labeldefinition) = 'REVTYPE2'
	--27140

	--Select the rows
	SELECT * 
  	  FROM #tmpreprint_tbl
      ORDER BY ivh_hdrnumber ASC    

  END

-- for master bills with 'RTP' status
IF UPPER(@p_reprintflag) <> 'REPRINT' 
  BEGIN

     SELECT 
         invoiceheader.ivh_invoicenumber,  
	 invoiceheader.ivh_hdrnumber, 
         invoiceheader.ivh_billto,   
         invoiceheader.ivh_totalcharge,   
         invoiceheader.ivh_originpoint,  
         invoiceheader.ivh_destpoint,   
         invoiceheader.ivh_origincity,   
         invoiceheader.ivh_destcity,   
         invoiceheader.ivh_shipdate,   
         invoiceheader.ivh_deliverydate,   
         invoiceheader.ivh_revtype1,
	 @p_mbnumber     ivh_mbnumber,
 	 billto_name = cmp1.cmp_name,
         -- dpete for LOR pts4785 provide for maitlto override of billto
	 billto_address = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))-1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))-1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) -1),'')
	    END,
	billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty1.cty_nmstct   origin_nmctst,
	cty1.cty_state	   origin_state,
	cty2.cty_nmstct   dest_nmctst,
	cty2.cty_state	   dest_state,

	@p_billdate	billdate,
	--ISNULL(ref1.ref_number,'') billoflading,
	ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	--ISNULL(ref2.ref_number,'') serialnum,
	--PTS# 25129 ILB 10/28/2004
	invoiceheader.ivh_shipper,     
        @v_temp_name shipper_name,  
        @v_temp_addr shipper_addr,  
	@v_temp_addr2 shipper_addr2,  
	@v_temp_nmstct shipper_nmctst,  
	invoiceheader.ivh_consignee,     
	@v_temp_name consignee_name,  
	@v_temp_addr consignee_addr,  
	@v_temp_addr2 consignee_addr2,  
	@v_temp_nmstct consignee_nmctst,
        @v_show_shipper ivh_showshipper,
        @v_show_cons ivh_showcons,
        @v_tariffkey_startdate tariffkey_startdate,
        @v_tar_number tar_number,
        @v_tar_tariffitem tar_tariffitem,
        @v_commodity ivd_description ,
        @v_remarks remarks, 
        billto_address3 = 
	    CASE
	 	WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
	 	WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
	 	ELSE ''
	    END,
        @v_temp_altid cmp_altid,
        invoiceheader.ord_hdrnumber ,
        ivh_hideshipperaddr,  
        ivh_hideconsignaddr ,
        0 ivd_sequence ,
        ivh_user_id1,
	@v_temp_addr2 shipper_addr3,
        @v_temp_addr2 consignee_addr3  ,
        @v_MinShipperZip shipper_zip,
        @v_MinConZip consignee_zip,    
	--END PTS# 25129 ILB 10/28/2004 
	--PTS# 27140 ILB 03/09/2005
	isnull(cmp1.cmp_country,'')billto_country,
	@v_MinShipperCountry shipper_country,
	@v_MinConsigneeCountry consignee_country,
	sum(isnull(fgt.fgt_length,0)) fgt_length,
	sum(isnull(fgt.fgt_height,0))fgt_height,
	sum(isnull(fgt.fgt_width,0)) fgt_width,
	sum(isnull(fgt.fgt_weight,0)) fgt_weight,
        sum(isnull(fgt.fgt_count,0)) fgt_count,
	--isnull(fgt.fgt_length,0) fgt_length,
	--isnull(fgt.fgt_height,0)fgt_height,
	--isnull(fgt.fgt_width,0) fgt_width,
        --isnull(fgt.fgt_weight,0) fgt_weight,
        --isnull(fgt.fgt_count,0) fgt_count,
        ivh_invoicestatus,
	isnull(@v_Balance_Due,0) Balance_Due,
        isnull(@v_Total_Paid,0) Total_Paid,
        ivh_revtype2,
        @v_temp_revdesc revtype1_desc,
 	@v_temp_revdesc revtype2_desc
	--PTS# 27140 ILB 03/09/2005
    into #tmprtp_tbl

    FROM company cmp1, 
         city cty1, 
         city cty2,         
	 invoiceheader join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
         left outer join freightdetail as fgt on (ivd.stp_number = fgt.stp_number)
	 --invoiceheader, 
	 --invoicedetail ivd,
	 --freightdetail fgt
         --referencenumber ref1,referencenumber ref2
   WHERE ( invoiceheader.ivh_billto = @p_billto )  
     AND (invoiceheader.ivh_mbnumber is NULL OR invoiceheader.ivh_mbnumber = 0)     
     AND (invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend ) 
     AND (invoiceheader.ivh_mbstatus = 'RTP')  
     AND (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
     AND (cmp1.cmp_id = invoiceheader.ivh_billto)
     AND (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND (cty2.cty_code = invoiceheader.ivh_destcity)
     AND (ivd.ivd_type NOT IN ('SUB','LI'))
     --AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
     --AND (ivd.stp_number *= fgt.stp_number)
 group by ivd.ord_hdrnumber,invoiceheader.ivh_invoicenumber,invoiceheader.ivh_billto,
	   invoiceheader.ivh_totalcharge,invoiceheader.ivh_originpoint,invoiceheader.ivh_destpoint,
           invoiceheader.ivh_origincity,invoiceheader.ivh_destcity,invoiceheader.ivh_shipdate,
           invoiceheader.ivh_deliverydate,invoiceheader.ivh_revtype1,invoiceheader.ivh_mbnumber,
           invoiceheader.ivh_hdrnumber,cmp1.cmp_name,cmp1.cmp_address1,cmp1.cmp_mailto_name,
           cmp1.cmp_mailto_address1,cmp1.cmp_address2,cmp1.cmp_mailto_address2,cmp1.cty_nmstct,
           cmp1.mailto_cty_nmstct,cmp1.cmp_zip,cmp1.cmp_mailto_zip,cty1.cty_nmstct,cty1.cty_state,
           cty2.cty_nmstct,cty2.cty_state,invoiceheader.ivh_billdate,invoiceheader.ivh_shipper,
           invoiceheader.ivh_consignee,cmp1.cmp_address3,invoiceheader.ord_hdrnumber,invoiceheader.ivh_hideshipperaddr,
           invoiceheader.ivh_hideconsignaddr,invoiceheader.ivh_user_id1,cmp1.cmp_country,invoiceheader.ivh_invoicestatus,
           invoiceheader.ivh_revtype2
     --AND    (ref1.ref_table = 'orderheader')
     --AND    (ref1.ref_tablekey =* invoiceheader.ord_hdrnumber)
     --AND    (ref1.ref_type ='BL#'  )
     --AND    (ref2.ref_table = 'orderheader')
     --AND    (ref2.ref_tablekey =* invoiceheader.ord_hdrnumber)
     --AND    (ref2.ref_type ='SER'  )


        --Get the minimum order
	SELECT @v_Min_Ord = MIN(ord_hdrnumber) FROM  #tmprtp_tbl
        --select @v_Min_Ord = ivh.ord_hdrnumber
	--  from invoiceheader ivh, #tmprtp_tbl t
        -- where ivh.ivh_invoicenumber = t.ivh_invoicenumber and
	--       ivh.ivh_hdrnumber = (select min(#tmprtp_tbl.ivh_hdrnumber)         
        --                         from #tmprtp_tbl)
	
	--Set the remarks based on the first order
	Update #tmprtp_tbl
	   set #tmprtp_tbl.remarks = invoiceheader.ivh_remark
	       --#tmpreprint_tbl.remarks = orderheader.ord_remark,
               --ord_hdrnumber = orderheader.ord_hdrnumber
          from invoiceheader
	       --orderheader
         where invoiceheader.ord_hdrnumber = @v_Min_Ord   
	       --orderheader.ord_hdrnumber = @v_Min_Ord 

	 --Get The show shipper/cons based on the first order
	 select @v_show_shipper = (Case invoiceheader.ivh_showshipper   
           			   when 'UNKNOWN' then invoiceheader.ivh_shipper  
           			   else IsNull(invoiceheader.ivh_showshipper,invoiceheader.ivh_shipper)   
           			   end),
                @v_show_cons    = (Case invoiceheader.ivh_showcons   
           			   when 'UNKNOWN' then invoiceheader.ivh_consignee  
                                   else IsNull(invoiceheader.ivh_showcons,invoiceheader.ivh_consignee)   
                                    end) 
	  from invoiceheader
         where invoiceheader.ord_hdrnumber = @v_Min_Ord   
     

	--Get the shipper information based on the first order
	select @v_MinShipper = company.cmp_name,  
	       @v_MinShipperAddr = Case ivh_hideshipperaddr when 'Y'   
	         then ''  
	         else company.cmp_address1  
	         end,  
	       @v_MinShipperAddr2 = Case ivh_hideshipperaddr when 'Y'   
	         then ''  
	         else company.cmp_address2  
	         end,  
	       @v_MinShipperNmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,'') ,
               @v_MinShipperAddr3 = isnull(company.cmp_address3,''),
               @v_MInShipperZip = company.cmp_zip	,
               @v_MinShipperCountry = company.cmp_country  
	 
	  from #tmprtp_tbl, company  
	 where company.cmp_id = @v_show_shipper  and
               #tmprtp_tbl.ord_hdrnumber = @v_MIn_Ord


	--Get the consignee information based on the first order
	select @v_mincon = company.cmp_name,  
	       @v_minconnmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
	       @v_minconaddr = Case ivh_hideconsignaddr when 'Y'   
	         then ''  
	         else company.cmp_address1  
	         end,      
	       @v_minconaddr2 = Case ivh_hideconsignaddr when 'Y'   
	         then ''  
	         else company.cmp_address2  
	         end  ,
               @v_minconaddr3 = isnull(company.cmp_address3,''),
	       @v_MInConZip = company.cmp_zip	,
               @v_MinConsigneeCountry = company.cmp_country 
	 
	  from #tmprtp_tbl, company  
	 where company.cmp_id = @v_show_cons and
               #tmprtp_tbl.ord_hdrnumber = @v_min_ord

	--Get the tariff info based on the first order
	select @v_tar_tariffitem = isnull(ivh.tar_tariffitem,''),
               @v_tar_number  = ivh.tar_number
          from invoiceheader ivh
         where ivh.ord_hdrnumber = @v_min_ord

     --Set the commodity description based on the first commodity of the order	
     WHILE (SELECT COUNT(*) FROM #tmprtp_tbl WHERE ivh_hdrnumber > @v_MinInv) > 0
	BEGIN
	  
	  SELECT @v_MinInv = (SELECT MIN(ivh_hdrnumber) 
                              FROM #tmprtp_tbl 
                             WHERE ivh_hdrnumber > @v_MinInv)

	  Select @v_MinSeq = (Select MIN(ivd_sequence)
                              from invoicedetail
                             where ivd_type = 'DRP' and
                                   ivd_description <> 'UNKNOWN' and
                                   ivd_description IS NOT NULL and
                                   ivh_hdrnumber = @v_MinInv)
	  
	  Update #tmprtp_tbl
             set ivd_description = ivd.ivd_description
            from #tmprtp_tbl, invoicedetail ivd
           where #tmprtp_tbl.ivh_hdrnumber = @v_MinInv and
                 #tmprtp_tbl.ivh_hdrnumber = ivd.ivh_hdrnumber and
                 ivd.ivd_sequence = @v_MinSeq
	
	END

	--Set the show shipper id and show consignee id 
	Update #tmprtp_tbl
	   set #tmprtp_tbl.ivh_showshipper = @v_show_shipper,
               #tmprtp_tbl.ivh_showcons    = @v_show_cons	

	--Set tariff info 
        Update #tmprtp_tbl
           set #tmprtp_tbl.tar_tariffitem = @v_tar_tariffitem,
               #tmprtp_tbl.tar_number     = @v_tar_number  
         
        --Set the tariff startdate
	update #tmprtp_tbl
	   set #tmprtp_tbl.tariffkey_startdate = tar.trk_startdate
	  from #tmprtp_tbl,tariffkey tar
	 where #tmprtp_tbl.tar_number = tar.tar_number 	 
	  
	-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
	update #tmprtp_tbl  
	   set shipper_nmctst = #tmprtp_tbl.origin_nmctst
	  from #tmprtp_tbl  
	 where #tmprtp_tbl.ivh_shipper = 'UNKNOWN'
	
	 --PTS# 27140 ILB 04/14/2005
	 IF UPPER(@v_MinShipperCountry) = 'MX' or UPPER(@v_MinShipperCountry) = 'MEX' or UPPER(@v_MinShipperCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinShipperNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_show_shipper and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')	
		--print @v_MinshipperNmctst	
		END       
	--END PTS# 27140 ILB 04/14/2005		

	--Set the shipper information 
	update #tmprtp_tbl  
	   set shipper_name   = @v_MinShipper,
	       shipper_addr   = @v_MinShipperAddr,  
	       shipper_addr2  = @v_MinShipperAddr2,  
	       shipper_nmctst = @v_MinShippernmctst,
               shipper_addr3  = @v_MinShipperAddr3,
               shipper_zip =  @v_MInshipperZip,
               shipper_country = @v_MinShipperCountry 	 	  

	-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
	update #tmprtp_tbl  
	   set consignee_nmctst = #tmprtp_tbl.dest_nmctst  
	  from #tmprtp_tbl  
	 where #tmprtp_tbl.ivh_consignee = 'UNKNOWN' 

	--PTS# 27140 ILB 04/14/2005
	IF UPPER(@v_MinConsigneeCountry) = 'MX' or UPPER(@v_MinConsigneeCountry) = 'MEX' or UPPER(@v_MinConsigneeCountry) = 'MEXICO'
		BEGIN
		  SELECT @v_MinConNmctst = city.alk_city+','+isnull(cmp.cmp_state, '')
		    FROM company cmp, city 
		   WHERE cmp.cmp_id = @v_show_cons and
			 cmp.cmp_city = city.cty_code and 
                         cmp.cmp_country IN('MX','MEX','MEXICO')
		--print @v_MinConNmctst		
		END	
	--END PTS# 27140 ILB 04/14/2005

	 --Set the consignee information 
	update #tmprtp_tbl  
	   set consignee_name = @v_mincon,  
	       consignee_nmctst = @v_minconnmctst, 
	       consignee_addr = @v_minconaddr,      
	       consignee_addr2 = @v_minconaddr2,
               consignee_addr3 = @v_minconaddr3,
               consignee_zip =  @v_MInConZip,
               consignee_country = @v_MinConsigneeCountry 	

	--Set Billto altid	
        update #tmprtp_tbl  
           set #tmprtp_tbl.cmp_altid = company.cmp_altid	         	         
          from #tmprtp_tbl, company  
         where company.cmp_id = #tmprtp_tbl.ivh_billto

	--27140
	Update #tmprtp_tbl
	   set revtype1_desc = l.name
	  from #tmprtp_tbl invtmp
	       inner join labelfile l on invtmp.ivh_revtype1 = l.abbr
	 where upper(l.labeldefinition) = 'REVTYPE1'
	
	Update #tmprtp_tbl
	   set revtype2_desc = l.name
	  from #tmprtp_tbl invtmp
	       inner join labelfile l on invtmp.ivh_revtype2 = l.abbr
	 where upper(l.labeldefinition) = 'REVTYPE2'
	--27140
	
	--Select the rows
	SELECT * 
  	  FROM #tmprtp_tbl         
      ORDER BY ord_hdrnumber, ivd_sequence
      --ORDER BY ivh_INVOICENUMBER ASC
  END
GO
GRANT EXECUTE ON  [dbo].[d_masterbill50_sp] TO [public]
GO
