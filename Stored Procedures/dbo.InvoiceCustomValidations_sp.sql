SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE  PROC [dbo].[InvoiceCustomValidations_sp]	@ivh_hdrnumber int, 
													@ivh_invoiceNumber char(12), 	
													@ls_invoice_type  char(12), 
													@ll_custom_rtn_code int output,
													@ls_message_level char(10) output,
													@ls_custom_msg_title char(50) output,
													@ls_msg char(100) output AS
/**
 * NAME:
 * dbo.InvoiceCustomValidations_sp
  * TYPE:
 * StoredProcedure
  * DESCRIPTION:
 * Proc for CUSTOMER SPECIFIC Invoice validations.  TMW validates run first, then these custom validations run.
 * RETURNS:  4 values per invoice:
 *  	1) Print Invoice (1)  OR Do not print Invoice (0).
 *      2) Message severity level:  WARNING, QUESTION, FAILURE, SUCCESS
 *      3) Message custom title
 * 		4) Text of message
 * PARAMETERS: 
  * 001 - @ivh_hdrnumber int		--  Input:  table invoice header number
 * 002 - @ivh_invoiceNumber char(12)    --  Input:  friendly invoice number - example 809A
 * 003 - @ls_invoice_type  char(12)     --  Input:  invoice or master
 * 004 - @ll_custom_rtn_code int        --  output:  Return code values  0 (do not print), OR 1 (print)
 * 005 - @ls_message_level char(10)     --  output:  WARNING, QUESTION, FAILURE, SUCCESS  ( we may not want a returned message for Success )
 * 006 - @ls_custom_msg_title char(25)  --  output:  Custom title appears on the message.  Example:  Custom Validation:
 * 007 - @ls_msg char(100)              --  output:  text of the message to be returned. 
 * REVISION HISTORY:
 * Created PTS 37779 JDSwindell 02/28/2008
*/

-- default values 
set @ls_custom_msg_title = space(50)
set @ls_custom_msg_title = @ivh_invoiceNumber + ' Custom Validation:' 

set @ll_custom_rtn_code = 1 
set @ls_message_level = ''
set @ls_msg = '' 
-- end of default values 

--  FOUR Validation Examples follow 
--  THESE SHOULD ALWAYS BE COMMNETED OUT UNLESS BEING TESTED BY THE CLIENT 
-- Validation Example 1:
-- If the invoice header number is EVEN - Print the Invoice, 
-- ** in the case of success - we may not want to return a message or message level - just the Return code of 1.
--IF @ivh_hdrnumber % 2 = '0' 
--BEGIN
--		set @ll_custom_rtn_code = 1
--		--set @ls_message_level = 'SUCCESS'
--		--set @ls_msg = 'EVEN NUMBER!'  +  '  ' + cast(@ivh_hdrnumber as char(20)) + @ivh_invoiceNumber + '  ' +  @ls_invoice_type
--		set @ls_msg = 'Sample Successful Text  :-)' 
--END  
---- Validation Example 2:
---- If the invoice header number is ODD - Print the Invoice, present warning message.
--IF @ivh_hdrnumber % 2 <> '0' 
--BEGIN
--		set @ll_custom_rtn_code = 1
--		set @ls_message_level = 'WARNING'
--		set @ls_msg = 'ODD NUMBER! Sample Warning Text.'  
--END  
---- Validation Example 3:
---- If the invoice header number > 2000 - it Fails.  Do NOT print, return failure message.
--IF @ivh_hdrnumber > 2000
--BEGIN
--		set @ll_custom_rtn_code = 0
--		set @ls_message_level = 'FAILURE'
--		set @ls_msg = 'Sample Failure Text.  :-('  
--END  
---- Validation Example 4:
---- If the invoice header number <= 1907 -  Inspires a question.  Do NOT Print the Invoice,  return question message.
--IF @ivh_hdrnumber = 1907
--BEGIN
--		set @ll_custom_rtn_code = 0
--		set @ls_message_level = 'QUESTION'
--		set @ls_msg = 'Sample Question Text??? -- Invoice Print Bypassed' 
--END  
--  END OF FOUR Validation Examples
------  CLIENT Validations GO HERE ----
------  END OF CLIENT Validations  ----

--  Return output to application
select @ll_custom_rtn_code, @ls_message_level, @ls_custom_msg_title, @ls_msg
--  END OF Return output to application
GO
GRANT EXECUTE ON  [dbo].[InvoiceCustomValidations_sp] TO [public]
GO
