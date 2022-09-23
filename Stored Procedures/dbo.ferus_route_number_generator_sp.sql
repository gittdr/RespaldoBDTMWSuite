SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROC [dbo].[ferus_route_number_generator_sp] @ord_hdrnumber int, @ord_revtype1 varchar(10), @ord_revtype2 varchar(10),
	  @ord_revtype3 varchar(10), @ord_revtype4 varchar(10), @ord_startdate datetime, @ord_shipper varchar(8),
	  @generated_route_value varchar(8) OUTPUT
AS



DECLARE @generated_number 	varchar(8), 
	@plant_code 		varchar(1), 
	@plant_counter		varchar(2),
	@month_first 		varchar(1), 
	@month_second 		varchar(1),
	@day_of_month		varchar(2),
	@year_digit		varchar(1),
	@counter_day		int,
	@max_sequence 		int,
	@cur_delete_ctr		int,
	@i			int,
	@j			int,
-- PTS 30166 -- BL (start)
	@counter		int
-- PTS 30166 -- BL (end)

BEGIN

-- PTS 30166 -- BL (start)
--	(check to see if current Order already has a ROUTE NUMBER)
SELECT @counter = count(*)
FROM referencenumber
WHERE ref_tablekey = @ord_hdrnumber
AND ref_table = 'orderheader'
AND ref_type = 'LC'
AND Not IsNull(ref_number, '') = '' 

if @counter > 0
   BEGIN
	select	@generated_number = '00000000'
	select	@generated_route_value = @generated_number
	RETURN
   END
-- PTS 30166 -- BL (end)

select 	@generated_number = ''

select	@counter_day = datepart(dy, @ord_startdate)

select 	@plant_code = 	left(cmp_othertype1, 1) from company
		    	where cmp_id = @ord_shipper

