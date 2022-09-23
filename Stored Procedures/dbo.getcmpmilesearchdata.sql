SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
Create Proc [dbo].[getcmpmilesearchdata] @cmpid varchar(8),@DefaultLatitude char(1) ,@DefaultLongitude char(1) ,@Xface varchar(50), @precision integer = 4, @includeaddress varchar(1) = 'N'
As  
/*   
SR 22841 DPETE created 8/2/4 
  cmp_milesearchlevel M = Manual, A = zip;Address, L = latlong, Z = zip, C = city state
  For level M return the company ID (cache level searchonly)
  For level A return zip + semicolon + address (map address if specified else address1)
  For level L return lat plus comma plus long converted from seconds to decimal
  For level C return city name plus comma pplus state plus comma plus county (if specified) use xface overrides if any
  For level Z return the zip code
  If level is  NULL, C is assumed
 NOTE: not sure if data passed to Rand is the same as that for ALK (the model)

 PTS 40257 (recode of Pauls Hauling 25291
*/ 
SET NOCOUNT ON
declare @cmp_milesearchlevel char (1)
SELECT @cmp_milesearchlevel = ISNull (cmp_milesearchlevel,'C') from company where cmp_id = @cmpid
SELECT @Xface = LEFT (Upper (@Xface),1)
if @Xface = 'I'
	begin
	if @cmp_milesearchlevel = 'A' or @cmp_milesearchlevel = 'L' 
		select @cmp_milesearchlevel = 'C'
	end
if @Xface = 'P'
	begin
	if @cmp_milesearchlevel = 'A' or @cmp_milesearchlevel = 'L' 
		select @cmp_milesearchlevel = 'C'
	end
Select 
SearchLevel = @cmp_milesearchlevel,
Searchstring = Case  @cmp_milesearchlevel
  When 'M' Then cmp_id
  WHen 'A' Then Case Rtrim(IsNull(cmp_mapaddress,''))
              When '' Then Rtrim(IsNull(cmp_zip,''))+';'+Rtrim(cmp_address1)
              Else Rtrim(IsNull(cmp_zip,''))+';'+Rtrim(cmp_mapaddress)
              End
  When 'L' Then 
		case @precision 
		when 6 then --PTS92864
			convert(varchar(25),Convert(decimal(19,6),Round((abs(cmp_latseconds) / 3600.0),6))) + 
				Case When cmp_latseconds > 0 Then @defaultLatitude Else Case @DefaultLatitude WHen 'N' Then 'S' Else 'N' End End
			+',' +
			convert(varchar(25),Convert(decimal(19,6),Round((abs(cmp_longseconds) / 3600.0),6))) + 
				Case When cmp_longseconds > 0 Then @defaultlongitude Else Case @DefaultLongitude WHen 'W' Then 'E' Else 'W' End End
		when 5 then 
			convert(varchar(25),Convert(decimal(19,5),Round((abs(cmp_latseconds) / 3600.0),5))) + 
				Case When cmp_latseconds > 0 Then @defaultLatitude Else Case @DefaultLatitude WHen 'N' Then 'S' Else 'N' End End
			+',' +
			convert(varchar(25),Convert(decimal(19,5),Round((abs(cmp_longseconds) / 3600.0),5))) + 
				Case When cmp_longseconds > 0 Then @defaultlongitude Else Case @DefaultLongitude WHen 'W' Then 'E' Else 'W' End End
		else 
			convert(varchar(25),Convert(decimal(19,4),Round((abs(cmp_latseconds) / 3600.0),4))) + 
				Case When cmp_latseconds > 0 Then @defaultLatitude Else Case @DefaultLatitude WHen 'N' Then 'S' Else 'N' End End
			+',' +
			convert(varchar(25),Convert(decimal(19,4),Round((abs(cmp_longseconds) / 3600.0),4))) + 
				Case When cmp_longseconds > 0 Then @defaultlongitude Else Case @DefaultLongitude WHen 'W' Then 'E' Else 'W' End End
		end
		+ case @includeaddress
			when 'Y' then 
				case cmp_usestreetaddr when 'Y' then case isnull (cmp_mapaddress,'') when '' then '' else ';' + cmp_mapaddress end
			                                     else case isnull (cmp_address1, '') when '' then '' else ';' + cmp_address1 end 
			   end else '' end
		 
  	/* 12/07/2010 MDH PTS 54467: Added check for new GI setting */
  	/* 03/07/2011 MDH PTS 56058: Changed to use GI String 3 */
    When 'Z' Then
    	CASE ISNull (gi_string3, 'N') 
    		WHEN 'Y' THEN
			     RTrim(IsNull(cmp_zip,''))+' '+  
					Case  @Xface
						When 'A' Then Case Rtrim(IsNull(city.alk_city,''))   
				            WHen '' Then cty_name+','+  
				              Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End   
				            Else Rtrim(city.alk_city) +','+ Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End   
				            End  
						When 'P' Then Case Rtrim(IsNull(city.rand_city,''))   
					         When '' Then cty_name+','+  
					             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End   
					         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End   
					         End  
						When 'I' Then Case Rtrim(IsNull(city.rand_city,''))   
					         When '' Then cty_name+','+  
					             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End   
					         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End   
					         End  
			      		Else Rtrim(city.cty_name)+','+city.cty_state  
			      	END
			ELSE RTrim(IsNull(cmp_zip,''))
		END
  WHen 'C' Then Case @Xface   -- return depends on interface and any overrides
      When 'A' Then Case Rtrim(IsNull(city.alk_city,'')) 
         WHen '' Then cty_name+','+
             Case Rtrim(IsNull(alk_state,'')) WHen '' Then cty_state Else Rtrim(alk_state) End +
             --Case Rtrim(IsNull(alk_county_name,'')) When '' Then Case county_name When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(alk_county_name) ENd 
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
         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End +
             --Case Rtrim(IsNull(rand_county_name,'')) When '' Then Case county_name When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(rand_county_name) ENd 
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd  
         End
      When 'I' Then Case Rtrim(IsNull(city.rand_city,'')) 
         When '' Then cty_name+','+
             Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End +
             --Case Rtrim(IsNull(rand_county_name,'')) When '' Then Case county_name When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(rand_county_name) ENd
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd  
         Else Rtrim(city.rand_city)+',' + Case Rtrim(IsNull(rand_state,'')) WHen '' Then cty_state Else Rtrim(rand_state) End +
             --Case Rtrim(IsNull(rand_county_name,'')) When '' Then Case county_name When '' Then '' Else ','+Rtrim(county_name) End Else ','+Rtrim(rand_county_name) ENd 
             Case Rtrim(IsNull(rand_county,'')) When '' Then Case rtrim(isnull(cty_county,'')) When '' Then '' Else ','+Rtrim(cty_county) End Else ','+Rtrim(rand_county) ENd  
         End
      Else Rtrim(city.cty_name)+','+city.cty_state+ Case Rtrim(IsNull(county_name,'')) When '' Then '' Else ','+Rtrim(county_name) End
      End
  Else '?'
  End
,cmp_city = IsNull(cmp_city,0),
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
     Else Rtrim(city.cty_state) End, 
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
     Else Rtrim(city.cty_county) End,
zip = cmp_zip, 
nmstct = city.cty_nmstct
From company join city on city.cty_code = cmp_city, generalinfo
Where cmp_id = @cmpid
and gi_name = 'DistanceLookupVersion'

GO
GRANT EXECUTE ON  [dbo].[getcmpmilesearchdata] TO [public]
GO
