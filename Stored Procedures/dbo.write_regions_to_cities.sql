SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[write_regions_to_cities]  as

/**
 * DESCRIPTION:
 * 
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 01/02/2008.01 - PTS40830 - SLM  - Add Script that will update Legheader_active to the correct regions.  
 * 02/05/2012    - PTS60940 - CCI  - Changed ZIP logic to use pre-existing city zip index dk_company_zip to improve 
                                     performance.  Added company regions indexes to improve performance for all updates.  
                                     Broke up reset to UNK update at top into individual region 1,2,etc. updates to 
                                     improve performance.  These now use the new city regions indexes.  Added check for 'UNK' 
                                     in ACODE pre-partition counts (these were already included with the update statements).
                                     Added RegionUpdateBatchSize setting.
 *      
 *
 **/

declare @li_total int,
	@li_loops int,
	@li_batchsize int,
	@li_recordbatch int,
	@li_ctr int,
	@li_mod int, 
	@cty_zip_len int , 
	@zipdegree int 

-- Get length of cty_zip field dynamically, used for Regions definded by Partial Zip's
SELECT @cty_zip_len = syscolumns.length 
  FROM sysobjects 
       INNER JOIN syscolumns ON sysobjects.id = syscolumns.id 
 WHERE sysobjects.xtype='U' AND 
       sysobjects.name = 'city' AND 
       syscolumns.name = 'cty_zip' 

	/* PTS 16559 - DJM - Generalinfo setting to allow users to choose
		the priority when setting Regions.  
			Standard: The method used until this PTS.  Assigns based on State first, then Area Code then Zip.
			ZIP/AREA/STATE: Method that matches the Documentation. Uses the option with the most
					granularity to determine the Region (Zip first, then Area Code and State)		*/
	Declare @priority   varchar(25)
	select @priority = 'ORIGINAL'
	Select @priority = isNull(gi_string1,'ORIGINAL') from generalinfo where gi_name = 'RegionUpdatePriority'


--      debug table abc
--      create table abc(t_id int identity not null, t_dttm date not null, t_msg char(255) null)	
--	insert into abc(t_dttm,t_msg) values (getdate(),'PROC START')
	
	select @li_recordbatch = 100000
	-- PTS60940
	SELECT @li_recordbatch = ISNULL( CASE ISNUMERIC( gi_string1 ) WHEN 1 THEN CAST( gi_string1 AS INT ) ELSE @li_recordbatch END, @li_recordbatch ) 
	FROM generalinfo WHERE gi_name = 'RegionUpdateBatchSize'
	
	select @li_total = count(*) 
	from	city

	select @li_batchsize = @li_recordbatch
	select @li_loops = 1
	If @li_total <= @li_batchsize 
	   select @li_batchsize = 0
	else		
	begin
	  select @li_mod = @li_total % @li_batchsize
	  
	  If @li_mod = 0
	     select @li_loops = (@li_total / @li_batchsize)
	  Else
	     select @li_loops = (@li_total / @li_batchsize) + 1		
	end
	select @li_ctr = 0	
	
	
	while @li_ctr < @li_loops
	begin
		SET ROWCOUNT @li_batchsize 
		
		-- PTS60940 - broke into 4 separate updates to take advantage of new city regions indexes
		UPDATE city
		   SET cty_region1 = 'UNK' 
		 WHERE cty_region1 <> 'UNK' or cty_region1 is null 
		
		UPDATE city
		   SET cty_region2 = 'UNK' 
		 WHERE cty_region2 <> 'UNK' or cty_region2 is null 
		
		UPDATE city
		   SET cty_region3 = 'UNK' 
		 WHERE cty_region3 <> 'UNK' or cty_region3 is null 
		
		UPDATE city
		   SET cty_region4 = 'UNK' 
		 WHERE cty_region4 <> 'UNK' or cty_region4 is null 
		
		SET ROWCOUNT 0
		select @li_ctr = @li_ctr + 1
	end

