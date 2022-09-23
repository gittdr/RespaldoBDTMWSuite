SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_upd_fuelpurchased2] @p_trc_number varchar(8), 		--  1 	REQUIRED
 					  					  @p_trl_number varchar(13), 		--  2 
	 				  					  @p_mpp_id varchar(8), 			--  3 	Manpower profile ID
		 			  					  @p_fp_date varchar(22), 			--  4 	REQUIRED
				          				  @p_fp_time varchar(30),			--  5
			 		  					  @p_fp_purchcode varchar(6),		--  6
					  					  @p_fp_vendorname varchar(50),		--  7
					              		  @p_fp_quantity varchar(10),		--  8   REQUIRED
					  				      @p_fp_cost_per varchar(10),		--  9   REQUIRED
 					  					  @p_fp_odometer varchar(10),		-- 10 
					  					  @p_fp_uom varchar(6), 			-- 11 
					  					  @p_fp_fueltype varchar(6),		-- 12
					  					  @p_fp_invoice_no varchar(12),		-- 13   
					  					  @p_fp_city varchar(24),			-- 14	REQUIRED
					  					  @p_fp_state varchar(6),			-- 15	REQUIRED
					  					  @p_flags int						-- 16

AS

SET NOCOUNT ON 

DECLARE @v_fp_id varchar(36),
 	@v_fp_sequence int,
	@v_ord_number char(12), 
	@v_ord_hdrnumber int, 
	@v_mov_number int, 
	@v_lgh_number int,
	@v_fp_odometer decimal(8,1), 
	@v_fp_date datetime,
	@v_fp_time datetime,
	@v_dtNow datetime,
	@v_fp_status varchar(6),
	@v_fp_purchcode varchar(6),
	@v_fp_uom varchar(6),
	@v_fp_fueltype varchar(6),
	@v_fp_quantity decimal(9,2),
	@v_fp_cost_per money,
	@v_fp_amount money,
	@v_fp_trc_trl varchar(6),
	@v_flags int,
	@v_city varchar(24),
	@v_state varchar(6),
	@v_DateTime varchar(50),
	@v_fp_invoice_no varchar(12)	-- PTS 44918

/**
-- For testing   
	@p_trc_number varchar(8), 		--  1 
 	@p_trl_number varchar(13), 		--  2 
	@p_mpp_id varchar(8), 			--  3 
	@p_fp_date varchar(22), 		--  4 
	@p_fp_purchcode varchar(6),		--  5
	@p_fp_vendorname varchar(50),	--  6
	@p_fp_cost_per varchar(10),		--  7
	@p_fp_amount varchar(10),		--  8
 	@p_fp_odometer varchar(10),		--  9
	@p_fp_uom varchar(6), 			-- 10 
	@p_fp_fueltype varchar(6),		-- 11
	@p_fp_invoice_no varchar(12),	-- 12
	@p_fp_city varchar(24),			-- 13
	@p_fp_state varchar(6),			-- 14
	@p_flags int					-- 15

SET @p_trc_number  = '1500'
SET @p_trl_number  = '2320'
SET @p_mpp_id  = 'MBURR'
SET @p_fp_date  = '05/23/2006'
SET @p_fp_time  = '08:00:00 AM'
SET @p_fp_purchcode  = 'TM'
SET @p_fp_vendorname  = 'VENDOR NAME'
SET @p_fp_cost_per  = '2.75'
SET @p_fp_quantity  = '100'
SET @p_fp_odometer  = '54321'
SET @p_fp_uom  = 'GAL'
SET @p_fp_fueltype = 'DSL'
SET @p_fp_invoice_no  = '1234'
SET @p_fp_city  = 'AKRON'
SET @p_fp_state = 'OH'
SET @v_flags = 0
**/

SET NOCOUNT ON

-- PARAMETER CHECKING
IF (ISNUMERIC(@p_flags) < 1)
    SET @v_flags = 0
ELSE
    SET @v_flags = CONVERT(DECIMAL(8,1), @p_flags)

-- Check Date and Time
SET @p_fp_date = RTRIM(LTRIM(ISNULL(@p_fp_date,'')))
SET @p_fp_date = LTRIM(LEFT(@p_fp_date, CHARINDEX(' ', @p_fp_time)))
SET @p_fp_time = RTRIM(LTRIM(ISNULL(@p_fp_time,'')))
SET @p_fp_time = LTRIM(SUBSTRING(@p_fp_time, CHARINDEX(' ', @p_fp_time), DATALENGTH(@p_fp_time)))

