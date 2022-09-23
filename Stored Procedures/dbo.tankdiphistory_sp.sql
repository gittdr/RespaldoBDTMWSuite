SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE 	PROCEDURE [dbo].[tankdiphistory_sp] 
		  @cmp_id		varchar(8),
		  @tank_loc		varchar(10),
		  @tank_dip_date 	datetime = NULL
AS
/*
*
* REVISION HISTORY
*   CREATED ?
*  04/13/06  PTS32542  DPETE pick up avg sales from the diplog table instead of tankdiphistory
*
*/
	DECLARE   @tank_nbr		int, @weeksback int, @daysback int

select @weeksback = convert(int,gi_string1) from generalinfo
where gi_name = 'FuelMgtWeeksForAvgSales'
Select @weeksback = isnull(@weeksback,4)
If @weeksback = 0 select weeksback = 4
select @daysback = (@weeksback * -7)  

	SELECT @tank_nbr = tank_nbr
	FROM   tank
	WHERE  tank_loc = @tank_loc
	AND    cmp_id   = @cmp_id

	IF @tank_dip_date IS NULL
	   SELECT @tank_dip_date = MAX(tank_dip_date)
	   FROM	  tankdiphistory
	   WHERE  tank_nbr = @tank_nbr
 
	SELECT 	cmp_id,
		tank_loc,
		DATENAME(dw, tank_dip_date) weekday,
		tank_dip_date,
		tank_dip_shift,
		tank_dip,
		tank_inventoryqty,
		tank_ullageqty,
		tank_deliveredqty,
		ord_hdrnumber,
		tank_sales,
                (select sum(isnull(dl_salesvolume,0)) 
                 from diplog
                 where diplog.tank_nbr = a.tank_nbr and 
                 dl_date between dateadd(dd,@daysback,a.tank_dip_date) and a.tank_dip_date and 
                 datename(dw,dl_date) = datename(dw,a.tank_dip_date)) /@weeksback

		--(SELECT AVG(tank_sales)
		-- FROM   tankdiphistory b
		-- WHERE  tank_nbr = @tank_nbr
		-- AND    DATENAME(dw, b.tank_dip_date) = DATENAME(dw, a.tank_dip_date))
	FROM	tankdiphistory a, tank b
	WHERE	a.tank_nbr = @tank_nbr
	AND     a.tank_nbr = b.tank_nbr
	AND     a.tank_dip_date <= @tank_dip_date
	ORDER BY a.tank_dip_date

	RETURN 0
GO
GRANT EXECUTE ON  [dbo].[tankdiphistory_sp] TO [public]
GO
