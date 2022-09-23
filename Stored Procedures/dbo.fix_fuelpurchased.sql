SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[fix_fuelpurchased] (@startdate DATETIME, @enddate DATETIME)
AS

DECLARE @fp_id          VARCHAR(36), 
        @fp_sequence    INT, 
        @fp_purchcode   VARCHAR(6), 
        @ord_number     CHAR(12), 
        @mov_number     INT, 
        @trip           VARCHAR(10), 
        @lgh_number     INT, 
        @fp_state       CHAR(2), 
        @fp_trc_trl     CHAR(1), 
        @trc_number     VARCHAR(8), 
        @trl_number     VARCHAR(8), 
        @mpp_id         VARCHAR(8), 
        @fp_owner       VARCHAR(12), 
        @fp_date        DATETIME, 
        @fp_quantity    FLOAT, 
        @fp_uom         VARCHAR(6), 
        @fp_fueltype    VARCHAR(6), 
        @fp_cost_per    FLOAT, 
        @fp_amount      MONEY, 
        @fp_odometer    FLOAT, 
        @ts_code        VARCHAR(8), 
        @fp_vendorname  VARCHAR(30), 
        @fp_city        INT, 
        @fp_invoice_no  VARCHAR(10), 
        @fp_charge_yn   CHAR(1), 
        @fp_enteredby   VARCHAR(20), 
        @fp_processeddt DATETIME, 
        @fp_status      VARCHAR(6), 
        @ord_hdrnumber  INT, 
        @fp_cityname    VARCHAR(18)

-- set the default/constant values
SELECT @fp_id = LEFT(CONVERT(VARCHAR(10), GETDATE(), 1), 2) +  SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 1), 4, 2) + 
                RIGHT(CONVERT(VARCHAR(10), GETDATE(), 1), 2) + LEFT(CONVERT(VARCHAR(5), GETDATE(), 8), 2) + 
                RIGHT(CONVERT(VARCHAR(5), GETDATE(), 8), 2) + 'CMD' + UPPER(USER),
       @fp_sequence = 1,
       @fp_purchcode = 'CMD', 
       @fp_trc_trl = 'C', 
       @fp_uom = 'GAL', 
       @fp_fueltype = 'DSL', 
       @fp_enteredby = UPPER(USER), 
       @fp_status = 'NPD', 
       @fp_processeddt = GETDATE() 

-- declare cursor with the return set that can be gathered from the cdfuelbill table
DECLARE read_fuelbill CURSOR
FOR SELECT cfb_transdate, cfb_trcgallons, cfb_trccostpergallon, cfb_trccost, 
           cfb_truckstopcode, cfb_truckstopname, cfb_truckstopcityname, cfb_truckstopstate, cfb_truckstopinvoicenumber,
           cfb_tripnumber, cfb_employeenum, cfb_trailernumber, cfb_unitnumber, cfb_trchubmiles 
      FROM cdfuelbill 
     WHERE cfb_transdate BETWEEN @startdate AND @enddate 

-- open the cursor for retrieval
OPEN read_fuelbill

-- find first matching value in the cursor, load the data to variables.
FETCH NEXT FROM read_fuelbill 
 INTO @fp_date, @fp_quantity, @fp_cost_per, @fp_amount, 
      @ts_code, @fp_vendorname, @fp_cityname, @fp_state, @fp_invoice_no, 
      @trip, @mpp_id, @trl_number, @trc_number, @fp_odometer

-- while matching data still exists in the cursor, then load data to the fuelpurchased table
WHILE @@FETCH_STATUS = 0
BEGIN
     -- change the string trip value to an integer number
     SELECT @mov_number = CONVERT(INT, @trip)
     IF @mov_number IS NULL
        SELECT @mov_number = 0

     -- locate move and load legheader and ordheader information
     SELECT @lgh_number = lgh_number, @ord_hdrnumber =ord_hdrnumber 
       FROM legheader 
      WHERE mov_number = @mov_number AND 
            lgh_tractor = @trc_number AND 
            (@fp_date BETWEEN lgh_startdate AND lgh_enddate OR 
             @fp_date > lgh_startdate) 
     IF @lgh_number IS NULL 
        SELECT @lgh_number = 0
     IF @ord_hdrnumber IS NULL 
        SELECT @ord_hdrnumber = 0

     -- locate ord_number from the orderheader table
     SELECT @ord_number = ord_number 
       FROM orderheader 
      WHERE ord_hdrnumber = @ord_hdrnumber 
     IF @ord_number IS NULL 
        SELECT @ord_number = ''

     -- locate tractor owner from the tractor file
     SELECT @fp_owner = trc_owner 
       FROM tractorprofile 
      WHERE trc_number = @trc_number 
     IF @fp_owner IS NULL 
        SELECT @fp_owner = 'UNKNOWN'

     -- find the city code 
     SELECT @fp_city = cty_code 
       FROM city 
      WHERE cty_name = @fp_cityname AND 
            cty_state = @fp_state 
     IF @fp_city IS NULL 
        SELECT @fp_city = 0

     -- load data into the fuelpurchased table
     INSERT INTO fuelpurchased (fp_id, fp_sequence, fp_purchcode, ord_number, mov_number, lgh_number, fp_state, 
                                fp_trc_trl, trc_number, trl_number, mpp_id, fp_owner, fp_date, fp_quantity, 
                                fp_uom, fp_fueltype, fp_cost_per, fp_amount, fp_odometer, ts_code, fp_vendorname, 
                                fp_city, fp_invoice_no, fp_enteredby, fp_processeddt, fp_processedby, fp_status, 
                                ord_hdrnumber, fp_cityname)
          VALUES (@fp_id, @fp_sequence, @fp_purchcode, @ord_number, @mov_number, @lgh_number, @fp_state, 
                  @fp_trc_trl, @trc_number, @trl_number, @mpp_id, @fp_owner, @fp_date, @fp_quantity, 
                  @fp_uom, @fp_fueltype, @fp_cost_per, @fp_amount, @fp_odometer, @ts_code, @fp_vendorname, 
                  @fp_city, @fp_invoice_no, @fp_enteredby, @fp_processeddt, @fp_enteredby, @fp_status, 
                  @ord_hdrnumber, @fp_cityname)

     -- find next matching row and load data into variables
     FETCH NEXT FROM read_fuelbill 
      INTO @fp_date, @fp_quantity, @fp_cost_per, @fp_amount, 
           @ts_code, @fp_vendorname, @fp_cityname, @fp_state, @fp_invoice_no, 
           @trip, @mpp_id, @trl_number, @trc_number, @fp_odometer

     -- increment the sequence variable
     SELECT @fp_sequence = @fp_sequence + 1
END

-- close the cursor
CLOSE read_fuelbill

-- remove the cursor from memory
DEALLOCATE read_fuelbill

GO
GRANT EXECUTE ON  [dbo].[fix_fuelpurchased] TO [public]
GO