IF (@p_fp_time + @p_fp_date = '')
  BEGIN
	RAISERROR ('NO DATE ASSIGNED. CANNOT PROCESS.', 16, 1)
	RETURN 1
  END
ELSE
  BEGIN
	IF (@p_fp_date <> '' AND @p_fp_time <> '')
	  BEGIN
		-- Both date and time fields are populated, so put together and test.
		SET @p_fp_date = @p_fp_date + ' ' + @p_fp_time
		IF (ISDATE(@p_fp_date) < 1)
		  BEGIN
			RAISERROR ('1) INVALID DATE/TIME (%s). CANNOT PROCESS.', 16, 1, @p_fp_date)
			RETURN 1
		  END
		ELSE
			SET @v_DateTime = CONVERT(datetime, @p_fp_date)
	  END
	ELSE
	  BEGIN
		IF (@p_fp_time = '') 
		  BEGIN
			-- @v_fp_date must hold both date and time
			IF (ISDATE(@p_fp_date) < 1)
			  BEGIN
				RAISERROR ('2) INVALID DATE/TIME (%s). CANNOT PROCESS.', 16, 1, @p_fp_date)
				RETURN 1
			  END
			ELSE
				SET @v_DateTime = CONVERT(datetime, @p_fp_date)
		  END
		ELSE
			-- @v_fp_time must hold both date and time
			IF (ISDATE(@p_fp_time) < 1)
			  BEGIN
				RAISERROR ('3) INVALID DATE/TIME (%s). CANNOT PROCESS.', 16, 1, @p_fp_time)
				RETURN 1
			  END
			ELSE
				SET @v_DateTime = CONVERT(datetime, @p_fp_time)	
	  END
  END

IF ISDATE(@v_DateTime) < 1  
BEGIN
     RAISERROR ('Fuel purchase date/time (%s) is invalid, cannot process.',16,1, @v_DateTime)
     RETURN
END

--Validate tractor exists in TMWSuite
IF NOT EXISTS (SELECT * FROM tractorprofile (NOLOCK) WHERE trc_number = @p_trc_number)  
BEGIN
     RAISERROR ('Tractor (%s) is not a valid tractor, cannot process.',16,1, @p_trc_number)
     RETURN
END

--Validate trailer exists in TMWSuite
--PTS 88846 - 05.14.15 AB: Since the trailer is not required
--Just see if the trailer exists or use UNKNOWN instead.
SELECT @p_trl_number = ISNULL((SELECT trl_number  FROM trailerprofile (NOLOCK) WHERE trl_number = @p_trl_number), 'UNKNOWN')

--IF NOT EXISTS (SELECT * FROM trailerprofile (NOLOCK) WHERE trl_number = ISNULL(@p_trl_number,'UNKNOWN'))  
--BEGIN
--     RAISERROR ('Trailer (%s) is not a valid trailer, cannot process.',16,1, @p_trl_number)
--     RETURN
--END

--Validate driver exists in TMWSuite
IF NOT EXISTS (SELECT * FROM manpowerprofile (NOLOCK) WHERE mpp_id = @p_mpp_id)  
BEGIN
     RAISERROR ('Driver (%s) is not a valid driver, cannot process.',16,1, @p_mpp_id)
     RETURN
END

IF ISNUMERIC(@p_fp_odometer) < 1
    SET @v_fp_odometer = 0
ELSE
    SET @v_fp_odometer = CONVERT(DECIMAL(8,1), @p_fp_odometer)

-- Check Purchase Code
IF (ISNULL(@p_fp_purchcode,'') = '') 
    SET @v_fp_purchcode = 'BLK'
ELSE
    SET @v_fp_purchcode = RTRIM(UPPER(@p_fp_purchcode))

-- Check fp_uom
IF (ISNULL(@p_fp_uom,'') = '') OR (RTRIM(UPPER(@p_fp_uom)) <> 'LTR') AND (RTRIM(UPPER(@p_fp_uom)) <> 'GAL') 
    SET @v_fp_uom = 'GAL'
ELSE
    SET @v_fp_uom = RTRIM(UPPER(@p_fp_uom))

