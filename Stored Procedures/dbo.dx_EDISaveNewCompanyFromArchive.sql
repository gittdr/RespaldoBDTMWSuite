SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[dx_EDISaveNewCompanyFromArchive]
	(@p_identity INT,
	 @@p_cmpid VARCHAR(8) OUTPUT)
AS

DECLARE @ret INT, @cmp_name VARCHAR(100), @cmp_add1 VARCHAR(40), @cmp_add2 VARCHAR(40),
	@cmp_city VARCHAR(18), @cmp_state VARCHAR(2), @cmp_zip VARCHAR(10), @cmp_billto CHAR(1),
	@cmp_phone VARCHAR(20)

SELECT @@p_cmpid = ''

SELECT	@cmp_name = dx_field004,
	@cmp_add1 = CASE RTRIM(ISNULL(dx_field012,'')) WHEN '' THEN dx_field005 ELSE dx_field012 END,
	@cmp_add2 = dx_field006,
	@cmp_city = dx_field007,
	@cmp_state = dx_field008,
	@cmp_zip = dx_field009,
	@cmp_phone = ISNULL(dx_field011,''),
	@cmp_billto = CASE dx_field003 WHEN 'BT' THEN 'Y' ELSE 'N' END
  FROM	dx_archive
 WHERE	dx_ident = @p_identity

EXEC @ret = dx_add_company @@p_cmpid OUTPUT, @cmp_name, @cmp_add1, @cmp_add2,
	@cmp_city, @cmp_state, @cmp_zip, '', '', @cmp_billto, 'Y', 'Y', '',
	'UNK', 'UNK', 'UNK', 'UNK', '', @cmp_phone,'','','UNKNOWN'

IF @ret <> 1
	SELECT @@p_cmpid = ''

RETURN @ret


GO
GRANT EXECUTE ON  [dbo].[dx_EDISaveNewCompanyFromArchive] TO [public]
GO
