SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[getcitylocation] @city int ,@Xface varchar(50)
As  
/*
DPETE PTS26309
Returns all location information appropriate to the mileage interface type.  It is up to the
   code to determine which information to use for mapping.  City,state and county names are
   always appropriate to the interface (ALK or RAND)
DPETE 40260 recode Pauls
   
*/
Select citycounty =  Case Upper(@Xface)   -- return depends on interface and any overrides
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
From city
Where cty_code = @city


GO
GRANT EXECUTE ON  [dbo].[getcitylocation] TO [public]
GO
