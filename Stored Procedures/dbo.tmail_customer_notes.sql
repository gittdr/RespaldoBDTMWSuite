SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_customer_notes] @customer_id varchar(8) AS
/* Customer Notes ***************************************************************
** Used for retrieving notes for a given customer
** Called from the TotalMail Transaction Server
**
**  Created:                  	Matt Zerefos 07/05/00 
** Modified:		
*********************************************************************************/
BEGIN

	EXEC dbo.tmail_get_notes_sp 'company', @customer_id

END	-- End of the proc
GO
GRANT EXECUTE ON  [dbo].[tmail_customer_notes] TO [public]
GO
