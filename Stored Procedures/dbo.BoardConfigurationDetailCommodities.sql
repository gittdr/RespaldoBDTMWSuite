SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[BoardConfigurationDetailCommodities] @lgh_number int
as
	execute dbo.d_leg_commodities_sp @lghnumber = @lgh_number
GO
GRANT EXECUTE ON  [dbo].[BoardConfigurationDetailCommodities] TO [public]
GO
