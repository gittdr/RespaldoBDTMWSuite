SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[billing_validation_sp]
	@ivh_InvoiceNumber varchar(12), 
	@ErrorMessage varchar(255) OUTPUT
AS
/****************************************************************************************/
/* Description:  This stored procedure validates customer's    				*/
/*		 billing requirements for EDI purposes.	     				*/
/**************************************************************************************/

select @ErrorMessage = ''

GO
GRANT EXECUTE ON  [dbo].[billing_validation_sp] TO [public]
GO
