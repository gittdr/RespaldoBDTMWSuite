SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE   Procedure [dbo].[DriverAwareSuite_AutoCompleteExpirations] 
        (@ExcludeExpCodesList Varchar(255) ='LIC,PHYS',
	     @AsgnType varchar(50) = 'DRV'
 ) 

As 

Set @ExcludeExpCodesList  = ',' + @ExcludeExpCodesList  + ',' 
update expiration 
        set exp_completed = 'Y',
	    exp_updateby = 'AUTO',
	    exp_updateon = GETDATE()
        where 
            expiration.exp_compldate <= GETDATE()
	    	And
            ISNULL(expiration.exp_completed, 'N') = 'N' 
	    	and 
            (@ExcludeExpCodesList = ',,' OR Not (CHARINDEX(',' + exp_code + ',', @ExcludeExpCodesList) > 0)) 
            and
	    	exp_idtype = @AsgnType




GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_AutoCompleteExpirations] TO [public]
GO