-- Check fp_Type
IF ISNULL(@p_fp_fueltype,'') = '' OR RTRIM(UPPER(@p_fp_fueltype)) <> 'DSL' AND RTRIM(UPPER(@p_fp_fueltype)) <> 'REEF' 
    SET @v_fp_fueltype = 'DSL'	
ELSE
    SET @v_fp_fueltype = RTRIM(UPPER(@p_fp_fueltype))

IF (@v_fp_fueltype = 'DSL')
    SET @v_fp_trc_trl = 'C'	-- DSL defaults to tractor
ELSE IF (@v_fp_fueltype = 'REEF')
    SET @v_fp_trc_trl = 'L'	-- REEFER defaults to TRL
ELSE
    SET @v_fp_trc_trl = 'C'	-- REEFER defaults to TRL


-- Check  City
IF (ISNULL(@p_fp_city,'') = '') 
  BEGIN
      RAISERROR ('No city was assigned, cannot process.',16,1)
      RETURN
  END
-- Check  State 
IF (ISNULL(@p_fp_state,'') = '') 
  BEGIN
      RAISERROR ('No state was assigned, cannot process.',16,1)
      RETURN
  END

IF NOT EXISTS (SELECT * FROM city WHERE cty_state = @p_fp_state AND cty_name = @p_fp_city)  
  BEGIN
      RAISERROR ('Invalid City/State combination (%s/%s), cannot process.',16,1, @p_fp_city, @p_fp_state)
      RETURN
  END

-- PTS 44918 - Begin
-- Check Invoice Number
IF  (ISNULL(@p_fp_invoice_no, '') = '')
	SET @v_fp_invoice_no = ''
ELSE
	SET @v_fp_invoice_no = @p_fp_invoice_no
-- PTS 44918 - End

-- Check @v_fp_amount
IF (ISNULL(@p_fp_quantity,'') <> '')
    IF (ISNUMERIC(@p_fp_quantity) > 0) 
       SET @v_fp_quantity = @p_fp_quantity
    ELSE
       SET @v_fp_quantity = -1
ELSE
    SET @v_fp_quantity = -1

IF (@v_fp_quantity = -1)
  BEGIN
      RAISERROR ('No quantity was assigned, cannot process.',16,1)
      RETURN
  END

-- Check @v_fp_cost_per
IF (ISNULL(@p_fp_cost_per, '') <> '')
   IF (ISNUMERIC(@p_fp_cost_per) > 0)
      set @v_fp_cost_per = CONVERT(MONEY, @p_fp_cost_per)
   ELSE
      SET @v_fp_cost_per = -1
ELSE
   SET @v_fp_cost_per = -1

IF (@v_fp_cost_per = -1)
  BEGIN
      RAISERROR ('No cost per value was assigned, cannot process.',16,1)
      RETURN
  END

SET @v_fp_amount = (@v_fp_quantity * @v_fp_cost_per)

/*	-- FOR TESTING ---
-- Code for checking the requirement of 2 out of 3 variables for quantity, cost_per and amount
-- Validate the @v_fp_quantity, @v_fp_amount and @fp_cost 
IF (@v_fp_quantity > -1) AND (@v_fp_amount > -1) AND (@v_fp_cost_per > -1)
  BEGIN
    IF (CONVERT(money,(@v_fp_quantity * @v_fp_cost_per)) <> @v_fp_amount)
	BEGIN
	  print  @v_fp_quantity * @v_fp_cost_per
          RAISERROR ('(Quantity * Cost per UOM) <> TotalAmount, cannot process.',16,1)
          RETURN
        END
  END
ELSE
    IF (@v_fp_quantity = -1) 
        IF (@v_fp_amount > -1) AND (@v_fp_cost_per > -1)
	    SET @v_fp_quantity = @v_fp_amount / @v_fp_cost_per
	ELSE
	  BEGIN
	    RAISERROR ('A) 2 out of the 3 values (Quantity = (%s), Cost per UOM = (%s), TotalAmount = (%s)) are not set, cannot process.',16,1, @v_fp_quantity, @v_fp_amount, @v_fp_cost_per)
	    RETURN
  	  END
    ELSE if (@v_fp_amount = -1) 
        IF (@v_fp_quantity > -1) AND (@v_fp_cost_per > -1)
	    SET @v_fp_amount = @v_fp_quantity * @v_fp_cost_per
	ELSE
	  BEGIN
	    RAISERROR ('B) 2 out of the 3 values (Quantity = (%s), Cost per UOM = (%s), TotalAmount = (%s)) are not set, cannot process.',16,1, @v_fp_quantity, @v_fp_amount, @v_fp_cost_per)
	    RETURN
  	  END
    ELSE -- (@fp_cost > -1)
        IF (@v_fp_quantity > -1) AND (@v_fp_amount > -1)
	    SET @v_fp_cost_per = @v_fp_amount / @v_fp_quantity 
	ELSE
	  BEGIN
	    RAISERROR ('C) 2 out of the 3 values (Quantity = (%s), Cost per UOM = (%s), TotalAmount = (%s)) are not set, cannot process.',16,1, @v_fp_quantity, @v_fp_amount, @v_fp_cost_per)
	    RETURN
  	  END
*/

