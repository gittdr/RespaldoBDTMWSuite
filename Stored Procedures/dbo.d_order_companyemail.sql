SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--PTS 46118 JJF 20090717
CREATE PROCEDURE [dbo].[d_order_companyemail] (
	@ord_number	char(12)
)

AS

  SELECT	oce.ord_hdrnumber,
			oce.ce_id,   
			ce.cmp_id,   
			ce.contact_name,   
			ce.email_address,   
			ce.type,   
			ce.ce_phone1,   
			ce.ce_phone1_ext,   
			ce.ce_phone2,   
			ce.ce_phone2_ext,   
			ce.ce_mobilenumber,   
			ce.ce_faxnumber,   
			ce.ce_title,   
			ce.ce_contact_type,
			ce.ce_comment  
			FROM orderheader oh 
				INNER JOIN ordercompanyemail oce on oh.ord_hdrnumber = oce.ord_hdrnumber
				INNER JOIN companyemail ce on oce.ce_id = ce.ce_id
			WHERE oh.ord_number = @ord_number 


GO
GRANT EXECUTE ON  [dbo].[d_order_companyemail] TO [public]
GO
