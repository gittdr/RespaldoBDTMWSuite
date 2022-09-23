SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 

--BEGIN PTS 52398 SPN
--Create procedure d_tar_tableratechange_sp (@ps_billto varchar(8), @ps_cmd_class varchar(8)) -- , @ps_origin_cmp varchar(8), @pi_origin_city int, @ps_dest_cmp varchar(8), @pi_dest_city int)
CREATE PROCEDURE [dbo].[d_tar_tableratechange_sp]
( @ps_billto	                  VARCHAR(8)
, @ps_cmd_class                  VARCHAR(8)
, @ps_tariffkey_trk_enddate_type CHAR(1)
)
--END PTS 52398 SPN
as

create table #temp(tar_number int not  null,tar_rowbasis varchar(6) not null , tar_colbasis varchar(6) not null,cmd_class varchar(8) null)
create table #tempmain (set_number int not null, tar_number int not  null,tar_rowbasis varchar(6)not null, tar_colbasis varchar(6) not null,
						 trc_matchvaluerow varchar(50) null, trc_matchvaluecol varchar(50) null,cmd_class varchar(8) null, tra_rate money null,
						 trc_number_row int null, trc_number_col int null, trc_sequencerow int null , trc_sequencecol int null, 
						 tra_apply char(1) null, tra_retired char(1) null, tra_activedate datetime null, cty_nmstctrow varchar(30) null,
						 cty_nmstctcol varchar(30) null,
						tar_number1 int null, tra_rate1 money null,cmd_class1 varchar(8) null, 
						tar_number2 int null, tra_rate2 money null,cmd_class2 varchar(8) null,
						tar_number3 int null, tra_rate3 money null,cmd_class3 varchar(8) null, 
						tar_number4 int null, tra_rate4 money null,cmd_class4 varchar(8) null,
						trc_number_row1 int null,trc_number_col1 int null,
						trc_number_row2 int null, trc_number_col2 int null,
						trc_number_row3 int null, trc_number_col3 int null,
						trc_number_row4 int null, trc_number_col4 int null,
						tar_number_billmiles int null,				-- pts 48777
						tra_billmiles money null,					-- pts 48777
						tar_number_toll_charge int null,			-- pts 48777
						toll_charge money null,						-- pts 48777
						-----------------------
						toll_trc_number_row int null,				-- pts 48777
						toll_trc_number_col int null,				-- pts 48777						
						--------------------------------------------------------
						
						tar_number_pump_charge int null,			-- pts 48777
						pump_charge money null,						-- pts 48777
						-----------------------
						pump_trc_number_row int null,				-- pts 48777
						pump_trc_number_col int null,				-- pts 48777		
						--------------------------------------------------------												
						tar_minquantity  dec(19,4),					    -- pts 48777
						tar_minquantity_1  dec(19,4),					-- pts 48777
						tar_minquantity_2  dec(19,4),					-- pts 48777
						tar_minquantity_3  dec(19,4),					-- pts 48777
						tar_minquantity_4  dec(19,4),				    -- pts 48777
						flag_newrow  char(1),							-- pts 48777
						flag_newcol char(1),							-- pts 48777
						flag_ADDorINS char(1),							-- pts 48777
						tra_rateasflat char(1),							-- pts 48777
						flag_AddGroup int null						    -- pts 48777
)						


create table #matchfind (trc_rowcolumn char(1) not null ,trc_sequence int not null, trc_matchvalue varchar(50) null,trc_rangevalue money null)

--BEGIN PTS 52398 SPN
declare @ldtm_enddate_from  DATETIME
declare @ldtm_enddate_to    DATETIME

If @ps_tariffkey_trk_enddate_type = 'A'      --tariffkey.trk_enddate Range for Active
   select @ldtm_enddate_from = getdate()
        , @ldtm_enddate_to = NULL
