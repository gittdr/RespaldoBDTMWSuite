SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[UD_STOP_LEG_2_FN] (@p_data int, @Header_or_Data varchar(2))	
returns varchar(255) 
AS 
begin 
  declare @return varchar(255) 
  
  SET @Header_or_Data = UPPER(@Header_or_Data)
  
	--PTS 70513 SGB Added distinction for OE and Tripfolder
	--IF @Header_or_Data = 'H' --Header For Stop
	IF @Header_or_Data in ('H','HO') --Header For Stop
	BEGIN
		SET @return = 'ZIP CODE' 
	END
	IF @Header_or_Data = 'HS' --Header for Leg Start City
	BEGIN
		SET @return = 'Start City TZ' 
	END
	IF @Header_or_Data = 'HE' --Header for Leg Start City
	BEGIN
		SET @return = 'End City TZ' 
	END	

    --PTS 70513 SGB Added distinction for OE and Tripfolder
    --IF @Header_or_Data = 'S' -- Stop City 
    IF @Header_or_Data in ('S','SO') -- Stop City 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			ELSE
				CASE isnull(abbr,'') WHEN ''
				THEN 'UNKNOWN'
				ELSE abbr
				END
								
			END,'UNKNOWN')			
		from stops s
		left outer join city c
		on c.cty_code = s.stp_city
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where s.stp_number = @p_data
	END 
	IF @Header_or_Data = 'LS' -- Legheader Start City 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			ELSE
				CASE isnull(abbr,'') WHEN ''
				THEN 'UNKNOWN'
				ELSE abbr
				END
								
			END,'UNKNOWN')					
		from legheader_active l
		left outer join city c
		on c.cty_code = l.lgh_startcity
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where l.lgh_number = @p_data
	END 
	IF @Header_or_Data = 'LE' -- Legheader End City 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			ELSE
				CASE isnull(abbr,'') WHEN ''
				THEN 'UNKNOWN'
				ELSE abbr
				END
								
			END,'UNKNOWN')			
		from legheader_active l
		left outer join city c
		on c.cty_code = l.lgh_endcity
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where l.lgh_number = @p_data
	END 
	IF @Header_or_Data = 'L' -- Legheader TEST 
    BEGIN
		Select @return = 	
		lgh_originzip			
		from legheader_active l
		where l.lgh_number = @p_data
	END 
	IF @Header_or_Data = 'CO' -- Company 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			ELSE
				CASE isnull(abbr,'') WHEN ''
				THEN 'UNKNOWN'
				ELSE abbr
				END
								
			END,'UNKNOWN')		
		from company co
		left outer join city c
		on c.cty_code = co.cmp_city
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where co.cmp_id = @p_data
	END 
	IF @Header_or_Data = 'C' -- City 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			ELSE
				CASE isnull(abbr,'') WHEN ''
				THEN 'UNKNOWN'
				ELSE abbr
				END
								
			END,'UNKNOWN')		
		from city c
		left outer join labelfile on code = c.cty_GMTDelta
		and labeldefinition = 'Timezone'
		where c.cty_code = @p_data
	END 	
	
 
return @return 
END

GO
GRANT EXECUTE ON  [dbo].[UD_STOP_LEG_2_FN] TO [public]
GO
