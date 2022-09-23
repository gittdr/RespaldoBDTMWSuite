SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[generate_cmp_serviceexeptions_sp]
	@mov_number integer
as

-- PTS 52165 - DJM - corrected SQL 2000 errors
-- PTS 61832 - DJM - Modified per Mindy's instructions. (2/29/2012)

Declare @early as int,
	@late as int,
	@billtocmp	varchar(8),
	@checkstop	int,
	@curseq		int,
	@stpcmp		varchar(8),
	@cmp_seq	int,
	@curr_cmp	varchar(8),
	@earliest	datetime,
	@latest		datetime,
	@arrival	datetime,
	@departure	datetime,
	@type		varchar(6),
	@cmp_var_early	int,
	@cmp_var_late	int,
	@role		varchar(8),
	@cmp_type	varchar(8),
	@err_message	 varchar(1000),
	@leg			int,
	@stpord			int,
	@svc_id			int,
	@report			char(1),
	@stpcty			int
	
declare @deaddate datetime
select @deaddate = '1/1/1900'

Declare @stp_companies table(
	seq			int		identity,
	cmp_id		varchar(8)	not null,
	cmp_type	varchar(6)	not null)	
	
declare @cmp_stops table(
	stp_number			int		not null,
	cmp_id				varchar(8)	null,
	cmp_parentid		varchar(8)	null,
	stp_schdtearliest	datetime	null,
	stp_arrivaldate		datetime	null,
	stp_schdtlatest		datetime	null,
	stp_departuredate	datetime	null,
	stp_billto			varchar(8)	null,
	stp_billto_parent	varchar(8)	null,
	stp_mfh_sequence	int			null,
	stp_type			varchar(6)	null,
	lgh_number			int			null,
	ord_hdrnumber		int			null,
	stp_city			int			null
)

-- Create the list of companies that need to be checked on the trip
insert into @stp_companies
select distinct cmp_id, 'stop'
from stops s
where s.mov_number = @mov_number
	and s.stp_status = 'DNE'	
	and isNull(s.ord_hdrnumber,0) > 0
	
insert into @stp_companies
select distinct ord_billto, 'billto'
from orderheader o join stops s on s.ord_hdrnumber = o.ord_hdrnumber
where s.mov_number = @mov_number
	and s.stp_status = 'DNE'	
	and isNull(s.ord_hdrnumber,0) > 0
	and isNull(ord_billto,'UNKNOWN') <> 'UNKNOWN'

-- Build a table of the stops that need to be checked.
insert into @cmp_stops
select stp_number,
	cmp_id,
	(select cmp_mastercompany from company where cmp_id = s.cmp_id),
	stp_schdtearliest,
	stp_arrivaldate,
	stp_schdtlatest,
	stp_departuredate,
	(select o.ord_billto from orderheader o where o.ord_hdrnumber = s.ord_hdrnumber),
	(select cmp_mastercompany from company c , orderheader o where o.ord_hdrnumber = s.ord_hdrnumber and o.ord_billto = c.cmp_id),
	s.stp_mfh_sequence,
	s.stp_type,
	s.lgh_number,
	s.ord_hdrnumber,
	s.stp_city
from stops s
where s.mov_number = @mov_number
	and s.stp_status = 'DNE'	
	and isNull(s.ord_hdrnumber,0) > 0
order by stp_mfh_sequence
	
/*	
  For each stop, we need to loop through all the companies on the TRIP and the Bill To company on the order and see if the Early/Late
	thresholds for ANY of those companies triggers a Service Exception.
*/
select @curseq = min(stp_mfh_sequence) from @cmp_stops
select @checkstop = isnull(stp_number,0) from @cmp_stops s where s.stp_mfh_sequence = @curseq