else
   if @ps_tariffkey_trk_enddate_type = 'I'   --tariffkey.trk_enddate Range for Inactive
      select @ldtm_enddate_from = NULL
           , @ldtm_enddate_to = getdate()
   else                                      --tariffkey.trk_enddate Range for All
      select @ldtm_enddate_from = NULL
           , @ldtm_enddate_to = NULL
--END PTS 52398 SPN

if @ps_cmd_class = 'UNKNOWN'
	insert into #temp
	select distinct tariffheader.tar_number,tariffheader.tar_rowbasis,tariffheader.tar_colbasis,tariffkey.cmd_class
	from tariffkey join tariffheader on tariffkey.tar_number = tariffheader.tar_number 
	where	trk_billto = @ps_billto and tar_rowbasis in ('OCT','OCM','DCT','DCM') and tar_colbasis in ('OCT','OCM','DCT','DCM')
			and tariffkey.cmd_class <> 'UNKNOWN'
			and tariffkey.trk_primary = 'Y'			-- PTS 48777
         --BEGIN PTS 52398 SPN
         AND (tariffkey.trk_enddate >= @ldtm_enddate_from or @ldtm_enddate_from IS NULL)
         AND (tariffkey.trk_enddate <= @ldtm_enddate_to or @ldtm_enddate_to IS NULL)
         --END PTS 52398 SPN
else
	insert into #temp
	select distinct tariffheader.tar_number,tariffheader.tar_rowbasis,tariffheader.tar_colbasis,@ps_cmd_class from tariffkey 
	join tariffheader on tariffkey.tar_number = tariffheader.tar_number 
where
	trk_billto = @ps_billto and
	cmd_class = @ps_cmd_class and
	tar_rowbasis in ('OCT','OCM','DCT','DCM') and tar_colbasis in ('OCT','OCM','DCT','DCM')
	and tariffkey.trk_primary = 'Y'		-- PTS 48777
   --BEGIN PTS 52398 SPN
   AND (tariffkey.trk_enddate >= @ldtm_enddate_from or @ldtm_enddate_from IS NULL)
   AND (tariffkey.trk_enddate <= @ldtm_enddate_to or @ldtm_enddate_to IS NULL)
   --END PTS 52398 SPN
	
--select * from #temp
--select * from tariffrowcolumn
-- select * from tariffheader
--select * from labelfile where labeldefinition = 'TariffBasisInv'

declare @li_tar int ,@li_ctr int
declare @ls_cmd_class varchar(8) 
select @li_tar = 0,@li_ctr = 0

select  top 1 @ls_cmd_class =cmd_class from #temp group by cmd_class order by count(*) desc
while 1=1
begin
	select @li_ctr = @li_ctr + 1
	select @li_tar = min(tar_number) from #temp where tar_number > @li_tar and cmd_class = @ls_cmd_class
	if @li_tar is null
		break
	
	insert into #tempmain
	SELECT  @li_Ctr ,tariffrow.tar_number,
			#temp.tar_rowbasis,
			#temp.tar_colbasis,
			tariffrow.trc_matchvalue trc_matchvaluerow, 
			tariffcolumn.trc_matchvalue trc_matchvaluecol, 
		#temp.cmd_class,
		tariffrate.tra_rate,
		tariffrate.trc_number_row,
		tariffrate.trc_number_col,
	--	tariffrate.tar_number,
		tariffrow.trc_sequence trc_sequencerow,
		tariffcolumn.trc_sequence trc_sequencecol,
		tra_apply,
		tra_retired,
		tra_activedate,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		tariffrow.tar_number as 'tar_number_billmiles', 					-- PTS 48777
		isnull(tariffrate.tra_billmiles, 0)	'tariffrate.tra_billmiles',		-- PTS 48777
		NULL,  -- tar_number_toll_charge									-- pts 48777
		NULL,  -- toll_charge 												-- pts 48777
		NULL,  -- toll_trc_number_row 	-----------							-- pts 48777
		NULL,  -- toll_trc_number_col 	-----------							-- pts 48777		
		NULL,  -- tar_number_pump_charge									-- PTS 48777
		NULL,  -- pump_charge 												-- PTS 48777
		NULL,  -- pump_trc_number_row 	-----------							-- pts 48777
		NULL,  -- pump_trc_number_col 	-----------							-- pts 48777													
		NULL,  -- tar_minquantity											-- pts 48777
		NULL,  -- tar_minquantity_1											-- pts 48777	
		NULL,  -- tar_minquantity_2											-- pts 48777	
		NULL,  -- tar_minquantity_3											-- pts 48777	
		NULL,  -- tar_minquantity_4											-- pts 48777	
		'N',   -- flag_newrow 												-- pts 48777
		'N',   -- flag_newcol 												-- pts 48777
		NULL,   -- flag_ADDorINS 											-- pts 48777
		tra_rateasflat,														-- pts 48777
		NULL     -- flag_AddGroup 											-- pts 48777
	
	FROM tariffrate 
		INNER join tariffrowcolumn as tariffrow on tariffrate.trc_number_row = tariffrow.trc_number
		INNER join tariffrowcolumn as tariffcolumn on tariffrate.trc_number_col = tariffcolumn.trc_number	
		INNER join #temp on tariffrate.tar_number = #temp.tar_number
	where #temp.tar_number =@li_tar
	order by tariffrow.tar_number, 	tariffrow.trc_sequence,
		tariffcolumn.trc_sequence
