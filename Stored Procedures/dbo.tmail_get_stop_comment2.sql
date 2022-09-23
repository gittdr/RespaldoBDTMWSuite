SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--  DAG 12/26/01 Created stored proc: tmail_get_stop_comment2
--  MZ 11/30/00 Created stored proc (original)
--  DAG 3/29/02 Extra functionality moved back to original!  This routine is now defunct.
--				Still exists only for compatibility during the upgrade process.  May be removed
--				after v6.4, so DO NOT REUSE.
CREATE PROCEDURE [dbo].[tmail_get_stop_comment2] (@stp_number int, @NoWrapFlag VARCHAR(30))
AS
	EXEC dbo.tmail_get_stop_comment @stp_number
GO
GRANT EXECUTE ON  [dbo].[tmail_get_stop_comment2] TO [public]
GO