if (@plant_code = '1' or @plant_code = '2' or @plant_code = '3' or @plant_code = '4' or @plant_code = '5' or
    @plant_code = '6' or @plant_code = '7' or @plant_code = '8' or @plant_code = '9')
 BEGIN
	Select 	@plant_counter =
		Case @plant_code
			When '1' Then plant_1
			When '2' Then plant_2
			When '3' Then plant_3
			When '4' Then plant_4
			When '5' Then plant_5
			When '6' Then plant_6
			When '7' Then plant_7
			When '8' Then plant_8
			When '9' Then plant_9
		END
	from 	ferus_plant_counter 
	where 	day_id = @counter_day

	select 	@month_first = 	substring(convert(varchar(10), @ord_startdate, 101), 1, 1),
		@month_second =	substring(convert(varchar(10), @ord_startdate, 101), 2, 1),
		@day_of_month = substring(convert(varchar(10), @ord_startdate, 101), 4, 2),
		@year_digit =	right(convert(varchar(10), @ord_startdate, 101), 1)

	if @plant_counter < 10 
		select @plant_counter = '0' + @plant_counter

	if @plant_code = '1'
 	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_1 from ferus_plant_counter 
				where plant_1 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_1 = plant_1 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_1 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
 	 END

	if @plant_code = '2'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_2 from ferus_plant_counter 
				where plant_2 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_2 = plant_2 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_2 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	if @plant_code = '3'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_3 from ferus_plant_counter 
				where plant_3 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_3 = plant_3 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_3 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	if @plant_code = '4'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_4 from ferus_plant_counter 
				where plant_4 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_4 = plant_4 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_4 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	if @plant_code = '5'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_5 from ferus_plant_counter 
				where plant_5 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_5 = plant_5 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_5 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	if @plant_code = '6'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_6 from ferus_plant_counter 
				where plant_6 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_6 = plant_6 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_6 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	if @plant_code = '7'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_7 from ferus_plant_counter 
				where plant_7 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_7 = plant_7 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_7 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	if @plant_code = '8'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_8 from ferus_plant_counter 
				where plant_8 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_8 = plant_8 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_8 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	if @plant_code = '9'
	 BEGIN
		-- PTS 30166 -- BL (start)
		if exists(select plant_9 from ferus_plant_counter 
				where plant_9 < 99 and day_id = @counter_day)
		BEGIN
		-- PTS 30166 -- BL (end)
			update 	ferus_plant_counter
			set 	plant_9 = plant_9 + 1
			where	day_id = @counter_day
		-- PTS 30166 -- BL (start)
		END
		ELSE
		BEGIN
			update 	ferus_plant_counter
			set 	plant_9 = 99
			where	day_id = @counter_day
		END
		-- PTS 30166 -- BL (end)
	 END

	select @cur_delete_ctr = 1
	select @i = 1

	If @counter_day < 61
	 BEGIN
		--select @cur_delete_ctr = 305 + @counter_day
		select @cur_delete_ctr = 245 + @counter_day

		While @i < 61
	 	 BEGIN
			update	ferus_plant_counter
			set 	plant_1 = 1,
				plant_2 = 1,
				plant_3 = 1,
				plant_4 = 1, 
				plant_5 = 1,
				plant_6 = 1, 
				plant_7 = 1,
				plant_8 = 1,
				plant_9 = 1
			where	day_id = @cur_delete_ctr

			if @cur_delete_ctr = 365
				select @cur_delete_ctr = 1
			else
				select @cur_delete_ctr = @cur_delete_ctr + 1
			
			select @i = @i + 1
 		 END
	 END
	Else
	 BEGIN
		While @cur_delete_ctr < (@counter_day  - 60)
	 	 BEGIN
			update	ferus_plant_counter
			set 	plant_1 = 1,
				plant_2 = 1,
				plant_3 = 1,
				plant_4 = 1, 
				plant_5 = 1,
				plant_6 = 1, 
				plant_7 = 1,
				plant_8 = 1,
				plant_9 = 1
			where	day_id = @cur_delete_ctr

			select 	@cur_delete_ctr = @cur_delete_ctr + 1
	 	 END
	 END

	select 	@generated_number = @plant_code + @month_first + @plant_counter + @month_second + @day_of_month + @year_digit
	
	--DPH PTS 29636
	If exists (select *
		   from   referencenumber
		   where  ref_table = 'orderheader'
		   and    ref_tablekey = @ord_hdrnumber
    		   and	  ref_type = 'LC'
		   and	  IsNull(ref_number, '') = '')
	 BEGIN
		update	referencenumber
		set	ref_number = @generated_number
		where	ref_tablekey = @ord_hdrnumber
		and	ref_type = 'LC'
		and	IsNull(ref_number, '') = ''

		select 	@max_sequence = min(ref_sequence)
		from	referencenumber
		where	ref_tablekey = @ord_hdrnumber
		and	ref_type = 'LC'
		and 	IsNull(ref_number, '') <> ''
   	 END
	--DPH PTS 29636

	Else If not exists  (select 	* 
			from 	referencenumber
			where 	ref_table = 'orderheader'
			and 	ref_tablekey = @ord_hdrnumber
			and	ref_type = 'LC')
	 BEGIN
		select 	@max_sequence = max(ref_sequence) + 1
		from 	referencenumber
		where	ref_tablekey = @ord_hdrnumber
		and	ref_table = 'orderheader'
		and	ord_hdrnumber = @ord_hdrnumber

		Select @max_sequence = IsNull(@max_sequence,'1')
	
		insert into referencenumber (ref_tablekey, ref_type, ref_number, ref_sequence, ord_hdrnumber, ref_table, 
				    	     last_updatedate)
		values (@ord_hdrnumber, 'LC', @generated_number, @max_sequence, @ord_hdrnumber, 'orderheader', getdate())
	 END

	If (@Max_Sequence <> 1) 
	 BEGIN
		update	referencenumber
		set	ref_sequence = 0
		where	ref_sequence = @Max_Sequence

		update 	referencenumber
		set 	ref_sequence = ref_sequence + 1
		where 	ref_sequence < @Max_Sequence
			and ref_sequence > 0

		update	referencenumber
		set	ref_sequence = 1
		where	ref_sequence = @Max_Sequence
	 END

	if (select IsNull(ord_refnum,'') from orderheader where ord_hdrnumber = @ord_hdrnumber) = ''
-- 	if (@Max_Sequence = 1)
 	 BEGIN
		update	orderheader
		set	ord_reftype = 'LC',
			ord_refnum = @generated_number
		where	ord_hdrnumber = @ord_hdrnumber
	 END
 END


Else

 BEGIN
	select	@generated_number = '00000000'
 END

select	@generated_route_value = @generated_number

END

GO
GRANT EXECUTE ON  [dbo].[ferus_route_number_generator_sp] TO [public]
GO
