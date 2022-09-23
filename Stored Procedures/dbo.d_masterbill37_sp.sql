SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 /*    
    
   This format is used by a company that links invoices by a ref number on the orderheader of type 'JOB' - Allegre      
    
  
DPETE 17999 Create master bill
DPETE 18722 return new master bill number when not a reprint
*/    
    
CREATE PROC [dbo].[d_masterbill37_sp] (
@reprintflag varchar(10),
@mbnumber int,
@billto varchar(8),     
@revtype1 varchar(6), 
@revtype2 varchar(6),
@revtype3 varchar(6), 
@revtype4 varchar(6),
@mbstatus varchar(6),    
@shipstart datetime,
@shipend datetime,
@billdate datetime,     
@shipper varchar(8), 
@consignee varchar(8),
@delstart datetime, 
@delend datetime,
@orderby varchar(8),
@copy tinyint,
@job varchar(30))

AS    

SELECT @job 		= isnull(@job,'')   
SELECT @shipstart 	= convert(char(12),@shipstart)+'00:00:00'    
SELECT @shipend   	= convert(char(12),@shipend  )+'23:59:59'    
SELECT @delstart 	= convert(char(12),@delstart)+'00:00:00'    
SELECT @delend   	= convert(char(12),@delend  )+'23:59:59'    

    
CREATE TABLE #masterbill_temp (  
	ord_hdrnumber int,    
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
	billto_nmstct varchar(25) NULL ,      
	shippr_name varchar(100) NULL,
	Cons_name varchar(100) NULL,
	Cmd_name varchar(30) NULL,    
	ivh_mbnumber int NULL, 
	ivh_shipdate datetime NULL,       
	ivh_billdate datetime NULL,  
	BL#_ref varchar(35) NULL,
	JOB_ref varchar(35) NULL,
	PO_ref varchar(35) null,  
	ivd_quantity float  NULL,     
	ivd_unit char(6) NULL,    
	ivd_rate money NULL,    
	ivd_rateunit char(6) NULL,    
	ivd_charge money NULL,    
	ivd_description varchar(50) NULL,    
	cht_primary char(1) NULL,
	ivd_sequence int null,    
	copy tinyint NULL,
	truck varchar(8) NULL    )    
    
    
    
-- If printflag is set to REPRINT, retrieve an already printed mb by #    
    
 If UPPER(@reprintflag) = 'REPRINT'     
   BEGIN    
    INSERT INTO #masterbill_temp    
    SELECT	ih.ord_hdrnumber,    
		ivh_invoicenumber ,      
		ih.ivh_hdrnumber,  
		ord_number = Case ih.ord_hdrnumber When 0 Then ivh_invoicenumber Else ih.ord_number End,  
		ivh_terms,
		ivh_charge,
		ivh_billto, 
		billtoID = Case Rtrim(IsNull(bc.cmp_altid,'')) When '' Then ivh_billto else bc.cmp_altid End, 
		billto_name = bc.cmp_name,
		billto_address = IsNull(bc.cmp_address1,''),    
		billto_address2 = IsNull(bc.cmp_address2,''),   
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
		 shippr_name = sc.cmp_name,
		 Cons_name = cc.cmp_name,
		 Cmd_name = Case ih.ord_hdrnumber When 0 Then '' Else ord_description End,    
		ivh_mbnumber , 
		 ivh_shipdate ,        
		ivh_billdate ,  
		BL#_ref = Case ih.ord_hdrnumber When 0 Then 
		(IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
		and ref_tablekey = ih.ivh_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
		r2.ref_type  = 'BL#'))
		,''))
		Else (IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'ORDERHEADER' 
		and ref_tablekey = ih.ord_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'orderheader' and r2.ref_tablekey = ih.ord_hdrnumber and 
		r2.ref_type  = 'BL#'))
		,''))
		End,
		JOB_ref = IsNull(ivh_ref_number,''),
		PO_ref = Case ih.ord_hdrnumber When 0 Then 
		(IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
		and ref_tablekey = ih.ivh_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
		r2.ref_type  = 'PO'))
		,''))
		Else (IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'ORDERHEADER' 
		and ref_tablekey = ih.ord_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'orderheader' and r2.ref_tablekey = ih.ord_hdrnumber and 
		r2.ref_type  = 'PO'))
		,''))
		End,
		ivd_quantity ,     
		ivd_unit ,    
		ivd_rate ,    
		ivd_rateunit,    
		ivd_charge ,    
		ivd_description = Case IsNull(ivd_description,'UNKNOWN') When 'UNKNOWN' Then cht_description 
		When '' Then cht_description Else ivd_description End ,    
		cht_primary = IsNull(cht_primary,'N'),
		ivd_sequence ,    
		@copy ,
		truck = Case ivh_tractor When 'UNKNOWN' Then ivh_carrier Else ivh_tractor End 

 	FROM	invoiceheader ih     
		LEFT OUTER JOIN company sc ON ih.ivh_shipper = sc.cmp_id    
		LEFT OUTER JOIN company cc ON ih.ivh_consignee = cc.cmp_id
		LEFT OUTER JOIN orderheader ord ON ih.ord_hdrnumber = ord.ord_hdrnumber,
		company bc,
		invoicedetail ivd 
		LEFT OUTER JOIN chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode
		
   	WHERE 	( ih.ivh_mbnumber = @mbnumber )    
		AND (ih.ivh_hdrnumber = ivd.ivh_hdrnumber)    
 		AND (bc.cmp_id = ih.ivh_billto)  

  END    
    
