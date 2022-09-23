SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[OrderScrollReferenceNumberRestriction]
(
	@ref_number varchar(30),
	@ref_type varchar(6),
	@exactMatch int			-- 0 LIKE, 1 EXACT, 2 STARTSWITH
)
RETURNS @Table TABLE(Value INT)
AS
BEGIN
	if @ref_type <> 'UNK' and (@ref_number is not null and RTrim(@ref_number) <> '' and RTrim(@ref_number) <> '%') and @exactmatch = 0
	BEGIN
		 INSERT @Table SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, referencenumber 
			WHERE ( stops.mov_number = orderheader.mov_number ) 
			and ( referencenumber.ref_tablekey = stops.stp_number ) 
			and ( referencenumber.ref_table = 'stops' ) 
			AND (referencenumber.ref_type =  @ref_type)
			AND (referencenumber.ref_number like '%' + @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, referencenumber 
			WHERE ( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) 
			and ( referencenumber.ref_table = 'orderheader' ) 
			AND (referencenumber.ref_type =  @ref_type)
			AND (referencenumber.ref_number like '%' + @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, freightdetail, referencenumber 
			WHERE ( stops.ord_hdrnumber = orderheader.ord_hdrnumber ) 
			and  ( freightdetail.stp_number = stops.stp_number ) 
			and ( referencenumber.ref_tablekey = freightdetail.fgt_number ) 
			and ( referencenumber.ref_table = 'freightdetail' ) 
			AND (referencenumber.ref_type = @ref_type )
			AND (referencenumber.ref_number like '%' + @ref_number + '%')
	END
	else if @ref_type <> 'UNK' and @ref_number is not null and RTrim(@ref_number) <> '' and RTrim(@ref_number) <> '%' and @exactmatch = 1
			INSERT @Table SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, referencenumber 
			WHERE ( stops.mov_number = orderheader.mov_number ) 
			and ( referencenumber.ref_tablekey = stops.stp_number ) 
			and ( referencenumber.ref_table = 'stops' ) 
			AND (referencenumber.ref_type = @ref_type)
			AND (referencenumber.ref_number =  @ref_number)
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, referencenumber 
			WHERE ( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) 
			and ( referencenumber.ref_table = 'orderheader' ) 
			AND (referencenumber.ref_type = @ref_type)
			AND (referencenumber.ref_number =  @ref_number)
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, freightdetail, referencenumber 
			WHERE ( stops.ord_hdrnumber = orderheader.ord_hdrnumber ) 
			and  ( freightdetail.stp_number = stops.stp_number ) 
			and ( referencenumber.ref_tablekey = freightdetail.fgt_number ) 
			and ( referencenumber.ref_table = 'freightdetail' ) 
			AND (referencenumber.ref_type = @ref_type)
			AND (referencenumber.ref_number =  @ref_number)
	else if @ref_type <> 'UNK' and @ref_number is not null and RTrim(@ref_number) <> '' and RTrim(@ref_number) <> '%' and @exactmatch = 2
		 INSERT @Table SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, referencenumber 
			WHERE ( stops.mov_number = orderheader.mov_number ) 
			and ( referencenumber.ref_tablekey = stops.stp_number ) 
			and ( referencenumber.ref_table = 'stops' ) 
			AND (referencenumber.ref_type =  @ref_type)
			AND (referencenumber.ref_number like @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, referencenumber 
			WHERE ( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) 
			and ( referencenumber.ref_table = 'orderheader' ) 
			AND (referencenumber.ref_type =  @ref_type)
			AND (referencenumber.ref_number like @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, freightdetail, referencenumber 
			WHERE ( stops.ord_hdrnumber = orderheader.ord_hdrnumber ) 
			and  ( freightdetail.stp_number = stops.stp_number ) 
			and ( referencenumber.ref_tablekey = freightdetail.fgt_number ) 
			and ( referencenumber.ref_table = 'freightdetail' ) 
			AND (referencenumber.ref_type = @ref_type )
			AND (referencenumber.ref_number like @ref_number + '%')
	else if @ref_type = 'UNK' and (@ref_number is not null and RTrim(@ref_number) <> '' and RTrim(@ref_number) <> '%') and @exactmatch = 0
			INSERT @Table SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, referencenumber 
			WHERE ( stops.mov_number = orderheader.mov_number ) 
			and ( referencenumber.ref_tablekey = stops.stp_number ) 
			and ( referencenumber.ref_table = 'stops' ) 
			AND (referencenumber.ref_number like '%' + @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, referencenumber 
			WHERE ( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) 
			and ( referencenumber.ref_table = 'orderheader' ) 
			AND (referencenumber.ref_number like '%' + @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, freightdetail, referencenumber 
			WHERE ( stops.ord_hdrnumber = orderheader.ord_hdrnumber ) 
			and  ( freightdetail.stp_number = stops.stp_number ) 
			and ( referencenumber.ref_tablekey = freightdetail.fgt_number ) 
			and ( referencenumber.ref_table = 'freightdetail' ) 
			AND (referencenumber.ref_number like '%' + @ref_number + '%')
	else if @ref_type = 'UNK' and (@ref_number is not null and RTrim(@ref_number) <> '' and RTrim(@ref_number) <> '%') and @exactmatch = 1
			INSERT @Table SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, referencenumber 
			WHERE ( stops.mov_number = orderheader.mov_number ) 
			and ( referencenumber.ref_tablekey = stops.stp_number ) 
			and ( referencenumber.ref_table = 'stops' ) 
			AND (referencenumber.ref_number =  @ref_number)
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, referencenumber 
			WHERE ( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) 
			and ( referencenumber.ref_table = 'orderheader' ) 
			AND (referencenumber.ref_number =  @ref_number)
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, freightdetail, referencenumber 
			WHERE ( stops.ord_hdrnumber = orderheader.ord_hdrnumber ) 
			and  ( freightdetail.stp_number = stops.stp_number ) 
			and ( referencenumber.ref_tablekey = freightdetail.fgt_number ) 
			and ( referencenumber.ref_table = 'freightdetail' ) 
			AND (referencenumber.ref_number =  @ref_number)
	else if @ref_type = 'UNK' and (@ref_number is not null and RTrim(@ref_number) <> '' and RTrim(@ref_number) <> '%') and @exactmatch = 2
			INSERT @Table SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, referencenumber 
			WHERE ( stops.mov_number = orderheader.mov_number ) 
			and ( referencenumber.ref_tablekey = stops.stp_number ) 
			and ( referencenumber.ref_table = 'stops' ) 
			AND (referencenumber.ref_number like @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, referencenumber 
			WHERE ( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) 
			and ( referencenumber.ref_table = 'orderheader' ) 
			AND (referencenumber.ref_number like @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, freightdetail, referencenumber 
			WHERE ( stops.ord_hdrnumber = orderheader.ord_hdrnumber ) 
			and  ( freightdetail.stp_number = stops.stp_number ) 
			and ( referencenumber.ref_tablekey = freightdetail.fgt_number ) 
			and ( referencenumber.ref_table = 'freightdetail' ) 
			AND (referencenumber.ref_number like @ref_number + '%')
	else
			INSERT @Table SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, referencenumber 
			WHERE ( stops.mov_number = orderheader.mov_number ) 
			and ( referencenumber.ref_tablekey = stops.stp_number ) 
			and ( referencenumber.ref_table = 'stops' ) 
			AND (referencenumber.ref_number like  @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, referencenumber 
			WHERE ( referencenumber.ref_tablekey = orderheader.ord_hdrnumber ) 
			and ( referencenumber.ref_table = 'orderheader' ) 
			AND (referencenumber.ref_number like  @ref_number + '%')
			UNION SELECT orderheader.ord_hdrnumber 
			FROM orderheader, stops, freightdetail, referencenumber 
			WHERE ( stops.ord_hdrnumber = orderheader.ord_hdrnumber ) 
			and  ( freightdetail.stp_number = stops.stp_number ) 
			and ( referencenumber.ref_tablekey = freightdetail.fgt_number ) 
			and ( referencenumber.ref_table = 'freightdetail' ) 
			AND (referencenumber.ref_number like  @ref_number + '%')
	RETURN
END
GO
GRANT SELECT ON  [dbo].[OrderScrollReferenceNumberRestriction] TO [public]
GO
