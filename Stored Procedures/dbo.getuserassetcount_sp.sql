SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[getuserassetcount_sp]
	@mov_number		integer, 
	@asset_type		varchar(6),
	@user_id		varchar(20),
	@legcount		integer OUT
AS

--Declare 	@legcount		integer

select @legcount = (Select count(*) 
	from legheader
	where mov_number = @mov_number
		and (lgh_outstatus = 'AVL' OR
			lgh_carrier in (select uar_asgnid
				from user_asset_restrictions
				where usr_userid = @user_id
						and uar_asgntype = @asset_type
				Union
				select uar_asgnid
				from user_asset_restrictions uar, ttsgroups g, ttsgroupasgn ga
				where ga.usr_userid = @user_id
					and ga.grp_id = g.grp_id
					and g.grp_id = uar.usr_userid
					and uar.uar_asgntype = @asset_type)))

--Print cast(@legcount as varchar(20))

Return @legcount
GO
GRANT EXECUTE ON  [dbo].[getuserassetcount_sp] TO [public]
GO
