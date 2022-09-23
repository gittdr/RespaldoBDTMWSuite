SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create  proc [dbo].[dx_create_order_from_stops_Rem_Jr]  
	@validate char(1),
    @mov_number int,  
    @assigned_ord_number varchar(12), 
	@orderby_cmpid varchar(8),
	@ord_bookdate datetime,
	@ord_bookedby char(20),
    @ord_billto_cmpid varchar(8),		
	@pickup_revtypes_from_billto char(1), 
	@ord_revtype1 varchar(6), 
	@ord_revtype2 varchar(6), 	
	@ord_revtype3 varchar(6), 
	@ord_revtype4 varchar(6),
	@ord_totalmiles int,
    @ord_reftype varchar(6), 
	@ord_refnum varchar(30), 
	@ord_remark varchar(254),
	@ord_rateby char(1), 
	@ord_billing_quantity float, 
	@ord_billing_unit varchar(6), 
	@ord_rate money, 
	@ord_charge money,
	@ord_chargetype varchar(6),
	@ord_currency varchar(6),
    @fix_billing_quantity int, 
	@fix_charge int,
	@terms  varchar(6),
	@trailer_Type varchar(6),
	@do_not_invoice char(1),
	@carrier varchar(8),
	@dispatch_status varchar(6),
	@lgh_type1 varchar(6),
	@edipurpose varchar(1),
	@edistate tinyint,
	@ordsource varchar(20),
	@ord_supplier_cmpid varchar(8),
	@remolque1	varchar(13),
	@remolque2	varchar(13),
    @@ord_number varchar(12) OUTPUT
as	


DECLARE @ord_hdrnumber int,
	@ord_originpoint varchar(8), @ord_destpoint varchar(8), 
	@ord_origincity int, @ord_destcity int, @ord_originstate char(2),
	@ord_deststate  char(2), @ord_originregion1 varchar(6), 
	@ord_destregion1  varchar(6),
	@ord_startdate datetime, @ord_completiondate datetime,
	@ord_originregion2 varchar(6), @ord_originregion3 varchar(6), 	
	@ord_originregion4 varchar(6), @ord_destregion2 varchar(6), 
	@ord_destregion3 varchar(6), @ord_destregion4 varchar(6),
	@Pup_stp int, @drp_stp int,  @cmd_name varchar(60),
	@cmd_code varchar(8), @ord_origin_earliestdate datetime,
	@ord_origin_latestdate datetime, @ord_stopcount int,
	@ord_dest_earliestdate datetime, @ord_dest_latestdate datetime,
	@ord_totalweight int,@ord_weightunit varchar(6),
	@ord_totalvolume int,@ord_volumeunit varchar(6),
	@ord_totalcount int,@ord_countunit varchar(6),
        @nextone smallint, @foundaletter char(1),
	@err_ret int, @next_stpnumber int, @ord_invoice_status varchar(6),
	@evt_number int, @stp_status varchar(6), @ord_ediflag varchar(6),
	@ord_quantity float, @ord_quantityunit varchar(6),
	@ord_originzip varchar(10), @ord_destzip varchar(10),
	@min_status varchar(6), @retcode int, @cmd_stp int

DECLARE @ls_ord_customer varchar(8), @ls_ord_orderby varchar(8), @ls_ord_billto varchar(8), @ls_ord_revtype1 varchar(6),
	@ls_ord_revtype2 varchar(6), @ls_ord_revtype3 varchar(6), @ls_ord_revtype4 varchar(6), @ls_revtypesource char(1),
	@ls_ord_priority varchar(6), @ls_edictkey varchar(6), @ls_ord_subcompany varchar(8), @ls_ord_rateby char(1),
	@ls_ord_rateunit varchar(6), @ls_trl_type1 varchar(6), @ls_ord_terms varchar(6), @ls_cht_itemcode varchar(6), 
	@ls_ref_sid char(1), @ls_ref_pickup char(1), @ls_ord_tempunits varchar(6), @ls_ord_unit varchar(6), 
	@ls_ord_remark varchar(254), @ls_UseCompanyDefaultEventCodes char(1), @ls_default_event char(6), 
	@ls_auto_add_pul_flag char(1), @ls_quantity_type int, @ld_available_date datetime, @ls_ord_bookedby varchar(20),
	@ls_ord_format varchar(20)

  SELECT @validate = 
     CASE UPPER(ISNULL(@validate,'N'))
       WHEN 'Y' then 'Y'
       WHEN 'I' then 'I'
       ELSE 'N'
     END

