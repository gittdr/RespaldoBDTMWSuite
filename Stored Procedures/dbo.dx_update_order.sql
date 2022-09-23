SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE      proc [dbo].[dx_update_order] 
(
	@ord_number varchar(12),
	@ord_edistate varchar(6),
	@ord_purpose varchar(1) = 'U',
	@copy_freight_to_pu varchar(1) = 'N'
)
as
/******Change Log ********
*
* 2009.02.20.001 - AR - Updated for fgt_actual_qty and fgt_actual_unit
* 2009.06.10.002 - AR - Fix for Master Order Updates. Orderstate not being set.
*
*/

DECLARE @pws_ordhdrnumber int, @pws_movnumber int, @TotalValue decimal, @TotalUnit varchar(6)
--Aross 01.21.2009
DECLARE @v_orderstate varchar(6)

IF ISNULL(@ord_purpose,'') = '' SELECT @ord_purpose = 'U'

SELECT @pws_ordhdrnumber = ord_hdrnumber, @pws_movnumber = mov_number,@v_orderstate = ord_edistate
FROM orderheader WHERE ord_number = @ord_number

IF ISNULL(@pws_ordhdrnumber,0) = 0 RETURN -2

DECLARE @stp_number int, @cmd_code varchar(8), @cmd_description varchar(60)
SELECT @stp_number = (SELECT TOP 1 stp_number FROM stops
		       WHERE ord_hdrnumber = @pws_ordhdrnumber AND ISNULL(stp_description,'UNKNOWN') <> 'UNKNOWN' 
		       ORDER BY stp_sequence)
IF ISNULL(@stp_number, 0) > 0
BEGIN
	SELECT @cmd_code = cmd_code, @cmd_description = stp_description FROM stops WHERE stp_number = @stp_number
	UPDATE orderheader SET cmd_code = @cmd_code, ord_description = @cmd_description WHERE ord_hdrnumber = @pws_ordhdrnumber
END

