SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[railramp_schedules_sp] (@asshipper	varchar(8),
									@consignee	varchar(8),
									@rail_dest	varchar(25),
									@config		varchar(6),
									@avl_date	datetime)
as

Declare		@lead_time	int,
			@cutoff		datetime, 
			@pickup		datetime, 
			@latest_pickup	datetime, 
			@latest_drop	datetime,
			@defailt_lead	int,
			@cutoff_day	char(3),
			@new_avl	datetime,
			@min_cutoff	datetime,
			@min_cutoff_year varchar(10),
			@li_try		int,
			@adj_time	datetime,
			@li		int

If (select count(*) 
	from company
	where cmp_id = @consignee and
			cmp_railramp = 'Y') > 0
Begin

select @defailt_lead = IsNull(gi_integer1, 2) 
from generalinfo 
where gi_name = 'RailRampSchedules'

select @lead_time = IsNull(cmp_leadtime, @defailt_lead) 
from company
where cmp_id = @asshipper

select @adj_time = DateAdd(Hour, @lead_time, @avl_date)

select @li_try = 0	
while @li_try  <= 7
Begin
--	select @adj_time

	select @min_cutoff = min(crc_cutoff_time)
	from company_rail_cutoffs
	where ((crc_equipmconfiguration = 'B' and @config in ('U', 'S', 'Z', 'JBHU')) or
		 (crc_equipmconfiguration = 'C' and @config in ('U', 'S')) or
		 (crc_equipmconfiguration = 'T' and @config in ('Z', 'JBHU'))) and 
		crc_destination_city = @rail_dest and 
		cmp_id = @consignee and 
		crc_cutoff_day = Substring(Upper(datename(weekday, @adj_time)), 1, 3) and
		(convert(int, (substring(convert(char, crc_cutoff_time, 120), 12, 2))) > convert(int, (substring(convert(char, @adj_time, 120), 12, 2) )) or
		(convert(int, (substring(convert(char, crc_cutoff_time, 120), 12, 2))) = convert(int, (substring(convert(char, @adj_time, 120), 12, 2) )) and
		convert(int, (substring(convert(char, crc_cutoff_time, 120), 15, 2))) > convert(int, (substring(convert(char, @adj_time, 120), 15, 2) )) ))
	
--	select @min_cutoff
--	select @min_cutoff_year = substring(convert(char, @min_cutoff, 120), 1, 10)
--	select @min_cutoff_year
--	If (select IsNull(@min_cutoff_year, '1899-12-31')) = '1900-01-01'
	If @min_cutoff is not null
		select @li_try = 8
	Else
		begin
		IF 	@li_try = 0 
			select @li = @li_try
		else
			select @li = 1
		select @adj_time = convert(datetime, convert(char, dateAdd(Day, @li, @adj_time), 120)) +
			(convert(datetime, convert(char, '1-1-1900 23:00:00', 8)) - 
			 convert(datetime, convert(char, DateAdd(Hour, (- 1), @adj_time), 8)))
		select @li_try = @li_try + 1
--		select @adj_time, @li_try
		end
End

--If @min_cutoff_year = '1900-01-01'
If @min_cutoff is not null
Begin
	select @cutoff = @min_cutoff
	Select @new_avl = @adj_time

	select @latest_drop = convert(datetime, substring(convert(char, @new_avl, 120), 1, 11) + 
							substring(convert(char, @cutoff, 120), 12, 5))
	
	Select @pickup = DateAdd(Hour, (@lead_time * (-1)), @latest_drop)
	
	select @latest_pickup = DateAdd(Hour, (-1), @latest_drop)
end
Else
	select @pickup = '1-1-1900 00:00:00', @latest_pickup = '1-1-1900 00:00:00', 
			@latest_drop = '1-1-1900 00:00:00'

end
else
select @pickup = '1-1-1900 00:00:00', @latest_pickup = '1-1-1900 00:00:00', 
			@latest_drop = '1-1-1900 00:00:00'
/*
stp_type = 'PUP'
stp_arrivaldate = @pickup
stp_schdtearliest = @avl_date
stp_departuredate = @pickup
stp_schdtlatest = @latest_pickup

stp_type = 'DRP'
stp_schdtlatest = @latest_drop
stp_arrivaldate = @latest_drop
stp_departuredate = @latest_drop
stp_schdtearliest = @avl_date
*/
select @avl_date, @pickup, @latest_pickup, @latest_drop


GO
GRANT EXECUTE ON  [dbo].[railramp_schedules_sp] TO [public]
GO
