SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_retrieve_stops_from_archive]
	@OrderHeaderNumber int,
	@EventList varchar(256) output
AS

	DECLARE	@sourcedate datetime

	SELECT	
		@sourcedate = max(dx_sourcedate)
	FROM
		dx_archive WITH (NOLOCK)
	WHERE
		dx_orderhdrnumber = @OrderHeaderNumber 

	declare @dx_ident bigint
	declare @event varchar(3)
	set @dx_ident = 0
	set @EventList = ''
	while 1=1
	begin
		SELECT @dx_ident = min(dx_ident)
		FROM	dx_archive (nolock)
		 WHERE dx_orderhdrnumber = @OrderHeaderNumber 
			and dx_field001 = '03'
			AND dx_ident > @dx_ident
		If @dx_ident is null BREAK
		if @EventList <> ''
			set @EventList = @EventList + ','
		select @event = dx_field003 from dx_archive (nolock) where dx_ident = @dx_ident
		set @EventList = @EventList + @event 
	end

GO
GRANT EXECUTE ON  [dbo].[dx_retrieve_stops_from_archive] TO [public]
GO
