SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[getcmplocation] @cmpid varchar(8),@DefaultLatitude char(1) ,@DefaultLongitude char(1) ,@Xface varchar(50)
As  
/*
DPETE PTS26309
Returns all location information appropriate to the mileage interface type.  It is up to the
   code to determine which information to use for mapping.  City,state and county names are
   always appropriate to the interface (ALK or RAND)
   latlong is the formatted lat long that can be passed, if '' there is not lat/long data for the company
   zip is simply the zip code
   mapaddress loc is the zip;mapaddress (if zip exists) else the city,state;mapaddress
   address1loc is the zip;address2 (if zip exists) else the city,state;address1 
  zip city is the zip(space)city,state  if there is a zip code, else blank
  citycounty is the city,state,county (if county is specified) else city,state

DPETE 40260 recode Pauls
*/

Select cmp_usestreetaddr = IsNull(cmp_usestreetaddr,'N')
,zip =  RTrim(IsNull(cmp_zip,''))
,latlong = Case IsNull(cmp_latseconds,0)
     When 0 Then ''
     Else
		Convert(varchar(25),Convert(decimal(19,6),Round((abs(cmp_latseconds) / 3600.0), 6))) + 
		Case When cmp_latseconds > 0 Then @defaultLatitude Else Case @DefaultLatitude WHen 'N' Then 'S' Else 'N' End End
		+',' +
		convert(varchar(25),Convert(decimal(19, 6),Round((abs(cmp_longseconds) / 3600.0), 6))) + 
		Case When cmp_longseconds > 0 Then @defaultlongitude Else Case @DefaultLongitude WHen 'W' Then 'E' Else 'W' End End
     END
,mapaddressloc = Case Rtrim(isNull(cmp_mapaddress,'')) 
   WHen '' Then '' 
   Else case Rtrim(ISNull(cmp_zip,'')) 
        When '' Then (Case Upper(@Xface)
			    	When 'A - ALK' Then Case Rtrim(IsNull(city.alk_city,'')) 
			         WHen '' Then cty_name+','+
			             Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End
			         Else Rtrim(city.alk_city) +','+ Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End
			         End
			      When 'P - RAND PC' Then Case Rtrim(IsNull(city.rand_city,'')) 
			         When '' Then cty_name+','+
			             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End 
			         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End 
			         End
			      Else Rtrim(city.cty_name)+','+city.cty_state + ',' + city.cty_county
			      End )+';'+cmp_mapaddress
        Else cmp_zip + ';'+cmp_mapaddress 
        End 
   End
-- put together either zip;address1 or city,state;address1 (zip preferrred)
,address1loc =  Case Rtrim(isNull(cmp_address1,'')) 
   WHen '' Then '' 
   Else case Rtrim(ISNull(cmp_zip,'')) 
        When '' Then (Case Upper(@Xface)
			    	When 'A - ALK' Then Case Rtrim(IsNull(city.alk_city,'')) 
			         WHen '' Then cty_name+','+
			             Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End  
			         Else Rtrim(city.alk_city) +','+ Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End
			         End
			      When 'P - RAND PC' Then Case Rtrim(IsNull(city.rand_city,'')) 
			         When '' Then cty_name+','+
			             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End 
			         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End 
			         End
			      Else Rtrim(city.cty_name)+','+city.cty_state
			      End )+';'+cmp_address1
        Else cmp_zip + ';'+cmp_address1 
        End 
   End
,zipcity = Case Rtrim(IsNull(cmp_zip,'')) 
   When '' Then ''
   Else Rtrim(cmp_zip) + ' ' + Case Upper(@Xface)
    	When 'A - ALK' Then Case Rtrim(IsNull(city.alk_city,'')) 
         WHen '' Then cty_name+','+
             Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End 
         Else Rtrim(city.alk_city) +','+ Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End 
         End
      When 'P - RAND PC' Then Case Rtrim(IsNull(city.rand_city,'')) 
         When '' Then cty_name+','+
             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End 
         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End 
         End
      Else Rtrim(city.cty_name)+','+city.cty_state
      End
   End
,citycounty =  Case Upper(@Xface)   -- return depends on interface and any overrides
      When 'A - ALK' Then Case Rtrim(IsNull(city.alk_city,'')) 
         WHen '' Then cty_name+','+
             Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End +
             Case Rtrim(IsNull(alk_county,'')) When '' Then Case cty_county When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(alk_county) ENd 
         Else Rtrim(city.alk_city) +','+ Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End +
             Case Rtrim(IsNull(alk_county,'')) When '' Then Case cty_county When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(alk_county) ENd 
         End
      When 'P - RAND PC' Then Case Rtrim(IsNull(city.rand_city,'')) 
         When '' Then cty_name+','+
             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End +
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case cty_county When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd 
         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End +
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case cty_county When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd 
         End
      Else Rtrim(city.cty_name)+','+city.cty_state+ Case Rtrim(IsNull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End
      End
From Company,city
Where  cmp_id = @cmpid
and city.cty_code = cmp_city

GO
GRANT EXECUTE ON  [dbo].[getcmplocation] TO [public]
GO
