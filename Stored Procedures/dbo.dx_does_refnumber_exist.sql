SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[dx_does_refnumber_exist]
	@refnumber varchar(30),
	@reftype varchar(6),
	@reftable varchar(18),
	@@reftablekey int OUTPUT
	
 AS 

SELECT @@reftablekey = 0

IF LEN(RTRIM(@refnumber)) = 0
 RETURN -2

IF LEN(RTRIM(@reftype)) = 0
 RETURN -3

IF LOWER(@reftable) IN ('orderheader','stops','freightdetail')
 SELECT @reftable = LOWER(@reftable)
ELSE
 RETURN -4

IF (SELECT COUNT(*) FROM referencenumber 
           WHERE ref_type = @reftype AND ref_number = @refnumber AND ref_table = @reftable) > 0
 BEGIN
  SELECT @@reftablekey = MAX(ref_tablekey) FROM referencenumber
         WHERE ref_type = @reftype AND ref_number = @refnumber AND ref_table = @reftable
  RETURN 1
 END
ELSE
 RETURN 0 


GO
GRANT EXECUTE ON  [dbo].[dx_does_refnumber_exist] TO [public]
GO
