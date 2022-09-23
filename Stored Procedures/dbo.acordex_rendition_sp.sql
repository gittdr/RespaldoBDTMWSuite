SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
Create procedure [dbo].[acordex_rendition_sp] @p_imageID varchar(20)
AS
/**  
 *   
 * NAME:  
 * dbo.acordex_rendition_sp     For Acordex imaging interface. used to create web service
 *                              to get invoice or mb information for image 
 *  
 * TYPE:  
 * [StoredProcedure]  
 *  
 * DESCRIPTION:  
 * For Acordex imaging interface. used to create web service
 * to get invoice or mb information for image 
 *  
 * RETURNS:  
 * -1 if @imageID is not numeric
 * 1  if success 
 *  
 * RESULT SETS:   
 * ord_number varchar(12)
 * master bill number converted to varchar(10)
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 1) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 2) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 3) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 4) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 5) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 6) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 7) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 8) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 9) defined as required for supporting docs for order bill to company 
 * doc1 varchar(6) labelfile abbr for billdoctypes entry (seq 10) defined as required for supporting docs for order bill to company 
 * InvoiceNumber varchar(13)
 * AmountDue money
 * Dest_type Varchar(20)
 * Dest varchar(50)
 * billto_ID company Id varchar(8)
 * billto_name varchar(100)
 * billto_citystate varchar(30)
 * billto_misc1 varchar(254)
 * billto_misc2 varchar(254)
 * billto_misc3 varchar(254)
 * billto_misc4 varchar(254)
 *  
 * PARAMETERS:  
 * 001 - @p_imageID varchar(20) the image file name
 *  
 * REFERENCES:   
  
 *   
 * REVISION HISTORY:  
 * 08/02/2006.01 ? PTS??? - D Petersen ? Created for Acordex imaging interface for Custome Companies
 * 06/04/2007.01 - PTS36869 - EMK - Added check for attach field in billdoctype and fixed typos in sequences (bdt7 was being used for doc8-10)
 *  
 **/  
If isnumeric(@p_imageID) = 0 Return -1
   
select ord_number 
,master_bill = case isnull(mb_number,0) when 0 then ' ' else convert(varchar(10),mb_number) end
,doc1 =isnull(bdt1.bdt_doctype,'')
,doc2 =isnull(bdt2.bdt_doctype,'')
,doc3 =isnull(bdt3.bdt_doctype,'')
,doc4 = isnull(bdt4.bdt_doctype,'')
,doc5 =isnull(bdt5.bdt_doctype,'')
,doc6 =isnull(bdt6.bdt_doctype,'')
,doc7 =isnull(bdt7.bdt_doctype,'')
-- 6/04/07 EMK Fixed typos changed bdt7 to bdt8,9,10
,doc8 =isnull(bdt8.bdt_doctype,'')
,doc9 =isnull(bdt9.bdt_doctype,'')
,doc10 =isnull(bdt10.bdt_doctype,'')
,InvoiceNumber = ivh_invoicenumber
,AmountDue = ivh_totalcharge
, Dest_type = 
  Case isnull(ivh_definition,'LH')
    WHen 'LH' then
      Case cmp_edi210
       when 1 then 'ArchiveOnly'  -- EDI only
       when 3 then 'ArchiveOnly'  -- EDI original , print rebill
       else  Case isnull(bmail.type,'%') 
               when '%' then 'Print'
               else case bmail.type
                     when 'F' then 'Fax'
                     else 'Email'
                     end
               end
       end
    WHen 'MISC' then
      Case cmp_edi210
       when 1 then 'ArchiveOnly'  -- EDI only
       when 3 then 'ArchiveOnly'  -- EDI original , print rebill
       else  Case isnull(bmail.type,'%') 
               when '%' then 'Print'
               else case bmail.type
                     when 'F' then 'Fax'
                     else 'Email'
                     end
               end
       end
    WHen 'SUPL' then  -- supplemental treat like regualr invoice
      Case cmp_edi210
       when 1 then 'ArchiveOnly'  -- EDI only
       when 3 then 'ArchiveOnly'  -- EDI original , print rebill
       else  Case isnull(bmail.type,'%') 
               when '%' then 'Print'
               else case bmail.type
                     when 'F' then 'Fax'
                     else 'Email'
                     end
               end
       end
     WHen 'RBIL' then  -- re bill
      Case cmp_edi210
        when 1 then 'ArchiveOnly'
        else  Case isnull(rbmail.type,'%') 
                when '%' then case isnull(bmail.type,'$') 
                               when '$' then 'Print' 
                               else case bmail.type 
                                    when 'F' then 'Fax' 
                                    else 'Email' 
                                    end
                               end
                else case rbmail.type
                     when 'F' then 'Fax'
                     else 'Email'
                     end
                end
        end
     WHen 'CRD' then  -- treat like rebill
       Case cmp_edi210
        when 1 then 'ArchiveOnly'
        else  Case isnull(rbmail.type,'%') 
                when '%' then case isnull(bmail.type,'$') 
                               when '$' then 'Print' 
                               else case bmail.type 
                                    when 'F' then 'Fax' 
                                    else 'Email' 
                                    end
                               end
                else case rbmail.type
                     when 'F' then 'Fax'
                     else 'Email'
                     end
                end
         end
   
