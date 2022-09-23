SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[dx_custom_company_search]
	@tpid VARCHAR(20),
	@edi_location VARCHAR(30),
	@@cmp_id VARCHAR(8) OUTPUT
/**
 * 
 * NAME:
 * dbo.dx_custom_company_search
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Executes custom company search logic for LTSL2.0
 *
 * PARAMETERS:
 * 001 - @tpid,varchar(20)t, input, not null;
 *       This parameter indicatestrading partner to which the company store location is linked to
 * 002 - @edi_location varchar(30) intput,null;
 *	  This parameter indicates the edi location code being searched
 *RETURNS
 * REFERENCES:
 * CALLS
 * 
 * REVISION HISTORY:
 * 08/29/2008.01 - A. Rossman - Initial release.
 *
 **/
AS

SELECT @@cmp_id = 'UNKNOWN'

IF ISNULL(@edi_location,'') = '' RETURN 1

IF ISNULL(@tpid,'') IN ('','UNKNOWN') RETURN 1

IF (SELECT COUNT(1) FROM company_xref WHERE cmp_name = RTRIM(@edi_location) AND src_tradingpartner =RTRIM(@tpid)) = 1
	SELECT @@cmp_id = MAX(cmp_id) FROM company_xref WHERE cmp_name = RTRIM(@edi_location) AND src_tradingpartner = RTRIM(@tpid)

RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_custom_company_search] TO [public]
GO