while isnull(@curseq,0) > 0 
	Begin
	
		select @stpcmp = cmp_id from @cmp_stops where stp_number = @checkstop
		
		-- Get the stop time info
		select @earliest = stp_schdtearliest,
			@latest = stp_schdtlatest,
			@arrival = stp_arrivaldate,
			@departure = stp_departuredate,
			@type = stp_type,
			@leg = lgh_number,
			@stpord = ord_hdrnumber,
			@stpcty = stp_city
		from @cmp_stops
		where stp_number = @checkstop

		-- Loop through all the companies on the Trip 
		select @cmp_seq = isNull(min(seq),0) from @stp_companies
		while @cmp_seq > 0
			Begin
				select @curr_cmp = cmp_id,
					@cmp_type = cmp_type
				from @stp_companies where seq = @cmp_seq
				
				-- Get the company variance numbers.
				exec get_cmp_svcrpt_variance_sp @curr_cmp, @earliest, @type, @cmp_type, @cmp_var_early OUT, @cmp_var_late OUT, @err_message OUT, @report OUT
				
				--Print '@curr_cmp: ' + @curr_cmp
				--Print '@cmp_var_early: ' + cast(@cmp_var_early as varchar(10))
				--Print '@cmp_var_late: ' + cast(@cmp_var_late as varchar(10))
				
			
								
				-- If a variance is returned, check the trip
				if @cmp_var_early >= 0 or @cmp_var_late >= 0 
					Begin
						
						-- Calculate the early/late minutes
						select @early = datediff(mi, @arrival, @earliest),
							@late = datediff(mi, @latest, @arrival)
						
						if @early > @cmp_var_early OR @late > @cmp_var_late 
							Begin
								-- Need to get/create a ServiceException record for the current stop so customer can collect information
								exec generate_auto_serviceexception @mov_number, @checkstop, @stpcmp, @stpord,'', @stpcty, @svc_id OUT
							End
						
						-- if the Arrival is Early, but less than the CMP Variance, then delete the record
					  if @early >= 0 and @early <= @cmp_var_early and exists (select 1 from cmp_service_exception with (nolock) 
												where cmp_id = @curr_cmp and cse_stop = @checkstop and 
												isNull(cse_rpt_date,@deaddate) = @deaddate)  
							delete from cmp_service_exception where cmp_id = @curr_cmp and cse_stop = @checkstop and isNull(cse_rpt_date,@deaddate) = @deaddate  
							
						if @early > @cmp_var_early
							Begin
								--Print 'Early Service Variance.  Trip + '  + cast(@leg as varchar(10)) + ' arrived ' + cast(@early as varchar(6)) + ' minutes early on Stop: ' + cast(@checkstop as varchar(10))					
							
								 if not exists (select 1 from cmp_service_exception cse with (nolock) join serviceexception se on cse.sxn_sequence_number = se.sxn_sequence_number   
										where cmp_id = @curr_cmp and cse_stop = @checkstop and se.sxn_delete_flag = 'N')
									insert into cmp_service_exception 
										(cmp_id, 
										sxn_sequence_number,
										cse_variance, 
										cse_early_late, 
										cse_status,
										ord_hdrnumber,
										cse_reportable,
										cse_role,
										cse_stop,
										cmp_var_setting)
									Values( @curr_cmp,
										@svc_id,
										@early,
										'E',
										'OPN',
										@stpord,
										@report,
										@type,
										@checkstop,
										@cmp_var_early)
										
								else
									update cmp_service_exception
									set cse_variance = @early, 
										cse_early_late = 'E', 
										cse_status = 'OPN',
										ord_hdrnumber = @stpord,
										cse_reportable = @report,
										cse_role = @type,
										cmp_var_setting = @cmp_var_early
									from cmp_service_exception cse join serviceexception se on cse.sxn_sequence_number = se.sxn_sequence_number
									where cmp_id = @curr_cmp 
										and cse_stop = @checkstop
										and cse_status <> 'DNE'
										and se.sxn_delete_flag = 'N'
							End	
								
						-- if the Arrival is Late, but less than the CMP Variance, then delete the record
						if @late >= 0 and @cmp_var_late <= @late and exists (select 1 from cmp_service_exception cse join serviceexception s on cse.sxn_sequence_number = s.sxn_sequence_number where cmp_id = @curr_cmp and cse_stop = @checkstop and 
											isNull(cse_rpt_date,@deaddate) = @deaddate AND s.sxn_delete_flag = 'N')  
							delete from cmp_service_exception where cmp_id = @curr_cmp and cse_stop = @checkstop and isNull(cse_rpt_date,@deaddate) = @deaddate  

						if @late > @cmp_var_late 
							Begin
								--Print 'Early Service Variance.  Trip + '  + cast(@leg as varchar(10)) + ' arrived ' + cast(@early as varchar(6)) + ' minutes early on Stop: ' + cast(@checkstop as varchar(10))					
					
								if not exists (select 1 from cmp_service_exception cse with (nolock) join serviceexception se on cse.sxn_sequence_number = se.sxn_sequence_number 
										where cmp_id = @curr_cmp and cse_stop = @checkstop and se.sxn_delete_flag = 'N')
									insert into cmp_service_exception 
										(cmp_id, 
										sxn_sequence_number,
										cse_variance, 
										cse_early_late, 
										cse_status,
										ord_hdrnumber,
										cse_reportable,
										cse_role,
										cse_stop,
										cmp_var_setting)
									Values( @curr_cmp,
										@svc_id,
										@late,
										'L',
										'OPN',
										@stpord,
										@report,
										@type,
										@checkstop,
										@cmp_var_late)
								else
									update cmp_service_exception
									set cse_variance = @late, 
										cse_early_late = 'L', 
										cse_status = 'OPN',
										ord_hdrnumber = @stpord,
										cse_reportable = @report,
										cse_role = @type,
										cmp_var_setting = @cmp_var_late
									from cmp_service_exception cse with (nolock) join serviceexception se on cse.sxn_sequence_number = se.sxn_sequence_number
									where cmp_id = @curr_cmp 
										and cse_stop = @checkstop
										and cse_status <> 'DNE'
										and se.sxn_delete_flag = 'N'
								
							End
					End
				-- Get the next company
				select @cmp_seq = isNull(min(seq),0) from @stp_companies where seq > @cmp_seq
			End
			
		/*	
			PTS 53044 - DJM - Since this is run from the Update Move Post Processing and the logic to set the 
				Order status is in the appliation, if a user completes a whole trip without opening the Service Exception
				window the Order is saved with an Invoice Status of Available.  We need to set the Invoice Status of the Order
				here so we don't need to rely on the user opening the service exception window.
		*/
		if @svc_id > 0 
			Begin
				-- PTS 56784 - DJM - Check for the Reportable flag.
				if exists (select 1 
							from serviceexception  join cmp_service_exception on serviceexception.sxn_sequence_number = cmp_service_exception.sxn_sequence_number
							where  sxn_ord_hdrnumber = @stpord
								and (isNull(sxn_expcode,'UNK') = 'UNK' or sxn_expcode = '' OR ISNULL(sxn_description,'') = '' OR sxn_description = 'UNK' )
								and sxn_delete_flag = 'N'
								and sxn_ord_hdrnumber > 0
								and cmp_service_exception.cse_reportable = 'Y')
								
					Update orderheader
					set ord_invoicestatus = 'PND'
					where ord_hdrnumber = @stpord
						and ord_invoicestatus not in ('PND','PPD','XIN')
						and ord_status not in ('MST','CAN')

			End
			
	
		-- Get the next stop
		select @curseq = isNull(min(stp_mfh_sequence),0) from @cmp_stops where stp_mfh_sequence > @curseq
				
	
		select @checkstop = isnull(stp_number,0) from @cmp_stops s where s.stp_mfh_sequence = @curseq
		
		

	End



GO
GRANT EXECUTE ON  [dbo].[generate_cmp_serviceexeptions_sp] TO [public]
GO
