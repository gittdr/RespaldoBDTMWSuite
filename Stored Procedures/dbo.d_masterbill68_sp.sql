SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE           procedure [dbo].[d_masterbill68_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8),     
                        @revtype1 varchar(6), @revtype2 varchar(6),@revtype3 varchar(6), @revtype4 varchar(6),@mbstatus varchar(6),    
                        @shipstart datetime,@shipend datetime,@billdate datetime,     
                               @shipper varchar(8), @consignee varchar(8),
    						 @delstart datetime, @delend datetime,@orderby varchar(8),@copy tinyint,@job varchar(25))
AS    
/**
 * DESCRIPTION:
 * This format is used by a company that links invoices by a ref number on the orderheader of type 'JOB' - Allegre      
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * DPETE 17999 ALTER  master bill
 * DPETE 18722 return new master bill number when not a reprint
 * 10/30/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax. Included the changes for PTS 40063 for Brad Y.
 *
 **/

declare
@invoice_date datetime,
@MinOrd int,
@MinStp int,
@MinIvd int,
@fgt_refnum varchar(30),
@found_tax money,
@found_fuel money,
@fuel money,
@tax money,
@tax_subtotal money,
@fuel_subtotal money,
@commodity varchar(60),
@tonnage money,
@tar_number int,
@tar_tariffnumber varchar(12) ,
@subtotal money,
@grand_total money,
@ignorereflist varchar(35),
@polist		varchar(35),
@firstrow_ordhdrnumber	int

select @ignorereflist = ',PO,PPO,JB,'
Select @polist = ',PO,PPO,'


Select @job = isnull(@job,'')   
 
Select @shipstart = convert(char(12),@shipstart)+'00:00:00'    
Select @shipend   = convert(char(12),@shipend  )+'23:59:59'    
Select @delstart = convert(char(12),@delstart)+'00:00:00'    
Select @delend   = convert(char(12),@delend  )+'23:59:59'    

    
CREATE TABLE #masterbill_temp (  ord_hdrnumber int,    
   ivh_invoicenumber varchar(12),      
   ivh_hdrnumber int NULL,  
   ord_number varchar(15) NULL, 
   ivh_terms varchar(6) NULL,
   ivh_charge money NULL,
   ivh_billto varchar(8) NULL,  
   billtoID varchar(8) NULL,
   billto_name varchar(100) NUll, 
   billto_address varchar(100) NULL,    
   billto_address2 varchar(100) NULL,    
   billto_nmstct varchar(50) NULL ,      
   shippr_name varchar(100) NULL,
   Cons_name varchar(100) NULL,
   Cmd_name varchar(30) NULL,    
   ivh_mbnumber int NULL, 
   ivh_shipdate datetime NULL,       
   ivh_billdate datetime NULL,  
   BL#_ref varchar(35) NULL,
   JOB_ref varchar(35) NULL,
	ord_nonpo_ref varchar(35) null,
   master_PO_ref varchar(35) null,  
	plan_po_ref varchar(35) null,
	ord_po_ref varchar(35) null, 
   ivd_quantity float  NULL,     
   ivd_unit char(6) NULL,    
   ivd_rate money NULL,    
   ivd_rateunit char(6) NULL,    
   ivd_charge money NULL,    
   ivd_description varchar(50) NULL,    
   cht_primary char(1) NULL,
   ivd_sequence int null,    
   copy tinyint NULL,
   truck varchar(8) NULL,
   invoice_date datetime null,
   delivery_date datetime null ,
   ticket_number varchar(30)null,
   ivd_number int null ,
   tax_subtotal money null,
   fuel_subtotal money null,
   ivd_type varchar(6) null ,
   cht_lh_rpt char(1) null,
   tonnage money null,
   tar_number int null,
   tar_tariffnumber varchar(12) null,
   tar_description varchar(250) null,
   subtotal money null,
   grand_total money null,
   cht_itemcode varchar(6) null,
   ord_fromorder varchar(12) null,
   ivh_revtype2 	varchar(6) null,
   ivh_ref_number varchar(30) null
)

    
    
-- If printflag is set to REPRINT, retrieve an already printed mb by #    
    
