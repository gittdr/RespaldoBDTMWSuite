SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[link_partorder_OH] @p_num INT
AS
BEGIN

set nocount on

DECLARE 
	  @v_count INT
	, @v_ordhdr INT
	, @v_user VARCHAR(10)
	, @v_msg VARCHAR(255)
	, @v_branch VARCHAR(12)
	, @v_supplier VARCHAR(8)
	, @v_MFST VARCHAR(15)
	, @v_cutoff INT
	, @v_pohid INT
	, @v_ordstatus INT
	, @v_startedmethod char(1)
	, @v_route VARCHAR(15) -- timeline.detail.route
	, @v_direction CHAR(1)
	, @v_master_ordhdr INT
	, @sql nvarchar(3000)
	, @sql1 nvarchar(200)
	, @sql2 nvarchar(200)
	, @sql3 nvarchar(200)
	, @sql4 nvarchar(200)
	, @sql5 nvarchar(200)
	, @sql6 nvarchar(200)
	, @sql7 nvarchar(200)
	, @sql8 nvarchar(200)
	, @sql9 nvarchar(400)
	, @sql10 nvarchar(200)
	, @sql11 nvarchar(200)
	, @sql20 nvarchar(200)
	, @enddate_limit datetime
	, @v_porid INT
	, @debug INT
	, @por_group_identity INT
	, @History INT

declare @unlinked_por TABLE ( por_identity INT )

----------- DEBUG FLAG MUST BE OFF TO RUN IN TMWS ------------
select @debug = 0	-- Off
--select @debug = 1	-- On
---------------- HISTORY FLAG --------------------------------
--select @History = 0 -- Off. Do not generate history
select @History = 1 -- On
--------------------------------------------------------------

if @debug > 0 print ' ******************* DEBUG MODE ON ************************'

EXEC gettmwuser @v_user OUTPUT

SELECT @v_cutoff = isnull(gi_integer1, 1)
FROM generalinfo
WHERE gi_name = 'LinkPartOrderDays'

SELECT @v_startedmethod = left(isnull(gi_string1, 'Y'), 1)
FROM generalinfo
WHERE gi_name = 'TimeLineLinkStarted'

--if @debug > 0 set @v_startedmethod = 'S'

set @enddate_limit = DATEADD(dd, -@v_cutoff, getdate())

if @debug > 0 set @enddate_limit = DATEADD(dd, -45, getdate())

IF @p_num > 0 
	INSERT INTO @unlinked_por
	SELECT por_identity
	FROM partorder_routing
	where por_route = (SELECT ord_route FROM orderheader WHERE ord_hdrnumber = @p_num
    --AND por_begindate between DATEADD(DAY, DATEDIFF(DAY, 0, ord_miscdate1), 0) and DATEADD(DAY, DATEDIFF(DAY, 0, ord_completiondate), 0) + 1
    --AND por_enddate <= DATEADD(DAY, DATEDIFF(DAY, 0, ord_completiondate), 0) + 1)
	AND por_begindate >= DATEADD(DAY, DATEDIFF(DAY, 0, ord_miscdate1), 0) 
	AND por_begindate < DATEADD(DAY, DATEDIFF(DAY, 0, ord_completiondate), 0) + 1
    AND por_enddate < DATEADD(DAY, DATEDIFF(DAY, 0, ord_completiondate), 0) + 1)
	AND isNull(por_ordhdr, 0) = 0
	AND isnull(por_route, '0') <> '0'
	order by por_identity
ELSE
	INSERT INTO @unlinked_por
	SELECT por_identity
	FROM partorder_routing
	WHERE IsNull(por_ordhdr, 0) = 0
	AND por_enddate >= @enddate_limit
--	AND por_enddate >= DATEADD(dd, -1, getdate())

SET @v_count = 0
SET @v_porid = 0

