SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[expiration_start_status_sync_sp]
AS

/*
JLB PTS 25370
Written to be scheduled as a job in SQL Server.  This will run the appropriate
expstatus proc for any resource that is currently available by status but has 
a current priority 1 expiration
*/
declare @mpp_id varchar(8), @trc_number varchar(8), @trl_id varchar(13),  @car_id varchar(8)

--Driver
select @mpp_id = min(mpp_id)
  from manpowerprofile, expiration
 where manpowerprofile.mpp_status = 'AVL'
   and manpowerprofile.mpp_id <> 'UNKNOWN'
   and expiration.exp_id = manpowerprofile.mpp_id
   and expiration.exp_idtype = 'DRV'
   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
   and isnull(expiration.exp_completed,'N') <> 'Y'
   and expiration.exp_priority = '1'


while @mpp_id is not null
begin
   --select @mpp_id as 'Driver'
	exec drv_expstatus @mpp_id
	select @mpp_id = min(mpp_id)
	  from manpowerprofile, expiration
	 where manpowerprofile.mpp_status = 'AVL'
	   and manpowerprofile.mpp_id <> 'UNKNOWN'
	   and expiration.exp_id = manpowerprofile.mpp_id
	   and expiration.exp_idtype = 'DRV'
	   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
	   and isnull(expiration.exp_completed,'N') <> 'Y'
	   and expiration.exp_priority = '1'
		and mpp_id > @mpp_id
	end

--Tractor
select @trc_number = min(trc_number)
  from tractorprofile, expiration
 where tractorprofile.trc_status = 'AVL'
   and tractorprofile.trc_number <> 'UNKNOWN'
   and expiration.exp_id = tractorprofile.trc_number
   and expiration.exp_idtype = 'TRC'
   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
   and isnull(expiration.exp_completed,'N') <> 'Y'
   and expiration.exp_priority = '1'

while @trc_number is not null
begin
	--select @trc_number as 'Tractor'
	exec trc_expstatus @trc_number
	select @trc_number = min(trc_number)
	  from tractorprofile, expiration
	 where tractorprofile.trc_status = 'AVL'
	   and tractorprofile.trc_number <> 'UNKNOWN'
	   and expiration.exp_id = tractorprofile.trc_number
	   and expiration.exp_idtype = 'TRC'
	   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
	   and isnull(expiration.exp_completed,'N') <> 'Y'
	   and expiration.exp_priority = '1'
		and trc_number > @trc_number
end

--Trailer
select @trl_id = min(trl_id)
  from trailerprofile, expiration
 where trailerprofile.trl_status = 'AVL'
   and trailerprofile.trl_id <> 'UNKNOWN'
   and expiration.exp_id = trailerprofile.trl_id
   and expiration.exp_idtype = 'TRL'
   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
   and isnull(expiration.exp_completed,'N') <> 'Y'
   and expiration.exp_priority = '1'

while @trl_id is not null
begin
	--select @trl_number as 'Trailer'
	exec trl_expstatus @trl_id
	select @trl_id = min(trl_id)
	  from trailerprofile, expiration
	 where trailerprofile.trl_status = 'AVL'
	   and trailerprofile.trl_id <> 'UNKNOWN'
	   and expiration.exp_id = trailerprofile.trl_id
	   and expiration.exp_idtype = 'TRL'
	   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
	   and isnull(expiration.exp_completed,'N') <> 'Y'
	   and expiration.exp_priority = '1'
		and trl_id > @trl_id

end

--Carrier
select @car_id = min(car_id)
  from carrier, expiration
 where carrier.car_status = 'ACT'
   and carrier.car_id <> 'UNKNOWN'
   and expiration.exp_id = carrier.car_id
   and expiration.exp_idtype = 'CAR'
   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
   and isnull(expiration.exp_completed,'N') <> 'Y'
   and expiration.exp_priority = '1'

while @car_id is not null
begin
	--select @car_id as 'Carrier'
	exec car_expstatus @car_id
	select @car_id = min(car_id)
	  from carrier, expiration
	 where carrier.car_status = 'ACT'
	   and carrier.car_id <> 'UNKNOWN'
	   and expiration.exp_id = carrier.car_id
	   and expiration.exp_idtype = 'CAR'
	   and isnull(expiration.exp_expirationdate,'01/01/49') <= getdate()
	   and isnull(expiration.exp_completed,'N') <> 'Y'
	   and expiration.exp_priority = '1'
		and car_id > @car_id

end

GO
GRANT EXECUTE ON  [dbo].[expiration_start_status_sync_sp] TO [public]
GO
