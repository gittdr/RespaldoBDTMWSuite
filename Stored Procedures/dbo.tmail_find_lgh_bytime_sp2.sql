SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_find_lgh_bytime_sp2]
	@p_tractor varchar(8),
	@p_startdate varchar(30),
	@p_enddate varchar(30),
	@p_which_lgh varchar(6),
	@p_driver varchar(8)
AS

SET NOCOUNT ON 

DECLARE
	@v_startdate datetime,
	@v_enddate datetime,
	@v_which_lgh int,
	@v_lgh_number int,
	@v_lgh_startdate datetime, 
	@v_lgh_enddate datetime, 
	@v_lgh_outstatus varchar(6), 
	@v_lgh_tractor varchar(8), 
	@v_lgh_driver1 varchar(8), 
	@v_lgh_driver2 varchar(8),
	@v_lgh_start_hubmiles int,
	@v_lgh_end_hubmiles int,
	@v_lgh_startcty_nmstct varchar(30),
	@v_lgh_endcty_nmstct varchar(30),
	@v_stp_number int


CREATE TABLE #LegTemp
(
	lgh_number int,
	lgh_startdate datetime,
	lgh_enddate datetime,
	lgh_outstatus varchar(6),
	lgh_tractor varchar(8),
	lgh_driver1 varchar(8),
	lgh_driver2 varchar(8),
	lgh_startcty_nmstct varchar(30),
	lgh_endcty_nmstct varchar(30) 
)

if isnull(@p_tractor,'') = '' and isnull(@p_driver,'') = ''
	BEGIN
	RAISERROR ('Tractor ID or Driver ID required.', 16, 1)
	RETURN 1
	END

if isdate(@p_startdate) = 0
	BEGIN
	RAISERROR ('Invalid start date-time %s.', 16, 1, @p_startdate)
	RETURN 1
	END
set @p_enddate = isnull(@p_enddate, getdate())
if isdate(@p_enddate) = 0
	BEGIN
	RAISERROR ('Invalid end date-time %s.', 16, 1, @p_enddate)
	RETURN 1
	END
set @v_startdate = convert(datetime, @p_startdate)
set @v_enddate = convert(datetime, @p_enddate)
if @v_startdate >= @v_enddate
	BEGIN
	RAISERROR ('Start date-time %s must be less than end date-time %s.', 16, 1, @p_startdate, @p_enddate)
	RETURN 1
	END

set @p_which_lgh = isnull(@p_which_lgh, 0)
if isnumeric(@p_which_lgh) = 0
	BEGIN
	RAISERROR ('''Which legheader'' argument %s must be -1, 0, 1 or 2.', 16, 1, @p_which_lgh)
	RETURN 1
	END
set @v_which_lgh = convert(int, @p_which_lgh)
set @v_stp_number = 0
if not exists (select @v_which_lgh where @v_which_lgh in (-1, 0, 1, 2))
	BEGIN
	RAISERROR ('''Which legheader'' argument %s must be -1, 0, 1, or 2.', 16, 1, @p_which_lgh)
	RETURN 1
	END

IF @p_tractor <> ''
BEGIN
	INSERT INTO #LegTemp
	select lgh_number,lgh_startdate,lgh_enddate, lgh_outstatus, lgh_tractor, lgh_driver1, lgh_driver2, LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1) 
	from legheader (NOLOCK)
	where lgh_tractor = @p_tractor
   		and ((lgh_outstatus = 'STD' and lgh_startdate < @v_enddate)
    	or (lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))

 	IF @v_which_lgh > 0
	BEGIN
  		select top 1 @v_lgh_number = lgh_number, @v_lgh_startdate = lgh_startdate, @v_lgh_enddate = lgh_enddate, @v_lgh_outstatus = lgh_outstatus, @v_lgh_tractor = lgh_tractor, @v_lgh_driver1 = lgh_driver1, @v_lgh_driver2 = lgh_driver2, @v_lgh_startcty_nmstct = LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), @v_lgh_endcty_nmstct = LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1)  
		from #LegTemp
		where lgh_tractor = @p_tractor
   			and ((lgh_outstatus = 'STD' and lgh_startdate < @v_enddate)
    		or (lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))
   		order by lgh_startdate
	END
 	ELSE
	BEGIN
  		select top 1 @v_lgh_number = lgh_number, @v_lgh_startdate = lgh_startdate, @v_lgh_enddate = lgh_enddate, @v_lgh_outstatus = lgh_outstatus, @v_lgh_tractor = lgh_tractor, @v_lgh_driver1 = lgh_driver1, @v_lgh_driver2 = lgh_driver2, @v_lgh_startcty_nmstct = LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), @v_lgh_endcty_nmstct = LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1) 
		from #LegTemp
   		where lgh_tractor = @p_tractor
   			and ((lgh_outstatus = 'STD' and lgh_startdate < @v_enddate)
    		or (lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))
   		order by lgh_startdate desc
	END
