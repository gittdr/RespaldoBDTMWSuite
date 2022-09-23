SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_recommended_fuel_limit_sp] (@lgh int)
AS

declare @trc as varchar(8)
declare @refnumtype as varchar(6)
declare @ord_hdrnumber as integer
declare @daysback as integer
declare @miles as integer
declare @mpg as float
declare @price as money
declare @temp as money
declare @recommended_amount as money

select @miles = 0
select @mpg = 0.00
select @recommended_amount = 0.00

select @trc = lgh_tractor
  from legheader
 where lgh_number = @lgh

select @daysback = isnull(gi_integer1,14) * -1,
       @refnumtype = left(isnull(gi_string1, ''),6)
  from generalinfo 
 where gi_name = 'AverageFuelPriceDaysBack'
 
select @ord_hdrnumber = MAX(ord_hdrnumber)
  from stops
 where lgh_number = @lgh

if not exists(select * from referencenumber where ref_table = 'orderheader' and ref_tablekey = @ord_hdrnumber and ref_type = @refnumtype)
begin
	select @miles = sum(isnull(stp.stp_lgh_mileage,0))
	  from stops stp
	  where stp.lgh_number = @lgh
		and stp.stp_loadstatus = 'LD'

	select @mpg = isnull(trc.trc_mpg,0)
	  from tractorprofile trc
	 where trc.trc_number = @trc
	 
	 if @mpg > 0 and @miles > 0
	 begin
		select @price = max(isnull(afp_price,0.00))
		  from averagefuelprice
		 where afp_date >= DATEADD(DD, @daysback, (select convert(datetime,convert(varchar(10), GETDATE(), 101))))
		if @price > .01
		begin
			select @temp = ((@miles/@mpg) * @price) * 1.175
			select @recommended_amount = CEILING((@temp)*.2)/.2
			--select @miles, @mpg, DATEADD(DD, @daysback, convert(datetime,convert(date, (GETDATE())))),@price, @temp, @recommended_amount
		end
	 end
	 else
	 begin
		select @recommended_amount = -1
	 end
end
else
begin
	select @recommended_amount = -1
end
--no update will be done if the limit is negative (zero will cause a 0 update to be sent)
select @recommended_amount

GO
GRANT EXECUTE ON  [dbo].[get_recommended_fuel_limit_sp] TO [public]
GO
