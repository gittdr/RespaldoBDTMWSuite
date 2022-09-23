SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[tmail_update_mppfields2]( 
	@pdrvid varchar(13),
	@pmsgdatetime varchar(30), 
	@pestavldate varchar(30), 
	@pestavltime varchar(30), 
	@pavlcmpid varchar(25), 	-- PTS 61189 enhance cmp_id to 25 length
	@phrs10 varchar(30),		/* hrs available field, conventionally daily hrs. */
	@phrs70 varchar(30),		/* hrs available field, conventionally weekly hrs. */
	@pptadate varchar(30),
	@pptatime varchar(30),
	@phomedate varchar(30),
	@phometime varchar(30)

	)
as

exec dbo.tmail_update_mppfields3 @pdrvid, @pmsgdatetime, @pestavldate, @pestavltime, @pavlcmpid, @phrs10, @phrs70, @pptadate, @pptatime,@phomedate,@phometime,NULL


GO
GRANT EXECUTE ON  [dbo].[tmail_update_mppfields2] TO [public]
GO
