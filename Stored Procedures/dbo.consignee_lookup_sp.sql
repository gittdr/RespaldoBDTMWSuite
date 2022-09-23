SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[consignee_lookup_sp] (@railpoolid	varchar(8),
									@dest	varchar(25),
									@config	varchar(6),
									@cmp varchar(8) OUTPUT)
as

select distinct @cmp = r.cmp_id
from rail_customers r, company c
where rcu_id = @railpoolid and 
		rcu_destination_city = @dest and 
		((rcu_equipmconfiguration = 'B' and @config in ('U', 'S', 'Z', 'JBHU')) or
			(rcu_equipmconfiguration = 'C' and @config in ('U', 'S')) or
			(rcu_equipmconfiguration = 'T' and @config in ('Z', 'JBHU'))) and
	c.cmp_id = r.cmp_id and c.cmp_railramp = 'Y'

GO
GRANT EXECUTE ON  [dbo].[consignee_lookup_sp] TO [public]
GO
