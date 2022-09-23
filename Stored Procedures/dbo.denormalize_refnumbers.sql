SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[denormalize_refnumbers](	@reftable 	varchar(30), 
						@tablekey 	int )

as
declare @refseq int

/*EXECUTE timerins "denormalize_refnumbers", "START"*/

SELECT @refseq = MIN(referencenumber.ref_sequence)
	FROM referencenumber
	WHERE referencenumber.ref_tablekey = @tablekey  AND
			referencenumber.ref_table = @reftable AND
			referencenumber.ref_sequence > 0
			
if ( @refseq Is Not null and @refseq <> 1)
	BEGIN
	UPDATE referencenumber
	SET 	referencenumber.ref_sequence = 1
	FROM referencenumber
	WHERE referencenumber.ref_tablekey = @tablekey  AND
			referencenumber.ref_table = @reftable AND
			referencenumber.ref_sequence = @refseq
	
	END


if @reftable = 'stops'
	BEGIN
	UPDATE stops
		SET stops.stp_reftype = referencenumber.ref_type,
	 		 stops.stp_refnum	= referencenumber.ref_number
	FROM stops, referencenumber
	WHERE referencenumber.ref_tablekey = stops.stp_number and
			stops.stp_number = @tablekey AND
			referencenumber.ref_table = @reftable AND
			referencenumber.ref_sequence = 1 AND 
         (referencenumber.ref_type <> stops.stp_reftype OR
          referencenumber.ref_number <> stops.stp_refnum)
			
	END
ELSE IF @reftable = 'freightdetail'
	BEGIN
	UPDATE freightdetail
		SET freightdetail.fgt_reftype = referencenumber.ref_type,
	 		 freightdetail.fgt_refnum	= referencenumber.ref_number
	FROM freightdetail, referencenumber
	WHERE referencenumber.ref_tablekey = freightdetail.fgt_number and
			freightdetail.fgt_number = @tablekey AND
			referencenumber.ref_table = @reftable AND
			referencenumber.ref_sequence = 1 AND 
         (referencenumber.ref_type <> freightdetail.fgt_reftype OR
          referencenumber.ref_number <> freightdetail.fgt_refnum)
		
	END
ELSE IF @reftable = 'orderheader'
	BEGIN
	UPDATE orderheader
		SET orderheader.ord_reftype = referencenumber.ref_type,
	 		 orderheader.ord_refnum	= referencenumber.ref_number,
			 orderheader.ref_sid		= referencenumber.ref_sid,   
          orderheader.ref_pickup	= 	 referencenumber.ref_pickup		
	FROM orderheader, referencenumber
	WHERE referencenumber.ref_tablekey = orderheader.ord_hdrnumber and
			orderheader.ord_hdrnumber = @tablekey AND
			referencenumber.ref_table = @reftable AND
			referencenumber.ref_sequence = 1 AND 
         (referencenumber.ref_type <> orderheader.ord_reftype OR
          referencenumber.ref_number <> orderheader.ord_refnum)
		
	END
ELSE IF @reftable = 'invoiceheader'
	BEGIN
	UPDATE invoiceheader
		SET invoiceheader.ivh_ref_number	= referencenumber.ref_number,
          invoiceheader.ivh_reftype = referencenumber.ref_type
	FROM invoiceheader, referencenumber
	WHERE referencenumber.ref_tablekey = invoiceheader.ivh_hdrnumber and
			invoiceheader.ivh_hdrnumber = @tablekey AND
			referencenumber.ref_table = @reftable AND
			referencenumber.ref_sequence = 1 AND 
         (referencenumber.ref_type <> invoiceheader.ivh_reftype OR
          referencenumber.ref_number <> invoiceheader.ivh_ref_number)
		
	END
/*EXECUTE timerins "denormalize_refnumbers", "END"*/

return

GO
GRANT EXECUTE ON  [dbo].[denormalize_refnumbers] TO [public]
GO