If UPPER(@reprintflag) = 'REPRINT'     
  BEGIN    
    INSERT Into #masterbill_temp    
    Select  ih.ord_hdrnumber,    
    ivh_invoicenumber ,      
    ih.ivh_hdrnumber,  
    ord_number = Case ih.ord_hdrnumber When 0 Then ivh_invoicenumber Else ih.ord_number End,  
    ivh_terms,
    ivh_charge,
    ivh_billto, 
    billtoID = Case Rtrim(IsNull(bc.cmp_altid,'')) When '' Then ivh_billto else bc.cmp_altid End, 


    /* billto_name = bc.cmp_name, */
	-- KMM MCC changes on site, 6/1/06, handle VISA jobs
	billto_name = 
	   CASE
		WHEN ivh_billto = 'VISA' THEN 
		  (CASE	WHEN oc.cmp_mailto_name is null then isnull(oc.cmp_name, '')
		  	WHEN (oc.cmp_mailto_name<= ' ') THEN ISNULL(oc.cmp_name, '')
		  	ELSE ISNULL(oc.cmp_mailto_name, '') + ' *' end)
		ELSE
		  (CASE	WHEN bc.cmp_mailto_name IS NULL THEN ISNULL(bc.cmp_name,'')
			WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_name,'')
			ELSE ISNULL(bc.cmp_mailto_name,'') + ' *' end)
	    END,

    
	/* billto_address = IsNull(bc.cmp_address1,''),     */
    
	billto_address = 
	   CASE
		WHEN ivh_billto = 'VISA' THEN 
		  (CASE	WHEN oc.cmp_mailto_name is null then isnull(oc.cmp_address1, '')
		  	WHEN (oc.cmp_mailto_name<= ' ') THEN ISNULL(oc.cmp_address1, '')
		  	ELSE ISNULL(oc.cmp_mailto_address1, '') end)
		ELSE
		  (CASE	WHEN bc.cmp_mailto_name IS NULL THEN ISNULL(bc.cmp_address1,'')
			WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_address1,'')
			ELSE ISNULL(bc.cmp_mailto_address1,'')  end)
	    END,



	/* billto_address2 = IsNull(bc.cmp_address2,''),   */

	billto_address2 = 
	   CASE
		WHEN ivh_billto = 'VISA' THEN 
		  (CASE	WHEN oc.cmp_mailto_name is null then isnull(oc.cmp_address2, '')
		  	WHEN (oc.cmp_mailto_name<= ' ') THEN ISNULL(oc.cmp_address2, '')
		  	ELSE ISNULL(oc.cmp_mailto_address2, '') end)
		ELSE
		  (CASE	WHEN bc.cmp_mailto_name IS NULL THEN ISNULL(bc.cmp_address2,'')
			WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_address2,'')
			ELSE ISNULL(bc.cmp_mailto_address2,'')  end)
	    END,