WHILE EXISTS (SELECT por_identity FROM @unlinked_por WHERE por_identity > @v_porid)
BEGIN
	--Loop control
	SELECT @v_porid = MIN(por_identity) FROM @unlinked_por WHERE por_identity > @v_porid

	SELECT 
	@v_ordhdr = por_ordhdr,
	@v_master_ordhdr = por_master_ordhdr,
	@v_route = por_route,
	@v_pohid = poh_identity
	FROM partorder_routing WHERE por_identity = @v_porid
	and por_enddate >= convert(varchar(10),@enddate_limit,101) 
	
	--MRH need the direction from the header
	SELECT @v_direction = PH.poh_direction , @v_branch = ISNULL(poh_branch, '') from partorder_header PH
	where PH.poh_identity =  @v_pohid
	
		select @sql = '', @sql1 = '', @sql2 = '', @sql3 = '', @sql4 = '', @sql5 = '', @sql6 = '', @sql7 = '', @sql8 = '', @sql9 = '', @sql10 = '', @sql11 = ''
	
		set @sql1 = N'SELECT @v_count = COUNT(Distinct s.ord_hdrnumber) '
		set @sql2 = N'FROM stops s inner join orderheader oh1 on s.ord_hdrnumber = oh1.ord_hdrnumber '
		set @sql7 = N'AND pr.por_identity = ' + convert(varchar(15),@v_porid) + ' '

		--if isnull(@v_master_ordhdr, 0) > 0 
		--	set @sql20 = N'INNER JOIN orderheader oh2 on oh1.ord_fromorder = oh2.ord_number and oh2.ord_hdrnumber = pr.por_master_ordhdr '

		If @v_direction = 'P'
			begin
				set @sql3 = N'INNER JOIN partorder_routing pr on s.cmp_id = pr.por_origin '
				set @sql4 = N'WHERE ((s.stp_type = ''PUP'' or s.stp_type = ''CTR'') '
				set @sql5 = N'AND CAST(FLOOR(CAST(s.stp_schdtearliest AS float)) AS datetime) = CAST(FLOOR(CAST(pr.por_begindate AS float)) AS datetime) '
			end
		else
			begin
				set @sql3 = N'INNER JOIN partorder_routing pr on s.cmp_id = pr.por_destination '
				set @sql4 = N'WHERE ((s.stp_type = ''DRP'' or s.stp_type = ''CTR'') '
				set @sql5 = N'AND CAST(FLOOR(CAST(s.stp_schdtearliest AS float)) AS datetime) = CAST(FLOOR(CAST(pr.por_enddate AS float)) AS datetime) '
			end
	
		if @v_startedmethod = 'N'
		begin
			--set @sql6 = N'and ISNULL(por_ordhdr, 0) = 0 '
			set @sql8 = N'and oh1.ord_status IN (''AVL'', ''PLN'', ''DSP'') '
		end
	
		if @v_startedmethod in ('S','Y')
			set @sql9 = N'and oh1.ord_status IN (''AVL'', ''PLN'', ''STD'', ''DSP'') '
	
		if @v_startedmethod = 'S'
			set @sql6 = N'AND s.stp_status = ''OPN'' AND (select count(0) from stops s1 where s1.ord_hdrnumber = oh1.ord_hdrnumber AND s1.cmp_id = pr.por_origin AND s1.stp_type = ''PUP'' AND s1.stp_status = ''OPN'') > 0) '
		else
			set @sql6 = N') '

		--if isnull(@v_master_ordhdr, 0) = 0 
			set @sql10 = N'AND ord_route = ''' + @v_route + N''' '

		if @v_branch = '203'
			set @sql11 = N'AND oh1.ord_booked_revtype1 in (select alt_branch from altbranch where branch = ''203'') '
		else
			set @sql11 = N'and oh1.ord_booked_revtype1 = ''' + @v_branch + N''' '

		set @sql = @sql1 + isnull(@sql2,'') + isnull(@sql3,'') + isnull(@sql20,'') + isnull(@sql4,'') + isnull(@sql5,'') + isnull(@sql6,'') + isnull(@sql7,'') + isnull(@sql8,'') + isnull(@sql9,'') + isnull(@sql10, '') + isnull(@sql11, '')

		if @debug > 0 print @sql
		exec sp_executesql @sql, N'@v_count int output',@v_count output
		if @debug > 0 print 'Count:' + convert(varchar(20), @v_count)
	
		IF @v_count = 0
			BEGIN
			IF (SELECT DATEDIFF(dd, GetDate(), por_begindate) FROM partorder_routing WHERE por_identity = @v_porid) < @v_cutoff
				BEGIN
				SELECT @v_branch = ISNULL(poh_branch, '')
					, @v_mfst = ISNULL(poh_refnum, '')
					, @v_supplier = ISNULL(poh_supplier,'')
				FROM partorder_header
				WHERE poh_identity = @v_pohid
				SET @v_msg = 'No transaction match for part order.  Reference: ' + @v_mfst + '  Branch: ' + @v_branch + '  Supplier: ' + @v_supplier
				INSERT INTO tts_errorlog (
					  err_batch   
					, err_user_id 
					, err_message                                                                                                                                                                                                                                                    
					, err_date                                               
					, err_number  
					, err_title
					, err_type)
				VALUES (
					  0
					, @v_user
					, @v_msg
					, GETDATE()
					, 10110
					, 'link_partorder_OH'
					, 'TOM')
				END
			END
		ELSE IF @v_count > 1
			BEGIN
				SELECT @v_branch = ISNULL(poh_branch, '')
					, @v_mfst = ISNULL(poh_refnum, '')
					, @v_supplier = ISNULL(poh_supplier,'')
			FROM partorder_header
			WHERE poh_identity = @v_pohid
			SET @v_msg = 'Too many transaction matches for part order.  Reference: ' + @v_mfst + '  Branch: ' + @v_branch + '  Supplier: ' + @v_supplier
			INSERT INTO tts_errorlog (
				  err_batch   
				, err_user_id 
				, err_message                                                                                                                                                                                                                                                    
				, err_date                                               
				, err_number  
				, err_title
				, err_type)
			VALUES (
				  0
				, @v_user
				, @v_msg
				, GETDATE()
				, 10110
				, 'link_partorder_OH'
				, 'TOM')
			END
		ELSE
		begin
	
			select @sql = '', @sql1 = '', @sql2 = '', @sql3 = '', @sql4 = '', @sql5 = '', @sql6 = '', @sql7 = '', @sql8 = '', @sql9 = '', @sql10 = '', @sql11 = '', @sql20 = ''
		
			set @sql1 = N'SELECT @v_ordhdr = MIN(s.ord_hdrnumber) '
			set @sql2 = N'FROM stops s inner join orderheader oh1 on s.ord_hdrnumber = oh1.ord_hdrnumber '
			set @sql7 = N'AND pr.por_identity = ' + convert(varchar(15),@v_porid) + ' '

			--if isnull(@v_master_ordhdr, 0) > 0 
			--	set @sql20 = N'INNER JOIN orderheader oh2 on oh1.ord_fromorder = oh2.ord_number and oh2.ord_hdrnumber = pr.por_master_ordhdr '

			If @v_direction = 'P'
				begin
					set @sql3 = N'INNER JOIN partorder_routing pr on s.cmp_id = pr.por_origin '
					set @sql4 = N'WHERE ((s.stp_type = ''PUP'' or s.stp_type = ''CTR'') '
					set @sql5 = N'AND CAST(FLOOR(CAST(s.stp_schdtearliest AS float)) AS datetime) = CAST(FLOOR(CAST(pr.por_begindate AS float)) AS datetime) '
				end
			else
				begin
					set @sql3 = N'INNER JOIN partorder_routing pr on s.cmp_id = pr.por_destination '
					set @sql4 = N'WHERE ((s.stp_type = ''DRP'' or s.stp_type = ''CTR'') '
					set @sql5 = N'AND CAST(FLOOR(CAST(s.stp_schdtearliest AS float)) AS datetime) = CAST(FLOOR(CAST(pr.por_enddate AS float)) AS datetime) '
				end
		
			if @v_startedmethod = 'N'
			begin
				--set @sql6 = N'and ISNULL(por_ordhdr, 0) = 0 '
				set @sql8 = N'and oh1.ord_status IN (''AVL'', ''PLN'', ''DSP'') '
			end
		
			if @v_startedmethod in ('S','Y')
				set @sql9 = N'and oh1.ord_status IN (''AVL'', ''PLN'', ''STD'', ''DSP'') '
		
			if @v_startedmethod = 'S'
				set @sql6 = N'AND s.stp_status = ''OPN'' AND (select count(0) from stops s1 where s1.ord_hdrnumber = oh1.ord_hdrnumber AND s1.cmp_id = pr.por_origin AND s1.stp_type = ''PUP'' AND s1.stp_status = ''OPN'') > 0) '
			else
				set @sql6 = N') '

			--if isnull(@v_master_ordhdr, 0) = 0 
				set @sql10 = N'AND ord_route = ''' + @v_route + N''' '

			if @v_branch = '203'
				set @sql11 = N'AND oh1.ord_booked_revtype1 in (select alt_branch from altbranch where branch = ''203'') '
			else
				set @sql11 = N'and oh1.ord_booked_revtype1 = ''' + @v_branch + N''' '

			set @sql = @sql1 + isnull(@sql2,'') + isnull(@sql3,'') + isnull(@sql20,'') + isnull(@sql4,'') + isnull(@sql5,'') + isnull(@sql6,'') + isnull(@sql7,'') + isnull(@sql8,'') + isnull(@sql9,'') + isnull(@sql10, '') + isnull(@sql11, '')
	
			if @debug > 0 print @sql
			exec sp_executesql @sql,N'@v_ordhdr int output',@v_ordhdr output
			if @debug > 0 print 'Order :' + convert(varchar(20), @v_ordhdr)

			-- If there is no master order number get one from the order.
			if isnull(@v_master_ordhdr, 0) = 0 
				select 	@v_master_ordhdr = ord_fromorder from orderheader where ord_hdrnumber = @v_ordhdr

			if @History > 0
			BEGIN
				-- Create a routing history record
				Select @por_group_identity = max(por_group_identity) + 1 From partorder_routing_history
			
				Insert into partorder_routing_history(
					por_group_identity, 
					por_identity,     
					poh_identity,     
					por_master_ordhdr,
					por_ordhdr,     
					por_origin,     
					por_begindate,  
					por_destination,
					por_enddate,
					por_updatedby,
					por_updatedon,
					por_route,
					por_trl_unload_dt,
					por_sequence)

				Select	@por_group_identity, 
					por_identity,     
					poh_identity,     
					por_master_ordhdr,
					por_ordhdr,    	 
					por_origin,     
					por_begindate,  
					por_destination,
					por_enddate,
					por_updatedby,
					por_updatedon,
					por_route,
					por_trl_unload_dt,
					por_sequence
				From partorder_routing
				Where poh_identity = @v_pohid
					order by por_sequence
			END

			UPDATE partorder_routing
			SET por_ordhdr = @v_ordhdr,
				por_master_ordhdr = @v_master_ordhdr,
				por_updatedby = @v_user,
				por_updatedon = GETDATE()
			WHERE por_identity = @v_porid
		
		END
	END

END

GO
GRANT EXECUTE ON  [dbo].[link_partorder_OH] TO [public]
GO
