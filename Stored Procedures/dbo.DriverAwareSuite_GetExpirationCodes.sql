SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO









CREATE    Procedure [dbo].[DriverAwareSuite_GetExpirationCodes] (@OverrideDispExp char(1) = 'Y')

as


		Select  IsNull(Abbr,'') as Abbr, 
			IsNull(name,'') as Name 
		from    labelfile (NOLOCK) 
		where   labeldefinition='DrvExp' 
        		and 
        		IsNull(retired,'')<>'Y' 
			and
			(
	  		  (@OverrideDispExp = 'Y')
	  		  OR
	  		  --If
	  		  (@OverrideDispExp = 'N' And labelfile.code >= 200)
			)
			--and --eliminate any In Service Create/Move Expirations from being displayed from the list
			--IsNull(create_move,'N') = 'N'
		order by Abbr
	





GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetExpirationCodes] TO [public]
GO
