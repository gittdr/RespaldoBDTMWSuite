SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Created 02/15/02 to list the security code information bases on shipper,consigee or supplier

CREATE PROCEDURE [dbo].[get_securitycode_sp] (@shipper varchar(8),@consignee varchar(8),@supplier varchar(6))				
AS
SELECT notescomb.shipper,   
         notescomb.consignee,   
         notescomb.supplier,   
         notescomb.security_note,   
         notescomb.created,   
         notescomb.created_by,   
         notescomb.updated,   
         notescomb.updated_by  
    FROM notescomb
   WHERE @Shipper in ( 'UNKNOWN',shipper) and
	 @consignee in ('UNKNOWN',consignee) and
	 @supplier in ('UNK',supplier) 

GO
GRANT EXECUTE ON  [dbo].[get_securitycode_sp] TO [public]
GO
