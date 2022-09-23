SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/*
Stored Procedure dbo.load_label_inv31_sp

	Retrieve "RateBy" labels, except that instead of pulling '$/Dollar', pull '%'.  This 
	is to be used by Kriska's Invoice Format 31 only (at the time of creation).

	The characteristic expression in the main select says, if the name is '$/Dollar', 
	return '%' to the result set; otherwise return the column name to the result set.

	Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	----------------------------------------
	08/18/2003	Vern Jewett		19499	(none)	Original
*/

create procedure [dbo].[load_label_inv31_sp] 
as 

select	replicate('%', sign(charindex('$/Dollar', name)) * 
					sign(charindex(name, '$/Dollar'))) + 
			replicate(name, 1 - (sign(charindex('$/Dollar', name)) * 
					sign(charindex(name, '$/Dollar')))) as name,
		abbr, 
		code 
  from	labelfile 
  where	labeldefinition = 'RateBy'
	and	isnull(retired, 'N') <> 'Y'
  order by name
GO
GRANT EXECUTE ON  [dbo].[load_label_inv31_sp] TO [public]
GO