/*    
billto_nmstct = (Case Charindex(',',IsNull(bc.cty_nmstct,'')) 
     When 0 then '' 
     Else
       Substring( bc.cty_nmstct ,1, charindex( ',',bc.cty_nmstct)) + ' ' +
       Case Charindex('/',bc.cty_nmstct) 
        When 0 Then 
			Substring(bc.cty_nmstct,
			charindex( ',',bc.cty_nmstct)+ 1,
         len(bc.cty_nmstct) -   charindex( ',',bc.cty_nmstct))
        Else Substring(bc.cty_nmstct,Charindex(',',bc.cty_nmstct) + 1,
		   charindex('/',bc.cty_nmstct) - Charindex(',',bc.cty_nmstct) - 1)
        End 
     End) + '    '+IsNull(bc.cmp_zip,''), 
*/	


	billto_nmstct = 
	    CASE
		 WHEN ivh_billto = 'VISA' THEN 
			(CASE 	WHEN oc.cmp_id = 'UNKNOWN' THEN
				     'UNKNOWN'
					WHEN oc.cmp_mailto_name IS NULL THEN 
					   ISNULL(SUBSTRING(oc.cty_nmstct,1,(CHARINDEX('/',oc.cty_nmstct))- 1),'')
					WHEN (oc.cmp_mailto_name <= ' ') THEN 
					   ISNULL(SUBSTRING(oc.cty_nmstct,1,(CHARINDEX('/',oc.cty_nmstct))- 1),'')
					ELSE ISNULL(SUBSTRING(oc.mailto_cty_nmstct,1,(CHARINDEX('/',oc.mailto_cty_nmstct)) - 1),'')
				    END
					+
				    '    '+CASE
					WHEN oc.cmp_mailto_name IS NULL  THEN ISNULL(oc.cmp_zip ,'')  
					WHEN (oc.cmp_mailto_name <= ' ') THEN ISNULL(oc.cmp_zip,'')
					ELSE ISNULL(oc.cmp_mailto_zip,'')
				    END)

		ELSE
			(CASE 	WHEN bc.cmp_id = 'UNKNOWN' THEN
				     'UNKNOWN'
					WHEN bc.cmp_mailto_name IS NULL THEN 
					   ISNULL(SUBSTRING(bc.cty_nmstct,1,(CHARINDEX('/',bc.cty_nmstct))- 1),'')
					WHEN (bc.cmp_mailto_name <= ' ') THEN 
					   ISNULL(SUBSTRING(bc.cty_nmstct,1,(CHARINDEX('/',bc.cty_nmstct))- 1),'')
					ELSE ISNULL(SUBSTRING(bc.mailto_cty_nmstct,1,(CHARINDEX('/',bc.mailto_cty_nmstct)) - 1),'')
				    END
					+
				    '    '+CASE
					WHEN bc.cmp_mailto_name IS NULL  THEN ISNULL(bc.cmp_zip ,'')  
					WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_zip,'')
					ELSE ISNULL(bc.cmp_mailto_zip,'')
				    END)
 		END,    
	-- END KMM MCC changes on site, 6/1/06, handle VISA jobs


	 shippr_name = sc.cmp_name,
	 Cons_name = cc.cmp_name,
	 Cmd_name = Case ih.ord_hdrnumber When 0 Then '' Else ord_description End,    
    ivh_mbnumber , 
	 ivh_shipdate ,        
    ivh_billdate ,  
	BL#_ref = Case ih.ord_hdrnumber When 0 Then 
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      r2.ref_type  = 'BL#'))
      ,''))
     Else (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'ORDERHEADER' 
      and ref_tablekey = ih.ord_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'orderheader' and r2.ref_tablekey = ih.ord_hdrnumber and 
      r2.ref_type  = 'BL#'))
      ,''))
     End,
	JOB_ref = --
			  -- bcy (select	isnull(toepr_ref_type, '') + ' ' + isnull(toepr_ref_number , '')
				(select	isnull(labelfile.[name], '') + ' ' + isnull(toepr_ref_number , '')
				from 	ticket_order_entry_plan_ref, labelfile
				WHERE 	toepr_ref_type = labelfile.abbr 
						and labeldefinition = 'referencenumbers'
						and CHARINDEX( ',' + toepr_ref_type + ',', @ignorereflist) < 1 AND
						toep_id = (select 	toep_id
									from 	ticket_order_entry_plan_orders
									where	ord_hdrnumber =  ord.ord_hdrnumber)
						and toepr_ref_sequence = (select 	min(toepr_ref_sequence)
													from	ticket_order_entry_plan_ref tr2
													where	CHARINDEX( ',' + tr2.toepr_ref_type + ',', @ignorereflist) < 1 AND
															tr2.toep_id = (select	toep_id
																			from 	ticket_order_entry_plan_orders
																			where 	ord_hdrnumber = ord.ord_hdrnumber))),
	ord_nonpo_ref = 0,
	
	master_PO_ref = Case ih.ord_hdrnumber When 0 Then 
		-- MISC INVOICE
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
 	where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      charindex (',' + r2.ref_type + ',', @polist) > 0))
      ,''))
		-- END MISC INVOICE
     Else 
		(Select isnull(ref_number , '')
				from 	referencenumber 
				WHERE 	REF_TABLE = 'ORDERHEADER' AND
						charindex(',' + ref_type +',',@polist) > 0 ANd
						ref_sequence =  (select 	min(ref_sequence)
											from	referencenumber r2
											where	r2.ref_table = 'ORDERHEADER' AND
													charindex(',' + r2.ref_type +',',@polist) > 0 AND
													r2.ref_tablekey = (select	ord_hdrnumber
																		from 	orderheader
																		where 	ord_number = (SELECT ord_fromorder from orderheader where ord_hdrnumber = ord.ord_hdrnumber))) AND
						ref_tablekey = (select	ord_hdrnumber
										from 	orderheader
										where 	ord_number =(SELECT ord_fromorder from orderheader where ord_hdrnumber = ord.ord_hdrnumber))) end,
	plan_po_ref = 	Case ih.ord_hdrnumber When 0 Then 
		-- MISC INVOICE
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      charindex(',' + ref_type +',',@polist) > 0))
      ,''))
		-- END MISC INVOICE
     Else 
		(select	isnull(toepr_ref_number , '')
		from 	ticket_order_entry_plan_ref
		WHERE 	charindex(',' + toepr_ref_type +',',@polist) > 0 AND
				toep_id = (select 	toep_id
							from 	ticket_order_entry_plan_orders
							where	ord_hdrnumber =  ord.ord_hdrnumber)
				and toepr_ref_sequence = (select 	min(toepr_ref_sequence)
											from	ticket_order_entry_plan_ref tr2
											where	charindex(',' + tr2.toepr_ref_type + ',',@polist) > 0 AND
													tr2.toep_id = (select	toep_id
																	from 	ticket_order_entry_plan_orders
																	where 	ord_hdrnumber = ord.ord_hdrnumber))) end,
	ord_po_ref = 	Case ih.ord_hdrnumber When 0 Then 
		-- MISC INVOICE
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      charindex(',' + r2.ref_type +',',@polist) > 0))
      ,''))
		-- END MISC INVOICE
     Else 
		(select	isnull(ref_number , '')
		from 	referencenumber 
		WHERE 	REF_TABLE = 'ORDERHEADER' AND
				charindex (',' + ref_type + ',', @polist) > 0 AND
				ref_tablekey = ord.ord_hdrnumber AND
				ref_sequence =  (select 	min(ref_sequence)
									from	referencenumber r2
									where	r2.ref_table = 'ORDERHEADER' AND
											charindex(',' + r2.ref_type +',',@polist) > 0 AND
											r2.ref_tablekey = ord.ord_hdrnumber)) end,
   ivd_quantity ,     
   ivd_unit ,    
   ivd_rate ,    
   ivd_rateunit,    
   ivd_charge ,    
   ivd_description = upper(Case IsNull(ivd_description,'UNKNOWN') When 'UNKNOWN' Then cht_description 
       When '' Then cht_description Else ivd_description End) ,    
   cht_primary = IsNull(cht_primary,'N'),
	ivd_sequence ,    
   @copy ,
   truck = Case ivh_tractor When 'UNKNOWN' Then ivh_carrier Else ivh_tractor End,
   '',                  --invoice_date
   ord_completiondate,  --delivery_date
   '',                  --ticket number
   ivd.ivd_number,      --ivd_number
   0 ,                  --tax_subtotal
   0,                   --fuel_subtotal   
   ivd.ivd_type,        --PUP/DRP
   ivd.cht_lh_rpt,      --flag used to determine if Fuel Surcharge items should be displayed
   0,                   --total tonnage for primary charges only
   0,                   --tariff number id
   '',                  --tariff number
   '',                  --tariff description
   0,		       --primary charge subtotal
   0,                   --grand total
   ivd.cht_itemcode,
	ord.ord_fromorder,
	ih.ivh_revtype2,
	ih.ivh_ref_number

   From  company sc  RIGHT OUTER JOIN  invoiceheader ih  ON  sc.cmp_id  = ih.ivh_shipper   
			LEFT OUTER JOIN  company cc  ON  cc.cmp_id  = ih.ivh_consignee   
			LEFT OUTER JOIN  orderheader ord  ON  ord.ord_hdrnumber  = ih.ord_hdrnumber   
			LEFT OUTER JOIN  company oc  ON  ih.ivh_order_by  = oc.cmp_id ,
	 chargetype cht  RIGHT OUTER JOIN  invoicedetail ivd  ON  cht.cht_itemcode  = ivd.cht_itemcode ,
	 company bc 
   Where ( ih.ivh_mbnumber = @mbnumber )    
  AND (ih.ivh_hdrnumber = ivd.ivh_hdrnumber)       
  AND (bc.cmp_id = ih.ivh_billto)     
    
  END    
    
