SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[fcn_SSRS_RefNumbyOrder]
( 
 @ord_hdrnumber int,
 @ref_type varchar(6)
)

returns varchar(2000)

as
/*************************************************************************
 *
 * NAME:
 * dbo.[fcn_SSRS_RefNumbyOrder]
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Return all values for a reference number type for an orderheader
 *
**************************************************************************

Sample call

select 
dbo.fcn_SSRS_RefNumbyOrder(ord_hdrnumber,'BL#') as [refList]
,*
from orderheader
where ord_hdrnumber = 4195
**************************************************************************
 * RETURNS:
 * varchar(2000)
 *
 * RESULT SETS:
 * varchar(2000)
 *
 * PARAMETERS:
 @ord_hdrnumber int,
 @ref_type varchar(6)
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 4/17/2014 JR Created function
 ***********************************************************/



begin


DECLARE @listStr VARCHAR(2000)
SELECT @listStr = COALESCE(@listStr+',' ,'') + ref_number
FROM 
(select Distinct ref_number
FROM 
referencenumber
where ref_type=@ref_type
and ord_hdrnumber = @ord_hdrnumber
) ParentRef

RETURN  ISNULL(@listStr,'')
 

end
GO
