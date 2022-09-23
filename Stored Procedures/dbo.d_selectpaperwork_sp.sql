SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
	

CREATE   PROCEDURE [dbo].[d_selectpaperwork_sp] 
as

/*
*
* NAME:d_selectpaperwork_sp
* dbo.d_selectpaperwork_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Provide a return SET of all the required documents (paperwork) for a chargetype
*
* RETURNS:  
*
* RESULT SETS: 
* 001 - name 				varchar(20) Paperwork name (labelfile name)
* 002 - abbr				varchar(6)	Paperwork code (labelfile abbreviation)
* 003 - cpw_inv_required 	char		Y or N indicating required to invoice
* 004 - cpw_inv_attach 		char		Y or N indicating attachment to invoice
* 005 - used 				char 		No longer being utilized as of PTS 38771
* PARAMETERS:
*
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* 
* 
* REVISION HISTORY:
* 05/15/07 PTS 34919 - EMK - Created
* 08/07/07 PTS 38793 - EMK - Ignoring retired paperwork
* 08/09/07 PTS 38771 - EMK - Set defaults to 'N' as part of select paperwork window rework
* 06/05/09 pts 47517 DPETE consol to 46106
* 09/14/11 PTS 51905 - SPN - added bdt_required_for_dispatch
*/

SELECT 
	name,
	abbr,
	'N' inv_required, 	--default state is not required  //PTS 38771 Changed from Y to N
	'N' inv_attach,	--default state is do not attach		//PTS 38771 Changed from Y to N
	'N'	used,		--default used on chargetype
	'B' required_for_application,	--PTS 40877 JJF 20080204
	'B' required_for_fgt_event,	--PTS 40877 JJF 20080204
    'N' bdt_inv_attachBC, -- 47517 DPETE (Microdea for Pauls)
    'N' rbdt_inv_attachMisc --47517
    , 'N' AS bdt_required_for_dispatch
FROM labelfile l 
WHERE labeldefinition = 'PaperWork' 
and IsNULL(l.retired,'N') <> 'Y'  
ORDER BY abbr

GO
GRANT EXECUTE ON  [dbo].[d_selectpaperwork_sp] TO [public]
GO
