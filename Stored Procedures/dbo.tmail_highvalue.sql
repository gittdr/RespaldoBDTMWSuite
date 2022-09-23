SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_highvalue] 
		@ord					AS VARCHAR(20)
							 
AS


-- =============================================================================
-- Stored Proc: tmail_highvalue
-- Author     :	Created from email authored by Lori Brickley
-- Create date: 2014.03.04
-- Description:
--      
--      Outputs:
--      ------------------------------------------------------------------------
--
--      Input parameters:
--      ------------------------------------------------------------------------
--
-- =============================================================================
-- Modification Log:
-- PTS 74198 - VMS - 2014.03.04 - Adding this stored proc to my database
-- =============================================================================

BEGIN

	SET NOCOUNT ON;

	declare @HV varchar(6)

	select @HV = case when ord_revtype4 in ('CANHV','CRITHV','FRHV','METMHV','RFTMHH','RFTMHV','SOHH','SOHV','TMHH','TMHV') then'true' else 'false' end
	from orderheader (NOLOCK)
	where ord_hdrnumber = @ord

	if @HV = 'true'
	begin
		select @hv = case when lgh_type2 in ('OK') then 'false' else 'true' end
		from legheader (nolock) 
		where ord_hdrnumber = @ord
	end

	select @HV

END

GO
GRANT EXECUTE ON  [dbo].[tmail_highvalue] TO [public]
GO
