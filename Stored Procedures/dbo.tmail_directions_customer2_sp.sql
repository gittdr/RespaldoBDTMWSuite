SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_directions_customer2_sp] @customer_id VARCHAR(8), @NoWrapFlag VARCHAR(30) 
AS
/* Directions to Customer ********************************************************
**				Don George 3/8/2002 - We changed our mind in using the NoWrap flag.  Actually use the NoWrapCustomerNotes field instead.
**                              - The reason is for multiple paging.  It is a much simpler and safer solution.
--  DAG 3/29/02 Extra functionality moved back to original!  This routine is now defunct.
--				Still exists only for compatibility during the upgrade process.  May be removed
--				after v6.4, so DO NOT REUSE.
*********************************************************************************/

	exec dbo.tmail_directions_customer_sp @customer_id 
GO
GRANT EXECUTE ON  [dbo].[tmail_directions_customer2_sp] TO [public]
GO
