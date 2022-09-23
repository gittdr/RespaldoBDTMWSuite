SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TMW_AllocateLegRevenue] (@lgh_number INT,
                                          @revenue_value      Decimal(12,4))
returns Decimal(10,2)
AS
Begin
	Declare @returnval as Decimal(12,4)
	declare @legmiles	as Decimal(12,4),
		@movmiles		as Decimal(12,4),
		@pct			as Decimal(12,4),
		@mov			as int


	select @mov = mov_number, @legmiles = lgh_miles from legheader where lgh_number = @lgh_number

	-- Get the miles for all the legs on move that have at lease one billable stop
	if @mov > 0 
		begin
			select @movmiles = sum(isNull(lgh_miles,0))
			from legheader 
			where mov_number = @mov
				and exists (select 1 from stops s where s.lgh_number = legheader.lgh_number and isNull(s.ord_hdrnumber,0) > 0)
		end
	else
		-- If no Movement was found, then simply return the passed revenue amount
		return @revenue_value

	if @movmiles <= 0 
		select @movmiles = 1
	

	select @pct = (@legmiles/@movmiles)

	select @returnval = Round(@revenue_value * @pct, 4)

	RETURN @returnval
end

GO
GRANT EXECUTE ON  [dbo].[TMW_AllocateLegRevenue] TO [public]
GO