END
ELSE
BEGIN
	INSERT INTO #LegTemp
	select lgh_number,lgh_startdate,lgh_enddate, lgh_outstatus, lgh_tractor, lgh_driver1, lgh_driver2, LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1) 
	from legheader nolock
   	where (lgh_driver1 = @p_driver)
   		and ((lgh_outstatus = 'STD' and lgh_startdate < @v_enddate)
    	or (lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))

	INSERT INTO #LegTemp
	select lgh_number,lgh_startdate,lgh_enddate, lgh_outstatus, lgh_tractor, lgh_driver1, lgh_driver2, LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1) 
	from legheader nolock
   	where (lgh_driver2 = @p_driver)
   		and ((lgh_outstatus = 'STD' and lgh_startdate < @v_enddate)
    	or (lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))
   	
	IF @v_which_lgh > 0 and @v_which_lgh <> 2
	BEGIN
  		select top 1 @v_lgh_number = lgh_number, @v_lgh_startdate = lgh_startdate, @v_lgh_enddate = lgh_enddate, @v_lgh_outstatus = lgh_outstatus, @v_lgh_tractor = lgh_tractor, @v_lgh_driver1 = lgh_driver1, @v_lgh_driver2 = lgh_driver2, @v_lgh_startcty_nmstct = LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), @v_lgh_endcty_nmstct = LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1) 
		from #LegTemp
   		where (lgh_driver1 = @p_driver or lgh_driver2 = @p_driver)
   			and ((lgh_outstatus = 'STD' and lgh_startdate < @v_enddate)
    		or (lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))
   		order by lgh_startdate
	END
	ELSE IF @v_which_lgh = 2
	BEGIN
		select top 1 @v_lgh_number = lgh_number, @v_lgh_startdate = lgh_startdate, @v_lgh_enddate = lgh_enddate, @v_lgh_outstatus = lgh_outstatus, @v_lgh_tractor = lgh_tractor, @v_lgh_driver1 = lgh_driver1, @v_lgh_driver2 = lgh_driver2, @v_lgh_startcty_nmstct = LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), @v_lgh_endcty_nmstct = LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1) 
		from #LegTemp
   		where (lgh_driver1 = @p_driver or lgh_driver2 = @p_driver)
   			and ((lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))
   		order by lgh_startdate desc
		select @v_stp_number=stp_number from stops where lgh_number = @v_lgh_number and stp_mfh_sequence = (select max(stp_mfh_sequence) from stops where lgh_number = @v_lgh_number)
	END
 	ELSE
	BEGIN
  		select top 1 @v_lgh_number = lgh_number, @v_lgh_startdate = lgh_startdate, @v_lgh_enddate = lgh_enddate, @v_lgh_outstatus = lgh_outstatus, @v_lgh_tractor = lgh_tractor, @v_lgh_driver1 = lgh_driver1, @v_lgh_driver2 = lgh_driver2, @v_lgh_startcty_nmstct = LEFT(lgh_startcty_nmstct,LEN(lgh_startcty_nmstct)-1), @v_lgh_endcty_nmstct = LEFT(lgh_endcty_nmstct,LEN(lgh_endcty_nmstct)-1) 
		from #LegTemp
   		where (lgh_driver1 = @p_driver or lgh_driver2 = @p_driver)
   			and ((lgh_outstatus = 'STD' and lgh_startdate < @v_enddate)
    		or (lgh_outstatus = 'CMP' and lgh_startdate < @v_enddate and lgh_enddate > @v_startdate))
   		order by lgh_startdate desc
	END
END

set @v_lgh_number = isnull(@v_lgh_number, 0)

--if @v_lgh_number = 0 RETURN 0 -- no error, no results

select top 1 @v_lgh_start_hubmiles = evt_hubmiles 
from stops (NOLOCK)
	inner join event (NOLOCK) on event.stp_number = stops.stp_number and evt_sequence = 1
	where stops.lgh_number = @v_lgh_number 
	order by stp_mfh_sequence
set @v_lgh_start_hubmiles = isnull(@v_lgh_start_hubmiles, 0)

select top 1 @v_lgh_end_hubmiles = evt_hubmiles 
from stops (NOLOCK)
	inner join event (NOLOCK) on event.stp_number = stops.stp_number and evt_sequence = 1
	where stops.lgh_number = @v_lgh_number 
	order by stp_mfh_sequence desc
set @v_lgh_end_hubmiles = isnull(@v_lgh_end_hubmiles, 0)

select 	@v_lgh_number as lgh_number, 
		@v_lgh_startdate as lgh_startdate, 
		@v_lgh_enddate as lgh_enddate, 
		@v_lgh_outstatus as lgh_outstatus, 
		@v_lgh_tractor as lgh_tractor, --5
		@v_lgh_driver1 as lgh_driver1,
		@v_lgh_driver2 as lgh_driver2, 
		@v_lgh_start_hubmiles as lgh_start_hubmiles, 
		@v_lgh_end_hubmiles as lgh_end_hubmiles, 
		@v_lgh_startcty_nmstct as lgh_startcty_nmstct, 
		@v_lgh_endcty_nmstct as lgh_endcty_nmstct,
		@v_stp_number as last_stp_number


RETURN 0

GO
GRANT EXECUTE ON  [dbo].[tmail_find_lgh_bytime_sp2] TO [public]
GO