end


--now get the other commodity classes
declare @ls_cmd_class_hold varchar(8)
select @ls_cmd_class_hold = min(cmd_class) from #tempmain
select @ls_cmd_class =''
select @li_ctr = 0
while 1 = 1
begin
	select @ls_cmd_class = min(cmd_class) from #temp where cmd_class > @ls_cmd_class and cmd_class <> @ls_cmd_class_hold
	if @ls_cmd_class is null
		break
	select @li_ctr = @li_ctr + 1
	if @li_ctr = 1 
		update #tempmain set cmd_class1 = @ls_cmd_class 
	else if @li_ctr = 2
		update #tempmain set cmd_class2 = @ls_cmd_class 
	else if @li_ctr = 3
		update #tempmain set cmd_class3 = @ls_cmd_class 
	else if @li_ctr = 4
		update #tempmain set cmd_class4 = @ls_cmd_class 
	else
		break

end

--==================================--==================================--==================================
-- PTS 48777 << start >>
declare @TOLL_Charge_types varchar(100)
declare @PUMP_Charge_types varchar(100)

IF exists (select 1 from generalinfo where gi_name = 'MassTableRateChange') 
BEGIN 
	Set @TOLL_Charge_types = (select gi_string1 from generalinfo where gi_name = 'MassTableRateChange' and LEN(gi_string1)> 0 )
	Set @PUMP_Charge_types = (select gi_string2 from generalinfo where gi_name = 'MassTableRateChange' and LEN(gi_string2)> 0 )
END

IF LEN(@TOLL_Charge_types) <= 0  OR @TOLL_Charge_types is null 
	Set @TOLL_Charge_types = ''
	
IF LEN(@TOLL_Charge_types) > 0 	
	Set @TOLL_Charge_types = ',' + @TOLL_Charge_types + ','	
		
IF LEN(@PUMP_Charge_types) <= 0	 OR @PUMP_Charge_types is null 
	Set @PUMP_Charge_types = ''	
	
IF LEN(@PUMP_Charge_types) > 0	
	Set @PUMP_Charge_types = ',' + @PUMP_Charge_types + ','		

--==================================
--Insert into #TOLLS_and_PUMPS (set_number, Primary_tar_number)
--select set_number, tar_number from #tempmain
--group by set_number, tar_number

create table #Primary_Tariffs (set_number int not null, 
							   Primary_tar_number int not null, 
							   toll_rate int, toll_row_number int, 							
							   pump_rate int, pump_row_number int)							   

