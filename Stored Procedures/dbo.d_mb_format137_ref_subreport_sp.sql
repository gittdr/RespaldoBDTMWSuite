SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_mb_format137_ref_subreport_sp] (@ivh_hdrnumber int)
AS  
/**
 * 
 * NAME:
 * dbo.d_mb_format137_ref_subreport_sp
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure returns a single row for ref_type of FPBL with ref_table of either invoiceheader or orderheader 
 * 
 * RETURNS:
 * None
 *
 * PARAMETERS:
 * 001 - @ivh_hdrnumber int
 *       The invoiceheader number for which the ref numbers are to be returned
 *
 * 
 * REVISION HISTORY:
 * 01/06/2010 ? PTS50122 - Tim Mezera ? Created for M&M Transportation MB 137
 *
 **/

begin
If (select ivh_definition from invoiceheader where ivh_hdrnumber = @ivh_hdrnumber) = 'MISC'

	select top 1 (lf.name + ': ' + ref_number) as ref_number
	 from referencenumber
		LEFT OUTER JOIN labelfile lf ON lf.labeldefinition = 'ReferenceNumbers' and lf.abbr = referencenumber.ref_type
	 where ref_tablekey = @ivh_hdrnumber and ref_type = 'FPBL' and ref_table = 'invoiceheader'

else

	select top 1 (lf.name + ': ' + ref_number) as ref_number
	 from referencenumber
		LEFT OUTER JOIN labelfile lf ON lf.labeldefinition = 'ReferenceNumbers' and lf.abbr = referencenumber.ref_type
	 where ref_tablekey = (select ord_hdrnumber from invoiceheader where ivh_hdrnumber = @ivh_hdrnumber)
	 and ref_type = 'FPBL' and ref_table = 'orderheader'

end
GO
GRANT EXECUTE ON  [dbo].[d_mb_format137_ref_subreport_sp] TO [public]
GO