--	insert into abc(t_dttm,t_msg) values (getdate(),'UNKNOWN OK')
--	select 'Done Set all to UNKNOWN'
-- Update region1 STATE
IF @priority = 'ORIGINAL'		
BEGIN
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 1 and
					c.cty_region1 = 'UNK'
				
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			
			--	select 'updating region1 STATE'	,@li_loops
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg1 state ')
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize	                                                                      
			
				update 	city 
				set 	cty_region1 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 1 and
					c.cty_region1 = 'UNK'
				set rowcount 0
				select @li_ctr = @li_ctr + 1
			
				end
			
			
			-- Update the State for type 2
			--	select 'updating region2 STATE'	,@li_loops
			--	insert into abc(t_dttm,t_msg) values (getdate(),'REG2 state')
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 2 and
					c.cty_region2 = 'UNK'
			
				select @li_batchsize = @li_recordbatch	
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
				
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
				update 	city 
				set 	cty_region2 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 2 and
					c.cty_region2 = 'UNK'
			
				set rowcount 0
				select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the State for type 3
				select @li_total =  count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 3 and
					c.cty_region3 = 'UNK'
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	select 'updating region3 STATE'	,@li_loops
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg3 state')
				
				while @li_ctr < @li_loops
				begin
			
				update 	city 
				set 	cty_region3 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 3 and
					c.cty_region3 = 'UNK'
			
				set rowcount 0
				select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the State for type 4
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 4 and
					c.cty_region4 = 'UNK'
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
			
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	select 'updating region4 STATE',@li_loops		
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg4 state')
				while @li_ctr < @li_loops
				begin
			
				update 	city 
				set 	cty_region4 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 4 and
					c.cty_region4 = 'UNK'
			
				set rowcount 0
				select @li_ctr = @li_ctr + 1
				end
			                                                                    
			
			                                                       
			-- Update the AreaCode for type 1
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 1 and 
					c.cty_region1 = 'UNK' 
				
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg1 code')	
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set	cty_region1 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 1 and
					c.cty_region1 = 'UNK'
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the AreaCode for type 2
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 2 and 
					c.cty_region2 = 'UNK' 
				
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg2 code')		
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set 	cty_region2 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 2 and
					c.cty_region2 = 'UNK'
			
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the AreaCode for type 3
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 3 and 
					c.cty_region3 = 'UNK' 
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg3 acode')		
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set 	cty_region3 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 3 and
					c.cty_region3 = 'UNK'
			
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the AreaCode for type 4
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 4 and 
					c.cty_region4 = 'UNK' 
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg4 acode')		
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set 	cty_region4 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 4 and
					c.cty_region4 = 'UNK'
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end
			
			-- PTS 60940 - added outer loop for zip updates to improve performance.
			-- Update the Zip for type 1
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 1 
				 WHERE c.cty_region1 = 'UNK'
				
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region1 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 1 
					 WHERE c.cty_region1 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			
			-- Update the Zip for type 2
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 2 
				 WHERE c.cty_region2 = 'UNK'
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region2 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 2 
					 WHERE c.cty_region2 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			
			-- Update the Zip for type 3
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 3 
				 WHERE c.cty_region3 = 'UNK'
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region3 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 3 
					 WHERE c.cty_region3 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			
			-- Update the Zip for type 4
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 4 
				 WHERE c.cty_region4 = 'UNK'
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region4 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 4 
					 WHERE c.cty_region4 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			
