SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[updatetankdiphistory_sp]
		 @cmp_id		varchar(8),
		 @tank_loc		varchar(10),
		 @tank_dip_date		datetime,
		 @tank_dip_shift	char(2),
		 @tank_dip		int = NULL,
		 @tank_inventoryqty	int = NULL,
		 @tank_ullageqty	int = NULL,
		 @tank_deliveredqty	int = NULL,
		 @ord_hdrnumber		int = NULL,
		 @tank_sales		int = NULL
AS
/*
 *
 *
* 
 * REVISION HISTORY:
 * 04/13/2006  ? PTS32542 - AuthorName ? Revision - sales passed is only sales from last 
 *     diplog . Need to add all diplog sales from prior tankdiphistory record
 *
 **/
	DECLARE  @tank_nbr		int, @v_diplogsales int, @v_priortankhistdate datetime

	SELECT @tank_nbr = tank_nbr
	FROM   tank
	WHERE  tank_loc = @tank_loc
	AND    cmp_id   = @cmp_id
       
       /* sum sales from diplog records created since the diplog record added
          for the prior tankdiphistory record */

        Select @v_priortankhistdate = max(tank_dip_date) from tankdiphistory
        Where tank_nbr = @tank_nbr and tank_dip_date < @tank_dip_date
        If @v_priortankhistdate is not null
          BEGIN 
           /* do not include diplog record from prior tankdiphistory record */
           Select @v_priortankhistdate = dateadd(mi,1,@v_priortankhistdate)
           Select @v_diplogsales = sum(isnull(dl_salesvolume,0))
                     from diplog where tank_nbr = @tank_nbr
                     and dl_date between @v_priortankhistdate and @tank_dip_date
           If @v_diplogsales < 0  select  @v_diplogsales = 0
           Select @tank_sales = @v_diplogsales + @tank_sales
          END
 


        

	IF EXISTS (SELECT 1
		   FROM   tankdiphistory
		   WHERE  tank_nbr = @tank_nbr
	 	   AND    tank_dip_date  = @tank_dip_date)
	BEGIN	   /* update */
	   UPDATE tankdiphistory
	   SET	  tank_dip          = @tank_dip,
		  tank_inventoryqty = @tank_inventoryqty,
		  tank_ullageqty    = @tank_ullageqty,
		  tank_deliveredqty = @tank_deliveredqty,
		  ord_hdrnumber     = @ord_hdrnumber,
		  tank_sales        = @tank_sales
	   WHERE  tank_nbr      = @tank_nbr
	   AND    tank_dip_date = @tank_dip_date
	END	   /* update ends */
	ELSE
	BEGIN	   /* insert */
	   INSERT INTO tankdiphistory (
		  tank_nbr,
		  tank_dip_date,
		  tank_dip_shift,
		  tank_dip,
		  tank_inventoryqty,
		  tank_ullageqty,
		  tank_deliveredqty,
		  ord_hdrnumber,
		  tank_sales)
	   VALUES(@tank_nbr,
		  @tank_dip_date,
		  @tank_dip_shift,
		  @tank_dip,
		  @tank_inventoryqty,
		  @tank_ullageqty,
		  @tank_deliveredqty,
		  @ord_hdrnumber,
		  @tank_sales)
	END	   /* insert ends */
	
	RETURN
GO
GRANT EXECUTE ON  [dbo].[updatetankdiphistory_sp] TO [public]
GO
