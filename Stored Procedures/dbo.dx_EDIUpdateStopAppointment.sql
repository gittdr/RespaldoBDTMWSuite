SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_EDIUpdateStopAppointment]
	@stp_number int,
	@stp_arrivaldate datetime,
	@stp_earlydate datetime,
	@stp_latedate datetime,
	@Force char(1) = 'Y',
	@Message varchar(255) output	
as

declare @p_arrivaldate datetime, @p_earlydate datetime, @p_latedate datetime, @p_update char(1), @p_mov int, @p_status varchar(6)
declare @p_departuredate datetime, @midnight datetime
select @Message = ''
select @p_update = 'N'

select @p_mov = mov_number, @p_arrivaldate = stp_arrivaldate, @p_earlydate = stp_schdtearliest, 
	@p_latedate = stp_schdtlatest, @p_status = stp_status, @p_departuredate = stp_departuredate
  from stops
 where stp_number = @stp_number

if @p_arrivaldate is null return -1

if @p_status = 'DNE' return 1

if @stp_arrivaldate is null
	select @stp_arrivaldate = @p_arrivaldate
else
	if @stp_arrivaldate <> @p_arrivaldate
		select @p_update = 'Y'

if @stp_earlydate is null
	select @stp_earlydate = @p_earlydate
else
	if @stp_earlydate <> @p_earlydate
		select @p_update = 'Y'

if @stp_latedate is null
	select @stp_latedate = @p_latedate
else
	if @stp_latedate <> @p_latedate
		select @p_update = 'Y'

select @midnight =  CONVERT(smalldatetime,convert(varchar(10),@stp_arrivaldate,101))
		select @p_departuredate = case when @stp_arrivaldate = @midnight and DATEDIFF(dd,@p_departuredate,@stp_arrivaldate) > 0
	     		then DATEADD(dd,DATEDIFF(dd,@p_departuredate,@stp_arrivaldate),@p_departuredate) when @stp_arrivaldate = @midnight then @p_departuredate else @stp_arrivaldate end

--begin validate sequence
if @Force = 'N'
	begin
	if @stp_earlydate > @stp_arrivaldate
		select @Message = 'Earliest is after current arrival time.' + char(13) + char(10)
	if @stp_latedate < @stp_earlydate
		select @Message = @Message + 'Latest is before current earliest time.' + char(13) + char(10)
	if @stp_latedate < @stp_arrivaldate
		select @Message = @Message + 'Latest is before current arrival time.' + char(13) + char(10)
	if @Message <> ''
		return 2
	end
--end validate sequence

if @p_update = 'Y'
begin
	update stops
	   set stp_arrivaldate = @stp_arrivaldate, stp_schdtearliest = @stp_earlydate, stp_schdtlatest = @stp_latedate,
	       stp_departuredate = @p_departuredate
	 where stp_number = @stp_number
	if @@ROWCOUNT > 0
	begin
		declare @mov_number int
		select @mov_number = mov_number from stops where stp_number = @stp_number
		if @mov_number > 0 exec update_ord @mov_number, 'UNK'
	end
end

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_EDIUpdateStopAppointment] TO [public]
GO
