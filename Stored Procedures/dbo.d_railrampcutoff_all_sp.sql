SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_railrampcutoff_all_sp] 
as

declare @city	varchar(25),
		@li	int,
		@li_try	int,
		@new_try int,
		@cmp	varchar(8),
		@city_count	int

create table #temp (t_id int not null identity,
		crc_cutoff_time datetime null,
		crc_cutoff_day char(3) null,
		crc_equipmconfiguration varchar(6) null,
		crc_destination_city varchar(25) null,
		cmp_id	varchar(8) null,
		sort int null)

insert #temp
SELECT 	crc_cutoff_time,
		crc_cutoff_day,   
        crc_equipmconfiguration,   
        crc_destination_city ,
		cmp_id,
		sort = case  crc_cutoff_day
		when 'SUN' then 1
		when 'MON' then 2
		when 'TUE' then 3
		when 'WED' then 4
		when 'THU' then 5
		when 'FRI' then 6
		when 'SAT' then 7
	       end
FROM company_rail_cutoffs  
order by cmp_id, crc_destination_city, sort

--select * from #temp 

create table #count(c_id int not null identity,
		crc_destination_city varchar(25) null,
		cmp_id	varchar(8) null,
		count_1 int null)

insert #count
select distinct crc_destination_city, cmp_id,  count_1 = (count(*)/7) 
from company_rail_cutoffs 
group by cmp_id, crc_destination_city
order by cmp_id

--select * from #count

select @li = count(*) from #count
select @li_try = 1	

while @li_try  <= @li
Begin
	select @city = crc_destination_city, @city_count = count_1, @cmp = cmp_id 
	from #count 
	where c_id = @li_try

	If @city_count > 1
	begin
		select @new_try = 1
		while @new_try <= (@city_count * 7)
		begin
			update #temp  set sort = sort + 7
			where sort = @new_try and 
				crc_destination_city = @city and 
				cmp_id = @cmp and 
				crc_cutoff_day = (select min(e.crc_cutoff_day) 
						from #temp e , #temp t
						where e.t_id <> t.t_id and 
							e.crc_cutoff_day = t.crc_cutoff_day and
							e.crc_destination_city = t.crc_destination_city and 
							e.cmp_id = t.cmp_id and
							t.cmp_id = @cmp and 
							e.sort = t.sort and 
							t.sort = @new_try and 
							t.crc_destination_city = @city) and
				t_id not in (select min(t.t_id) 
						from #temp e , #temp t
						where e.t_id <> t.t_id and 
							e.crc_cutoff_day = t.crc_cutoff_day and
							e.crc_destination_city = t.crc_destination_city and 
							e.cmp_id = t.cmp_id and
							t.cmp_id = @cmp and 
							e.sort = t.sort and 
							t.sort = @new_try and 
							t.crc_destination_city = @city)
			
--			select * from #temp 
		
			select @new_try = @new_try + 1
		end
	end
	select @li_try = @li_try + 1
End

select crc_cutoff_time ,
		crc_cutoff_day,
		crc_equipmconfiguration,
		crc_destination_city,
		cmp_id,
		sort
from #temp 
order by cmp_id, crc_destination_city, sort

--drop table #temp
--drop table #count

GO
GRANT EXECUTE ON  [dbo].[d_railrampcutoff_all_sp] TO [public]
GO
