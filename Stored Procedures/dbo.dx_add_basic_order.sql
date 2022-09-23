SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/* This proc adds a simple one pickup and one drop order.  Set the @validatedata parm to 'Y'
   to turn on data validation.  Once things are working, consider turning it off.  If it 
   Returns a -1, an error in saving the data to the database occurred and everything has
   been cleaned out - no order was created!

Arguments passed 
   validatadata char(1) - If 'Y' proc will validate data and return values as 
              indicated below (wihtout addid the order) if edits fail

   OrdNumber varchar(12) - Optional, the order number will be assigned by PowerSuite
              If a blank is passed. NOTE: If an order number is passed
	      it must contain only numbers 0-9 and letters A-Z and must
              contain at least one letter.

   assigned_ord_number varchar(12) - Optional, the order number will be assigned by PowerSuite
              and returned in ord_number if a blank is passed. NOTE: If an order number is passed
	      it must contain only numbers 0-9 and letters A-Z and must
              contain at least one letter.
   orderby_cmpID varchar(8) - The PowerSuite company ID for the company which placed the
	      order (optional, default value should be UNKNOWN)

   billto_cmpID varchar(8) - The PowerSuite company ID for the company whic is to be 
	      billed (required)

   ref_number_type varchar(6) - A code to identify the type of reference number which 
              follows. It should be a valid label file entry in PowerSuite 
              (EG BL# for bill of lading)

   Ref_number varchar(12) - a reference number to be attached to the order (as opposed to
              a ref number on the stop or a freight detail).  Additional
              reference numbers can be added by calling the proc 
              dx_add_refnumber_to_order.

    ord_remark varchar(256) - optional.
 
    ord_bookedby varchar(8) - optional. Identifies the party entering the order.  If a
              blank is passed, 'IMPORT' will be placed in this field. Free form.

    commodity_code varchar(8) - optional. Identifies the commodity picked up and delivered
              on the simple order.  Must match the PowerSuite table of 
              commodities.  Defualt value is UNKNOWN.

    billing_quantity float - optional. If the order is to be pre rated, and if the order is rated by
              total (total miles or weight, etc.) then this is the quantity
              which is to be billed.  If the order is not to be pre rated pass zero.
                                
    billing_quantity_unitofmeas varchar(6) - optional. If the billing quantity is passed, this is the
              unit of measure for this quantity.   It must match one of the
              PowerSuite label file entries for 'WeightUnits', 'VolumeUnits',
              'CountUnits', 'DistanceUnits', 'FlatUnits', or 'TimeUnits'.

    fix_billing_quantity_level smallint - If zero(0), then the billing quantity for this order will
              be determined from actual values (weight, distance, count,
              or volume) at the time of billing. If one(1) this quantity will
              be used  by billing no matter what actual values are provided
              (EG atually shipped 6427 pounds but want to bill for 6500 pounds).
              If a two(2) quantity will be fixed for setttlements also.

    rate (money) -  optional. If the order is to be pre rated, this is the rate to be applied.

    linehaul_charge money - optional.  Pass if the order is to be pre rated. At this time
              we do not handle accessorial charges on pre rating - feature
              must be added if needed.

    fix_charge smallint - (default zero) If zero(0), the pre rated line haul charge is not
	      fixed (may be overridden with rating in the application).  IF
	      one(1), the pre rated charge is fixed.  NOTE: If this is
              used and secondary charges must be put on the order, a change
              must be made.  Assumption - there are only linehaul charges.

    pickup_revtypes_from_billto char(1) - Values 'Y' or 'N' (default) Rev Type values are
              customer defined, but usually represent organizational structure.
              PowerSuite has provision for copying these values from the 
              Bill to company profile.  If 'Y' the Revtype 1,2,3, and 4
              values will be copied fom the bill to company and the following
              four arguments ignored.

    revtype1 varchar(6) - optional. (default 'UNK') If provided must match the PowerSuite labelfile
              entries for 'RevType1'.  Revtype values are user defines and often
              define organizational hierarchy for GL purposes.

    revtype2 varchar(6) - optional. See above

    revtype3 varchar(6) - optional. See above

    revtype4 varchar(6) - optional.  See above

    ord_totalmiles int - optional. The total trip miles for this order.
  
    pickup_cmpID varchar(8) - (either the company ID or a city code must be provided)
               A valid PowerSuite company ID for pickup location for this order.
               If the company ID is pased, the city code from the company table
               entry will be used for the pick up location. 

    pickup_citycode int - (either the company ID or a city code must be provided)
               A valid PowerSUite city code value (returned from dx_does_city_exist
               proc) for a pickup location.

    pickup_contact - optional. Name and/or phone of contact person for the order

    pickup_phone - optional

    pickup_commoditycode  - optional. A valid PowerSuite commodity code for the
               freight picked up.
	
    commodity_ref_type - optional.  If a reference number is to be attached to the freight
               detail, enter a valid PS reference type code to identoty the
               type of reference.

    commodity_ref_number - optional. If provide there must be a ref_type. The reference number 
               of the type indicated above to  be attached to the freight.
   
    pickup_weight - optional. The weight of the freight picked up (will also be recorded
               as the weight delivered in the drop).

    pickup_weight_unitofmeasure - optional. A valid PS label file entry of type 'WeightUnits'
               to define the unit of measure.

    pickup_volume - optional. The volume of the freight picked up (also recorded as the volume
               dropped).

    pickup_volume_unitofmeasure - optional. A vlaid PS label file entry of the type 'VolumeUnits'

    pickup_count - optional

    pickup_count_unitofmeasure - optional.  A valid PS label file entry of type 'CountUnits'.

    pickup_stop_ref_type - optional.  If provided, must be a valid PS label file entry of
              type 'Referencenumber' to identify the type of reference number
              attached to the pickup stop.

    pickup_stop_ref_ref_number - optional.  If provide there must be a ref type. 

    estimated_pickup_dttm - required. The estimated time of arrival at the pickup location.

    earliest_pickup_dttm - optional (if not provided should pass '1-1-1950 00:00'.  Must be
              equal to or less than the estimated arrival if provided.

    latest_pickup_dttm - optional. (if not provided should pass '12-31-2049 23:59'. Must
              be equal to or later than the estimated arrival.

    drop_cmpID - (either the company ID or the city must be provided).  A valid PS company
              ID for the drop location.  The city fromt eh company table in PS
              will be picked up.

    drop_citycode (eith the company ID or the city must be provided). A valid city code
              (returned from a call to dx_does_city_exist) for the location
              of the drop if no company ID is provided.
 
    estimated_drop_dttm - required. The estimated arrival at the drop location.

    earliest_drop_dttm -  (see ealriest pickup dttm comments)

    latest_drop_dttm -  (see latest drop dttm comments)

    drop_stop_ref_type - optional. If a reference number is to be associated with the delivery
              stop location, this must be a valid PS label file entry of type 
              'ReferenceNumbers'.

    drop_stop_ref_number - optional. If provided, the ref_type must also be passed.

 

 Assumptions
	- the commodity picked up is the commodity delivered

 Return values (if validatadata is passed as 'Y')
        -1 database error (nothing saved, cannot turn off with validatedata flag)
	
	-2 Pickup company ID provided, and is not valid in PowerSuite
	-3 Pickup company not provided and pickup city is not valid in PS
	-4 Drop company ID provided, and is not valid in PowerSuite
	-5 Drop company not provided and drop city is not valid in PS
	-6 Reference number type does not exist in the PS labelfile
	-7 Billing quantity Unit of meas does not match PS unit codes in labelfile
	-8,9,10,11 Revtype1,2,3,4 invalid
	-12 Invalid commodity code
	-13 Duplicate order number passed in @assigned_ord_number
	-14 @assigned_ord_number is all numeric or contains chars other than A-Z, 0-1. Invalid in PS
	-15 Invalid weight unit of measure (not in PS labelfile)
	-16 Invalid volume unit of measure
	-17 Invalid count unit of measure
	-18 commodity reference number type cannot be found in PS labelfile
	-19 pickup stop reference type cannot be found in PS labelfile
	-20 drop stop reference type cannot be found in PS labelfile
        -21 Assigned rder number is a duplicate
	-22 Bill to company ID is not valid in PowerSuite
	
SAMPLE CALL

  DECLARE @ret int,@ord_number varchar(12)
 

EXEC @ret = dx_add_basic_order
	'Y',
	@ord_number OUTPUT,       -- order number assigned by proc returned
	'',            -- order number assigned by caller
 	'TOL11',       -- order by company 
	'CHIC11',      -- bill to company 
	'BL#',    -- order reference number type must be valid in PS labelfile 
	'ORDBL#',    -- order ref number 
	'added by add_basic_order',   --remark 
	'DPETE',      -- booked by, optional  
	'CAR2',       --commodity   
         89765,   --  billing quantity - only if pre rated (by total) 
	'lbs',   --billing qty unit of measure 
	0,       -- Fix billing qty - 0 default, 1 invoice, 2 inv & stlmnt 
	0.5,                           -- rate    
	44882.50,                --linehaul charge   	
	1,        --Fix charge - 0 default, 1 fix   
	'Y',        -- Pickup revtypes from bill to company 'Y' or 'N'   
	'UNK',                      -- revtype 1 used if @pickup = 'N'   
	'UNK',                    --revtype2 - ditto  
	'UNK',                    -- revtype 3 - ditto  
	'UNK',                    -- revtype 4 - ditto  
	62,                 -- order total mileage  
	'DET11',              -- pickup company must be valid if provided  
	0,                  -- city code - only if no cmpid provided  
	'',           -- pickup stop contact  
	'',             -- pickup stop phone nbr  
	'CAR1',     -- pickup commodity code  
	'phonec',         -- pickup stop reference number type  
	'fgtphone',        -- ref number  
	89765,                  -- pickup weight   
	'lbs',         -- unit of measure  if wgt > 0   
	0,                  -- pickup volume  
	'',         -- vol unit of meas must be valid in PS if vol > 0  
	0,                   -- pickup count   
	'',         -- count unit of meas -must be valid in PS if count > 0   
	'WAS',       -- pickup stop reference # type -if provided must be valid in PS labelfile  
	'STOPWASH',   -- ref number  
	'11-16-00 9:20',   -- estimated arrival  
	'1-1-50 00:00',   --earliest pickup  
	'11-16-00 9:20',   -- latest pickup  
	'CLEVE1',          -- drop at company  
	0,                  -- drop city code -   only if no cmpid provided  
	'',           -- drop stop contact  
	'',            -- phone  
	'11-16-00 14:05',   -- estimated arrival  
	'1-1-50 00:00',        -- earliest drop  
	'11-16-00 14:05',      -- latest dropp  
	'DEL#',       -- drop stop ref number type -if provided must be valid in PS labelfile  
        'dropdel#'    / ref number 
	
*/  
CREATE PROCEDURE [dbo].[dx_add_basic_order]
	@validatedata char(1),
	@@ord_number varchar(12) OUTPUT,   
	@assigned_ord_number varchar(12),   /* optional, assigned to @@ord_number if empty */
 	@orderby_cmpid varchar(8),
	@billto_cmpid varchar(8),
	@ord_status varchar(6),
	@ref_number_type varchar(6),    /* must be valid in PS labelfile */
	@ref_number varchar(30),
	@ord_remark varchar(256),
	@ord_bookedby varchar(8),      /* optional  */
	@commodity_code varchar(8),   /*optional  */
        @billing_quantity float(8),   /*only if pre rated (by total) */
	@billing_quantity_unitofmeas varchar(6),   /*ditto  */
	@fix_billing_quantity_level smallint,  /* 0 default, 1 invoice, 2 inv & stlmnt */
	@rate money,                            /*ditto  */
	@linehaul_charge money,                 /*ditto  */	
	@fix_charge smallint,         /* 0 default, 1 fix  */
	@pickuprevtypes_From_billto char(1),        /* 'Y' or 'N'  */
	@revtype1 varchar(6),                      /*used if @pickup = 'N'  */
	@revtype2 varchar(6),
	@revtype3 varchar(6),
	@revtype4 varchar(7),
	@ord_totalmiles int,
	@pickup_cmpid varchar(8),              /* must be valid if provided */
	@pickup_citycode int,                  /* only if no cmpid provided */
	@pickup_contact varchar(30),           /* optional */
	@pickup_phone varchar(20),             /* optional */
	@pickup_commoditycode varchar(8),      /* optional */
	@commodity_ref_type varchar(6),         /* if provided msut be valid in PS */
	@commodity_ref_number varchar(30),
	@pickup_weight float,                  /* optional  */
	@pickup_weight_unitofmeasure varchar(6),         /* must be valid in PS if wgt > 0  */
	@pickup_volume float,                  /* optional  */
	@pickup_volume_unitofmeasure varchar(6),         /* must be valid in PS if vol > 0 */
	@pickup_count float,                   /* optional  */
	@pickup_count_unitofmeasure varchar(6),         /* must be valid in PS if count > 0  */
	@pickup_stop_ref_type varchar(6),       /* if provided must be valid in PS labelfile */
	@pickup_stop_ref_number varchar (30),
	@estimated_pickup_dttm datetime,
	@earliest_pickup_dttm datetime,
	@latest_pickup_dttm datetime,
	@drop_cmpid varchar(8),
	@drop_citycode int,                  /*  only if no cmpid provided */
	@drop_contact varchar(30),           /* optional */
	@drop_phone varchar(20),
	@estimated_drop_dttm datetime,
	@earliest_drop_dttm datetime,
	@latest_drop_dttm datetime,
	@drop_stop_ref_type varchar(6),       /* if provided must be valid in PS labelfile */
	@drop_stop_ref_number varchar (30),
	@invoice_status	varchar(6)	--040109 AJR
	

 AS
   
  DECLARE @ret smallint
  DECLARE @ordhdrnumber int, @stp_number int, @mov_number int, @lgh_number int, @fgt_number int
  DECLARE @evt_number int
  DECLARE @nextone smallint, @foundaletter char(1)
  
 SELECT @ord_status = CASE ISNULL(@ord_status,'') WHEN '' THEN 'AVL' ELSE @ord_status END
 IF (SELECT COUNT(1) FROM labelfile where labeldefinition = 'DispStatus' and abbr = @ord_status) = 0
	RETURN -1
 
 IF @validatedata = 'Y'
   BEGIN  /* begin validation section */
     SELECT @assigned_ord_number = UPPER(@assigned_ord_number)
    IF LEN(RTRIM(@assigned_ord_number)) > 0 
       BEGIN
         IF (SELECT COUNT(*)   /* is the passed order number a duplicate */
		FROM orderheader
                WHERE ord_number = @assigned_ord_number) > 0
             RETURN -21
         SELECT @nextone = 1
	 SELECT @foundaletter = 'N'
         WHILE @nextone <= LEN(@assigned_ord_number)
           BEGIN
             /* does the passed order number contain a character other than 0-9,A-Z */
             IF CHARINDEX(SUBSTRING(@assigned_ord_number,@nextone,1),
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') = 0
                RETURN -14
             /* does it contain at least one letter */
             IF CHARINDEX(SUBSTRING(@assigned_ord_number,@nextone,1),
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0
                SELECT @foundaletter = 'Y'
             SELECT @nextone = @nextone + 1
           END
         IF @foundaletter = 'N' Return -14
         IF (SELECT COUNT (*)
             FROM orderheader
             WHERE ord_number = @assigned_ord_number) > 0
         RETURN -13 
      END
    /* check for valid company id's */
        /* Bill To is required */
      IF (SELECT COUNT(*)
	  FROM company
	  WHERE cmp_id = @billto_cmpid) = 0
         RETURN -22
   END  /* end validation */

	/* order by is not verified */
    SELECT @orderby_cmpid = UPPER(ISNULL(@orderby_cmpid,'UNKNOWN'))
    IF LEN(RTRIM(@orderby_cmpid)) = 0 SELECT @orderby_cmpid = 'UNKNOWN'

	/* if pickup company is missing, the pickup city better be valid */
    SELECT @pickup_cmpid = UPPER(ISNULL(@pickup_cmpid,'UNKNOWN'))
    IF LEN(RTRIM(@pickup_cmpid)) = 0 SELECT @pickup_cmpid = 'UNKNOWN'
    IF @validatedata = 'Y'
      BEGIN  /* begin validation section */
        IF @pickup_cmpid <> 'UNKNOWN'
          BEGIN
            IF (SELECT COUNT(*)
	    FROM company
	    WHERE cmp_id = @pickup_cmpid) = 0
              RETURN -2
          END  

      	ELSE
          BEGIN
	    IF (SELECT COUNT(*)
	    FROM city
	    WHERE cty_code = @pickup_citycode) = 0
              RETURN -3
          END
    END  /* end validation section  */

/* if found use the location info from the company */
    IF @pickup_cmpid <> 'UNKNOWN'
        SELECT @pickup_citycode = cmp_city
        FROM company
        WHERE cmp_id = @pickup_cmpid
    

    SELECT @pickup_contact = ISNULL(@pickup_contact,'')
    SELECT @pickup_phone = ISNULL(@pickup_phone,'')
    SELECT @drop_contact = ISNULL(@drop_contact,'')
    SELECT @drop_phone = ISNULL(@drop_phone,'')
    
	/* if drop company is missing, the drop city better be valid */
    SELECT @drop_cmpid = UPPER(ISNULL(@drop_cmpid,'UNKNOWN'))
    IF LEN(RTRIM(@drop_cmpid)) = 0 SELECT @drop_cmpid = 'UNKNOWN'
    IF @validatedata = 'Y'
      BEGIN
        IF @drop_cmpid <> 'UNKNOWN'
          BEGIN
            IF (SELECT COUNT(*)
	    FROM company
	    WHERE cmp_id = @drop_cmpid) = 0
              RETURN -4
          END
        ELSE
          BEGIN
	    IF (SELECT COUNT(*)
	    FROM city
	    WHERE cty_code = @drop_citycode) = 0
              RETURN -5
          END
       END

	/* Is ref type a valid  */
   
    SELECT @ref_number_type = UPPER(ISNULL(@ref_number_type,''))

    IF @validatedata = 'Y' and LEN(RTRIM(@ref_number)) > 0
      BEGIN
        IF (SELECT COUNT(*)
	    FROM labelfile
	    WHERE labeldefinition = 'ReferenceNumbers'
	    AND abbr = @ref_number_type ) = 0
              RETURN -6
      END
    SELECT @ref_number = UPPER(@ref_number)

    SELECT @commodity_ref_type = UPPER(ISNULL(@commodity_ref_type,''))
    IF @validatedata = 'Y' and LEN(RTRIM(@commodity_ref_number)) > 0
      BEGIN
        IF (SELECT COUNT(*)
	    FROM labelfile
	    WHERE labeldefinition = 'ReferenceNumbers'
	    AND abbr = @commodity_ref_type ) = 0
              RETURN -18
      END
    SELECT @commodity_ref_number = UPPER(@commodity_ref_number)

    
    SELECT @pickup_stop_ref_type = UPPER(ISNULL(@pickup_stop_ref_type,''))
    IF @validatedata = 'Y' and LEN(RTRIM(@pickup_stop_ref_number)) > 0
      BEGIN
        IF (SELECT COUNT(*)
	    FROM labelfile
	    WHERE labeldefinition = 'ReferenceNumbers'
	    AND abbr = @pickup_stop_ref_type ) = 0
              RETURN -19
      END
    SELECT @pickup_stop_ref_number = UPPER(@pickup_stop_ref_number)

    SELECT @drop_stop_ref_number = UPPER(ISNULL(@drop_stop_ref_number,''))
    SELECT @drop_stop_ref_type = UPPER(ISNULL(@drop_stop_ref_type,''))
    IF @validatedata = 'Y' and LEN(RTRIM(@drop_stop_ref_number)) > 0
      BEGIN
        IF (SELECT COUNT(*)
	    FROM labelfile
	    WHERE labeldefinition = 'ReferenceNumbers'
	    AND abbr = @drop_stop_ref_type ) = 0
              RETURN -20
      END
	/* Default on booked by is IMPORT   */
    SELECT @ord_bookedby = UPPER(ISNULL(@ord_bookedby,'IMPORT'))
    IF LEN(RTRIM(@ord_bookedby)) = 0 SELECT @ord_bookedby = 'IMPORT'

	/* Billing quantity unit of meas must match to PS  */
    SELECT @billing_quantity_unitofmeas = UPPER(ISNULL(@billing_quantity_unitofmeas,'UNK'))
    IF LEN(RTRIM(@billing_quantity_unitofmeas)) = 0 SELECT @billing_quantity_unitofmeas = 'UNK'
    IF @validatedata = 'Y' and @billing_quantity_unitofmeas <> 'UNK'
       BEGIN
         IF (SELECT COUNT(*)
	 FROM labelfile
	 WHERE labeldefinition in ('WeightUnits','CountUnits','VolumeUnits', 'DistanceUnits',
	                           'TimeUnits')
	 AND abbr = @billing_quantity_unitofmeas ) = 0
           RETURN -7
       END

	/* @fix_billing_quantity_level must be 0,1,2  */
     SELECT @fix_billing_quantity_level = 
        CASE @fix_billing_quantity_level
           WHEN 0 THEN 0
	   WHEN 1 THEN 1
	   WHEN 2 THEN 2
	   ELSE 0
        END

	/* @fix_charge must be 0 or 1   */
    SELECT  @fix_charge = 
        CASE  @fix_charge
           WHEN 0 THEN 0
	   WHEN 1 THEN 1
	   ELSE 0
        END
       
	/* If revtypes are to be picked up from bill to, do it, else validate ones passed */
  IF @pickuprevtypes_From_billto = 'Y'

       SELECT @revtype1 = cmp_revtype1,@revtype2 = cmp_revtype2, @revtype3 = cmp_revtype3, @revtype4 = cmp_revtype4
       FROM company
       WHERE cmp_id = @billto_cmpid

  ELSE 
    BEGIN
       SELECT @revtype1 = UPPER(ISNULL(@revtype1,'UNK'))
       IF LEN(RTRIM(@revtype1)) = 0 SELECT @revtype1 = 'UNK'
       IF @validatedata = 'Y' 
         BEGIN
           IF (SELECT COUNT(*)
	      FROM labelfile
	       WHERE labeldefinition = 'RevType1'
  	       AND abbr = @revtype1) = 0
                RETURN - 8
         END

       SELECT @revtype2 = UPPER(ISNULL(@revtype2,'UNK'))
       IF LEN(RTRIM(@revtype2)) = 0 SELECT @revtype2 = 'UNK'
       IF @validatedata = 'Y' 
         BEGIN
	    IF (SELECT COUNT(*)
	       FROM labelfile
	       WHERE labeldefinition = 'RevType2'
  	       AND abbr = @revtype2) = 0
               RETURN - 9
         END

       SELECT @revtype3 = UPPER(ISNULL(@revtype3,'UNK'))
       IF LEN(RTRIM(@revtype3)) = 0 SELECT @revtype3 = 'UNK'
       IF @validatedata = 'Y' 
         BEGIN
	    IF (SELECT COUNT(*)
	        FROM labelfile
	        WHERE labeldefinition = 'RevType3'
  	        AND abbr = @revtype3) = 0
                RETURN - 10
         END 

       SELECT @revtype4 = UPPER(ISNULL(@revtype4,'UNK'))
       IF LEN(RTRIM(@revtype4)) = 0 SELECT @revtype4 = 'UNK'
       IF @validatedata = 'Y' 
         BEGIN
	   IF (SELECT COUNT(*)
	       FROM labelfile
	       WHERE labeldefinition = 'RevType4'
  	       AND abbr = @revtype4) = 0
                RETURN - 11
         END
     END
	/* verify @pickup_commoditycode  can be found in commodity table */ 
      SELECT @pickup_commoditycode = UPPER(ISNULL(@pickup_commoditycode,'UNKNOWN'))
      IF LEN(RTRIM(@pickup_commoditycode)) = 0 SELECT @pickup_commoditycode = 'UNKNOWN'
      IF @validatedata = 'Y' 
         BEGIN
           IF (SELECT COUNT(*)
	       FROM commodity
	       WHERE cmd_code  = @pickup_commoditycode) = 0
                 RETURN - 12
         END

	/*if pickup wgt, vol, or count  is provided, unit of meas must be valid */   
      SELECT @pickup_weight = ISNULL(@pickup_weight,0)
      SELECT @pickup_weight_unitofmeasure = UPPER(ISNULL(@pickup_weight_unitofmeasure,'LBS'))
      IF @validatedata = 'Y' and @pickup_weight > 0
        BEGIN 
          IF (SELECT COUNT(*)
              FROM labelfile
              WHERE labeldefinition = 'WeightUnits'
              AND abbr = @pickup_weight_unitofmeasure) = 0
            RETURN -15
        END

      SELECT @pickup_volume = ISNULL(@pickup_volume,0)
      SELECT @pickup_volume_unitofmeasure = UPPER(ISNULL(@pickup_volume_unitofmeasure,'GAL'))
      IF @validatedata = 'Y' and @pickup_volume > 0
        BEGIN 
          IF (SELECT COUNT(*)
              FROM labelfile
              WHERE labeldefinition = 'VolumeUnits'
              AND abbr = @pickup_volume_unitofmeasure) = 0
            RETURN -16
        END
  EXEC @ordhdrnumber = dbo.getsystemnumber 'ORDHDR',NULL
  IF LEN(RTRIM(@assigned_ord_number)) = 0 SELECT @@ord_number = CONVERT(varchar(10),@ordhdrnumber)
  ELSE SELECT @@ord_number = @assigned_ord_number
 
      SELECT @pickup_count = ISNULL(@pickup_count,0)
      SELECT @pickup_count_unitofmeasure = UPPER(ISNULL(@pickup_count_unitofmeasure,'PCS'))
      IF @validatedata = 'Y' and @pickup_count > 0
        BEGIN 
          IF (SELECT COUNT(*)
              FROM labelfile
              WHERE labeldefinition = 'CountUnits'
              AND abbr = @pickup_count_unitofmeasure) = 0
            RETURN -17
        END

      /* get the control numbers needed to enter the order */


  EXEC @lgh_number =  dbo.getsystemnumber 'LEGHDR', NULL
  EXEC @stp_number =  dbo.getsystemnumber 'STPNUM', NULL
  EXEC @fgt_number =  dbo.getsystemnumber 'FGTNUM', NULL
  EXEC @evt_number =  dbo.getsystemnumber 'EVTNUM', NULL
  EXEC @mov_number =  dbo.getsystemnumber 'MOVNUM', NULL

  /*Inset pickup stop (also adds freight and event)  */
  EXEC @ret = dx_add_basic_order_stop
	@mov_number,@ordhdrnumber,@lgh_number,@stp_number,@fgt_number,@evt_number,
	'LLD',1,1,@pickup_commoditycode,@pickup_cmpid,@pickup_citycode,@pickup_contact,
	@pickup_phone,@estimated_pickup_dttm,@earliest_pickup_dttm,@latest_pickup_dttm,
	@pickup_weight,@pickup_weight_unitofmeasure,@pickup_count,@pickup_count_unitofmeasure,
	@pickup_volume,@pickup_volume_unitofmeasure,
	@pickup_stop_ref_type,@pickup_stop_ref_number,@commodity_ref_type,@commodity_ref_number,@ord_status

  IF @ret = -1 GOTO ERROR

  EXEC @stp_number =  dbo.getsystemnumber 'STPNUM', NULL
  EXEC @fgt_number =  dbo.getsystemnumber 'FGTNUM', NULL
  EXEC @evt_number =  dbo.getsystemnumber 'EVTNUM', NULL
  /*Inset DROP stop (also adds freight and event)  */
  EXEC @ret = dx_add_basic_order_stop
	@mov_number,@ordhdrnumber,@lgh_number,@stp_number,@fgt_number,@evt_number,
	'LUL',2,2,@pickup_commoditycode,@drop_cmpid,@drop_citycode,@drop_contact,
	@drop_phone,@estimated_drop_dttm,@earliest_drop_dttm,@latest_drop_dttm,
	@pickup_weight,@pickup_weight_unitofmeasure,@pickup_count,@pickup_count_unitofmeasure,
	@pickup_volume,@pickup_volume_unitofmeasure,
	@drop_stop_ref_type,@drop_stop_ref_number,@commodity_ref_type,@commodity_ref_number,@ord_status
 
   IF @ret = -1 GOTO ERROR

	/*  Finally add order header (and order refNumber) */

   EXEC @ret = dx_add_basic_orderheader
        @mov_number, @ordhdrnumber,
	@orderby_cmpid, @@ord_number,  		
	@ord_bookedby, @billto_cmpid,
	@revtype1, @revtype2, 	
	@revtype3, @revtype4,
	@ord_totalmiles, @ref_number_type,@ref_number,
	@ord_remark,
	@billing_quantity, @billing_quantity_unitofmeas,@rate, @linehaul_charge, @ord_status,
	@invoice_status	--AR 04APR2009 Added Inv Status.
   
   IF @ret = -1 GOTO ERROR
   GOTO ENDIMPORT

 ENDIMPORT:
  /* PTS 16783 - DJM - Add update_move_light proc to solve missing Legheader problem.	*/
  EXEC @ret = update_move_light @mov_number
  if @ret < 0 GOTO ERROR
 
  RETURN 1
 ERROR:
   EXEC purge_delete @mov_number,0
   SELECT 'ERROR :imported order:',@@ord_number
   RETURN -1

GO
GRANT EXECUTE ON  [dbo].[dx_add_basic_order] TO [public]
GO
