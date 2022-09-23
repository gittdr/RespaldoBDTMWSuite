SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROC [dbo].[d_loadaccounttype_sp] @p_cust_cmpid varchar(8) = 'UNK' , @p_ship_cmpid varchar(8) = 'UNK'
AS

/**
 * 
 * NAME:
 * dbo.d_loadaccounttype_sp
 *
 * TYPE:
 * [StoredProcedure]
 *
 * DESCRIPTION:
 * This procedure returns a list of account types back to its parent datawindow for selection
 * in the order header (currently)
 *
 * RETURNS:
 * See Selection list
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * @p_cust_cmpid varchar(8) , 
 * @p_ship_cmpid varchar(8)
 * 
 * REVISION HISTORY:
 * 09/14/2006.01 ? PTS 33324 - Phil Bidinger ? Created Proc.
 *                 PTS 33175 - DPETE QA is getting multiple rows in subselect error
 *
 **/

set nocount ON

-- Get all account types that match from the loadpin_relationship table

SELECT abbr = ISNULL(loadpin_relationship.lpr_account, 'UNK'),
       name = (SELECT MIN(name) 
	       FROM labelfile
	       WHERE abbr = ISNULL(loadpin_relationship.lpr_account, 'UNK') and labeldefinition = 'LoadAccount'),
       pin = ISNULL(loadpin_relationship.lpr_pin, '')
FROM loadpin_relationship
WHERE loadpin_relationship.lpr_cust_cmp_id = @p_cust_cmpid AND loadpin_relationship.lpr_ship_cmp_id = @p_ship_cmpid
union
select 'UNK', 'UNKNOWN', ''

set nocount off

GO
GRANT EXECUTE ON  [dbo].[d_loadaccounttype_sp] TO [public]
GO