end
     
  
, Dest =
  Case isnull(ivh_definition,'LH')
    WHen 'LH' then
      Case cmp_edi210
       when 1 then ''  -- EDI only
       when 3 then ''  -- EDI original , print rebill
       else  Case isnull(bmail.type,'%') 
               when '%' then ''
               else bmail.email_address
               end
       end
    WHen 'MISC' then
      Case cmp_edi210
       when 1 then ''  -- EDI only
       when 3 then ''  -- EDI original , print rebill
       else  Case isnull(bmail.type,'%') 
               when '%' then ''
               else bmail.email_address
               end
       end
    WHen 'SUPL' then  -- supplemental treat like regualr invoice
      Case cmp_edi210
       when 1 then ''  -- EDI only
       when 3 then ''  -- EDI original , print rebill
       else  Case isnull(bmail.type,'%') 
               when '%' then ''
               else bmail.email_address
               end
       end
     WHen 'RBIL' then  -- re bill
      Case cmp_edi210
        when 1 then ''
        else  Case isnull(rbmail.type,'%') 
                when '%' then case isnull(bmail.type,'$') 
                               when '$' then '' 
                               else  bmail.email_address 
                               end
                else rbmail.email_address 
                end
        end
     WHen 'CRD' then  -- treat like rebill
       Case cmp_edi210
        when 1 then ''
        else  Case isnull(rbmail.type,'%') 
                when '%' then case isnull(bmail.type,'$') 
                               when '$' then '' 
                               else  bmail.email_address 
                               end
                else rbmail.email_address 
                end
        end
   
end
, billto_ID = ivh_billto
, billto_name = cmp_name
, billto_citystate = Case charindex('/',cty_nmstct) when 0 then cty_nmstct else left(cty_nmstct, charindex('/',cty_nmstct) - 1) end
, billto_misc1 = isnull(cmp_misc1,'')
, billto_misc2 = isnull(cmp_misc2,'')
, billto_misc3 = isnull(cmp_misc3,'')
, billto_misc4 = isnull(cmp_misc4,'')
, billto_ediflag = convert(varchar(2), isnull(cmp_edi210,0))
, emailfaxforbill = isnull(bmail.email_address,'')
, emailfaxforrbill = isnull(rbmail.email_address,'')
from pegasus_invoicelist
join invoiceheader on invoiceheader.ivh_hdrnumber = pegasus_invoicelist.ivh_hdrnumber
--PTS 36869 EMK - Added attach condition Also Fixed typos, changed bdt7 to bdt8,9,10.
left outer join billdoctypes bdt1 on ivh_billto = bdt1.cmp_id and bdt1.bdt_sequence = 1 and IsNull(bdt1.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt2 on ivh_billto = bdt2.cmp_id and bdt2.bdt_sequence = 2 and IsNull(bdt2.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt3 on ivh_billto = bdt3.cmp_id and bdt3.bdt_sequence = 3 and IsNull(bdt3.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt4 on ivh_billto = bdt4.cmp_id and bdt4.bdt_sequence = 4 and IsNull(bdt4.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt5 on ivh_billto = bdt5.cmp_id and bdt5.bdt_sequence = 5 and IsNull(bdt5.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt6 on ivh_billto = bdt6.cmp_id and bdt6.bdt_sequence = 6 and IsNull(bdt6.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt7 on ivh_billto = bdt7.cmp_id and bdt7.bdt_sequence = 7 and IsNull(bdt7.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt8 on ivh_billto = bdt8.cmp_id and bdt8.bdt_sequence = 8 and IsNull(bdt8.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt9 on ivh_billto = bdt9.cmp_id and bdt9.bdt_sequence = 9 and IsNull(bdt9.bdt_inv_attach,'Y') = 'Y'
left outer join billdoctypes bdt10 on ivh_billto = bdt10.cmp_id and bdt10.bdt_sequence = 10 and IsNull(bdt10.bdt_inv_attach,'Y') = 'Y'
--PTS 36869 EMK - Added attach condition
join company on ivh_billto = company.cmp_id
left outer join companyemail bmail on ivh_billto = bmail.cmp_id and bmail.contact_name = 'SendBill'
left outer join companyemail rbmail on ivh_billto = rbmail.cmp_id and rbmail.contact_name = 'SendRebill'
where peg_controlnumber = @p_imageID
order by ivh_invoicenumber

return 1

GO
GRANT EXECUTE ON  [dbo].[acordex_rendition_sp] TO [public]
GO
