SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



--DriverSAT_GetListFromLabelDefinition 'DrvType1'
CREATE  Procedure [dbo].[DriverAwareSuite_GetListFromLabelDefinition] (@labeldefinition varchar(100)='')

As

Set NoCount On

Select left(abbr + '      ',6) + '-' + name as AbbrAndName
into   #TempList
from   labelfile (NOLOCK)
where  labeldefinition=@labeldefinition 
       and 
       retired<>'Y' 
order by abbr

Select 'ALL' as AbbrAndName 
Union ALL
Select AbbrAndName from #TempList




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetListFromLabelDefinition] TO [public]
GO
