SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[check_billto_refunique] @p_ord int, @p_refnumber varchar(20), @p_typetoenforce varchar(6),
                                   @p_billto varchar(8), @p_retval int output
AS

/*
 * 
 * NAME:
 * dbo.CHECK_BILLTO_REFUNIQUE
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface.
 *
 * RETURNS:
 * 0  - uniqueness has not been violated 
 * >0 - uniqueness has been violated   
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_ord, int, input, null;
 *       ord_hdrnumber used to get order, stop and freightdetail referencenumbers
 * 002 - @p_refnumber, varchar(20), input, null;
 *       reference number used to determine uniqueness 
 * 003 - @p_refnumber, varchar(6), input, null;
 *       reference type used to determine uniqueness 
 * 004 - @p_billto, varchar(8), input, null;
 *       orderheader billto company used to determine uniqueness 
 * 005 - @p_retval, int, output, null;
 *       return value used to identify if the reference number uniqueness has ben violated 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 09/22/2005 - PTS 20964 - Imari Bremer - Add billto parameter to for unique reference numbers by billto
 **/

DECLARE	@v_returnvalue int, @v_exists int

IF @p_typetoenforce = 'UNK'
	BEGIN
		SELECT @p_retval = 0
	END
ELSE
	BEGIN
		--print 'what is the problem'
		SELECT @p_retval =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber ) 
		 WHERE ref.ref_type = @p_typetoenforce
		   and ref.ref_number = @p_refnumber
                   and ((ref.ref_table='orderheader' and  ord.ord_billto = @p_billto)
		   or
	    	       (ref.ref_tablekey in (SELECT stp_number 					   
					       FROM stops AS stp JOIN orderheader as ord ON ( stp.ord_hdrnumber = ord.ord_hdrnumber ) 
					      WHERE ord.ord_billto = @p_billto) and
	                ref.ref_table='stops')
		   or
		       (ref.ref_tablekey in (SELECT fgt_number 
					       FROM freightdetail 
					      WHERE stp_number in (SELECT stp_number 					                          
							             FROM stops AS stp JOIN orderheader as ord ON ( stp.ord_hdrnumber = ord.ord_hdrnumber ) 
					                            WHERE ord.ord_billto = @p_billto)) and
	                ref.ref_table='freightdetail'))

		SELECT @v_exists =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber ) 
		 WHERE ref.ref_type = @p_typetoenforce
		   and ref.ref_number = @p_refnumber
                   and ref.ord_hdrnumber = @p_ord
                   and ((ref.ref_table='orderheader' and  ord.ord_billto = @p_billto)
		   or
	    	       (ref.ref_tablekey in (SELECT stp_number 					   
					       FROM stops AS stp JOIN orderheader as ord ON ( stp.ord_hdrnumber = ord.ord_hdrnumber ) 
					      WHERE ord.ord_billto = @p_billto and
                                                    ord.ord_hdrnumber = @p_ord) and
	                ref.ref_table='stops')
		   or
		       (ref.ref_tablekey in (SELECT fgt_number 
					       FROM freightdetail 
					      WHERE stp_number in (SELECT stp_number 					                          
							             FROM stops AS stp JOIN orderheader as ord ON ( stp.ord_hdrnumber = ord.ord_hdrnumber ) 
					                            WHERE ord.ord_billto = @p_billto and
                                                                          ord.ord_hdrnumber = @p_ord)) and
	                ref.ref_table='freightdetail'))


		 
		    IF @v_exists > 0 and @p_ord <> 0
                       BEGIN
                          SELECT @p_retval = 0
                       END
                       --PRINT CAST(@P_RETVAL AS VARCHAR(20))
	END
GO
GRANT EXECUTE ON  [dbo].[check_billto_refunique] TO [public]
GO
