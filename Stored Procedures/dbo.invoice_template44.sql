SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[invoice_template44] (@invoice_nbr   int,@copy  int)  
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
	DPETE 17999 Create invoice for alegre
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 *
 **/
 
CREATE TABLE #invtemp (  ord_hdrnumber int,    
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
	truck varchar(8) NULL    
 )    
    
INSERT Into #invtemp   
    Select  ih.ord_hdrnumber,    
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
	JOB_ref = IsNull(ivh_ref_number,''),
	PO_ref = Case ih.ord_hdrnumber When 0 Then 
      (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'invoiceheader' 
      and ref_tablekey = ih.ivh_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
      where r2.ref_table = 'invoiceheader' and r2.ref_tablekey = ih.ivh_hdrnumber and 
      r2.ref_type  = 'PO'))
      ,''))
     Else (IsNull(
      (Select ref_number from referencenumber WHERE REF_TABLE = 'ORDERHEADER' 
      and ref_tablekey = ih.ord_hdrnumber
      and ref_sequence = (select min(ref_sequence) From referencenumber r2
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
   From  company sc  RIGHT OUTER JOIN  invoiceheader ih  ON  sc.cmp_id  = ih.ivh_shipper   
			LEFT OUTER JOIN  company cc  ON  cc.cmp_id  = ih.ivh_consignee   
			LEFT OUTER JOIN  orderheader ord  ON  ord.ord_hdrnumber  = ih.ord_hdrnumber ,
		chargetype cht  RIGHT OUTER JOIN  invoicedetail ivd  ON  cht.cht_itemcode  = ivd.cht_itemcode ,
		company bc 
   Where  ( ih.ivh_hdrnumber  = @invoice_nbr  )      
    And (ih.ivh_hdrnumber = ivd.ivh_hdrnumber)    
    And (bc.cmp_id = ih.ivh_billto)    
--    And (sc.cmp_id =* ih.ivh_shipper)    
--    And (cc.cmp_id =* ih.ivh_consignee)       
--    And (ord.ord_hdrnumber =* ih.ord_hdrnumber)    
--    And cht.cht_itemcode =* ivd.cht_itemcode
   
 If  Exists (Select cmp_mailto_name From company c, #invtemp t  
        Where c.cmp_id = t.ivh_billto  
   And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
   And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
   And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )    
   Update #invtemp  
   Set billto_name = company.cmp_mailto_name,  
   billto_address =  company.cmp_mailto_address1 ,  
   billto_address2 = company.cmp_mailto_address2,     
   billto_nmstct = (Case Charindex(',',IsNull(company.mailto_cty_nmstct,'')) 
     When 0 then '' 
     Else
       Substring( company.mailto_cty_nmstct ,1, charindex( ',',company.mailto_cty_nmstct)) + ' ' +
       Case Charindex('/',company.mailto_cty_nmstct) 
        When 0 Then 
			Substring(company.mailto_cty_nmstct,
			charindex( ',',company.mailto_cty_nmstct)+ 1,
         len(company.mailto_cty_nmstct) -   charindex( ',',company.mailto_cty_nmstct))
        Else Substring(company.mailto_cty_nmstct,Charindex(',',company.mailto_cty_nmstct) + 1,
		   charindex('/',company.mailto_cty_nmstct) - Charindex(',',company.mailto_cty_nmstct) - 1)
        End 
     End) + '    '+IsNull(company.cmp_mailto_zip,'')
  from #invtemp, company  
  where company.cmp_id = #invtemp.ivh_billto  

    
 
    
  Select *     
 From  #invtemp    
 Where ivd_charge <> 0 
Order by ivd_sequence    
  
    
 Drop Table  #invtemp    


GO
GRANT EXECUTE ON  [dbo].[invoice_template44] TO [public]
GO