-- for master bills with 'RTP' status    
  
If UPPER(@reprintflag) <> 'REPRINT'     
  BEGIN    

     INSERT Into #masterbill_temp    
    Select  ih.ord_hdrnumber,    
    ivh_invoicenumber ,      
    ih.ivh_hdrnumber,  
    ord_number = Case ih.ord_hdrnumber When 0 Then ivh_invoicenumber Else ih.ord_number End, 
    ivh_terms,
    ivh_charge,
    ivh_billto,  
    billtoID = Case Rtrim(IsNull(bc.cmp_altid,'')) When '' Then ivh_billto else bc.cmp_altid End, 

 /* billto_name = bc.cmp_name, */
    /* billto_name = bc.cmp_name, */
	-- KMM MCC changes on site, 6/1/06, handle VISA jobs
	billto_name = 
	   CASE
		WHEN ivh_billto = 'VISA' THEN 
		  (CASE	WHEN oc.cmp_mailto_name is null then isnull(oc.cmp_name, '')
		  	WHEN (oc.cmp_mailto_name<= ' ') THEN ISNULL(oc.cmp_name, '')
		  	ELSE ISNULL(oc.cmp_mailto_name, '') + ' *' end)
		ELSE
		  (CASE	WHEN bc.cmp_mailto_name IS NULL THEN ISNULL(bc.cmp_name,'')
			WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_name,'')
			ELSE ISNULL(bc.cmp_mailto_name,'') + ' *' end)
	    END,

    
	/* billto_address = IsNull(bc.cmp_address1,''),     */
    
	billto_address = 
	   CASE
		WHEN ivh_billto = 'VISA' THEN 
		  (CASE	WHEN oc.cmp_mailto_name is null then isnull(oc.cmp_address1, '')
		  	WHEN (oc.cmp_mailto_name<= ' ') THEN ISNULL(oc.cmp_address1, '')
		  	ELSE ISNULL(oc.cmp_mailto_address1, '') end)
		ELSE
		  (CASE	WHEN bc.cmp_mailto_name IS NULL THEN ISNULL(bc.cmp_address1,'')
			WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_address1,'')
			ELSE ISNULL(bc.cmp_mailto_address1,'')  end)
	    END,



	/* billto_address2 = IsNull(bc.cmp_address2,''),   */

	billto_address2 = 
	   CASE
		WHEN ivh_billto = 'VISA' THEN 
		  (CASE	WHEN oc.cmp_mailto_name is null then isnull(oc.cmp_address2, '')
		  	WHEN (oc.cmp_mailto_name<= ' ') THEN ISNULL(oc.cmp_address2, '')
		  	ELSE ISNULL(oc.cmp_mailto_address2, '')  end)
		ELSE
		  (CASE	WHEN bc.cmp_mailto_name IS NULL THEN ISNULL(bc.cmp_address2,'')
			WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_address2,'')
			ELSE ISNULL(bc.cmp_mailto_address2,'')  end)
	    END,



