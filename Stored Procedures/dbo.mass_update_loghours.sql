SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[mass_update_loghours] as
declare @min_mpp_id varchar(8)
select @min_mpp_id=min(mpp_id) from manpowerprofile where mpp_status <> 'OUT'
while @min_mpp_id is not null begin

	execute update_loghours @min_mpp_id

	select @min_mpp_id=min(mpp_id)
	from manpowerprofile 
	where mpp_status <> 'OUT'
	and mpp_id > @min_mpp_id
end

GO
GRANT EXECUTE ON  [dbo].[mass_update_loghours] TO [public]
GO
