SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[tmail_update_mppfields]( 
	@pdrvid varchar(13),
	@pmsgdatetime varchar(30), 
	@pestavldate varchar(30), 
	@pestavltime varchar(30), 
	@pavlcmpid varchar(8), 	
	@phrs10 varchar(30),		/* hrs available field, conventionally daily hrs. */
	@phrs70 varchar(30)		/* hrs available field, conventionally weekly hrs. */
	)
as

SET NOCOUNT ON

DECLARE @pptadate varchar(30)
DECLARE @pptatime varchar(30)

set @pptadate = ''
set @pptatime = ''

exec dbo.tmail_update_mppfields2 @pdrvid, @pmsgdatetime, @pestavldate, @pestavltime, @pavlcmpid, @phrs10, @phrs70, @pptadate, @pptatime,'',''

GO
GRANT EXECUTE ON  [dbo].[tmail_update_mppfields] TO [public]
GO
