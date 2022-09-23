SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[BoardConfigurationDetailLastTrailerCommodities] @lgh_number int
as
	CREATE TABLE #hold(
	[ord_hdrnumber] [int] NULL,
	[evt_enddate] [datetime] NULL,
	[cmd_code] [varchar](8) NOT NULL,
	[cmd_name] [varchar](60) NOT NULL,
	[fbc_weight] [float] NULL,
	[fgt_weightunit] [varchar](6) NULL,
	[fgt_count] [decimal](10, 2) NULL,
	[fgt_countunit] [varchar](6) NULL,
	[fbc_volume] [float] NULL,
	[fgt_volumeunit] [varchar](6) NULL,
	[fgt_quantity] [float] NULL,
	[fgt_unit] [varchar](6) NULL,
	[scm_subcode] [varchar](8) NULL,
	[fbc_compartm_number] [int] NULL,
	[trailer] [varchar](13) NULL,
	[wash_status] [char](1) NULL,
	[fbc_compartm_from] [varchar](4) NULL) 

	declare @trl varchar(12)

	select @trl = ''
	while exists (select * from assetassignment where lgh_number = @lgh_number and asgn_type = 'TRL' and asgn_id > @trl)
	begin
		select @trl = min(asgn_id) from assetassignment 
		where lgh_number = @lgh_number and asgn_type = 'TRL' and asgn_id > @trl
		
		insert #hold
		execute dbo.d_view_commodity_last_sp;1 @stringparm = @trl, @numberparm = @lgh_number, @retrieveby = 'LEG'
	end 

	select * from #hold
GO
GRANT EXECUTE ON  [dbo].[BoardConfigurationDetailLastTrailerCommodities] TO [public]
GO