END
ELSE --ENHANCED PRIORITY
BEGIN
			-- PTS 60940 - added outer loop for zip updates to improve performance.
			
			-- Update the Zip for type 1
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 1 
				 WHERE c.cty_region1 = 'UNK'
				
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region1 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 1 
					 WHERE c.cty_region1 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			
			-- Update the Zip for type 2
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 2 
				 WHERE c.cty_region2 = 'UNK'
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region2 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 2 
					 WHERE c.cty_region2 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			
			-- Update the Zip for type 3
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 3 
				 WHERE c.cty_region3 = 'UNK'
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region3 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 3 
					 WHERE c.cty_region3 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			
			-- Update the Zip for type 4
			-- Loop through each degree of partial zips
			SET @zipdegree = @cty_zip_len 
			WHILE @zipdegree > 0 
			BEGIN 
				
				-- Partitional update into batches (just like above, but in one statement)
				SELECT @li_batchsize = CASE WHEN COUNT(*) <= @li_recordbatch THEN 0 ELSE @li_recordbatch END , 
				       @li_loops     = CASE WHEN COUNT(*) <= @li_recordbatch THEN 1 
				                            WHEN COUNT(*) % @li_recordbatch = 0 THEN COUNT(*) / @li_recordbatch 
				                            ELSE COUNT(*) / @li_recordbatch + 1 END , 
				       @li_ctr = 0 
				  FROM city c 
				       JOIN regiondetail d ON 
				            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
				            LEN( d.rgd_id ) = @zipdegree AND 
				            d.rgd_type = 'ZIP' 
				       JOIN regionheader h ON d.rgh_number = h.rgh_number AND h.rgh_type = 4 
				 WHERE c.cty_region4 = 'UNK'
				
				-- Update each partition
				WHILE @li_ctr < @li_loops 
				BEGIN
					
					SET ROWCOUNT @li_batchsize
					
					UPDATE city 
					   SET cty_region4 =  h.rgh_id 
					  FROM city c 
					       JOIN regiondetail d ON 
					            d.rgd_id = LEFT( c.cty_zip, @zipdegree )AND -- LEFT uses index on cmp_zip, LIKE does not
					            LEN( d.rgd_id ) = @zipdegree AND 
					            d.rgd_type = 'ZIP' 
					       JOIN regionheader h ON d.rgh_number = h.rgh_number AND 
					            h.rgh_type = 4 
					 WHERE c.cty_region4 = 'UNK'
					
					SET ROWCOUNT 0
					
					SET @li_ctr = @li_ctr + 1 
				END 
				
				-- Check less qualified partial zips
				SET @zipdegree = @zipdegree - 1
			END
			



			-- Update the AreaCode for type 1
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 1 and 
					c.cty_region1 = 'UNK' 
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg1 code')	
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set	cty_region1 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 1 and
					c.cty_region1 = 'UNK'
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the AreaCode for type 2
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 2 and 
					c.cty_region2 = 'UNK' 
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg2 code')		
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set 	cty_region2 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 2 and
					c.cty_region2 = 'UNK'
			
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the AreaCode for type 3
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 3 and 
					c.cty_region3 = 'UNK' 
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg3 acode')		
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set 	cty_region3 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 3 and
					c.cty_region3 = 'UNK'
			
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the AreaCode for type 4
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 4 and 
					c.cty_region4 = 'UNK' 
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg4 acode')		
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
			
				update 	city 
				set 	cty_region4 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_areacode = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'ACODE' and
					h.rgh_type = 4 and
					c.cty_region4 = 'UNK'
					set rowcount 0
					select @li_ctr = @li_ctr + 1
				end






				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 1 and
					c.cty_region1 = 'UNK'
				
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			
			--	select 'updating region1 STATE'	,@li_loops
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg1 state ')
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize	                                                                      
			
				update 	city 
				set 	cty_region1 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 1 and
					c.cty_region1 = 'UNK'
				set rowcount 0
				select @li_ctr = @li_ctr + 1
			
				end
			
			
			-- Update the State for type 2
			--	select 'updating region2 STATE'	,@li_loops
			--	insert into abc(t_dttm,t_msg) values (getdate(),'REG2 state')
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 2 and
					c.cty_region2 = 'UNK'
			
				select @li_batchsize = @li_recordbatch	
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
				
				while @li_ctr < @li_loops
				begin
				set rowcount @li_batchsize
				update 	city 
				set 	cty_region2 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 2 and
					c.cty_region2 = 'UNK'
			
				set rowcount 0
				select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the State for type 3
				select @li_total =  count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 3 and
					c.cty_region3 = 'UNK'
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	select 'updating region3 STATE'	,@li_loops
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg3 state')
				
				while @li_ctr < @li_loops
				begin
			
				update 	city 
				set 	cty_region3 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 3 and
					c.cty_region3 = 'UNK'
			
				set rowcount 0
				select @li_ctr = @li_ctr + 1
				end
			
			
			-- Update the State for type 4
				select @li_total = count(*) 
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 4 and
					c.cty_region4 = 'UNK'
			
				select @li_batchsize = @li_recordbatch
				select @li_loops = 1
			
				If @li_total <= @li_batchsize 
				   select @li_batchsize = 0
				else		
				begin
				  select @li_mod = @li_total % @li_batchsize
				  If @li_mod = 0
				     select @li_loops = (@li_total / @li_batchsize)
				  Else
				     select @li_loops = (@li_total / @li_batchsize) + 1		
				end
				select @li_ctr = 0	
			--	select 'updating region4 STATE',@li_loops		
			--	insert into abc(t_dttm,t_msg) values (getdate(),'reg4 state')
				while @li_ctr < @li_loops
				begin
			
				update 	city 
				set 	cty_region4 =  h.rgh_id
				from 	city c, regionheader h,  regiondetail d  
				where 	c.cty_state = d.rgd_id and
					h.rgh_number = d.rgh_number and
					d.rgd_type = 'STATE' and
					h.rgh_type = 4 and
					c.cty_region4 = 'UNK'
			
				set rowcount 0
				select @li_ctr = @li_ctr + 1
				end			
