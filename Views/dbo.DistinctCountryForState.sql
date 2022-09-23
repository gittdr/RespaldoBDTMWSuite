SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
Created 8/31/10 DPETE for PTS 51802 to ensure only one row per state. called by d_loaded_empty_miles_sp
*/


CREATE VIEW [dbo].[DistinctCountryForState]
AS
select  stc_state_c,min(stc_country_c) stc_country_c
from  statecountry
group by stc_state_c
GO
GRANT REFERENCES ON  [dbo].[DistinctCountryForState] TO [public]
GO
GRANT SELECT ON  [dbo].[DistinctCountryForState] TO [public]
GO
