SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getOrderStopDetails] 
	(@ord_hdrnumber int)
AS

set nocount on
	select 	stp_event
			, isnull(c.cmp_name + ' at ' + c.cty_nmstct, '') as location
			, stp_schdtearliest
			, stp_arrivaldate
			, stp_schdtlatest
			, stp_departuredate
			, stp_comment
	from 	stops s
			join company c on c.cmp_id = s.cmp_id
			join city ct on ct.cty_code = s.stp_city
	where ord_hdrnumber = @ord_hdrnumber
	order by stp_sequence

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_getOrderStopDetails] TO [public]
GO
