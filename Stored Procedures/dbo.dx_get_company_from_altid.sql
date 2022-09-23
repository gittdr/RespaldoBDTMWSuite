SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_get_company_from_altid]
	@alternateid varchar(25),
	@@companyid varchar(8) OUTPUT
	
 AS 

SELECT @@companyid = ''

IF LEN(RTRIM(@alternateid)) = 0
 RETURN -2

IF (SELECT COUNT(1) FROM company WHERE cmp_altid = @alternateid and IsNull(cmp_active,'Y') = 'Y') > 0
 BEGIN
  SELECT @@companyid = MAX(cmp_id) FROM company WHERE cmp_altid = @alternateid and IsNull(cmp_active,'Y') = 'Y'
  RETURN 1
 END
ELSE
 RETURN -1 

GO
GRANT EXECUTE ON  [dbo].[dx_get_company_from_altid] TO [public]
GO