/*    
billto_nmstct = (Case Charindex(',',IsNull(bc.cty_nmstct,'')) 
     When 0 then '' 
     Else
       Substring( bc.cty_nmstct ,1, charindex( ',',bc.cty_nmstct)) + ' ' +
       Case Charindex('/',bc.cty_nmstct) 
        When 0 Then 
			Substring(bc.cty_nmstct,
			charindex( ',',bc.cty_nmstct)+ 1,
         len(bc.cty_nmstct) -   charindex( ',',bc.cty_nmstct))
        Else Substring(bc.cty_nmstct,Charindex(',',bc.cty_nmstct) + 1,
		   charindex('/',bc.cty_nmstct) - Charindex(',',bc.cty_nmstct) - 1)
        End 
     End) + '    '+IsNull(bc.cmp_zip,''), 
*/	


	billto_nmstct = 
	    CASE
		 WHEN ivh_billto = 'VISA' THEN 
			(CASE 	WHEN oc.cmp_id = 'UNKNOWN' THEN
				     'UNKNOWN'
					WHEN oc.cmp_mailto_name IS NULL THEN 
					   ISNULL(SUBSTRING(oc.cty_nmstct,1,(CHARINDEX('/',oc.cty_nmstct))- 1),'')
					WHEN (oc.cmp_mailto_name <= ' ') THEN 
					   ISNULL(SUBSTRING(oc.cty_nmstct,1,(CHARINDEX('/',oc.cty_nmstct))- 1),'')
					ELSE ISNULL(SUBSTRING(oc.mailto_cty_nmstct,1,(CHARINDEX('/',oc.mailto_cty_nmstct)) - 1),'')
				    END
					+
				    '    '+CASE
					WHEN oc.cmp_mailto_name IS NULL  THEN ISNULL(oc.cmp_zip ,'')  
					WHEN (oc.cmp_mailto_name <= ' ') THEN ISNULL(oc.cmp_zip,'')
					ELSE ISNULL(oc.cmp_mailto_zip,'')
				    END)

		ELSE
			(CASE 	WHEN bc.cmp_id = 'UNKNOWN' THEN
				     'UNKNOWN'
					WHEN bc.cmp_mailto_name IS NULL THEN 
					   ISNULL(SUBSTRING(bc.cty_nmstct,1,(CHARINDEX('/',bc.cty_nmstct))- 1),'')
					WHEN (bc.cmp_mailto_name <= ' ') THEN 
					   ISNULL(SUBSTRING(bc.cty_nmstct,1,(CHARINDEX('/',bc.cty_nmstct))- 1),'')
					ELSE ISNULL(SUBSTRING(bc.mailto_cty_nmstct,1,(CHARINDEX('/',bc.mailto_cty_nmstct)) - 1),'')
				    END
					+
				    '    '+CASE
					WHEN bc.cmp_mailto_name IS NULL  THEN ISNULL(bc.cmp_zip ,'')  
					WHEN (bc.cmp_mailto_name <= ' ') THEN ISNULL(bc.cmp_zip,'')
					ELSE ISNULL(bc.cmp_mailto_zip,'')
				    END)
		END,    

	-- END KMM MCC changes on site, 6/1/06, handle VISA jobs


	 shippr_name = sc.cmp_name,
	 Cons_name = cc.cmp_name,
	 Cmd_name = Case ih.ord_hdrnumber When 0 Then '' Else ord_description End,    
 --   ivh_mbnumber , 
    @mbnumber ,
	 ivh_shipdate ,        
    ivh_billdate ,  
	BL#_ref = Case ih.ord_hdrnumber When 0 Then 
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      r2.ref_type  = 'BL#'))
      ,''))
     Else (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'ORDERHEADER' 
      and ref_tablekey = ih.ord_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'orderheader' and r2.ref_tablekey = ih.ord_hdrnumber and 
      r2.ref_type  = 'BL#'))
      ,''))
     End,
	JOB_ref = 	-- bcy (select	isnull(toepr_ref_type, '') + ' ' + isnull(toepr_ref_number , '')
				--from 	ticket_order_entry_plan_ref
				(select	isnull(labelfile.[name], '') + ' ' + isnull(toepr_ref_number , '')
				from 	ticket_order_entry_plan_ref, labelfile 
				WHERE 	toepr_ref_type = labelfile.abbr 
						and labeldefinition = 'referencenumbers'
						and charindex (',' + toepr_ref_type + ',', @ignorereflist) < 1 AND
						toep_id = (select 	toep_id
									from 	ticket_order_entry_plan_orders
									where	ord_hdrnumber =  ord.ord_hdrnumber)
						and toepr_ref_sequence = (select 	min(toepr_ref_sequence)
													from	ticket_order_entry_plan_ref tr2
													where	charindex (',' + tr2.toepr_ref_type + ',', @ignorereflist) < 1  AND
															tr2.toep_id = (select	toep_id
																			from 	ticket_order_entry_plan_orders
																			where 	ord_hdrnumber = ord.ord_hdrnumber))),
	ord_nonpo_ref = 0,
--IsNull(ivh_ref_number,''),
	master_PO_ref = Case ih.ord_hdrnumber When 0 Then 
		-- MISC INVOICE
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
 	where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      charindex (',' + r2.ref_type + ',', @polist) > 0))
      ,''))
		-- END MISC INVOICE
     Else 
		(Select isnull(ref_number , '')
				from 	referencenumber 
				WHERE 	REF_TABLE = 'ORDERHEADER' AND
						charindex(',' + ref_type +',',@polist) > 0 ANd
						ref_sequence =  (select 	min(ref_sequence)
											from	referencenumber r2
											where	r2.ref_table = 'ORDERHEADER' AND
													charindex(',' + r2.ref_type +',',@polist) > 0 AND
													r2.ref_tablekey = (select	ord_hdrnumber
																		from 	orderheader
																		where 	ord_number = (SELECT ord_fromorder from orderheader where ord_hdrnumber = ord.ord_hdrnumber))) AND
						ref_tablekey = (select	ord_hdrnumber
										from 	orderheader
										where 	ord_number =(SELECT ord_fromorder from orderheader where ord_hdrnumber = ord.ord_hdrnumber))) end,
	plan_po_ref = 	Case ih.ord_hdrnumber When 0 Then 
		-- MISC INVOICE
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      charindex(',' + ref_type +',',@polist) > 0))
      ,''))
		-- END MISC INVOICE
     Else 
		(select	isnull(toepr_ref_number , '')
		from 	ticket_order_entry_plan_ref
		WHERE 	charindex(',' + toepr_ref_type +',',@polist) > 0 AND
				toep_id = (select 	toep_id
							from 	ticket_order_entry_plan_orders
							where	ord_hdrnumber =  ord.ord_hdrnumber)
				and toepr_ref_sequence = (select 	min(toepr_ref_sequence)
											from	ticket_order_entry_plan_ref tr2
											where	charindex(',' + tr2.toepr_ref_type + ',',@polist) > 0 AND
													tr2.toep_id = (select	toep_id
																	from 	ticket_order_entry_plan_orders
																	where 	ord_hdrnumber = ord.ord_hdrnumber))) end,
	ord_po_ref = 	Case ih.ord_hdrnumber When 0 Then 
		-- MISC INVOICE
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      charindex(',' + r2.ref_type +',',@polist) > 0))
      ,''))
		-- END MISC INVOICE
     Else 
		(select	isnull(ref_number , '')
		from 	referencenumber 
		WHERE 	REF_TABLE = 'ORDERHEADER' AND
				charindex (',' + ref_type + ',', @polist) > 0 AND
				ref_tablekey = ord.ord_hdrnumber AND
				ref_sequence =  (select 	min(ref_sequence)
									from	referencenumber r2
									where	r2.ref_table = 'ORDERHEADER' AND
											charindex(',' + r2.ref_type +',',@polist) > 0 AND
											r2.ref_tablekey = ord.ord_hdrnumber)) end,
   ivd_quantity ,     
   ivd_unit ,    
   ivd_rate ,    
   ivd_rateunit,    
   ivd_charge ,    
   ivd_description = upper(Case IsNull(ivd_description,'UNKNOWN') When 'UNKNOWN' Then cht_description 
      When '' Then cht_description Else ivd_description End) ,      
   cht_primary = IsNull(cht_primary,'N'),
	ivd_sequence ,    
   @copy,
   truck = Case ivh_tractor When 'UNKNOWN' Then ivh_carrier Else ivh_tractor End,
   '',                 --invoice_date 
   ord_completiondate, --delivery_date
   '',                 --ticket number
   ivd.ivd_number,     --ivd_number  
   0,                  --tax_subtotal
   0,                  --fuel_subtotal   
   ivd.ivd_type,       --PUP/DRP   
   ivd.cht_lh_rpt,     --flag used to determine if Fuel Surcharge items should be displayed
   0,                  --total tonnage for primary charges only
   0,                  --tariff number id
   '',                 --tariff number
   '',                 --tariff description
   0,		       --primary charge subtotal
   0,                   --grand total 
   ivd.cht_itemcode,
	ord.ord_fromorder,
	ih.ivh_revtype2,
	ih.ivh_ref_number

   From  company sc  RIGHT OUTER JOIN  invoiceheader ih  ON  sc.cmp_id  = ih.ivh_shipper   
			LEFT OUTER JOIN  company cc  ON  cc.cmp_id  = ih.ivh_consignee   
			LEFT OUTER JOIN  orderheader ord  ON  ord.ord_hdrnumber  = ih.ord_hdrnumber   
			LEFT OUTER JOIN  company oc  ON  ih.ivh_order_by  = oc.cmp_id ,
	 chargetype cht  RIGHT OUTER JOIN  invoicedetail ivd  ON  cht.cht_itemcode  = ivd.cht_itemcode ,
	 company bc 
   Where  ( ih.ivh_billto = @billto )      
    And (ih.ivh_hdrnumber = ivd.ivh_hdrnumber)    
    And    ( ih.ivh_shipdate between @shipstart AND @shipend )     
    And    ( ih.ivh_deliverydate between @delstart AND @delend )     
    And     (ih.ivh_mbstatus = 'RTP')    
    And (@revtype1 in (ih.ivh_revtype1,'UNK'))       
    And (@revtype2 in (ih.ivh_revtype2,'UNK'))     
    And (@revtype3 in (ih.ivh_revtype3,'UNK'))    
    And (@revtype4 in (ih.ivh_revtype4,'UNK'))     
    And (bc.cmp_id = ih.ivh_billto)    
    And (@shipper IN(ih.ivh_shipper,'UNKNOWN'))    
    And (@consignee IN (ih.ivh_consignee,'UNKNOWN'))       
    And IsNull(ih.ivh_ref_number,'') = @job

  END    