IF (SELECT COUNT(DISTINCT ISNULL(fgt_weightunit, 'UNK')) FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP') = 1 
BEGIN
	SET @TotalValue = (SELECT SUM(ISNULL(fgt_weight, 0)) FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP') 
	SET @TotalUnit = (SELECT DISTINCT ISNULL(fgt_weightunit, 'UNK') FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP')
	UPDATE orderheader SET ord_totalweight = @TotalValue, ord_totalweightunits = @TotalUnit WHERE orderheader.ord_hdrnumber = @pws_ordhdrnumber
END

IF (SELECT COUNT(DISTINCT ISNULL(fgt_volumeunit, 'UNK')) FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP') = 1 
BEGIN
	SET @TotalValue = (SELECT SUM(ISNULL(fgt_volume, 0)) FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP')
	SET @TotalUnit = (SELECT DISTINCT ISNULL(fgt_volumeunit, 'UNK') FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP')
	UPDATE orderheader SET ord_totalvolume = @TotalValue, ord_totalvolumeunits = @TotalUnit where orderheader.ord_hdrnumber = @pws_ordhdrnumber
END

IF (SELECT COUNT(DISTINCT ISNULL(fgt_countunit, 'UNK')) FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP') = 1 
BEGIN
	SET @TotalValue =(SELECT SUM(ISNULL(fgt_count, 0)) FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP')
	SET @TotalUnit = (SELECT DISTINCT ISNULL(fgt_countunit, 'UNK') FROM FreightDetail INNER JOIN stops ON FreightDetail.stp_number = stops.stp_number WHERE stops.ord_hdrnumber = @pws_ordhdrnumber AND stp_type ='DRP')
	UPDATE orderheader SET ord_totalpieces = @TotalValue, ord_totalcountunits = @TotalUnit where orderheader.ord_hdrnumber = @pws_ordhdrnumber
END

IF ISNULL(@copy_freight_to_pu,'N') = 'Y'
BEGIN
	DECLARE @pu_stop INT, @pu_freight INT, @dr_stop INT, @dr_freight INT, @dr_refseq INT,
		@weight float, @weightunit varchar(6),
		@count float, @countunit varchar(6), @volume float, @volumeunit varchar(6),
		@reftype varchar(6), @refnum varchar(20), @length float, @lengthunit varchar(6),
		@width float, @widthunit varchar(6), @height float, @heightunit varchar(6),
		@count2 float, @count2unit varchar(6),@actualqty float, @actualunit varchar(6)
	SELECT @pu_stop = stp_number FROM stops WHERE ord_hdrnumber = @pws_ordhdrnumber AND stp_sequence = 1
	IF @pu_stop IS NULL RETURN -3
	UPDATE freightdetail
           SET fgt_weight = 0, fgt_volume = 0, fgt_count = 0
	 WHERE stp_number = @pu_stop AND fgt_sequence = 1
	DELETE freightdetail
	 WHERE stp_number = @pu_stop AND fgt_sequence > 1
	SELECT @dr_stop = 0
	WHILE 1=1
	BEGIN
		SELECT @dr_stop = MIN(stp_number) FROM stops 
		 WHERE ord_hdrnumber = @pws_ordhdrnumber AND stp_type = 'DRP' and stp_number > @dr_stop
		IF @dr_stop IS NULL BREAK
		SELECT @dr_freight = 0
		WHILE 1=1
		BEGIN
			SELECT @dr_freight = MIN(fgt_number) FROM freightdetail
			 WHERE stp_number = @dr_stop AND fgt_number > @dr_freight
			IF @dr_freight IS NULL BREAK
			SELECT @pu_freight = NULL
			SELECT @cmd_code = cmd_code, @cmd_description = fgt_description,
				@weight = fgt_weight, @weightunit = fgt_weightunit,
				@count = fgt_count, @countunit = fgt_countunit,
				@volume = fgt_volume, @volumeunit = fgt_volumeunit,
				@height = fgt_height, @heightunit = fgt_heightunit,
				@length = fgt_length, @lengthunit = fgt_lengthunit,
				@width = fgt_width, @widthunit = fgt_widthunit,
				@count2 = fgt_count2, @count2unit = fgt_count2unit,
				@actualqty = fgt_actual_quantity,@actualunit = fgt_actual_unit
			  FROM freightdetail
			 WHERE fgt_number = @dr_freight
			SELECT @pu_freight = NULL
			EXEC dx_add_neworder_freight_to_stop
				'N', @pu_stop, @cmd_code, @cmd_description, @weight, @weightunit,
				@count, @countunit, @volume, @volumeunit, '', '', 0, '', 0, 
				@length, @lengthunit, @width, @widthunit, @height, @heightunit,
				@count2, @count2unit,@actualqty,@actualunit, @pu_freight OUTPUT
			IF ISNULL(@pu_freight,0) > 0
			BEGIN
				SELECT @dr_refseq = 0
				WHILE 1=1
				BEGIN
					SELECT @dr_refseq = MIN(ref_sequence) FROM referencenumber
					 WHERE ref_tablekey = @dr_freight AND ref_table = 'freightdetail' AND ref_sequence > @dr_refseq
					IF @dr_refseq IS NULL BREAK
					SELECT @reftype = ref_type, @refnum = ref_number
					  FROM referencenumber
					 WHERE ref_tablekey = @dr_freight AND ref_sequence = @dr_refseq and ref_table = 'freightdetail'
					EXEC dx_add_refnumber_to_freight
						@pu_freight, @reftype, @refnum
				END
			END
		END
	END
	--EXEC update_move @pws_movnumber
	--EXEC update_ord @pws_movnumber, 'CMP'
END

IF ISNULL(@ord_edistate,'') > ''
BEGIN	--Aross 1.21.09
 IF ISNULL(@v_orderstate,-1) Not in('10','13','15','25','32','40','41','42','43','45')
	BEGIN
	UPDATE orderheader 
	   SET ord_order_source = 'EDI'
	     , ord_edipurpose = @ord_purpose
	     , ord_edistate = @ord_edistate
		WHERE ord_hdrnumber = @pws_ordhdrnumber
	   SELECT @stp_number = (SELECT TOP 1 stp_number FROM stops
		       WHERE ord_hdrnumber = @pws_ordhdrnumber AND ISNULL(cmp_id,'UNKNOWN') = 'UNKNOWN')
			IF ISNULL(@stp_number, 0) > 0
			BEGIN
				UPDATE orderheader SET ord_status = 'PND', ord_edistate = 41 WHERE ord_hdrnumber = @pws_ordhdrnumber and ord_status = 'AVL'
			END
	 END
ELSE	--Aross 1.21.2009 
	UPDATE orderheader
	   SET ord_order_source = 'EDI'
	   	,ord_edipurpose = @ord_purpose
	 WHERE ord_hdrnumber = @pws_ordhdrnumber  	
END

IF @ord_purpose = 'U'
BEGIN
	EXEC update_ord @pws_movnumber, 'UNK'
	IF @ord_edistate = '20'
		EXEC dx_EDICreateUpdate204 @pws_ordhdrnumber
END

IF ISNUMERIC(@ord_edistate) = 1
	RETURN CONVERT(INT, @ord_edistate)
ELSE
	RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_update_order] TO [public]
GO
