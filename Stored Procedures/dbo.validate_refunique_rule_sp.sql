SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[validate_refunique_rule_sp] @p_billto varchar(8), @p_shipper varchar(8), @p_consignee varchar(8), 
                                       @p_typetoenforce varchar(6), @p_level varchar(18),@p_refnumber varchar(30),
                                       @p_ord int,@p_validate char(1),@p_retval int output
AS

/*
 * 
 * NAME:
 * dbo.validate_refunique_rule_sp
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
DECLARE	@v_returnvalue int, @v_exists int, @v_MinRule int, @v_billto varchar(8),
        @v_consignee varchar(8), @v_shipper varchar(8), @v_level varchar(18)

SELECT @p_retval = 0

IF @p_validate = 'R' 
	
	BEGIN --validate rule only exists once in referencenumber_unique_rule.db	
		SELECT @p_retval = COUNT(*) 
		  FROM referencenumber_unique_rule
		 WHERE rur_billtoid = @p_billto AND
		       rur_shipperid = @p_shipper AND
		       rur_consigneeid = @p_consignee AND
	               rur_reftype = @p_typetoenforce AND
	               rur_level = @p_level		
	END --validate rule only exists once in referencenumber_unique_rule.db


IF @p_validate = 'U' 

   BEGIN --Validate uniqueness

	IF Upper(@p_level) = 'UNKNOWN'
	   BEGIN --uniqueness verified at any level
		
		SELECT @p_retval =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber )			                                              
		 WHERE ref.ref_type        = @p_typetoenforce
		   and ref.ref_number      = @p_refnumber                  
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) and
                       (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) and
                       (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee) 

		SELECT @v_exists =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber ) 					       
		 WHERE ref.ref_type      = @p_typetoenforce
		   and ref.ref_number    = @p_refnumber
                   and ref.ord_hdrnumber = @p_ord
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) and
                       (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) and
                       (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)  

		IF @v_exists > 0 and @p_ord <> 0 
	           BEGIN
	             SELECT @p_retval = 0
	           END
		   
	           --PRINT CAST(@P_RETVAL AS VARCHAR(20))                   
                                                            				 
	   END --uniqueness verified at any level		
	
	IF Upper(@p_level) = 'ORDERHEADER'

	   BEGIN --uniqueness verified at order level
		SELECT @p_retval =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber )			                                              
		 WHERE ref.ref_type        = @p_typetoenforce
		   and ref.ref_number      = @p_refnumber
                   and ref.ref_table = @p_level                  
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) and
                       (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) and
                       (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee) 

		SELECT @v_exists =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber ) 					       
		 WHERE ref.ref_type      = @p_typetoenforce
		   and ref.ref_number    = @p_refnumber
                   and ref.ord_hdrnumber = @p_ord
		   and ref.ref_table = @p_level
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) and
                       (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) and
                       (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)  

		 --PRINT 'return value ' + CAST(@P_RETVAL AS VARCHAR(20))
		 --PRINT 'exists value ' + CAST(@V_EXISTS AS VARCHAR(20))

		IF @v_exists > 0 and @p_ord <> 0 
	           BEGIN
	             SELECT @p_retval = 0
		     --PRINT 'return value updated ' + CAST(@P_RETVAL AS VARCHAR(20))
	           END
		   
	          

	   END --uniqueness verified at order level

	IF Upper(@p_level) = 'STOPS'

	   BEGIN --uniqueness verified at stops level
		
		SELECT @p_retval =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber )			                                              
		 WHERE ref.ref_type        = @p_typetoenforce
		   and ref.ref_number      = @p_refnumber
                   and ref.ref_table = @p_level                  
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee) 
                   and  ref.ref_tablekey in (SELECT stp_number 					   
					       FROM stops AS stp JOIN orderheader as ord ON ( stp.ord_hdrnumber = ord.ord_hdrnumber ) 
					      WHERE (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   				and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   				and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)) 
	               


		SELECT @v_exists =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber ) 					       
		 WHERE ref.ref_type      = @p_typetoenforce
		   and ref.ref_number    = @p_refnumber
                   and ref.ord_hdrnumber = @p_ord
		   and ref.ref_table = @p_level
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)
		   and  ref.ref_tablekey in (SELECT stp_number 					   
					       FROM stops AS stp JOIN orderheader as ord ON ( stp.ord_hdrnumber = ord.ord_hdrnumber ) 
					      WHERE (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   				and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   				and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)) 
	  

		IF @v_exists > 0 and @p_ord <> 0
	           BEGIN
	             SELECT @p_retval = 0
	           END
		   
	           --PRINT CAST(@P_RETVAL AS VARCHAR(20))
		
	   END --uniqueness verified at stops level
	
	IF Upper(@p_level) = 'FREIGHTDETAIL'

	   BEGIN--uniqueness verified at freight level

		SELECT @p_retval =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber )			                                              
		 WHERE ref.ref_type        = @p_typetoenforce
		   and ref.ref_number      = @p_refnumber
                   and ref.ref_table = @p_level                  
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee) 
                   and  ref.ref_tablekey in (SELECT fgt_number 
					       FROM freightdetail 
					      WHERE stp_number in (SELECT stp_number 					                          
							             FROM stops AS stp JOIN orderheader as ord ON (stp.ord_hdrnumber = ord.ord_hdrnumber) 
					                            WHERE (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   					 	      and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   						      and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)))		
	               


		SELECT @v_exists =  count(*) 		  
                  FROM referencenumber AS ref JOIN orderheader as ord ON ( ref.ord_hdrnumber = ord.ord_hdrnumber ) 					       
		 WHERE ref.ref_type      = @p_typetoenforce
		   and ref.ref_number    = @p_refnumber
                   and ref.ord_hdrnumber = @p_ord
		   and ref.ref_table = @p_level
                   and (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)
		   and  ref.ref_tablekey in (SELECT fgt_number 
					       FROM freightdetail 
					      WHERE stp_number in (SELECT stp_number 					                          
							             FROM stops AS stp JOIN orderheader as ord ON ( stp.ord_hdrnumber = ord.ord_hdrnumber ) 
					                            WHERE (@p_billto    = 'UNKNOWN' OR ord.ord_billto    = @p_billto) 
                   					 	      and (@p_shipper   = 'UNKNOWN' OR ord.ord_shipper   = @p_shipper) 
                   						      and (@p_consignee = 'UNKNOWN' OR ord.ord_consignee = @p_consignee)))	

		IF @v_exists > 0 and @p_ord <> 0
	           BEGIN
	             SELECT @p_retval = 0
	           END
		   
	           --PRINT CAST(@P_RETVAL AS VARCHAR(20))	

	   END	--uniqueness verified at freight level

	END --Validate Uniqueness               
			
GO
GRANT EXECUTE ON  [dbo].[validate_refunique_rule_sp] TO [public]
GO
