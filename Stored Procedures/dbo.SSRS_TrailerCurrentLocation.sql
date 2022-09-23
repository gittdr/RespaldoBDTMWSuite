SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




create Proc [dbo].[SSRS_TrailerCurrentLocation]
	
as

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

	

select  trl_id 'Trailer ID', 
	( select dbo.TMWSSRS_fnc_LastActualizedStop(trl_id)) 'Last Stop'
into #TrailerLastStop
from trailerprofile trl
			
where	trl_status <> 'OUT' 
		

select 
	[Trailer ID],
	[Last Stop],
	dbo.TMWSSRS_fnc_NextStop([Last Stop]) [Next Stop],

	(select top 1 exp_expirationdate
		from expiration 
		where	exp_idtype = 'TRL'
				and exp_code = 'INS'
				and exp_id = [Trailer ID]
		order by exp_expirationdate desc) 'In Service Date',


	(select top 1 cty_name
		from expiration 
			inner join city on city.cty_code = exp_city	
		where	exp_idtype = 'TRL'
			and exp_code = 'INS'
			and exp_id = [Trailer ID]
		order by exp_expirationdate desc) 'In Service City',

	(select top 1 cty_state
		from expiration 
			inner join city on city.cty_code = exp_city	
		where	exp_idtype = 'TRL'
			and exp_code = 'INS'
			and exp_id = [Trailer ID]
		order by exp_expirationdate desc) 'In Service State',


	(select top 1 exp_routeto
		from expiration 
		where	exp_idtype = 'TRL'
				and exp_code = 'INS'
				and exp_id = [Trailer ID]
		order by exp_expirationdate desc) 'In Service Company'

into #TrailerStops
from #TrailerLastStop
	



select 
	[Trailer ID],
--	[Last Stop],

	case when [In Service Date] > LastStop.stp_arrivaldate then
		[In Service Date]
	else
		LastStop.stp_arrivaldate
	end as 'Last Date',

	case when [In Service Date] > LastStop.stp_arrivaldate then
		'In Service'
	else
		LastStop.stp_event
	end as 'Last Event',

	case when [In Service Date] > LastStop.stp_arrivaldate then
		''
	else
		LastStop.cmp_id
	end as 'Company ID',

	case when [In Service Date] > LastStop.stp_arrivaldate then
		[In Service Company]
	else
		LastStopCmp.cmp_name
	end as 'Company',


	case when [In Service Date] > LastStop.stp_arrivaldate then
		[In Service City]
	else
		LastStopCty.cty_name 
	end as 'Last City',
	
	case when [In Service Date] > LastStop.stp_arrivaldate then
		[In Service State]
	else
		LastStopCty.cty_state 
	end as 'Last State',
	
	case when NextStop.stp_arrivaldate is null then
		case when [In Service Date] > LastStop.stp_arrivaldate then
			datediff(d,[In Service Date],getdate())
		else
			datediff(d,LastStop.stp_arrivaldate,getdate())
		end
	else
		case when [In Service Date] > LastStop.stp_arrivaldate then
			datediff(d,[In Service Date],NextStop.stp_arrivaldate)
		else
			datediff(d,LastStop.stp_arrivaldate,NextStop.stp_arrivaldate)
		end
	end 'Lag',

	case when [Next Stop] is null then
		'Sitting'
	else
		'Assigned'
	end 'Trailer Activity',
	
--	[Next Stop],
	NextStop.stp_arrivaldate 'Next Date',
	NextStop.stp_event 'Next Event',
	NextStop.cmp_id 'Next Company ID',
	NextStopCmp.cmp_name 'Next Company',
	NextStopCty.cty_name 'Next City',
	NextStopCty.cty_state 'Next State'



from #TrailerStops
	left join trailerprofile trl on trl.trl_id = [Trailer ID]
	left join stops LastStop on LastStop.stp_number = [Last Stop]	
	left join company LastStopCmp on LastStopCmp.cmp_id = LastStop.cmp_id
	left join city LastStopCty on LastStopCty.cty_code = LastStop.stp_city
	left join stops NextStop on NextStop.stp_number = [Next Stop]	
	left join company NextStopCmp on NextStopCmp.cmp_id = NextStop.cmp_id
	left join city NextStopCty on NextStopCty.cty_code = NextStop.stp_city

order by 
	case when [In Service Date] > LastStop.stp_arrivaldate then
		[In Service Company]
	else
		LastStopCmp.cmp_name
	end 


GO
