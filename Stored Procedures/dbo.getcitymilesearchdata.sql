SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[getcitymilesearchdata] @city int,@Xface varchar(30)
As  
/*   
SR 22841 DPETE created 8/2/4 
  Called if the stop on a trip has a city, not a company ID, Returns the text to pass to the mileage interface
  For a city level search
 PTS 40257 (Pauls recode of 25291) 3/12/08
*/ 

Select 
searchlevel = 'C',
searchstring =  Case Left (Upper(@Xface), 1)   -- return depends on interface and any overrides
      When 'A' Then Case Rtrim(IsNull(city.alk_city,'')) 
         WHen '' Then cty_name+','+
             Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End +
             --Case Rtrim(IsNull(alk_county_name,'')) When '' Then Case Rtrim(county_name) When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(alk_county_name) ENd 
             Case Rtrim(IsNull(alk_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(alk_county) ENd 
         Else Rtrim(city.alk_city) +','+ Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End +
             --Case Rtrim(IsNull(alk_county_name,'')) When '' Then Case county_name When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(alk_county_name) ENd 
             Case Rtrim(IsNull(alk_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(alk_county) ENd 
         End
      When 'P' Then Case Rtrim(IsNull(city.rand_city,'')) 
         When '' Then cty_name+','+
             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End +
             --Case Rtrim(IsNull(rand_county_name,'')) When '' Then Case county_name When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(rand_county_name) ENd 
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd  
         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End  +
             --Case Rtrim(IsNull(rand_county_name,'')) When '' Then Case Rtrim(county_name) When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(rand_county_name) ENd 
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd  
         End
      When 'I' Then Case Rtrim(IsNull(city.rand_city,'')) 
         When '' Then cty_name+','+
             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End +
             --Case Rtrim(IsNull(rand_county_name,'')) When '' Then Case county_name When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(rand_county_name) ENd 
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd  
         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End  +
             --Case Rtrim(IsNull(rand_county_name,'')) When '' Then Case Rtrim(county_name) When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(rand_county_name) ENd 
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd  
         End
      Else Rtrim(city.cty_name)+','+city.cty_state+ Case Rtrim(IsNull(county_name,'')) When '' Then '' Else ','+Rtrim(county_name) End
      End, 
city =  Case Left (Upper(@Xface), 1)
     When 'A' Then Case Rtrim(IsNull(city.alk_city,'')) 
         When '' Then cty_name 
         Else Rtrim(city.alk_city) End 
     When 'P' Then Case Rtrim(IsNull(city.rand_city,'')) 
         When '' Then cty_name 
         Else Rtrim(city.rand_city) End 
     When 'I' Then Case Rtrim(IsNull(city.rand_city,'')) 
         When '' Then cty_name 
         Else Rtrim(city.rand_city) End
     Else Rtrim(city.cty_state)End, 
state =  Case Left (Upper(@Xface), 1)
     When 'A' Then Case Rtrim(IsNull(city.alk_state,'')) 
         When '' Then cty_state 
         Else Rtrim(city.alk_state) End
     When 'P' Then Case Rtrim(IsNull(city.rand_state,'')) 
         When '' Then cty_state
         Else Rtrim(city.rand_state) End
     When 'I' Then Case Rtrim(IsNull(city.rand_state,'')) 
         When '' Then cty_state
         Else Rtrim(city.rand_state) End
     Else Rtrim(city.cty_state) End, 
county =  Case Left (Upper(@Xface), 1)
     When 'A' Then Case Rtrim(IsNull(city.alk_county,'')) 
         When '' Then cty_county
         Else Rtrim(city.alk_county) End
     When 'P' Then Case Rtrim(IsNull(city.rand_county,'')) 
         When '' Then cty_county
         Else Rtrim(city.rand_county) End
     When 'I' Then Case Rtrim(IsNull(city.rand_county,'')) 
         When '' Then cty_county
         Else Rtrim(city.rand_county) End
     Else Rtrim(city.cty_county)End, 
nmstct = city.cty_nmstct
From city
Where city.cty_code  = @city

GO
GRANT EXECUTE ON  [dbo].[getcitymilesearchdata] TO [public]
GO
