SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[GetDispatchObjectCurrentActivity] 
					@type       	varchar (6), 
				  	@id 	    	varchar(13)
as
	DECLARE @Output TABLE
	(
	  AssignType varchar(15), 
	  asgn_number int, 
	  mov_number int, 
	  lgh_number int, 
	  start_stp_number int, 
	  end_stp_number int, 
	  start_evt_number int, 
	  end_evt_number int, 
	  startdate datetime,
	  enddate datetime,
	  controlling varchar(1), 
	  status varchar(6),
	  AssetType varchar(6),
	  AssetId varchar(13)
	)
	
	declare @lastcmp_asgn_number int, 
	  @lastall_asgn_number int, 
	  @cur_asgn_number int, 
	  @next_asgn_number int

	DECLARE	@mov_number int, @lgh int

	exec @mov_number = cur_activity_asgn_number @type, 
								  @id, 
								  @lgh OUTPUT,
								  @cur_asgn_number OUTPUT
								  
	insert @Output
	select 'CURRENT',
		  asgn_number, 
		  mov_number, 
		  lgh_number, 
		  starte.stp_number, 
		  ende.stp_number, 
	      a.evt_number, 
		  a.last_evt_number, 
		  starte.evt_startdate,
		  ende.evt_enddate, 
	      a.asgn_controlling,
	      a.asgn_status,
	      a.asgn_type,
	      a.asgn_id
	  from assetassignment as a
			join event as starte on starte.evt_number = a.evt_number
			join event as ende on ende.evt_number = a.last_evt_number
	  where asgn_number = @cur_asgn_number							  
								  
	insert @Output
	select 'ONMOVE',
		  asgn_number, 
		  mov_number, 
		  lgh_number, 
		  starte.stp_number, 
		  ende.stp_number, 
	      a.evt_number, 
		  a.last_evt_number, 
		  starte.evt_startdate,
		  ende.evt_enddate, 
	      a.asgn_controlling,
	      a.asgn_status,
	      a.asgn_type,
	      a.asgn_id
	  from assetassignment as a
			join event as starte on starte.evt_number = a.evt_number
			join event as ende on ende.evt_number = a.last_evt_number
	  where a.mov_number = @mov_number and asgn_number <> @cur_asgn_number							  
								  
								  
	insert @Output
	select top 1 'LASTCMP',
		  lasta.asgn_number, 
		  lasta.mov_number, 
		  lasta.lgh_number, 
		  starte.stp_number, 
		  ende.stp_number, 
	      lasta.evt_number, 
		  lasta.last_evt_number, 
		  starte.evt_startdate,
		  ende.evt_enddate, 
	      lasta.asgn_controlling,
	      lasta.asgn_status,
	      lasta.asgn_type,
	      lasta.asgn_id
	from assetassignment as lasta 
		join event as starte on starte.evt_number = lasta.evt_number
		join event as ende on ende.evt_number = lasta.last_evt_number
	where 	lasta.asgn_status = 'CMP' and
			lasta.asgn_id = @id and 
			lasta.asgn_type = @type and
			lasta.asgn_enddate = (select MAX(a2.asgn_enddate) from assetassignment as a2
										where a2.asgn_id = lasta.asgn_id and 
											a2.asgn_type = lasta.asgn_type and
											a2.asgn_status = 'CMP')
	order by lasta.asgn_number desc
	
	insert @Output
	select top 1 'LASTALL',
		  lasta.asgn_number, 
		  lasta.mov_number, 
		  lasta.lgh_number, 
		  starte.stp_number, 
		  ende.stp_number, 
	      lasta.evt_number, 
		  lasta.last_evt_number, 
		  starte.evt_startdate,
		  ende.evt_enddate, 
	      lasta.asgn_controlling,
	      lasta.asgn_status,
	      lasta.asgn_type,
	      lasta.asgn_id
	from assetassignment as lasta 
		join event as starte on starte.evt_number = lasta.evt_number
		join event as ende on ende.evt_number = lasta.last_evt_number
	where 	lasta.asgn_id = @id and 
			lasta.asgn_type = @type and
			lasta.asgn_enddate = (select MAX(a2.asgn_enddate) from assetassignment as a2
										where a2.asgn_id = lasta.asgn_id and 
											a2.asgn_type = lasta.asgn_type and
											 a2.asgn_enddate < ISNULL((select o.startdate from @Output as o where o.AssignType = 'CURRENT'),'12/31/2049'))
	order by lasta.asgn_number desc
	
		insert @Output
	select top 1 'NEXTPLN',
		  lasta.asgn_number, 
		  lasta.mov_number, 
		  lasta.lgh_number, 
		  starte.stp_number, 
		  ende.stp_number, 
	      lasta.evt_number, 
		  lasta.last_evt_number, 
		  starte.evt_startdate,
		  ende.evt_enddate, 
	      lasta.asgn_controlling,
	      lasta.asgn_status,
	      lasta.asgn_type,
	      lasta.asgn_id
	from assetassignment as lasta 
		join event as starte on starte.evt_number = lasta.evt_number
		join event as ende on ende.evt_number = lasta.last_evt_number
	where lasta.asgn_id = @id and
			lasta.asgn_type = @type and
			lasta.asgn_status in ('PLN','DSP') and
			lasta.asgn_date = (select Min(a2.asgn_date) from assetassignment as a2
										where a2.asgn_id = lasta.asgn_id and 
											a2.asgn_type = lasta.asgn_type and
											a2.asgn_status in ('PLN','DSP'))
	order by lasta.asgn_number desc
	
	select * from @Output
GO
GRANT EXECUTE ON  [dbo].[GetDispatchObjectCurrentActivity] TO [public]
GO
