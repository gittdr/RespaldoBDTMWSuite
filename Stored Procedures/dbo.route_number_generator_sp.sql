SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[route_number_generator_sp] (@ord_revtype1 varchar(10), @ord_revtype2 varchar(10),
	 @ord_revtype3 varchar(10), @ord_revtype4 varchar(10), @generated_route_value varchar(8) OUTPUT) AS RETURN
GO
GRANT EXECUTE ON  [dbo].[route_number_generator_sp] TO [public]
GO
