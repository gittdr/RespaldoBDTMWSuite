SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_state_country_sp    Script Date: 6/1/99 11:54:24 AM ******/
CREATE PROCEDURE [dbo].[d_state_country_sp] (@StateCode	varchar(12))
AS
	select statecountry.stc_country_c
	from statecountry
	where statecountry.stc_state_c = @StateCode


GO
GRANT EXECUTE ON  [dbo].[d_state_country_sp] TO [public]
GO