SELECT @remolque1 = ISNULL(@remolque1,'UNKNOWN')
SELECT @remolque2 = ISNULL(@remolque2,'UNKNOWN')

  IF @validate = 'I'
  BEGIN
	select @ls_ord_customer = ifc_value from interface_constants 
	 where  ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_customer'
	select @ls_ord_orderby = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_orderby'
	select @ls_ord_billto = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_billto'
	select @ls_ord_revtype1 = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype1'
	select @ls_ord_revtype2 = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype2'
	select @ls_ord_revtype3 = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype3'
	select @ls_ord_revtype4 = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_revtype4'
	select @ls_revtypesource = ifc_value from interface_constants 
	 where ifc_tablename = 'misc' and ifc_columnname = 'revtypesource'
	select @ls_ord_priority = ifc_value from interface_constants 
	 where ifc_tablename = 'ltsl_orderheader' and ifc_columnname = 'ord_priority'
	select @ls_edictkey = ifc_value from interface_constants 
	 where ifc_tablename = 'misc' and ifc_columnname = 'edictkey'
	select @ord_reftype = case isnull(@ord_reftype,'') when '' then isnull(@ls_edictkey,'EDICT#') else @ord_reftype end
	select @ls_ord_subcompany = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'toh_ord_subcompany'
	select @ls_ord_rateby = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_rateby'
	select @ord_rateby = case isnull(@ord_rateby,'') when '' then isnull(@ls_ord_rateby,'D') else @ord_rateby end
	select @ls_ord_rateunit  = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_rateunit'
	select @ls_trl_type1 = ifc_value from interface_constants 
	 where ifc_tablename = 'ltsl_orderheader' and ifc_columnname = 'trl_type1'
	select @ls_ord_terms = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'toh_ord_terms'
	select @ls_cht_itemcode = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'cht_itemcode'
	select @ls_ref_sid = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ref_sid'
	select @ls_ref_pickup = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ref_pickup'
	select @ls_ord_tempunits  = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_tempunits'
	select @ls_ord_unit  = ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_unit'
	select @ord_billing_unit = case isnull(@ord_billing_unit,'') when '' then isnull(@ls_ord_unit,'UNK') else @ord_billing_unit end
	select @ls_ord_remark 	= ifc_value from interface_constants 
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_remark'
	select @ord_remark = case isnull(@ord_remark,'') when '' then isnull(@ls_ord_remark,'') else @ord_remark end
	select @ls_quantity_type = case isnumeric(ifc_value) when 0 then 0 else convert(int, ifc_value) end from interface_constants 
	 where ifc_tablename = 'orderheader' and ifc_columnname = 'ord_quantity_type'
	select @ld_available_date = case isdate(ifc_value) when 0 then getdate() else convert(datetime, ifc_value) end from interface_constants
	 where ifc_tablename = 'orderheader' and ifc_columnname = 'ord_availabledate'
	select @ls_ord_bookedby = ifc_value from interface_constants
	 where ifc_tablename = 'tempordhdr' and ifc_columnname = 'ord_bookedby'
	select @ls_ord_format = ifc_value from interface_constants
	 where ifc_tablename = 'misc' and lower(ifc_columnname) = 'orderidformat'
  END

  SELECT @ls_UseCompanyDefaultEventCodes = gi_string1 FROM generalinfo WHERE gi_name = 'UseCompanyDefaultEventCodes'

  SELECT @ord_bookdate = ISNULL(@ord_bookdate, getdate())
  SELECT @ord_rateby = CASE ISNULL(@ord_rateby,'') WHEN '' THEN 'T' ELSE @ord_rateby END
  SELECT @ord_chargetype = CASE ISNULL(@ord_chargetype,'') WHEN '' THEN 'UNK' ELSE @ord_chargetype END

  SELECT @terms = CASE ISNULL(@terms,'') WHEN '' THEN ISNULL(@ls_ord_terms,'UNK') ELSE @terms END
  IF @validate = 'Y'  AND  (SELECT COUNT(1) FROM labelfile
                          WHERE labeldefinition = 'CreditTerms'
                          AND abbr = @terms) = 0
       RETURN -11

  SELECT @trailer_type = CASE ISNULL(@trailer_type,'') WHEN '' THEN ISNULL(@ls_trl_type1,'UNK') ELSE @trailer_type END

  IF @validate = 'Y'  AND  (SELECT COUNT(1) FROM labelfile
                          WHERE labeldefinition = 'TrlType1'
                          AND abbr = @trailer_type) = 0
       RETURN -12 
       
 SELECT @carrier = UPPER(ISNULL(@carrier,'UNKNOWN'))
 IF RTRIM(@carrier) = '' SELECT @carrier = 'UNKNOWN' 
 IF @carrier <> 'UNKNOWN'
 BEGIN
	IF (SELECT COUNT(1) FROM carrier WHERE car_id = @carrier) = 0
	BEGIN
		IF @validate = 'Y'
			RETURN -13
		ELSE
			SELECT @carrier = 'UNKNOWN', @dispatch_status = 'AVL'
	END
 END
 
 /* if the invoice is not tagged to not invoice, leave available */
  SELECT @ord_invoice_status = 
	CASE @do_not_invoice
	  WHEN 'Y' THEN 'XIN'
	  ELSE 'PND'
	END

/*
IF @carrier <> 'UNKNOWN'
   SELECT @dispatch_status =      CASE @dispatch_status
	WHEN 'PLN' THEN @dispatch_status
	WHEN 'DSP' THEN @dispatch_status
	ELSE 'AVL'
     END
*/
IF @carrier <> 'UNKNOWN' and @dispatch_status in ('PLN','DSP','STD')
	SELECT @stp_status = 'OPN'
