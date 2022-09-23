SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create FUNCTION [dbo].[fnc_TMWRN_GetTollCharge] 
	(
		@Mode varchar(5)='Move',	--Move, Order, Leg, Stop
		@KeyNumber int		--mov_number,ord_hdrnumber,lgh_number,stp_number
	)
RETURNS Money
AS

/*
This function returns the toll charges associated with
a trip based on utilizing the toll costs fields.  The
source field for the toll costs is in the mileagetable.
For each trip the toll costs are represented in the 
orderheader and stops tables.

Calculation for various @Mode values is:
Order = toll value from the ord_toll_cost field
Leg = sum of stp_ord_toll_cost values for stops on this leg
Stop = toll value from stp_ord_toll_cost
Move = sum of stp_ord_toll_cost values for stops on this move
*/

BEGIN
	declare @TollCost money

	If @Mode = 'Order'
		begin
			Select @TollCost = ord_toll_cost
			From orderheader
			Where ord_hdrnumber = @KeyNumber
		end
	Else
	If @Mode = 'Leg'
		begin
			Select @TollCost = sum(stp_ord_toll_cost)
			From stops
			Where lgh_number = @KeyNumber
		end
	Else
	If @Mode = 'Stop'
		begin
			Select @TollCost = stp_ord_toll_cost
			From stops
			Where stp_number = @KeyNumber
		end
	Else -- if any other value, default to Move
		begin
			Select @TollCost = sum(stp_ord_toll_cost)
			From stops
			Where mov_number = @KeyNumber
		end

	
	return @TollCost 
	
END
GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_GetTollCharge] TO [public]
GO