-- for master bills with 'RTP' status    
  
If UPPER(@reprintflag) <> 'REPRINT'     
BEGIN    
	INSERT INTO #masterbill_temp    
	SELECT	ih.ord_hdrnumber,    
		ivh_invoicenumber ,      
		ih.ivh_hdrnumber,  
		ord_number = Case ih.ord_hdrnumber When 0 Then ivh_invoicenumber Else ih.ord_number End, 
		ivh_terms,
		ivh_charge,
		ivh_billto,  
		billtoID = Case Rtrim(IsNull(bc.cmp_altid,'')) When '' Then ivh_billto else bc.cmp_altid End, 
		billto_name = bc.cmp_name,
		billto_address = IsNull(bc.cmp_address1,''),    
		billto_address2 = IsNull(bc.cmp_address2,''),   
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
		 shippr_name = sc.cmp_name,
		 Cons_name = cc.cmp_name,
		 Cmd_name = Case ih.ord_hdrnumber When 0 Then '' Else ord_description End,    
		--   ivh_mbnumber , 
		@mbnumber ,
		 ivh_shipdate ,        
		ivh_billdate ,  
		BL#_ref = Case ih.ord_hdrnumber When 0 Then 
		(IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
		and ref_tablekey = ih.ivh_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
		r2.ref_type  = 'BL#'))
		,''))
		Else (IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'ORDERHEADER' 
		and ref_tablekey = ih.ord_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'orderheader' and r2.ref_tablekey = ih.ord_hdrnumber and 
		r2.ref_type  = 'BL#'))
		,''))
		End,
		JOB_ref = IsNull(ivh_ref_number,''),
		PO_ref = Case ih.ord_hdrnumber When 0 Then 
		(IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
		and ref_tablekey = ih.ivh_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
		r2.ref_type  = 'PO'))
		,''))
		Else (IsNull(
		(SELECT top 1 ref_number from referencenumber WHERE REF_TABLE = 'ORDERHEADER' 
		and ref_tablekey = ih.ord_hdrnumber
		and ref_sequence = (SELECT min(ref_sequence) From referencenumber r2
		where r2.ref_table = 'orderheader' and r2.ref_tablekey = ih.ord_hdrnumber and 
		r2.ref_type  = 'PO'))
		,''))
		End,
		ivd_quantity ,     
		ivd_unit ,    
		ivd_rate ,    
		ivd_rateunit,    
		ivd_charge ,    
		ivd_description = Case IsNull(ivd_description,'UNKNOWN') When 'UNKNOWN' Then cht_description 
		When '' Then cht_description Else ivd_description End ,      
		cht_primary = IsNull(cht_primary,'N'),
		ivd_sequence ,    
		@copy,
		truck = Case ivh_tractor When 'UNKNOWN' Then ivh_carrier Else ivh_tractor End   

 	FROM	invoiceheader ih     
		LEFT OUTER JOIN company sc ON ih.ivh_shipper = sc.cmp_id    
		LEFT OUTER JOIN company cc ON ih.ivh_consignee = cc.cmp_id
		LEFT OUTER JOIN orderheader ord ON ih.ord_hdrnumber = ord.ord_hdrnumber,
		company bc,
		invoicedetail ivd 
		LEFT OUTER JOIN chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode
		
   	WHERE 	( ih.ivh_billto = @billto )
		AND (ih.ivh_hdrnumber = ivd.ivh_hdrnumber)    
 		AND (bc.cmp_id = ih.ivh_billto)    
		AND ( ih.ivh_shipdate between @shipstart AND @shipend )     
		AND ( ih.ivh_deliverydate between @delstart AND @delend )     
		AND ( ih.ivh_mbstatus = 'RTP')    
		AND (@revtype1 in (ih.ivh_revtype1,'UNK'))       
		AND (@revtype2 in (ih.ivh_revtype2,'UNK'))     
		AND (@revtype3 in (ih.ivh_revtype3,'UNK'))    
		AND (@revtype4 in (ih.ivh_revtype4,'UNK'))     
		AND (@shipper IN(ih.ivh_shipper,'UNKNOWN'))    
		AND (@consignee IN (ih.ivh_consignee,'UNKNOWN'))       
		AND ih.ivh_ref_number = @job
END    
    

    
 
    
SELECT		ord_hdrnumber,
		ivh_invoicenumber,
		ivh_hdrnumber,
		ord_number,
		ivh_terms,
		ivh_charge,
		ivh_billto,
		billtoID,
		billto_name,
		billto_address,
		billto_address2,
		billto_nmstct,
		shippr_name,
		Cons_name,
		Cmd_name,
		ivh_mbnumber,
		ivh_shipdate,
		ivh_billdate,
		BL#_ref,
		JOB_ref,
		PO_ref,
		ivd_quantity,
		ivd_unit,
		ivd_rate,
		ivd_rateunit,
		ivd_charge,
		ivd_description,
		cht_primary,
		ivd_sequence,
		copy,
		truck
 FROM		#masterbill_temp    
WHERE		ivd_charge <> 0 
ORDER BY 	ivh_shipdate,
		ord_number,
		ivh_invoicenumber,
		ivd_sequence    
GO
GRANT EXECUTE ON  [dbo].[d_masterbill37_sp] TO [public]
GO