SELECT @v_fp_date = CONVERT(datetime, @v_DateTime)  -- this line will error if not a valid date
SELECT @v_dtNow=getdate()
SELECT @v_fp_status = 'NPD'

SELECT @v_ord_number='0', @v_ord_hdrnumber=0, @v_mov_number=0, @v_lgh_number=0 

SELECT @v_fp_id = right(convert(varchar(3),100+datepart(mm,@v_dtNow)),2) + right(convert(varchar(3),100+datepart(dd,@v_dtNow)),2) + 
	right(convert(varchar(4),datepart(yy,@v_dtNow)),2) + right(convert(varchar(3),100+datepart(hh,@v_dtNow)),2) +
	right(convert(varchar(3),100+datepart(mi,@v_dtNow)),2) + @v_fp_purchcode + 'TM' 

SELECT @v_fp_sequence = isnull(max(fp_sequence),0)+1 from fuelpurchased (NOLOCK) where fp_id=@v_fp_id

-- Get the current location of the tractor (last stop that tractor has arrived at)
SELECT @v_lgh_number = ISNULL(lgh_number,0),
       @v_mov_number = ISNULL(mov_number,0),
       @v_ord_hdrnumber = ISNULL(ord_hdrnumber,0)
  FROM legheader (NOLOCK)
  WHERE lgh_tractor = @p_trc_number
	AND lgh_outstatus IN ('STD','CMP')   
	AND lgh_startdate = (SELECT ISNULL(MAX(ISNULL(lgh_startdate,'19500101')),'19500101') FROM legheader WHERE lgh_tractor = @p_trc_number AND lgh_outstatus IN ('STD','CMP'))

IF (@v_lgh_number > 0)
   SELECT stp_number 
   FROM stops (NOLOCK) 
   WHERE lgh_number = @v_lgh_number
	AND stp_mfh_sequence = (SELECT MAX(stp_sequence) FROM stops WHERE lgh_number = @v_lgh_number AND stp_status = 'DNE')

IF (@v_lgh_number > 0)
   SELECT @v_ord_number  = ord_number FROM orderheader WHERE mov_number = @v_mov_number

-- Primary key: fp_id, fp_sequence
-- PTS 44918
INSERT INTO fuelpurchased(fp_id, 
				fp_sequence, fp_purchcode, fp_date, fp_quantity, 
				fp_uom, fp_fueltype, fp_trc_trl, fp_cost_per, 
				fp_amount, ord_number, ord_hdrnumber, mov_number, 
                lgh_number, trc_number, trl_number, mpp_id, 
				fp_vendorname, fp_cityname, fp_state, fp_odometer, 
				fp_enteredby, fp_processeddt, fp_invoice_no)
            VALUES(@v_fp_id, 
				@v_fp_sequence, @v_fp_purchcode, @v_fp_date, @v_fp_quantity, 
				@v_fp_uom, @v_fp_fueltype, @v_fp_trc_trl, @v_fp_cost_per, 
				@v_fp_amount, @v_ord_number, @v_ord_hdrnumber, @v_mov_number, 
				@v_lgh_number, @p_trc_number, 
				--PTS 88846
				ISNULL(@p_trl_number,'UNKNOWN'), 
				@p_mpp_id, 
				@p_fp_vendorname, @p_fp_city, @p_fp_state, @v_fp_odometer, 
				'TMAIL', getdate(), @v_fp_invoice_no)

GO
GRANT EXECUTE ON  [dbo].[tmail_upd_fuelpurchased2] TO [public]
GO
