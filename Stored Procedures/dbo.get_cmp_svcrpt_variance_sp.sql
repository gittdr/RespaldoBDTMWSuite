SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
	Created for PTS 45980 to determine the Service Reporting threshold for the specified company
	
	PTS 45980 - DJM - 8/6/2009 - initial creation.
	
		Per customer, default value for Variance should be 30 minutes.  -1 indicates use the Parent company value.  Zero should be a discrete
		value that can be used for variance and not used to indicate anything else.
*/
CREATE procedure [dbo].[get_cmp_svcrpt_variance_sp]
	@cmp_id	varchar(8),
	@date	datetime,
	@stp_type	varchar(6),
	@role	varchar(8),
	@early	int		output,
	@late	int		output,
	@error	varchar(1000) output,
	@reportable		char(1) output
as

Declare @parent as varchar(8)


select @early = 30
select @late = 30
select @reportable = 'Y'

--print 'Service Rpt variance for @cmp_id: ' + @cmp_id
--Print '@date: ' + Convert(varchar(50), @date, 20 )

if @role = 'billto'
	Begin
		if exists (select 1 from company where cmp_id = @cmp_id and cmp_servicebillto_rpt = 1)
			select @reportable = 'N'
		
		Select @early = isNull(csv_billto_early,30),
			@late = isNull(csv_billto_late,30)
		from company_service_variance
		where cmp_id = @cmp_id
			and @date between eff_date_start and eff_date_end
		
		-- If no values are found for the Company and the Service Reporting is not disabled for Bill To, look to the Parent company.
		if isNull(@early,30) = -1 OR isNull(@late,30)= -1 
			Begin
				select @parent = isNull(cmp_mastercompany,'UNKNOWN') from company where cmp_id = @cmp_id
				
						Begin
							if @parent <> 'UNKNOWN' AND ISNULL(@early,30) = -1
								Select @early = isNull(csv_billto_early,30)
								from company_service_variance
								where cmp_id = @parent
									and @date between eff_date_start and eff_date_end
									
							if @parent <> 'UNKNOWN' AND ISNULL(@late,30) = -1
								Select @late = isNull(csv_billto_late,30)
								from company_service_variance
								where cmp_id = @parent
									and @date between eff_date_start and eff_date_end

						End
				
			End
		
	End
			
else
	Begin
		-- Check the Shipper values.
		if @stp_type = 'PUP'
			Begin
				if exists (select 1 from company where cmp_id = @cmp_id and cmp_servicepup_rpt = 1)
					select @reportable = 'N'
			
				Select @early = isNull(csv_pup_early,30),
					@late = isNull(csv_pup_late,30)
				from company_service_variance
				where cmp_id = @cmp_id
					and @date between eff_date_start and eff_date_end
			
				-- If no values are found for the Company and the Service Reporting is not disabled for Shippers, look to the Parent company.
				if isNull(@early,30) = -1 OR isNull(@late,30)= -1 
					Begin
						select @parent = isNull(cmp_mastercompany,'UNKNOWN') from company where cmp_id = @cmp_id
						
						Begin
							if @parent <> 'UNKNOWN' AND ISNULL(@early,30) = -1
								Select @early = isNull(csv_pup_early,30)
								from company_service_variance
								where cmp_id = @parent
									and @date between eff_date_start and eff_date_end
									
							if @parent <> 'UNKNOWN' AND ISNULL(@late,30) = -1
								Select @late = isNull(csv_pup_late,30)
								from company_service_variance
								where cmp_id = @parent
									and @date between eff_date_start and eff_date_end

						End
						
					End
			
			End	
		
		
		-- Check the Consignee values
		if @stp_type = 'DRP'
			Begin
				if exists (select 1 from company where cmp_id = @cmp_id and cmp_servicepup_rpt = 1)
					select @reportable = 'N'
			
				Select @early = isNull(csv_del_early,30),
					@late = isNull(csv_del_late,30)
				from company_service_variance
				where cmp_id = @cmp_id
					and @date between eff_date_start and eff_date_end
			
				-- If no values are found for the Company and the Service Reporting is not disabled for Consignees, look to the Parent company.
				if isNull(@early,30) = -1 OR isNull(@late,30)= -1 
					Begin
						select @parent = isNull(cmp_mastercompany,'UNKNOWN') from company where cmp_id = @cmp_id
						
						Begin
							if @parent <> 'UNKNOWN' AND ISNULL(@early,30) = -1
								Select @early = isNull(csv_del_early,30)
								from company_service_variance
								where cmp_id = @parent
									and @date between eff_date_start and eff_date_end
									
							if @parent <> 'UNKNOWN' AND ISNULL(@late,30) = -1
								Select @late = isNull(csv_del_late,30)
								from company_service_variance
								where cmp_id = @parent
									and @date between eff_date_start and eff_date_end

						End
						
					End
			End	
			
	End
	
	Return


GO
GRANT EXECUTE ON  [dbo].[get_cmp_svcrpt_variance_sp] TO [public]
GO
