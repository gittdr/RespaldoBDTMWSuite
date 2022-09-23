SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_checkcall_sp]
		@ps_trc	varchar(13),
		@pdt_dt	datetime,
		@pi_legheader	int
as
/**
 * 
 * NAME:
 * dbo.d_checkcall_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns the last checkcalls for the tractor (or legheader)
 *
 * RETURNS:
 * NONE 
 *
 * RESULT SETS: 
 *		ckc_number
 *		ckc_status
 *		ckc_asgntype
 *		ckc_asgnid
 *		ckc_date
 *		ckc_event
 *		ckc_city
 *		ckc_comment
 *		ckc_updatedby
 *		ckc_updatedon
 *		ckc_latseconds
 *		ckc_longseconds
 *		ckc_lghnumber
 *		ckc_tractor
 *		ckc_extsensoralarm
 *		ckc_vehicleignition
 *		ckc_milesfrom
 *		ckc_directionfrom
 *		ckc_validity
 *		ckc_mtavailable
 *		ckc_mileage
 *		ckc_minutes
 *		ckc_home
 *		ckc_minutes_to_final
 *		ckc_miles_to_final
 *		ckc_commentlarge
 *
 * PARAMETERS:
 * 001 - @ps_trc	varchar(13),
 * 002 - @ps_dt	datetime,
 * 003 - @pi_legheader	int
 * 
 * REVISION HISTORY:
 * 07/16/2008 ? PTS43704 - vjh ? Original creation of stored
 *				proc, pulling logic from datawindow select,
 *				and adding carrier legheader select logic
 *
 **/
declare @EtaUseCurrTime4OldCKC	char(1)
declare @UseThisTimeForOldCKC	int

Select @EtaUseCurrTime4OldCKC = upper(left(isnull(gi_string1,'N'),1)) From generalinfo Where gi_name = 'EtaUseCurrTime4OldCKC'
Select @UseThisTimeForOldCKC = isnull(gi_integer1,96) From generalinfo Where gi_name = 'EtaUseCurrTime4OldCKC'

If @pi_legheader is null or @pi_legheader = 0
	select	ckc_number
			,ckc_status
			,ckc_asgntype
			,ckc_asgnid
			--JLB PTS 46897
            --,ckc_date
			,case when @EtaUseCurrTime4OldCKC = 'Y' and ckc_date < dateadd(hh,@UseThisTimeForOldCKC,getdate())
                  then getdate()
                  else ckc_date end as 'ckc_date'
			,ckc_event
			,ckc_city
			,ckc_comment
			,ckc_updatedby
			,ckc_updatedon
			,ckc_latseconds
			,ckc_longseconds
			,ckc_lghnumber
			,ckc_tractor
			,ckc_extsensoralarm
			,ckc_vehicleignition
			,ckc_milesfrom
			,ckc_directionfrom
			,ckc_validity
			,ckc_mtavailable
			,ckc_mileage
			,ckc_minutes
			,ckc_home
			,ckc_minutes_to_final
			,ckc_miles_to_final
			,ckc_commentlarge
	  from	checkcall with (NOLOCK)
	  where	ckc_tractor = @ps_trc
		 and	ckc_latseconds is not null
		 and	ckc_latseconds <> 0
		 and	ckc_longseconds is not null
		 and	ckc_longseconds <> 0
		 and	ckc_date >= 
					(select	isnull(max(ckc_date), @pdt_dt) 
					  from	checkcall with (NOLOCK)
					  where	ckc_tractor = @ps_trc 
						 and	ckc_latseconds is not null
						 and	ckc_latseconds <> 0
						 and	ckc_longseconds is not null
						 and	ckc_longseconds <> 0
						 and	ckc_date < @pdt_dt)
else
	select	ckc_number
			,ckc_status
			,ckc_asgntype
			,ckc_asgnid
			--JLB PTS 46897
            --,ckc_date
			,case when @EtaUseCurrTime4OldCKC = 'Y' and ckc_date < dateadd(hh,@UseThisTimeForOldCKC,getdate())
                  then getdate()
                  else ckc_date end as 'ckc_date'
			,ckc_event
			,ckc_city
			,ckc_comment
			,ckc_updatedby
			,ckc_updatedon
			,ckc_latseconds
			,ckc_longseconds
			,ckc_lghnumber
			,ckc_tractor
			,ckc_extsensoralarm
			,ckc_vehicleignition
			,ckc_milesfrom
			,ckc_directionfrom
			,ckc_validity
			,ckc_mtavailable
			,ckc_mileage
			,ckc_minutes
			,ckc_home
			,ckc_minutes_to_final
			,ckc_miles_to_final
			,ckc_commentlarge
	  from	checkcall with (NOLOCK)
	  where	ckc_lghnumber = @pi_legheader
		 and	ckc_latseconds is not null
		 and	ckc_latseconds <> 0
		 and	ckc_longseconds is not null
		 and	ckc_longseconds <> 0
		 and	ckc_date >= 
					(select	isnull(max(ckc_date), @pdt_dt) 
					  from	checkcall with (NOLOCK)
					  where	ckc_lghnumber = @pi_legheader
						 and	ckc_latseconds is not null
						 and	ckc_latseconds <> 0
						 and	ckc_longseconds is not null
						 and	ckc_longseconds <> 0
						 and	ckc_date < @pdt_dt)


GO
GRANT EXECUTE ON  [dbo].[d_checkcall_sp] TO [public]
GO
