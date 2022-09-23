SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_batchprint_invoices_sp    Script Date: 6/1/99 11:54:08 AM ******/
--Create stored proc with specified input parameters
CREATE PROC [dbo].[d_batchprint_invoices_sp](@cmpid varchar(8),
                                     @invhdrnumber int,
                                     @shipper varchar(8),
                                     @orderedby varchar(8),
                                     @updatestatus char(1),
                                     @useasbillto varchar(8),
                                     @billto varchar(8),
                                     @ismasterbill char(1),
                                     @edicode int) 
AS


--Declare variables
DECLARE @char1 int,
        @char2 varchar(8),
        @char3 char(1)

--Select required fields for the datawindow
SELECT company.cmp_id company_cmp_id, 
       company.cmp_invoiceto company_cmp_invoiceto,
       company.cmp_invprintto company_cmp_invprintto, 
       invoiceformat.ift_dwname invoiceformat_ift_dwname, 
       company.cmp_invformat company_cmp_invformat, 
       invoiceformat.ift_sequence invoiceformat_ift_sequence, 		
       @char1 inv_hdr_number,
       @char2 shipper,
       @char2 orderedby,
       @char3 updatestatus,
       @char2 useasbillto,
       @char2 billto,
       @char3 ismasterbill,
       @char1 edi_code

into #batch_print

FROM company, invoiceformat 
WHERE ( company.cmp_invformat *= invoiceformat.ift_id) and  
      ( company.cmp_id = @cmpid )
/**********************************************************************************************/

--Update dummy fields with input parameters
update #batch_print
   set inv_hdr_number = @invhdrnumber,
       shipper = @shipper,
       orderedby = @orderedby,
       updatestatus = @updatestatus,
       useasbillto = @useasbillto,
       billto = @billto,
       ismasterbill = @ismasterbill,
       edi_code = @edicode


/**********************************************************************************************/

--Select all fields from the temp table for use by the datawindow
select * from #batch_print


GO
GRANT EXECUTE ON  [dbo].[d_batchprint_invoices_sp] TO [public]
GO
