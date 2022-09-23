SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[image_invoicedata002_sp] (@pegcontrol int)    
As    

/**
 *
 * 
 *
 * NAME:
 *
 * dbo.image_invoicedata002_sp
 *
 *
 *
 * TYPE:
 *
 * StoredProcedure
 *
 *
 *
 * DESCRIPTION:
 *
 * This procedure returns a result set that contains invoice information for imaging
 *
 * 
 *
 *
 *
 * RETURNS:
 *
 * NONE
 *
 *
 *
 * RESULT SETS: 
 *
 * See Selection list
 *
 *
 *
 * PARAMETERS:
 *
 * 001 - @pegcontrol, INT, input, null;
 *
 *       This argument is the pegasus control number that handles filtering result set.
 *
 * REFERENCES: NONE
 *
 * REVISION HISTORY:
 *
 * 
 *
 *  03/09/2006.01 – Created PTS 14479 DPETE  
 *  8/13/02 DPETE added ivh_mbnumber to return set  
 *
 *  DPETE 15873 return mb number from pegasus_invoiclist table
 *  DPETE 25784 (temporary til PTS 25769) order rusults by invoice number so supporting docs
 *  printint hat sequence unit PTS 25769 handles all possible master bill sequences.
 *  DPETE PTS25769 return records in same sequence as they appear on the document if GI 
 *  DPETE PTS 25769 order by the new idenetiy col so that records are returned
 *  in the sequence in which they appear on the document if gi ImageSupportDocSeq = MB
 *  03/09/2006.02 – PTS32055 - PBIDI - Added change to Doc10 field to handle flagging EDI as printable.
 * 
 **/
 
Declare @Billto varchar(8),@doc1 varchar(6),@doc2 varchar(6),@doc3 varchar(6),@doc4 varchar(6),  
 @doc5 varchar(6),@doc6 varchar(6),@doc7 varchar(6),@doc8 varchar(6), @doc9 varchar(6), @doc10 varchar(7)  
Declare  @docsequence varchar(50)

/* determine the sequence in which records are to be returned */

Select @docsequence = UPPER(gi_string1) From generalinfo Where gi_name = 'ImageSupportDocSeq'
Select @docsequence = IsNull(@docsequence,'INV') 
  
  
  
Select @billto = MIN(ivh_billto)  
From pegasus_invoicelist c, invoiceheader i  
where c.peg_controlnumber = @pegcontrol   
and i.ivh_hdrnumber = c.ivh_hdrnumber  
  
Select @doc1 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 1  
Select @doc1 = IsNull(@doc1,'')  
Select @doc2 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 2  
Select @doc2 = IsNull(@doc2,'')  
Select @doc3 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 3  
Select @doc3 = IsNull(@doc3,'')  
Select @doc4 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 4  
Select @doc4 = IsNull(@doc4,'')  
Select @doc5 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 5  
Select @doc5 = IsNull(@doc5,'')  
Select @doc6 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 6  
Select @doc6 = IsNull(@doc6,'')  
Select @doc7 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 7  
Select @doc7 = IsNull(@doc7,'')  
Select @doc8 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 8  
Select @doc8 = IsNull(@doc8,'')  
Select @doc9 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 9  
Select @doc9 = IsNull(@doc9,'')  
Select @doc10 = bdt_doctype From BillDocTypes Where cmp_id = @billto and bdt_sequence = 10  
Select @doc10 = IsNull(@doc10,'')  
  

--Select invoicenumber=ivh_invoicenumber,mbnumber=c.mb_number,ordernumber=ord_number,billto=ivh_billto,doc1 = @doc1,doc2 =@doc2,doc3 =@doc3,doc4 = @doc4,doc5 =@doc5,doc6=@doc6,doc7=@doc7,doc8=@doc8,doc9=@doc9,doc10=@doc10  
--From pegasus_invoicelist c, invoiceheader i  
--where c.Peg_controlnumber = @pegcontrol   
--and i.ivh_hdrnumber = c.ivh_hdrnumber  
--Order by   Case @DocSequence When 'MB' Then peg_identity else 1 End,ivh_invoicenumber 

Select  peg_controlnumber,
	invoicenumber=ivh_invoicenumber,
	mbnumber=c.mb_number,
	ordernumber=ord_number,
	billto=ivh_billto,
	doc1 = @doc1,
	doc2 =@doc2,
	doc3 =@doc3,
	doc4 = @doc4,
	doc5 =@doc5,
	doc6=@doc6,
	doc7=@doc7,
	doc8=@doc8,
	doc9=@doc9,
	doc10 = (SELECT Doc10 = 
      			CASE cmp_edi210
         		WHEN 1 THEN 'EDIONLY'
			WHEN 3 THEN (SELECT CASE i.ivh_definition
						WHEN 'RBIL' THEN ''
						ELSE 'EDIONLY'
					   	END
				     )   
         		ELSE ''
      			END
		FROM company
		WHERE cmp_id = ivh_billto)

From pegasus_invoicelist c, invoiceheader i
where c.Peg_controlnumber = @pegcontrol   
and i.ivh_hdrnumber = c.ivh_hdrnumber  
Order by   Case @DocSequence When 'MB' Then peg_identity else 1 End,ivh_invoicenumber 
  


GO
GRANT EXECUTE ON  [dbo].[image_invoicedata002_sp] TO [public]
GO