DELETE FROM #masterbill_temp
WHERE	cht_itemcode = 'DEL'
	and isNull(ivd_charge,0) = 0
 
--PTS# 23438 ILB 04/11/2005   
select @invoice_date = min(ivh_billdate)
--  from #masterbill_temp
  from invoiceheader
 where ord_hdrnumber = (select min(ord_hdrnumber)
                         from #masterbill_temp)


If UPPER(@reprintflag) <> 'REPRINT'    
begin
Update #masterbill_temp
   set 	invoice_date = @billdate,--was @invoice_date 
		ivh_billdate = @billdate 
end
If UPPER(@reprintflag) = 'REPRINT'    
begin
Update #masterbill_temp
   set 	invoice_date = @invoice_date,--was @invoice_date 
		ivh_billdate = @invoice_date 
end

--ILB 07/14/2005
select @tar_number = tar_number,
       @tar_tariffnumber = tar_tarriffnumber
  from invoiceheader
 where ord_hdrnumber = (select min(ord_hdrnumber)
              		 from #masterbill_temp)
      
Update #masterbill_temp
   set tar_number = @tar_number,
       tar_tariffnumber = @tar_tariffnumber

Update 	#masterbill_temp
	set 	tar_description = (select 	min(isnull(ord_remark, ''))
								from 	orderheader o
								where	o.ord_number = #masterbill_temp.ord_fromorder)

 Update #masterbill_temp
    set tar_description = tariffheader.tar_description
   from #masterbill_temp, tariffheader
  where #masterbill_temp.tar_number = tariffheader.tar_number AND
		ISNull(#masterbill_temp.tar_description, '') = ''


--bcy case for Misc Invoices
 Update #masterbill_temp
    set tar_description = upper(isnull(invoiceheader.ivh_remark,''))
   from #masterbill_temp, invoiceheader
  where #masterbill_temp.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
		ISNull(#masterbill_temp.tar_description, '') = ''

--ILB 07/14/2005

 --Set the ticket_number column equal to the first stop which is a Drop for


 --for each order	
     Set @MinOrd = 0
     Set @MinStp = 0     
     WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ord_hdrnumber > @MinOrd) > 0
	BEGIN
	  
	  SELECT @MinOrd = (SELECT MIN(ord_hdrnumber) 
                              FROM #masterbill_temp 
                             WHERE ord_hdrnumber > @MinOrd)	
	  
	            
	  SELECT @MinStp = min(stp_number) 
            FROM invoicedetail 
           WHERE Upper(ivd_type) = 'DRP' and 
                 ord_hdrnumber = @MinOrd	
  
	  select @fgt_refnum = isnull(fgt_refnum,'') 
            from freightdetail
   where stp_number = @MinStp 	  
	
	  select @commodity = upper(ivd_description)
            from invoicedetail
           where stp_number = @MinStp

	--BCY
	--           UPDATE #masterbill_temp
	--              set ticket_number = @fgt_refnum,
	--                  ivd_description = @commodity
	--            where ord_hdrnumber = @minord and
	--                  Upper(ivd_type) = 'SUB'
	
	-- I HAD TO DO THIS OUTSIDE OF THE LOOP
	--END BCY
	  
	END

--BCY
-- I had to do this b/c the Agg Entry window doesn't denorm to ref table
UPDATE 	#masterbill_temp
SET 	ticket_number = (select max(fgt_refnum)
  from 	freightdetail, stops
 where 	stops.ord_hdrnumber = #masterbill_temp.ord_hdrnumber
		and stops.stp_number = freightdetail.stp_number
		and isNull(fgt_refnum,'') <> ''
		and isNull(#masterbill_temp.ord_hdrnumber ,0) > 0 ) /* PTS 40063 Added for Perf reasons */
	    	--and stp_type = 'PUP'
--END BCY

UPDATE	#masterbill_temp
  SET	ticket_number = '*' +isNULL(idt.ivd_refnum,'')
 FROM	invoicedetail idt
 WHERE	#masterbill_temp.ivd_number = idt.ivd_number
	and #masterbill_temp.ord_hdrnumber = 0 
	and isNULL(idt.ivd_refnum,'') <> ''


     --Set the fuel surcharge subtotal and the tax subtotal
     --print 'tax & fuel info'
     Set @MinOrd = 0
     Set @MinIvd = 0
     Set @fuel_subtotal = 0
     Set @tax_subtotal = 0
     Set @found_tax = 0
     Set @found_fuel = 0
     Set @fuel = 0
     Set @Tax = 0
     Set @tonnage = 0
     Set @subtotal = 0
     set @grand_total = 0

     WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ord_hdrnumber > @MinOrd) > 0
	
	BEGIN
	  
	  SELECT @MinOrd = (SELECT MIN(ord_hdrnumber) 
                              FROM #masterbill_temp 
                             WHERE ord_hdrnumber > @MinOrd)
                 --print 'Order Header Number'	
		 --print cast(@minord as varchar(20))                     
	   
	  WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ivd_number > @MinIvd and ord_hdrnumber = @MinOrd) > 0	  
	  	 
		BEGIN	
		 
		  --Get the first stop for the current order.
		  select @MinIvd = min(ivd_number)
		    from #masterbill_temp 
	           where ord_hdrnumber = @MinOrd and 
	                 ivd_number is not null and
                         ivd_number > @MinIvd 
		  --print 'ivd number'
                  --print cast(@minivd as varchar(20))	
		  
-- 		  SELECT @found_tax = CHARINDEX('TAX', upper(ivd_description))
-- 		    FROM #masterbill_temp
-- 	           WHERE ivd_number = @MinIvd
-- 
-- 		  IF @found_tax > 0
--                      begin
--                         select @tax = round(isNull(ivd_charge ,0),2)
--                           from #masterbill_temp
--                          where ivd_number = @MinIvd
-- 			 
-- 			 Select @tax_subtotal = @tax_subtotal + @tax
-- 		     end
		
		  --SELECT @found_fuel = CHARINDEX('FUEL', upper(ivd_description))
		  -- FROM #masterbill_temp
	          --WHERE ivd_number = @MinIvd	

		  /*
		  SELECT @found_fuel = CHARINDEX('FUEL', upper(cht_itemcode))
		    FROM #masterbill_temp
	           WHERE ivd_number = @MinIvd	
		
		   IF @found_fuel > 0
                     begin
                        select @fuel = ivd_charge 
                          from #masterbill_temp
                         where ivd_number = @MinIvd
			 
			 Select @fuel_subtotal = @fuel_subtotal + @fuel
		     end  
		  */		 
		 
		END
		
		--Update #masterbill_temp
		--   set fuel_subtotal = @fuel_subtotal,
                --       tax_subtotal = @tax_subtotal
		-- where ord_hdrnumber = @MinOrd

		Set @fuel = 0
		Set @tax = 0
                --Set @MinIvd = 0
                --Set @tonnage = 0
                --Set @subtotal = 0
		
	END

--bcy adding ROUND to next 3 SELECTS
	select @grand_total = sum(round(isNull(ivd_charge,0),2))
	  from #masterbill_temp

	Select @tonnage = sum(round(isNull(ivd_quantity,0),2))
	  from #masterbill_temp
     where cht_primary = 'Y' and ivd_charge > 0               

	select  @fuel_subtotal = sum(round(isNull(ivd_charge,0),2))
	  from #masterbill_temp
	 where	CHARINDEX('FUEL', upper(cht_itemcode)) > 0

	select  @tax_subtotal = sum(round(isNull(ivd_charge,0),2))
	  from #masterbill_temp
	 where	CHARINDEX('TAX', upper(cht_itemcode)) > 0
--         Update #masterbill_temp
-- 	   set 	fuel_subtotal = round(isNull(@fuel_subtotal,0),2),
--             tax_subtotal = round(isNull(@tax_subtotal,0),2),
--             tonnage      = round(isNull(@tonnage,0),2),
--             subtotal  = round(isNull(@grand_total,0),2) - round(isNull(@fuel_subtotal,0),2)+round(isNull(@tax_subtotal,0),2),
--             grand_total = round(isNull(@grand_total,0),2)
--         --PTS# 23438 ILB 04/11/2005
-- 

        Update #masterbill_temp
	   set fuel_subtotal = round(isNull(@fuel_subtotal,0),2),
               tax_subtotal = round(isNull(@tax_subtotal,0),2),
               tonnage      = round(isNull(@tonnage,0),2),
--               subtotal  = isNull(@grand_total,0) - (isNull(@fuel_subtotal,0)+isNull(@tax_subtotal,0)),
               grand_total = round(isNull(@grand_total,0),2)
        --PTS# 23438 ILB 04/11/2005

	 Update #masterbill_temp
	   set  subtotal  = isNull(grand_total,0) - (isNull(fuel_subtotal,0)+isNull(tax_subtotal,0))


 DELETE FROM #masterbill_temp    
 WHERE 	cht_primary = 'N' 
 	and isNull(cht_lh_rpt,'N') = 'Y'
   
UPDATE #masterbill_temp    
   SET  billtoid = ltrim(rtrim(isNull(cmp_misc1,'')))
  from  invoiceheader, company
 where	invoiceheader.ivh_hdrnumber = #masterbill_temp.ivh_hdrnumber
	and invoiceheader.ivh_revtype1 = 'DMT'
	and company.cmp_id = #masterbill_temp.ivh_billto

update #masterbill_temp
set 	ord_hdrnumber = isNull(ivh_hdrnumber,0)
where 	ord_hdrnumber = 0



/*
#
#	BYoung - had to change this to get the cmd name from the 
#	DEL ivd, b/c the orderheader is not always correct once the ivh exists
#
OLD WAY:
update	#masterbill_temp
  set	cmd_name = case cht_primary when 'Y' then cmd_name else ivd_description end
--bcy 1/2
update	#masterbill_temp
  set	cmd_name = case cht_primary when 'Y' then 
				(	
					select 	min(isNull(invoicedetail.ivd_description,''))
					  from	invoicedetail join #masterbill_temp on invoicedetail.ord_hdrnumber = #masterbill_temp.ord_hdrnumber and invoicedetail.cht_itemcode = 'DEL'
				) else ivd_description end

*/
update	#masterbill_temp
  set	cmd_name = upper(case cht_primary when 'Y' then isNull(invoicedetail.ivd_description,'') else #masterbill_temp.ivd_description end)
 from	invoicedetail
 where	invoicedetail.ord_hdrnumber = #masterbill_temp.ord_hdrnumber 
		and invoicedetail.cht_itemcode = 'DEL'



-- ORDER BY USED HERE!
select top 1 @firstrow_ordhdrnumber = ord_hdrnumber
from #masterbill_temp
   where ivd_charge <> 0 
Order by convert(datetime,convert(varchar,ivh_shipdate,10)),ticket_number,ivh_invoicenumber,ivd_sequence
-- END ORDER BY USED HERE  



update #masterbill_temp
	set 	ord_nonpo_ref = (Select IsNull(labelfile.[name], '') + ' ' + IsNull(ref_number, '') 
							from referencenumber, labelfile 
								WHERE ref_type = labelfile.abbr 
								and labeldefinition = 'referencenumbers'
								  and REF_TABLE = 'ORDERHEADER' 
							      and ref_tablekey = @firstrow_ordhdrnumber
				      				and ref_sequence = (select min(ref_sequence) 
														From referencenumber r2
				      									where r2.ref_table = 'orderheader' and r2.ref_tablekey = @firstrow_ordhdrnumber and 
				      									CHARINDEX( ',' + r2.ref_type + ',', @ignorereflist) < 1))

-- Stubbed out, for roll off box jobs.  Set description if no master order, or tar description filled out
--update #masterbill_temp
--	set 	tar_description = (Select IsNull(ord_remark, '')  
--								from orderheader
--								WHERE ord_hdrnumber = @firstrow_ordhdrnumber)
--where isnull(tar_description) = ''


-- IF YOU CHANGE THE ORDER BY, YOU MUST CHANGE THE ORDER BY AT COMMENT = -- ORDER BY USED HERE!
  Select *     
    From  #masterbill_temp    
   where ivd_charge <> 0 
Order by convert(datetime,convert(varchar,ivh_shipdate,10)),ticket_number,ivh_invoicenumber,ivd_sequence

    
Drop Table  #masterbill_temp    




GO
GRANT EXECUTE ON  [dbo].[d_masterbill68_sp] TO [public]
GO