ELSE
BEGIN
	IF @dispatch_status IS NOT NULL and LEN(RTRIM(@dispatch_status)) > 0
	  BEGIN
		IF (SELECT UPPER(LEFT(gi_string1, 1)) FROM generalinfo WHERE gi_name = 'DisplayPendingOrders') = 'Y'
			SELECT @min_status = 'PND'
		ELSE
			SELECT @min_status = 'AVL'
		IF (SELECT code FROM labelfile WHERE labeldefinition = 'DispStatus'
		AND abbr = @dispatch_status) <
		(SELECT code FROM labelfile WHERE labeldefinition = 'DispStatus'
		AND abbr = @min_status)
			SELECT @stp_status = 'NON'
		ELSE
			SELECT @stp_status = 'OPN'
	  END
	ELSE
  		SELECT @dispatch_status = 'AVL', @stp_status = 'OPN'
END


 /* assign an order header number (key) must be unique */
  EXEC @ord_hdrnumber = dbo.getsystemnumber 'ORDHDR',NULL
  IF LEN(RTRIM(@assigned_ord_number)) = 0 
	 SELECT @@ord_number = CONVERT(varchar(10),@ord_hdrnumber)
  ELSE 
     BEGIN
        SELECT @@ord_number = @assigned_ord_number
        IF LEN(RTRIM(@assigned_ord_number)) > 0 
        BEGIN
          SELECT @nextone = 1
	  SELECT @foundaletter = 'N'
          WHILE @nextone <= LEN(@assigned_ord_number)
            BEGIN
              IF CHARINDEX(SUBSTRING(@assigned_ord_number,@nextone,1),
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') = 0
                RETURN -3
             IF CHARINDEX(SUBSTRING(@assigned_ord_number,@nextone,1),
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0
                SELECT @foundaletter = 'Y'
             SELECT @nextone = @nextone + 1
           END
         IF @foundaletter = 'N' Return -3
         IF (SELECT COUNT (1)
             FROM orderheader
             WHERE ord_number = @assigned_ord_number) > 0
         RETURN -3 
      END
     END
 
  /* If I cannot find at least 2 stops with this move number return error */

  IF (SELECT COUNT(1)
      FROM stops
      WHERE mov_number = @mov_number) < 2
        BEGIN
          IF @validate != 'N'
            BEGIN
             SELECT @err_ret = -2
	     GOTO ERROR_EXIT
            END
          ELSE
            RETURN -2
        END

  /* get quantity totals from the freight detail */
   SELECT @ord_totalweight = SUM(ISNULL(fgt_weight,0)),
           @ord_totalvolume = SUM(ISNULL(fgt_volume,0)),
	   @ord_totalcount = SUM(ISNULL(fgt_count,0))
    FROM freightdetail
    WHERE stp_number in (SELECT stp_number 
                         FROM stops
                         WHERE mov_number = @mov_number
                         AND stp_type = 'DRP')
   

  /* get total from summing drop stops */
  IF @ord_totalmiles = 0
    SELECT @ord_totalmiles = SUM(ISNULL(stp_ord_mileage,0))
    FROM stops
    WHERE mov_number = @mov_number
 

  /* get units from first drop */
  SELECT @drp_stp=min(stp_sequence) 
  FROM stops
  WHERE mov_number = @mov_number and
	stp_type='DRP'

  SELECT @ord_weightunit = stp_weightunit,
	@ord_volumeunit = stp_volumeunit,
	@ord_countunit = stp_countunit
  FROM stops
  WHERE mov_number = @mov_number
  AND stp_sequence = @drp_stp

 /* get the stp_number for the first PUP and last DRP */
 SELECT @pup_stp = MIN(stp_number)
 FROM stops 
 WHERE mov_number = @mov_number
 AND stp_sequence = (SELECT MIN(s2.stp_sequence) 
			FROM stops s2
			WHERE s2.mov_number = @mov_number 
			and stp_type='PUP')

 IF @pup_stp IS NULL
 BEGIN
	SELECT @pup_stp = MIN(stp_number)
	  FROM stops 
	 WHERE mov_number = @mov_number
	   AND stp_sequence = (SELECT MIN(s2.stp_sequence)
				 FROM stops s2
				WHERE s2.mov_number = @mov_number
				  AND stp_event in ('IBBT','IBMT'))
 END

 SELECT @drp_stp = MAX(stp_number)
 FROM stops 
 WHERE mov_number = @mov_number
 AND stp_sequence = (SELECT MAX(s2.stp_sequence) 
			FROM stops s2
			WHERE s2.mov_number = @mov_number 
			and stp_type='DRP')

 IF @drp_stp IS NULL
 BEGIN
	SELECT @drp_stp = MAX(stp_number)
	  FROM stops
	 WHERE mov_number = @mov_number
	   AND stp_sequence = (SELECT MAX(s2.stp_sequence)
				 FROM stops s2
				WHERE s2.mov_number = @mov_number
				  AND stp_event IN ('IEBT','IEMT'))
 END

  IF @drp_stp IS NULL or @pup_stp IS NULL
    BEGIN
      IF @validate != 'N'
            BEGIN
             SELECT @err_ret = -4
	     GOTO ERROR_EXIT
            END
       ELSE
            RETURN -4
    END

 /* Default on booked by is DX   */
    SELECT @ord_bookedby = CASE ISNULL(@ord_bookedby,'') WHEN '' THEN UPPER(ISNULL(@ls_ord_bookedby,'DX')) ELSE @ord_bookedby END

 /* order by  */
    SELECT @orderby_cmpid = CASE ISNULL(@orderby_cmpid,'') WHEN '' THEN ISNULL(@ls_ord_orderby,'UNKNOWN') ELSE @orderby_cmpid END
    IF @orderby_cmpid <> 'UNKNOWN'
      BEGIN
         IF (SELECT COUNT(1)
             FROM company
             WHERE cmp_id =  @orderby_cmpid) = 0 
           BEGIN
             SELECT @err_ret = -6
	     GOTO ERROR_EXIT
            END 
      END  

 /* bill to */ 
    SELECT @ord_billto_cmpid = CASE ISNULL(@ord_billto_cmpid,'') WHEN '' THEN ISNULL(@ls_ord_billto,'UNKNOWN') ELSE @ord_billto_cmpid END
    IF @ord_billto_cmpid <> 'UNKNOWN'
      BEGIN
         IF (SELECT COUNT(1)
             FROM company
             WHERE cmp_id =  @ord_billto_cmpid) = 0 
           BEGIN
             SELECT @err_ret = -5
	     GOTO ERROR_EXIT
            END    
      END
      
 /* supplier */
	SELECT @ord_supplier_cmpid = CASE ISNULL(@ord_supplier_cmpid,'') WHEN '' THEN 'UNKNOWN' ELSE @ord_supplier_cmpid END
	IF @ord_supplier_cmpid <> 'UNKNOWN'
		BEGIN
			IF (SELECT COUNT(1)
				FROM company
				WHERE cmp_id = @ord_supplier_cmpid) = 0
			  BEGIN
				SELECT @err_ret = -17
			GOTO	ERROR_EXIT
			  END
		END	  			 


 SELECT @ord_originpoint=origin.cmp_id, @ord_destpoint = dest.cmp_id, 
	@ord_origincity = origin.stp_city, @ord_destcity = dest.stp_city, 
	@ord_originstate = oc.cty_state, @ord_deststate = dc.cty_state, 
	@ord_originzip = ISNULL(origin.stp_zipcode,''), @ord_destzip = ISNULL(dest.stp_zipcode,''),
	@ord_originregion1 = oc.cty_region1, @ord_destregion1 = dc.cty_region1,
	@ord_startdate = origin.stp_arrivaldate, @ord_completiondate = dest.stp_departuredate,
	@ord_originregion2 = oc.cty_region2, @ord_originregion3 = oc.cty_region3, 	
	@ord_originregion4 = oc.cty_region4, @ord_destregion2  = dc.cty_region2, 
	@ord_destregion3 = dc.cty_region3, @ord_destregion4 = dc.cty_region4,
	--@cmd_code = dest.cmd_code, @cmd_name=dest.stp_description,  --5/4 changed from origin. to dest.
	@ord_origin_earliestdate = origin.stp_schdtearliest,
	@ord_origin_latestdate = origin.stp_schdtlatest, 
	@ord_dest_earliestdate = dest.stp_schdtearliest,
	@ord_dest_latestdate = dest.stp_schdtlatest
 FROM stops origin, stops dest, city oc, city dc
 WHERE origin.stp_number=@pup_stp and
	dest.stp_number=@drp_stp and
	origin.stp_city = oc.cty_code and
	dest.stp_city = dc.cty_code
	
 SELECT @cmd_stp = (SELECT TOP 1 stp_number FROM stops 
					 WHERE mov_number = @mov_number AND ISNULL(stp_description,'UNKNOWN') <> 'UNKNOWN' ORDER BY stp_sequence)
 IF ISNULL(@cmd_stp, 0) > 0
	SELECT @cmd_code = cmd_code, @cmd_name = stp_description FROM stops WHERE stp_number = @cmd_stp
 ELSE
	SELECT @cmd_code = 'UNKNOWN', @cmd_name = 'UNKNOWN'

 /* pickup rev types from bill to company if requested */
   SELECT @pickup_revtypes_from_billto = UPPER(ISNULL(@pickup_revtypes_from_billto,'N'))
   If LEN(RTRIM(@pickup_revtypes_from_billto)) = 0 SELECT @pickup_revtypes_from_billto = 'N'

   IF @pickup_revtypes_from_billto = 'Y'
     BEGIN
       SELECT @ord_revtype1 = cmp_revtype1,@ord_revtype2 = cmp_revtype2,
              @ord_revtype3 = cmp_revtype3,@ord_revtype4 = cmp_revtype4
       FROM company 
       WHERE cmp_id = @ord_billto_cmpid
     END

   if @ls_revtypesource is not null
   begin
	if @ls_revtypesource = 'S'
	        select @ls_ord_revtype1 = case isnull(@ls_ord_revtype1,'') when '' then cmp_revtype1 else @ls_ord_revtype1 end,
	               @ls_ord_revtype2 = case isnull(@ls_ord_revtype2,'') when '' then cmp_revtype2 else @ls_ord_revtype2 end,
	               @ls_ord_revtype3 = case isnull(@ls_ord_revtype3,'') when '' then cmp_revtype3 else @ls_ord_revtype3 end,
	               @ls_ord_revtype4 = case isnull(@ls_ord_revtype4,'') when '' then cmp_revtype4 else @ls_ord_revtype4 end
	        from company
	        where company.cmp_id = @ord_originpoint
	
	else if @ls_revtypesource = 'C'
	        select @ls_ord_revtype1 = case isnull(@ls_ord_revtype1,'') when '' then cmp_revtype1 else @ls_ord_revtype1 end,
	               @ls_ord_revtype2 = case isnull(@ls_ord_revtype2,'') when '' then cmp_revtype2 else @ls_ord_revtype2 end,
	               @ls_ord_revtype3 = case isnull(@ls_ord_revtype3,'') when '' then cmp_revtype3 else @ls_ord_revtype3 end,
	               @ls_ord_revtype4 = case isnull(@ls_ord_revtype4,'') when '' then cmp_revtype4 else @ls_ord_revtype4 end
	        from company 
	        where company.cmp_id = @ord_destpoint
	
	else if @ls_revtypesource = 'B'			 	
	        select @ls_ord_revtype1 = case isnull(@ls_ord_revtype1,'') when '' then cmp_revtype1 else @ls_ord_revtype1 end,
	               @ls_ord_revtype2 = case isnull(@ls_ord_revtype2,'') when '' then cmp_revtype2 else @ls_ord_revtype2 end,
	               @ls_ord_revtype3 = case isnull(@ls_ord_revtype3,'') when '' then cmp_revtype3 else @ls_ord_revtype3 end,
	               @ls_ord_revtype4 = case isnull(@ls_ord_revtype4,'') when '' then cmp_revtype4 else @ls_ord_revtype4 end
	        from company 
	        where company.cmp_id = @ord_billto_cmpid
   end 

   SELECT @ord_revtype1 = CASE WHEN ISNULL(@ord_revtype1,'') IN ('','UNK') THEN ISNULL(@ls_ord_revtype1,'UNK') ELSE @ord_revtype1 END
   SELECT @ord_revtype2 = CASE WHEN ISNULL(@ord_revtype2,'') IN ('','UNK') THEN ISNULL(@ls_ord_revtype2,'UNK') ELSE @ord_revtype2 END
   SELECT @ord_revtype3 = CASE WHEN ISNULL(@ord_revtype3,'') IN ('','UNK') THEN ISNULL(@ls_ord_revtype3,'UNK') ELSE @ord_revtype3 END
   SELECT @ord_revtype4 = CASE WHEN ISNULL(@ord_revtype4,'') IN ('','UNK') THEN ISNULL(@ls_ord_revtype4,'UNK') ELSE @ord_revtype4 END
   SELECT @ord_currency = CASE ISNULL(@ord_currency,'') WHEN '' THEN 'US$' ELSE @ord_currency END
   SELECT @lgh_type1 = CASE ISNULL(@lgh_type1,'') WHEN '' THEN 'UNK' ELSE @lgh_type1 END
   IF @validate = 'Y'
   BEGIN 
     IF @pickup_revtypes_from_billto <> 'Y'
     BEGIN
       IF (SELECT COUNT(1)
           FROM labelfile
           WHERE labeldefinition = 'RevType1'
           AND abbr = @ord_revtype1) = 0
 	  BEGIN
	   SELECT @err_ret = -7
	   GOTO ERROR_EXIT
          END
	IF (SELECT COUNT(1)
           FROM labelfile
           WHERE labeldefinition = 'RevType2'
           AND abbr = @ord_revtype2) = 0
 	BEGIN
	  SELECT @err_ret = -8
	  GOTO ERROR_EXIT
        END
	IF (SELECT COUNT(1)
           FROM labelfile
           WHERE labeldefinition = 'RevType3'
           AND abbr = @ord_revtype3) = 0
 	BEGIN
	  SELECT @err_ret = -9
	  GOTO ERROR_EXIT
        END
	IF (SELECT COUNT(1)
           FROM labelfile
           WHERE labeldefinition = 'RevType4'
           AND abbr = @ord_revtype4) = 0
 	BEGIN
	  SELECT @err_ret = -10
	  GOTO ERROR_EXIT
        END
      END
      IF (SELECT COUNT(1)
         FROM labelfile
         WHERE labeldefinition = 'LghType1'
         AND abbr = @lgh_type1) = 0
      BEGIN
        SELECT @err_ret = -14
        GOTO ERROR_EXIT
      END
      IF (SELECT COUNT(1)
         FROM labelfile
         WHERE labeldefinition = 'Currencies'
         AND abbr = @ord_currency) = 0
      BEGIN
        SELECT @err_ret = -15
        GOTO ERROR_EXIT
      END
    END

 SELECT @ls_ord_format = UPPER(ISNULL(@ls_ord_format,''))
 IF @ls_ord_format = 'TERMINALPREFIX9' AND @ord_revtype1 <> 'UNK'
 BEGIN
	SELECT @ls_ord_format = 'ORD' + left(@ord_revtype1,3)
	EXEC @@ord_number = dbo.getsystemnumber @ls_ord_format, NULL
 END
		
 SELECT @ord_stopcount =count(1) from stops
 WHERE mov_number = @mov_number

 /* edit reference number type */
 SELECT @ord_reftype = UPPER(@ord_reftype)

 IF ISNULL(@ordsource,'') > ''
	SELECT @ord_ediflag = 'EDI'
 ELSE
	SELECT @ordsource = null

  /* update the order header number on the stops, one at a time to avoid trigger probs */
  SELECT @next_stpnumber = 0
  WHILE 1 = 1
    BEGIN
	  IF @dispatch_status = 'STD'
		SELECT @stp_status = CASE WHEN @next_stpnumber = 0 THEN 'DNE' ELSE 'OPN' END
      SELECT @next_stpnumber = MIN(stp_number)
      FROM stops
      WHERE mov_number = @mov_number
      AND stp_number > @next_stpnumber
     
      IF @next_stpnumber IS NULL BREAK

      SELECT @ls_default_event = '', @ls_auto_add_pul_flag = ''

      IF @ls_UseCompanyDefaultEventCodes = 'Y'
      BEGIN
	  IF @next_stpnumber = @pup_stp
	      SELECT @ls_default_event = ltsl_default_pickup_event
		FROM company WHERE cmp_id = @ord_originpoint
	  IF @next_stpnumber = @drp_stp
	      SELECT @ls_default_event = ltsl_default_delivery_event
		   , @ls_auto_add_pul_flag = ltsl_auto_add_pul_flag
	   	FROM company WHERE cmp_id = @ord_destpoint
      END

      IF isnull(@ls_default_event,'') <> ''
	      UPDATE stops
	      SET ord_hdrnumber = @ord_hdrnumber,
		  stp_event = @ls_default_event,
		  stp_status = @stp_status,
		  stp_departure_status = @stp_status,
		  trl_id = @remolque1,
		  stp_screenmode = case @ord_rateby when 'T' then 'STOPS' else 'COMMOD' end,
	          skip_trigger = 1
	      WHERE stp_number = @next_stpnumber
      ELSE
	      UPDATE stops
	      SET ord_hdrnumber = @ord_hdrnumber,
		  stp_status = @stp_status,
		  stp_departure_status = @stp_status,
		  trl_id = @remolque1,
		  stp_screenmode = case @ord_rateby when 'T' then 'STOPS' else 'COMMOD' end,
	          skip_trigger = 1
	      WHERE stp_number = @next_stpnumber

      SELECT @retcode = @@error
      IF @retcode<>0
        BEGIN
	  EXEC dx_log_error 888, 'Update stop with ordhdrnumber Failed', 
                 @retcode, @@ord_number
	  IF @validate != 'N'
            BEGIN
              SELECT @err_ret = -1
	      GOTO ERROR_EXIT
            END
          ELSE
            RETURN -1
        END

      IF isnull(@ls_default_event,'') <> ''
	      UPDATE event
		 SET ord_hdrnumber = @ord_hdrnumber,
		     evt_eventcode = @ls_default_event,
		     evt_status = @stp_status,
		     evt_departure_status = @stp_status,
		     skip_trigger = 1,
			 evt_trailer1 = @remolque1, evt_trailer2 = @remolque2
	       WHERE stp_number = @next_stpnumber
      ELSE
	      UPDATE event
		 SET ord_hdrnumber = @ord_hdrnumber,
		     evt_status = @stp_status,
		     evt_departure_status = @stp_status,
		     skip_trigger = 1,
			 evt_trailer1 = @remolque1, evt_trailer2 = @remolque2
	       WHERE stp_number = @next_stpnumber

      SELECT @retcode = @@error
      IF @retcode<>0
        BEGIN
	  EXEC dx_log_error 888, 'Update event with ordhdrnumber Failed', 
                 @retcode, @@ord_number
	  IF @validate != 'N'
            BEGIN
              SELECT @err_ret = -1
	      GOTO ERROR_EXIT
            END
          ELSE
            RETURN -1
        END

      IF isnull(@ls_auto_add_pul_flag,'') = 'Y'
	EXEC dx_add_event @next_stpnumber, 'PUL', @evt_number OUTPUT

    END

 IF @ord_rateby = 'T'
 BEGIN
 	SELECT @ord_billing_quantity = ISNULL(@ord_billing_quantity,0)
	     , @ord_rate = ISNULL(@ord_rate,0)
	     , @ord_charge = ISNULL(@ord_charge,0)
	IF (@ord_rate = 0 OR @ord_billing_quantity = 0) AND @ord_charge > 0
		SELECT @ord_billing_quantity = 1, @ord_rate = @ord_charge
	IF @ord_rate = 0 AND @ord_charge = 0
		SELECT @ord_billing_quantity = 0
 END

 SELECT @ord_quantity = CASE WHEN ISNULL(@ls_quantity_type,0) > 0 THEN @ord_totalmiles WHEN @ord_rateby = 'T' THEN ISNULL(@ord_billing_quantity,0) ELSE 0 END

 SELECT @fix_billing_quantity = CASE WHEN ISNULL(@ls_quantity_type,0) > 0 THEN @ls_quantity_type WHEN ISNULL(@fix_billing_quantity,0) BETWEEN 0 AND 2 THEN ISNULL(@fix_billing_quantity,0) ELSE 0 END

 INSERT INTO orderheader 
	( ord_company, ord_number, ord_customer, 		--1
	ord_bookdate, ord_bookedby, ord_status, 		--2
	ord_originpoint, ord_destpoint, ord_invoicestatus, 	--3	
	ord_origincity, ord_destcity, ord_originstate, 		--4
	ord_deststate, ord_originregion1, ord_destregion1, 	--5
	ord_supplier, ord_billto, ord_startdate, 		--6
	ord_completiondate, ord_revtype1, ord_revtype2, 	--7
	ord_revtype3, ord_revtype4, ord_totalweight, ord_totalvolume,	--8
	ord_totalpieces, ord_totalmiles, ord_totalcharge, 	--9
	ord_currency, ord_currencydate,  	--10
	ord_hdrnumber, ord_remark, ord_shipper, 		--11
	ord_consignee, ord_pu_at, ord_dr_at, ord_originregion2, ord_originregion3, 	--12
	ord_originregion4, ord_destregion2, ord_destregion3,	--13 
	ord_destregion4, ord_priority, mov_number, 		--14
	ord_showshipper, ord_showcons, ord_subcompany, 		--15
	ord_lowtemp, ord_hitemp, ord_quantity,	                --16
	ord_rate, ord_charge, ord_rateunit, 			--17
	ord_unit, trl_type1, ord_driver1, 			--18
	ord_driver2, ord_tractor, ord_trailer, 			--19
	ord_length, ord_width, ord_height, 			--20	
	ord_lengthunit, ord_widthunit, ord_heightunit,
	ord_reftype, ord_refnum, tar_tariffitem, cmd_code, ord_description, 		--21
	ord_terms, cht_itemcode, ord_origin_earliestdate, 	--22
	ord_origin_latestdate, ord_odmetermiles, ord_stopcount, --23
	ord_dest_earliestdate, ord_dest_latestdate, ref_sid, ref_pickup, ord_cmdvalue, --24
	ord_accessorial_chrg, ord_availabledate, ord_miscqty, ord_tempunits,	--25
	ord_datetaken, ord_totalweightunits, ord_totalvolumeunits,--26 
	ord_totalcountunits, ord_loadtime, ord_unloadtime, 	--27
	ord_drivetime, ord_rateby, tar_tarriffnumber, ord_thirdpartytype1, 	--28
	ord_thirdpartytype2, ord_quantity_type, ord_charge_type, ord_charge_type_lh,    --29 
	ord_ratingquantity, ord_ratingunit,
	ord_edipurpose, ord_edistate, ord_order_source,     --30
    ord_editradingpartner, ord_origin_zip, ord_dest_zip,
    ord_revenue_pay, ord_booked_revtype1)
VALUES ( @orderby_cmpid, @@ord_number, ISNULL(@ls_ord_customer,'UNKNOWN'), 	        	--1
	@ord_bookdate, @ord_bookedby, @dispatch_status, 		        --2
	@ord_originpoint, @ord_destpoint, @ord_invoice_status,		--3
	@ord_origincity, @ord_destcity, @ord_originstate, 	--4
	@ord_deststate, @ord_originregion1, @ord_destregion1, 	--5
	ISNULL(@ord_supplier_cmpid,'UNKNOWN'), @ord_billto_cmpid, @ord_startdate, 		--6
	@ord_completiondate, @ord_revtype1, @ord_revtype2, 	--7
	@ord_revtype3, @ord_revtype4, @ord_totalweight,@ord_totalvolume, --8
	@ord_totalcount, @ord_totalmiles, @ord_charge,			--9
	@ord_currency, @ord_bookdate, 					--10 
	@ord_hdrnumber, @ord_remark, @ord_originpoint,			--11	
	 @ord_destpoint, 'SHP', 'CNS', @ord_originregion2, @ord_originregion3, 	--12
	@ord_originregion4, @ord_destregion2, @ord_destregion3,	--13 
	@ord_destregion4, ISNULL(@ls_ord_priority,'UNK'), @mov_number, 		        --14
	'UNKNOWN', 'UNKNOWN', ISNULL(@ls_ord_subcompany,'UNKNOWN'), 			--15
	0, 0, @ord_quantity,     			--16
	CASE @ord_rateby WHEN 'T' THEN ISNULL(@ord_rate,0) ELSE 0 END, 
	CASE @ord_rateby WHEN 'T' THEN ISNULL(@ord_charge,0) ELSE 0 END,
	CASE WHEN ISNULL(@ls_quantity_type,0) > 0 THEN 'MIL' WHEN @ord_rateby = 'T' AND ISNULL(@ls_ord_rateunit,'UNK') = 'UNK' AND ISNULL(@ord_charge,0) > 0 THEN 'FLT' ELSE ISNULL(@ls_ord_rateunit,'UNK') END, 				--17
	@ord_billing_unit, @trailer_type, 'UNKNOWN', 			--18
	'UNKNOWN', 'UNKNOWN', @remolque1, 			--19
	0.0000, 0.0000, 0.0000, 				--20
	'FET','FET','FET',
	@ord_reftype, @ord_refnum, 'UNKNOWN', @cmd_code, @cmd_name, 	--21
	@terms, CASE WHEN @ord_chargetype <> 'UNK' THEN @ord_chargetype WHEN ISNULL(@ls_quantity_type,0) > 0 THEN 'LHD' WHEN @ord_rateby = 'T' AND ISNULL(@ls_cht_itemcode,'UNK') = 'UNK' AND ISNULL(@ord_charge,0) > 0 THEN 'LHF' ELSE ISNULL(@ls_cht_itemcode,'UNK') END, 
	@ord_origin_earliestdate, 		--22
	@ord_origin_latestdate, -1, @ord_stopcount, 		--23
	@ord_dest_earliestdate, @ord_dest_latestdate, @ls_ref_sid, @ls_ref_pickup, 0.0,      --24	
	0.0000, CASE ISDATE(@ld_available_date) WHEN 0 THEN getdate() ELSE @ld_available_date END, 0.0000, isnull(@ls_ord_tempunits,'Frnht'), 				--25
	getdate(), @ord_weightunit, @ord_volumeunit, 		--26
	@ord_countunit, 0, 0, 					--27
	0, @ord_rateby, 'UNKNOWN', 'UNKNOWN', 			        	--28
	NULL, @fix_billing_quantity, 0,	CASE WHEN ISNULL(@fix_charge,0) BETWEEN 0 AND 1 THEN ISNULL(@fix_charge,0) ELSE 0 END,		--29
	@ord_billing_quantity, CASE WHEN @ord_rateby = 'T' AND @ord_billing_unit = 'UNK' AND ISNULL(@ord_charge,0) > 0 THEN 'FLT' ELSE @ord_billing_unit END,
	@edipurpose, @edistate, @ord_ediflag,
	@ordsource, @ord_originzip, @ord_destzip,	--30
	CASE @ord_rateby WHEN 'T' THEN ISNULL(@ord_charge,0) ELSE null END, @ord_revtype1)

SELECT @retcode = @@error

IF @validate = 'I'
  SELECT @@ord_number = convert(varchar(12), @ord_hdrnumber)  --LTSL2 expects ord_hdrnumber
  
IF @retcode<>0
BEGIN
  EXEC dx_log_error 888, 'INSERT INTO Orderheader Failed', @retcode, @@ord_number
  IF @validate != 'N'
	BEGIN
		SELECT @err_ret = -1
	    GOTO ERROR_EXIT
	END
  ELSE
	RETURN -1
END

--insert tar refnumber
 IF LEN(RTRIM(@ord_reftype)) > 0 AND LEN(RTRIM(@ord_refnum)) > 0
   INSERT INTO referencenumber
      ( ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ref_table,
	ref_sid,
	ref_pickup)
   Values  (@ord_hdrnumber,
	@ord_reftype,
	@ord_refnum,
	1,
	'orderheader',
	'Y',
	Null)

 IF @validate = 'I'
 BEGIN
  EXEC dbo.update_move @mov_number
 END
 ELSE
  EXEC dbo.update_move_light @mov_number
  
 /* if carrier is to be assigned, update events, legheader */
  IF @carrier <> 'UNKNOWN'
	BEGIN
	  SELECT @evt_number = 0 
	  WHILE @evt_number is not null
 		BEGIN
		  SELECT @evt_number = MIN(evt_number)
		  FROM event
		  WHERE stp_number in (SELECT stp_number FROM stops where ord_hdrnumber = @ord_hdrnumber
			AND evt_number > @evt_number)
		  IF @evt_number IS NOT NULL
                    BEGIN
			UPDATE event
			SET evt_carrier = @carrier
			WHERE evt_number = @evt_number
		     SELECT @retcode = @@error
		     IF @retcode<>0
    			BEGIN
			  exec dx_log_error 0, 'Import update carrier in event Failed', @retcode, ''
			 IF @validate != 'N'
                           BEGIN
			         SELECT @err_ret = -1
	   			 GOTO ERROR_EXIT
	                   END
       			 ELSE
           			RETURN -1
    			END
		   END
		END
	  UPDATE legheader
	  SET lgh_carrier = @carrier, lgh_outstatus = @dispatch_status, lgh_type1 = @lgh_type1, lgh_primary_trailer = @remolque1, lgh_primary_pup = @remolque2
	  WHERE mov_number = @mov_number
	  SELECT @retcode = @@error
	  IF @retcode<>0
    	    BEGIN
		EXEC dx_log_error 0, 'Import update carrier in leg Failed', @retcode, ''
		IF @validate != 'N'
                  BEGIN
                   SELECT @err_ret = -1
	   	   GOTO ERROR_EXIT
                  END
       		ELSE
           	  RETURN -1
    	    END

	  EXEC update_assetassignment @mov_number
  END

  IF @carrier = 'UNKNOWN' AND @lgh_type1 <> 'UNK'
	BEGIN
	  UPDATE legheader
	  SET lgh_type1 = @lgh_type1
	  WHERE mov_number = @mov_number
	  SELECT @retcode = @@error
	  IF @retcode<>0
	    BEGIN
		EXEC dx_log_error 0, 'Import update LegType1 in leg Failed', @retcode, ''
		IF @validate != 'N'
		  BEGIN
		   SELECT @err_ret = -1
		   GOTO ERROR_EXIT
		  END
		ELSE
		  RETURN -1
 	    END
	END

  RETURN 1

ERROR_EXIT:
   IF @mov_number > 0
     EXEC purge_delete @mov_number,0
   SELECT 'ERROR dx_create_order_from_stops',@mov_number
   RETURN @err_ret 

GO