create table #TOLLS_and_PUMPS(set_number int,
							  Primary_tar_number int not  null,
							  Secondary_tar_number int ,
							  secondary_cht_itemcode varchar(8) , 
							  tar_rowbasis varchar(6) , 
							  tar_colbasis varchar(6),							 
							  taa_seq int,
							  to_keep char(1) , 
							  v_row_number INT IDENTITY(1,1)  )							   
							  

Insert into #Primary_Tariffs (set_number, Primary_tar_number)
select set_number, tar_number from #tempmain
group by set_number, tar_number

Insert into #TOLLS_and_PUMPS (set_number, Primary_tar_number, Secondary_tar_number, taa_seq , secondary_cht_itemcode, tar_rowbasis, tar_colbasis) 
select 0,
tariffaccessorial.tar_number , tariffkey.tar_number , tariffaccessorial.taa_seq, 
tariffheader.cht_itemcode, tariffheader.tar_rowbasis,tariffheader.tar_colbasis
from tariffkey, tariffaccessorial, tariffheader
where tariffkey.trk_number = tariffaccessorial.trk_number
and tariffkey.trk_number in (select trk_number from  tariffaccessorial where tar_number in ( select Primary_tar_number from #Primary_Tariffs)  )
and tariffheader.tar_number = tariffkey.tar_number
--BEGIN PTS 52398 SPN
AND (tariffkey.trk_enddate >= @ldtm_enddate_from or @ldtm_enddate_from IS NULL)
AND (tariffkey.trk_enddate <= @ldtm_enddate_to or @ldtm_enddate_to IS NULL)
--END PTS 52398 SPN
order by tariffaccessorial.tar_number, tariffaccessorial.taa_seq

update #TOLLS_and_PUMPS
set set_number = (select min(set_number) from #tempmain where #tempmain.tar_number = #TOLLS_and_PUMPS.Primary_tar_number) 

update #TOLLS_and_PUMPS
set secondary_cht_itemcode = LTRIM(RTRIM(secondary_cht_itemcode)) + ','

update #TOLLS_and_PUMPS
set to_keep  = 'T'
where charindex((rtrim(secondary_cht_itemcode)), @TOLL_Charge_types ,1) > 0 

update #TOLLS_and_PUMPS
set to_keep  = 'P'
where charindex((rtrim(secondary_cht_itemcode)), @PUMP_Charge_types ,1) > 0 


delete from #TOLLS_and_PUMPS where to_keep  is null


update #Primary_Tariffs
set toll_rate = (select Secondary_tar_number from #TOLLS_and_PUMPS 
						where #Primary_Tariffs.Primary_tar_number = #TOLLS_and_PUMPS.Primary_tar_number
						and  to_keep  = 'T' and taa_seq = (select MIN(taa_seq) from #TOLLS_and_PUMPS where 
													         #Primary_Tariffs.Primary_tar_number = #TOLLS_and_PUMPS.Primary_tar_number
																and  to_keep  = 'T' ) 	) 	
																
update #Primary_Tariffs
set toll_row_number = (select v_row_number from 	#TOLLS_and_PUMPS 
						where #Primary_Tariffs.Primary_tar_number = #TOLLS_and_PUMPS.Primary_tar_number
						and   #Primary_Tariffs.toll_rate  = #TOLLS_and_PUMPS.Secondary_tar_number 
						and   #Primary_Tariffs.set_number  = #TOLLS_and_PUMPS.set_number
						and   to_keep  = 'T') 												
											
update #Primary_Tariffs
set pump_rate = (select Secondary_tar_number from #TOLLS_and_PUMPS 
						where #Primary_Tariffs.Primary_tar_number = #TOLLS_and_PUMPS.Primary_tar_number
						and  to_keep  = 'P' and taa_seq = (select MIN(taa_seq) from #TOLLS_and_PUMPS where 
													         #Primary_Tariffs.Primary_tar_number = #TOLLS_and_PUMPS.Primary_tar_number
																and  to_keep  = 'P' ) 	) 	
update #Primary_Tariffs
set pump_row_number = (select v_row_number from 	#TOLLS_and_PUMPS 
						where #Primary_Tariffs.Primary_tar_number = #TOLLS_and_PUMPS.Primary_tar_number
						and   #Primary_Tariffs.pump_rate  = #TOLLS_and_PUMPS.Secondary_tar_number 
						and   #Primary_Tariffs.set_number  = #TOLLS_and_PUMPS.set_number
						and   to_keep  = 'P') 																											


																													
delete from #TOLLS_and_PUMPS where to_keep  = 'T' and 	v_row_number not in (select toll_row_number from #Primary_Tariffs)	
delete from #TOLLS_and_PUMPS where to_keep  = 'P' and 	v_row_number not in (select pump_row_number from #Primary_Tariffs)	
						
	
-- PTS 48777 << end >>
--==================================
--==================================--==================================--==================================


-- now loop through #tempmain and #temp to find the table rates for the commodities that match with the main tariff
declare @li_set int,@li_tar_match int ,@ls_rowbasis varchar(6),@ls_colbasis varchar(6),@ls_cmd_match varchar(8)
declare @li_count int ,@li_countrecords int,@li_countunion int
declare @li_counttollpumprecords int		-- technology failure fix <<12-9-2009>>

select @li_set = 0
while 1 = 1
begin
	select @li_set = min(set_number) from #tempmain where set_number > @li_set
	if @li_set is null
		break

	select @li_tar = min(tar_number),@ls_cmd_class = min(cmd_class) from #tempmain where set_number = @li_set
	select @ls_rowbasis = tar_rowbasis,@ls_colbasis = tar_colbasis from #temp where tar_number = @li_tar		
	-- for this tariff find a table from #temp that has a similar combination of rows and columns,identical table would be the best
	select @li_tar_match = 0
	while 2 = 2
	begin	
		select @li_tar_match = min(tar_number) from #temp 
		where tar_number > @li_tar_match and tar_rowbasis = @ls_rowbasis and tar_colbasis =@ls_colbasis and cmd_class <> @ls_cmd_class
		if @li_tar_match is null
			break

		select @ls_cmd_match = cmd_class from #temp where tar_number = @li_tar_match
		select @li_countrecords = count(*) from tariffrowcolumn where tar_number = @li_tar
		
		delete #matchfind
	
		insert into #matchfind	
		SELECT trc_rowcolumn,trc_sequence, trc_matchvalue,trc_rangevalue from tariffrowcolumn where tar_number = @li_tar
			union 
		SELECT trc_rowcolumn,trc_sequence, trc_matchvalue,trc_rangevalue from tariffrowcolumn where tar_number = @li_tar_match
	
		select 	@li_countunion = count(*) from #matchfind

		if @li_countrecords = @li_countunion
		begin
			if exists (select * from #tempmain where cmd_class1 = @ls_cmd_match)
				update 	#tempmain
				set 	tar_number1 = @li_tar_match, tra_rate1= tariffrate.tra_rate,
						trc_number_row1 = tariffrate.trc_number_row,trc_number_col1 = tariffrate.trc_number_col
				FROM 	tariffrate , tariffrowcolumn as tariffrow ,tariffrowcolumn as tariffcolumn
				WHERE   set_number = @li_set and 
						tariffrate.trc_number_row = tariffrow.trc_number and
						tariffrate.trc_number_col = tariffcolumn.trc_number	and
						tariffrate.tar_number = @li_tar_match and
						tariffrow.trc_matchvalue = #tempmain.trc_matchvaluerow and
						tariffcolumn.trc_matchvalue =#tempmain.trc_matchvaluecol and
						tariffrow.trc_sequence =#tempmain.trc_sequencerow and
						tariffcolumn.trc_sequence =#tempmain.trc_sequencecol
				
			else if exists (select * from #tempmain where cmd_class2 = @ls_cmd_match)

				update 	#tempmain
				set 	tar_number2 = @li_tar_match, tra_rate2= tariffrate.tra_rate,
						trc_number_row2 = tariffrate.trc_number_row,trc_number_col2 = tariffrate.trc_number_col
				FROM 	tariffrate , tariffrowcolumn as tariffrow ,tariffrowcolumn as tariffcolumn
				WHERE   set_number = @li_set and 
						tariffrate.trc_number_row = tariffrow.trc_number and
						tariffrate.trc_number_col = tariffcolumn.trc_number	and
						tariffrate.tar_number = @li_tar_match and
						tariffrow.trc_matchvalue = #tempmain.trc_matchvaluerow and
						tariffcolumn.trc_matchvalue =#tempmain.trc_matchvaluecol and
						tariffrow.trc_sequence =#tempmain.trc_sequencerow and
						tariffcolumn.trc_sequence =#tempmain.trc_sequencecol

			else if exists (select * from #tempmain where cmd_class3 = @ls_cmd_match)
				update 	#tempmain
				set 	tar_number3 = @li_tar_match, tra_rate3= tariffrate.tra_rate,
						trc_number_row3 = tariffrate.trc_number_row,trc_number_col3 = tariffrate.trc_number_col
				FROM 	tariffrate , tariffrowcolumn as tariffrow ,tariffrowcolumn as tariffcolumn
				WHERE   set_number = @li_set and 
						tariffrate.trc_number_row = tariffrow.trc_number and
						tariffrate.trc_number_col = tariffcolumn.trc_number	and
						tariffrate.tar_number = @li_tar_match and
						tariffrow.trc_matchvalue = #tempmain.trc_matchvaluerow and
						tariffcolumn.trc_matchvalue =#tempmain.trc_matchvaluecol and
						tariffrow.trc_sequence =#tempmain.trc_sequencerow and
						tariffcolumn.trc_sequence =#tempmain.trc_sequencecol

			else if exists (select * from #tempmain where cmd_class4 = @ls_cmd_match)
				update 	#tempmain
				set 	tar_number4 = @li_tar_match, tra_rate4= tariffrate.tra_rate,
						trc_number_row4 = tariffrate.trc_number_row,trc_number_col4 = tariffrate.trc_number_col
				FROM 	tariffrate , tariffrowcolumn as tariffrow ,tariffrowcolumn as tariffcolumn
				WHERE   set_number = @li_set and 
						tariffrate.trc_number_row = tariffrow.trc_number and
						tariffrate.trc_number_col = tariffcolumn.trc_number	and
						tariffrate.tar_number = @li_tar_match and
						tariffrow.trc_matchvalue = #tempmain.trc_matchvaluerow and
						tariffcolumn.trc_matchvalue =#tempmain.trc_matchvaluecol and
						tariffrow.trc_sequence =#tempmain.trc_sequencerow and
						tariffcolumn.trc_sequence =#tempmain.trc_sequencecol	

		end		--count=union for 2=2
	end			-- 2 = 2
		
		set @li_tar_match = 0
		set @li_countrecords = 0
		set @li_countunion = 0
		while 3=3
		begin
		
		select @li_tar_match = min(Secondary_tar_number) 
		from #TOLLS_and_PUMPS
		where Secondary_tar_number > @li_tar_match and @li_set = set_number and @li_tar = Primary_tar_number and to_keep = 'T'
							
			if @li_tar_match is null
				break
		
				select @li_countrecords = count(*) from tariffrowcolumn where tar_number = @li_tar
				select @li_counttollpumprecords  = count(*) from tariffrowcolumn where tar_number = @li_tar_match  -- technology failure fix <<12-9-2009>>
		
				delete #matchfind
		
				insert into #matchfind	
				SELECT trc_rowcolumn,trc_sequence, trc_matchvalue,trc_rangevalue from tariffrowcolumn where tar_number = @li_tar
				-- <<12-7-2009 fix>>
				-- technology failure fix <<12-9-2009>>				
				--intersect   CAN'T USE INTERSECT --- OLDER DATABASEs don't understand the operator. (go back to union)
				union 
				SELECT trc_rowcolumn,trc_sequence, trc_matchvalue,trc_rangevalue from tariffrowcolumn where tar_number = @li_tar_match
		
				select 	@li_countunion = count(*) from #matchfind			
				
				-- if @li_countrecords = @li_countunion  -- technology failure fix <<12-9-2009>>
				if ( @li_countrecords = @li_countunion )   AND ( @li_countrecords = @li_counttollpumprecords ) 
					begin			
							update 	#tempmain
							set 	tar_number_toll_charge = @li_tar_match, 
									toll_charge= tariffrate.tra_rate,
									toll_trc_number_row = tariffrate.trc_number_row,
									toll_trc_number_col = tariffrate.trc_number_col
							FROM 	tariffrate , tariffrowcolumn as tariffrow ,tariffrowcolumn as tariffcolumn
							WHERE   set_number = @li_set and 
									tariffrate.trc_number_row = tariffrow.trc_number and
									tariffrate.trc_number_col = tariffcolumn.trc_number	and
									tariffrate.tar_number = @li_tar_match and
									tariffrow.trc_matchvalue = #tempmain.trc_matchvaluerow and
									tariffcolumn.trc_matchvalue =#tempmain.trc_matchvaluecol and
									tariffrow.trc_sequence =#tempmain.trc_sequencerow and
									tariffcolumn.trc_sequence =#tempmain.trc_sequencecol
					end	 --count=union for 3=3
		end ---3 = 3
	---------------------------	
		set @li_tar_match = 0
		set @li_countrecords = 0
		set @li_countunion = 0
		while 4=4
		begin
		
		select @li_tar_match = min(Secondary_tar_number) 
		from #TOLLS_and_PUMPS
		where Secondary_tar_number > @li_tar_match and @li_set = set_number and @li_tar = Primary_tar_number and to_keep = 'P'	
			
			if @li_tar_match is null
				break
		
				select @li_countrecords = count(*) from tariffrowcolumn where tar_number = @li_tar
				select @li_counttollpumprecords  = count(*) from tariffrowcolumn where tar_number = @li_tar_match  -- technology failure fix <<12-9-2009>>
		
				delete #matchfind
		
				insert into #matchfind	
				SELECT trc_rowcolumn,trc_sequence, trc_matchvalue,trc_rangevalue from tariffrowcolumn where tar_number = @li_tar
				-- <<12-7-2009 fix>>
				-- technology failure fix <<12-9-2009>>				
				--intersect   CAN'T USE INTERSECT --- OLDER DATABASEs don't understand the operator. (go back to union)
				union 
				SELECT trc_rowcolumn,trc_sequence, trc_matchvalue,trc_rangevalue from tariffrowcolumn where tar_number = @li_tar_match
		
				select 	@li_countunion = count(*) from #matchfind		
				
				-- if @li_countrecords = @li_countunion  -- technology failure fix <<12-9-2009>>
				if ( @li_countrecords = @li_countunion )   AND ( @li_countrecords = @li_counttollpumprecords ) 
					begin			
							update 	#tempmain
							set 	tar_number_pump_charge = @li_tar_match, 
									pump_charge= tariffrate.tra_rate,
									pump_trc_number_row = tariffrate.trc_number_row,
									pump_trc_number_col = tariffrate.trc_number_col
							FROM 	tariffrate , tariffrowcolumn as tariffrow ,tariffrowcolumn as tariffcolumn
							WHERE   set_number = @li_set and 
									tariffrate.trc_number_row = tariffrow.trc_number and
									tariffrate.trc_number_col = tariffcolumn.trc_number	and
									tariffrate.tar_number = @li_tar_match and
									tariffrow.trc_matchvalue = #tempmain.trc_matchvaluerow and
									tariffcolumn.trc_matchvalue =#tempmain.trc_matchvaluecol and
									tariffrow.trc_sequence =#tempmain.trc_sequencerow and
									tariffcolumn.trc_sequence =#tempmain.trc_sequencecol
					end	 --count=union for 4=4
		end -- end 4=4
				
---------------------------		
	-----------------break
	
end				-- 1 = 1


---------------  << 12-7-09  Fix extraneous commodity code condition -- start >> ---------
declare @ll_rowcount int
set @ll_rowcount =  ( select count(*) from #tempmain  ) 

IF ( select count(cmd_class1) from #tempmain where tra_rate1 is null and cmd_class1 is NOT null ) > 0 
begin
	IF ( select count(cmd_class1) from #tempmain where tra_rate1 is null and cmd_class1 is NOT null ) = @ll_rowcount
	begin
		update #tempmain
		set cmd_class1 = null 
	end
end

IF ( select count(cmd_class2) from #tempmain where tra_rate2 is null and cmd_class2 is NOT null ) > 0 
begin
	IF ( select count(cmd_class2) from #tempmain where tra_rate2 is null and cmd_class2 is NOT null ) = @ll_rowcount
	begin
		update #tempmain
		set cmd_class2 = null 
	end
end

IF ( select count(cmd_class3) from #tempmain where tra_rate3 is null and cmd_class3 is NOT null ) > 0 
begin
	IF ( select count(cmd_class3) from #tempmain where tra_rate3 is null and cmd_class3 is NOT null ) = @ll_rowcount
	begin
		update #tempmain
		set cmd_class3 = null 
	end
end

IF ( select count(cmd_class4) from #tempmain where tra_rate4 is null and cmd_class4 is NOT null ) > 0 
begin
	IF ( select count(cmd_class4) from #tempmain where tra_rate4 is null and cmd_class4 is NOT null ) = @ll_rowcount
	begin
		update #tempmain
		set cmd_class4 = null 
	end
end
---------------  << 12-7-09  extraneous commodity -- end  >> ---------


update #tempmain 
set cty_nmstctrow = city.cty_nmstct
from city
where #tempmain.tar_rowbasis in ('OCT','DCT') and
	  #tempmain.trc_matchvaluerow = city.cty_code


update #tempmain 
set cty_nmstctcol = city.cty_nmstct
from city
where #tempmain.tar_colbasis in ('OCT','DCT') and
	  #tempmain.trc_matchvaluecol = city.cty_code


update #tempmain 
set  #tempmain.trc_matchvaluerow = null
where #tempmain.tar_rowbasis in ('OCT','DCT')
	  
update #tempmain 
set  #tempmain.trc_matchvaluecol = null
where #tempmain.tar_colbasis in ('OCT','DCT')




-- 42814 added code JD
update #tempmain 
set cty_nmstctrow = company.cty_nmstct 
from company
where #tempmain.tar_rowbasis in ('OCM','DCM') and
	  #tempmain.trc_matchvaluerow = company.cmp_id

update #tempmain 
set cty_nmstctcol = company.cty_nmstct 
from company
where #tempmain.tar_colbasis in ('OCM','DCM') and
	  #tempmain.trc_matchvaluecol = company.cmp_id


-- PTS 48777 -- start -- supply the MIN Quantity
update #tempmain
set tar_minquantity = tariffheader.tar_minquantity
from tariffheader where 
#tempmain.tar_number = tariffheader.tar_number

update #tempmain
set tar_minquantity_1 = tariffheader.tar_minquantity
from tariffheader where 
#tempmain.tar_number1 = tariffheader.tar_number

update #tempmain
set tar_minquantity_2 = tariffheader.tar_minquantity
from tariffheader where 
#tempmain.tar_number2 = tariffheader.tar_number

update #tempmain
set tar_minquantity_3 = tariffheader.tar_minquantity
from tariffheader where 
#tempmain.tar_number3 = tariffheader.tar_number

update #tempmain
set tar_minquantity_4 = tariffheader.tar_minquantity
from tariffheader where 
#tempmain.tar_number4 = tariffheader.tar_number
-- PTS 48777 -- end MIN Quantity

select * from #tempmain

GO
GRANT EXECUTE ON  [dbo].[d_tar_tableratechange_sp] TO [public]
GO
