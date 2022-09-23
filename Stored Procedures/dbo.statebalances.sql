SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.statebalances    Script Date: 6/1/99 11:54:39 AM ******/
create procedure [dbo].[statebalances] as 

select 	'Loads' in_out, 
mw_loads = ( select count(lgh_number) 
from legheader, city
where cty_state in ('MI','WI','MO','NE','KA','IN','MN','IL','IA') and 
lgh_startcity = cty_code and lgh_outstatus IN ( 'AVL', 'DSP', 'PLN' ) ),

ea_loads = ( select count(lgh_number) 
from legheader, city
where cty_state in ('OH','WV','PA','NY','DE','MD','NJ') and 
lgh_startcity = cty_code and lgh_outstatus IN ( 'AVL', 'DSP', 'PLN' ) ),

se_loads = ( select count(lgh_number) 
from legheader, city
where cty_state in ('LA','AR','VA','NC','SC','GA','FL','AL','MS','TN','KY') and 
lgh_startcity = cty_code and lgh_outstatus IN ( 'AVL', 'DSP', 'PLN' ) ),

ne_loads = ( select count(lgh_number) 
from legheader, city 
where cty_state in ('ME','CT','MA','RI','VT','NH') and 
lgh_startcity = cty_code and lgh_outstatus IN ( 'AVL', 'DSP', 'PLN' ) ),

nw_loads = ( select count(lgh_number) 
from legheader, city 
where cty_state in ('WY','WA','OR','ID','MT','ND','SD','UT') and 
lgh_startcity = cty_code and lgh_outstatus IN ( 'AVL', 'DSP', 'PLN' ) ),

sw_loads = ( select count(lgh_number) 
from legheader, city 
where cty_state in ('CO','CA','AZ','NM','NV','TX','OK') and 
lgh_startcity = cty_code and lgh_outstatus IN ( 'AVL', 'DSP', 'PLN' ) )

union 

select 	'Trucks' in_out, 
mw_loads = ( select count(lgh_number) 
from legheader, city
where cty_state in ('MI','WI','MO','NE','KA','IN','MN','IL','IA') and 
lgh_endcity = cty_code and lgh_instatus <> 'HST' ),

ea_loads = ( select count(lgh_number) 
from legheader, city
where cty_state in ('OH','WV','PA','NY','DE','MD','NJ') and 
lgh_endcity = cty_code and lgh_instatus <> 'HST' ),

se_loads = ( select count(lgh_number) 
from legheader, city  
where cty_state in ('LA','AR','VA','NC','SC','GA','FL','AL','MS','TN','KY') and 
lgh_endcity = cty_code and lgh_instatus <> 'HST' ),

ne_loads = ( select count(lgh_number) 
from legheader, city 
where cty_state in ('ME','CT','MA','RI','VT','NH') and 
lgh_endcity = cty_code and lgh_instatus <> 'HST' ),

nw_loads = ( select count(lgh_number) 
from legheader, city 
where cty_state in ('WY','WA','OR','ID','MT','ND','SD','UT') and 
lgh_endcity = cty_code and lgh_instatus <> 'HST' ),

sw_loads = ( select count(lgh_number) 
from legheader, city 
where cty_state in ('CO','CA','AZ','NM','NV','TX','OK') and 
lgh_endcity = cty_code and lgh_instatus <> 'HST' )







GO
GRANT EXECUTE ON  [dbo].[statebalances] TO [public]
GO
