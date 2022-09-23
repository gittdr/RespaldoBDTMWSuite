SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetPayTosList]

AS
/**
 *
 * NAME:
 * dbo.GetPayTosList
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure generates a list of Pay To IDs from the following tables:
 * manpowerprofile - mpp_payto
 * tractorprofile - trc_owner
 * trailerprofile - trl_owner
 * carrier - pto_id
 * thirdpartyprofile - tpr_payto
 *
 * RETURNS:
 * A table with the following schema:
 * owner_id (varchar 12)
 * is_mpp_payto (bit)
 * is_trc_payto (bit)
 * is_trl_payto (bit)
 * is_car_payto (bit)
 * is_tpr_payto (bit)
 *
 * RESULT SETS:
 * none
 *
 **/

declare @retTbl table (owner_id varchar(12), is_mpp_payto bit, is_trc_payto bit, is_trl_payto bit, is_car_payto bit, is_tpr_payto bit)
declare @tmpIdTbl table (tmpId varchar(12))
declare @tmpId varchar(12)

--manpowerprofile
insert into @tmpIdTbl
select distinct mpp_payto 
from manpowerprofile (nolock) 
where mpp_payto is not null 
	and mpp_payto <> 'UNKNOWN'

while (exists(select top 1 tmpId from @tmpIdTbl))
begin
	select top 1 @tmpId = tmpId from @tmpIdTbl
	
	if exists(select top 1 owner_id from @retTbl where owner_id = @tmpId)
	begin
		update @retTbl set is_mpp_payto = 1 WHERE owner_id = @tmpId
	end
	else
	begin
		insert into @retTbl
		(owner_id, is_mpp_payto, is_trc_payto, is_trl_payto, is_car_payto, is_tpr_payto)
		values
		(@tmpId, 1, 0, 0, 0, 0)
	end
	
	delete from @tmpIdTbl where tmpId = @tmpId
end

--tractorprpfile
insert into @tmpIdTbl
select distinct trc_owner 
from tractorprofile (nolock) 
where trc_owner is not null 
	and trc_owner <> 'UNKNOWN'

while (exists(select top 1 tmpId from @tmpIdTbl))
begin
	select top 1 @tmpId = tmpId from @tmpIdTbl
	
	if exists(select top 1 owner_id from @retTbl where owner_id = @tmpId)
	begin
		update @retTbl set is_trc_payto = 1 WHERE owner_id = @tmpId
	end
	else
	begin
		insert into @retTbl
		(owner_id, is_mpp_payto, is_trc_payto, is_trl_payto, is_car_payto, is_tpr_payto)
		values
		(@tmpId, 0, 1, 0, 0, 0)
	end
	
	delete from @tmpIdTbl where tmpId = @tmpId
end

--trailerprpfile
insert into @tmpIdTbl
select distinct trl_owner 
from trailerprofile (nolock) 
where trl_owner is not null 
	and trl_owner <> 'UNKNOWN'

while (exists(select top 1 tmpId from @tmpIdTbl))
begin
	select top 1 @tmpId = tmpId from @tmpIdTbl
	
	if exists(select top 1 owner_id from @retTbl where owner_id = @tmpId)
	begin
		update @retTbl set is_trl_payto = 1 WHERE owner_id = @tmpId
	end
	else
	begin
		insert into @retTbl
		(owner_id, is_mpp_payto, is_trc_payto, is_trl_payto, is_car_payto, is_tpr_payto)
		values
		(@tmpId, 0, 0, 1, 0, 0)
	end
	
	delete from @tmpIdTbl where tmpId = @tmpId
end

--carrier
insert into @tmpIdTbl
select distinct pto_id
from carrier (nolock) 
where pto_id is not null 
	and pto_id <> 'UNKNOWN'

while (exists(select top 1 tmpId from @tmpIdTbl))
begin
	select top 1 @tmpId = tmpId from @tmpIdTbl
	
	if exists(select top 1 owner_id from @retTbl where owner_id = @tmpId)
	begin
		update @retTbl set is_car_payto = 1 WHERE owner_id = @tmpId
	end
	else
	begin
		insert into @retTbl
		(owner_id, is_mpp_payto, is_trc_payto, is_trl_payto, is_car_payto, is_tpr_payto)
		values
		(@tmpId, 0, 0, 0, 1, 0)
	end
	
	delete from @tmpIdTbl where tmpId = @tmpId
end

--thirdpartyprofile
insert into @tmpIdTbl
select distinct tpr_payto
from thirdpartyprofile (nolock) 
where tpr_payto is not null 
	and tpr_payto <> 'UNKNOWN'

while (exists(select top 1 tmpId from @tmpIdTbl))
begin
	select top 1 @tmpId = tmpId from @tmpIdTbl
	
	if exists(select top 1 owner_id from @retTbl where owner_id = @tmpId)
	begin
		update @retTbl set is_tpr_payto = 1 WHERE owner_id = @tmpId
	end
	else
	begin
		insert into @retTbl
		(owner_id, is_mpp_payto, is_trc_payto, is_trl_payto, is_car_payto, is_tpr_payto)
		values
		(@tmpId, 0, 0, 0, 0, 1)
	end
	
	delete from @tmpIdTbl where tmpId = @tmpId
end

select owner_id, is_mpp_payto, is_trc_payto, is_trl_payto, is_car_payto, is_tpr_payto from @retTbl

GO
GRANT EXECUTE ON  [dbo].[GetPayTosList] TO [public]
GO
