SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[PpwkDocsCount] 
@ordhdrnumber int
,@invoiceby varchar(3)
,@billto  varchar(8)
,@chargetypescsv varchar(255)
,@forapp char(1)
,@docsrequired int OUTPUT
,@docsreceived int OUTPUT

AS

/**
 * 
 * NAME:
 * dbo.PpwkDocsCount_sp
 *
 * TYPE:
 * Stored proc
 *
 * DESCRIPTION:
 * Returns a count of required paperwork docs not yet received in output variable
 * and fills out a count of docs required and docs received
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * na
 *
 * PARAMETERS:
 *	001 - @ord_hdrnumber int
 *	002 - @invoiceby varchar(3)  is invoice crreated by ORD(er) or MOV(ment)
 *  003 - @billto varchar(8)    bill to company
 *  004 - @chargetypescsv varchar(255)
 *
 * REVISION HISTORY:
 * 01/07/09 DPETE PTS43837 invoice by move
 *

 **/



--PTS 62216 JJF/MC 20120323 change @ppwk to table var
Declare @ppwk  table(
  labelfile_bdt_doctype  varchar(6) null
  ,cht_itemcode varchar(6) null
  ,billdoctypes_ivh_invoicenumber  varchar(12) null
  ,billdoctypes_bdt_invrequired  char(1) null
  ,pw_received char(1) null
  ,paperwork_abbr varchar(6) null
  ,ord_hdrnumber int null
  ,lgh_number int null
  ,ord_number varchar(12) null
)

declare @PPWKCheckLevel varchar(15)
Select @PPWKchecklevel =  gi_string1 from generalinfo where gi_name = 'PaperWorkCheckLevel'
/* avoid overhead of paperwork by setting GI PaperWorkCheckLevel to NONE  */
if @PPWKchecklevel  = 'NONE'   
  BEGIN
    Select @docsrequired = 0
    Select @docsreceived = 0
    RETURN
  END
  

insert into @ppwk(
  labelfile_bdt_doctype  
  ,cht_itemcode 
  ,billdoctypes_ivh_invoicenumber  
  ,billdoctypes_bdt_invrequired 
  ,pw_received
  ,paperwork_abbr
  ,ord_hdrnumber
  ,lgh_number
  ,ord_number 
)
exec GetReqPpwkforinvoice_sp  @ordhdrnumber ,@invoiceby ,@billto
,@chargetypescsv, @forapp


select @docsrequired = count(*)  from @ppwk

select @docsreceived = count(*)
from @ppwk
where pw_received = 'Y'

--BEGIN PTS 52051 SGB Show all paperwork as received to satisfy P
If (Select gi_string1 From generalinfo Where gi_name = 'PaperworkMarkedYes') = 'ONE' and @docsreceived > 0
	BEGIN
	Select @docsreceived = @docsrequired
	End 
-- END PTS 52051 SGB	



GO
GRANT EXECUTE ON  [dbo].[PpwkDocsCount] TO [public]
GO
