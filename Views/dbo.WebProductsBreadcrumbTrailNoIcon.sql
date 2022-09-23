SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[WebProductsBreadcrumbTrailNoIcon] as
select o.ord_hdrnumber as ordernumber, o.ord_status, (cast(c.ckc_latseconds AS decimal)) as latitude, (cast(c.ckc_longseconds AS decimal)) as longitude, ci.cty_nmstct as city, ci.cty_state as state, c.ckc_date as date
from orderheader o WITH (NOLOCK)
join stops s WITH (NOLOCK) on o.ord_hdrnumber = s.ord_hdrnumber
join checkcall c WITH (NOLOCK) on c.ckc_lghnumber = s.lgh_number
join city ci WITH (NOLOCK) on ci.cty_code = c.ckc_city
GO
GRANT SELECT ON  [dbo].[WebProductsBreadcrumbTrailNoIcon] TO [public]
GO
