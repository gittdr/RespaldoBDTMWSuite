SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[calculateullage_sp]
		 @cmp_id		varchar(8),
		 @tank_loc		varchar(10),
		 @tank_model_id		varchar(12),
		 @tank_dip_date		datetime,
		 @tank_dip		int,
		 @tank_highdip		decimal(4, 2),
		 @tank_inventoryqty	int OUTPUT,
		 @tank_ullageqty	int OUTPUT,
		 @tank_deliveredqty	int OUTPUT,
		 @tank_sales		int OUTPUT,
		 @dip_level		int OUTPUT

AS

/**
 * 
 * NAME:
 * calculateullage_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Calculates ullage based on a tanks custom dip percentages and current dip level.
 *
 * RETURNS: 	
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS:
 * @cmp_id		varchar(8)	Company ID where tank is located
 * @tank_loc		varchar(10)	Specific tank location within the company
 * @tank_model_id	varchar(12)	Model of tank (from tankmodel table)
 * @tank_dip_date	datetime	Date of dip reading
 * @tank_dip		int		Dip reading
 * @tank_highdip	decimal(4, 2)	High dip percentage from which Ullage is calculated
 * @tank_inventoryqty	int OUTPUT	Output parameter (calculated total inventory quantity)
 * @tank_ullageqty	int OUTPUT	Output parameter (calculated ullage (empty) quantity)
 * @tank_deliveredqty	int OUTPUT	Output parameter (calculated delivered quantity)
 * @tank_sales		int OUTPUT	Output parameter (calculated tank_sales)
 * @dip_level		int OUTPUT	Output parameter (calculated dip level - quantity used by datawindow)

 *
 * REVISION HISTORY:
 * 10/6/2005.01 ? PTS29687 - Dan Hudec ? Created Procedure
 *
 **/

	DECLARE	 @capacity		int,
		 @last_inventoryqty	int,
		 @tank_nbr		int,
		 @last_dipdate		datetime,
		--PTS 40762 JJF 20080418
         @v_lastdipdate datetime,
         @v_priordip int,
         @v_priorvolume int,
         @v_dipvolume int,
         @v_sales int
		--END PTS 40762 JJF 20080418


	SELECT @tank_inventoryqty = tank_volume
	FROM   tankdipchart
	WHERE  model_id = @tank_model_id
	AND    tank_dip = (SELECT MAX(tank_dip)
			   FROM   tankdipchart
			   WHERE  tank_dip <= @tank_dip and model_id = @tank_model_id)

	SELECT @tank_nbr = tank_nbr,
	       @capacity = tank_capacity
	FROM   tank
	WHERE  cmp_id = @cmp_id
	AND    tank_loc = @tank_loc

	IF @capacity IS NULL
		SELECT @capacity = model_capacity
		FROM   tankmodel
		WHERE  model_id = @tank_model_id
	
-- 	SELECT @tank_ullageqty = (95*@capacity)/100 - @tank_inventoryqty
-- 	SELECT @dip_level = @tank_inventoryqty/(0.95*@capacity)*100

	--DPH PTS 28806
	SELECT @tank_ullageqty = (@tank_highdip*@capacity)/100 - @tank_inventoryqty
	SELECT @dip_level = @tank_inventoryqty/((@tank_highdip/100)*@capacity)*100
	--DPH PTS 28806
	
/*  27505 tank_deliveredqty is updated by trigger on freight_by_compartment when macro records delivery 
	-- @tank_deliveredqty 
	-- select sum(deliveredqty from somewhere where tank_loc = @tank_loc and 
	--   delivereddate between last dip date and @dip_date

	SELECT @last_dipdate = ISNULL(MAX(tank_dip_date), @tank_dip_date)
	FROM   tankdiphistory
	WHERE  tank_nbr = @tank_nbr
	AND    tank_dip_date < @tank_dip_date

	SELECT @tank_deliveredqty = SUM(fbc_volume)
	FROM freight_by_compartment a, stops b
	WHERE a.fbc_tank_nbr = @tank_nbr
	AND a.stp_number = b.stp_number
	AND a.ord_hdrnumber = b.ord_hdrnumber
	AND b.stp_arrivaldate between @last_dipdate and @tank_dip_date
*/
--PTS 40762 JJF 20080418
/* 32542 now tank_deliveredqty is summed from the diplog table where deliveries are recorded
        SELECT @tank_deliveredqty = IsNull(tank_deliveredqty,0)
        FROM tankdiphistory
        WHERE  tank_nbr = @tank_nbr
        AND    tank_dip_date = @tank_dip_date



	SELECT @last_inventoryqty = tank_inventoryqty
	FROM   tankdiphistory
	WHERE  tank_nbr = @tank_nbr
	AND    tank_dip_date = (SELECT MAX(tank_dip_date)
				FROM   tankdiphistory
				WHERE  tank_nbr = @tank_nbr
				AND    tank_dip_date < @tank_dip_date)

	SELECT @tank_sales = ISNULL(@last_inventoryqty, 0) + 
			     ISNULL(@tank_deliveredqty, 0) -  
			     ISNULL(@tank_inventoryqty, 0)
	IF @tank_sales < 0
	   SELECT @tank_sales = 0
--PTS 40762 JJF 20080418
*/
	  select @v_lastdipdate = max(dl_date) from diplog where tank_nbr = @tank_nbr
  /* volume from diplog entry priod to these two entries (before and after) 
    note: dipcharts don't necessarily include all dip readings */

  If @v_lastdipdate is not null
     BEGIN
     /* prior dip volume */
	     select @v_priordip =  dl_dipreading 
         from diplog where tank_nbr = @tank_nbr and dl_date = @v_lastdipdate
         select @v_priorvolume = tank_volume from tankdipchart 
            where model_id = @tank_model_id and tank_dip =
                 (select Max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @tank_model_id and tdc2.tank_dip <= 
                 (select MAX(dl_dipreading) from diplog where tank_nbr = @tank_nbr and dl_date = @v_lastdipdate))

         /* this dip volume */
         Select @v_dipvolume = tank_volume from tankdipchart where  model_id = @tank_model_id 
               and tank_dip = (select max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @tank_model_id
               and tank_dip <= @tank_dip)

                -- sales on this dip is the difference prior volume - this dip volume
         select @tank_sales = Case @v_priorvolume when 0 then 0 else (@v_priorvolume - @v_dipvolume) end
         Select @tank_sales = Case when @tank_sales < 0 then 0 else @tank_sales end
     END
  else
     Select @tank_sales = 0
	 
		
	RETURN
GO
GRANT EXECUTE ON  [dbo].[calculateullage_sp] TO [public]
GO