END --end enhanced mode

--	insert into abc(t_dttm,t_msg) values (getdate(),'PROC END')

-----------------------------
--BEGIN PTS40830 SLM 1/2/2008
-----------------------------
--If isnull((select count(*) from generalinfo where lower(gi_name) = 'updateregioninfo'),0) > 0
If upper((select gi_string1 from generalinfo where upper(gi_name) = 'UPDATEREGIONINFO')) = 'Y' 
BEGIN
	update 	legheader_active
	set	lgh_startregion1 = cty_region1
	from	legheader_active, city
	where	lgh_startcity = cty_code
		and lgh_startregion1 <> cty_region1 

	update 	legheader_active
	set	lgh_startregion2 = cty_region2
	from	legheader_active, city
	where	lgh_startcity = cty_code
		and lgh_startregion2 <> cty_region2

	update 	legheader_active
	set	lgh_startregion3 = cty_region3
	from	legheader_active, city
	where	lgh_startcity = cty_code
		and lgh_startregion3 <> cty_region3

	update 	legheader_active
	set	lgh_startregion4 = cty_region4
	from	legheader_active, city
	where	lgh_startcity = cty_code
		and lgh_startregion4 <> cty_region4  

	update 	legheader_active
	set	lgh_endregion1 = cty_region1
	from	legheader_active, city
	where	lgh_endcity = cty_code
		and lgh_endregion1 <> cty_region1 

	update 	legheader_active
	set	lgh_endregion2 = cty_region2
	from	legheader_active, city
	where	lgh_endcity = cty_code
		and lgh_endregion2 <> cty_region2

	update 	legheader_active
	set	lgh_endregion3 = cty_region3
	from	legheader_active, city
	where	lgh_endcity = cty_code
		and lgh_endregion3 <> cty_region3

	update 	legheader_active
	set	lgh_endregion4 = cty_region4
	from	legheader_active, city
	where	lgh_endcity = cty_code
		and lgh_endregion4 <> cty_region4
END
-----------------------------
--END PTS40830 SLM 1/2/2008
-----------------------------

                        
return

GO
GRANT EXECUTE ON  [dbo].[write_regions_to_cities] TO [public]
GO
