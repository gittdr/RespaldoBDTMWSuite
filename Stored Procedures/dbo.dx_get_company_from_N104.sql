SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_get_company_from_N104]
	@ord_billto varchar(8),
	@edi_location varchar(30),
	@@cmp_id varchar(8) OUTPUT
as

/*******************************************************************************************************************  
  Object Description:
  dx_get_company_from_N104

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

select @@cmp_id = 'UNKNOWN'

if isnull(@edi_location,'') = '' return 1

if isnull(@ord_billto,'') in ('','UNKNOWN') return 1

if (select count(1) from cmpcmp where billto_cmp_id = @ord_billto and ediloc_code = @edi_location) = 1
	select @@cmp_id = cmp_id from cmpcmp where billto_cmp_id = @ord_billto and ediloc_code = @edi_location

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_get_company_from_N104] TO [public]
GO
