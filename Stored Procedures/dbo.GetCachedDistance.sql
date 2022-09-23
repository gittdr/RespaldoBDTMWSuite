SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[GetCachedDistance] @origintype varchar(5) , @origin Varchar(100), @desttype varchar(5), 
           @dest varchar(100), @miletype  tinyint, 
	@haztype int ,@CacheOneWayForMileTYpeOverride char(1) = ''

As  
/*   
SR 22841 DPETE created 8/2/4 
  Called with the origin type and the dest type and the values, returns the mileagetable
  record's distance, time, and identiy column value
 PTS 28437 Add haztype to this version 
8/27/04 DPETE PTS22841 correct name fo GI setting for one way miles
7/20/10 DPETE KAG SR52712 wnats string 2 to be comma sep list of apps to ignore GI Return0Miles
8/13/20 DPETE 53226 add override by mile type for cacheoneway miles If Y or N use it else use GI
*/ 
Declare @temp1 varchar(100),@temp2 varchar(100),@exemptappslist varchar(500), @DistanceCacheOneWay char(1)

select @CacheOneWayForMileTYpeOverride = isnull(@CacheOneWayForMileTYpeOverride,'')

select @DistanceCacheOneWay = Left(Upper(gi_string1),1) From Generalinfo Where gi_name = 'DistanceCacheOneWay'
select @DistanceCacheOneWay = isnull(@DistanceCacheOneWay,'N')
If @CacheOneWayForMileTYpeOverride = 'Y' select  @DistanceCacheOneWay = @CacheOneWayForMileTYpeOverride
If @CacheOneWayForMileTYpeOverride = 'N' select  @DistanceCacheOneWay = @CacheOneWayForMileTYpeOverride

--If Exists (Select gi_string1 From Generalinfo Where gi_name = 'DistanceCacheOneWay' and gi_string1 = 'N') 
IF @DistanceCacheOneWay = 'N'
   If @origin > @dest 
     Begin  
       Select @temp1 = @origintype,@temp2 = @origin
       Select @origintype = @desttype, @origin = @dest
       Select @desttype = @temp1, @dest = @temp2
        
     End

/* PTS 28437 Add haztype to this version */
SELECT @haztype = IsNull (@haztype,0) 

--	LOR	PTS# 48807	check return0miles setting same as miles_between.
if exists (select * from generalinfo where gi_name = 'Return0miles' and substring(gi_string1,1,1) = 'Y'
   and charindex(','+app_name()+',',','+ isnull(gi_string2,':')+',') = 0  )
	select 0,0,0 
else
	Select 
	mt_identity
	,mt_miles
	,mt_hours = IsNull(mt_hours,0.0)
	--PTS 60177 JJF 20120224
	,mt_tolls_cost
	--END PTS 60177 JJF 20120224
	From Mileagetable
	Where mt_origintype = @origintype
	and mt_origin = @origin
	and mt_destinationtype = @desttype
	and mt_destination = @dest
	and mt_type = @miletype
	AND (IsNull(mt_haztype, 0) = @haztype) /* PTS 28437 Add haztype to this version */



GO
GRANT EXECUTE ON  [dbo].[GetCachedDistance] TO [public]
GO
