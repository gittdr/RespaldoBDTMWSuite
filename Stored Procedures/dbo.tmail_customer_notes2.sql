SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_customer_notes2] (@customer_id varchar(8), @NoWrapFlag VARCHAR(30)) AS
/* Customer Notes ***************************************************************
	3/8/2002 DAG: We changed our mind and decided not to use the no wrap flag.
--  DAG 3/29/02 Extra functionality moved back to original!  This routine is now defunct.
--				Still exists only for compatibility during the upgrade process.  May be removed
--				after v6.4, so DO NOT REUSE.
*********************************************************************************/
BEGIN
	EXEC dbo.tmail_customer_notes @customer_id
END	-- End of the proc
GO
GRANT EXECUTE ON  [dbo].[tmail_customer_notes2] TO [public]
GO
