SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[Dedicated_Custom_Count_sp] (@key int, @mode varchar (20),@ReturnValue varchar(255)OUTPUT) 
as
            

IF @Mode = 'TRC'
	BEGIN
		SELECT @ReturnValue = convert(varchar(255),COUNT(DISTINCT(ISNULL(ivh_tractor,'UNKNOWN')))) from invoiceheader 
		where dbh_id = @key
		and ivh_tractor <> 'UNKNOWN'
	END

IF @Mode = 'TRCORD'
	BEGIN
		
		SELECT @ReturnValue = convert(varchar(255),COUNT(DISTINCT(ISNULL(lgh_tractor,'UNKNOWN')))) from legheader l
		where l.ord_hdrnumber in (Select i.ord_hdrnumber 	from invoiceheader i
																			where i.dbh_id = @key
																			and i.ord_hdrnumber <> 0)
		and l.lgh_tractor <> 'UNKNOWN'
	END
	
	IF @Mode = 'TRCMOV'
	BEGIN
		
		SELECT @ReturnValue = convert(varchar(255),COUNT(DISTINCT(ISNULL(lgh_tractor,'UNKNOWN')))) from legheader l
		where l.mov_number in (Select mov_number 
																		from stops 
																		where ord_hdrnumber in (Select i.ord_hdrnumber 	
																																			from invoiceheader i
																																			where i.dbh_id = @key
																																			and i.ord_hdrnumber <> 0))
		and l.lgh_tractor <> 'UNKNOWN'
	END
    SELECT @RETURNVALUE

GO
GRANT EXECUTE ON  [dbo].[Dedicated_Custom_Count_sp] TO [public]
GO
